#include "launch/launch.h"
#include "launch/jump.h"
#include "flash_layout.h"

enum launch_code launch_RO(uint32_t addr, size_t max_size){
  const struct SignedHeader *hdr = (const struct SignedHeader *)addr;
  enum launch_code rc;

  if (verify_base_address(addr) != LAUNCH_SUCCESS)
    return LAUNCH_INVALID_REGION;

  if (addr != CONFIG_RO_A_BASE && addr != CONFIG_RO_B_BASE)
    return LAUNCH_INVALID_REGION;

  rc = verify_SignedHeader(hdr, max_size, addr);
  if (rc != LAUNCH_SUCCESS)
    return rc;

  // TODO: this will set CPU0_I_STAGING_REGIONx values
  // arg1 is the region
  // arg2 is the SignedHeader
  // stage_rx_region(0, hdr);

  return LAUNCH_SUCCESS;
}
