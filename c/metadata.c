// make printf to work: by default, the function printf is not included.
#define CKB_C_STDLIB_PRINTF

// use deps/ckb-c-stdlib
#include <stdio.h>
#include <stdlib.h>
// printf will use syscalls "ckb_debug" to print message to console
#include <ckb_syscalls.h>

const static char g_memory_limit[] __attribute__((section("ckb.memory_limit"))) = "500000";

int main(int argc, const char *argv[]) {
    printf("hello, world, %s\n", g_memory_limit);
    return 0;
}
