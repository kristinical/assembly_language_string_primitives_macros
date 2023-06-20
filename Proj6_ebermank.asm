TITLE String Primitives & Macros		(Proj6_ebermank.asm)

; Author: Kristin Eberman
; Last Modified: November 26, 2022
; OSU email address: ebermank@oregonstate.edu
; Course number/section:   CS271 Section 406
; Project Number:     6            Due Date: December 4, 2022
; Description: This program asks for 10 integers from the user,
;	validates the input, stores the numbers in an array, and 
;	then displays the values, their sum, and truncated average.
;	This program is implemented using two macros for processing
;	strings and two procedures for processing signed integers.
;	All parameters are passed on the runtime stack.

INCLUDE Irvine32.inc

; MACROS
; --------------------------------
; Name: mGetString
; Prompts a user to enter a string of text
; Preconditions: instruction parameter exists as a string, stringArr
;	has been initialized with length of STRINGSIZE global variable
; Postconditions: ECX changed, EDX holds address of user string,
;	EAX holds number of characters entered
; Receives:
;	instruction = address of prompt to display to the user
;	stringArr = address of array to hold user string input
;   STRINGSIZE = max size of string (length of BYTE array)
; Returns: stringArr = generated string address
; --------------------------------
mGetString MACRO instruction:REQ, stringArr:REQ
	MOV		EDX, instruction	; print instruction prompt to user
	CALL	WriteString
	MOV		EDX, stringArr		; point to the output string buffer
	MOV		ECX, STRINGSIZE		; specify max characters of stringArr
	CALL	ReadString
ENDM

; --------------------------------
; Name: mDisplayString
; Prints a string stored in a specified memory location
; Preconditions: string parameter exists as a string
; Postconditions: EDX changed
; Receives: string = address of string to print
; Returns: prints string to the console
; --------------------------------
mDisplayString MACRO string:REQ
	MOV		EDX, string
	CALL	WriteString
ENDM

; --------------------------------
; Name: mValidateChar
; Validates if a char is a valid digit and converts ascii 
;	value of char to its number equivalent
; Preconditions: AL holds a character, _displayError exists as code label
; Postconditions: none
; Receives: none
; Returns: AL holds ascii value of digit between 0-9
; --------------------------------
mValidateChar MACRO
	CMP		AL, 48			; 48 = ascii code for 0
	JB		_displayError	; Char < 48 is not a valid digit
	CMP		AL, 57			; 57 = ascii code for 9
	JA		_displayError	; Char > 57 is not a valid digit
	SUB		AL, 48			; convert char to number it represents in ascii
ENDM


; GLOBAL CONSTANTS
ARRAYSIZE = 10			; size of array that stores randomly generated integers
STRINGSIZE = 12			; length of string holding user input


.data
	programIntro	BYTE	"Hi! My name is Kristin Eberman and this is my String to Integer I/O Array Program.",13,10,0
	extraCred1		BYTE	13,10,"**EC 1: Program numbers each line of user input and displays running subtotal",13,10,0
	description		BYTE	13,10,"Please enter 10 valid integers (positive or negative, excluding commas). Each value needs",13,10
					BYTE	"to fit inside a 32 bit register, so must be in the range [-2,147,483,648, 2,147,483,647].",13,10
					BYTE	13,10,"I will then display all the integers, their sum, and average.",13,10,0
	prompt			BYTE	"Enter a signed integer: ",0 
	userString		BYTE	STRINGSIZE DUP(0)		; array to store user input string for each number prompt
	numberArray		SDWORD	ARRAYSIZE DUP(?)		; array to store validated user strings as signed integers
	validNum		SDWORD	?						; user input as validated signed integer
	sum				SDWORD	0						; holds sum of all validated signed integers entered by user
	count			DWORD	1						; holds count of user input to number each line of user input
	errorMsg		BYTE	13,10,"ERROR: Invalid input. Please try again.",0
	subtotal		BYTE	"Subtotal of integers: ",0
	numList			BYTE	13,10,"The numbers you entered are:",13,10,0
	sumMsg			BYTE	13,10,"Sum of the integers: ",0
	averageMsg		BYTE	13,10,"Truncated average of the integers: ",0
	separator		BYTE	") ",0

.code
main PROC
	; --------------------------------
	; INTRODUCTION
	; Describe the program by invoking the mDisplayString macro
	; --------------------------------
	mDisplayString OFFSET programIntro
	mDisplayString OFFSET extraCred1
	mDisplayString OFFSET description
	
	; --------------------------------
	; USER INPUT
	; Get 10 valid integers from the user and store in numberArray
	; --------------------------------
	MOV		ECX, ARRAYSIZE		; ARRAYSIZE = 10 -> loop counter
	MOV		EDI, OFFSET numberArray
_inputLoop:
	CALL	Crlf
	PUSH	count				; EC: number each line of user input
	CALL	WriteVal
	mDisplayString OFFSET separator
	INC		count				; Increment count for next iteration of user input

	; Call on readVal to get user string and convert it to a valid number
	PUSH	OFFSET validNum		; 4 bytes (+16 from EBP) 
	PUSH	OFFSET prompt		; 4 bytes (+12 from EBP)
	PUSH	OFFSET userString	; 4 bytes (+8 from EBP) -> RET 12
	CALL	readVal				; 4 bytes (+4 from EBP)

	; Store validated user input (validNum) in numberArray
	MOV		EAX, validNum
	MOV		[EDI], EAX			; EDI holds address of numberArray
	ADD		EDI, 4				; Move to location of next element (+4 bytes) in numberArray
	ADD		sum, EAX			; Add value of validNum to total sum

	; EC: display the running subtotal of user’s valid numbers
	mDisplayString OFFSET subtotal
	PUSH	sum					; 4 bytes (+8 from EBP) -> RET 4
	CALL	writeVal			; 4 bytes (+4 from EBP)
	LOOP	_inputLoop
	CALL	Crlf

	; --------------------------------
	; PRINT NUMBER ARRAY
	; Display the list of signed integers
	; --------------------------------
	mDisplayString OFFSET numList		; Invoke macro to print numList string
	MOV		ECX, ARRAYSIZE				; Set loop counter to size of array
	MOV		ESI, OFFSET numberArray

	; Print out each SDWORD value in numberArray via writeVal procedure
_printLoop:
	MOV		EAX, [ESI]					
	PUSH	EAX
	CALL	writeVal
	MOV		AL, 32						; 32 = ascii value for space " "
	CALL	WriteChar					; Print a space between each number
	ADD		ESI, 4						; Move to location of next element (+4 bytes) in numberArray
	LOOP	_printLoop

	; --------------------------------
	; PRINT SUM
	; Display the sum of integers
	; --------------------------------
	mDisplayString OFFSET sumMsg		; Invoke macro to print sumMsg string

	; Call writeVal procedure to convert SDWORD value of sum to string of ascii digits
	PUSH	sum							; 4 bytes (+8 from EBP) -> RET 4
	CALL	writeVal					; 4 bytes (+4 from EBP)

	; --------------------------------
	; PRINT AVERAGE
	; Calculate and display the truncated average
	; --------------------------------	
	mDisplayString OFFSET averageMsg	; Invoke macro to print averageMsg string

	; Calculate the averate by dividing the sum by ARRAYSIZE
	MOV		EAX, sum
	CDQ							; sign-extend
	MOV		EBX, ARRAYSIZE
	IDIV	EBX
	PUSH	EAX					; EAX holds the truncated average
	CALL	writeVal					

	CALL	Crlf

	Invoke	ExitProcess,0		; exit to operating system

main ENDP

; --------------------------------
; READ VALUE PROCEDURE
; Gets user input via mGetString macro, validates and converts the string of ascii digits 
;	to its numeric value representation, and stores validated value in memory variable
; preconditions: prompt exists as a string; validNum and userString variables are declared 
; postconditions: ECX is maintained; EAX, EBX, EDX, ESI are changed
; receives: Address of validNum variable [EBP+16], address of prompt string [EBP+12],
;	& address of userString [EBP+8]
; returns: validNum [EBP+16] memory variable holds validated signed integer
; --------------------------------
readVal PROC USES ECX
	; Local variables: userIntValue stores signed int value of user string,
	;				   negBoolean indicates if user string is negative or not
	LOCAL	userIntValue:SDWORD, negBoolean:BYTE

_getInput:
	MOV		userIntValue, 0			; Initialize starting value of userIntValue to 0
	MOV		negBoolean, 0			; Set negBoolean as false (0 = positive)
	mGetString	[EBP+12], [EBP+8]	; Invoke mGetString macro to prompt user and get input as string
	MOV		ECX, EAX				; EAX stores length of string, use to control loop counter

	CMP		EAX, 0					; Display error if user enters an empty string
	JE		_displayError

	CLD								; Clear direction flag to move forward through array
	MOV		ESI, [EBP+8]			; [EBP+8] = userString -> user input as string
	LODSB 
	CMP		AL, 45					; 45 = ascii code for - sign
	JE		_negBool				; If first char is -, jump to negBool code section
	CMP		AL, 43					; 43 = ascii code for + sign
	JE		_continueLoop			; If first char is +, it is valid -> continue to next char

_validateChar:
	mValidateChar					; Invoke mValidateChar macro to check if char is a valid digit
	MOVZX	EBX, AL					; Copy reg16 to larger reg32 to align the sizing
	IMUL	EAX, userIntValue, 10	; Use signed integer multiplication -> store userIntValue * 10 in EAX
	JO		_displayError			; If multiplication causes overflow, user input is invalid 
	MOV		userIntValue, EAX		; If no overflow, update userIntValue to product of multiplication
	CMP		negBoolean, 1			; Branch to _negative condition if negBoolean is set
	JE		_negative
	ADD		userIntValue, EBX		; If negBoolean is clear, add ascii value of char to userIntValue
	JO		_displayError			; If addition causes overflow, user input is invalid 
_continueLoop:
	LODSB							; Load next char of user string to the AL register for validation
	LOOP	_validateChar			
	JMP		_exit					; Exit procedure once user string has been fully validated

	; Conditional branch if negBoolean is set
_negative:
	SUB		userIntValue, EBX		; Subtract ascii value of char from userIntValue
	JO		_displayError			; If subtraction causes overflow, user input is invalid 
	JMP		_continueLoop

	; Conditional branch if first char of userString is -
_negBool:
	MOV		negBoolean, 1			; Set negBoolean to 1
	LODSB							; Load next char of user string to the AL register
	mValidateChar					; Invoke mValidateChar macro to check if char is a valid digit
	MOV		userIntValue, EAX		; If valid, set userIntValue variable to equal ascii value of digit
	NEG		userIntValue			; Negate userIntValue 
	SUB		ECX, 2					; Reduce the loop counter by 2 to account for 2 chars accounted for
	CMP		ECX, 0					; If count = 0, user string has been fully validated -> exit procedure
	JE		_exit
	LODSB							; Load next char of user string to the AL register for validation
	JMP		_validateChar
	
_displayError:
	mDisplayString	OFFSET errorMsg	; Invoke mDisplayString to print errorMsg string
	CALL	Crlf
	JMP		_getInput				; Re-prompt user for new input

_exit:
	MOV		EDX, [EBP+16]			; [EBP+16] = address of validNum variable
	MOV		EAX, userIntValue		
	MOV		[EDX], EAX				; Update value of validNum to value of userIntValue
	RET		12
readVal ENDP

; --------------------------------
; WRITE VALUE PROCEDURE
; Converts a numeric SDWORD value to a string of ascii digits and invokes the 
;	mDisplayString macro to print the ascii representation to the output
; preconditions: SDWORD variable passed on the stack is a valid signed integer
; postconditions: ECX, ESI, EDI are maintained; EAX, EBX, EDX are changed
; receives: Value of an SDWORD [EBP+8]
; returns: Prints the numeric SDWORD value as a string of ascii digits
; --------------------------------
writeVal PROC USES ECX ESI EDI
	; Local variables: numString stores string of ascii values representing SDWORD value in backwards order,
	;				   reverseString reverses the contents of numString, negBoolean indicates if SDWORD
	;				   is negative or not, stringCount holds the length of the SDWORD
	LOCAL	numString[STRINGSIZE]:BYTE, reverseString[STRINGSIZE]:BYTE, negBoolean:BYTE, stringCount:DWORD

	CLD							; Clear direction flag to move forward through array
	MOV		stringCount, 0		; Initialize stringCount to 0
	MOV		negBoolean, 0		; Clear the negBoolean (=0)
	LEA		EDI, numString		; Set EDI to numString to fill with ascii chars
	MOV		EAX, [EBP+8]		; Move SDWORD value parameter to EAX register
	CMP		EAX, 0
	JL		_negativeVal		; Branch if the SDWORD value is negative

_continue:
	; Divide EAX by 10 to isolate last digit of the SDWORD
	MOV		EDX, 0
	MOV		EBX, 10
	DIV		EBX

	ADD		EDX, 48			; Add 48 to the last digit to it to its ascii digit representation
	MOV		[EDI], DL		; Store the ascii value in the numString
	INC		EDI				; Move to next element location in negBoolean
	INC		stringCount		; Increment the stringCount
	CMP		EAX, 0			; If EAX is > 0, continue the loop until every digit in SDWORD has been converted
	JA		_continue
	CMP		negBoolean, 0	; If negBoolean is clear, move on to reverse negBoolean as is
	JE		_reverseString
	MOV		DL, 45			; Otherwise, 45 = ascii code for - sign
	MOV		[EDI], DL		; Add ascii value for negative sign so the string displays with a leading -
	INC		stringCount
	JMP		_reverseString

	; If the SDWORD value is negative, turn it positive and set negBoolean (=1)
_negativeVal:
	NEG		EAX
	MOV		negBoolean, 1
	JMP		_continue

	; Reverse the contents of numString (ESI) to reverseString (EDI)
	; in order to put the ascii chars back in proper order
_reverseString:
	MOV		ECX, stringCount	; Set loop counter to length of the string/SDWORD
	LEA		ESI, numString
	ADD		ESI, ECX
	DEC		ESI
	LEA		EDI, reverseString
_revLoop:
    STD							; Set direction flag to move backward through numString
    LODSB
    CLD							; Clear direction flag to move forward through reverseString
    STOSB
	LOOP	_revLoop
	MOV		AL, 0				; Null-terminate the reverseString array
	MOV		[EDI], AL
	LEA		EDI, reverseString
	mDisplayString EDI			; Print the the ascii representation of the SDWORD

	RET		4
writeVal ENDP

END main
