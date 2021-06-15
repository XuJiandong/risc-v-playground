#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>

uint64_t test_sbb(void);
uint64_t test_adc(void);
uint64_t test_add(void);
uint64_t test_lea(void);

#define CF 0x0001
#define ZF 0x0040
#define SF 0x0080
#define OF 0x0800
#define IS_ONE(s) ((s) ? 1 : 0)

void dump_flags(uint64_t flags) {
  printf("CF = %d, ", IS_ONE(flags & CF));
  printf("ZF = %d, ", IS_ONE(flags & ZF));
  printf("SF = %d, ", IS_ONE(flags & SF));
  printf("OF = %d\n", IS_ONE(flags & OF));
}

int main(int argc, const char *argv[]) {
  uint64_t res = 0;

  res = test_add();
  printf("test_add:\n");
  dump_flags(res);

  res = test_sbb();
  printf("test_sbb:\n");
  dump_flags(res);

  res = test_adc();
  printf("test_adc:\n");
  dump_flags(res);

  res = test_lea();
  return 0;
}
