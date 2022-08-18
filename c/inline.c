// make printf to work: by default, the function printf is not included.
#define CKB_C_STDLIB_PRINTF

// use deps/ckb-c-stdlib
#include <stdio.h>
#include <stdlib.h>
// printf will use syscalls "ckb_debug" to print message to console
#include <ckb_syscalls.h>

int main2(int a, int b, int c) {
    // https://gcc.gnu.org/onlinedocs/gcc-6.1.0/gcc/Local-Register-Variables.html
    register int a2 asm("t0") = a;
    register int b2 asm("t1") = b;
    register int c2 asm("t2") = c;
    register int r asm("t3") = 0;

    //  + means input and output while = means output only.
    asm volatile(
        "add t1, t1, t2\n"
        "add t3, t1, t0\n"
        : "=r"(r)
        : "r"(a2), "r"(b2), "r"(c2));

    return r;
}

void six_copy(uint64_t *dst, const uint64_t *src) {
    *(dst + 0) = *(src + 0);
    *(dst + 1) = *(src + 1);
    *(dst + 2) = *(src + 2);
    *(dst + 3) = *(src + 3);
    *(dst + 4) = *(src + 4);
    *(dst + 5) = *(src + 5);
}

int main(int argc, const char *argv[]) {
    int r = main2(100, 200, 300);
    printf("result is %d\n", r);
    return 0;
}
