TITLE Programming Assignment One(Assignment1.asm)

; Author: Tara Massey				
; OSU Email Address: masseyta@onid.oregonstate.edu
; Course: CS271-400	
; Assignment Number: Assignment One
; Assignment Due Date: 04/12/2015
; Description: This program will display the author's name, program title, and intstructions for the user.
; The program will receive two integers as input, and calculate the sum, difference, product, quotient and 
; remainder of the numbers. The program will notify the user that the program is terminating. The program 
; will notify the user if the second value entered is larger than the first value entered.


INCLUDE Irvine32.inc


.data
; user input
input		DWORD	?									; Integer to be entered by user
input2		DWORD	?									; Integer to be entered by user

; prompts, instructions, and messages
intro_one	BYTE	"Author: Tara Massey", 0	
intro_two	BYTE	"Title: Programming Assignment One", 0	
instr_one	BYTE	"Enter two numbers and this program will display the sum, difference, product, quotient, and remainder.", 0	
instr_two	BYTE	"Please enter a number now: ", 0	
instr_three	BYTE	"Thanks! Please enter a second, smaller number for the calculations: ", 0
goodbye		BYTE	"Thanks for using the program. Goodbye!", 0		; Terminating message
err_msg		BYTE	"The second number needed to be smaller than the first for the program to work.", 0			; error  msg
ec_two		BYTE	"EXTRA CREDIT: Option #2: Program verifies the second number is less than the first", 0		; extra credit msg

; structuring display of output
sum_msg		BYTE	" + ", 0							; Sum message
diff_msg	BYTE	" - ", 0							; Difference message
prod_msg	BYTE	" x ", 0							; Product message
quot_msg	BYTE	" / ", 0							; Quotient message
remaind_msg	BYTE	" with a remainder of ", 0			; Remainder message
answer_msg	BYTE	" = ", 0

; answer variables
answer_sum	DWORD	?
answer_diff	DWORD	?
answer_prod	DWORD	?
answer_quot	DWORD	?
answer_rem	DWORD	?



.code
main PROC
; Introduction
	; Display my name
	mov		edx, OFFSET intro_one			
	call	WriteString
	call	CrLf

	; Display the program's name
	mov		edx, OFFSET intro_two			
	call	WriteString
	call	CrLf
	call	CrLf

	; Display purpose of the program
	mov		edx, OFFSET instr_one
	call	WriteString		
	call	CrLf
	call	CrLf

	; Dislay Extra Credit Option
	mov		edx, OFFSET ec_two					; extra credit two - validation
	call	WriteString
	call	CrLf
	call	CrLf
	

; Get the data
	; Print prompt and get first integer
	mov		edx, OFFSET instr_two
	call	WriteString
	call	ReadInt
	mov		input, eax							; store user input into input variable
	call	CrLf

	; Print prompt and get second integer
	mov		edx, OFFSET instr_three
	call	WriteString
	call	ReadInt
	mov		input2, eax							; store user input into input variable
	call	CrLf
	call	CrLf


; Calculate the required values
	; Extra Credit Option: Compare input for validation purposes
	mov		ebx, input
	mov		ecx, input2
	cmp		ebx, ecx
	jng		L1									; jump to error message at end if left is not greater than right
	
	; Finish calculating the sum
	add		ecx, ebx							; add values from input one and input two together
	mov		answer_sum, ecx						; store answer in variable


	; Calculate the difference of input and input2
	mov		ebx, input
	mov		ecx, input2
	sub		ebx, ecx							; subtract value of input two from value of input one
	mov		answer_diff, ebx					; store answer in variable

	; Calculate the product of input and input2
	mov		eax, input
	mul		input2								; eax is automatically used, multiplied by input2
	mov		answer_prod, eax					; store answer in variable

	; Calculate the quotient and remainder of input and input2
	mov		edx, 0								; initialize to 0 to prevent a program crash
	mov		eax, input							
	mov		ebx, input2							
	div		ebx									; divides by value stored in eax
	mov		answer_quot, eax					; store answer in variable
	mov		answer_rem, edx						; store remainder in variable
	

; Display the results
	; Display the Sum
	mov		eax, input							
	call	WriteDec							; display input's value
	mov		edx, OFFSET sum_msg
	call	WriteString							; " + "
	mov		eax, input2
	call	WriteDec							; display input2's value
	mov		edx, OFFSET answer_msg
	call	WriteString							; " = "
	mov		eax, answer_sum	
	call	WriteDec							; display the answer
	call	CrLf

	; Display the Difference
	mov		eax, input							
	call	WriteDec							; display input's value
	mov		edx, OFFSET diff_msg
	call	WriteString							; " - "
	mov		eax, input2
	call	WriteDec							; display input2's value
	mov		edx, OFFSET answer_msg
	call	WriteString							; " = "
	mov		eax, answer_diff
	call	WriteDec							; display the answer
	call	CrLf

	; Display the Product
	mov		eax, input							
	call	WriteDec							; display input's value
	mov		edx, OFFSET prod_msg
	call	WriteString							; " x "
	mov		eax, input2
	call	WriteDec							; display input2's value
	mov		edx, OFFSET answer_msg
	call	WriteString							; " = 
	mov		eax, answer_prod	
	call	WriteDec							; display the answer
	call	CrLf

	; Display the quotient and remainder
	mov		eax, input							
	call	WriteDec							; display input's value
	mov		edx, OFFSET quot_msg
	call	WriteString							; " / "
	mov		eax, input2
	call	WriteDec							; display input2's value
	mov		edx, OFFSET answer_msg
	call	WriteString							; " = "
	mov		eax, answer_quot	
	call	WriteDec							; display the answer
	mov		edx, OFFSET remaind_msg
	call	WriteString							; remainder message
	mov		eax, answer_rem
	call	WriteDec							; display remainder's value
	call	CrLf
	jmp		L2									; successful completion of tasks

; Say goodbye
	L1:											; Start of error message if input2 was larger than input
	mov		edx, OFFSET err_msg
	call	WriteString
	L2:											; Start of successful ending message if input > input2
	call	CrLf
	mov		edx, OFFSET goodbye
	call	WriteString
	call	CrLf

	invoke ExitProcess,0

main endp
END main