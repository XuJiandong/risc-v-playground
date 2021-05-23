
// make printf to work: by default, the function printf is not included.
#define CKB_C_STDLIB_PRINTF

// use deps/ckb-c-stdlib
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// printf will use syscalls "ckb_debug" to print message to console
#include <ckb_syscalls.h>

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

void ll_u256_mont_mul(uint64_t rd[4], const uint64_t ad[4],
                      const uint64_t bd[4], const uint64_t Nd[4], uint64_t k0);

// blst's C version of mul_mont.
typedef uint64_t limb_t;
typedef unsigned __int128 llimb_t;
#define LIMB_T_BITS 64

static void mul_mont_n(limb_t ret[], const limb_t a[], const limb_t b[],
                       const limb_t p[], limb_t n0, size_t n) {
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

  if (asm_version || both_version) {
    printf("Testing asm version ...\n");
    for (int i = 0; i < 1000; i++) {
      ll_u256_mont_mul(result, a, b, N, k);
    }
    check_result(result, expected, 4);
  }

  if (c_version || both_version) {
    printf("Testing C version ...\n");
    for (int i = 0; i < 1000; i++) {
      mul_mont_n(result, a, b, N, k, 4);
    }
    check_result(result, expected, 4);
  }
  printf("done\n");
  return 0;
}
