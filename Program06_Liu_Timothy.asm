TITLE Low-level I/O Procedures     (Program06_Liu_Timothy.asm)

; Author: Timothy Liu
; Last Modified: December 2, 2018
; Description: This program implements ReadVal and WriteVal procedures
;   for unsigned integers and uses getString and displayString macros.
;	A test program will prompt the user for 10 values, validate the inputs,
;	display all valid inputs, calculate and display the sum, and calculate
;	and display the average.

; Implementation notes: All procedure parameters are passed on system stack.
;	Also, assumes sum of numbers fits in 32 bits. 

INCLUDE Irvine32.inc

; Description: Macro to get a string from the user
; Receives: Address of prompt and address of string variable
; Returns: String variable with user's input and user's input length
; Preconditions: none
; Registers changed: none

getString MACRO prompt, input, strLen
; Save registers
	push	eax
	push	ebx
	push	ecx
	push	edx
	mov		edx, prompt
	call	WriteString		; Prompt user for input
	mov		edx, input		; Get input location
	mov		ecx, SIZE_CATCH
	dec		ecx				
	call	ReadString		; Get input from user
	mov		ebx, strLen		; Access stringLength variable
	mov		[ebx], eax		; Store length of user input

; Restore registers
	pop		edx
	pop		ecx
	pop		ebx
	pop		eax
ENDM

; Description: Macro to display a string
; Receives: @ string to be displayed
; Returns: none
; Preconditions: none
; Registers changed: none

displayString MACRO str
	push	edx
	mov		edx, str
	call	WriteString
	pop		edx
ENDM

NUM_VALUES = 10		; Size of array
STRING_SIZE = 11	; Allows up to 10 digits, leaving space for null terminator
SIZE_CATCH = 99		; Captures user input greater than 10 digits so it can be discarded and not processed

.data
intro_1			BYTE	"Low-level I/O Procedures by Timothy Liu", 0dh, 0ah, 0dh, 0ah, 0
intro_2			BYTE	"Please provide 10 unsigned decimal integers.", 0dh, 0ah, 0
intro_3			BYTE	"Each number needs to be small enough to fit inside "
				BYTE	"a 32-bit register.", 0dh, 0ah, "After you have "
				BYTE	"finished inputting the numbers I will display a list "
				BYTE	"of the integers, the sum, and the average.", 0dh, 0ah, 0dh, 0ah, 0
promptText		BYTE	"Please enter an unsigned number: ", 0
userString		BYTE	SIZE_CATCH DUP(0)											; Holds input as a string (up to 10 digits)
stringLength	DWORD	?															; Holds length of user input
tempVar			BYTE	0															; Helps with conversion from char to numeric value
tempDword		DWORD	0															; Helps with conversion from numeric to char
userVal			DWORD	?															; Holds input as a numeric value
invalidFlag		DWORD	?															; 0 if input is only numbers, 1 otherwise
array			DWORD	NUM_VALUES DUP(?)											; Stores valid user inputs
errorText		BYTE	"ERROR: You did not enter an unsigned number or your "
				BYTE	"number was too big.", 0dh, 0ah, 0
tempString		BYTE	STRING_SIZE DUP(0)											; Holds string converted from numeric value to be displayed
arrayText		BYTE	"You entered the following valid numbers:", 0dh, 0ah, 0
comma			BYTE	", ", 0
sumText			BYTE	"The sum of these numbers is: ", 0						
avgText			BYTE	"The average is: ", 0
farewellText	Byte	"Thanks for playing!", 0

.code
main PROC
; Introduce the program and programmer
	push	OFFSET intro_1				; Pass intro text by reference
	push	OFFSET intro_2
	push	OFFSET intro_3
	call	Introduction

; Prompt user for inputs to fill array
	push	OFFSET errorText			; Pass error message text
	push	OFFSET array				; Pass address of array
	push	OFFSET promptText			; Pass prompt to user
	push	OFFSET userString			; Pass user's input
	push	OFFSET stringLength			; Pass length of user's input
	push	OFFSET tempVar				; Pass temporary variable used for converting from char to numeric
	push	OFFSET userVal				; Holds user's numeric value converted from string input
	push	OFFSET invalidFlag			; Holds status of user input and string conversion
	call	FillArray

; Display integers stored in array
	push	OFFSET arrayText			; Pass text introducing array of ints
	push	OFFSET comma				; Pass comma used to display ints
	push	OFFSET array				; Pass address of array
	push	OFFSET tempString			; Pass temporary string used for converting from numeric to char
	push	OFFSET tempDword			; Pass temporary DWORD variable to help with conversion
	push	OFFSET userString			; Pass user input
	call	ShowArray

; Calculate and display sum and average
	push	OFFSET avgText				; Pass text introducing the average
	push	OFFSET sumText				; Pass text introducing the sum
	push	OFFSET array				; Pass address of array
	push	OFFSET tempString			; Pass temporary string used for converting from numeric to char
	push	OFFSET tempDword			; Pass temporary DWORD variable to help with conversion
	push	OFFSET userString			; Pass user input
	call	ShowSumAvg

; Say farewell
	push	OFFSET farewellText			; Pass farewell text
	call	Farewell

	exit	; exit to operating system
main ENDP

; Description: Procedure to introduce the program and programmer
; Receives: addresses of intro text
; Returns: none
; Preconditions: none
; Registers changed: none

Introduction	PROC
; Set up stack frame
	push	ebp
	mov		ebp, esp
	
; Display program's title and programmer's name
	displayString	[ebp+16]

; Display program instructions
	displayString	[ebp+12]

; Display program description
	displayString	[ebp+8]

; Reset stack frame
	pop		ebp
	ret		12
Introduction	ENDP

; Description: Procedure to get a value from the user
; Receives: @ prompt, @ userString variable, @ string length, @ tempVar, @ userVal variable, @ invalidFlag
; Returns: userVal with the user's string converted to numeric value and invalidFlag with status of result
; Preconditions: none
; Registers changed: none

ReadVal		PROC
; Set up stack frame
	pushad
	push		ebp
	mov			ebp, esp

; Get string from user
	getString	[ebp+60], [ebp+56], [ebp+52]

; Check if user input was more than 10 digits
	mov			ebx, [ebp+40]			; Access status flag
	mov			eax, [ebp+52]			; Access stringLength variable
	mov			edx, STRING_SIZE
	cmp			[eax], edx
	jge			notNum

; Set up conversion from char to int
	mov			ecx, [eax]				; Set up counter						
	mov			esi, [ebp+56]			; Store input
	mov			edi, [ebp+56]			; Store output
	cld									; Read string in forward direction
counter:
	lodsb								; Load first digit
	cmp			al, 48					; Check lower range of value
	jl			notNum				
	cmp			al, 57					; Check upper range of value
	jg			notNum
	sub			al, 48					; Convert to int value
	stosb								; Store converted digit
	loop		counter

; Set up conversion to numeric value
	push		[ebp+56]				; Pass user input by reference
	mov			edx, [ebp+52]			; Access length of input
	push		[edx]					; Pass length of input
	push		[ebp+48]				; Pass tempVar value by reference
	push		[ebp+44]				; Pass variable to hold user's numeric value by reference
	push		ebx						; Pass status flag by reference
	call		charToNum
	mov			eax, 1
	cmp			[ebx], eax				; Check if conversion procedure failed due to invalid input
	je			invalidInput
	jmp			validInput

notNum:
	mov			eax, 1
	mov			[ebx], eax				; Set status flag to 1 to indicate invalid input
	jmp			invalidInput

validInput:
	mov			eax, 0
	mov			[ebx], eax				; Set status flag to 0 to indicate valid input

invalidInput:
; Reset stack frame
	pop			ebp
	popad
	ret			24
ReadVal		ENDP

; Description: Sub-procedure to convert user's string to numeric value
; Receives: @ userString variable, string length, @ tempVar, @ userVal variable, @ invalidFlag
; Returns: userVal with the user's string converted to numeric value and invalidFlag with status of result
; Preconditions: none
; Registers changed: none

charToNum	PROC
; Set up stack frame
	pushad
	push	ebp
	mov		ebp, esp

; Set up conversion
	mov		ecx, [ebp+52]			; Set up counter
	mov		esi, [ebp+56]			; Start of string
	mov		edx, 0
	mov		edi, [ebp+48]			; Access tempVar
	mov		ebx, 0					; Set up initial value
counter:
	lodsb
	mov		[edi], al				; Store each byte in tempVar
	mov		eax, 10					; Set up multiplicand
	mul		ebx						; Perform multiplication
	cmp		edx, 0					; Check if number exceeds 32-bit register
	jne		bigNum
	mov		ebx, eax
	add		ebx, DWORD PTR [edi]	; Add value of next byte
	jc		bigNum					; Check if addition exceeds 32-bit register
	loop	counter
; Store final value in userVal variable
	mov		eax, [ebp+44]
	mov		[eax], ebx

; Set status of invalidFlag to 0 to indicate valid input
	mov		ebx, [ebp+40]
	mov		eax, 0
	mov		[ebx], eax
	jmp		noCarry

; Set status of invalidFlag to 1 to indicate invalid input
bigNum:
	mov		ebx, [ebp+40]
	mov		eax, 1
	mov		[ebx], eax

noCarry:
; Reset stack frame
	pop		ebp
	popad
	ret		20
charToNum	ENDP

; Description: Procedure to display a value
; Receives: value to be displayed, @ string
; Returns: none
; Preconditions: none
; Registers changed: none

WriteVal	PROC
; Set up stack frame
	pushad
	push			ebp
	mov				ebp, esp

; Set up storage location of string
	mov				edi, [ebp+48]			; Access storage location of initial string to be generated

; Convert numeric value
	mov				ecx, 0					; Track number of digits
	mov				ebx, [ebp+52]			; Access value to be converted
loopString:
	mov				edx, 0
	mov				eax, ebx				; Set up dividend
	mov				ebx, 10					; Set up divisor
	div				ebx						; Perform division
	mov				ebx, eax				; Save new quotient
	mov				esi, [ebp+44]			; Access temp variable
	add				edx, 48					; Convert remainder to ASCII val
	mov				[esi], edx				; Save remainder in temp variable
	mov				al, BYTE PTR [esi]		; Prepare to store byte
	stosb									; Store converted byte
	inc				ecx						; Track number of digits
	cmp				ebx, 0					; Check if converted all digits
	je				endString
	jmp				loopString

endString:
	push			ecx
; Clear userString
	mov				edi, [ebp+40]
	mov				ecx, STRING_SIZE
	mov				al, 0
	cld
	rep				stosb
	pop				ecx
; Reverse string
	mov				esi, [ebp+48]			; Access generated string
	add				esi, ecx				; Move pointer to 1 byte past end of string
	dec				esi						; Access last byte of string
	mov				edi, [ebp+40]			; Access userString var to store final result
reverse:
	std										; Load string backwards
	lodsb
	cld										; Store string forwards
	stosb							
	loop			reverse

; Display the final converted string
	displayString	[ebp+40]				; Pass final string by reference to macro

; Reset stack frame
	pop				ebp
	popad
	ret				16
WriteVal	ENDP

; Description: Procedure to fill an array
; Receives: @ array, @ prompt, @ userString, @ string length, @ tempVar, @ userVal, @ invalidFlag
; Returns: array filled with 10 valid unsigned integers
; Preconditions: none
; Registers changed: none

FillArray	PROC
; Set up stack frame
	pushad
	push			ebp
	mov				ebp, esp
	mov				edi, [ebp+64]		; Access start of array
	cld									; Read array in forwards direction
	mov				ecx, NUM_VALUES		; Set up loop counter
filling:
	push			[ebp+60]			; Pass promptText by reference
	push			[ebp+56]			; Pass userString variable by reference
	push			[ebp+52]			; Pass string length
	push			[ebp+48]			; Pass tempVar
	push			[ebp+44]			; Pass userVal
	push			[ebp+40]			; Pass invalidFlag
	call			ReadVal
	mov				eax, 0
	mov				ebx, [ebp+40]
	cmp				[ebx], eax			; Check if ReadVal received invalid input
	jne				badInput
	mov				ebx, [ebp+44]		; Get address of user's numeric value
	mov				eax, 0				; Clear register
	mov				eax, [ebx]			; Get user's numeric value
	stosd								; Store in array
	jmp				nextVal
badInput:
	inc				ecx					; Make up for decrementing on bad input
	displayString	[ebp+68]			; Display error text if bad input
nextVal:
	loop			filling

; Reset stack frame
	pop				ebp
	popad
	ret				32
FillArray	ENDP

; Description: Procedure to show contents of array
; Receives: @ array text, @ array, @ tempString, @tempDword, @userString
; Returns: none
; Preconditions: none
; Registers changed: none

ShowArray	PROC
; Set up stack frame
	pushad
	push			ebp
	mov				ebp, esp

; Set up WriteVal
	call			Crlf
	displayString	[ebp+60]
	mov				esi, [ebp+52]		; Access array
	cld									; Read array in forward direction
	mov				ecx, NUM_VALUES		; Set up loop counter
show:
	lodsd
	push			eax
	push			[ebp+48]
	push			[ebp+44]
	push			[ebp+40]
	call			WriteVal
	cmp				ecx, 1				; Check if reached last number
	je				noComma
	displayString	[ebp+56]
noComma:
	loop			show

; Reset stack frame
	pop				ebp
	popad
	ret				24
ShowArray	ENDP

; Description: Procedure to calculate and display the sum of array contents
; Receives: @ avtText, @ sumText, @ array, and parameters for WriteVal
; Returns: none
; Preconditions: none
; Registers changed: none

ShowSumAvg	PROC
; Set up stack frame
	pushad
	push			ebp
	mov				ebp, esp
	call			Crlf
	displayString	[ebp+56]			; Display text for sum
	mov				esi, [ebp+52]		; Access array
	cld									; Read array in forward direction
	mov				ebx, 0				; Set up accumulator
	mov				ecx, NUM_VALUES		; Set up loop counter
sum:
	lodsd								; Get next array element
	add				ebx, eax			; Add array element
	loop			sum

; Set up WriteVal to display sum
	push			ebx					; Push sum to be displayed
	push			[ebp+40]			; Push tempString
	push			[ebp+44]			; Push tempDword
	push			[ebp+48]			; Push userString
	call			WriteVal

; Find average
	call			Crlf
	displayString	[ebp+60]			; Display text for average
	mov				eax, ebx			; Set up dividend
	mov				edx, 0		
	mov				ebx, NUM_VALUES		; Set up divisor
	div				ebx					; Perform division

; Set up WriteVal to display average
	push			eax					; Push average to be displayed
	push			[ebp+40]			; Push tempString
	push			[ebp+44]			; Push tempDword
	push			[ebp+48]			; Push userString
	call			WriteVal

; Reset stack frame
	pop				ebp
	popad
	ret				24
ShowSumAvg	ENDP

; Description: Procedure to say farewell to user
; Receives: @ farewellText
; Returns: none
; Preconditions: none
; Registers changed: none

Farewell	PROC
; Set up stack frame
	push			ebp
	mov				ebp, esp
	call			Crlf
	call			Crlf
	displayString	[ebp+8]		; Display farewell text
	call			Crlf

; Reset stack frame
	pop				ebp
	ret				4
Farewell	ENDP

END main
