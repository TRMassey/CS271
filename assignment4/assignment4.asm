TITLE Programming Assignment Four(assignment4.asm)

; Author: Tara Massey				
; OSU Email Address: masseyta@onid.oregonstate.edu
; Course: CS271-400	
; Assignment Number: Assignment Four
; Assignment Due Date: 05/10/2015
;
; Description: This program calculates composite numbers up to and including a number of user choice. The user may enter any integer from
; 1 to 400. If the number is out of range the user will be notified. The composites will be displayed as 10 composite numbers per line,
; with at least three spaces between each number.
; Additionally:
;	1. The main procedure will be composed of calls to other procedures
;	2. At this time the procedures will use global variables
;	3. Upper limit is a constant
;	4. The counting uses a MASM loop instruction


INCLUDE Irvine32.inc

; constants
	UPPER_LIMIT = 400

.data
	; introduction
	program		BYTE	"Program Name: Composite Numbers, Assignment Four", 0
	author		BYTE	"Programmed By: Tara Massey", 0

	; instructions
	purpose		BYTE	"This program will calculate the composite numbers up to/including the nth input supplied by the user.", 0
	greet		BYTE	"Hi there, ", 0

	; prompts and messages
	prompt_name	BYTE	"What's your name? ", 0
	prompt_one	BYTE	"Enter the amount of composite numbers you'd like to see [ between 1 - 400] : ", 0
	error_msg	BYTE	"ERROR : The number must be between 1 and 400!", 0

	; user input and input buffers
	num			SDWORD	?
	count		DWORD	?
	user		BYTE	31 DUP(0)

	; display values
	val			DWORD	?
	column		DWORD	?
	format		BYTE	"   ", 0

	; ending
	goodbye		BYTE	", thank you for using the Program!", 0
	end_msg		BYTE	"END", 0


.code
main PROC
	
	; Procedure One : Introduction
	call	introduction

	; Procedure Two : getUserData & sub-procedure validate
	call	getUserData
		
	; Procedure Three : showComposites & sub-procedure isComposite
	call	showComposites
	
	; Procedure Four : Farewell
	call	farewell


	invoke ExitProcess,0
main endp


; Procedure: introduction
; Displays the program name, author, and description of the program. Prompts for the user's name and
; stores the user's name.
; receives: none
; returns: prints program title, author name, and description of the program. User's name is stored in
; the global variable 'user'.
introduction PROC
	
	; display program and author
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

	; display program purpose
	mov		edx, OFFSET purpose								
	call	WriteString										; explain program
	call	CrLf
	call	CrLf

	ret														; return to main
introduction	ENDP
	


; Procedure : getUserData
; Prompts the user for input and calls the validate function to ensure valid input. Will be called again
; by validate function if input is invalid.
; receives: none
; returns: stores the user input in variable num
getUserData	PROC
	range:
		; display number terms prompt
		mov		edx, OFFSET prompt_one
		call	WriteString									; display prompt for number input

		; get number input
		call	ReadInt										; get the user's number
		mov		num, eax									; store the number
	
		call	validate									; check that the number is within range
	ret														; return to main
getUserData		ENDP



; Procedure: validate
; Checks the user input against the lowest possible and highest possible valid ranges. Returns user to
; getUserData function if invalid.
; receives: global variable num, which has user input
; returns: prints error message if invalid. Num remains unaltered.
validate PROC
	; make sure the user's number is at least 1
	cmp		num, 1										; check that the number is non-negative
	jl		invalid	

	; make sure the user's number is less than 400
	cmp		num, UPPER_LIMIT							
	jg		invalid								
	jmp		done										; otherwise, passed and can return

	; if the number did not pass validation
	invalid:			
		mov		edx, OFFSET error_msg
		call	WriteString
		call	CrLf
		call	getUserData								; return to get data, nothing stored

	; user's number passed validation check
	done:
		ret												; return to main
validate		ENDP




; Procedure: showComposites
; Using a loop, displays each composite number in a row of ten. Calls on isComposite procedures
; to determine if the number is a composite prior to display.
; receives: global variable num, which is user input.
; returns: prints the value of variable "val" to screen. Val starts at 1 and is increased each loop,
; sent to isComposite, and is printed on return if it is a composite. Variable column is decremented
; and restored to 10 to ensure proper number amount per row.
showComposites PROC

	; set up counter and starting values
	mov		ecx, num									; loop counter set to user's number
	mov		column, 10									; column amount
	mov		val, 1										; first non-neg number
	
	loop1:												; loop for calculations, per instructions

		; determine if it's a composite
		call	isComposite								; determine if the number is a composite number			

		; store values and format columns
		mov		eax, val								; val is now a composite number, and is in eax
		mov		edx, OFFSET format						; 3 spaces between		
		call	WriteString							
		
		; determine if maximum column amount is reached
		cmp		column, 10								; if the column is less than 10
		jl		sameRow									; continue displaying on same row

		; making a new row
		call	CrLf									; make new row if column is already at 10
		mov		column, 0								; make the column amount 0 for next row

		sameRow:										; if the column amount is less than 10
			call	WriteDec							; print the composite number
			mov		edx, column
			inc		edx									; inc column amount
			mov		column, edx							; store back in column
			mov		eax, val
			add		eax, 1								; increase val by one for testing at beginning of loop
			mov		val, eax							; store


		;loop it until ecx (user's max terms to display) is out
		loop	loop1									; loop, per instructions
	ret
showComposites	ENDP


; Function: isComposite
; Divides each value received by 2, 3, 5, 7, and 9. If there is no remainder, the value is determined to be a composite
; and is returned. Else, the value is increased by run and the test is rerun until a valid composite is found.
; receives:
; returns:
isComposite	PROC

	; test for fringe cases
	mov		edx, 0
	mov		ebx, 0
	mov		eax, val									; moving to eax since a var can't move to a var
	cmp		eax, 3										; 1-3 are not composite numbers
	jle		notValidComp								; only divisible by self, doesn't meet definition

	; test for remainder when divided by 2				; eax has the value in it already
	mov		ebx, 2										; store in ebx for division
	div		ebx											; divide eax by ebx
	cmp		edx, 0										; if there is no remainder, composite is true
	je		validComp
	mov		edx, 0

	; test for remainder when divided by 3
	mov		eax, val									; put the original number back in eax
	mov		ebx, 3										; store in ebx for division
	div		ebx											; divide eax by ebx
	cmp		edx, 0										; if there is no remainder, composite is true
	je		validComp
	mov		edx, 0

	; test for remainder when divided by 5
	mov		eax, val									; put the original number back in eax
	mov		ebx, 5										; store in ebx for division
	div		ebx											; divide eax by ebx
	cmp		edx, 0										; if there is no remainder, composite is true
	je		validComp
	mov		edx, 0

	; test for remainder when divided by 7
	mov		eax, val									; put the original number back in eax
	mov		ebx, 7										; store in ebx for division
	div		ebx											; divide eax by ebx
	cmp		edx, 0										; if there is no remainder, composite is true
	je		validComp
	mov		edx, 0

	; test for remainder when divided by 9
	mov		eax, val									; put value in a testVal variable
	mov		ebx, 9										; store in ebx for division
	div		ebx											; divide eax by ebx
	cmp		edx, 0										; if there is no remainder, composite is true
	je		validComp
	mov		edx, 0

	notValidComp:
		mov		eax, val
		add		eax, 1									; go to next number if not composite
		mov		val, eax
		call	isComposite								; start process over

	validComp:
		; catch fringe cases from testing
		mov		eax, val
		cmp		eax, 5									; is val equal to five?
		je		notValidComp							; 5 is only divisible by itself, jump if five
		cmp		eax, 7									; is val equal to seven?
		je		notValidComp							; 7 is only diisible by itself, jump if seven
		ret												; contents of val is a composite
isComposite		ENDP




;Function farewell
; Tells the user goodbye by name
; receives: global variable user
; returns: Prints the user's name and goodbye message.
farewell PROC
	call	CrLf
	call	CrLf
	mov		edx, OFFSET user						; call the user by name again
	call	Writestring
	mov		edx, OFFSET goodbye						; tell them farewell
	call	WriteString
	call	CrLf
	mov		edx, OFFSET end_msg
	call	WriteString								; end program message
	call	CrLf
	ret
farewell	ENDP

END main