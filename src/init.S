.text
.syntax unified

.thumb
.align 2
.global reset

.thumb_func
reset:
	movs r0, #0
	msr control, r0
	isb

	mov r1, r0
	mov r2, r0
	mov r3, r0
	mov r4, r0
	mov r5, r0
	mov r6, r0
	mov r7, r0
	mov r8, r0
	mov r9, r0
	mov r10, r0
	mov r11, r0
	mov r12, r0

	ldr r1, =vectors
	ldr r2, =0xE000ED08
	str r1, [r2]

	ldr r1, _bss_start
	ldr r2, _bss_end
bss_loop:
	cmp r1, r2
	bhs bss_done
	str r0, [r1], #4
	b bss_loop
bss_done:

	ldr r1, _data_start
	ldr r2, _data_end
	ldr r3, _data_lma_start
data_loop:
	cmp r1, r2
	bhs data_done
	ldr r4, [r3], #4
	str r4, [r1], #4
	b data_loop
data_done:

	ldr r0, =stack_end
	mov sp, r0

	bl main
fini_loop:
  wfi
	b fini_loop

	.align 2
_bss_start:
	.long __bss_start
_bss_end:
	.long __bss_end
_data_start:
	.long __data_start
_data_end:
	.long __data_end
_data_lma_start:
	.long __data_lma_start
