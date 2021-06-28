#include <blake2b.h>
#include <stdint.h>

int main(int argc, const char* argv[]) {
    uint8_t result[32] = {0};
    uint8_t random_data[100] = {1,2,3,4,5};

    blake2b_state ctx;

    for (int i = 0; i < 10000; i++) {
        ckb_blake2b_init(&ctx, 32);
        blake2b_update(&ctx, random_data, sizeof(random_data));
        blake2b_final(&ctx, result, sizeof(result));
        random_data[0] = result[0];
    }

    return result[0];
}
