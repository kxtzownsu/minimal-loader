#ifndef __MINIMAL_LOADER_LAUNCH_JUMP_H
#define __MINIMAL_LOADER_LAUNCH_JUMP_H

#include <stdint.h>
#include "signed_header.h"
#include "sha256.h"

typedef struct sha256_hashes {
	uint32_t img_hash[SHA256_DIGEST_WORDS];
	uint32_t fuses_hash[SHA256_DIGEST_WORDS];
	uint32_t info_hash[SHA256_DIGEST_WORDS];
} sha256_hashes;

typedef enum permission_level {
	PERMISSION_LOW = 0x00,
	PERMISSION_MEDIUM = 0x33, /* APPS run at medium */
	PERMISSION_HIGH = 0x3C,
	PERMISSION_HIGHEST = 0x55
} permission_level;

enum launch_code verify_base_address(uint32_t addr);
enum launch_code verify_SignedHeader(const struct SignedHeader *hdr, size_t max_size, uint32_t addr);
void stage_rx_region(uint32_t region, const struct SignedHeader *hdr);
void hash_region(uint32_t info_base, uint32_t fuses[FUSE_MAX], uint32_t info[INFO_MAX], struct sha256_hashes *hashes, const struct SignedHeader *hdr);
void print_hashes(const struct sha256_hashes *hashes, const struct SignedHeader *hdr);
#endif /* ifndef __MINIMAL_LOADER_LAUNCH_JUMP_H */
