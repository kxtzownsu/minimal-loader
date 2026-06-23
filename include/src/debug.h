#ifndef __MINIMAL_LOADER_DEBUG_H
#define __MINIMAL_LOADER_DEBUG_H

#ifdef DEBUG
#define DLOG(msg, ...) \
  do { \
    printf("[debug] "); \
    printf(msg, ##__VA_ARGS__); \
  } while (0)

#else
#define DLOG(msg, ...) {}
#endif /* DEBUG */

#endif /* __MINIMAL_LOADER_DEBUG_H */