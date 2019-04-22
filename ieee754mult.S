		;		ARM Programming Assignment #3: 32 bit IEEE 754 single-precision multiplier
		;
		;		Write a 32-bit floating point multiplier. The numbers will be represented
		;       in the single-precision IEEE 754 floating-point standard. The result should
		;       also be in IEEE 754 binary32. Assume you only have normalized numbers, i.e.
		;       the exponent is never 0b00000000.
		;		Write the result in the provided "fill" word.

		;		Your code here

floats		DCD		0xa0bcff0d, 0x13c0adea
result		FILL		8
			
masks
sign			DCD		0x80000000
exp			DCD		0x7f800000
frac			DCD		0x007fffff
			
			
			ldr		r1, =0xa0bcff0d
			ldr		r2, =0x13c0adea
			
multiply
			adr		r10, sign
			ldr		r10, [r10]
			and		r3, r1, r10        ; get the sign of the first operand
			and		r4, r2, r10         ; get the sign of the second operand
			
			eor		r0, r3, r4                  ; get the new sign bit
			
			adr		r9, exp
			ldr		r9, [r9]
			
			and		r3, r1, r9                  ;get exponent of 1st with exp mask
			and		r4, r2, r9                  ;get exponent of 2nd with exp mask
			
			mov		r3, r3, lsr #23
			mov		r4, r4, lsr #23
			sub		r3, r3, #127        ; remove exponent bias 1st operand (bias in floating point is 127)
			sub		r4, r4, #127		; remove bias for 2nd operand
			
			add		r5, r3, r4          ; add exponents, r5 now holds the new exponent of the result
			
			adr		r9, frac
			ldr		r9, [r9]
			
			and		r3, r1, r9                  ; get fraction from operand1
			and		r4, r2, r9                  ; get fraction  from operand2
			orr		r3, r3, #0x00800000         ; add implied 1 to front of fractions
			orr		r4, r4, #0x00800000
			
			
			
			mov		r6, #0
			mov		r7, #0
			mov		r9, #0                      ; Zero out to store the results
			
mul
			and		r8, r3, #1                 ; Check for a 1 in the LSB
			beq		noadd                      ; Ands will set the zero flag if the LSB doesn't exist. "eq" jumps when the zero flag is present
			
			adds		r7, r7, r4
			add		r6, r6, r9                   ; Add r4 to the low significance register if the LSB in r3 is a 1, then add carry to high reg along with high sig register
			
noadd
			mov		r9, r9, lsl #1
			movs		r4, r4, lsl #1
			add		r9, r9, #0                 ; Shift r4 to the left, move carry bit and add overflow into r9
			
			movs		r3, r3, lsr #1             ; Shift r3 to the right and set flags
			bne		mul                         ; The previous movs will set the zero flag if we move zero into r3, causing a branch if r3 is not yet zero
			
			
			
fraction
			and		r8, r6, #0x00008000         ; check to see if 16th bit is 0 or 1
			
			
			addne	r5, r5, #1         ; means 16th bit was a 1
			movne	r6, r6, lsl #16    ; move bits befre combining
			movne	r7, r7, lsr #16     ; move bits before combining
			
			
			moveq	r6, r6, lsl #17    ; if bit 16 was not 1 shift 17
			moveq	r7, r7, lsr #15     ; move the low bits right so they can be merged with the high bits
			
			
			orr		r6, r6, r7           ; put the fraction halves together
			mov		r6, r6, lsr #8       ; shift to create correct number of bits
			bic		r6, r6, #0x00800000         ; clear the implied 1 from the fraction that was added earlier
			
combine
			add		r5, r5, #127        ; re-add bias to the exponent to make sure it is correct
			mov		r5, r5, lsl #23     ; shift exponent into its ieee754 position
			orr		r0, r0, r5          ; merge exponent into the result register r0
			orr		r0, r0, r6          ; merge fraction into the result register r0
			

			end
