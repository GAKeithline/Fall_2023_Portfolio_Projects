TITLE -Redacted-    (Proj6_keithlig.asm)

; Author: Gilbert Keithline
; Last Modified: 12/18/2023
; OSU email address: keithlig@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 12/20/2023
; Description: Program accepts 10 numeric values from the user in the form of ASCII strings. The ASCII characters are then converted into
;			   their equivalent numeric values which are then used to calculate the sum and truncated average of the values. The original numeric values are
;			   then converted back to ASCII, along with the sum and average, and displayed to the user. All input values are accepted exclusively
;			   by using the mGetString macro, and all values are displayed back to the user exclusively by using the mDisplayString macro.
;			   This program features two procedures, readVal and writeVal, that are designed to work in conjunction with the aforementioned macros
;			   to accept the user inputs, convert the values from ASCII, perform arithmatic, convert the values back to ASCII, and display back to the user. 
;			   All values entered and displayed must fit into a 32-bit register or a programmed 'error' will occur.
;			   Program also features a procedure, getMean, that serves as a helper function to generate the truncated average without cluttering up main PROC.

INCLUDE Irvine32.inc

;------------------------------------------------------------------------------------------------------------
; Name: mDisplayString
;
; Accepts a string offset and displays the string at that locaiton to the user
;
; Recieves: 
;			'someString' is a string offset
;------------------------------------------------------------------------------------------------------------
	mDisplayString	MACRO	someString
		PUSH	EDX							
		MOV		EDX,	someString
		CALL	WriteString
		POP		EDX							
	ENDM

;------------------------------------------------------------------------------------------------------------
; Name: mGetString
;
; Displays a prompt (prompt) to the user before accepting a string input (userInput) of a predetermined length
; (inputCount). The length of the input is saved to a preinitialized locaiton in the .data segment (inputLength)
;
; Recieves: 
;			'prompt' is the location of a string
;			'userInput' is the location of an empty byte array
;			'inputCount' is a numeric value denoting the maximum allowed length of the input string
;			'inputLength' is an empty DWORD
;
; Returns:
;			'userInput' will contain the string input from the user
;			'inputLength' will reflect the length of the user input
;------------------------------------------------------------------------------------------------------------
	mGetString	MACRO	prompt, userInput, inputCount, inputLength
		PUSH	EDX
		PUSH	ECX
		PUSH	EAX
		MOV		EDX, prompt					; this is essentially the 'get input' block from the Mod8Ex1 video 
		CALL	WriteString
		MOV		EDX, userInput
		MOV		ECX, inputCount
		CALL	ReadString
		MOV		inputLength, EAX
		POP		EAX
		POP		ECX
		POP		EDX
	ENDM
;----------------------------------------------------------------------

	;Constants
	MAX_INPUT_LENGTH	= 13
	LENGTH_MINUS_NULL	= 12
	INPUT_MAX			= 10
	ASCII_CEILING		= 57
	ASCII_FLOOR			= 48
	POSITIVE			= 43
	NEGATIVE			= 45

	BIG_FOUR			= 4
	BIG_ONE				= 1
	BIG_ZERO			= 0
	BIG_NEGATIVE		= -1



.data

	;introduction and instruction data
	titleAndAuthor			BYTE	'		String Primitives and Macros   '
							BYTE	'by: Gilbert (Alex) Keithline',13,10,10,0
	instructions			BYTE	'Please enter 10 signed decimal integers.',13,10
							BYTE	'The numbers entered must be able to fit within a 32 bit register (range -2147483647 to 2147483647).',13,10
							BYTE	'Once all 10 signed integers have been entered, I will return you a list of the integers, their sum, and their truncated average.',13,10,10,0

	;strings and prompts
	integerPrompt			BYTE	'Please enter a signed integer: ',0
	errorPrompt				BYTE	'Your input was either not a signed integer or was too big to fit in a 32 bit register. Please try again.',13,10,0
	sumError				BYTE	'The current sum of your integers exceeds the limit of a 32-bit register. Please try a different number.',13,10,0
	numberString			BYTE	13,10,'You entered the following numbers:',13,10,0
	sumString				BYTE	13,10,'The sum of your numbers is: ',0
	averageString			BYTE	13,10,'The truncated average of your numbers is: ',0
	sayGoodbye				BYTE	'Thank you for checking out my program! Bye now.',13,10,0
	commaSpace				BYTE	', ',0

	;empty strings for value conversion
	userInput				BYTE	14	DUP(?)
	userOutput				BYTE	14	DUP(?)
	conversionString		BYTE	14  DUP(?)

	;empty array and DWORDs
	userNumbers				SDWORD	INPUT_MAX	DUP(?)
	inputLength				DWORD	?
	negativeFlag			DWORD	0
	sum						SDWORD	0
	mean					SDWORD	?
	



.code
main PROC
		

	;--------------------------------------------
	;introduction call using DisplayString macro
	;--------------------------------------------
		mDisplayString	OFFSET	titleAndAuthor
		mDisplayString	OFFSET	instructions

	;-------------------------------------------
	;Prepare counting loop and destination 
	;register to recieve user input
	;-------------------------------------------
		MOV		ECX, INPUT_MAX
		MOV		EDI, OFFSET userNumbers

	;--------------------------------------------
	;Push necessary offsets/values and execute
	;the readVal procedure ten times
	;--------------------------------------------
		_getVals:
		PUSH	OFFSET sumError
		PUSH	OFFSET sum
		PUSH    OFFSET negativeFlag
		PUSH	OFFSET errorPrompt
		PUSH	EDI
		PUSH	OFFSET integerPrompt
		PUSH	OFFSET userInput
		PUSH	MAX_INPUT_LENGTH
		PUSH	OFFSET inputLength
		CALL	readVal
		ADD		EDI, BIG_FOUR
		LOOP	_getVals

	;-------------------------------------------
	;Place truncated average of user inputs into 
	;'mean' by executing getMean procedure
	;-------------------------------------------
		PUSH	OFFSET mean
		PUSH	OFFSET sum
		CALL	getMean

	;-------------------------------------------
	;Prepare counting loop and source register 
	;to display user input. Display info string.
	;-------------------------------------------
		MOV		ECX, INPUT_MAX
		MOV		ESI, OFFSET userNumbers

		mDisplayString offset numberString
	
	;-------------------------------------------
	;Push necessary offsets/values and execute
	;the writeVal procedure ten times
	;-------------------------------------------
		_showVals:
		PUSH	OFFSET conversionString
		PUSH	OFFSET userOutput
		PUSH	ESI
		CALL	writeVal
		CMP		ECX, BIG_ONE												; ommits last value from having a comma
		JZ		_next
		mDisplayString offset commaSpace									; inserts a string and comma after each value displayed re: '1, 2, 3'
		ADD		ESI, BIG_FOUR
		LOOP	_showVals

	;-------------------------------------------
	;Convert and display sum of user input using
	;writeVal
	;-------------------------------------------
		_next:
		mDisplayString OFFSET sumString
	
		PUSH offset conversionString
		PUSH offset userOutput
		PUSH offset sum
		CALL writeVal

	;-------------------------------------------
	;Convert and display average of user input 
	;using writeVal
	;-------------------------------------------
		mDisplayString offset averageString

		PUSH offset conversionString
		PUSH offset userOutput
		PUSH offset mean
		CALL writeVal

	;-------------------------------------------
	;Display goodbye string using DisplayString
	;macro
	;-------------------------------------------
		CALL CrLf
		CALL CrLf
		mDisplayString	OFFSET sayGoodbye

	
	
	Invoke ExitProcess,0	; exit to operating system
main ENDP


;------------------------------------------------------------------------------------------------------------
; Name: readVal
;
; Accepts string of numbers from the user using mGetString. Converts each string input from ASCII to decimal
; values and stores those values in an SDWORD array. readVal also keeps a running sum count of each value entered.
; If any entered values are too large or too small to fit in a 32 bit register, or if the sum should become to large
; or too small to fit in a 32 bit register, an error message is displayed and the user is prompted for a new value.
; After accepting and storing an input, or after an error is detected, the input string is cleaned and reset to 0
; for next use.
;
; Preconditions: 
;			BIG_ZERO, BIG_ONE, LENGTH_MINUS_NULL, NEGATIVE, POSITIVE, ASCII_FLOOR, and ASCII_CEILING are constants
;			
;
; Recieves: 
;			[EBP + 32] refers to an unsigned integer DWORD
;			[EBP + 36] refers to a constant
;			[EBP + 40] refers to the first element of a BYTE array (string)
;			[EBP + 44], [EBP + 56], and [EBP + 68] refer to a string offset
;			[EBP + 52] refers to a location in an SDWORD array passed via pushing EDI
;			[EBP + 60] and [EBP + 64] refer to signed integer SDWORDS
;			
; Returns:
;			[EBP + 52] will refer to the location of an SDWORD integer within an array
;------------------------------------------------------------------------------------------------------------
readVal PROC	USES EAX EBX ECX EDX ESI EDI								; maybe PUSHAD using too much stack space? Try 'uses'
		PUSH	EBP																;Update: it was not PUSHAD but now I don't want to go correct all the base+pointer addresses
		MOV		EBP, ESP
		
	_getValue:
		MOV			EBX,	[EBP + 32]
		mGetString			[EBP + 44], [EBP + 40], [EBP + 36], [EBX]		; make sure to assign EBP+32 to a register and then use the [reg] format to properly place the value
	
	;-----------------------------------
	; Check user input for length and 
	; valid characters. Set user-made
	; sign flag if value is negative.
	; Trigger an error if any checks fail.
	;-----------------------------------
	;check len
		MOV			ECX,	[EBX]											; Had to expand the size of the inputString to account for signs, but this length checker should render that moot
		PUSH		ECX
		PUSH		ECX														; double push ECX for two separate calls much later in the procedure
		CMP			ECX,	BIG_ZERO
		JE			_asciiError	
		CMP			ECX,	LENGTH_MINUS_NULL
		JGE			_asciiError

	;load character
		MOV			ESI,	[EBP + 40]										; Source is the userInput byte array
		CLD
		LODSB

	;look at sign
		CMP			AL,		POSITIVE										
		JE			_nextChar
		CMP			AL,		NEGATIVE
		JE			_makeNeg
		JMP			_asciiCheck

	_makeNeg:
		PUSH		EBX
		PUSH		EAX
		MOV			EAX,	BIG_ONE
		MOV			EBX,	[EBP + 56]										; EBP+60 refers to an unsigned DWORD initialized at 0
		MOV			[EBX],	EAX
		POP			EAX
		POP			EBX
		JMP			_nextChar

	_asciiCheck:
		CMP			AL,		ASCII_FLOOR
		JL			_asciiError
		CMP			AL,		ASCII_CEILING
		JG			_asciiError												
		JMP			_nextChar

	_nextChar:
		DEC			ECX									
		CMP			ECX,	BIG_ZERO										; if final character, move to math
		JE			_convertToInt
		MOV			EAX,	BIG_ZERO										; gotta initialize EAX to zero for each grab. This caused me a lot of headaches
		CLD
		LODSB
		JMP			_asciiCheck

		
	;-----------------------------------
	; Mathematically converts characters
	; from ASCII representation to integers.
	; Places converted integers into an
	; SDWORD array, and keeps a running sum
	; of each integer converted.
	;-----------------------------------
	_convertToInt:
		POP			ECX														; pull original inputLength to count string
		MOV			EDI,	[EBP + 48]										; destination will be userNumbers array
		MOV			ESI,	[EBP + 40]										; source is our userInput string

	;initialize regs for ascii math
		MOV			EBX,	BIG_ZERO
		INC			ECX														; this little step made it easier to write the following decrementing loop

	_decCount:
		DEC			ECX

	_loadChar:
		MOV			EAX,	BIG_ZERO										; initially tried to account for little endianness by loading values backwards (std) and reading the sign last.
		CLD																		; After fighting several bugs, I chose to engage a sign flag variable and resimplify this section back to CLD
		LODSB
		
	;check sign
		CMP			AL,		NEGATIVE										; if there is an ASCII + or -, simply move to next character. Math conversion obviously won't work on them
		JE			_decCount
		cmp			AL,		POSITIVE
		JE			_decCount							
		
	;math time
		PUSH		EBX														; formula for ASCII to Int conversion found in Module 8, Exploration 1
		SUB			EAX,	ASCII_FLOOR										; subtract 48
		PUSH		EAX
		MOV			EAX,	EBX
		MOV			EBX,	INPUT_MAX
		IMUL		EBX														; multiply by 10
		JO			_overflowError
		MOV			EDX,	EAX
		POP			EAX
		POP			EBX
		ADD			EAX,	EDX												; add to previous total
		MOV			EBX,	EAX

		LOOP		_loadChar
		
	;-----------------------------------
	; Checks user-made sign flag. If set,
	; negates the converted value
	;-----------------------------------
	_signcheck:
		PUSH		EDX
		PUSH		EAX
		MOV			EAX,	[EBP + 56]
		MOV			EDX,	[EAX]
		POP			EAX
		CMP			EDX,	BIG_ZERO
		JZ			_saveInt
		NEG			EBX
	
	;-----------------------------------
	; Saves newly converted value to 
	; SDWORD array
	;-----------------------------------
	_saveInt:
		POP				EDX
		MOV				[EDI],	EBX

	;-----------------------------------
	; Adds value to running sum (initial
	; SDWORD value 0). Triggers an error
	; if the value of the sum exceeds a
	; 32-bit register
	;-----------------------------------
	_runningSum:
		MOV			EBX,	[EBP + 60]
		MOV			EAX,	[EDI]
		ADD			EAX,	[EBX]
		JO			_sumError
		MOV			[EBX],	EAX
		JMP			_sumCheck

	;-----------------------------------
	; A series of error responses that 
	; pop values off the stack based on 
	; where the error was encountered, 
	; display a message to the user, clean
	; the input string, and return to 
	; _getValue.
	;-----------------------------------
	_asciiError:
		POP			ECX
		POP			ECX
		mDisplayString		[EBP + 52]											; EBP+56 is the offset of an error string
			; scrub input string
			INC			ECX
			MOV			EDI,	[EBP + 40]
		_cleanErrorString:														; since all of the error messages clean their string after the necessary stack pops, this one loop can be called by all three.
			MOV			EAX,	BIG_ZERO
			STOSB
			LOOP		_cleanErrorString
			JMP			_getValue

	_overflowError:
		POP			EAX
		POP			EBX
		POP			ECX
		mDisplayString		[EBP + 52]

			INC			ECX
			MOV			EDI,	[EBP + 40]
			JMP			_cleanErrorString

	_sumError:
		POP			ECX
		mDisplayString		[EBP + 68]											; EBP+68 is the offset of an error string
		
			INC			ECX
			MOV			EDI,	[EBP + 40]
			JMP			_cleanErrorString
	
	;-----------------------------------
	; Final check that the Sum fits within
	; a 32-bit register
	;-----------------------------------
	_sumCheck:
		MOV			ECX,	BIG_ONE
		IMUL		ECX
		JO			_sumError

	;-----------------------------------
	; Reset sign flag and input string
	;-----------------------------------
	;clear the sign flag for next value
		MOV			EBX,	[EBP + 56]
		MOV			EAX,	BIG_ZERO
		MOV			[EBX],	EAX

	;clean input string for next value
		POP			ECX
		INC			ECX
		MOV			EDI,	[EBP + 40]

	_cleanInString:
		MOV			EAX,	BIG_ZERO
		STOSB
		LOOP		_cleanInString
		

	_end:
		POP	EBP
		RET 40
readVal ENDP

;------------------------------------------------------------------------------------------------------------
; Name: writeVal
;
; Accepts an SDWORD integer value from memory and mathematically converts the value to ASCII format.
; ASCII string is then loaded into an empty output BYTE array and displayed to the user with mDisplayString macro.
; Once value is converted and displayed, output and 'holder' BYTE arrays are cleared for next use.
;
; Preconditions: 
;			BIG_ZERO, BIG_ONE, INPUT_MAX, NEGATIVE, and ASCII_FLOOR are constants
;			
;
; Recieves: 
;			[EBP + 40] refers to a location in an SDWORD array passed via pushing ESI
;			[EBP + 44] and [EBP + 48] refer to the first element of an empty BYTE array (string)
;
; Returns:
;			Nothing. All strings used are reset for future use.
;------------------------------------------------------------------------------------------------------------
writeVal PROC
		PUSHAD
		PUSH	EBP
		MOV		EBP, ESP
		
		MOV			EDI,	[EBP + 44]											; destination will be the userOutput string
		MOV			EBX,	[EBP + 40]											; need the value stored in the userNumbers array, move it to EAX
		MOV			EAX,	[EBX]
		MOV			ECX,	BIG_ONE

	;-----------------------------------
	; Check to see if value is negative.
	; If so, negate (two's complement) the
	; value and store a negative sign in
	; output. If not negative, pass.
	;-----------------------------------
		CMP			EAX,	BIG_ZERO
		JGE			_swapEDI
	
	;negate value and store neg sign
		NEG			EAX
		PUSH		EAX
		CLD
		MOV			AL,		NEGATIVE
		STOSB
		POP			EAX
	
	;-----------------------------------
	; Push current EDI location to stack
	; and place the 'holder string' location
	; into EDI for conversion
	;-----------------------------------
	_swapEDI:
		PUSH		EDI
		MOV			EDI,	[EBP + 48]											; EBP+48 is the location of our holder string

	;-----------------------------------
	; Convert numeric character to ASCII.
	; Divide by 10 until EAX is 0, store
	; the final remainder.
	;-----------------------------------
	_convertToASCII:
		MOV			EBX,	INPUT_MAX
		CDQ
		IDIV		EBX

		ADD			EDX,	ASCII_FLOOR
		PUSH		EAX
		MOV			EAX,	EDX
		STOSB
		POP			EAX
		CMP			EAX,	0
		JE			_final
		INC			ECX															; Build the length of the value for string reversal and cleaning
		JMP			_convertToASCII

	;-----------------------------------
	; Place now converted 'holder string'
	; into ESI and restore EDI as the 
	; output string. Increment ESI to the 
	; end of the string since values were 
	; stored in reverse.
	;-----------------------------------
	_final:
		MOV			ESI,	[ebp + 48]
		ADD			ESI,	ECX
		POP			EDI
		DEC			ESI
		PUSH		ECX															; Hold onto ECX for string cleaning at end of PROC

	;-----------------------------------
	; Load from the end of holder string 
	; and store to the front of the output
	; string.
	;-----------------------------------
	_populate:																	; this is essentially the 'reverse string' block from the Mod8Ex1 video 
		MOV			EAX,	BIG_ZERO
		STD
		LODSB
		CLD
		STOSB
		LOOP		_populate

	;-----------------------------------
	; Display newly converted string to
	; user with mDisplayString macro
	;-----------------------------------
		mDisplayString			[EBP + 44]

	;-----------------------------------
	; Reset 'holder' and output strings
	; back to 'empty' so no unwanted 
	; characters appear in later uses of 
	; this procedure.
	;-----------------------------------
		POP			ECX
		INC			ECX
		PUSH		ECX
		MOV			EDI,	[ebp + 48]

	_cleanConversionString:
		MOV			EAX,	BIG_ZERO
		STOSB
		LOOP		_cleanConversionString

		POP			ECX
		INC			ECX
		MOV			EDI,	[EBP + 44]

	_cleanOutString:
		MOV			EAX,	BIG_ZERO
		STOSB
		LOOP		_cleanOutString


		POP EBP
		POPAD
		RET 12
writeVal ENDP

;------------------------------------------------------------------------------------------------------------
; Name: getMean
;
; Accepts an SDWORD value and divides it by 10. The truncated value (EAX) is then saved to a different
; uninitialized SDWORD value in .data.
;
; Preconditions: 
;			INPUT_MAX is a constant
;			
;
; Recieves: 
;			[EBP + 40] refers to the location of an SDWORD value
;			[EBP + 44] refers to the locaiton of an uninitialized SDWORD value
;
; Returns:
;			[EBP + 44] will refer to the location of the quotient of the value stored at [EBP + 40] divided by ten.
;------------------------------------------------------------------------------------------------------------
getMean PROC
		PUSHAD
		PUSH	EBP
		MOV		EBP, ESP

		MOV			EBX,	[EBP + 40]
		MOV			EAX,	[EBX]
		MOV			EBX,	INPUT_MAX
		CDQ
		IDIV		EBX
		MOV			EDI,	[EBP + 44]
		MOV			[EDI],	EAX

		POP EBP
		POPAD
		RET 8
getMean ENDP
;--------------------------------------------------------------------------


END main
