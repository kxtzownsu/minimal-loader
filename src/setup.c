#include "registers.h"

void init_cpu() {
	GWRITE_FIELD(M3, DEMCR, TRCENA, 1);
	GWRITE_FIELD(M3, DWT_CTRL, CYCCNTENA, 1);
}