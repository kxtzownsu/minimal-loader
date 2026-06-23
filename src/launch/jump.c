#include "launch/launch.h"
#include "launch/jump.h"
#include "signed_header.h"
#include "flash_layout.h"
#include "registers.h"
#include "sha256.h"
#include "uart.h"
#include "printf.h"

enum launch_code verify_base_address(uint32_t addr){
  if (addr != CONFIG_RO_A_BASE &&
      addr != CONFIG_RO_B_BASE &&
      addr != CONFIG_RW_A_BASE &&
      addr != CONFIG_RW_B_BASE) {
    /* 
      The user passed us an invalid address that
      doesn't match any known code spots in the
      flash.
    */
    return LAUNCH_INVALID_REGION;
  }

  return LAUNCH_SUCCESS;
}

enum launch_code verify_SignedHeader(const struct SignedHeader *hdr, size_t max_size, uint32_t addr) {
  if (hdr->magic != MAGIC_HAVEN)
    return LAUNCH_INVALID_MAGIC;

  if (hdr->image_size < CONFIG_FLASH_BANK_SIZE)
    return LAUNCH_IMAGE_TOO_SMALL;

  if (hdr->image_size > max_size)
    return LAUNCH_IMAGE_TOO_LARGE;

  if (hdr->ro_base < addr)
    return LAUNCH_RO_BASE_BEFORE_REGION;
  if (hdr->ro_max > addr + max_size)
    return LAUNCH_RO_MAX_AFTER_REGION;
  if (hdr->rx_base < addr)
    return LAUNCH_RX_BASE_BEFORE_REGION;
  if (hdr->rx_max > addr + max_size)
    return LAUNCH_RX_MAX_AFTER_REGION;

  return LAUNCH_SUCCESS;
}

void stage_rx_region(uint32_t region, const struct SignedHeader *hdr){
  uint32_t offset;

  if (region > 7)
    return;

  offset = GC_GLOBALSEC_CPU0_I_STAGING_REGION0_CTRL_OFFSET + region * 0xc;

  REG32(GC_GLOBALSEC_BASE_ADDR + offset + 4) = hdr->rx_base;
  REG32(GC_GLOBALSEC_BASE_ADDR + offset + 8) = hdr->rx_max - hdr->rx_base - 1;
  REG32(GC_GLOBALSEC_BASE_ADDR + offset) = 3;
}

void hash_region(uint32_t info_base, uint32_t fuses[FUSE_MAX], uint32_t info[INFO_MAX], struct sha256_hashes *hashes, const struct SignedHeader *hdr) {
  int i;
  
  sha256(&hdr->tag, hdr->image_size - offsetof(struct SignedHeader, tag), hashes->img_hash);
  
  for (i = 0; i < FUSE_MAX; ++i) {
    fuses[i] = FUSE_IGNORE_B;
  }

  for (i = 0; i < FUSE_MAX; ++i) {
    if (hdr->fusemap[i>>5] & (1 << (i & 31))) {
      fuses[i] = GREG32_ADDR(FUSE, BNK0_INTG_CHKSUM)[i];
    }
  }

  sha256(fuses, FUSE_MAX * sizeof(uint32_t), hashes->fuses_hash);

  // TODO: implement flash_info_read
  for (i = 0; i < INFO_MAX; ++i)
		info[i] = INFO_IGNORE_B;

	for (i = 0; i < INFO_MAX; ++i) {
		if (hdr->infomap[i>>5] & (1 << (i&31))) {
			uint32_t val = 0;
			int retval = 0; // flash_info_read(info_base + i, &val);

			info[i] ^= val ^ retval;
		}
	}

  sha256(info, INFO_MAX * sizeof(uint32_t), hashes->info_hash);
}

void print_hashes(const struct sha256_hashes *hashes, const struct SignedHeader *hdr){
  printf(
    "Himg =%X..%X: %d\n",
    hashes->img_hash[0],
    hashes->img_hash[SHA256_DIGEST_WORDS - 1],
    hdr->img_chk_ == hashes->img_hash[0]
  );
  printf(
    "Hfss =%X..%X: %d\n",
    hashes->fuses_hash[0],
    hashes->fuses_hash[SHA256_DIGEST_WORDS - 1],
    hdr->fuses_chk_ == hashes->fuses_hash[0]
  );
  printf(
    "Hinf =%X..%X: %d\n",
    hashes->info_hash[0],
    hashes->info_hash[SHA256_DIGEST_WORDS - 1],
    hdr->info_chk_ == hashes->info_hash[0]
  );
}