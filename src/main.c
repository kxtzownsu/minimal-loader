#include <stdint.h>
#include <stdbool.h>

#include "setup.h"
#include "uart.h"
#include "flash_layout.h"
#include "launch/launch.h"

void main(){
  init_cpu();
  init_uart();

  uart_txchar('h');
  uart_txchar('w');
  uart_txchar('\n');

  launch_image(CONFIG_RO_A_BASE, CONFIG_RO_SIZE);

  while (true)
    asm("wfi");
};