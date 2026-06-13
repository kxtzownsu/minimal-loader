ENTRY(reset)

MEMORY
{
  ROM   (rx)  : ORIGIN = 0x00000000, LENGTH = 8K
  SRAM  (rwx) : ORIGIN = 0x00010000, LENGTH = 64K
  FLASH (rx)  : ORIGIN = 0x00040000, LENGTH = 512K

  RO_A  (rx)  : ORIGIN = 0x00040000, LENGTH = 16K
  RW_A  (rx)  : ORIGIN = 0x00044000, LENGTH = 240K
  RO_B  (rx)  : ORIGIN = 0x00080000, LENGTH = 16K
  RW_B  (rx)  : ORIGIN = 0x00084000, LENGTH = 240K

  /* sizeof(SignedHeader) == 0x400 */
  RO_A_EXEC (rx) : ORIGIN = 0x00040400, LENGTH = 16K - 0x400
  RW_A_EXEC (rx) : ORIGIN = 0x00044400, LENGTH = 240K - 0x400
  RO_B_EXEC (rx) : ORIGIN = 0x00080400, LENGTH = 16K - 0x400
  RW_B_EXEC (rx) : ORIGIN = 0x00084400, LENGTH = 240K - 0x400
}

REGION_ALIAS("LOADER_EXEC", RO_A_EXEC)

PHDRS
{
  text PT_LOAD FLAGS(5);
  data PT_LOAD FLAGS(6);
}

SECTIONS
{
  .text :
  {
    KEEP(*(.text.vecttable))

    . = ALIGN(4);
    *(.rodata*)

    . = ALIGN(4);
    KEEP(*(.text.reset))
    KEEP(*(.text.__reset))

    . = ALIGN(4);
    *(.text*)

    . = ALIGN(4);
    __flash_end = .;
  } > LOADER_EXEC :text = 0xFFFFFFFF

  .data : AT(__flash_end)
  {
    . = ALIGN(4);
    __data_start = .;
    *(.data*)
    . = ALIGN(4);
    __data_end = .;
  } > SRAM :data

  __data_lma_start = LOADADDR(.data);

  .bss (NOLOAD) :
  {
    . = ALIGN(8);
    __bss_start = .;
    *(.bss.regtable)
    *(.bss*)
    *(COMMON)
    . = ALIGN(8);
    __bss_end = .;
  } > SRAM

  .bss.system_stack (NOLOAD) :
  {
    . = ALIGN(8);
    *(.bss.system_stack)
  } > SRAM

  stack_end = ORIGIN(SRAM) + LENGTH(SRAM);

  /DISCARD/ :
  {
    *(.ARM.exidx*)
    *(.ARM.extab*)
    *(.ARM.attributes*)
    *(.comment*)
    *(.note*)
  }
}
