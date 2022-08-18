
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
uint8_t *g_string = "hello,world";

uint64_t use_global_variables(void) {
    g_array[0] = g_int;
    return g_array[0];
}

typedef struct StructArgs {
    uint64_t a1;
    uint64_t a2;
    uint64_t a3;
} StructArgs;

uint64_t __attribute__((noinline))
with_structure_args(uint64_t a64, uint32_t a32, uint16_t a16, uint8_t a8,
                    StructArgs args) {
    uint64_t s = a64 + a32 + a16 + a8 + args.a1 + args.a2 + args.a3;
    return s;
}

uint64_t __attribute__((noinline))
with_many_args(uint64_t a1, uint64_t a2, uint64_t a3, uint64_t a4, uint64_t a5,
               uint64_t a6, uint64_t a7, uint64_t a8, uint64_t a9,
               uint64_t a10) {
    uint64_t sum = a1 + a2 + a3 + a4 + a5 + a6 + a7 + a8 + a9 + a10;
    return sum;
}

uint64_t call() {
    StructArgs args = {.a1 = 100, .a2 = 200, .a3 = 300};
    uint64_t sum = with_structure_args(1, 2, 3, 4, args);

    uint64_t a1 = 1;
    uint64_t a2 = 2;
    uint64_t a3 = 3;
    uint64_t a4 = 4;
    uint64_t a5 = 5;
    uint64_t a6 = 6;
    uint64_t a7 = 7;
    uint64_t a8 = 8;
    uint64_t a9 = 9;
    uint64_t a10 = 10;
    uint64_t sum2 = with_many_args(a1, a2, a3, a4, a5, a6, a7, a8, a9, a10);

    return sum + sum2;
}
