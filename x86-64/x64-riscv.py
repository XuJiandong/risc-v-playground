import re
import argparse
import sys

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
