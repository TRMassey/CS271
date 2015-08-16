TITLE Programming Assignment Two(assignment2.asm)

; Author: Tara Massey				
; OSU Email Address: masseyta@onid.oregonstate.edu
; Course: CS271-400	
; Assignment Number: Assignment Two
; Assignment Due Date: 04/19/2015
;
; Description: This program calculates Fibonacci numbers in a range of 1-46. The 0th Fibonacci number is not included. The numbers will
; be displayed in 5 columns, separated by at least 5 spaces. The program will validate user input is between 1 and 46, and redirect the
; user to enter proper input if out of range. The program introduces the title of the program, the author, the purpose of the program, 
; and displays a goodbye message. In addition, the following requirements have been met:
;		- data validation is implemented in a post test loop
;		- the calculation for the Fibonacci terms uses a loop instruction
;		- the main procedure is divided into five sections
;		- the upper limit is a defined constant
;
; Help with Fibonacci Loop Received From:
; OSU Discussion Q&A Week Two, April 9th
; Student Sven wrote that he treated F^1 as a special case, and then created a loop by summing the previous term.
; Loop created based off Sven's posted idea


INCLUDE Irvine32.inc

; constants
UPPER_LIMIT = 46

.data
	; introduction
	program		BYTE	"Program Name: Fibonacci Numbers", 0
	author		BYTE	"Programmed By: Tara Massey", 0

	; instructions
	purpose		BYTE	"This program will display fibonacci numbers 1 through an amount you specify.", 0
	greet		BYTE	"Hi there, ", 0

	; prompts
	prompt_name	BYTE	"What's your name? ", 0
	prompt_one	BYTE	"As an integer, enter the amount of Fibonacci terms to be displayed [1 - 46]: ", 0
	error_msg	BYTE	"ERROR : The number must be between 1 and 46.", 0

	; user input and input buffers
	num			DWORD	?
	count		DWORD	?
	user		BYTE	31 DUP(0)

	; display values
	value		DWORD	?
	prev		DWORD	?

	; formatting
	column		DWORD	?
	format		BYTE	"         ", 0

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


; Section Three: GetUserData

	range:
		; display number terms prompt
		mov		edx, OFFSET prompt_one
		call	WriteString									; display prompt for number input

		; get number input
		call	ReadInt
		call	CrLf

		; validate input loop
		cmp		eax, 1
		jl		error										; jump to error message if less than 1
		cmp		eax, UPPER_LIMIT		
		jg		error										; jump to error message if greater than 46
		jmp		continue									; jump over error message to continue

	; display error if the input was wrong
	error:
		mov		edx, OFFSET error_msg
		call	WriteString									; display error message
		call	CrLf
		call	CrLf
		jmp		range										; jump back to section getUserInput, creating a loop

	; continuing without error message if correct
	continue:												; all input looks good, jumped out of loop
		mov		num, eax									; store the user's input
		call	CrLf
		call	CrLf


; Section Four: displayFibs

	; set up the starting conditions for the calculation loop
	mov		eax, 0
	mov		ebx, 1
	mov		ecx, num									; counter is set to user input
	mov		value, 1									; value is at one for special case handling prior to loop
	mov		prev, 0										; previous is 0, since no calculatio loop has run
	mov		column, 1									; column is 1, since special case will print at column 0

	; F^0 is not allowed, per assignment. F^1 is a special case
	mov		eax, value
	call	WriteDec									; display "1" as a special case
	dec		ecx											; decrease for special case print

	; Account for special case, user asking for first number
	cmp		num, 1										; if the user num input was "1"
	je		farewell									; go to the ending message

	loop1:												; loop for calculations, per instructions
		; add the terms
		mov		eax, value								; put the value in eax		
		add		eax, prev								; add the value to the previous value		
		mov		value, eax								; store sum					
		
		; store values and format columns
		mov		prev, ebx								; store previous value (number before current)
		mov		edx, OFFSET format						; 5 spaces between		
		call	WriteString	
		mov		ebx, value								; move over the current sum for printing								
		
		; determine if maximum column amount is reached
		cmp		column, 5								; if the column is less than 5
		jl		sameRow									; continue displaying on same row

		; making a new row
		call	CrLf									; make new row if column is already at 5
		mov		column, 0								; make the column amount 0 for next row

		sameRow:										; if the column amount is less than 5
			call	WriteDec							; print the sum
			mov		edx, column
			inc		edx									; inc column amount
			mov		column, edx							; store back in column


		;loop it until ecx (user's max terms to display) is out
		loop	loop1									; loop, per instructions


; Section Five: farewell
	; display parting message							
	farewell:											; once user number is reached, this finishes the program
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