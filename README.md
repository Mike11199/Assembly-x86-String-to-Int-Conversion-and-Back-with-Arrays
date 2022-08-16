# Project-6-String-Primitives-and-Macros

This is my submission for CS 271 - Computer Architecture & Assembly Language Project 6, taken Summer 2022 at Oregon State University.  Per the Syllabus, this is the portfolio project, which is allowed to be made public, unlike other projects.  This was coded in Visual Studio in x86 Assembly Language, using the MASM assembler.

<h2> Project Description </h2>

-This program allows numbers to be read/written by the users without Irvine library procedures, using manual conversion of numbers to strings and vice versa.

-This program allows user to enter in a series of numbers as strings.  It then converts the string into a number using the ReadVal procedure.  It accomplishes this without Irvine library procedures, by REPEATEDLY MULTIPLYING each char of the string converted to a number by 10 if necessary, building up a number digit by digit.

-After creating the number, it saves it to an array of numbers.  It then calculates the average and sum of these numbers and displays these to the user.

-Finally, it uses the WriteVal function (also used for the sum/average previously) to loop through each SDWORD integer array and convert that number
back into a string manually wihtout Irvine library procedures.  It does this by REPEATEDLY DIVIDING each number by 10 to build back a string from the
remainder of each division. From this, it uses string primitve instructions to reverse the string, so that it is in the correct order.

-It also makes use of two macros to get and display strings to the user.




```assembly
; =======================================================================================================================================================
; Name:				ConvertNumtoASCII
;
; Description:		-This is passed an integer by reference.  It repeatedly divides this integer by 10 to obtain its digits.  It adds each remainder after
;					 the division by 10 to a string, then adds a null terminator.  It then reverses the string using string primitives so that it is in the
;					 original order the number was entered in by the user (as a string).
;
; Preconditions:	-none
;
; Postconditions:	-none
;
; Receives:			-Offsets of the two output strings needed by reference.  One to hold the string being created after multiple divisions by 10, the other
;					 to hold the reversed string.  Also receives the integer by reference to be divided.  Does not receive length, stops when both the quotient
;					 and the remainder are both zero.  Due to this, has a special case to handle being given a number that is exactly zero.
;
; Returns:			-Returns
;
; =======================================================================================================================================================
ConvertNumtoASCII PROC
	
	 ; parameter order:  integer value, temp string 1, tempstring2

	LOCAL num:DWORD, quotient:DWORD, remainder:DWORD, newStringLen:DWORD, negativeFlag:DWORD, num2:SDWORD
	PUSHAD

	MOV					negativeFlag, 1

	MOV					ecx, 32
	MOV					EDI, [EBP + 12]		; temp string1 offset from stack

_ClearString_one:
	MOV					EAX, 0
	MOV					[EDI], EAX
	add					EDI, 1
	loop				_ClearString_one


	
	MOV					ecx, 32
	MOV					EDI, [EBP + 16]		; temp string 2 offset from stack

_ClearString_two:
	MOV					EAX, 0
	MOV					[EDI], EAX
	add					EDI, 1
	loop				_ClearString_two



	MOV					EDI, [EBP + 12]		; temp string offset from stack
	MOV					EAX, [EBP + 8]		; integer from stack

	MOV					num2, EAX
	MOV					newStringLen, 0

	cmp				    EAX, 2147483648		;edge case
	jz					_numNegativeinArrayEdgeCase
	jmp					_skipEdgeCase

_numNegativeinArrayEdgeCase:
	mov				    EAX, 2147483648		;edge case
	mov					num2, EAX
	mov					num, EAX
	MOV					negativeFlag, 2
    jmp					_MainConversionLoop

_skipEdgeCase:

	;test if number is negative, if so we need to reverse it and add a negative sign in front
	CMP					EAX, 0
	jl					_numIsNegativeInvert
	CMP					EAX, 0
	jz					_NumisJustZero
	mov					eax, num2
	mov					num, eax
	jmp					_MainConversionLoop


	;test if number is just zero

_numIsNegativeInvert:
	
	mov					num2, eax
	neg					num2
	mov					eax, num2
	mov					num, eax
	MOV					negativeFlag, 2


_MainConversionLoop:
	;need to repeatedly divide by 10, multiply by zeros until no remainder left, then reverse string array created.

	MOV					EAX, num
	CDQ 
	MOV					ebx, 10
	IDIV				ebx
	MOV					quotient, EAX
	MOV					remainder, EDX

	CMP					remainder, 0
	jg					_remainderExists
	CMP					quotient, 0
	jg					_Quotient						; if no quotient and remainder
	jmp					_AddTERMINATOR


_Quotient:
	MOV					EAX, 0
	MOV					num, EAX
	jmp					_startNumConversion

_remainderExists:
	MOV					EAX, remainder
	MOV					num, EAX
	jmp					_startNumConversion


_startNumConversion:
	CMP					num, 0
	jz					_zero_num
	CMP					num, 1
	jz					_one_num
	CMP					num, 2
	jz					_two_num
	CMP					num, 3
	jz					_three_num
	CMP					num, 4
	jz					_four_num
	CMP					num, 5
	jz					_five_num
	CMP					num, 6
	jz					_six_num
	CMP					num, 7
	jz					_seven_num
	CMP					num, 8
	jz					_eight_num
	CMP					num, 9
	jz					_nine_num


_zero_num:
	MOV					AL, 48 
	jmp					add_num_to_string

_one_num:
	MOV					AL, 49 
	jmp					add_num_to_string

_two_num:
	MOV					AL, 50 
	jmp					add_num_to_string

_three_num:
	MOV					AL, 51 
	jmp					add_num_to_string

_four_num:
	MOV					AL, 52
	jmp					add_num_to_string

_five_num:
	MOV					AL, 53 
	jmp					add_num_to_string

_six_num:
	MOV					AL, 54 
	jmp					add_num_to_string

_seven_num:
	MOV					AL, 55 
	jmp					add_num_to_string

_eight_num:
	MOV					AL, 56
	jmp					add_num_to_string

_nine_num:
	MOV					AL, 57 
	jmp					add_num_to_string

_NumisJustZero:
	MOV					AL, 48
	MOV					[EDI], AL				; move result to output variable
	add					EDI, 1					; increment
	inc					newStringLen
	jmp					_AddTERMINATOR

add_num_to_string:
	MOV					[EDI], AL				; move result to output variable
	add					EDI, 1					; increment
	MOV					EAX, quotient
	MOV					num, EAX
	inc					newStringLen
	jmp					_MainConversionLoop


_AddTERMINATOR:
	MOV					AL, 0
	MOV					[EDI], AL				; move result to output variable
	inc					newStringLen


_FinishConvertingNumtoString:

	;NEED TO REVERSE STRING AFTERWARDS
	MOV					ECX, newStringLen
	MOV					ESI, [EBP + 12]			; temp string offset from stack
	add					ESI, ECX				; so source strings starts from end
	dec					ESI
	dec					ESI
	MOV					EDI, [EBP + 16]			; temp string offset2 from stack
	
	CMP					negativeFlag, 2
	jz					_addNegativeSignBeforeReversal
	jmp					_revLoop

_addNegativeSignBeforeReversal:
	MOV					EAX, 45
	MOV					[EDI], EAX				; temp string offset2 from stack
	add					edi, 1

_revLoop:										;reference StringManipulator.asm from canvas
	STD
	LODSB
	CLD
	STOSB
	LOOP				_revLoop



	POPAD
	ret 12

ConvertNumtoASCII ENDP
```
