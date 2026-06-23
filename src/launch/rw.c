#include "launch/launch.h"
#include "launch/jump.h"
#include "flash_layout.h"
#include "signed_header.h"

enum launch_code launch_RW(uint32_t addr, size_t max_size) {
  const struct SignedHeader *hdr = (const struct SignedHeader *)addr;
  static uint32_t fuses[FUSE_MAX];
  static uint32_t info[INFO_MAX];
  static struct sha256_hashes hashes;
  enum launch_code rc;

  if (verify_base_address(addr) != LAUNCH_SUCCESS)
    return LAUNCH_INVALID_REGION;

  if (addr != CONFIG_RW_A_BASE && addr != CONFIG_RW_B_BASE)
    return LAUNCH_INVALID_REGION;

  rc = verify_SignedHeader(hdr, max_size, addr);
  if (rc != LAUNCH_SUCCESS)
    return rc;

  stage_rx_region(1, hdr);
  
  hash_region(INFO_MAX, fuses, info, &hashes, hdr);
  print_hashes(&hashes, hdr);

  /*
    Verify the hash checksums. We can't reliably get the
    info hash until flash_info_read is implemented, so
    let's not check it for right now.
  */
	if (hdr->img_chk_ != hashes.img_hash[0] ||
	    hdr->fuses_chk_ != hashes.fuses_hash[0] /* || */
/* 	    hdr->info_chk_ != hashes.info_hash[0] */
    )
	  return LAUNCH_INVALID_HASH;
  
  set_runlevel(PERMISSION_MEDIUM); // RW firmware runs at PERMISSION_MEDIUM
/* TODO(kxtz): uncomment as the functions are implemented
  set_fwr(hdr);
  protect_flash_region(addr, hdr);

  disarm_ram_guards();

  printf("jump @%08x (%s)\n", addr, flash_region_to_string);
  _jump_to_address(addr + sizeof(SignedHeader));
*/
  /* This should never be reached */
  return LAUNCH_SUCCESS;
}
