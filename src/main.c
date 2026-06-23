#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include <stdbool.h>

#include "setup.h"
#include "uart.h"
#include "flash_layout.h"
#include "launch/launch.h"
#include "printf.h"
#include "debug.h"

void main() {
  init_cpu();
  init_uart();

  printf("\n");
  printf("minimal-loader\n");

  uint32_t rc = launch_image(CONFIG_RW_A_BASE, CONFIG_RW_SIZE);
  DLOG("RW_A rc: 0x%08X\n", rc);

  while (true)
    asm("wfi");
};
