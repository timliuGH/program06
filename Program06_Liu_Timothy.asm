TITLE Low-level I/O Procedures     (Program06_Liu_Timothy.asm)

; Author: Timothy Liu
; Last Modified: November 27, 2018
; OSU email address: liutim@oregonstate.edu
; Course number/section: CS_271_400_F2018
; Project Number: 06               Due Date: December 2, 2018
; Description: This program implements ReadVal and WriteVal procedures
;   for unsigned integers and uses getString and displayString macros.
;	The program will prompt the user for a value, validate the input,
;	display all valid inputs, calculate and display the sum, and calculate
;	and display the average.

; Implementation notes: All procedure parameters are passed on system stack.
;	Also, assumes sum of numbers fits in 32 bits. 

INCLUDE Irvine32.inc

; Description: Macro to get a string from the user
; Receives: 
; Returns: 
; Preconditions: 
; Registers changed: 
getString MACRO prompt, input
	mov		edx, prompt
	call	WriteString
	mov		edx, input
	mov		ecx, STRING_SIZE
	call	ReadString
ENDM

; Description: Macro to display a string
; Receives: 
; Returns: 
; Preconditions: 
; Registers changed: 
displayString MACRO
ENDM

NUM_VALUES = 10
STRING_SIZE = 11

.data
intro_1			BYTE	"Low-level I/O Procedures by Timothy Liu", 0dh, 0ah, 0dh, 0ah, 0
intro_2			BYTE	"Please provide 10 unsigned decimal integers.", 0dh, 0ah, 0
intro_3			BYTE	"Each number needs to be small enough to fit inside "
				BYTE	"a 32-bit register.", 0dh, 0ah, "After you have "
				BYTE	"finished inputting the numbers I will display a list "
				BYTE	"of the integers, the sum, and the average.", 0dh, 0ah, 0dh, 0ah, 0
promptText		BYTE	"Please enter an unsigned number: ", 0
userString		BYTE	STRING_SIZE DUP(0)											; Holds input as a string (up to 10 digits)
stringLength	DWORD	?															; Holds length of user input
temp			BYTE	0															; Helps with conversion from char to numeric value
userVal			DWORD	?															; Holds input as a numeric value
invalidFlag		DWORD	?															; 0 if input is only numbers, 1 otherwise
array			DWORD	NUM_VALUES DUP(?)											; Stores valid user inputs
goodString		BYTE	"Good input", 0
badString		BYTE	"Bad input", 0
.code
main PROC

; Introduce the program and programmer
	push	OFFSET intro_1
	push	OFFSET intro_2
	push	OFFSET intro_3
	call	introduction

; Prompt the user for input
	push	OFFSET promptText
	push	OFFSET userString
	push	OFFSET stringLength
	push	OFFSET temp
	push	OFFSET userVal
	push	OFFSET invalidFlag
	call	ReadVal

	cmp		invalidFlag, 1
	je		badInput
	mov		edx, OFFSET goodString
	call	WriteString
	mov		eax, userVal
	call	WriteDec
	jmp		goodInput
badInput:
	mov		edx, OFFSET badString
	call	WriteString
goodInput:

; Display valid inputs
; Display sum of inputs
; Display average of inputs
; Say farewell

	exit	; exit to operating system
main ENDP

; Description: Procedure to introduce the program and programmer
; Receives: addresses of intro text
; Returns: none
; Preconditions: none
; Registers changed: none

introduction	PROC
; Set up stack frame
	push	edx
	push	ebp
	mov		ebp, esp
	
; Display program's title and programmer's name
	mov		edx, [ebp+20]
	call	WriteString

; Display program instructions
	mov		edx, [ebp+16]
	call	WriteString

; Display program description
	mov		edx, [ebp+12]
	call	WriteString

; Reset stack frame
	pop		ebp
	pop		edx
	ret		12
introduction	ENDP

; Description: Procedure to get a value from the user
; Receives: 
; Returns: 
; Preconditions: 
; Registers changed: 

ReadVal		PROC
; Set up stack frame
	pushad
	push		ebp
	mov			ebp, esp

; Get string from user
	getString	[ebp+60], [ebp+56]

; Set up conversion from char to int
	mov			edx, [ebp+52]			; Access address of string length variable
	mov			[edx], eax				; Store string length	
	mov			ecx, eax				; Set up counter			
	mov			ebx, [ebp+40]			; Store status flag
	mov			esi, [ebp+56]			; Store input
	mov			edi, [ebp+56]			; Store output
	cld									; Read string in forward direction
counter:
	lodsb
	cmp			al, 48
	jl			notNum
	cmp			al, 57
	jg			notNum
	sub			al, 48
	stosb
	loop		counter
	push		[ebp+56]	; Pass user input by reference
	push		[edx]		; Pass length of input
	push		[ebp+48]	; Pass temp value by reference
	push		[ebp+44]	; Pass variable to hold user's numeric value by reference
	push		[ebx]		; Pass status flag
	call		charToNum
	jmp			validInput

notNum:
	mov			eax, 1
	mov			[ebx], eax
	jmp			invalidInput

validInput:
	mov			eax, 0
	mov			[ebx], eax

invalidInput:
; Reset stack frame
	pop			ebp
	popad
	ret			24
ReadVal		ENDP

charToNum	PROC
; Set up stack frame
	pushad
	push	ebp
	mov		ebp, esp

; Set up conversion
	mov		ecx, [ebp+52]	; Set up counter
	mov		esi, [ebp+56]	; Start of string
	mov		edx, 0
	mov		edi, [ebp+48]	; Access temp variable
	mov		ebx, 0
counter:
	lodsb
	mov		[edi], al
	mov		eax, 10
	mul		ebx
	mov		ebx, eax
	add		ebx, DWORD PTR [edi]
	loop	counter
	mov		eax, [ebp+44]
	mov		[eax], ebx
	
; Reset stack frame
	pop		ebp
	popad
	ret		20
charToNum	ENDP

END main
