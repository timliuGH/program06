TITLE Low-level I/O Procedures     (Program06_Liu_Timothy.asm)

; Author: Timothy Liu
; Last Modified: November 21, 2018
; OSU email address: liutim@oregonstate.edu
; Course number/section: CS_271_400_F2018
; Project Number: 06               Due Date: December 2, 2018
; Description: This program implements ReadVal and WriteVal procedures
;   for unsigned integers and uses getString and displayString macros.
;	The program will prompt the user for a value, validate the input,
;	display all valid inputs, calculate and display the sum, and calculate
;	and display the average.

; Implementation notes: All procedure parameters are passed on system stack
;	Also, assumes sum of numbers fits in 32 bits. 

INCLUDE Irvine32.inc

getString MACRO prompt, input
	
ENDM

displayString MACRO
ENDM

NUM_VALUES = 10

.data

intro_1			BYTE	"Low-level I/O Procedures by Timothy Liu", 0dh, 0ah, 0
intro_2			BYTE	"Please provide 10 unsigned decimal integers", 0
intro_3			BYTE	"Each number needs to be small enough to fit inside "
				BYTE	"a 32-bit register.", 0dh, 0ah, "After you have "
				BYTE	"finished inputting the numbers I will display a list "
				BYTE	"of the integers, the sum, and the average.", 0dh, 0ah, 0
promptText		BYTE	"Please enter an unsigned number: ", 0
userInput		BYTE	?															; Holds user input as a string
array			DWORD	NUM_VALUES DUP(?)											; Stores valid user inputs


.code
main PROC

; Introduce the program and programmer
; Prompt the user for input and store
; Display valid inputs
; Display sum of inputs
; Display average of inputs
; Say farewell

	exit	; exit to operating system
main ENDP

; Description: Procedure to introduce the program and programmer
; Receives: 
; Returns: none
; Preconditions: none
; Registers changed: edx

introduction	PROC

	ret
introduction	ENDP

END main
