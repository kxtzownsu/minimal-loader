INCLUDE linker/memory_map.ld

#if defined(SECTION_A)
REGION_ALIAS("LOADER_EXEC", RO_A_EXEC)
#elif defined(SECTION_B)
REGION_ALIAS("LOADER_EXEC", RO_B_EXEC)
#else
#error "Please define SECTION_A or SECTION_B. e.g: '-DSECTION_A'"
#endif
INCLUDE linker/common.ld
