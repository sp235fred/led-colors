#include <avr/io.h>

	.section	.text

	.global	USART_Init
USART_Init:
	; Set baud rate
	ldi		r17, 0x00
	ldi		r16, 0xcf ; 9600 baud
	sts		UBRR0H, r17
	sts		UBRR0L, r16
	; Enable receiver and transmitter and receiver interrupt
	ldi		r16, (1<<RXEN0)|(1<<TXEN0)|(1<<RXCIE0)
	sts		UCSR0B,r16
	; Set frame format: 8 data, 2 stop bit
	ldi		r16, (1<<USBS0)|(3<<UCSZ00)
	sts		UCSR0C, r16
	ldi		r16, (1<<U2X0)
	sts		UCSR0A, r16
	ret

	.global	USART_send
USART_send:
	push	r16
check:
	lds		r16, UCSR0A
	sbrs	r16, UDRE0
	rjmp	check
	pop		r16
	sts		UDR0, r16
	ret

	.end
