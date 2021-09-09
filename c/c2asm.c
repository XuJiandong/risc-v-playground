
#include <stdint.h>


typedef unsigned int u128 __attribute__((mode(TI)));

u128 test_u128(uint64_t a, uint64_t b) {
  u128 a2 = a;
  u128 r = a2 * b;
  return r;
}

u128 test_u128_example() {
  uint64_t a = -1;
  uint64_t b = -1;
  u128 r = test_u128(a, b);  
  return r;
}

uint64_t rotr64(const uint64_t w, const unsigned c) {
  return (w >> c) | (w << (64 - c));
}


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

uint64_t g_int = 200;
uint64_t g_array[20] = {0};
uint8_t* g_string = "hello,world";

uint64_t use_global_variables(void) {
  g_array[0] = g_int;
  return g_array[0];
}
