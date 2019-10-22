;Daniel Richards
;dric372
;761994566
        	.orig   x3000

		LEA	r0, start
		JMP	r0

op1     	.fill   b10000010		; must be < 256, treating as -128 to 127
op2     	.fill   b10000001		; must be < 256, treating as -128 to 127

; now the arithmetic

ADDNUMS        	add     r2, r0, r1	; r2 is cresult
		ld	r3, mask
		and	r3, r2, r3	; r3 is result
        	st      r3, result
; carry
		and	r3, r3, #0	; clear r3, carry
		ld	r4, carrybit	; r4 is carrybit
        	and     r4, r2, r4
		brz	nocarry
		add	r3, r3, #1
nocarry        	st      r3, carry
; overflow
		and	r3, r3, #0
		ld	r4, signbit	; r4 is signbit
		and	r0, r0, r4	; r0 no longer op1
		brz	plus1
		add	r3, r3, #1
plus1		add	r0, r3, #0	; r0 sign1
		and	r3, r3, #0
		and	r1, r1, r4	; r1 no longer op1
		brz	plus2
		add	r3, r3, #1
plus2		add	r1, r3, #0	; r1 sign2
		and	r3, r3, #0
		and	r2, r2, r4	; r2 no longer cresult
		brz	plus3
		add	r3, r3, #1
plus3		add	r2, r3, #0	; r2 is signres
		and	r3, r3, #0
; we need to compare sign1(r0) with sign2(r1)
		not	r0, r0
		add	r0, r0, #1	; 2's complement
		add	r1, r1, r0	; subtraction
		brnp	different
; compare signres(r2) with sign1(r0)
		add	r2, r2, r0	; subtraction
		brz	different	; actually the same
		add	r3, r3, #1
different	st	r3, overflow

		RET			;Returns to Main Routine



start		;MAIN ROUTINE
       		ld      r0, op1		; r0 is op1
	        ld      r1, op2		; r1 is op
		LD	r6, op1		;r1 = op1
		JSR	ADDNUMS
		JSR	PRINTLN
		JSR	CR
		LD	r6, op2
		JSR	PRINTLN
		JSR	CR
		LD	r0, #61	
		JSR	EQUALS
		JSR	CR
		LD	r6, result
		JSR	PRINTLN
		
		ld	r1, carry		; IF r1 P then print carry
		BRnz	NoCarryP		;No carry print
		JSR	SPACE
		JSR	PRINTC
NoCarryP	ld	r1, overflow
		BRnz	NoOFP			;NoOverFlow Print
		JSR 	SPACE
		JSR	PRINTV

NoOFP		ld	r1, #19


		
		halt


PRINTV		ST 	r7, RETADD		
		LEA	r0, charv	;Overflow Character
		PUTS
		BRnzp 	RETURN

PRINTC		ST	r7, RETADD
		LEA	r0, charc	;Carry Character 
		PUTS
		BRnzp RETURN

SPACE		ST	r7, RETADD
		LEA	r0, chars	;Space Charcter
		PUTS
		BRnzp RETURN

EQUALS		ST	r7, RETADD
		LEA	r0, Eq
		PUTS
		BRnzp RETURN

CR		ST	r7, RETADD	; RETADD = Return Address	
		LD	r0, Car		
		OUT
		BRnzp RETURN

RETURN		LD	r7, RETADD
		ret			;Just a branch to return the subroutine. 
		

PRINTLN		ST	r7, RETADD			;INITIALISES THE REGISTERS NEEDED FOR LOOPING
		LD	r2, ZERO	;R2 = Iteration Count of loop.
		LD	r1, ITERATE	;8 Indicates the maximum number of complete iterations (COUNTING FROM 0)
		NOT 	r1, r1
		ADD	r1, r1, #1	;r1 = -8. To use in subtraction with r1 to compare if r1 (iterations) == 8.
		
PRINTLOOP	ADD	r5, r1, r2	;SUBS r2 - r1 to see if it's 8. If 8 then STOP.
		BRz	RETURN
		LEA	r3, MASKARRAY	;Puts address of MASKARRAY into r3
		ADD	r3, r3, r2	;Puts + ITERATION to the address
		
		LDR	r3, r3, #0
		AND	r5, r3, r6	;ANDS r4(Mask OBJ) w/ r0(PRINTVAL) into r5
		BRz	PRINTZERO
		BRp	PRINTONE
		
		;IF the program gets here. Something went wrong. VERY VERY WRONG.
		LD	r0,ERROR
		OUT
		RET

PRINTZERO	LD	r0, ASCIIR
		ADD	r2, r2, #1 ; add to iter
		OUT
		BRnzp PRINTLOOP

PRINTONE	LD	r0, ASCIIR
		ADD	r0, r0, #1
		ADD	r2, r2, #1 ; add to iter
		OUT
		BRnzp PRINTLOOP





		


		

	
END
	        halt
;All values in Binary. because why not?

Car		.STRINGz "\n"
Eq		.STRINGz "========"
charc		.STRINGz "c"
charv		.STRINGz "v"
chars		.STRINGz " "
RETADD		.blkw	1		;Address in memory in which causes 
ASCIIR		.fill	b00110000	;48 IN ASCII "R" indicated "OFFSET" much like the sill LDR OPCODE.
ERROR		.fill	b00100001	;"!" in ASCII
ITERATE		.fill	#8		;Value 8
ZERO		.fill	#0		;Value 0
mask		.fill	b11111111	;MASK used in  addition of numbers
signbit		.fill	b10000000	;Used in addition of numbers
carrybit	.fill	b100000000	;Used in addition of number
result  	.blkw   1		;Memeory for result
carry   	.blkw   1		;Memory for carry
overflow    	.blkw   1		;Memory for overfloww
MASKARRAY	.fill	b10000000	
		.fill	b01000000	
		.fill	b00100000
		.fill	b00010000
		.fill	b00001000
		.fill	b00000100
		.fill	b00000010
		.fill	b00000001

		.end			