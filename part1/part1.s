.text
.global _start

_start:                             
            ldr     r6, =0xFF200050      // KEY base address
            mov     r5, #0               // current digit (0-9)
            b       display

loop:

            ldr     r1, [r6]             // read KEY data register
            cmp     r1, #0
            beq     loop                 // no key pressed

            tst     r1, #1               // KEY0
            bne     key0

            tst     r1, #2               // KEY1
            bne     key1

            tst     r1, #4               // KEY2
            bne     key2

            tst     r1, #8               // KEY3
            bne     key3

            b       loop

key0:
            mov     r5, #0               // display 0
wait0:
            ldr     r1, [r6]
            tst     r1, #1
            bne     wait0
            b       display

key1:
            add     r5, r5, #1           // increment
            cmp     r5, #10
            moveq   r5, #0               // wrap 9 to 0
wait1:
            ldr     r1, [r6]
            tst     r1, #2
            bne     wait1
            b       display

key2:
            cmp     r5, #0
            subne   r5, r5, #1
            moveq   r5, #9               // wrap 0 to 9
wait2:
            ldr     r1, [r6]
            tst     r1, #4
            bne     wait2
            b       display

key3:
            mov     r0, #0               // blank HEX0
            ldr     r8, =0xff200020
            str     r0, [r8]
wait3:
            ldr     r1, [r6]
            tst     r1, #8
            bne     wait3
            b       loop


bit_codes:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2      // pad with 2 bytes to maintain word alignment

seg7_code:  ldr     r1, =bit_codes  
            ldrb    r0, [r1, r0]    
            bx      lr
            
/* display r5 on hex1-0, r6 on hex3-2 and r7 on hex5-4 */
display:    ldr     r8, =0xff200020 // base address of hex3-hex0
            mov     r0, r5          // digit to display
            bl      seg7_code       // returns r0 converted to a bit code in r0   
            str     r0, [r8]
            b       loop
          
.end
