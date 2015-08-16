TITLE Programming Assignment Five(assign5.asm)

; Author: Tara Massey				
; OSU Email Address: masseyta@onid.oregonstate.edu
; Course: CS271-400	
; Assignment Number: Assignment Five
; Assignment Due Date: 05/24/2015
; Description: This program receives integer input from the user and generates that amount of random integers in the range 100-999, storing
; the elements in an array. The program displays the array before and after sorting, with 10 elements per line. The program then calculates
; and displays the median value, rounded to the nearest integer. Per assignment instructions:
;	- The main program is function calls to procedures main, introduction, getData, fillArray, and displayMedian
;	- The program has four global constants
;	- The program title, author's name, and instructions are displayed
;	- Variables are not referenced by name outside of the main function
; Citations listed in the function headers, when appropriate.
; Citation List Includes:
; Irvine, Kip. Assembly Language for x86 Processors. Page 375, BubbleSort.
; Paulson, Paul. Lecture 19 Slide 12
; Paulson, Paul. Lecture 20 Slides 3 and 7




INCLUDE Irvine32.inc

; constants
	MIN = 10
	MAX = 200
	LO = 100
	HI = 999

.data
	; introduction
	program		BYTE	"Program Name: Random Integers, Assignment Five", 0
	author		BYTE	"Programmed By: Tara Massey", 0

	; instructions
	purpose		BYTE	"This program will generate random numbers in the range [100 -999], display the original list, ", 0
	purpose2	BYTE	"sort the list, display the median value, and display the list sorted in descending order.", 0

	; prompts and messages
	prompt_one	BYTE	"Enter the amount of numbers you'd like to see generated [ between 10 - 200] : ", 0
	error_msg	BYTE	"ERROR : The number amount must be between 10 and 200!", 0

	; user input and input buffers
	request		DWORD	?										; user gives size

	; display values
	array		DWORD	MAX	DUP(?)								; array capacity 200
	unsorted	BYTE	"Unsorted List : ", 0					; Title Unsorted
	sorted		BYTE	"Sorted List : ", 0						; Title Sorted
	median		BYTE	"Median : ", 0							; Displaying Median
	format		BYTE	"   ", 0								; Formatting columns
	count		DWORD	?



.code
main PROC
	; Lecture states randomize can be called only once, should be from main
	call	RANDOMIZE
	
	; Procedure One : Introduction
	; No parameters. Per instructions, strings can be global
	call	introduction												; push return address [ESP]

	; Procedure Two : getData
	; Parameters : request (reference)
	push	OFFSET request												; push @request. [ESP + 4]
	call	getData														; push return address [ESP]

	; Procedure Three: Fill Array
	; Parameters : request (value), array (reference)
	push	OFFSET array												; push address of the array [ESP + 8]
	push	request														; push value of request	[ESP + 4]
	call	fillArray													; push return address [ESP]

	; Procedure Four a: displayList, unsorted
	; Parameters : array (reference), request (value), title (reference)
	push	OFFSET array												; push address of array [ESP+12]
	push	request														; push request value [ESP+8]
	push	OFFSET unsorted												; even though strings are global, per instructions[ESP+4]
	call displayList													; push return address [ESP]

	; Procedure Five: sortList
	; Parameters : array (reference), request (value)
	push	OFFSET array												; push address of array[ESP +8]
	push	request														; push value of request[ESP +4]
	call	sortList													; push return address [ESP]

	; Procedure Six : displayMedian
	; Parameters : array (reference), request (value)
	push	OFFSET array												; push address of array[ESP +8]
	push	request														; push value of request[ESP +4]
	call	displayMedian												; push return address [ESP]

	; Procedure Four b: displayList, now sorted
	; Parameters : array (reference), request (value), title (reference)
	push	OFFSET array												; push address of array [ESP+12]
	push	request														; push request value [ESP+8]
	push	OFFSET sorted												; even though strings are global, per instructions[ESP+4]
	call displayList													; push return address [ESP]

	invoke ExitProcess,0
main endp

;***********************************************************************************************************
; Procedure: introduction
; Displays the program name, author, and description of the program. 
; receives: none
; returns: prints program title, author name, and description of the program. 
; registers changed: edx
;***********************************************************************************************************
introduction PROC

	; display program and author
	mov		edx, OFFSET program
	call	WriteString										; program title
	call	CrLf
	mov		edx, OFFSET author
	call	WriteString										; introduce myself
	call	CrLf
	call	CrLf

	; display program purpose
	mov		edx, OFFSET purpose								
	call	WriteString										; explain program
	mov		edx, OFFSET purpose2							; continue explanation
	call	WriteString
	call	CrLf
	call	CrLf

	ret														; return to main
introduction	ENDP



;***********************************************************************************************************
; Procedure : getData
; Prompts the user for input and validates data is within range
; receives: request by reference
; returns: alters contents at address of request
; registers changed: edx, eax, ebx
;************************************************************************************************************
getData	PROC
	push	ebp												; set up stack frame, old ebp on stack +4
	mov		ebp, esp										; now pointing at same
	mov		ebx, [ebp+8]									; ebp+8 location of request's address in stack
															; ebx now pointint to location of request
	range:
		; display prompt for request
		mov		edx, OFFSET prompt_one						; strings can be global, per instructions
		call	WriteString									; display prompt for number input
		call	CrLf

		; get number input
		call	ReadInt										; get the user's number
		cmp		eax, MIN									; user's request is in eax
		jl		invalid										; if less than global minimum, go to invalid msg
		cmp		eax, MAX									; else, compare to global max
		jg		invalid										; go to invalid message if greater than global max
		jmp		valid										; else, is valid, go to end

	invalid:
		mov		edx, OFFSET error_msg						; error message, global string
		call	WriteString									; user notified of errror
		call	CrLf
		jmp		range										; jump back to range to try and get proper input

	valid:
		mov		[ebx], eax									; stores valid value in address pointed to by ebx
		pop		ebp											; restore the stack
		ret		4											; returns bytes pushed prior to the call
getData		ENDP


;***********************************************************************************************************
; Procedure : fillArray
; Fills the array at the passed address location with random numbers until the value of the user's request
; is met
; receives: Address location of the array, value of variable "request", which serves as the number to fill
; the array to 
; returns: Array at passed array address changed
; registers changed: eax, ecx
; Citation: Function set up based on Lecture 19, Slide 12.
; Citation: Generating the range based on Lecture 20, Slide 7.
;************************************************************************************************************
fillArray	PROC
	push	ebp												; set up stack frame. Old ebp on stack, +4 to others
	mov		ebp, esp										; now pointing to same
	mov		edi, [ebp+12]									; address of beginning of array to edi
	mov		ecx, [ebp+8]									; number of elements to put in to ecx to loop through

	addAnother:
		mov		eax, HI										; global high
		sub		eax, LO										; global high - global low
		add		eax, 1										; and add one to get the full range
		call	RandomRange									; from Irvine library, produces number in range
		add		eax, LO										; per instructor's lecture video 20, create psuedo-random integer
		mov		[edi], eax									; store random number in current array element
		add		edi, 4										; add four to increase address location to next element of array
		loop	addAnother									; loop for more input

		pop		ebp											; pop what's been pushed
		ret		8											; returns bytes pushed prior to the call
fillArray	ENDP


;***********************************************************************************************************
; Procedure : displayList
; Displays the values stored in the array
; receives: Address of array, the value of the user's request, title
; returns: Displays the title and the values stored in the array. No changes.
; registers used: ecx, ebx, edx, eax
; Citation: Main display based on Lecture 20, Slide 3. Changes to lecture include incorporation of displaying
; with columns and displaying the title
;************************************************************************************************************
displayList PROC
	push	ebp												; set up stack frame. Old ebp to stack. +4 to others.
	mov		ebp, esp										; now pointing at same
	mov		esi, [ebp+16]									; address of array
	mov		ecx, [ebp+12]									; amount to print to ecx loop
	mov		ebx, 1											; separate counter for row of 10

	; display the title
	call	CrLf
	mov		edx, [ebp+8]									; location of the global string on stack
	call	WriteString										; print
	call	CrLf

	displayCurrent:
		cmp		ebx, MIN									; global MIN is set to 10, use as comparison
		jg		newRow										; jump to new row to reset ebx if 10 values are printed
		mov		eax, [esi]									; else, get current element
		call	WriteDec									; display number
		mov		edx, OFFSET format
		call	WriteString									; display spaces
		add		esi, 4										; add four to go to next element
		add		ebx, 1										; increase ebx for the next loop
		loop	displayCurrent
		jmp		done										; jump to skip the creation of a new row

	newRow:
		call	CrLf										; make a new row
		mov		ebx, 1										; reset ebx for the new row
		jmp		displayCurrent								; and go display the current number

	done:
		pop		ebp											; reached the end of the array, pop what's been pushed
		ret		12											; return bytes pushed before the call
displayList ENDP



;***********************************************************************************************************
; Procedure : sortList
; Sorts the values stored in the array in order of greatest to least
; receives: Address of the array, the value of the user's request
; returns: Contents of array at passed address are changed, now ordered
; registers changed: ecx , eax
; Citation: Irvine, Kip. Assembly Language. Page 375, BubbleSort. Code adjusted for descending size.
;************************************************************************************************************
sortList PROC
	push	ebp												; set up stack frame. Old ebp on stack +4 to others
	mov		ebp, esp										; now pointing to same
	mov		ecx, [ebp+8]									; number of elements to put in to ecx to loop through
	dec		ecx

	; outer loop
	L1:
		push	ecx											; save outer loop
		mov		esi, [ebp+12]								; arrays address

	; inner loop
	L2:
		mov		eax, [esi]									; contents in that element of the array
		cmp		[esi +4], eax								; compare current value to next value
		jl		L3											; if the next is smaller than current, jump
		xchg	eax, [esi+4]								; swap
		mov		[esi], eax									

	L3:
		add		esi, 4										; move to next element
		loop	L2											; inner loop

	; return to outer loop
	pop		ecx												; restore outer loop
	loop	L1												; repeat outer loop

	pop		ebp												; pop what's been pushed
	ret		8												; outer loop counter down to 0, end

sortList ENDP


;***********************************************************************************************************
; Procedure : displayMedian
; Determines the median of a sorted array. Rounds to the nearest whole integer.
; receives: Address to the array, the value of the user's request
; returns: None. Displays median.
; registers used: eax, ecx, ebx, edx
;************************************************************************************************************
displayMedian PROC
	push	ebp												; set up stack frame. Old ebp on stack, +4 to others
	mov		ebp, esp										; now pointing to same
	mov		esi, [ebp+12]									; address of beginning of array to esi
	mov		eax, [ebp+8]									; number of elements to put in to eax
	mov		edx, 0											; set edx

	; find the half way point
	mov		ebx, 2
	div		ebx												; divide the array in half
	cmp		edx, 0											; if the remainder is 0, more calculations will have to occur
	je		findMedian										; jump to determine the number half way between two array numbers

	; find the halfway point in the array
	mov		ebx, 4
	mul		ebx												; 4 bytes per DWORD, should bring us to location in array
	add		esi, eax										; eax holds the location in the array, + current start of array in esi
	mov		eax, [esi]										; no remainder, no further calculations, move the value in esi at location for printing

	; display the median
	call	CrLf
	call	CrLf
	mov		edx, OFFSET median								; strings are global, per instructions
	call	WriteString
	call	WriteDec										; display the median stored in eax
	call	CrLf
	jmp		done

	findMedian:

		; find the higher position's address location
		mov		ebx, 4
		mul		ebx											; 4 bytes per DWORD, should bring us to location in array
		add		esi, eax									; eax holds the location in the array, + current start of array in esi
		mov		edx, [esi]									; one value stored

		; find the lower position's address location
		mov		eax, esi									; higher positon's address
		sub		eax, 4										; go down one address location
		mov		esi, eax									; new address location in esi
		mov		eax, [esi]									; value oof lower position's address stored
		
		; get the average of the two values
		add		eax, edx									; add value one and two
		mov		edx, 0										; restore edx to zero for division
		mov		ebx, 2										; prep to divide in half
		div		ebx											; divide the sum stored in eax in half
		
		; display the median
		call	CrLf
		call	CrLf
		mov		edx, OFFSET median							; "Median:"
		call	WriteString
		call	WriteDec									; Median's value
		call	CrLf	

	done:
		pop		ebp
		ret 8

displayMedian ENDP
END main
