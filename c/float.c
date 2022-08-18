
#define CKB_C_STDLIB_PRINTF
#include <ckb_syscalls.h>
#include <stdio.h>
#include <stdlib.h>

int main() {
    double a = 100.1;
    double b = 200.2;
    double c = 300.3;
    double d = 400.4;
    double r = (c + d * b - 12.3456) / a;

    int res = (int)r;
    printf("%d\n", res);
    return 0;
}
