import re
import argparse

FILE="mul_mont_384.S"
all = []

# how to calculate the cost
# 1. for every x86-64 instruction, conver it to corresponding RISC-V instructions (1 or more)
# 2. sum the corresponding RISC-V instructions cycles (according to the cost_model.rs), with best result of MOP
riscv_cost_model = {
    "pushq": 2, # sd
    "subq": 1, 
    "movq": 1,
    "call": 3, # jalr
    "leaq": 2, # ld
    "mulq": 5, # mul
    "addq": 1,
    "adcq": 1,
    "imulq": 5, # muli
    "xorq": 1,
    "sbbq": 1,
    "cmovcq": 1,
}

def cost(opcode):
    global riscv_cost_model
    if opcode not in riscv_cost_model:
        print(f"warning, {opcode} is without cost.")
        return 1
    else:
        return riscv_cost_model[opcode]

def parse():
    global all
    global FILE
    all = []
    for line in open(FILE, "r"):
        line = line.strip()
        if len(line) > 0 and line[0] != ".":
            if line[-1] == ":":
                label = line[:-1]
            else:
                fields = re.split(",| ", line)
                all.append(fields)

def dump_statistic():
    global all
    parse()
    print("print the summary of instructions, name: count")
    print("-----------")
    mapping = {}
    for i in all:
        opcode = i[0]
        if opcode not in mapping:
            mapping[opcode] = 1
        else:
            mapping[opcode] += 1
    total_cycles = 0
    for opcode in mapping:
        print(f"{opcode}: {mapping[opcode]}")
        total_cycles += cost(opcode)*mapping[opcode]
    print("")
    print(f"total cycles : {total_cycles}")


parser = argparse.ArgumentParser(description="Process " + FILE)
parser.add_argument('-s', dest='statistics', action='store_const', const=True, default=False, help="print statistics")
args = parser.parse_args()
if args.statistics:
    dump_statistic()

