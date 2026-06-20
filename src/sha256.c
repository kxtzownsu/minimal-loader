#include "registers.h"

void sha256(const void *data, size_t len, uint32_t *digest) {
  const uint8_t *bp = (const uint8_t *)data;
  const uint32_t *wp;

  GREG32(KEYMGR, SHA_ITOP) = 0;
  GREG32(KEYMGR, SHA_CFG_MSGLEN_LO) = len;
  GREG32(KEYMGR, SHA_CFG_MSGLEN_HI) = 0;
  GWRITE_FIELD(KEYMGR, SHA_CFG_EN, INT_EN_DONE, 1);
  GWRITE_FIELD(KEYMGR, SHA_TRIG, TRIG_GO, 1);

  while (len && ((uint32_t)bp & 3)) {
    *((uint8_t *)GREG32_ADDR(KEYMGR, SHA_INPUT_FIFO)) = *bp++;
    len -= 1;
  }

  wp = (const uint32_t *)bp;
  while (len >= 32) {
    for (int i = 0; i < 8; i++)
      GREG32(KEYMGR, SHA_INPUT_FIFO) = *wp++;
    len -= 32;
  }

  while (len >= 4) {
    GREG32(KEYMGR, SHA_INPUT_FIFO) = *wp++;
    len -= 4;
  }

  bp = (uint8_t *)wp;
  while (len) {
    *((uint8_t *)GREG32_ADDR(KEYMGR, SHA_INPUT_FIFO)) = *bp++;
    len -= 1;
  }

  while (!GREG32(KEYMGR, SHA_ITOP))
    ;

  for (int i = 0; i < 8; ++i)
    *digest++ = GREG32_ADDR(KEYMGR, SHA_STS_H0)[i];

  GREG32(KEYMGR, SHA_ITOP) = 0;
}