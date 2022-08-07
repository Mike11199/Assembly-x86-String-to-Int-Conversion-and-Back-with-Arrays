TITLE Project 6 - String Primitives and Macros      (Proj6_iwanekm.asm)

;--------------------------------------------------------------------------------------------------------------------------------------------------
; Author:					Michael Iwanek
; Last Modified:			08/04/2022
; OSU email address:		iwanekm@oregonstate.edu
; Course number/section:	CS271 Section 400
; Project Number:			06
; Due Date:					08/07/2022
;--------------------------------------------------------------------------------------------------------------------------------------------------
; Description: 
;--------------------------------------------------------------------------------------------------------------------------------------------------
;			
;			-This program allows numbers to be read/written by the users without Irvine library procedures, using manual conversion of numbers to strings
;			 and vice versa.
;
;			-This program allows user to enter in a series of numbers as strings.  It then converts the string into a number using the ReadVal procedure.
;			 it accomplishes this without Irvine library procedures, by REPEATEDLY MULTIPLYING each char of the string converted to a number by 10 if necessary,
;			 building up a number digit by digit.
;
;			-After creating the number, it saves it to an array of numbers.  It then calculates the average and sum of these numbers and displays these to the user.
;
;			-Finally, it uses the WriteVal function (also used for the sum/average previously) to loop through each SDWORD integer array and convert that number
;			 back into a string manually wihtout Irvine library procedures.  It does this by REPEATEDLY DIVIDING each number by 10 to build back a string from the
;			 remainder of each division. From this, it uses string primitve instructions to reverse the string, so that it is in the correct order.
;
;			-It also makes use of two macros to get and display strings to the user.
;
;--------------------------------------------------------------------------------------------------------------------------------------------------


INCLUDE Irvine32.inc


; =======================================================================================================================================================
; Name:				mGetString
;
; Description:		-This macro makes use of the ReadString Irvine library procedure to read a number entered by a user in the console as a string. 
;					 It then updates the string by reference passed to it on the stack.  It also updates the number of characters entered by the user into an
;					 output variable passed to it by reference on the stack.
;
; Preconditions:	-none
;
; Postconditions:	-none
;
; Receives:			-The temp string output variable by reference, max size of string, and output by reference for the number of characters the user enters. 
;					 This output of characters this output of characters entered is used to test if the user entered nothing into the console or too large
;					 of a number for a 32 bit signed register.
;
; Returns:			-Returns by reference a string, and the number of characters entered by the user by reference, so that global variable are updated.
;
; =======================================================================================================================================================
mGetString	MACRO	buffer, buffer_size, output_nums_entered, message
	
	PUSH				EDX							; Save EDX register
	PUSH				ECX
	PUSH				EAX
	mDisplayString		message						; Diplay prompt for num
	MOV					EDX,  buffer				; Buffer is where output string by ref is saved to
	MOV					ECX,  [buffer_size]
	CALL				setTextColorGreen	
	CALL				ReadString
	CALL				setTextColorWhite
	MOV					ecx, output_nums_entered
	MOV					[ecx], EAX
	POP					EAX
	POP					ECX							  ; Restore EDX
	POP					EDX							  ; Restore ECX

ENDM

; =======================================================================================================================================================
; Name:				mDisplayString
;
; Description:		-This macro makes use of the WriteString Irvine library procedure to write a string to the conosle.  Used by the mGetString macro.
;
; Preconditions:	-none
;
; Postconditions:	-none
;
; Receives:			-Addresses of the string variable to be written needs to be passed as a parameter.
;
; Returns:			-nothing
;
; =======================================================================================================================================================
mDisplayString	MACRO	buffer

	PUSH				EDX							  ;Save EDX register
	MOV					EDX, buffer
	CALL				WriteString
	POP					EDX							  ;Restore EDX

ENDM

; (insert constant definitions here)

.data
program_info_1		BYTE		"Hello!  Welcome to my program:  String Primitives and Macros by Michael Iwanek",13,10,13,10,0

program_info_2		BYTE		"Please enter in 10 signed decimal integers.  This program will then display each number entered, their average value, and sum.",13,10,13,10
					BYTE		"It will do this without using any Irvine procedures to read/write numbers, but will instead convert inputted strings to numbers using an algorithm.",13,10,13,10
					BYTE		"After storing these numbers to an array, it will use another algorithm to convert these numbers back to strings to be displayed to the console.  ",13,10,13,10
					BYTE		"Each number must be able to fit within a 32 bit register, or be between the values of -2,147,483,648 and 2,147,483,647 inclusive (or -2^31 to 2^31-1).",13,10,13,10,0

userString_len		DWORD		?
temp_num			SDWORD		?
temp_num2			SDWORD		?
rounded_avg			SDWORD		?
sum_all_nums		SDWORD		?

IntegerArray_len	DWORD		0				;num elements
IntegerArray_len2	DWORD		1				;num elements
userString			BYTE		50 DUP(?)		;10 digit string, +1 for + or neg sign; +1 for null terminator
temp_string			BYTE		32 DUP(?)
temp_string2		BYTE		32 DUP(?)
IntegerArray		SDWORD		10 DUP(?)
StringArray			SDWORD		10 DUP(?)
userString_max_len	DWORD		LENGTHOF userString

num_prompt			BYTE		"Please enter a signed number between -2^31 and 2^31-1: ",0
Error_no_input		BYTE		"Error!  You didn't enter in any numbers.",0 
Error_char_num		BYTE		"Error!  You can only enter numbers, and the plus or minus sign.",0 
Error_sign_use		BYTE		"Error!  You can only enter the plus or minus sign at the beginning of the number.",0 
Error_too_large		BYTE		"Error!  Your number must be between the ranges of-2,147,483,648 and 2,147,483,647 inclusive (or -2^31 and 2^31-1).",0 
display_1			BYTE		"You entered the following numbers: ",0 
display_2			BYTE		"The sum of all numbers entered is: ",0 
display_3			BYTE		"The truncated average of all numbers entered is: ",0 
goodbye				BYTE		"Thanks for using my program!  Goodbye.",0
comma_string		BYTE		", ",0

.code
main PROC

	;THIS PROGRAM DOES NOT USE GLOBAL VARIABLES BUT PASSES VARIABLE TO PROCEDURES ON THE STACK
	;VARIABLE USED IN THE PROCEDURES ARE NOT GLOBAL; THEY ARE LOCAL VARIABLES USED FOR PROGRAM READABILITY



	;display program prompts and info to the user using the mDisplayString macro
	mDisplayString		OFFSET program_info_1
	mDisplayString		OFFSET program_info_2	
	


	MOV ECX, 10
	;loop to get 10 numbers from the user as strings, converted to an array of numbers from ASCII manually
_InputNumberLoop:

	PUSH				OFFSET temp_num2
	PUSH				OFFSET Error_too_large
	PUSH				OFFSET IntegerArray_len
	PUSH				OFFSET IntegerArray
	PUSH				OFFSET temp_num
	PUSH				OFFSET userString_len
	PUSH				OFFSET Error_no_input
	PUSH				OFFSET Error_char_num
	PUSH				OFFSET Error_sign_use
	PUSH				userString_max_len
	PUSH				OFFSET userString
	PUSH				OFFSET num_prompt
	CALL				ReadVal

LOOP _InputNumberLoop

	
	;calc sum
	PUSH				OFFSET sum_all_nums
	PUSH				OFFSET IntegerArray_len
	PUSH				OFFSET IntegerArray
	CALL				CalculateSum	

	;calc average
	PUSH				OFFSET rounded_avg
	PUSH				OFFSET sum_all_nums
	PUSH				OFFSET IntegerArray_len
	CALL				CalculateAverage	

	;display numbers entered by user
	CALL				CrLf
	mDisplayString		OFFSET display_1
	CALL				CrLf
	CALL				setTextColorGreen	
	PUSH				OFFSET comma_string
	PUSH				OFFSET temp_string2
	PUSH				OFFSET temp_string
	PUSH				OFFSET StringArray
	PUSH				OFFSET IntegerArray_len
	PUSH				OFFSET IntegerArray
	CALL				WriteVal
	CALL				setTextColorWhite		

	;display text prompt before sum is displayed
	CALL				CrLf
	CALL				CrLf
	mDisplayString		OFFSET display_2	
	CALL				setTextColorGreen	
	CALL				CrLf
	
	;display sum of numbers entered by user
	PUSH				OFFSET comma_string
	PUSH				OFFSET temp_string2
	PUSH				OFFSET temp_string
	PUSH				OFFSET StringArray
	PUSH				OFFSET IntegerArray_len2
	PUSH				OFFSET sum_all_nums
	CALL				WriteVal
	CALL				setTextColorWhite	

	;display text prompt before truncated average is displayed
	CALL				CrLf
	CALL				CrLf
	mDisplayString		OFFSET display_3	
	CALL				setTextColorGreen	
	CALL				CrLf

	;display truncated average of numbers entered by user
	PUSH				OFFSET comma_string
	PUSH				OFFSET temp_string2
	PUSH				OFFSET temp_string
	PUSH				OFFSET StringArray
	PUSH				OFFSET IntegerArray_len2
	PUSH				OFFSET rounded_avg
	CALL				WriteVal	
	

	;display the farewell message
	CALL				setTextColorWhite	
	CALL				CrLf
	CALL				CrLf
	mDisplayString		OFFSET goodbye	
	CALL				CrLf
	CALL				CrLf




	Invoke ExitProcess,0	; exit to operating system
main ENDP


; =======================================================================================================================================================
; Name:				ReadVal
;
; Description:		-This procedure invokes the mGetString macro to prompt the user to numbers as strings into the console.  It then has an inner loop that 
;					 repeatedly calls the ConvertASCIItoNum procedure based on how many characters the user entered.  After receiving on the stack the number
;					 converted from the string representation the user entered from the ConvertASCIItoNum procedure ,it repeately multiplies the number received
;					 by 10, to slowly build the actual numerical representation of the string given.  After this, it saves the numerical value into a SDWORD 
;					 array of integers.  
;
; Preconditions:	-none
;
; Postconditions:	-none
;
; Receives:			-The temp string output variable by reference, max size of string, and output by reference for the number of characters the user enters. 
;					 This output of characters this output of characters entered is used to test if the user entered nothing into the console or too large
;					 of a number for a 32 bit signed register.
;
; Returns:			-Returns by reference a string, and the number of characters entered by the user by reference, so that global variable are updated.
;
; =======================================================================================================================================================
ReadVal PROC

;*****************************************************************************************************************************************************
;	1) Invoke the mGetString macro to get user input in the form of a string of digits	
;*****************************************************************************************************************************************************

	LOCAL StringMaxLen:DWORD, StringRef:DWORD, NumsEntered:DWORD, sign:DWORD, numTemp:DWORD, returnValueAscii:SDWORD, arrayelements:DWORD, messagePrompt:DWORD
	PUSHAD

	MOV					sign, 1
	MOV					eax, [EBP + 12]
	MOV					StringRef, eax
	MOV					eax, [EBP + 16]	
	MOV					StringMaxLen, eax		


_PromptUserInput:

	MOV					edx, [EBP + 52]	
	MOV					NumsEntered, edx										   ;output variable to hold nums entered
						
	MOV					edx,[EBP + 8]
	MOV					messagePrompt, edx										   ;prompt num	

    mGetString			StringRef, StringMaxLen, NumsEntered, messagePrompt 	   ;pass string output by ref, size by value, and nums entered by ref to macro

	MOV					edx, [EBP + 52]	
	MOV					edx, [edx]
	MOV					NumsEntered, edx										   ;output variable from macro to local variable





	
;*****************************************************************************************************************************************************
;	2) Convert (USING STRING PRIMITIVES) the string of ASCII digits to its numeric value representation (SDWORD).
;   validating each char is a valid # (not symbol)                                                                
;*****************************************************************************************************************************************************


	MOV					ECX, NumsEntered				; test if no nums entered using local variable
	CMP					ECX, 0
	jz					_noInputError
	CMP					ECX, 11
	jg					_numTooLargeError
	MOV					ESI, StringRef					; if nums were entered, then start loop
	MOV					ECX, StringMaxLen				; test if no nums entered using local variable
	MOV					numTemp, 0


;==================LOOP TO CONVERT STRING STARTS HERE======================================================================================
_convertString:	
	LODSB												; takes ESI and copies to AL, then increment ESI to next element
	CMP					AL, 0
	jz					_FinishedConvertingtoNum
	CMP					AL, 48							; nums are from 48 to 57; + is 43 and - is 45
	jl					_checkifSign	
	CMP					AL, 57
	jg					_NotNumError
	jmp					_Convert	


_checkifSign:
	CMP					AL, 43							; + sign
	jz					_TestifFirstDigitPlus
	CMP					AL, 45							; - sign
	jz					_TestifFirstDigitMinus
	jmp					_NotNumError

_Convert:
	PUSH				[EBP + 36]						; temp return variable from ConvertASCIItoNum
	PUSH				EAX								; this pushes AL and garbage values
	CALL				ConvertASCIItoNum	
	
	MOV					EAX, numTemp					; tempNum to hold digits


_ConvertResume:

	MOV					ebx, 10							; Multiply the number repeatedly by 10 to build up the number digit by digit from the string
	mul					ebx								; multiply by 10 then loop
	push				eax								; save multiplied numTemp

	MOV					ebx, [EBP + 36]		
	MOV					eax, [ebx]						; return variable from ConvertASCIItoNum
	MOV					returnValueAscii, eax			; save return variable from ConvertASCIItoNum

	pop					eax								; restore multipled value to eax
	add					returnValueAscii, eax			; add to return variable

	MOV					eax, returnValueAscii			; move num so far to eax
	MOV					numTemp, EAX					; save to numTemp for next loop


_NextLoop:
	
	loop				_ConvertString
	jmp					_FinishedConvertingtoNum
;==================LOOP TO CONVERT STRING ENDS HERE========================================================================================



;Errors and testing if + or - if first char
_NotNumError:
	
	mDisplayString		[EBP + 24]				; not num string
	call				CrLf
	call				CrLF
	jmp					_PromptUserInput


_noInputError:
	mDisplayString		[EBP + 28]				; no input string
	call				CrLf
	call				CrLF
	jmp					_PromptUserInput

_TestifFirstDigitPlus:
	CMP					NumsEntered, 1
	jz					_noInputError
	CMP					StringMaxLen, ECX
	jnz					_signNotFirstError
	MOV					sign, 1	
	jmp					_NextLoop


_TestifFirstDigitMinus:
	CMP					NumsEntered, 1
	jz					_noInputError
	CMP					StringMaxLen, ECX
	jnz					_signNotFirstError
	MOV					sign, 2					; local variable set as negative
	jmp					_NextLoop

_signNotFirstError:
	mDisplayString		[EBP + 20]				; prompt num	
	call				CrLf
	call				CrLF
	jmp					_PromptUserInput




;*****************************************************************************************************************************************************
;	3) Store this one value in a memory variable (output paratmeter, by reference).                                                              
;*****************************************************************************************************************************************************

_FinishedConvertingtoNum:
	
	CMP					sign, 2
	jz					_testNegativetooLarge
	jmp					_testPositivetooLarge
	

_convertNumtoNegative:
	MOV					eax, returnValueAscii  
	neg					returnValueAscii
	MOV					eax, returnValueAscii  
	MOV					returnValueAscii, eax 
	MOV					EAX, returnValueAscii	
	jmp					_storeNumtoArray


_testNegativetooLarge:
	MOV					EAX, returnValueAscii	
	CMP					EAX, 2147483648
	ja					_numTooLargeError
	CMP					EAX, 2147483648
	jz					_storeNumtoArray	; for edge case if exactly 2,147,483,648 will convert to - automatically due to SDWORD local variable
	jmp					_convertNumtoNegative


_testPositivetooLarge:
	MOV					EAX, returnValueAscii	
	CMP					EAX, 2147483647
	ja					_numTooLargeError
	jmp					_storeNumtoArray

_numTooLargeError:
	mDisplayString		[EBP + 48]	
	call				CrLf
	call				CrLF
	mov					sign, 1
	jmp					_PromptUserInput	
	


_storeNumtoArray:

	MOV					ESI, [EBP + 40]				    ; offset of int array		
	MOV					EAX, [EBP + 44]					; offset IntegerArray length variable to track how many elements are in array
	MOV					EAX, [EAX]
	MOV					arrayelements, EAX				; local variable
	MOV					EBX, 4
	mul					EBX	
	MOV					ECX, returnValueAscii
	MOV					[ESI + EAX], ECX				; store num in int array + offset to put in the last postion of the array

	MOV					EDI, [EBP + 44]
	inc					arrayelements
	MOV					eax, arrayelements
	MOV					[EDI], eax						;store count of array elements


	POPAD
	RET 44									


ReadVal ENDP



; =======================================================================================================================================================
; Name:				ConvertASCIItoNum
;
; Description:		-This procedure invokes converts an ASCII character of a number to an actual number.  It then returns it as an output variable.
;					 It is only called by the ReadVal function.  It is separated from the ReadVal function to modularize the program.  Its parameters
;					 are passed to it on the stack by the ReadVal function to avoid using globals.
;
; Preconditions:	-none
;
; Postconditions:	-none
;
; Receives:			-The the input string of a num passed to it on the stack.  Also receives the output variable where the actual num will be returned
;					 to the ReadVal function.
;
; Returns:			-Returns
;
; =======================================================================================================================================================
ConvertASCIItoNum PROC
	
	LOCAL numText:BYTE 
	PUSHAD

	MOV EAX,			[EBP + 8]			; input variable - string number passed into the entire EAX register
	MOV EBX,			[EBP + 12]			; output variable by reference

	MOV					numText, AL			; moves the lower portion (AL) of the EAX register to be used to decide what digit to convert the ASCII to


	CMP					numText, 48
	jz					_zero
	CMP					numText, 49
	jz					_one
	CMP					numText, 50
	jz					_two
	CMP					numText, 51
	jz					_three
	CMP					numText, 52
	jz					_four
	CMP					numText, 53
	jz					_five
	CMP					numText, 54
	jz					_six
	CMP					numText, 55
	jz					_seven
	CMP					numText, 56
	jz					_eight
	CMP					numText, 57
	jz					_nine


_zero:
	MOV					EAX, 0
	jmp					_return

_one:
	MOV					EAX, 1
	jmp					_return

_two:
	MOV					EAX, 2
	jmp					_return

_three:
	MOV					EAX, 3
	jmp					_return

_four:
	MOV					EAX, 4
	jmp					_return

_five:
	MOV					EAX, 5
	jmp					_return

_six:
	MOV					EAX, 6
	jmp					_return

_seven:
	MOV					EAX, 7
	jmp					_return

_eight:
	MOV					EAX, 8
	jmp					_return

_nine:
	MOV					EAX, 9
	jmp					_return



_return:
	MOV					[EBX],EAX	; move result to output variable that was stored in EBX above.  Now ASCII num character is an actual num
	
	POPAD
	ret 8							; dereference variables so that num can be passed back to the ReadVal function

ConvertASCIItoNum ENDP


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


; =======================================================================================================================================================
; Name:				CalculateSum
;
; Description:		-This procedure calculates the sum of all integers entered by the user in the integer array passed into it by reference.
;
; Preconditions:	-none
;
; Postconditions:	-none
;
; Receives:			-Integer array length, integer array of nums entered by the user by reference, and output variable for the sum by reference.
;
; Returns:			-Returns 
;
; =======================================================================================================================================================
CalculateSum PROC
	LOCAL num:SDWORD 
	PUSHAD

	MOV					num, 0

	MOV					ECX, [EBP + 12]		; OFFSET IntegerArray_len
	MOV					ECX, [ECX]
	MOV					EDI, [EBP + 8]		; OFFSET IntegerArray

_SumLoop:	
	MOV					EAX, [EDI]
	MOV					EBX, num
	add					EAX, EBX
	MOV					num, EAX
	add					EDI, 4

	LOOP				_SumLoop

	
	MOV					EAX, [EBP + 16]		; OFFSET sum_all_nums
	MOV					EBX, num
	MOV					[EAX], EBX


	POPAD
	ret 12

CalculateSum ENDP


; =======================================================================================================================================================
; Name:				CalculateAverage
;
; Description:		-This procedure calculates the average of all integers entered by the user.
;
; Preconditions:	-none
;
; Postconditions:	-none
;
; Receives:			-Integer array length, sum of all numbers input variable by reference, and output variable for the average by reference.
;
; Returns:			-Returns 
;
; =======================================================================================================================================================
CalculateAverage PROC
	LOCAL num:SDWORD, quotient:SDWORD, remainder:SDWORD, divisor:DWORD, dividend: SDWORD ;,doubledRemainder:SDWORD, 
	PUSHAD

	MOV					num, 0
	MOV					ECX, [EBP + 8]		; OFFSET IntegerArray_len
	MOV					ECX, [ECX]
	MOV					divisor, ECX
	MOV					EAX, [EBP + 12]		; OFFSET sum_all_nums
	MOV					EAX, [EAX]
	MOV					dividend, EAX
	CDQ
	IDIV				ECX

	MOV					quotient, EAX
	MOV					remainder, EDX
;
; ***********COMMENTED OUT AS PROJECT INSTRUCTIONS CHANGED FROM ROUNDING TO TRUNCATION - REFERENCE ED DISCUSSION 1661642****************
;
;	MOV EAX, remainder
;	MOV EBX, 2
;	mul EBX
;	MOV doubledRemainder, EAX
;
;
;	CMP dividend, 0
;	jl	_testNegativeRounding
;	jmp _testPositiveRounding
;
;_testNegativeRounding:
;	CMP EAX, dividend
;	jle _roundNegativeDown
;	jmp _saveValue
;
;_testPositiveRounding:
;	CMP EAX, dividend
;	jge _roundPositiveUp
;	jmp _saveValue
;
;_roundPositiveUp:	
;	inc quotient
;	jmp _saveValue
;
;_roundNegativeDown:
;	dec quotient

_saveValue:

	MOV					EAX, [EBP + 16]		; OFFSET rounded_avg
	MOV					EBX, quotient
	MOV					[EAX], ebx	


	POPAD
	ret 12

CalculateAverage ENDP


; =======================================================================================================================================================
; Name:				WriteVal
;
; Description:		-This procedure converts a numeric SDWORD value, input parameter by reference, to a string of ASCII digits manually.  It also 
;					 invokes the mGetString macro to print the converted value to the console for the user.  It prints out commas if there are multiple values.
;
;					-It calls a procedure called "ConvertNumtoASCII", and passes parameters on the stack to it to modularize the program.  This procedure
;					 repeatedly divides the number by 10 and adds the reaminder as a string to a string array, then reverses the string.
;
; Preconditions:	-none
;
; Postconditions:	-none
;
; Receives:			-
;
; Returns:			-Returns 
;
; =======================================================================================================================================================
WriteVal PROC

	LOCAL num:SDWORD, arrayLengthNum:SDWORD, integerArrayReference:SDWORD
	PUSHAD

	MOV					ECX, [EBP + 12]					; OFFSET integer array length from stack for LOOP counter
	MOV					ECX, [ECX]
	MOV					arrayLengthNum, ECX
	MOV					ESI, [EBP + 8]					; OFFSET integer array from stack
	MOV					integerArrayReference, ESI


_convertLoop:
	MOV					EAX, [EBP + 24]					; OFFSET temp_string2 RETURN VARIABLE from stack	
	PUSH				EAX								; push temp_string for ConvertNumtoASCII proc

	MOV					EAX, [EBP + 20]					; OFFSET temp_string RETURN VARIABLE from stack	
	PUSH				EAX								; push temp_string for ConvertNumtoASCII proc

	MOV					EBX, [ESI]						; save value in EBX
	PUSH				EBX								; push int from integer array by value for ConvertNumtoASCII proc

	CALL				ConvertNumtoASCII				; parameter order: return string, int by val

	MOV					EAX, [EBP + 24]					; access return value from stack that ConvertNumtoASCII used with temp string
	
	MOV					num, EAX
	mDisplayString		num

	CMP					ECX, 1
	jz					_noComma

_writeComma:	
	MOV					EAX, [EBP + 28]					;comma string
	mDisplayString		EAX

_noComma:
	add					ESI, 4							; increment int array
	LOOP				_convertLoop
	
	
	POPAD
	ret 24



WriteVal ENDP


; =======================================================================================================================================================
;			*****THIS PROCEDURE IS NOT USED.  THIS WAS BEFORE I REALIZED THAT THE READSTRING IRVINE PROC CAN COUNT THE CHARACTERS ENTERED*******
;
; Name:				getStringLen
;
; Description:		-This procedure converts a numeric SDWORD value, input parameter by reference, to a string of ASCII digits manually.  It also 
;					 invokes the mGetString macro to print the converted value to the console for the user.  It prints out commas if there are multiple values.
;
; Preconditions:	-none
;
; Postconditions:	-none
;
; Receives:			-
;
; Returns:			-Returns 
;
; =======================================================================================================================================================
getStringLen PROC
	
	LOCAL StringLen:DWORD
	PUSHAD

	MOV					ECX, 30				; max length for counter
	MOV					ESI, [EBP + 12]		; output ref

	MOV					StringLen, 0
	
_countLoop:
	LODSB	
	CMP					AL, 0
	jle					_end
	CMP					AL, 43				; + sign
	jz					_nocount
	CMP					AL, 45				; - sign
	jz					_nocount
	inc					StringLen

_nocount:
	loop				_countLoop
	
_end:	
	MOV					EAX, StringLen		; LOCAL VARIABLE
	MOV					EDX, [EBP + 16] 	; move count to output variable
	MOV					[EDX], EAX 			; move count to output variable
	
	POPAD
	ret 12

getStringLen ENDP


; =======================================================================================================================================================
; Name:	setTextColorWhite
; Procedure to change console text to white.  Preserves all general-purpose registers.
; Preconditions: none
; Postconditions: none
; Receives: none
; Returns:  none
; =======================================================================================================================================================
setTextColorWhite PROC
	pushad
	MOV					eax, white 
	call				SetTextColor
	popad
	ret
setTextColorWhite ENDP


; =======================================================================================================================================================
; Name:	setTextColorGreen
; Procedure to change console text to green. Preserves all general-purpose registers.
; Preconditions: none
; Postconditions: none
; Receives: none
; Returns:  none
; =======================================================================================================================================================
setTextColorGreen PROC	
	pushad
	MOV					eax, green 
	call				SetTextColor
	popad
	ret
setTextColorGreen ENDP

END main