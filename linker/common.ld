ENTRY(reset)

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
