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
userString			BYTE		50 DUP(?)			;10 digit string, +1 for + or neg sign; +1 for null terminator
userString_len		DWORD		?
temp_num			SDWORD		?
temp_string			BYTE		32 DUP(?)
temp_string2		BYTE		32 DUP(?)
userString_max_len	DWORD		LENGTHOF userString
num_prompt			BYTE		"Please enter a signed number between -2^31 and 2^31: ",0
IntegerArray		SDWORD		10 DUP(?)
IntegerArray_len	DWORD		0 ;num elements
IntegerArray_size	DWORD		SIZEOF IntegerArray	   ;num bytes
StringArray			SDWORD		10 DUP(?)
Error_no_input		BYTE		"Error!  You didn't enter in any numbers.",0 
Error_char_num		BYTE		"Error!  You can only enter numbers, and the plus or minus sign.",0 
Error_sign_use		BYTE		"Error!  You can only enter the plus or minus sign at the beginning of the number.",0 
Error_too_large		BYTE		"Error!  Your number must be between the ranges of-2,147,483,647 and 2,147,483,647 inclusive (or +/- 2^31).",0 
display_1			BYTE		"You entered the following numbers: ",0 
display_2			BYTE		"The sum offset these numbers is: ",0 
display_3			BYTE		"The rounded average is: ",0 
rounded_avg			SDWORD		?
sum_all_nums		SDWORD		?


.code
main PROC

; (insert executable instructions here)
	
	mDisplayString OFFSET program_info_1
	mDisplayString OFFSET program_info_2	
	
	mov ECX, 10

_InputNumberLoop:

	PUSH	OFFSET Error_too_large
	PUSH    OFFSET IntegerArray_len
	PUSH    OFFSET IntegerArray
	PUSH    OFFSET temp_num
	PUSH    OFFSET userString_len
	PUSH	OFFSET Error_no_input
	PUSH	OFFSET Error_char_num
	PUSH	OFFSET Error_sign_use
	PUSH    userString_max_len
	PUSH	OFFSET userString
	PUSH	OFFSET num_prompt
	CALL	ReadVal

LOOP _InputNumberLoop

	PUSH    OFFSET sum_all_nums
	PUSH    OFFSET IntegerArray_len
	PUSH    OFFSET IntegerArray
	CALL CalculateSum	

	PUSH    OFFSET rounded_avg
	PUSH    OFFSET sum_all_nums
	PUSH    OFFSET IntegerArray_len
	CALL CalculateAverage	


	mDisplayString OFFSET display_1
	PUSH    OFFSET temp_string2
	PUSH    OFFSET temp_string
	PUSH    OFFSET StringArray
	PUSH    OFFSET IntegerArray_len
	PUSH    OFFSET IntegerArray
	CALL WriteVal

	mDisplayString OFFSET display_2	


	mDisplayString OFFSET display_3	
	PUSH    OFFSET rounded_avg
	PUSH	OFFSET	temp_num
	CALL DisplayAverage	



	Invoke ExitProcess,0	; exit to operating system
main ENDP


ReadVal PROC

	;***************************************************************************************************************************
	;	1) Invoke the mGetString macro to get user input in the form of a string of digits	
	;***************************************************************************************************************************

	LOCAL StringMaxLen:DWORD, StringRef:DWORD, NumsEntered:DWORD, sign:DWORD, numTemp:DWORD, returnValueAscii:DWORD, arrayelements:DWORD
	PUSHAD

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
	cmp ECX, 10
	jg _numTooLargError
	mov ESI, StringRef				;if nums were entered, then start loop
	mov ECX, StringMaxLen			;test if no nums entered using local variable
	mov numTemp, 0


;==================LOOP TO CONVERT STRING STARTS HERE=====================================================
_convertString:	
	LODSB					;takes ESI and copies to AL, then increment ESI to next element
	cmp AL, 0
	jz _FinishedConvertingtoNum
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
	PUSH [EBP + 36]			 ;temp return variable from ConvertASCIItoNum
	PUSH EAX				; this pushes AL and garbage values
	CALL ConvertASCIItoNum	
	
	mov EAX, numTemp			; tempNum to hold digits

	cmp EAX, 214748364
	jg  _numTooLargError


	mov ebx, 10
	mul ebx						; multiply by 10 then loop
	push eax					; save multiplied numTemp

	mov ebx, [EBP + 36]		
	mov eax, [ebx]				; return variable from ConvertASCIItoNum
	mov returnValueAscii, eax	; save return variable from ConvertASCIItoNum

	pop eax						; restore multipled value to eax
	add returnValueAscii, eax	; add to return variable
	mov	eax, returnValueAscii	; move num so far to eax
	mov numTemp, EAX			; save to numTemp for next loop

_NextLoop:
	
	loop _ConvertString
	jmp _FinishedConvertingtoNum
;==================LOOP TO CONVERT STRING ENDS HERE=====================================================



;Errors and testing if + or - if first char
_NotNumError:
	
	mDisplayString [EBP + 24]				;not num string
	call CrLf
	call CrLF
	jmp _PromptUserInput


_noInputError:
	mDisplayString [EBP + 28]				;no input string
	call CrLf
	call CrLF
	jmp _PromptUserInput

_TestifFirstDigitPlus:
	cmp StringMaxLen, ECX
	jnz _signNotFirstError
	mov sign, 1	
	jmp _NextLoop


_TestifFirstDigitMinus:
	cmp StringMaxLen, ECX
	jnz _signNotFirstError
	mov sign, 2							; local variable set as negative
	jmp _NextLoop

_signNotFirstError:
	mDisplayString [EBP + 20]				;prompt num	
	call CrLf
	call CrLF
	jmp _PromptUserInput




	;***************************************************************************************************************************
	;	3) Store this one value in a memory variable (output paratmeter, by reference).                                                              
	;***************************************************************************************************************************

_FinishedConvertingtoNum:
	
	cmp sign, 2
	jz _convertNumtoNegative
	jmp _testIfNumtooLarge
	

_convertNumtoNegative:
	mov eax, returnValueAscii  
	neg eax
	mov returnValueAscii, eax 


_testIfNumtooLarge:
	mov EAX, returnValueAscii	
	cmp EAX, 2147483647
	jg	_numTooLargError
	cmp EAX, -2147483647
	jl	_numTooLargError
	jmp _storeNumtoArray

_numTooLargError:
	mDisplayString [EBP + 48]	
	call CrLf
	call CrLF
	jmp _PromptUserInput	
	


_storeNumtoArray:


	mov eax, returnValueAscii				; test delete
	add eax, 5								; test delete to add num
	call writeint							; test to show added num

	mov     ESI, [EBP + 40]				    ; offset of int array		
	MOV		EAX, [EBP + 44]					; offset IntegerArray length variable to track how many elements are in array
	mov		EAX, [EAX]
	mov		arrayelements, EAX				; local variable
	mov		EBX, 4
	mul		EBX	
	mov		ECX, returnValueAscii
	mov		[ESI + EAX], ECX		; store num in int array + offset to put in the last postion of the array

	mov		EDI, [EBP + 44]
	inc		arrayelements
	mov		eax, arrayelements
	MOV	    [EDI], eax				;store count of array elements


	POPAD
	RET 44					; dereference passed parameters


ReadVal ENDP


getStringLen PROC
	
	LOCAL StringLen:DWORD
	PUSHAD

	mov ECX, 30				;max length for counter
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
	
	POPAD
	ret 12

getStringLen ENDP



ConvertASCIItoNum PROC
	
	LOCAL numText:BYTE 
	PUSHAD

	mov EAX, [EBP + 8]		;whole EAX register
	mov EBX, [EBP + 12]		;output variable

	mov numText, AL		;technically comparing AL here


	cmp numText, 48
	jz _zero
	cmp numText, 49
	jz _one
	cmp numText, 50
	jz _two
	cmp numText, 51
	jz _three
	cmp numText, 52
	jz _four
	cmp numText, 53
	jz _five
	cmp numText, 54
	jz _six
	cmp numText, 55
	jz _seven
	cmp numText, 56
	jz _eight
	cmp numText, 57
	jz _nine


_zero:
	mov EAX, 0
	jmp _return

_one:
	mov EAX, 1
	jmp _return

_two:
	mov EAX, 2
	jmp _return

_three:
	mov EAX, 3
	jmp _return

_four:
	mov EAX, 4
	jmp _return

_five:
	mov EAX, 5
	jmp _return

_six:
	mov EAX, 6
	jmp _return

_seven:
	mov EAX, 7
	jmp _return

_eight:
	mov EAX, 8
	jmp _return

_nine:
	mov EAX, 9
	jmp _return



_return:
	mov [EBX],EAX	;move result to output variable
	
	POPAD
	ret 8

ConvertASCIItoNum ENDP


ConvertNumtoASCII PROC
	
	 ; parameter order:  temp string, integer value, tempstring2

	LOCAL num:DWORD, quotient:DWORD, remainder:DWORD, newStringLen:DWORD
	PUSHAD

	mov ecx, 32
	mov EDI, [EBP + 16]		; temp string2 offset from stack

_ClearString_one:
	mov EAX, 0
	mov [EDI], EAX
	add EDI, 1
	loop _ClearString_one


	
	mov ecx, 32
	mov EDI, [EBP + 16]		; temp string offset from stack

_ClearString_two:
	mov EAX, 0
	mov [EDI], EAX
	add EDI, 1
	loop _ClearString_two





	mov EDI, [EBP + 12]		; temp string offset from stack
	mov EAX, [EBP + 8]		; integer from stack

	mov	num, EAX
	mov newStringLen, 0


_MainConversionLoop:
	;need to repeatedly divide by 10, multiply by zeros until no remainder left, then reverse string array created.

	mov EAX, num
	CDQ 
	mov ebx, 10
	IDIV ebx
	mov quotient, EAX
	mov remainder, EDX

	cmp remainder, 0
	jg _remainderExists
	cmp quotient, 0
	jg _Quotient						; if no quotient and remainder
	jmp _AddTERMINATOR


_Quotient:
	mov EAX, 0
	mov num, EAX
	jmp _startNumConversion

_remainderExists:
	mov EAX, remainder
	mov num, EAX
	jmp _startNumConversion


_startNumConversion:
	cmp num, 0
	jz _zero_num
	cmp num, 1
	jz _one_num
	cmp num, 2
	jz _two_num
	cmp num, 3
	jz _three_num
	cmp num, 4
	jz _four_num
	cmp num, 5
	jz _five_num
	cmp num, 6
	jz _six_num
	cmp num, 7
	jz _seven_num
	cmp num, 8
	jz _eight_num
	cmp num, 9
	jz _nine_num


_zero_num:
	mov AL, 48 
	jmp add_num_to_string

_one_num:
	mov AL, 49 
	jmp add_num_to_string

_two_num:
	mov AL, 50 
	jmp add_num_to_string

_three_num:
	mov AL, 51 
	jmp add_num_to_string

_four_num:
	mov AL, 52
	jmp add_num_to_string

_five_num:
	mov AL, 53 
	jmp add_num_to_string

_six_num:
	mov AL, 54 
	jmp add_num_to_string

_seven_num:
	mov AL, 55 
	jmp add_num_to_string

_eight_num:
	mov AL, 56
	jmp add_num_to_string

_nine_num:
	mov AL, 57 
	jmp add_num_to_string



add_num_to_string:
	mov [EDI], AL	;move result to output variable
	add EDI, 1		;increment
	mov EAX, quotient
	mov num, EAX
	inc newStringLen
	jmp _MainConversionLoop


_AddTERMINATOR:
	mov	AL, 0
	mov [EDI], AL	;move result to output variable
	inc newStringLen


_FinishConvertingNumtoString:

	;NEED TO REVERSE STRING AFTERWARDS
	mov ECX, newStringLen
	mov ESI, [EBP + 12]		; temp string offset from stack
	add ESI, ECX			; so source strings starts from end
	dec ESI
	dec ESI
	mov EDI, [EBP + 16]		; temp string offset2 from stack
	
_revLoop: ;reference StringManipulator.asm from canvas
	STD
	LODSB
	CLD
	STOSB
	LOOP _revLoop



	POPAD
	ret 8

ConvertNumtoASCII ENDP






	;PUSH    OFFSET sum_all_nums
	;PUSH    OFFSET IntegerArray_len
	;PUSH    OFFSET IntegerArray

CalculateSum PROC
	LOCAL num:SDWORD 
	PUSHAD

	mov num, 0

	mov ECX, [EBP + 12]		; OFFSET IntegerArray_len
	mov ECX, [ECX]
	mov EDI, [EBP + 8]		; OFFSET IntegerArray

_SumLoop:	
	mov EAX, [EDI]
	mov EBX, num
	add EAX, EBX
	mov num, EAX
	add EDI, 4

	LOOP _SumLoop

	
	mov EAX, [EBP + 16]		; OFFSET sum_all_nums
	mov EBX, num
	mov [EAX], EBX


	POPAD
	ret 12

CalculateSum ENDP


	;PUSH    OFFSET rounded_avg
	;PUSH    OFFSET sum_all_nums
	;PUSH    OFFSET IntegerArray_len

CalculateAverage PROC
	LOCAL num:SDWORD, quotient:SDWORD, remainder:SDWORD, doubledRemainder:SDWORD
	PUSHAD

	mov num, 0
	mov ECX, [EBP + 8]		; OFFSET IntegerArray_len
	mov ECX, [ECX]
	mov EAX, [EBP + 12]		; OFFSET sum_all_nums
	mov EAX, [EAX]
	CDQ
	IDIV ECX

	mov quotient, EAX
	mov remainder, EDX
	
	mov EAX, remainder
	mov EBX, 2
	mul EBX
	mov doubledRemainder, EAX

	;test delete start
	;mov EAX, quotient
	;CALL WriteInt
	;mov EAX, remainder
	;CALL WriteInt
	;mov EAX, doubledRemainder
	;CALL WriteInt
	;test delete end

	cmp EAX, 0
	jl	_testNegativeRounding
	jmp _testPositiveRounding

_testNegativeRounding:
	cmp EAX, quotient
	jle _roundNegativeDown
	jmp _saveValue

_testPositiveRounding:
	cmp EAX, quotient
	jge _roundPositiveUp
	jmp _saveValue

_roundPositiveUp:	
	inc quotient
	jmp _saveValue

_roundNegativeDown:
	dec quotient

_saveValue:

	mov EAX, [EBP + 16]		; OFFSET rounded_avg
	mov EBX, quotient
	mov [EAX], ebx	



	;test delete start
	;mov EAX, [EBP + 16]		; OFFSET rounded_avg
	;mov EAX, [EAX]
	;CALL WriteInt
	;test delete end


	POPAD
	ret 12

CalculateAverage ENDP




	;PUSH   OFFSET rounded_avg
	;PUSH	OFFSET	temp_num


DisplayAverage PROC
	LOCAL num:SDWORD, numString:DWORD
	PUSHAD

	mov EBX, [EBP + 8]		; OFFSET temp_num
	mov EBX, [EBX]
	mov EAX, [EBP + 12]		; OFFSET rounded_avg
	mov EAX, [EAX]

	PUSH EAX  ;average input num 
	PUSH EBX  ;temp string
	CALL ConvertNumtoASCII

	mDisplayString numString

	POPAD
	ret 8

DisplayAverage ENDP


	;PUSH    OFFSET temp_string2
	;PUSH    OFFSET temp_string
	;PUSH    OFFSET StringArray
	;PUSH    OFFSET IntegerArray_len
	;PUSH    OFFSET IntegerArray


WriteVal PROC

	LOCAL num:SDWORD, numStringOffset:DWORD
	PUSHAD

	mov ECX, [EBP + 12]		; OFFSET integer array length from stack for LOOP counter
	mov ESI, [EBP + 8]		; OFFSET integer array from stack
	;mov EDI, [EBP + 16]		; OFFSET string array from stack

_convertLoop:

	mov EAX, [EBP + 24]		; OFFSET temp_string2 RETURN VARIABLE from stack	
	PUSH EAX				; push temp_string for ConvertNumtoASCII proc

	mov EAX, [EBP + 20]		; OFFSET temp_string RETURN VARIABLE from stack	
	PUSH EAX				; push temp_string for ConvertNumtoASCII proc

	mov EBX, [ESI]			; save value in EBX
	PUSH EBX				; push int from integer array by value for ConvertNumtoASCII proc

	CALL ConvertNumtoASCII  ; parameter order: return string, int by val

	mov EAX, [EBP + 24]		; access return value from stack that ConvertNumtoASCII used with temp string
	
	mDisplayString EAX

	add ESI, 4				; increment int array

	LOOP _convertLoop
	
	
	
	POPAD
	ret 12



WriteVal ENDP








END main
