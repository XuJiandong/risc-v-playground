// make printf to work: by default, the function printf is not included.
#define CKB_C_STDLIB_PRINTF

// use deps/ckb-c-stdlib
#include <stdio.h>
#include <stdlib.h>
// printf will use syscalls "ckb_debug" to print message to console
#include <ckb_syscalls.h>

int main(int argc, const char* argv[]) {
    // style from: http://www.ethernut.de/en/documents/arm-inline-asm.html
    asm(
        "addi t0, zero, 1\n\t"
        "add  t0, t0, t0\n\t"
        "add  t0, t0, t0\n\t"
        );
    printf("the result is %d\n", 100);
    return 0;
}
