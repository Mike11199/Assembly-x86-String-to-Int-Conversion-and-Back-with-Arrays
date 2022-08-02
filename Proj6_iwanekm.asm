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
userString			BYTE		12 DUP(?)			;10 digit string, +1 for + or neg sign; +1 for null terminator
userString_len		DWORD		?
userString_max_len	DWORD		LENGTHOF userString
num_prompt			BYTE		"Please enter a signed number between -2^31 and 2^31: ",0
IntegerArray		SDWORD		2000 DUP(?)
IntegerArray_len	DWORD		LENGTHOF IntegerArray  ;num elements
IntegerArray_size	DWORD		SIZEOF IntegerArray	   ;num bytes
Error_no_input		BYTE		"Error!  You didn't enter in any numbers.",0 
Error_char_num		BYTE		"Error!  You can only enter numbers, and the plus or minus sign.",0 
Error_sign_use		BYTE		"Error!  You can only enter the plus or minus sign at the beginning of the number.",0 

.code
main PROC

; (insert executable instructions here)
	
	mDisplayString OFFSET program_info_1
	mDisplayString OFFSET program_info_2
	
	PUSH    OFFSET userString_len
	PUSH	OFFSET Error_no_input
	PUSH	OFFSET Error_char_num
	PUSH	OFFSET Error_sign_use
	PUSH    userString_max_len
	PUSH	OFFSET userString
	PUSH	OFFSET num_prompt
	CALL	ReadVal


	Invoke ExitProcess,0	; exit to operating system
main ENDP


ReadVal PROC

	;***************************************************************************************************************************
	;	1) Invoke the mGetString macro to get user input in the form of a string of digits	
	;***************************************************************************************************************************

	LOCAL StringMaxLen:DWORD, StringRef:DWORD, NumsEntered:DWORD, sign:DWORD

	mov eax, [EBP + 12]
	mov StringRef, eax
	mov eax, [EBP + 16]	
	mov StringMaxLen, eax

_PromptUserInput:

	mDisplayString [EBP + 8]				    ;prompt num	
    mGetString StringRef, StringMaxLen			;pass (ref, size) to macro to get user string

	;======GET HOW MANY NUMBERS THE USER ENTERED=====================
	push [EBP + 32]				;push empty output variable by ref
	push StringRef				;local variable
	push StringMaxLen			;local variable
	CALL getStringLen			;get string len
	mov eax, [EBP + 32]	
	mov edx, [eax]
	mov NumsEntered, edx		;local variable to hold nums entered




	
	;***************************************************************************************************************************
	;	2) Convert (USING STRING PRIMITIVES) the string of ASCII digits to its numeric value representation (SDWORD).
	;   validating each char is a valid # (not symbol)                                                                
	;***************************************************************************************************************************

	
	;mov EDX, StringRef				;LOCAL VARIABLE - test delete
	;CALL WriteString				;test delete
	

	mov ECX, NumsEntered			;test if no nums entered using local variable
	cmp ECX, 0
	jz _noInputError
	mov ESI, StringRef				;if nums were entered, then start loop
	mov ECX, StringMaxLen			;test if no nums entered using local variable


;==================LOOP TO CONVERT STRING STARTS HERE=====================================================
_convertString:	
	LODSB					;takes ESI and copies to AL, then increment ESI to next element
	cmp AL, 0
	jz _Finished
	cmp AL, 48				;nums are from 48 to 57; + is 43 and - is 45
	jl	_checkifSign	
	cmp AL, 57
	jg	_NotNumError
	jmp _Convert	


_checkifSign:
	cmp AL, 43			; + sign
	jz	_TestifFirstDigitPlus
	cmp AL, 45			; - sign
	jz	_TestifFirstDigitMinus
	jmp _NotNumError

_Convert:
	;TODO


_NextLoop:
	
	loop _ConvertString
	jmp _Finished
;==================LOOP TO CONVERT STRING ENDS HERE=====================================================



;Errors and testing if + or - if first char
_NotNumError:
	
	mDisplayString [EBP + 24]				;prompt num	
	call CrLf
	call CrLF
	jmp _PromptUserInput


_noInputError:
	mDisplayString [EBP + 28]				;prompt num	
	call CrLf
	call CrLF
	jmp _PromptUserInput

_TestifFirstDigitPlus:
	cmp StringMaxLen, ECX
	jnz _signNotFirstError
	jmp _NextLoop
	mov sign, 1	

_TestifFirstDigitMinus:
	cmp StringMaxLen, ECX
	jnz _signNotFirstError
	mov sign, -1							; local variable set as negative
	jmp _NextLoop

_signNotFirstError:
	mDisplayString [EBP + 20]				;prompt num	
	call CrLf
	call CrLF
	jmp _PromptUserInput




	;***************************************************************************************************************************
	;	3) Store this one value in a memory variable (output paratmeter, by reference).                                                              
	;***************************************************************************************************************************
_Finished:
	





	RET 28		; dereference 1 passed parameter address

ReadVal ENDP



WriteVal PROC


WriteVal ENDP



getStringLen PROC
	
	LOCAL StringLen:DWORD

	mov ECX, [EBP + 8]		;max length for counter
	mov ESI, [EBP + 12]		;output ref

	mov StringLen, 0
	
_countLoop:
	LODSB	
	cmp AL, 0
	jle _end
	cmp AL, 43			; + sign
	jz _nocount
	cmp AL, 45			; - sign
	jz _nocount
	inc StringLen

_nocount:
	loop _countLoop
	
_end:
	mov EAX, StringLen		;LOCAL VARIABLE
	mov EDX, [EBP + 16] 	;move count to output variable
	mov [EDX], EAX 			;move count to output variable
	
	ret 12

getStringLen ENDP




END main
