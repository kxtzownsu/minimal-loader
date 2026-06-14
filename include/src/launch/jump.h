#ifndef __MINIMAL_LOADER_LAUNCH_JUMP_H
#define __MINIMAL_LOADER_LAUNCH_JUMP_H

#include <stdint.h>
#include "signed_header.h"

enum launch_code verify_base_address(uint32_t addr);
enum launch_code verify_SignedHeader(const struct SignedHeader *hdr, size_t max_size, uint32_t addr);
void stage_rx_region(uint32_t region, const struct SignedHeader *hdr);

#endif /* ifndef __MINIMAL_LOADER_LAUNCH_JUMP_H */
