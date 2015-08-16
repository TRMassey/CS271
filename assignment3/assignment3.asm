TITLE Programming Assignment Three(assignment3.asm)

; Author: Tara Massey				
; OSU Email Address: masseyta@onid.oregonstate.edu
; Course: CS271-400	
; Assignment Number: Assignment Three
; Assignment Due Date: 05/03/2015
;
; Description: This program calculates the rounded integer average and sum of all the negative numbers input by the user.
; The user will have the ability to enter numbers untili a non-negative number is entered. Additionally, the program will:
;		- Display the program title and author's name
;		- Get the user's name and greet them
;		- Display instructions
;		- Display the number of negative numbers entered, the sum, and the average
;		- Display a goodbye message
;
; **EC: DESCRIPTION
; Option 1 : Number the lines during user Input


INCLUDE Irvine32.inc

; constants
LOWER_LIMIT = -100

.data
	; introduction
	program		BYTE	"Program Name: Negative Number Calculations, Assignment Three", 0
	author		BYTE	"Programmed By: Tara Massey", 0

	; extra credit
	extra		BYTE	"**EC : DESCRIPTION - Option 1, Number the lines during user input.", 0

	; instructions
	purpose		BYTE	"This program will calculate the rounded average and sum of all negative numbers entered.", 0
	greet		BYTE	"Hi there, ", 0

	; prompts and messages
	prompt_name	BYTE	"What's your name? ", 0
	prompt_one	BYTE	"Enter a negative number [-100 to -1], then enter, as many times as you like.", 0
	prompt_two	BYTE	"To begin the calculations, enter a positive number. This number will be discarded.", 0
	prompt_thr	BYTE	". Negative Number to Continue, or Positive Number to Display Calculations: ", 0
	error_msg	BYTE	"ERROR : The number must be between -100 and -1!", 0
	calc_msg	BYTE	"You entered ", 0
	calc_msg2	BYTE	" valid numbers.", 0
	spc_msg		BYTE	"You entered NO numbers for calculations.", 0

	; user input and input buffers
	num			SDWORD	?
	count		DWORD	?
	user		BYTE	31 DUP(0)

	; display values
	accum		DWORD	?
	lineCount	DWORD	?
	prev		SDWORD	?
	sum			SDWORD	?
	avg			SDWORD	?
	remaind		DWORD	?
	sum_msg		BYTE	"SUM: ", 0
	avg_msg		BYTE	"AVERAGE: ", 0

	; ending
	goodbye		BYTE	", thank you for using the Program!", 0
	end_msg		BYTE	"END", 0


.code
main PROC

; Section One: Introduction

	; display introduction
	mov		edx, OFFSET program
	call	WriteString										; program title
	call	CrLf
	mov		edx, OFFSET author
	call	WriteString										; introduce myself
	call	CrLf
	call	CrLf

	; display extra credit
	mov		edx, OFFSET extra								; numbered lines
	call	WriteString
	call	CrLf
	call	crLf

	; display prompt
	mov		edx, OFFSET prompt_name
	call	WriteString										; ask for name

	; get user name input
	mov		edx, OFFSET user								; point to buffer
	mov		ecx, SIZEOF	user								; max characters
	call	ReadString										; get the user's name
	mov		count, eax										; number of characters the user entered
	call	CrLf

	; greet user by name		
	mov		edx, OFFSET greet	
	call	WriteString										; display first part of greeting
	mov		edx, OFFSET user
	call	WriteString										; display user's name
	call	CrLf

; Section Two: UserInstructions

	; display program purpose
	mov		edx, OFFSET purpose								
	call	WriteString										; explain program
	call	CrLf
	call	CrLf


	; display the prompt for input
	mov		edx, OFFSET prompt_one
	call	WriteString									; first part of message
	mov		edx, OFFSET prompt_two
	call	WriteString									; second part of message
	call	CrLf
	call	crLf


; Section Three: GetUserData
	mov		sum, 0										; they'll give the terms to add, must have a starting term
	mov		eax, 0
	mov		accum, eax									; starting value for the accumulator

	; set up for counting the lines
	mov		lineCount, 0

	repeatInput:
		; get the number for the line
		mov		eax, lineCount
		add		eax, 1									; increase line count
		mov		lineCount, eax							; store line count

		; now ask for the input with the line number
		mov		ebx, lineCount
		call	writeDec								; display line count
		mov		edx, OFFSET prompt_thr
		call	WriteString								; prompt for input

		; get number input
		call	ReadInt									; get user's input
		call	CrLf

		; validate input loop
		cmp		eax, LOWER_LIMIT						; compare to end of range
		jl		error									; send to error message of less than -100
		cmp		eax, 0									; compare to end of range
		jge		calculations							; if positive, go to calculations and printing
		mov		num, eax								; still a valid negative, so store the results	
		jmp		continue								; then go to summation
						

	; display error if the input was wrong
	error:
		mov		edx, OFFSET error_msg
		call	WriteString									; display error message
		call	CrLf
		call	CrLf
		jmp		repeatInput									; jump back to section repeatInput, creating a loop



; Section Four: Adding

	continue:											; loop for getting the sum
		; update my accumulator for valid input
		mov		eax, accum
		inc		eax
		mov		accum, eax

		; add the terms
		mov		eax, num								; put the value in eax		
		add		eax, sum								; add the value to the previous sum		
		mov		sum, eax								; store sum					
		jmp		repeatInput								; go get more negative numbers


; Section Five: Calculation

	; Get the average
	calculations:
		; make sure there are results to display
		cmp		accum, 0
		je		specialError							; if no negative numbers were entered, send to special error and goodbye

		; there are negative numbers that have been entered, so calculate
		mov		eax, sum								; store the sum
		cdq												; extend for sign
		mov		ebx, accum								; store the amount of valid numbers
		idiv	ebx										; divide
		mov		avg, eax								; store the average as an integer
		mov		remaind, edx							; tuck away the remainder
		mov		accum, ebx

		;Figure out if it should be rounded
		cmp		remaind, 5								; per instructions, 20.5 rounds to 20
		jle		displayResults							; keep it, no rounding up
		mov		eax, avg								; otherwise round up by one
		add		eax, 1
		mov		avg, eax								; store it and move on


; Section Six: Display Results
	displayResults:
		mov		eax, 0
		mov		ebx, 0

		; let the user know the amount of valid numbers
		mov		edx, OFFSET calc_msg						; first part of message
		call	WriteString
		mov		eax, accum
		call	WriteDec
		mov		edx, OFFSET	calc_msg2						; second part of message
		call	WriteString
		call	CrLf

		; display the results 
		mov		edx, OFFSET sum_msg							; SUM :
		call	WriteString
		mov		eax, sum									; sum amount
		call	WriteInt
		call	CrLf

		mov		edx, OFFSET avg_msg							; AVG :
		call	WriteString
		mov		eax, avg									; rounded average amount
		call	WriteInt
		jmp		farewell									; jump over error message to get to end
		

; display parting message							
	specialError:
		call	CrLf
		mov		edx, OFFSET	spc_msg						; tells the user they had no valid input
		call	WriteString
		call	CrLf

	farewell:											; end message
		call	CrLf
		call	CrLf
		mov		edx, OFFSET user						; call the user by name again
		call	WriteString
		mov		edx, OFFSET goodbye						; tell them farewell
		call	WriteString
		call	CrLf
		mov		edx, OFFSET end_msg
		call	WriteString								; end program message
		call	CrLf


	invoke ExitProcess,0
main endp
END main