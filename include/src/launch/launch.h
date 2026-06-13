#ifndef __MINIMAL_LOADER_LAUNCH_LAUNCH_H
#define __MINIMAL_LOADER_LAUNCH_LAUNCH_H

#include <stdint.h>
#include <stddef.h>

enum launch_code {
  LAUNCH_SUCCESS = 0, 

  LAUNCH_INVALID_REGION = -1,

  LAUNCH_GENERIC_FAIL = -63
};

enum launch_code launch_image(uint32_t addr, size_t max_size);

#endif /* ifndef __MINIMAL_LOADER_LAUNCH_LAUNCH_H */