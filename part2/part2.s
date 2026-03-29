.text
.global _start

_start:
        // Initialize counter to 0
        mov r4, #0              // r4 = counter

        // Load base addresses
        ldr r5, =0xFF200020     // HEX0 base address
        ldr r6, =0xFF200030     // HEX1 base address

        // Displaying initial value
        bl display_counter

loop:

do_delay:
        ldr r7, =200000000
sub_loop:
        subs r7, r7, #1
        bne sub_loop

        // Increment counter
        add r4, r4, #1
        cmp r4, #100
        moveq r4, #0

        // Display updated counter
        bl display_counter

        b loop


display_counter:
        // displaying 
        mov r0, r4
        bl seg7_code
        str r0, [r5]

        mov r0, r3
        bl seg7_code
        str r0, [r6]
        
        b loop


bit_codes:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2           // pad with 2 bytes to maintain word alignment

seg7_code:  ldr     r1, =bit_codes
            ldrb    r0, [r1, r0]
            bx      lr

.end
