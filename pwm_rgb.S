#include <avr/io.h>

#define RED_LED		DDD1
#define GREEN_LED	DDD2
#define BLUE_LED	DDD3

#define RED_VALUE 	OCR1AL
#define GREEN_VALUE	OCR1BL
#define BLUE_VALUE	OCR2A

	.section	.data

table:	.byte	1
		.byte	3
		.byte	7
		.byte	15
		.byte	31
		.byte	63
		.byte	127
		.byte	255

	.section	.bss

red:	.space	1, 0
green:	.space	1, 0
blue:	.space	1, 0

	.section	.text

; RGB LED
;   9 PB1	R	PWM		OC1A	OCR1AH OCR1AL	TCCR1A TCCR1B TCCR1C
;  10 PB2	G	PWM		OC1B	OCR1BH OCR1BL	TCCR1A TCCR1B TCCR1C
;  11 PB3	B	PWM		OC2A	OCR2A			TCCR2A TCCR2B

; Red:   3X numbers   1-8
; Green: 6X	lowercase a-h
; Blue:  4X uppercase A-H
; Levels: [RGB]Y
;			1 3 7 15 31 63 127 255
;         	0 1 2 3  4  5  6   7

	.global doit
doit:
	cbi		_SFR_IO_ADDR(DDRD), DDD2
	cbi		_SFR_IO_ADDR(DDRD), DDD3
	cbi		_SFR_IO_ADDR(DDRD), DDD4
	sbi		_SFR_IO_ADDR(PORTD), PORTD2
	sbi		_SFR_IO_ADDR(PORTD), PORTD3
	sbi		_SFR_IO_ADDR(PORTD), PORTD4
	ldi		r16, (1<<ISC00)|(1<<ISC10)
	sts		EICRA, r16
	ldi		r16, (1<<INT0)|(1<<INT1)
	sts		EIMSK, r16
	ldi		r16, (1<<PCIE2)
	sts		PCICR, r16
	ldi		r16, (1<<PCINT20)
	sts		PCMSK2, r16
   
   clr      r18
   clr      r19
   clr      r22

	ldi		r18, 0
	ldi		r17, 3
	call	EEPROM_read
	cpi		r16, 23
	brne	firsttime
	ldi		r18, 0
	ldi		r17, 0
	call	EEPROM_read
	sts		red, r16
	ldi		r18, 0
	ldi		r17, 1
	call	EEPROM_read
	sts		green, r16
	ldi		r18, 0
	ldi		r17, 2
	call	EEPROM_read
	sts		blue, r16
	rjmp	cont
firsttime:
	clr		r16
	sts		red, r16
	sts		green, r16
	sts		blue, r16

cont:
	sts		OCR1AH, r16
	sts		OCR1AL, r16
	sts		OCR1BH, r16
	sts		OCR1BL, r16
	ldi		r16, (1<<COM1A1)|(1<<COM1B1)|(1<<WGM10)
	sts		TCCR1A, r16
	ldi		r16, (1<<CS10)|(1<<WGM12)
	sts		TCCR1B, r16

	clr		r16
	sts		OCR2A, r16
	ldi		r16, (1<<COM2A1)|(1<<WGM21)|(1<<WGM20)
	sts		TCCR2A, r16
	ldi		r16, (1<<CS20)
	sts		TCCR2B, r16

	sbi		_SFR_IO_ADDR(DDRB), DDD1
	sbi		_SFR_IO_ADDR(DDRB), DDD2
	sbi		_SFR_IO_ADDR(DDRB), DDD3
	sei

forever:
	lds		r16, red
	sts		OCR1AL, r16
	lds		r16, green
	sts		OCR1BL, r16
	lds		r16, blue
	sts		OCR2A, r16
	rjmp	forever

	.global	USART_RX_vect
USART_RX_vect:
	in		r2, _SFR_IO_ADDR(SREG)
	push	r2
	lds		r2, UDR0
	call	store_color
	pop		r2
	out		_SFR_IO_ADDR(SREG), r2
	reti

	.global INT0_vect
INT0_vect:
	in		r2, _SFR_IO_ADDR(SREG)
	push	r2
	sbic	_SFR_IO_ADDR(PIND), PIND2
	rjmp	notPushed_1
pushed_1:
	ldi		r17, 0
	lds		r16, red
	call		EEPROM_write
	ldi		r17, 1
	lds		r16, green
	call		EEPROM_write
	ldi		r17, 2
	lds		r16, blue
	call		EEPROM_write
	ldi		r17, 3
	ldi		r16, 23
	call		EEPROM_write
   	inc      	r18
   	cpi      	r18, 5
   	breq     	reset_1
   	rjmp     	notPushed_1
   
reset_1:
   	clr      	r18
   
notPushed_1:
	pop		r2
	out		_SFR_IO_ADDR(SREG), r2
	reti
	
	.global INT1_vect
INT1_vect:
	in	r2, _SFR_IO_ADDR(SREG)
	push	r2
	sbic	_SFR_IO_ADDR(PIND), PIND3
	rjmp	notPushed_clear
	clr	r18
pushed_clear:
	ldi		r16, 0
	ldi		r17, 0
	call	EEPROM_write
	ldi		r16, 0
	ldi		r17, 1
	call	EEPROM_write
	ldi		r16, 0
	ldi		r17, 2
	call	EEPROM_write
	ldi		r16, 0
	ldi		r17, 3
	call	EEPROM_write
   	inc      r18
   	cpi      r18, 4
   	breq     reset_clear
   	rjmp     pushed_clear
reset_clear:
   	clr     r18
	sts	red, r18
	sts	green, r18
	sts	blue, r18
notPushed_clear:
	pop		r2
	out		_SFR_IO_ADDR(SREG), r2
	reti

	.global PCINT2_vect
PCINT2_vect:
	in		r2, _SFR_IO_ADDR(SREG)
	push	r2
	sbic	_SFR_IO_ADDR(PIND), PIND4
	rjmp	notPushed_2
pushed_2:
	ldi		r17, 3
	call		EEPROM_read
	cpi		r16, 23
	brne		loopit
	ldi		r17, 0
	call		EEPROM_read
	sts		red, r16
	ldi		r17, 1
	call		EEPROM_read
	sts		green, r16
	ldi		r17, 2
	call		EEPROM_read
	sts		blue, r16
   	inc      	r19
   	cpi      	r19, 5
   	breq     	reset_2
   	rjmp     	notPushed_2
loopit:
	ldi		r19, 0
	ldi		r17, 0
	call		EEPROM_read
	sts		red, r16
	ldi		r19, 0
	ldi		r17, 1
	call		EEPROM_read
	sts		green, r16
	ldi		r19, 0
	ldi		r17, 2
	call		EEPROM_read
	sts		blue, r16
	inc		r19
	pop		r2
	out		_SFR_IO_ADDR(SREG), r2
	reti
reset_2:
   clr      r19   
   
notPushed_2:
	pop		r2
	out		_SFR_IO_ADDR(SREG), r2
	reti

store_color:

;	int index = (r2 & ox0f) - 1;
;	int color = table[index];
;   if (color & 0xf0 == 0x30) {
;		red = color;
;	} else {
;		if (color & 0xf0 == 0x60) {
;			green = color;
;		} else {
;			if (color & 0xf0 == 0x40) {
;				blue = color;
;			}
;		}
;	}

	push	   r31
	push	   r30
	push	   r20
	push	   r21
	clr		r21
	ldi		r31, hi8(table)
	ldi		r30, lo8(table)
	mov		r20, r2
	andi	   r20, 0x0f
	dec		r20
	andi	   r20, 0x07
	add		r30, r20
	adc		r31, r21
	ld		   r20, Z
	mov		r21, r2
	andi	   r21, 0x70
rt:
	cpi		r21, 0x30
	breq	r
gt:
	cpi		r21, 0x60
	breq	g
bt:
	cpi		r21, 0x40
	breq	b
r:
	sts		red, r20
	rjmp	done
g:
	sts		green, r20
	rjmp	done
b:
	sts		blue, r20
done:
	pop		r21
	pop		r20
	pop		r30
	pop		r31
	ret

	.end
