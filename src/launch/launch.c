#include <flash_layout.h>

#include "launch/launch.h"
#include "launch/ro.h"

enum launch_code launch_image(uint32_t addr, size_t max_size) {
  if (addr == CONFIG_RO_A_BASE || addr == CONFIG_RO_B_BASE) {
    return launch_RO(addr, max_size);
  }

  return LAUNCH_INVALID_REGION; 
}