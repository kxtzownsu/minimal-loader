#ifndef __MINIMAL_LOADER_LAUNCH_RW_H
#define __MINIMAL_LOADER_LAUNCH_RW_H

#include <stdint.h>
#include <stddef.h>
#include "launch/launch.h"

enum launch_code launch_RW(uint32_t addr, size_t max_size);

#endif /* ifndef __MINIMAL_LOADER_LAUNCH_RW_H */