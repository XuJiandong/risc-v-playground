
#define CKB_C_STDLIB_PRINTF
#include <ckb_syscalls.h>
#include <stdio.h>
#include <stdlib.h>

double __attribute__((noinline)) op(int op_type, double a, double b) {
    switch (op_type) {
        case 0:
            return a + b;
        default:
            return a + b + 1.0;
    }
}

int main() {
    double res = op(0, 100.1, 200.2);
    int r = (int)res;
    printf("%d\n", r);
    return 0;
}
