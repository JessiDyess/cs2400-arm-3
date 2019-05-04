		;		ARM Programming Assignment #3: IEEE 754 to TNS bit-level marshaller
		;
		;		Write a program to convert a 32-bit single-precision IEEE 754 floating-point
		;       number to the Tandem Non-stop Series (TNS) format. Refer to the README for a
		;       description of the format. Convert the numbers in `floats` and write the TNS
		;       equivalents into the `tns` area, one after the other.
		;
		;       Bonus:
		;       1. (30 extra points) Implement the reverse conversion, from TNS to IEEE.
		;       2. (50 extra points) Organize the code into two subroutines, with stack
		;          support.
		;       3. (10 extra points) In the main program, implement a round-trip conversion
		;          and prove the results match the initial values in 'floats'.  Define a
		;          `FILL` region to hold the IEEE 754 results.
		;

		;		Your code here

floats	DCD		0xa0bcff0d, 0x13c0adea
tns	    FILL	16
			
			
; Made a mask for each part of the numbers: Significand, exponent and sign bit of float
; Applied each maks after "taking apart" the numbers then put them all back in order to get the correct result 
			
SMASK		DCD		0x0000,  0x8000  ; Mask for sign bit of the float numbers
IEEEEXPMASK	DCD		0x0000, 0x7F80  ; Mask for the exponent bits of the IEEE format
IEEESIGMASK	DCD		0xFFFF, 0x007F  ; Mask for the significand bits of the IEEE format
TNSSIGMASK	DCD		0xFE00, 0x7FFF  ; Mask for TNS Significand
TNSEXPMASK	DCD		0x01FF, 0x0000  ; Mask for TNS Exponent
			
Main
			ADR		r0, floats
			LDR		r0, [r0]        ; Load IEEE formatted # into r0
			BL		ToTNS       ; Branch to IEEE to TNS conversion
			BL		ToIEEE      ; Branch to TNS to IEEE conversion
			
			end
			
			
ToTNS		ADR		r1, SMASK
			LDR		r1,[r1]
			ADR		r2, IEEEEXPMASK
			LDR		r2,[r2]
			ADR		r3, IEEESIGMASK
			LDR		r3, [r3]
			
			
			AND		r4, r0, r1          ; store sign bit in r4
			AND		r5, r2, r0          ; estore exponent in r5
			MOV		r5, r5, LSR #23     ; shift exponent right by 23 bits
			AND		r6, r3, r0          ; store significand in r6
			ADD		r6, r7, r6, LSL #8  ; shift significand left 8 bits, remove the least significatn bit
			ORR		r0, r4, r5          ; put sign and exponent back in
			ORR		r0, r0, r6          ; put significand back in
			mov		pc,lr
			
			
ToIEEE		ADR		r1, SMASK
			LDR		r1, [r1]        ; Put the sign mask into r1
			ADR		r2, TNSSIGMASK
			LDR		r2, [r2]        ; Put the Significand mask into r2
			ADR		r3, TNSEXPMASK
			LDR		r3, [r3]        ; Load TNS Exponent mask into r3
			
			;		Convert back to IEEE
			AND		r4, r0, r1          ; pull out sign bit
			AND		r5, r2, r0          ; pull out significand
			MOV		r5, r5, LSR #8      ; Shift significand right 8 bits
			AND		r6, r3, r0          ; pull out exponent
			SUB		r6, r6, #129		; subtract for excess encoding 
			ADD		r6, r7, r6, LSL #23 ; Shift exponent left 23 bits
			
			;		Pack the converted number into r0
			ORR		r0, r4, r5          ; Pack sign and significand
			ORR		r0, r0, r6          ; Pack exponent with sign and significand,
			;		r0 now holds TNS to IEEE converted word
			MOV		PC, LR              ; Return to main subroutine
			
Loop			MOV		r0, r1, LSR #28     ; Get top nibble
			CMP		r0, #9              
			MOV		r1, r1, LSL #4      ; Shift left one 
			SUBS		r2, r2, #1      ; Decrement nibble count
			BNE		Loop           ; If to loop again if needed
			MOV		r0, #10             ; Load 10 into r0
			MOV		r0, r3              ; Move converted number back to r0
			b		Main
			
			
			
