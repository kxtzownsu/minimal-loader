#include <stdint.h>
#include <stdbool.h>

#include "setup.h"
#include "uart.h"

void main(){
  init_cpu();
  init_uart();

  uart_txchar('h');
  uart_txchar('w');
  uart_txchar('\n');

  while (true)
    asm("wfi");
};