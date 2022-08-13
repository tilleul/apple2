# Code Bookmarks in Applesoft

## Introducing the concept of bookmarks in code
This is a proof-of-concept based on a simple idea: the values of string variables are referenced by pointers to locations inside the Applesoft tokenized code. 

Using these pointers, it should be possible to reference "bookmarks" (locations) inside the Applesoft code and jump to these bookmarks with an `&` subroutine.

For example, type
```basic
NEW
10 A$ = "HELLO": PRINT A$
RUN
CALL-151
7FF (and press return at least 5 times)
```
This lists the following:
```
0800: 00 14 08 0A 00 41 24 D0
0808: 22 48 45 4C 4C 4F 22 3A
0810: BA 41 24 00 00 00 41 80
0818: 05 09 08 00 00
```
Bytes \$801 to \$813 is the tokenized line 10.
```
0801: 14 08			 	; the next line (if any) will be found in $0814
0803: 0A 00     	 	; this line is line number 10 ($000A)
0805: 41 24	    	 	; A$
0807: D0			 	; =
0808: 22			 	; " (double-quote)
0809: 48 45 4C 4C 4F 	; HELLO
080E: 22				; " (double-quote)
080F: 3A				; : (colon)
0810: BA				; Token for PRINT statement
0811: 41 24				; A$
0813: 00				; 00 marks the end of the line
```
Bytes \$814-\$815 indicate the end of the program (two zero bytes)
Bytes \$816-\$81C is the simple variables table and in this case it describes `A$`:
```
0816: 41				; Character 'A' (first letter of the variable's name)
0817: 80				; Second letter of the variable's name but with hi-bit set to indicate as string variable.
						  As in this case, there's no second letter, the value is $80 (zero with the hi-bit set)
0818: 					; length of the string
0819: 09 08 			; pointer to the variable's value ($0809)
081B: 00 00				; unused bytes
```
And surely enough, in $0809, we can find the string value coded on 5 bytes:
```
0809: 48 45 4C 4C 4F 	; HELLO
```
The pointer to \$809 will point to this location until another `A$="..."` statement is found in the code, and accordingly the pointer will point to this new location.

>The pointer will reference a location *within the code* as long as the contents of `A$` is a constant. If the contents of `A$` are calculated (as the result of string concatenation (`A$ = "HELLO" + "GOODBYE"`), string extraction (`A$ = LEFT$("HELLO", 4)`) or string conversion (`A$ = STR$(12345)`) then the pointer will reference a location between FRETOP (a value in zero page stored in \$6F-\$70) and MEMSIZ (whose value is in zero page too at \$73-\$74).

>Also, if a new variable is created and that it is set equal to A$ (like `B$=A$`) then the pointer for the newly created variable will have the same value as the one for `A$`. If the contents of `A$` is subsequently changed, then `A$` will point to a new location while `B$` will still point to the location of the previous `A$`.

Now that we have a pointer in the code **AND** the length of the string it points to, we can use both these to point to the next instruction **after** the initialisation of A\$ in line 10. In our case that is:

```basic
: PRINT A$
```
(notice the colon)
or, as found in $080F
```
080F: 3A BA 41 24 00			
```
To reach that location, all we have to do is add the value of the pointer ($0809) to the length of the variable plus one: $0809 + 5 + 1 = $080F.

This value has to be injected in the current location being parsed by Applesoft. This value is in TXTPTR (zero page \$B8-\$B9 within the CHRGOT routine).

Also, we need to set CURLIN (a value in zero page representing the current line number the Applesoft parser is in). It's not essential as it's only used to print the line number in case of error but we want to be thorough.

In order to find the current line number, all we have to do is search backwards from $080F until we find a "00" which indicates the end of the previous line. The trick is that this "00" could also be part of the line number if the line number is below 256. So another check is made 4 bytes earlier: if we find another "00" there then what we had was a part of a line number below 256. If not, it really was the end of the previous line. From there we read the actual line number and store it in CURLIN.

## What are bookmarks good for ?

Using bookmarks is interesting, it's like a GOTO that goes back to a line previously parsed but with at least two advantages:
1. Speed. Searching the variable's table for a pointer is much more faster than searching for a line number, particularly because you probably have many more lines than variables and because the GOTO/GOSUB algorithm in Applesoft is so bad <sup>(*)</sup>.
2. You can go back in the middle of a line of code. GOTO allows you to go back to the **beginning** of a line, not **anywhere** in the line.
3. It can be used with **any** string variable of course.

<sup>(*) In fact, searching for a line is almost as fast as searching for a variable (55-65 cycles) but searching for variables from the list is faster simply because there are less variables in your code than there are lines (99.99% of the time). </sup>

<sup>Searching for lines is also slower because when you use GOTO/GOSUB you'll either search from the next line in your code or from the very first line. You'll search from the next line in your code **only and only if** the line you search for has a number that is at least the next multiple of 256 in your program. Most of the time it's not the case. This is why the Applesoft ][ User Manual suggest you GOTO line numbers at the start of your code.</sup>

It has some drawbacks too:

1. You can only go back on a line that's been parsed before, otherwise the variable won't be found in the table and so you'll have nowhere to go. There might be some ways to circumvent this, though.
2. You have to be careful to not mess with the variables you use as bookmarks. If you change the value of A$ later in the code, this is the location where the bookmark will be placed, from now on. Also you need to make sure you don't compute the value of A$ as this will bookmark a location outside of the code.

## Alpha implementation
Here's a basic implementation of what's been said so far ... it's only a first draft, it might need optimization and improvement, we'll see about that later, it's only a proof of concept.

The idea is that you can GOTO back to a bookmark with a command like `& A$`. Later this should be improved to use the `GOTO/GOSUB` command like `& GOTO A$`. But it's for later ...

The following does not handle pointers outside the tokenized code ... yet.

```assembly
		amper_vector	equ	$03f5	
		frmevl			equ	$dd7b	
		chkstr			equ	$dd6c	
		varpnt			equ	$83	
		txtptr			equ	$b8	
		chrgot			equ	$b7	
		ptrget			equ	$dfe3	
		oldlin			equ	$77	
		curlin			equ	$75	
		underr			equ	$d97c			undefined statement error
					
						org	$300
					
		
300: A9 4C				lda	#$4c			prepare amper vector JMP $start
302: 8D F5 03			sta	amper_vector	
305: A9 10				lda	#<start	
307: 8D F6 03			sta	amper_vector+1	
30A: A9 03				lda	#>start	
30C: 8D F7 03			sta	amper_vector+2	
30F: 60					rts		
		start			
310: 20 E3 DF			jsr	ptrget	
313: 20 6C DD			jsr	chkstr			check if string AND set carry !
316: A0 00				ldy	#0	
318: B1 83				lda	(varpnt),y		length
31A: 8D 21 03			sta	.offset+1		self modifying code
						
31D: C8					iny		
31E: B1 83				lda	(varpnt),y	
						
320: 69 00		.offset	adc	#$00			add WITH carry SET ! (=length+1)
322: 85 B8				sta	txtptr	
324: 85 77				sta	oldlin	
326: C8					iny		
327: B1 83				lda	(varpnt),y	
329: F0 12				beq	.underr			if zero then variable has just been created
32B: 69 00				adc	#$00			add carry to pointer hi
32D: 85 B9				sta	txtptr+1	
32F: AA					tax					now we search the line number
330: CA					dex		
331: 86 78				stx	oldlin+1	
333: A0 FF				ldy	#$ff	
335: B1 77		.loop	lda	(oldlin),y	
337: F0 07				beq	.out	
339: 88					dey		
33A: D0 F9				bne	.loop	
33C: 60			.rts	rts					we arrive here if y=0. We have scanned 255 chars and
33D: 4C 7C D9	.underr	jmp	underr			failed finding a zero. It's impossible as lines entered
											with keyboard are max 239 chars, And tokenized it's less
340: 8C 4C 03	.out	sty	.save_y+1		save y
343: 88					dey					y is of course above 3, so we can dey 4 times
344: 88					dey		
345: 88					dey		
346: 88					dey		
347: B1 77				lda	(oldlin),y		get byte 4 positions earlier
349: F0 02				beq	.save			if it's zero, then we found the end of the previous line
34B: A0 00		.save_y	ldy	#$00			we didn't find a zero, restore previous y
34D: C8			.save	iny					advance to next line
34E: C8					iny					skip ptrl to next line
34F: C8					iny					skip ptrh
350: B1 77				lda	(oldlin),y	
352: 85 75				sta	curlin	
354: C8					iny		
355: B1 77				lda	(oldlin),y	
357: 85 76				sta	curlin+1	
359: 60					rts		
```

To test the code, type the following
```
CALL-151
300: A9 4C 8D F5 03 A9 10 8D F6 03 A9 03 8D F7 03 60
310: 20 E3 DF 20 6C DD A0 00 B1 83 8D 21 03 C8 B1 83
320: 69 00 85 B8 85 77 C8 B1 83 F0 12 69 00 85 B9 AA
330: CA 86 78 A0 FF B1 77 F0 07 88 D0 F9 60 4C 7C D9
340: 8C 4C 03 88 88 88 88 B1 77 F0 02 A0 00 C8 C8 C8
350: B1 77 85 75 C8 B1 77 85 76 60

(press CTRL-C + return, going back to basic)

CALL 768 (to initiate & vector)
NEW
10 A$ = "HELLO": PRINT "THIS IS LINE 10 - A$="; A$; " - N=";N
20 N=N+1: IF N=1 THEN & A$
30 A$ = "GOODBYE": PRINT "THIS IS LINE 30 - A$="; A$; " - N=";N
40 N=N+1: IF N = 2 THEN & A$
50 B$ = A$: PRINT "B$=A$ NOW !": A$ = "HOORAY !": PRINT "THIS IS LINE 50 - A$="; A$; " - B$="; B$; " - N=";N
60 N = N + 1: IF N = 3 THEN & A$
70 IF N= 4 THEN & B$
80 PRINT "THIS IS THE END"
RUN
```
The output should be
```
THIS IS LINE 10 - A$=HELLO - N=0
THIS IS LINE 10 - A$=HELLO - N=1
THIS IS LINE 30 - A$=GOODBYE - N=2
B$=A$ NOW !
THIS IS LINE 50 - A$=HOORAY ! - B$=GOODBYE - N=3
THIS IS LINE 30 - A$=HOORAY ! N=4
B$=A$ NOW !
THIS IS LINE 50 - A$=HOORAY ! - B$=GOODBYE - N=5
THIS IS THE END
```

I hope to improve this code in many ways:
- use GOTO/GOSUB keywords and actually support `GOSUB`
- support bookmarks that have not been parsed yet. This could be done with something like `& GOTO A$, 20`. This would **try** to go to the bookmark `A$`, but if it has not been parsed yet (or more exactly if `A$` does not exist yet), it will (1) create the variable `A$` and (2) search from line 20 for the code `A$="`. Once found, the pointer to `A$` (+ its length !) is modified accordingly. The next `& GOTO` to `A$` would then use the modified values.
- support `ON >expr< GOTO/GOSUB` as well as `ONERR GOTO`.
- support `GOTO/GOSUB >expr<`: if the code after GOTO/GOSUB is not a string variable, consider it a float  `>expr<` and resolve to a line number and go to the next case
- support `GOTO/GOSUB >line number<` and use a better algorithm than Applesoft's. 
	- If the line number is equal to the current line, search for the current line start and go from there
	- if the line number is above the current line, search from the next line (Applesoft only search from the next line if the line to search is above or equal to the next multiple of 256).
	- if the line number is below the current line, search from the first line of the program. Exception: if it's statistically faster to search backwards from the current line, this approach should be used.
