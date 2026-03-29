.text
.global _start

_start:
        mov r4, #0              // r4 = 0-99
        mov r5, #0              // r5 = 0-59
        mov r10, #0             // r10 = running flag

        ldr r6, =0xFF200020     // HEX0 and HEX1
        ldr r7, =0xFF200030     // HEX2 and HEX3


        ldr r9, =0xFF20005C     // KEY edge-capture register

        ldr r8, =0xFFFEC600     // timer base

        ldr r11, =2000000
        str r11, [r8]           // write to Load register

        // Control: Auto=1, Enable=0
        mov r11, #0b010
        str r11, [r8, #8]

        // Clear any pending key presse
        mov r11, #0xF
        str r11, [r9]

        bl display_time

loop:
        // Check for key press via edge-capture register
        ldr r11, [r9]           
        tst r11, #0xF           
        beq no_keypress

        // Clear the edge-capture register
        mov r11, #0xF
        str r11, [r9]

        // Toggle running flag
        cmp r10, #0
        bne stop_timer

start_timer:
        mov r10, #1            
        // Enable time
        mov r11, #0b011
        str r11, [r8, #8]
        b no_keypress

stop_timer:
        mov r10, #0            
        // Disable timer
        mov r11, #0b010
        str r11, [r8, #8]

no_keypress:
        // If not running, skip timer check
        cmp r10, #0
        beq loop

        // Poll F flag in interrupt status register
        ldr r11, [r8, #12]
        tst r11, #1
        beq loop                // check keys again

        // Clear F flag
        mov r11, #1
        str r11, [r8, #12]

        // Increment hundredths
        add r4, r4, #1
        cmp r4, #100
        bne update_display

        // Hundredths rolled over, increment seconds
        mov r4, #0
        add r5, r5, #1
        cmp r5, #60
        movge r5, #0 

update_display:
        bl display_time

        b loop


// display_time
display_time:
        push {lr}

        mov r0, r4
        bl seg7_code
        str r0, [r11]
        
        mov r0, r5
        bl seg7_code
        str r0, [r11, #4]
        
        mov r0, r6
        bl seg7_code
        str r0, [r12]
        
        mov r0, r7
        bl seg7_code
        str r0, [r12, #4]

        pop {lr}
        bx lr


bit_codes:  .byte   0b00111111, 0b00000110, 0b01011011, 0b01001111, 0b01100110
            .byte   0b01101101, 0b01111101, 0b00000111, 0b01111111, 0b01100111
            .skip   2           // pad with 2 bytes to maintain word alignment

seg7_code:  ldr     r1, =bit_codes
            ldrb    r0, [r1, r0]
            bx      lr

.end
