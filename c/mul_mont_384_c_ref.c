#include <stddef.h>

// blst's C version of mul_mont.
typedef uint64_t limb_t;
typedef unsigned __int128 llimb_t;
#define LIMB_T_BITS 64

__attribute__((noinline)) void mul_mont_384(limb_t ret[], const limb_t a[],
                                            const limb_t b[], const limb_t p[],
                                            limb_t n0) {
  size_t n = 6;
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
