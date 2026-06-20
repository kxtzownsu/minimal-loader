#include "common.h"
#include "registers.h"
#include "uart.h"

void uart_txchar(char tx) {
  while (!uart_tx_ready())
    ;

  GREG32(UART, WDATA) = tx;
}

uint32_t uart_tx_ready() {
  return (GREG32(UART, STATE) ^ 1) & 1;
}

uint32_t uart_rx_available() {
  return !(GREG32(UART, STATE) & GC_UART_STATE_RXEMPTY_MASK);
}

uint32_t uart_rxchar() {
  if (!uart_rx_available())
    return -1;

  return GREG32(UART, RDATA) & 0xff;
}

uint32_t check_uart_tx() {
	if (!(GREG32(UART, CTRL) & 1))
		return 1;

	if ((GREG32(UART, STATE) & 0x30) != 0x30)
		return 0;

	return 1;
}

uint32_t init_uart() {
  int i;

	GREG32(PMU, PERICLKSET1) |= 32;

	do
		i = check_uart_tx();
	while (!i);

	GREG32(PINMUX, DIOA0_SEL) = 70;
	GREG32(PINMUX, UART0_RX_SEL) = 12;
	GREG32(PINMUX, DIOA13_CTL) = 6;
	GREG32(UART, FIFO) = 3;
	GREG32(UART, NCO) = 0x13a9;
	GREG32(UART, CTRL) = 3;

	return i;
}
