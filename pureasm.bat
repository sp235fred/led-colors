del avrasm.*
..\..\arduino-1.6.5-r5\hardware\tools\avr\bin\avr-gcc -mmcu=atmega328p -I ..\..\arduino-1.6.5-r5\hardware\tools\avr\avr\include -o avrasm.o *.S
..\..\arduino-1.6.5-r5\hardware\tools\avr\bin\avr-ld -o avrasm.elf -Map avrasm.map avrasm.o
..\..\arduino-1.6.5-r5\hardware\tools\avr\bin\avr-objdump -h -D avrasm.elf > avrasm.lss
..\..\arduino-1.6.5-r5\hardware\tools\avr\bin\avr-objcopy -O ihex avrasm.elf avrasm.hex
..\..\arduino-1.6.5-r5\hardware\tools\avr\bin\avrdude -C..\..\arduino-1.6.5-r5\hardware\tools\avr\etc\avrdude.conf -patmega328p -carduino -PCOM3 -b115200 -D -Uflash:w:avrasm.hex:i
