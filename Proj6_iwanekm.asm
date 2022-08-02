TITLE Project 6 - String Primitives and Macros      (Proj6_iwanekm.asm)

;--------------------------------------------------------------------------------------------------------------------------------------------------
; Author:					Michael Iwanek
; Last Modified:			08/01/2022
; OSU email address:		iwanekm@oregonstate.edu
; Course number/section:	CS271 Section 400
; Project Number:			06
; Due Date:					08/07/2022
;--------------------------------------------------------------------------------------------------------------------------------------------------
; Description: 
;--------------------------------------------------------------------------------------------------------------------------------------------------
;			-This program 

;--------------------------------------------------------------------------------------------------------------------------------------------------


INCLUDE Irvine32.inc

mGetString	MACRO	buffer, buffer_size
	PUSH  EDX				;Save EDX register
	PUSH  ECX
	MOV   EDX,  buffer
	MOV   ECX,  [buffer_size]
	CALL  ReadString
	POP   EDX				;Restore EDX
	POP   ECX				;Restore ECX
ENDM

mDisplayString	MACRO	buffer
	PUSH  EDX				;Save EDX register
	MOV   EDX, buffer
	CALL  WriteString
	POP   EDX				;Restore EDX
ENDM

; (insert constant definitions here)

.data
program_info_1		BYTE		"Hello!  Welcome to my program:  String Primitives and Macros by Michael Iwanek",13,10,13,10,0
program_info_2		BYTE		"Please enter in 10 signed decimal integers.  This program will then display each number entered, their average value, and sum.",13,10
					BYTE		"Each number must be able to fit within a 32 bit register, or be between the values of -2,147,483,647 and 2,147,483,647 inclusive (or +/- 2^31).",13,10,13,10,0
userString			BYTE		12 DUP(0)			;10 digit string, +1 for + or neg sign; +1 for null terminator
userString_len		DWORD		LENGTHOF userString
num_prompt			BYTE		"Please enter a signed number between -2^31 and 2^31: ",0
IntegerArray		SDWORD		2000 DUP(?)
IntegerArray_len	DWORD		LENGTHOF IntegerArray  ;num elements
IntegerArray_size	DWORD		SIZEOF IntegerArray	   ;num bytes

.code
main PROC

; (insert executable instructions here)
	
	mDisplayString OFFSET program_info_1
	mDisplayString OFFSET program_info_2
	

	PUSH    userString_len
	PUSH	OFFSET userString
	PUSH	OFFSET num_prompt
	CALL	ReadVal


	Invoke ExitProcess,0	; exit to operating system
main ENDP


ReadVal PROC

	;Invoke the mGetString macro to get user input in the form of a string of digits
	
	LOCAL Value:DWORD, wholeNum:DWORD
	mDisplayString [EBP + 8]				;prompt num	
	mGetString [EBP + 12], [EBP + 16]		;pass (ref, size) to macro to get user string




	;Convert (USING STRING PRIMITIVES) the string of ASCII digits to its numeric value representation (SDWORD), validating each char is a valid # (not symbol)
	
	;LODSB	;takes ESI and copies to AL, then increment ESI to next element

	mov EDX, OFFSET userString		;test delete
	CALL WriteString				;test delete


	;Store this one value in a memory variable (output paratmeter, by reference).




	RET 4		; dereference 1 passed parameter address

ReadVal ENDP


WriteVal PROC


WriteVal ENDP


END main
