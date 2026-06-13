#ifndef __UART_H
#define __UART_H

#include <stdint.h>

uint32_t init_uart();

void uart_txchar(char tx);
uint32_t uart_rxchar();

uint32_t uart_tx_ready();
uint32_t uart_rx_available();
uint32_t check_uart_tx();

#endif /* ifndef __UART_H */
