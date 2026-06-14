#include <stdint.h>
#include <string.h>
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

  uint32_t rc = launch_image(CONFIG_RO_A_BASE, CONFIG_RO_SIZE);
  uart_txstr("rc=");
  uart_txhex32(rc);

  rc = launch_image(CONFIG_RO_B_BASE, CONFIG_RO_SIZE);
  uart_txstr("rc=");
  uart_txhex32(rc);

  rc = launch_image(CONFIG_RW_A_BASE, CONFIG_RW_SIZE);
  uart_txstr("rc=");
  uart_txhex32(rc);

  rc = launch_image(CONFIG_RW_B_BASE, CONFIG_RW_SIZE);
  uart_txstr("rc=");
  uart_txhex32(rc);

  while (true)
    asm("wfi");
};
