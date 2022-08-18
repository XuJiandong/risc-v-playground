#define CKB_C_STDLIB_PRINTF

#include <stdio.h>
#include <stdlib.h>

#include "ckb_syscalls.h"

double pow(double, double);
int main() {
    printf("using old crt");
    double d = pow(2.0, 3.0);
    int v = (int)d;
    printf("2 ** 3 = %d", v);
    return 0;
}
