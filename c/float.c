
#define CKB_C_STDLIB_PRINTF
#include <ckb_syscalls.h>
#include <stdio.h>
#include <stdlib.h>

double __attribute__((noinline)) op(int op_type, double a, double b) {
    switch (op_type) {
        case 0:
            return a + b;
        case 1:
            return a - b;
        case 2:
            return a * b;
        case 4:
            return a / b;
        default:
            return (a + b) * (a / b - b);
    }
}

int main() {
    double a = 100.1;
    double b = 200.2;
    double c = 300.3;
    double d = 400.4;
    double r = (c + d * b - 12.3456) / a;

    int res = (int)r;
    printf("%d\n", res);
    r = op(res, 100.1, 200.2);
    res = (int)r;
    printf("%d\n", r);
    return 0;
}
