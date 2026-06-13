extern void reset(void);
extern void stack_end(void);
void common_handler(void);

typedef void (*func)(void);

/* Vector table */
const func vectors[] __attribute__((section(".text.vecttable"))) = {
	stack_end,
	reset,
    common_handler, // NMI
    common_handler, // HardFault
    common_handler, // MPUFault
	  common_handler, // BusFault
    common_handler, // UsageFault
    common_handler, // reserved
    common_handler, // reserved
    common_handler, // reserved
    common_handler, // reserved
    common_handler, // SVCall
    common_handler, // Debug
    common_handler, // reserved
    common_handler, // PendSV
    common_handler, // SysTick
};

void common_handler(void) {
  // idk what to put here yet.
};