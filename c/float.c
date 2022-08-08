
#define CKB_C_STDLIB_PRINTF
#include <stdio.h>
#include <stdlib.h>

#include <ckb_syscalls.h>

    
int main() {
    double a = 1.0;
    double b = 2.0;

    double c = a + b;
    int res = (int)c;
    printf("%d\n", res);
    return 0;
}
