.text
.global _start

_start:
        mov r4, #0              // r4 = counter

        // Load HEX display addresses
        ldr r5, =0xFF200020     // HEX0 base address
        ldr r6, =0xFF200030     // HEX1 base address

        // Setup ARM A9 Private Timer
        ldr r8, =0xFFFEC600     

        // Write load valu
        ldr r9, =50000000
        str r9, [r8]           

        // Setting control register
        mov r9, #0b011
        str r9, [r8, #8]        // store to Control register

        bl display_counter

loop:
        
wait_timer:
        ldr r9, [r8, #12]       // read interrupt status register
        tst r9, #1              // test bit
        beq wait_timer          // loop if F not set yet

        // Clear the F flag by writing 1 to it
        mov r9, #1
        str r9, [r8, #12]

        // Increment counter
        add r4, r4, #1
        cmp r4, #100
        moveq r4, #0

       
        bl display_counter

        b loop


// display_counter
display_counter:
	push {lr, r3, r4}
        
        mov r0, r4
        bl seg7_code
        str r0, [r5]
        
        mov r0, r3
        bl seg7_code
        str r0, [r6]
        
        pop {lr, r3, r4}
        
        bx lr


bit_codes:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2           // pad with 2 bytes to maintain word alignment

seg7_code:  ldr     r1, =bit_codes
            ldrb    r0, [r1, r0]
            bx      lr

.end
