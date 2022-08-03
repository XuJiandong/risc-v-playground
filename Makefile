TARGET := riscv64-unknown-linux-gnu
# other option 
# TARGET2 := riscv64-unknown-elf
CC := $(TARGET)-gcc
LD := $(TARGET)-gcc
OBJCOPY := $(TARGET)-objcopy
CKB-DEBUGGER=ckb-debugger

CLANG-CC = /usr/local/opt/llvm/bin/clang

# -fno-builtin-printf must be used to use our own printf
CFLAGS := -fPIC -O3 -fno-builtin-printf -fno-builtin-memcmp \
-nostdinc -nostdlib -nostartfiles -fvisibility=hidden \
-fdata-sections -ffunction-sections\
-I deps/ckb-c-stdlib -I deps/ckb-c-stdlib/libc \
-Wall -Werror -Wno-nonnull -Wno-nonnull-compare -Wno-unused-function -g

CLANG-CFLAGS=-target riscv64-unknown-elf -march=rv64imc -mno-relax $(subst -nostartfiles,,$(subst -Wno-nonnull-compare,,$(CFLAGS))) 

# used to generate assembly code
ASM_CFLAGS := -S -O3 \
-fno-builtin-printf -fno-builtin-memcmp \
-nostdinc -nostdlib -nostartfiles -fvisibility=hidden \
-I deps/ckb-c-stdlib -I deps/ckb-c-stdlib/libc

LDFLAGS := -Wl,-static -Wl,--gc-sections

CLANG-LDLAGS=$(subst -Wl,--gc-sections,,$(LDFLAGS))

X64_CC := clang
X64_CFLAGS := -fPIC -g
X64_LDFLAGS :=


# docker pull nervos/ckb-riscv-gnu-toolchain:gnu-bionic-20191012
BUILDER_DOCKER := nervos/ckb-riscv-gnu-toolchain@sha256:aae8a3f79705f67d505d1f1d5ddc694a4fd537ed1c7e9622420a470d59ba2ec3

all: build/hello build/test_asm build/mont build/inline build/float

all-via-docker:
	docker run --rm -v `pwd`:/code ${BUILDER_DOCKER} bash -c "cd /code && make"

### simple hello world
build/hello: c/hello.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<
	cp $@ $@.debug
	$(OBJCOPY) --strip-debug --strip-all $@

### simple hello world by clang
# TODO: 
# 1. support entry in assembly
# 2. support syscall
build/hello2: c/hello2.c
	$(CLANG-CC) $(CLANG-CFLAGS) $(CLANG-LDFLAGS) -o $@ $<

### test_asm
build/asm.o: c/asm.S
	$(CC) -c -DCKB_DECLARATION_ONLY $(CFLAGS) -o $@ $<

build/test_asm.o: c/test_asm.c
	$(CC) -c $(CFLAGS) -o $@ $<

build/test_asm: build/test_asm.o build/asm.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

### test_asm_x64
build/asm_x64.o: c/asm_x64.S
	$(X64_CC) -c $(X64_CFLAGS) -o $@ $<
	$(X64_CC) -S -c $(X64_CFLAGS) -o $@.S $<

build/test_asm_x64.o: c/test_asm_x64.c
	$(X64_CC) -c $(X64_CFLAGS) -o $@ $<
	$(X64_CC) -S -c $(X64_CFLAGS) -o $@.S $<

build/test_asm_x64: build/test_asm_x64.o build/asm_x64.o
	$(X64_CC) $(X64_CFLAGS) $(X64_LDFLAGS) -o $@ $^


### montgomery multiplicaton
build/ll_u256_mont-riscv64.o: c/ll_u256_mont-riscv64.S
	$(CC) -c -DCKB_DECLARATION_ONLY $(CFLAGS) -o $@ $<

build/mul_mont_384.o: c/mul_mont_384.S
	$(CC) -c -DCKB_DECLARATION_ONLY $(CFLAGS) -o $@ $<

build/blst_mul_mont_384.o: x86-64/blst_mul_mont_384.S.riscv.S
	$(CC) -c -DCKB_DECLARATION_ONLY $(CFLAGS) -o $@ $<

build/blst_mul_mont_384x.o: x86-64/blst_mul_mont_384x.S.riscv.S
	$(CC) -c -DCKB_DECLARATION_ONLY $(CFLAGS) -o $@ $<

build/mul_mont_384_s.o: c/mul_mont_384_s.S
	$(CC) -c -DCKB_DECLARATION_ONLY $(CFLAGS) -o $@ $<

build/mont.o: c/mont.c
	$(CC) -c $(CFLAGS) -o $@ $<

build/mont: build/ll_u256_mont-riscv64.o build/mul_mont_384.o build/mont.o build/blst_mul_mont_384.o build/blst_mul_mont_384x.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(CC) -S $(CFLAGS) -o build/mont.S c/mont.c

build/mont_s: build/ll_u256_mont-riscv64.o build/mul_mont_384_s.o build/mont.o build/blst_mul_mont_384.o build/blst_mul_mont_384x.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

### convert mul_mont_384_c_ref.c into asm version
build/mul_mont_384_c_ref.s: c/mul_mont_384_c_ref.c
	$(CC) -S $(subst -g,,$(CFLAGS)) -o $@ $<

mont384-c2asm:
	docker run --rm -v `pwd`:/code ${BUILDER_DOCKER} bash -c "cd /code && make build/mul_mont_384_c_ref.s"

gen:
	cd x86-64; make all

# anohter try, with minimal size
build/mul_mont_384_c_ref_s.s: c/mul_mont_384_c_ref.c
	$(CC) -S $(subst -O3,-Os,$(subst -g,,$(CFLAGS))) -o $@ $<

mont384-c2asm-s:
	docker run --rm -v `pwd`:/code ${BUILDER_DOCKER} bash -c "cd /code && make build/mul_mont_384_c_ref_s.s"

### c2asm
build/c2asm.S: c/c2asm.c
	$(CC) $(ASM_CFLAGS) -o $@ $<

c2asm:
	docker run --rm -v `pwd`:/code ${BUILDER_DOCKER} bash -c "cd /code && make build/c2asm.S"

### run
run-hello:
	$(CKB-DEBUGGER) --bin build/hello

run-test-asm:
	$(CKB-DEBUGGER) --bin build/test_asm

run-test-asm-x64: build/test_asm_x64
	build/test_asm_x64

run-mont:
	echo "using $(CKB-DEBUGGER)"
	$(CKB-DEBUGGER) --bin build/mont -- mont -asm
	$(CKB-DEBUGGER) --bin build/mont -- mont -c

bench-mont-384:
	$(CKB-DEBUGGER) --bin build/mont -- mont -bench384
	$(CKB-DEBUGGER) --bin build/mont -- mont -bench384asm
	$(CKB-DEBUGGER) --bin build/mont -- mont -bench384asm2
	$(CKB-DEBUGGER) --bin build/mont -- mont -bench384x
	$(CKB-DEBUGGER) --bin build/mont -- mont -bench384xasm2

bench-mont-384-s:
	$(CKB-DEBUGGER) --bin build/mont_s -- mont -bench384
	$(CKB-DEBUGGER) --bin build/mont_s -- mont -bench384asm


verify-mont-384:
	$(CKB-DEBUGGER) --bin build/mont -- mont -verify384

### inline assembly
build/inline: c/inline.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<
	$(CC) -S -c $(CFLAGS) $(LDFLAGS) -o $@.S $<

run-inline: build/inline
	$(CKB-DEBUGGER) --simple-binary $<

### bench blake2b
build/bench_blake2b: c/bench_blake2b.c	
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<

build/bench_blake2b-via-docker:
	docker run --rm -v `pwd`:/code ${BUILDER_DOCKER} bash -c "cd /code && make build/bench_blake2b"

bench_blake2b: build/bench_blake2b-via-docker
	$(CKB-DEBUGGER) --bin build/bench_blake2b || exit 0

### float
build/float: c/float.c
	$(CC) -D__riscv_soft_float -D__riscv_float_abi_soft $(CFLAGS) $(LDFLAGS) -o $@ $<

fmt:
	clang-format -i -style=Google $(wildcard c/*.c c/*.h)

clean:
	rm -rf build/*

install-tools:
	cargo install --git https://github.com/nervosnetwork/ckb-standalone-debugger.git ckb-debugger-binaries --branch develop
