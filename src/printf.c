#include "printf.h"
#include "uart.h"

#include <stdarg.h>
#include <stdint.h>

static const char hexdigits[] = "0123456789ABCDEF";

uint32_t print_uint(uint32_t val, uint32_t base, uint32_t pad_width) {
  uint32_t written = 0;

  if (pad_width > 1 || val >= base)
    written += print_uint(val / base, base, pad_width - 1);

  uart_txchar(hexdigits[val % base]);
  return written + 1;
}

uint32_t vfnprintf(const char *format, va_list args) {
  uint32_t written = 0;

  while (*format) {
    uint32_t c = *format++;
    uint32_t pad_width = 0;

    if (c != '%') {
      uart_txchar(c);
      written++;
      continue;
    }

    c = *format++;
    if (c == '\0')
      break;

    while (c >= '0' && c <= '9') {
      pad_width = (10 * pad_width) + c - '0';
      c = *format++;
    }

    switch (c) {
      case 'd': {
        uint32_t val = va_arg(args, uint32_t);

        written += print_uint(val, 10, pad_width);
        break;
      }

      case 'h': {
        uint32_t len = va_arg(args, uint32_t);
        char *ptr = va_arg(args, char *);

        while (len > 0) {
          uint32_t byte = (uint32_t)*ptr++;

          uart_txchar(hexdigits[byte >> 4]);
          uart_txchar(hexdigits[byte & 0xf]);
          written += 2;
          len--;
        }
        break;
      }

      case 'x':
      case 'X': {
        uint32_t val = va_arg(args, uint32_t);

        written += print_uint(val, 16, pad_width);
        break;
      }

      case '%':
        uart_txchar('%');
        written++;
        break;

      default:
        uart_txchar('%');
        uart_txchar(c);
        written += 2;
        break;
    }
  }

  return written;
}

uint32_t printf(const char *format, ...) {
  uint32_t written;
  va_list args;

  va_start(args, format);
  written = vfnprintf(format, args);
  va_end(args);

  return written;
}