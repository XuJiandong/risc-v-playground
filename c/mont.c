
// make printf to work: by default, the function printf is not included.
#define CKB_C_STDLIB_PRINTF

// use deps/ckb-c-stdlib
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// printf will use syscalls "ckb_debug" to print message to console
#include <ckb_syscalls.h>
#define LOOP_COUNT 1000
#define LOOP_COUNT2 100000

// m' = -m^(-1) mod b
static uint64_t ll_invert_limb(uint64_t a) {
  uint64_t inv;

  inv = (((a + 2u) & 4u) << 1) + a;
  inv *= (2 - inv * a);
  inv *= (2 - inv * a);
  inv *= (2 - inv * a);
  inv *= (2 - inv * a);
  inv = -inv;
  return inv;
}

// blst's C version of mul_mont.
typedef uint64_t limb_t;
typedef unsigned __int128 llimb_t;
#define LIMB_T_BITS 64

__attribute__((noinline)) static void mul_mont_n(limb_t ret[], const limb_t a[],
                                                 const limb_t b[],
                                                 const limb_t p[], limb_t n0,
                                                 size_t n) {
  llimb_t limbx;
  limb_t mask, borrow, mx, hi, tmp[n + 1], carry;
  size_t i, j;

  for (mx = b[0], hi = 0, i = 0; i < n; i++) {
    limbx = (mx * (llimb_t)a[i]) + hi;
    tmp[i] = (limb_t)limbx;
    hi = (limb_t)(limbx >> LIMB_T_BITS);
  }
  mx = n0 * tmp[0];
  tmp[i] = hi;

  for (carry = 0, j = 0;;) {
    limbx = (mx * (llimb_t)p[0]) + tmp[0];
    hi = (limb_t)(limbx >> LIMB_T_BITS);
    for (i = 1; i < n; i++) {
      limbx = (mx * (llimb_t)p[i] + hi) + tmp[i];
      tmp[i - 1] = (limb_t)limbx;
      hi = (limb_t)(limbx >> LIMB_T_BITS);
    }
    limbx = tmp[i] + (hi + (llimb_t)carry);
    tmp[i - 1] = (limb_t)limbx;
    carry = (limb_t)(limbx >> LIMB_T_BITS);

    if (++j == n) break;

    for (mx = b[j], hi = 0, i = 0; i < n; i++) {
      limbx = (mx * (llimb_t)a[i] + hi) + tmp[i];
      tmp[i] = (limb_t)limbx;
      hi = (limb_t)(limbx >> LIMB_T_BITS);
    }
    mx = n0 * tmp[0];
    limbx = hi + (llimb_t)carry;
    tmp[i] = (limb_t)limbx;
    carry = (limb_t)(limbx >> LIMB_T_BITS);
  }

  for (borrow = 0, i = 0; i < n; i++) {
    limbx = tmp[i] - (p[i] + (llimb_t)borrow);
    ret[i] = (limb_t)limbx;
    borrow = (limb_t)(limbx >> LIMB_T_BITS) & 1;
  }

  mask = carry - borrow;

  for (i = 0; i < n; i++) ret[i] = (ret[i] & ~mask) | (tmp[i] & mask);
}

#if LIMB_T_BITS == 64
#define TO_LIMB_T(limb64) limb64
#else
#define TO_LIMB_T(limb64) (limb_t) limb64, (limb_t)(limb64 >> 32)
#endif

#define NLIMBS(bits) (bits / LIMB_T_BITS)
typedef limb_t vec384[NLIMBS(384)];
typedef vec384 vec384x[2];

static void add_mod_n(limb_t ret[], const limb_t a[], const limb_t b[],
                      const limb_t p[], size_t n) {
  llimb_t limbx;
  limb_t mask, carry, borrow, tmp[n];
  size_t i;

  for (carry = 0, i = 0; i < n; i++) {
    limbx = a[i] + (b[i] + (llimb_t)carry);
    tmp[i] = (limb_t)limbx;
    carry = (limb_t)(limbx >> LIMB_T_BITS);
  }

  for (borrow = 0, i = 0; i < n; i++) {
    limbx = tmp[i] - (p[i] + (llimb_t)borrow);
    ret[i] = (limb_t)limbx;
    borrow = (limb_t)(limbx >> LIMB_T_BITS) & 1;
  }

  mask = carry - borrow;

  for (i = 0; i < n; i++) ret[i] = (ret[i] & ~mask) | (tmp[i] & mask);
}

static void sub_mod_n(limb_t ret[], const limb_t a[], const limb_t b[],
                      const limb_t p[], size_t n) {
  llimb_t limbx;
  limb_t mask, carry, borrow;
  size_t i;

  for (borrow = 0, i = 0; i < n; i++) {
    limbx = a[i] - (b[i] + (llimb_t)borrow);
    ret[i] = (limb_t)limbx;
    borrow = (limb_t)(limbx >> LIMB_T_BITS) & 1;
  }

  mask = 0 - borrow;

  for (carry = 0, i = 0; i < n; i++) {
    limbx = ret[i] + ((p[i] & mask) + (llimb_t)carry);
    ret[i] = (limb_t)limbx;
    carry = (limb_t)(limbx >> LIMB_T_BITS);
  }
}

void mul_mont_384x(vec384x ret, const vec384x a, const vec384x b,
                   const vec384 p, limb_t n0) {
  vec384 aa, bb, cc;

  add_mod_n(aa, a[0], a[1], p, NLIMBS(384));
  add_mod_n(bb, b[0], b[1], p, NLIMBS(384));
  mul_mont_n(bb, bb, aa, p, n0, NLIMBS(384));
  mul_mont_n(aa, a[0], b[0], p, n0, NLIMBS(384));
  mul_mont_n(cc, a[1], b[1], p, n0, NLIMBS(384));
  sub_mod_n(ret[0], aa, cc, p, NLIMBS(384));
  sub_mod_n(ret[1], bb, aa, p, NLIMBS(384));
  sub_mod_n(ret[1], ret[1], cc, p, NLIMBS(384));
}

bool check_result(uint64_t* result, uint64_t* expected, size_t len) {
  bool ret = true;
  for (size_t i = 0; i < len; i++) {
    if (result[i] != expected[i]) {
      ret = false;
      printf("The result is not same as expected: 0x%x, 0x%d at index %d\n",
             result[i], expected[i], i);
    }
  }
  if (ret) {
    printf("Passed.\n");
  }
  return ret;
}

// asm version
__attribute__((noinline)) void mul_mont_384(limb_t ret[], const limb_t a[],
                                            const limb_t b[], const limb_t p[],
                                            limb_t n0);
__attribute__((noinline)) void blst_mul_mont_384(limb_t ret[], const limb_t a[],
                                                 const limb_t b[],
                                                 const limb_t p[], limb_t n0);
__attribute__((noinline)) void blst_mul_mont_384x(vec384x ret, const vec384x a,
                                                  const vec384x b,
                                                  const vec384 p, limb_t n0);

__attribute__((noinline)) void ll_u256_mont_mul(uint64_t rd[4],
                                                const uint64_t ad[4],
                                                const uint64_t bd[4],
                                                const uint64_t Nd[4],
                                                uint64_t k0);

int bench_384(void) {
  printf("benchmark for 384 bits\n");
  uint64_t result[6] = {0};
  uint64_t a[6] = {0xce8c0cc97e7a3027, 0xfc15bac58616015,  0x158831ba1c2c4ea6,
                   0x166188c234f8200b, 0x3b59569282528b5e, 0xd63a606f6afeba1};
  uint64_t b[6] = {0x192f996e0ec92133, 0x9038456a15d49df3, 0x98f16fe4889fd109,
                   0xd8c4a3ff44714ebc, 0x31740434d39a3eb9, 0xedfd8a69df4e386};
  const uint64_t N[6] = {0xb9feffffffffaaab, 0x1eabfffeb153ffff,
                         0x6730d2a0f6b0f624, 0x64774b84f38512bf,
                         0x4b1ba7b6434bacd7, 0x1a0111ea397fe69a};
  uint64_t k = ll_invert_limb(N[0]);
  for (int i = 0; i < LOOP_COUNT2; i++) {
    mul_mont_n(result, a, b, N, k, 6);
  }
  printf("done\n");
  return 0;
}

int bench_384x(void) {
  printf("benchmark for 384x bits, C version\n");
  vec384x result = {0};
  const vec384x a = {
      {0xce8c0cc97e7a3027, 0xfc15bac58616015, 0x158831ba1c2c4ea6,
       0x166188c234f8200b, 0x3b59569282528b5e, 0xd63a606f6afeba1},
      {0xce8c0cc97e7a3027, 0xfc15bac58616015, 0x158831ba1c2c4ea6,
       0x166188c234f8200b, 0x3b59569282528b5e, 0xd63a606f6afeba1},
  };
  const vec384x b = {
      {0x192f996e0ec92133, 0x9038456a15d49df3, 0x98f16fe4889fd109,
       0xd8c4a3ff44714ebc, 0x31740434d39a3eb9, 0xedfd8a69df4e386},
      {0x192f996e0ec92133, 0x9038456a15d49df3, 0x98f16fe4889fd109,
       0xd8c4a3ff44714ebc, 0x31740434d39a3eb9, 0xedfd8a69df4e386}};

  const vec384 N = {0xb9feffffffffaaab, 0x1eabfffeb153ffff, 0x6730d2a0f6b0f624,
                    0x64774b84f38512bf, 0x4b1ba7b6434bacd7, 0x1a0111ea397fe69a};

  uint64_t k = ll_invert_limb(N[0]);
  for (int i = 0; i < LOOP_COUNT2; i++) {
    mul_mont_384x(result, a, b, N, k);
  }
  printf("done\n");
  return 0;
}

int bench_384x_asm2(void) {
  printf(
      "benchmark for 384x bits, (generated from blst asm "
      "version)\n");
  vec384x result = {0};
  const vec384x a = {
      {0xce8c0cc97e7a3027, 0xfc15bac58616015, 0x158831ba1c2c4ea6,
       0x166188c234f8200b, 0x3b59569282528b5e, 0xd63a606f6afeba1},
      {0xce8c0cc97e7a3027, 0xfc15bac58616015, 0x158831ba1c2c4ea6,
       0x166188c234f8200b, 0x3b59569282528b5e, 0xd63a606f6afeba1},
  };
  const vec384x b = {
      {0x192f996e0ec92133, 0x9038456a15d49df3, 0x98f16fe4889fd109,
       0xd8c4a3ff44714ebc, 0x31740434d39a3eb9, 0xedfd8a69df4e386},
      {0x192f996e0ec92133, 0x9038456a15d49df3, 0x98f16fe4889fd109,
       0xd8c4a3ff44714ebc, 0x31740434d39a3eb9, 0xedfd8a69df4e386}};

  const vec384 N = {0xb9feffffffffaaab, 0x1eabfffeb153ffff, 0x6730d2a0f6b0f624,
                    0x64774b84f38512bf, 0x4b1ba7b6434bacd7, 0x1a0111ea397fe69a};

  uint64_t k = ll_invert_limb(N[0]);
  for (int i = 0; i < LOOP_COUNT2; i++) {
    blst_mul_mont_384x(result, a, b, N, k);
  }
  printf("done\n");
  return 0;
}

void mixed_in(uint64_t* array, size_t length, uint8_t input) {
  // uint64_t val = input;
  for (size_t i = 0; i < length; i++) {
    // array[i] += val;
    // array[i] += val << 8;
    // array[i] += val << 16;
    // array[i] += val << 32;
    // array[i] += val << 40;
    // array[i] += val << 48;
    // array[i] += val << 56;
    uint8_t* ptr = (uint8_t*)&array[i];
    ptr[7] = input;
  }
}

int verify_384x_inner(uint8_t index) {
  vec384x result = {0};
  vec384x a = {
      {0xce8c0cc97e7a3027, 0xfc15bac58616015, 0x158831ba1c2c4ea6,
       0x166188c234f8200b, 0x3b59569282528b5e, 0xd63a606f6afeba1},
      {0xce8c0cc97e7a3027, 0xfc15bac58616015, 0x158831ba1c2c4ea6,
       0x166188c234f8200b, 0x3b59569282528b5e, 0xd63a606f6afeba1},
  };
  vec384x b = {{0x192f996e0ec92133, 0x9038456a15d49df3, 0x98f16fe4889fd109,
                0xd8c4a3ff44714ebc, 0x31740434d39a3eb9, 0xedfd8a69df4e386},
               {0x192f996e0ec92133, 0x9038456a15d49df3, 0x98f16fe4889fd109,
                0xd8c4a3ff44714ebc, 0x31740434d39a3eb9, 0xedfd8a69df4e386}};

  const vec384 N = {0xb9feffffffffaaab, 0x1eabfffeb153ffff, 0x6730d2a0f6b0f624,
                    0x64774b84f38512bf, 0x4b1ba7b6434bacd7, 0x1a0111ea397fe69a};
  mixed_in(a[0], 6, index);
  mixed_in(a[1], 6, index);
  mixed_in(b[0], 6, index);
  mixed_in(b[1], 6, index);
  uint64_t k = ll_invert_limb(N[0]);
  mul_mont_384x(result, a, b, N, k);

  vec384x result2 = {0};
  blst_mul_mont_384x(result2, a, b, N, k);
  for (int i = 0; i < 2; i++) {
    for (int j = 0; j < 6; j++) {
      if (result[i][j] != result2[i][j]) {
        printf(
            "failed, wrong result at index %d, %d: %llx(correct) vs "
            "%llx(wrong)\n",
            i, j, result[i][j], result2[i][j]);
        return 1;
      }
    }
  }
  return 0;
}

int verify_384_inner(uint8_t index) {
  uint64_t result[6] = {0};
  uint64_t a[6] = {0xce8c0cc97e7a3027, 0xfc15bac58616015,  0x158831ba1c2c4ea6,
                   0x166188c234f8200b, 0x3b59569282528b5e, 0xd63a606f6afeba1};
  uint64_t b[6] = {0x192f996e0ec92133, 0x9038456a15d49df3, 0x98f16fe4889fd109,
                   0xd8c4a3ff44714ebc, 0x31740434d39a3eb9, 0xedfd8a69df4e386};
  const uint64_t N[6] = {0xb9feffffffffaaab, 0x1eabfffeb153ffff,
                         0x6730d2a0f6b0f624, 0x64774b84f38512bf,
                         0x4b1ba7b6434bacd7, 0x1a0111ea397fe69a};
  mixed_in(a, 6, index);
  mixed_in(b, 6, index);
  uint64_t k = ll_invert_limb(N[0]);
  mul_mont_n(result, a, b, N, k, 6);

  uint64_t result2[6] = {0xff};
  mul_mont_384(result2, a, b, N, k);
  for (int i = 0; i < 6; i++) {
    if (result[i] != result2[i]) {
      printf("failed, wrong result at index %d: %lld(correct) vs %lld(wrong)\n",
             i, result[i], result2[2]);
      return 1;
    }
  }

  uint64_t result3[6] = {0xff};
  blst_mul_mont_384(result3, a, b, N, k);
  for (int i = 0; i < 6; i++) {
    if (result[i] != result3[i]) {
      printf("failed, wrong result at index %d: %lld(correct) vs %lld(wrong)\n",
             i, result[i], result3[2]);
      return 1;
    }
  }
  return 0;
}

int bench_384_asm(void) {
  printf("benchmark for 384 bits, asm version\n");
  uint64_t result[6] = {0};
  uint64_t a[6] = {0xce8c0cc97e7a3027, 0xfc15bac58616015,  0x158831ba1c2c4ea6,
                   0x166188c234f8200b, 0x3b59569282528b5e, 0xd63a606f6afeba1};
  uint64_t b[6] = {0x192f996e0ec92133, 0x9038456a15d49df3, 0x98f16fe4889fd109,
                   0xd8c4a3ff44714ebc, 0x31740434d39a3eb9, 0xedfd8a69df4e386};
  const uint64_t N[6] = {0xb9feffffffffaaab, 0x1eabfffeb153ffff,
                         0x6730d2a0f6b0f624, 0x64774b84f38512bf,
                         0x4b1ba7b6434bacd7, 0x1a0111ea397fe69a};
  uint64_t k = ll_invert_limb(N[0]);
  for (int i = 0; i < LOOP_COUNT2; i++) {
    mul_mont_384(result, a, b, N, k);
  }
  printf("done\n");
  return 0;
}

int verify_384(void) {
  int res = 0;
  printf("verify_384 starts\n");
  for (uint16_t i = 0; i <= 255; i++) {
    int r = verify_384_inner(i);
    if (r != 0) {
      printf("verify_384_inner failed with %d\n", i);
    }
    res |= r;
  }
  printf("verify_384 done\n");
  return res;
}

int verify_384x(void) {
  int res = 0;
  printf("verify_384x starts\n");
  for (uint16_t i = 0; i <= 255; i++) {
    int r = verify_384x_inner(i);
    if (r != 0) {
      printf("verify_384x_inner faild with %d\n", i);
    }
    res |= r;
  }
  printf("verify_384x done\n");
  return res;
}

int bench_384_asm2(void) {
  printf(
      "benchmark for 384 bits, asm version (generated from blst asm "
      "version)\n");
  uint64_t result[6] = {0};
  uint64_t a[6] = {0xce8c0cc97e7a3027, 0xfc15bac58616015,  0x158831ba1c2c4ea6,
                   0x166188c234f8200b, 0x3b59569282528b5e, 0xd63a606f6afeba1};
  uint64_t b[6] = {0x192f996e0ec92133, 0x9038456a15d49df3, 0x98f16fe4889fd109,
                   0xd8c4a3ff44714ebc, 0x31740434d39a3eb9, 0xedfd8a69df4e386};
  const uint64_t N[6] = {0xb9feffffffffaaab, 0x1eabfffeb153ffff,
                         0x6730d2a0f6b0f624, 0x64774b84f38512bf,
                         0x4b1ba7b6434bacd7, 0x1a0111ea397fe69a};
  uint64_t k = ll_invert_limb(N[0]);
  for (int i = 0; i < LOOP_COUNT2; i++) {
    blst_mul_mont_384(result, a, b, N, k);
  }
  printf("done\n");
  return 0;
}

int main(int argc, const char* argv[]) {
  bool asm_version = false;
  bool c_version = false;
  bool both_version = false;

  uint64_t expected[4] = {0xe7f5addeb61a539a, 0x53bcacb7fd99f0f4,
                          0x471d58e78e2d6b00, 0x6fc7};
  uint64_t result[4] = {0};
  uint64_t a[4] = {0x4fecd9c6bef4805b, 0xd0756fcc51b07b0f, 0x0ff21caf40d141c8,
                   0x13a1};
  uint64_t b[4] = {0x416f50773146a5a8, 0x3d0688a3ae92febb, 0xb70671c25ec783df,
                   0x5c03};
  const uint64_t N[4] = {0x0ea6dd724f352a8d, 0x68888ca48183dd72,
                         0x8fa0b8b4ada1a38b, 0x76e4};
  uint64_t k = ll_invert_limb(N[0]);

  if (argc != 2) {
    printf("specify arguments: -asm, -c, -both\n");
    return -1;
  }
  if (strcmp(argv[1], "-asm") == 0) {
    asm_version = true;
  }
  if (strcmp(argv[1], "-c") == 0) {
    c_version = true;
  }
  if (strcmp(argv[1], "-both") == 0) {
    both_version = true;
  }
  if (strcmp(argv[1], "-bench384") == 0) {
    return bench_384();
  }
  if (strcmp(argv[1], "-bench384x") == 0) {
    return bench_384x();
  }
  if (strcmp(argv[1], "-verify384") == 0) {
    int res = verify_384();
    res |= verify_384x();
    return res;
  }
  if (strcmp(argv[1], "-bench384asm") == 0) {
    return bench_384_asm();
  }
  if (strcmp(argv[1], "-bench384asm2") == 0) {
    return bench_384_asm2();
  }
  if (strcmp(argv[1], "-bench384xasm2") == 0) {
    return bench_384x_asm2();
  }

  if (asm_version || both_version) {
    printf("Testing asm version ...\n");
    for (int i = 0; i < LOOP_COUNT; i++) {
      ll_u256_mont_mul(result, a, b, N, k);
    }
    check_result(result, expected, 4);
  }

  if (c_version || both_version) {
    printf("Testing C version ...\n");
    for (int i = 0; i < LOOP_COUNT; i++) {
      mul_mont_n(result, a, b, N, k, 4);
    }
    check_result(result, expected, 4);
  }

  printf("done\n");
  return 0;
}
