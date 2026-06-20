#ifndef __MINIMAL_LOADER_SHA256_H
#define __MINIMAL_LOADER_SHA256_H

#include <inttypes.h>
#include <stddef.h>

#define SHA256_DIGEST_LENGTH 32
#define SHA256_DIGEST_WORDS (SHA256_DIGEST_LENGTH / sizeof(uint32_t))

void sha256(const void *data, size_t len, uint32_t *digest);

#endif  /* ifndef __MINIMAL_LOADER_SHA256_H */