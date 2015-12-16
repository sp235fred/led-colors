#include <avr/io.h>

	.section	.text

	.global main
main:
	call	USART_Init
	call	doit
	ret

	.global __do_copy_data
	.global __do_clear_bss

	.end
