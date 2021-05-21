TARGET := riscv64-unknown-linux-gnu
CC := $(TARGET)-gcc
LD := $(TARGET)-gcc
OBJCOPY := $(TARGET)-objcopy

# -fno-builtin-printf must be used to use our own printf
CFLAGS := -fPIC -O3 -fno-builtin-printf -fno-builtin-memcmp \
-nostdinc -nostdlib -nostartfiles -fvisibility=hidden \
-fdata-sections -ffunction-sections\
-I deps/ckb-c-stdlib -I deps/ckb-c-stdlib/libc \
-Wall -Werror -Wno-nonnull -Wno-nonnull-compare -Wno-unused-function -g

# used to generate assembly code
ASM_CFLAGS := -S -O3 \
-fno-builtin-printf -fno-builtin-memcmp \
-nostdinc -nostdlib -nostartfiles -fvisibility=hidden \
-I deps/ckb-c-stdlib -I deps/ckb-c-stdlib/libc

LDFLAGS := -Wl,-static -Wl,--gc-sections

# docker pull nervos/ckb-riscv-gnu-toolchain:gnu-bionic-20191012
BUILDER_DOCKER := nervos/ckb-riscv-gnu-toolchain@sha256:aae8a3f79705f67d505d1f1d5ddc694a4fd537ed1c7e9622420a470d59ba2ec3

all: build/hello build/test_asm build/mont

all-via-docker:
	docker run --rm -v `pwd`:/code ${BUILDER_DOCKER} bash -c "cd /code && make"

### simple hello world
build/hello: c/hello.c
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $<
	$(OBJCOPY) --only-keep-debug $@ $@.debug
	$(OBJCOPY) --strip-debug --strip-all $@

### test_asm
build/asm.o: c/asm.S
	$(CC) -c -DCKB_DECLARATION_ONLY $(CFLAGS) -o $@ $<

build/test_asm.o: c/test_asm.c
	$(CC) -c $(CFLAGS) -o $@ $<

build/test_asm: build/test_asm.o build/asm.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJCOPY) --only-keep-debug $@ $@.debug
	$(OBJCOPY) --strip-debug --strip-all $@

### montgomery multiplicaton
build/ll_u256_mont-riscv64.o: c/ll_u256_mont-riscv64.S
	$(CC) -c -DCKB_DECLARATION_ONLY $(CFLAGS) -o $@ $<

build/mont.o: c/mont.c
	$(CC) -c $(CFLAGS) -o $@ $<

build/mont: build/ll_u256_mont-riscv64.o build/mont.o
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^
	$(OBJCOPY) --only-keep-debug $@ $@.debug
	$(OBJCOPY) --strip-debug --strip-all $@

### c2asm
build/c2asm.s: c/c2asm.c
	$(CC) $(ASM_CFLAGS) -o $@ $<

c2asm:
	docker run --rm -v `pwd`:/code ${BUILDER_DOCKER} bash -c "cd /code && make build/c2asm.s"

### run
run-hello:
	ckb-vm-cli --bin build/hello

run-test-asm:
	ckb-vm-cli --bin build/test_asm

run-mont:
	ckb-vm-cli --bin build/mont -- -both
	ckb-vm-cli --bin build/mont -- -asm
	ckb-vm-cli --bin build/mont -- -c


fmt:
	clang-format -i -style=Google $(wildcard c/*.c c/*.h)

clean:
	rm -rf build/*

install-tools:
	echo "start to install tool: ckb-vm-cli"
	cargo install --git https://github.com/XuJiandong/ckb-vm-cli.git
