#include <avr/io.h>

	.section	.text

	.global	EEPROM_write
EEPROM_write:
	sbic	_SFR_IO_ADDR(EECR), EEPE
	rjmp	EEPROM_write
	sts		EEARH, r18
	sts		EEARL, r17
	sts		EEDR, r16
	in		r16, _SFR_IO_ADDR(SREG)
	cli
	sbi		_SFR_IO_ADDR(EECR), EEMPE
	sbi		_SFR_IO_ADDR(EECR), EEPE
	out		_SFR_IO_ADDR(SREG), r16
	ldi		r16, 'W'
	call	USART_send
	ret

		.global	EEPROM_read
EEPROM_read:
	sbic	   _SFR_IO_ADDR(EECR),EEPE
	rjmp	   EEPROM_read
	sts		EEARH, r19
	sts		EEARL, r17
	sbi		_SFR_IO_ADDR(EECR), EERE
	ldi		r16, 'R'
	call	   USART_send
	lds		r16, EEDR
	call		usart_send
	ret
	
	.end
