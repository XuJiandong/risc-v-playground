
#include <stdint.h>

uint32_t add(uint32_t a, uint32_t b) { return a + b; }

uint32_t loop_and_add(uint32_t count) {
  uint32_t result = 0;
  for (uint32_t i = 0; i < count; i++) {
    result += i;
  }
  return result;
}


uint64_t test_i(void) {
  uint64_t a = 0x40003080;
  uint64_t b = 1;
  uint64_t c = a + b;
  return c;
}
