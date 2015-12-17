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
	sbic	_SFR_IO_ADDR(EECR),EEPE
	rjmp	EEPROM_read
	sts		EEARH, r18
	sts		EEARL, r17
	sbi		_SFR_IO_ADDR(EECR), EERE
	ldi		r16, 'R'
	call	USART_send
	lds		r16, EEDR
	ret
	
	.global	EEPROM_clearall
EEPROM_clearall:
	push	r18
	push	r17
	push	r16
	in	r16, _SFR_IO_ADDR(SREG)
	push	r16
	clr	r18
	clr	r17
	clr	r16
clearstuff:
	sts	EEARH, r18
	sts	EEARL, r17
	sts	EEDR, r16
	cli
	sbi		_SFR_IO_ADDR(EECR), EEMPE
	sbi		_SFR_IO_ADDR(EECR), EEPE
	inc	r17
	cpi	r17, 4
	breq	next
	rjmp	clearstuff
next:
	inc	r18
	clr	r17
	cpi	r18,5
	breq	cleared
	rjmp	clearstuff
cleared:
	pop	r16
	out	_SFR_IO_ADDR(SREG), r16
	pop	r16
	pop	r17
	pop	r18
	clr	r22
	clr	r19
	clr	r18
	ret
	
	.end
