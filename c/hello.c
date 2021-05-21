// make printf to work: by default, the function printf is not included.
#define CKB_C_STDLIB_PRINTF

// use deps/ckb-c-stdlib
#include <stdio.h>
#include <stdlib.h>
// printf will use syscalls "ckb_debug" to print message to console
#include <ckb_syscalls.h>

int main(int argc, const char* argv[]) {
  printf("hello, world\n");
  return 0;
}
