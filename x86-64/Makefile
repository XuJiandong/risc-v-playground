


all: blst_mul_mont_384.S.riscv.S blst_mul_mont_384x.S.riscv.S


blst_mul_mont_384.S.riscv.S: blst_mul_mont_384.S
	python3 x64-riscv.py -f blst_mul_mont_384.S -c


blst_mul_mont_384x.S.riscv.S: blst_mul_mont_384x.S
	python3 x64-riscv.py -f blst_mul_mont_384x.S -c

