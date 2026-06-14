#include "launch/launch.h"
#include "signed_header.h"
#include "flash_layout.h"

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