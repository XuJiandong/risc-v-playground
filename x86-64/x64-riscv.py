

import re
import argparse
import sys

X64_TO_RISCV_REGS = {
    "rdi": "a0",
    "rsi": "a1",
    "rdx": "a2",
    "rcx": "a3",
    "r8": "a4",
    # ra -
    "rax": "a0",
    "rsp": "sp",
    "rbp": "fp",
    "rbx": "s1",
    # t2-t6 -
    "r10": "t0",
    "r11": "t1",
    "r12": "s2",
    "r13": "s3",
    "r14": "s4",
    "r15": "s5",
    "flag_carry": "t2",  # carry
    "flag_zero": "t3",  # zero
    "flag_sign": "t4",  # sign
    "flag_overflow": "t5",  # overflow
    # s6-s11	-
}

RISCV_TEMP_REG = "t6"
RISCV_TEMP_REG2 = "s6"

# make sure values are not duplicated


def check_sanity(mapping):
    map2 = {}
    for key in mapping:
        value = mapping[key]
        if value in map2:
            assert False
        else:
            map2[value] = 1


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


class X64Operand:
    REG = re.compile(r'%(\w+)')
    MEM = re.compile(r'([\d-]+)\(%\w+\)')
    IMM = re.compiler(r'\$(\w+)')

    def __init__(self, field):
        reg = X64Operand.REG.match(field)
        if reg:
            self.type = "reg"
            self.reg = trans_operand(field)
        else:
            match = X64Operand.REG.match(field)
            if match:
                imm = match.group(1)
                reg = match.group(2)
                self.type = "mem"
                self.reg = trans_operand(reg)
                self.imm = int(imm)
            else:
                match = X64Operand.IMM.match(field)
                if match:
                    imm = match.group(1)
                    self.type = "imm"
                    self.reg = None
                    self.imm = int(imm)
                else:
                    assert False

    def __str__(self):
        if self.type == "reg":
            return self.reg
        elif self.type == "mem":
            return f"{self.imm}({self.reg})"
        elif self.type == "imm":
            return f"{self.imm}"


check_sanity(X64_TO_RISCV_REGS)


class RiscvInstruction:
    def __init__(self, opcode, *operands):
        self.opcode = opcode
        self.operands = list(operands)

    def __str__(self):
        self.opcode + " " + self.fields.join(' ')


class X64Insruction:
    def __init__(self, fields):
        self.opcode = fields[0]
        self.operands = fields[1:]

    def is_valid(self):
        return True

    def dest(self):
        return self.operands[-1]

    def src(self, index=0):
        return self.operands[index]

    def translate(self):
        if self.opcode == "pushq":
            return self.trans_pushq()
        elif self.opcode == "popq":
            return self.trans_popq()
        elif self.opcode == "subq":
            return self.trans_subq()
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
            return self.trans_addq()
        elif self.opcode == "adcq":
            return self.trans_adcq()
        elif self.opcode == "xorq":
            return self.trans_xorq()
        elif self.opcode == "sbbq":
            return self.trans_sbbq()
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
        src = trans_operand(self.src(0))
        return [
            RiscvInstruction("addi", "sp", "8"),
            RiscvInstruction("sd", src, "0(sp)")
        ]

    def trans_popq(self):
        dest = trans_operand(self.src(0))
        return [
            RiscvInstruction("ld", dest, "0(sp)"),
            RiscvInstruction("addi", "sp", "8")
        ]

    # TODO: carry
    # The SUB instruction performs integer subtraction.
    # It evaluates the result for both signed and unsigned integer
    # operands and sets the OF and CF flags to indicate an overflow
    # in the signed or unsigned result, respectively.
    def trans_subq(self, carry=False):
        src = trans_operand(self.src(0))
        dest = trans_operand(self.dest())
        res = []
        if carry:
            carry_flag = trans_operand("flag_carry")
            res.append([RiscvInstruction("sltu", carry_flag, dest, src)])
        res.append(RiscvInstruction("sub", dest, dest, src))
        return res

    def trans_movq(self):
        src = str(X64Operand(self.src()))
        dest = str(X64Operand(self.dest()))
        if src.type == "reg" and dest.type == "reg":
            return RiscvInstruction("add", dest, src, "zero")
        elif src.type == "reg" and dest.type == "mem":
            return RiscvInstruction("sd", dest, src)
        elif src.type == "mem" and dest.type == "reg":
            return RiscvInstruction("ld", dest, src)
        else:
            assert False

    def trans_call(self):
        dest = self.operands[0]  # it's a label
        return RiscvInstruction("call", dest)

    def trans_leaq(self):
        src = X64Operand(self.src())
        dest = X64Operand(self.dest())
        if dest.type == "reg" and dest.src == "mem":
            return RiscvInstruction("addi", dest, src.reg, src.imm)
        else:
            assert False

    # %rdx:%rax = %rax * S
    def trans_mulq(self, signed=False):
        mul_opcode = "mulhu"
        if signed:
            mul_opcode = "mulh"
        src = X64Operand(self.src())
        assert len(self.operands) == 1
        if src.type == "mem":
            src2 = trans_operand(r'%rax')
            dest_h = trans_operand(r'%rdx')
            dest_l = trans_operand(r'%rax')
            [RiscvInstruction("ld", RISCV_TEMP_REG, src),
             RiscvInstruction(mul_opcode, dest_h, RISCV_TEMP_REG, src2),
             RiscvInstruction("mul", dest_l, RISCV_TEMP_REG, src2)]
        elif src.type == "reg":
            src2 = trans_operand(r'%rax')
            dest_h = trans_operand(r'%rdx')
            dest_l = trans_operand(r'%rax')
            [RiscvInstruction(mul_opcode, dest_h, src, src2),
             RiscvInstruction("mul", dest_l, src, src2)]
        else:
            assert False

    def trans_imulq(self):
        return self.trans_mulq(True)

    # TODO: detect if need to set "carry" on
    # if there is any "adc" after "add", should append the "sltu" instruction:
    # add a0, a1, a2
    # sltu a3, a0, a1
    def trans_addq(self, carry=False):
        src = X64Operand(self.src())
        dest = X64Operand(self.dest())
        flag_carry = trans_operand("flag_carry")
        assert len(self.operands) == 2
        res = []
        if src.type == "reg" and dest.type == "reg":
            res = [RiscvInstruction("add", dest, dest, src)]
            if carry:
                res.append(RiscvInstruction("sltu", flag_carry, dest, src))
        elif src.type == "reg" and dest.type == "mem":
            res = [RiscvInstruction("ld", RISCV_TEMP_REG, dest),
                   RiscvInstruction("add", RISCV_TEMP_REG,
                                    RISCV_TEMP_REG, src),
                   RiscvInstruction("sd", RISCV_TEMP_REG, dest)]
            if carry:
                res.append(RiscvInstruction(
                    "sltu", flag_carry, RISCV_TEMP_REG, src))
        elif src.type == "mem" and dest.type == "reg":
            res = [RiscvInstruction("ld", RISCV_TEMP_REG, src),
                   RiscvInstruction("add", dest,
                                    RISCV_TEMP_REG, dest)]
            if carry:
                res.append(RiscvInstruction(
                    "sltu", flag_carry, dest, RISCV_TEMP_REG))
        else:
            assert False
        return res

    def trans_adcq(self, carry=False):
        src = trans_operand(self.src())
        dest = trans_operand(self.dest())
        carry_flag = trans_operand("flag_carry")
        res = [RiscvInstruction("add", RISCV_TEMP_REG, carry_flag, src)]
        # considering src + carry_flag = 0 (with carry)
        if carry:
            res.append(RiscvInstruction("sltu", carry_flag, RISCV_TEMP_REG, src))
        res.append(RiscvInstruction("add", dest, dest, RISCV_TEMP_REG))
        if carry:
            res.append(RiscvInstruction(
                "sltu", carry_flag, dest, RISCV_TEMP_REG))

    def trans_xorq(self):
        assert len(self.operands) == 2
        assert self.src() == self.dest()
        operand = trans_operand(self.operands[0])
        return RiscvInstruction("xor", operand, operand, operand)

    # DEST ← (DEST – (SRC + CF));
    # The SBB instruction does not distinguish between signed or unsigned operands.
    # Instead, the processor evaluates the result for both data types and sets the
    # OF and CF flags to indicate a borrow in the signed or unsigned result, respectively.
    # The SF flag indicates the sign of the signed result.
    def trans_sbbq(self, carry=False):
        dest = trans_operand(self.dest())
        src = trans_operand(self.src())
        carry_flag = trans_operand("flag_carry")
        res = [RiscvInstruction("add", RISCV_TEMP_REG, src, carry_flag)]
        # TODO: check carry flag: src + carry_flag = 0 with carry
        # require testing
        if carry:
            res.append(RiscvInstruction(
                "sltu", carry_flag, dest, RISCV_TEMP_REG))
        res.append(RiscvInstruction("sub", dest, dest, RISCV_TEMP_REG))
        return res

    # TODO: when to clear flags(e.g. carry, zero)?
    # cmov rd, rs2, rs1, rs3
    # uint_xlen_t cmov(uint_xlen_t rs1, uint_xlen_t rs2, uint_xlen_t rs3)
    # {
    #    return rs2 ? rs1: rs3
    # }
    def cmovcc(self, flag, cc=True):
        src = trans_operand(self.src())
        dest = trans_operand(self.dest())
        cl = trans_operand(flag)
        if cc:
            return [RiscvInstruction("cmov", dest, cl, src, dest)]
        else:
            return [RiscvInstruction("cmov", dest, cl, dest, src)]

    def trans_cmovcq(self):
        return self.cmovcc("flag_carry")

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
}


def cost(opcode):
    global riscv_cost_model
    if opcode not in riscv_cost_model:
        print(f"warning, {opcode} is without cost.")
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
            asm.append([line])
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


parser = argparse.ArgumentParser(
    description="Tools about x86-64 and RISC-V assembly code")
parser.add_argument('-s', '--statistics', dest='statistics',
                    action='store_true', help="print statistics")
parser.add_argument('-f', '--file', dest='file', type=str,
                    help="specify input file. default: stdin")
parser.add_argument('-d', '--dump', dest='dump', action='store_true',
                    help="dump x86-64 assembly, remove directives")
parser.add_argument('-t', '--test', dest='test', action='store_true',
                    help="test")

args = parser.parse_args()
input = sys.stdin
if args.file:
    input = open(args.file, "r")

asm = parse(input)

if args.statistics:
    dump_statistic(asm)
elif args.dump:
    dump(asm)

elif args.test:
    test(asm)
else:
    print("specify command")
