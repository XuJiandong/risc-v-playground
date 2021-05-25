// make printf to work: by default, the function printf is not included.
#define CKB_C_STDLIB_PRINTF

// use deps/ckb-c-stdlib
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

// printf will use syscalls "ckb_debug" to print message to console
#include <ckb_syscalls.h>

void void_call();
uint32_t add(uint32_t a, uint32_t b);
int print_hello(void);

int main(int argc, const char* argv[]) {
  void_call();
  printf("void_call()\n");
  uint32_t c = add(100, 200);
  printf("add(100, 200) = %d\n", c);

  print_hello();
  return 0;
}
