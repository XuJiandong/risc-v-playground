# TODO: optimization
# 1. aggregate pushq operation
# 2. don't carry if not needed (less sltu)
# 3. adcq/sbbq

import re
import argparse
import sys

X64_TO_RISCV_REGS = {
    "rdi": "a0",
    "rsi": "a1",
    "rdx": "a2",
    "rcx": "a3",
    "r8": "a4",
    "r9": "a5",

    "rax": "a6",

    "rsp": "sp",
    "rbp": "fp",
    "rbx": "s1",
    "r10": "t0",
    "r11": "t1",
    "r12": "s2",
    "r13": "s3",
    "r14": "s4",
    "r15": "s5",

    # pseudo x86 register names
    "reg_zero": "zero",  # register zero, 0

    "flag_carry": "t2",  # carry
    "flag_zero": "t3",  # zero
    "flag_sign": "t4",  # sign
    "flag_overflow": "t5",  # overflow

    "temp": "t6",
    "temp2": "a7",
    # s7-s11	-
}

LABEL_INDEX = 0


def gen_label():
    global LABEL_INDEX
    LABEL_INDEX += 1
    return f".LABLE{LABEL_INDEX}"


# make sure values are not duplicated
def check_sanity(mapping):
    map2 = {}
    for key in mapping:
        value = mapping[key]
        if value in map2:
            print(f"{value} is duplicated.")
            assert False
        else:
            map2[value] = 1


check_sanity(X64_TO_RISCV_REGS)


def get_reverse_mapping(mapping):
    result = {}
    for key in mapping:
        result[mapping[key]] = key

    return result


def trans_operand(operand):
    name = operand
    if name[0] == "%":
        name = operand[1:]
    assert name in X64_TO_RISCV_REGS
    return X64_TO_RISCV_REGS[name]


def T(operand):
    return trans_operand(operand)


# internal format of X64Operand is always X64
class X64Operand:
    REG = re.compile(r'%(\w+)')
    MEM = re.compile(r'([\d-]+)\((%\w+)\)')
    IMM = re.compile(r'\$([\w-]+)')
    LBL = re.compile(r'([0-9a-zA-Z_\.]+)')

    # field is with AT&T x86 format
    def __init__(self, field):
        reg = X64Operand.REG.match(field)
        if reg:
            self.type = "reg"
            self.reg = field
            return
        match = X64Operand.MEM.match(field)
        if match:
            imm = match.group(1)
            reg = match.group(2)
            self.type = "mem"
            self.reg = reg
            self.imm = int(imm)
            return
        match = X64Operand.IMM.match(field)
        if match:
            imm = match.group(1)
            self.type = "imm"
            self.reg = None
            self.imm = int(imm)
            return
        match = X64Operand.LBL.match(field)
        if match:
            self.type = "label"
            self.reg = None
            self.imm = 0
            self.label = match.group(1)
            return

        assert False

    def to_riscv(self):
        if self.type == "reg":
            return trans_operand(self.reg)
        elif self.type == "mem":
            return f"{self.imm}({trans_operand(self.reg)})"
        elif self.type == "imm":
            return f"{self.imm}"
        elif self.type == "label":
            return f"{self.label}"
        else:
            assert False

    def load_mem(self):
        global RISCV_TEMP_REG
        assert self.type == "mem"
        r = RISCV_TEMP_REG
        i = RiscvInstruction("ld", r, self)
        return (r, i)


RISCV_TEMP_REG = X64Operand("%temp")
RISCV_TEMP_REG2 = X64Operand("%temp2")


class RiscvInstruction:
    def __init__(self, opcode, *x64_operands, raw=False, directive=False, label=False):
        count = 0
        if raw:
            count += 1
        if directive:
            count += 1
        if label:
            count += 1
        assert count <= 1

        self.raw = False
        self.directive = False
        self.label = False
        self.optimized = False
        self.opcode = False

        if raw:
            self.raw = opcode
            return
        if directive:
            self.directive = opcode
            self.operands = list(x64_operands)
            return

        if label:
            self.label = opcode
            return

        self.opcode = opcode
        self.operands = list(x64_operands)
        for i in self.operands:
            if not isinstance(i, X64Operand):
                print("the operand is not with wrong type", i)
                assert False

    def optimize(self):
        self.optimized = True

    def is_opcode(self):
        return self.opcode

    def optimize_str(self, s):
        if self.optimized:
            return "# optimized: " + s
        else:
            return s

    def __str__(self):
        if self.raw:
            return self.optimize_str(self.raw)
        if self.directive:
            res = self.directive
            res += "    "
            res += ",".join(self.operands)
            return self.optimize_str(res)
        if self.label:
            res = self.label
            res += ":"
            return self.optimize_str(res)

        res = self.opcode
        res += "    "
        for f in self.operands:
            if not isinstance(f, X64Operand):
                print("error, the type of operand is wrong: ", f)
                assert False
        res += ", ".join([op.to_riscv() for op in self.operands])
        return self.optimize_str(res)


class X64Insruction:
    def __init__(self, fields):
        self.opcode = fields[0]
        self.operands = fields[1:]

    def is_valid(self):
        return True

    def dest(self):
        return X64Operand(self.operands[-1])

    def src(self, index=0):
        return X64Operand(self.operands[index])

    def translate(self):
        if self.opcode == "pushq":
            return self.trans_pushq()
        elif self.opcode == "popq":
            return self.trans_popq()
        elif self.opcode == "subq":
            return self.trans_subq(True)
        elif self.opcode == "movq":
            return self.trans_movq()
        elif self.opcode == "call":
            return self.trans_call()
        elif self.opcode == "leaq":
            return self.trans_leaq()
        elif self.opcode == "mulq":
            return self.trans_mulq()
        elif self.opcode == "imulq":
            return self.trans_imulq()
        elif self.opcode == "addq":
            return self.trans_addq(True)
        elif self.opcode == "adcq":
            return self.trans_adcq(True)
        elif self.opcode == "xorq":
            return self.trans_xorq()
        elif self.opcode == "sbbq":
            return self.trans_sbbq(True)
        elif self.opcode == "cmovcq":
            return self.trans_cmovcq()
        elif self.opcode == "andq":
            return self.trans_andq()
        elif self.opcode == "notq":
            return self.trans_notq()
        elif self.opcode == "orq":
            return self.trans_orq()
        elif self.opcode == "cmovzq":
            return self.trans_cmovzq()
        elif self.opcode == "cmovnzq":
            return self.trans_cmovnzq()
        elif self.opcode == "decl":
            return self.trans_decl()
        else:
            assert False

    def trans_pushq(self):
        sp = X64Operand(r"%rsp")
        imm = X64Operand(r"$8")
        imm.imm = -imm.imm
        src = self.src(0)
        dest = X64Operand(r"0(%rsp)")
        return [
            RiscvInstruction("addi", sp, sp, imm),
            RiscvInstruction("sd", src, dest)
        ]

    def trans_popq(self):
        sp = X64Operand(r"%rsp")
        imm = X64Operand(r"$8")
        src = self.src(0)
        dest = X64Operand(r"0(%rsp)")
        return [
            RiscvInstruction("ld", src, dest),
            RiscvInstruction("addi", sp, sp, imm)
        ]

    # The SUB instruction performs integer subtraction.
    # It evaluates the result for both signed and unsigned integer
    # operands and sets the OF and CF flags to indicate an overflow
    # in the signed or unsigned result, respectively.
    def trans_subq(self, carry=False):
        src = self.src(0)
        dest = self.dest()
        res = []

        if src.type == "mem":
            (reg, i) = src.load_mem()
            res.append(i)
            src = reg

        if carry:
            # don't carry for imm...
            if src.type != "imm":
                carry_flag = X64Operand(r"%flag_carry")
                res.append(RiscvInstruction("sltu", carry_flag, dest, src))
        if src.type == "reg" and dest.type == "reg":
            res.append(RiscvInstruction("sub", dest, dest, src))
        elif src.type == "imm" and dest.type == "reg":
            src.imm = 0 - src.imm
            res.append(RiscvInstruction("addi", dest, dest, src))
        elif src.type == "mem" and dest.type == "reg":
            pass
        else:
            assert False
        return res

    def trans_movq(self):
        src = self.src()
        dest = self.dest()
        zero = X64Operand(r"%reg_zero")
        if src.type == "reg" and dest.type == "reg":
            return RiscvInstruction("add", dest, src, zero)
        elif src.type == "reg" and dest.type == "mem":
            # SD rs2,offset(rs1)
            # u64[rs1 + offset] ← rs2
            # memory operand is always at the end
            return RiscvInstruction("sd", src, dest)
        elif src.type == "mem" and dest.type == "reg":
            return RiscvInstruction("ld", dest, src)
        else:
            print(src.type, dest.type)
            assert False

    def trans_call(self):
        res = []
        dest = self.dest()  # it's a label
        res.append(RiscvInstruction("call", dest))
        return res

    def trans_leaq(self):
        src = self.src()
        dest = self.dest()
        if dest.type == "reg" and src.type == "mem":
            reg = X64Operand(src.reg)
            imm = X64Operand("$" + str(src.imm))
            return RiscvInstruction("addi", dest, reg, imm)
        else:
            assert False

    # %rdx:%rax = %rax * S
    def trans_mulq(self, signed=False):
        mul_opcode = "mulhu"
        if signed:
            mul_opcode = "mulh"
        src = self.src()
        if len(self.operands) == 1:
            if src.type == "mem":
                src2 = X64Operand(r'%rax')
                dest_h = X64Operand(r'%rdx')
                dest_l = X64Operand(r'%rax')
                return [RiscvInstruction("ld", RISCV_TEMP_REG, src),
                        RiscvInstruction(mul_opcode, dest_h,
                                         RISCV_TEMP_REG, src2),
                        RiscvInstruction("mul", dest_l, RISCV_TEMP_REG, src2)]
            elif src.type == "reg":
                src2 = X64Operand(r'%rax')
                dest_h = X64Operand(r'%rdx')
                dest_l = X64Operand(r'%rax')
                return [RiscvInstruction(mul_opcode, dest_h, src, src2),
                        RiscvInstruction("mul", dest_l, src, src2)]
            else:
                assert False
        elif len(self.operands) == 2:
            res = []
            dest = self.dest()
            if src.type == "mem" and dest.type == "reg":
                (reg, i) = src.load_mem()
                res.append(i)
                res.append(RiscvInstruction("mul", dest, dest, reg))
            return res
        else:
            assert False

    def trans_imulq(self):
        return self.trans_mulq(True)

    # src -> dest
    # 1. imm -> dest
    # 2. reg -> reg
    # 3. mem -> reg
    #
    # when to set carry to True?
    # 1. adc after that
    # 2.
    def trans_addq(self, carry=False):
        src = self.src()
        dest = self.dest()
        flag_carry = X64Operand(r'%flag_carry')
        assert len(self.operands) == 2
        res = []
        if src.type == "reg" and dest.type == "reg":
            res = [RiscvInstruction("add", dest, dest, src)]
            if carry:
                res.append(RiscvInstruction("sltu", flag_carry, dest, src))
        elif src.type == "mem" and dest.type == "reg":
            res = [RiscvInstruction("ld", RISCV_TEMP_REG, src),
                   RiscvInstruction("add", dest,
                                    RISCV_TEMP_REG, dest)]
            if carry:
                res.append(RiscvInstruction(
                    "sltu", flag_carry, dest, RISCV_TEMP_REG))
        elif src.type == "imm" and dest.type == "reg":
            pass
        else:
            assert False
        return res

    # 1. imm(0), reg
    # 2. reg, reg
    # 3. mem, reg

    # Thus, adding src, dest, and flag_carry with results in dest and carry-out in carry_flag:
    # add dest, dest, flag_carry
    # sltu carry_flag, a0, a1
    # add dest, dest, src
    # sltu carry_flag2, a0, a2
    # add carry_flag, carry_flag2, carry_flag
    def trans_adcq(self, carry=True):
        src = self.src(0)
        dest = self.dest()

        carry_flag = X64Operand(r"%flag_carry")
        carry_flag2 = RISCV_TEMP_REG2
        res = []

        def f(src, dest):
            res.append(RiscvInstruction("add", dest, dest, carry_flag))
            if carry:
                res.append(RiscvInstruction(
                    "sltu", carry_flag2, dest, carry_flag))
            res.append(RiscvInstruction("add", dest, dest, src))
            if carry:
                res.append(RiscvInstruction(
                    "sltu", carry_flag, dest, src))
                res.append(RiscvInstruction(
                    "add", carry_flag, carry_flag, carry_flag2))
        if src.type == "reg" and dest.type == "reg":
            f(self.src(0), self.dest())
        elif src.type == "imm" and dest.type == "reg":
            res = []
            if src.imm == 0:
                res.append(RiscvInstruction("add", dest, carry_flag, dest))
            else:
                assert False
        elif src.type == "mem" and dest.type == "reg":
            (reg, i) = src.load_mem()
            res.append(i)
            f(reg, dest)
        return res

    def trans_xorq(self):
        assert len(self.operands) == 2
        src = self.src()
        dest = self.dest()
        assert src.type == dest.type
        assert src.type == "reg" and src.reg == dest.reg
        return RiscvInstruction("xor", dest, dest, src)

    # src -> dest
    # 1. imm -> reg
    # 2. reg -> reg
    # 3. mem -> reg
    # DEST ← (DEST – SRC - CF);

    def trans_sbbq(self, carry=True):
        dest = self.dest()
        src = self.src()
        carry_flag = X64Operand(r"%flag_carry")
        carry_flag2 = X64Operand(r"%temp2")
        zero = X64Operand(r"%reg_zero")

        res = []

        def f(src, dest):
            if carry:
                res.append(RiscvInstruction(
                    "sltu", carry_flag2, dest, carry_flag))
            res.append(RiscvInstruction("sub", dest, dest, carry_flag))
            if carry:
                res.append(RiscvInstruction(
                    "sltu", carry_flag, dest, src))
            res.append(RiscvInstruction("sub", dest, dest, src))
            if carry:
                res.append(RiscvInstruction(
                    "add", carry_flag, carry_flag, carry_flag2))

        if src.type == "reg" and dest.type == "reg":
            f(src, dest)
        elif src.type == "mem" and dest.type == "reg":
            (reg, i) = src.load_mem()
            res.append(i)
            f(reg, dest)
        elif src.type == "imm" and dest.type == "reg":
            if src.imm == 0:
                res.append(RiscvInstruction(
                    "sltu", carry_flag2, dest, carry_flag))
                res.append(RiscvInstruction("sub", dest, dest, carry_flag))
                res.append(RiscvInstruction(
                    "add", carry_flag, carry_flag2, zero))
            else:
                assert False
        else:
            assert False
        return res

    #
    # beq cl, zero, .LABLE
    # add dest, src, zero
    # .LABLE:
    def cmovcc(self, flag, cc=True):
        src = self.src()
        dest = self.dest()
        cl = X64Operand(flag)
        zero = X64Operand(r"%reg_zero")
        label = gen_label()
        label_operand = X64Operand(label)

        res = []
        if cc:
            res.append(RiscvInstruction("beq", cl, zero, label_operand))
        else:
            res.append(RiscvInstruction("bne", cl, zero, label_operand))
        res.append(RiscvInstruction("add", dest, src, zero))
        res.append(RiscvInstruction(f"{label}:", raw=True))
        return res

    def trans_cmovcq(self):
        return self.cmovcc(r"%flag_carry")

    def trans_andq(self):
        src = trans_operand(self.src())
        dest = trans_operand(self.dest())
        return [RiscvInstruction("and", dest, dest, src)]

    def trans_notq(self):
        src = trans_operand(self.src())
        dest = trans_operand(self.dest())
        return [RiscvInstruction("not", dest, dest, src)]

    def trans_orq(self):
        src = trans_operand(self.src())
        dest = trans_operand(self.dest())
        return [RiscvInstruction("or", dest, dest, src)]

    # performs a bitwise AND on two operands:
    # The SF is set to the most significant bit of the result of the AND.
    # If the result is 0, the ZF is set to 1, otherwise set to 0.
    def trans_testq(self):
        assert False

    def trans_cmovzq(self):
        return self.cmovcc("flag_zero")

    def trans_cmovnzq(self):
        return self.cmovcc("flag_zero", False)

    def trans_decl(self):
        dest = trans_operand(self.dest())
        return [RiscvInstruction("addiw", dest, dest, -1)]

    def trans_jnz(self):
        assert False


# how to calculate the cost
# 1. for every x86-64 instruction, conver it to corresponding RISC-V instructions (1 or more)
# 2. sum the corresponding RISC-V instructions cycles (according to the cost_model.rs), with best result of MOP
riscv_cost_model = {
    "pushq": 2,  # sd
    "subq": 1,
    "movq": 1,
    "call": 3,  # jalr
    "leaq": 2,  # ld
    "mulq": 5,  # mul
    "addq": 1,
    "adcq": 1,
    "imulq": 5,  # mul
    "xorq": 1,
    "sbbq": 1,
    "cmovcq": 1,
    "andq": 1,
    "notq": 1,
    "orq": 1,
    "testq": 1,
    "cmovzq": 1,
    "cmovnzq": 1,
    "movd": 1,
    "decl": 1,
    "jnz": 3,  # beq
    "sd": 2,
    "add": 1,
    "ret": 3,
    "beq": 3,
    "sltu": 1,
    "sub": 1,
    "ld": 2,
    "mul": 5,
    "mulhu": 5,
    "xor": 1,
    "addi": 1,
}


def cost(opcode):
    global riscv_cost_model
    if opcode not in riscv_cost_model:
        print(f"warning, {opcode} is without cost, use 1")
        return 1
    else:
        return riscv_cost_model[opcode]


def is_special_directive(line):
    prefix = [".byte", ".globl"]
    for i in prefix:
        if i == line[0:len(i)]:
            return True
    return False


def is_call(line):
    return line[0] == "call"


def is_label(line):
    first = line[0]
    return first[0] == "." and first[-1] == ":"


def is_function(line):
    first = line[0]
    return first[0] != "." and first[-1] == ":"


def is_instruction(line):
    first = line[0]
    if first[0] == "." or first[-1] == ":":
        return False
    else:
        return True


def is_immediate(field):
    return field[0] == "$"


def normalize(line):
    return [i.lower() for i in line]


def parse(input):
    asm = []
    for line in input:
        line = line.strip()
        if len(line) == 0:
            continue
        if line[-1] == ":":
            asm.append([line])
        elif is_special_directive(line):
            fields = re.split(r'[,\s]+', line)
            asm.append(fields)
        else:
            if line[0] != ".":
                fields = re.split(r'[,\s]+', line)
                asm.append(fields)

    return [normalize(line) for line in asm]


def get_fun_cycles(asm, fun):
    start_fun = False
    mapping = {}
    total_cycles = 0

    for line in asm:
        if is_function(line) and start_fun:
            break
        if is_function(line) and line[0] == (fun + ":"):
            start_fun = True
        if start_fun and is_instruction(line):
            add_mapping(mapping, line[0])
    for opcode in mapping:
        total_cycles += cost(opcode)*mapping[opcode]
    return total_cycles


def add_mapping(mapping, name):
    if name not in mapping:
        mapping[name] = 1
    else:
        mapping[name] += 1


def dump_statistic(asm):
    print("print the summary of instructions, name: count")
    mapping = {}
    mapping_fun = {}
    fun_count = 0
    for line in asm:
        if is_function(line):
            fun_count += 1
            if fun_count == 2:
                break
        if is_instruction(line):
            add_mapping(mapping, line[0])
        if is_call(line):
            add_mapping(mapping_fun, line[1])

    total_cycles = 0
    for name in mapping:
        print(f"instruction {name}: {mapping[name]}")
        total_cycles += cost(name)*mapping[name]
    for fun in mapping_fun:
        cycles = get_fun_cycles(asm, fun)
        print(f"function {fun}: {mapping_fun[fun]}")
        print(f"function {fun} single cycles: {cycles}")
        total_cycles += cycles * mapping_fun[fun]

    print("")
    print(f"total cycles : {total_cycles}")


def dump(asm):
    for fields in asm:
        print("    ".join(fields))


def test(asm):
    return True


def check_stack(instructions):
    offset = 0
    for inst in instructions:
        if inst.opcode and inst.opcode == "addi":
            dest = inst.operands[0].to_riscv()
            src = inst.operands[1].to_riscv()
            imm = inst.operands[2].to_riscv()
            if dest == "sp" and src == "sp":
                offset += int(imm)
    if offset != 0:
        print(f"the stack is not balanced: {offset}")
    else:
        print("the stack is balanced.")


# combine the push stack operations:
# for example, the following:
# addi    sp, sp, -8
# sd    fp, 0(sp)
# addi    sp, sp, -8
# sd    s1, 0(sp)
#
# can be combined into
#
# addi sp, sp -16
# sd fp, 8(sp)
# sd s1, 0(sp)

def optimize_push(instructions):
    def is_addi(inst):
        if inst.opcode and inst.opcode == "addi":
            dest = inst.operands[0].to_riscv()
            src = inst.operands[1].to_riscv()
            return dest == src and dest == "sp"
        else:
            return False

    def is_sd(inst):
        if inst.opcode and inst.opcode == "sd":
            dest = inst.operands[0].to_riscv()
            src = inst.operands[1].to_riscv()
            if src.find("0(sp)") >= 0:
                return True
            else:
                return False
        else:
            return False

    index = 0
    res = []
    while True:
        if index >= (len(instructions) - 2):
            res.append(instructions[index])
            res.append(instructions[index+1])
            break
        imm = []
        regs = []
        inst2 = []

        while is_addi(instructions[index]) and is_sd(instructions[index+1]):
            offset = int(instructions[index].operands[2].to_riscv())
            imm += [offset]
            regs += [instructions[index+1].operands[0].to_riscv()]
            index += 2
            if not instructions[index].is_opcode():
                index += 1

        if len(imm) > 1:
            offset = -sum(imm)
            inst2.append(RiscvInstruction("addi", X64Operand(r"%rsp"), X64Operand(r"%rsp"), X64Operand(f"${-offset}")))
            offset -= 8
            for reg in regs:
                inst2.append(RiscvInstruction(
                    f"sd {reg}, {offset}(sp)", raw=True))
                offset -= 8
            
            res += inst2
            res += [instructions[index]]
        else:
            res += [instructions[index]]

        index += 1
    return res


def convert(asm, output_file):
    instructions = []

    def append_raw(code):
        instructions.append(RiscvInstruction(code, raw=True))
    append_raw(".text")
    for index in range(0, len(asm)):
        fields = asm[index]
        x64 = fields[0]
        x64 += "    "
        if len(fields) > 1:
            x64 += ", ".join(fields[1:])

        append_raw(f"# {x64}")
        if is_instruction(fields):
            x64 = X64Insruction(fields)
            riscv = []

            riscv0 = x64.translate()
            if not isinstance(riscv0, list):
                riscv.append(riscv0)
            else:
                riscv = riscv0
            for r in riscv:
                assert isinstance(r, RiscvInstruction)
                instructions.append(r)
        elif is_function(fields):
            fun_name = fields[0]
            if fun_name[-1] == ":":
                fun_name = fun_name[0:-1]
            instructions.append(RiscvInstruction(
                ".globl", fun_name, directive=True))
            instructions.append(RiscvInstruction(
                ".align", "4", directive=True))
            instructions.append(RiscvInstruction(fun_name, label=True))

            instructions.append(RiscvInstruction("addi sp, sp, -8", raw=True))
            instructions.append(RiscvInstruction("sd ra, 0(sp)", raw=True))

        elif is_special_directive(fields[0]):
            # https://repzret.org/p/repzret/
            if len(fields) == 3 and fields[0] == ".byte" and fields[1].lower() == "0xf3" \
                    and fields[2].lower() == "0xc3":
                # we have an assumption here, for the first function in every file
                # it's an exported function: which is linked with C code.
                # we mimimc x86 call, at the beginning of function, push the RA on stack
                # to make stack balanced. Then pop it before returning.
                instructions.append(RiscvInstruction("ld ra, 0(sp)", raw=True))
                instructions.append(RiscvInstruction(
                    "addi sp, sp, 8", raw=True))

                instructions.append(RiscvInstruction("ret"))
            else:
                append_raw(f"# special directive: {fields}")
        elif is_label(fields):
            append_raw(f"# label: {fields}")
        elif is_call(fields):
            append_raw(f"# call: {fields}")
        elif is_function(fields):
            append_raw(f"# function: {fields}")
        else:
            assert False

    # print("start optimizing...")
    # instructions = optimize_push(instructions)

    total_opcode = 0
    total_cycles = 0
    output = open(output_file, "w")
    for ins in instructions:
        output.write(str(ins))
        output.write("\n")
        if ins.is_opcode():
            total_opcode += 1
            total_cycles += cost(ins.opcode)

    output.close()

    print(f"done, about {total_opcode} instructions generated!")
    print(f"estimated cycles: {total_cycles}.")
    check_stack(instructions)


parser = argparse.ArgumentParser(
    description="Tools about x86-64 and RISC-V assembly code")
parser.add_argument('-s', '--statistics', dest='statistics',
                    action='store_true', help="print statistics")
parser.add_argument('-f', '--file', dest='file', type=str,
                    help="specify input file. default: stdin")
parser.add_argument('-c', '--convert', dest='convert', action='store_true',
                    help="convert x86-64 assembly to RISC-V")
parser.add_argument('-d', '--dump', dest='dump', action='store_true',
                    help="dump x86-64 assembly, remove directives")
parser.add_argument('-t', '--test', dest='test', action='store_true',
                    help="test")

args = parser.parse_args()
input = sys.stdin
if args.file:
    input = open(args.file, "r")

asm = parse(input)

if args.convert:
    ret = convert(asm, args.file + ".riscv.S")
    sys.exit(ret)

if args.statistics:
    dump_statistic(asm)
elif args.dump:
    dump(asm)

elif args.test:
    test(asm)
else:
    print("specify command")
