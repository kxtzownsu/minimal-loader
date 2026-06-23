#include "printf.h"
#include "uart.h"

#include <stdarg.h>
#include <stdint.h>

static const char hexdigits[] = "0123456789ABCDEF";

static int print_uint(uint32_t val, uint32_t base, int pad_width) {
  int written = 0;

  if (pad_width > 1 || val >= base)
    written += print_uint(val / base, base, pad_width - 1);

  uart_txchar(hexdigits[val % base]);
  return written + 1;
}

static int print_str(const char *str) {
  int written = 0;

  while (*str) {
    uart_txchar(*str++);
    written++;
  }

  return written;
}

static int vfnprintf(const char *format, va_list args) {
  int written = 0;

  while (*format) {
    int c = *format++;
    int pad_width = 0;

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
        int val = va_arg(args, int);
        uint32_t magnitude = val;

        if (val < 0) {
          uart_txchar('-');
          written++;
          magnitude = 0u - magnitude;
        }

        written += print_uint(magnitude, 10, pad_width);
        break;
      }

      case 'h': {
        int len = va_arg(args, int);
        char *ptr = va_arg(args, char *);

        while (len > 0) {
          uint32_t byte = (uint32_t)(unsigned char)*ptr++;

          uart_txchar(hexdigits[byte >> 4]);
          uart_txchar(hexdigits[byte & 0xf]);
          written += 2;
          len--;
        }
        break;
      }

      case 's': {
        const char *str = va_arg(args, const char *);

        written += print_str(str);
        break;
      }

      case 'u': {
        uint32_t val = va_arg(args, uint32_t);

        written += print_uint(val, 10, pad_width);
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

int printf(const char *format, ...) {
  int written;
  va_list args;

  va_start(args, format);
  written = vfnprintf(format, args);
  va_end(args);

  return written;
}
