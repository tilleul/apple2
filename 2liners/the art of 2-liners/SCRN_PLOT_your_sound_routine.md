# Introduction
This aricle will explain a new (?) technique to poke subroutines using Applesoft (without using POKEs at ALL :D ) and actually spare several characters if you're into 2-liners.

## Generating various sounds in 2-liners.
Using a sound generating routine, we are going to see different techniques to interface assembly routines with Applesoft in the context of 2-liners.

The routines will be taken of the book "Assembly Lines" by Roger Wagner. The book is available freely as a PDF. It is a goldmine. I'm not sure if this is legal or not but whatever, here's the link to download a copy.
https://archive.org/details/AssemblyLinesCompleteWagner/mode/2up

### How it usually works
We all know that the speaker of the Apple II is rather limited. What's worse is that there's no way in Applesoft to generate other sounds than
- a beep, using ``PRINT CHR$(7)``
- a click, by accessing address 49200, for example using a ``PEEK`` or a ``POKE``

The latest technique is called 1-bit sound. It sends a voltage signal to the Apple speaker that will just produce a click because it has been "activated". It is 1-bit because it's either on or off: we're sending voltage or not.

To generate different tones we need to activate the speaker in two nested loops. The inner loop controls the pitch while the outer loop controls the duration ... 
This is usually done with some 6502 using delays between accesses to memory 49200 ($C030) ...

One of those routines is provided in Assembly Lines book by Roger Wagner (p. 57).

The routine is the following:
```
0300- A6 07     LDX $07     ; load value in X from byte $07 as duration
0302- A4 06     LDY $06     ; load value in Y from byte $06 as pitch 
0304- AD 30 C0  LDA $C030   ; activate the "speaker"
0307- 88        DEY         ; decrement the pitch value
0308- D0 FD     BNE $0307   ; until it reaches zero
030A- CA        DEX         ; decrement the duration
030B- D0 F5     BNE $0302   ; until it reaches zero
030D- 60        RTS         ; all done
```

Usage from Applesoft is then the following:
```POKE 6, P: POKE 7, D: CALL S```

Where P is the "pitch" and D is the duration ...

## Integration with Applesoft: the regular way
But if we want this routine available for Applesoft, we have to either load it from disk (which is not allowed in a 2-liner) or to POKE it into memory before usage.
Like this:
```
10 S=768: FOR L = 0 TO 13 : READ V : POKE S+L ,V : NEXT L: REM 38 + 1 character (":")
20 DATA 166, 7, 164, 6, 173, 48, 192, 136, 208, 253, 202, 208, 245, 96:  REM +53 chars = 92 chars
```

As you can see, this takes 92 characters if we were to use it in a 2-liner ... 
And each call to generate a sound would take 21 additional characters assuming we use variables for pitch and duration:
``POKE 6,P : POKE 7,D : CALL S``

## Integration with Applesoft: relocation of routine in page zero
Can this be reduced ?
Well, first we could relocate it in page zero ... after all, it's only 14 bytes ... of course this all depends on what you need in page zero.
For example, bytes $34-$4F are used by Monitor, it is doubtful you have a need for it (but who knows) ... this would result in, 
for example (not all memory location work):
10 FOR L = 60 TO 73 : READ V : POKE L,V : NEXT L:  REM 31+1 chars
20 DATA 166, 7, 164, 6, 173, 48, 192, 136, 208, 253, 202, 208, 245, 96:  REM +53 chars = 85 chars
Each call to generate a sound would take 22 additional characters (because we didn't store the calling address in S)

But this is still a lot of bytes just to emit an interesting (?) sound ...
The main problem is the data we have to poke ... it ranges from 0 to 255 ...
It means, in basic, values above 99 will take triple the space needed !
The DATA line, if we omit "DATA" is 49 characters long for only 14 bytes !
Hexadecimal representation of bytes take only two characters, so it would be only 28 characters in the end. This is the way to explore/experiment.

There are ways to send monitor commands via Applesoft but even the monitor does not accept less than 3 characters per byte, that is two characters for the byte + one space like "300:16 07 14 06 AD 30 C0 88 D0 FD CA D0 F5 60".
Such a program would be like this (see http://nparker.llx.com/a2/shlam.html for more info)

100 A$="300:A6 07 A4 06 AD 30 C0 88 D0 FD CA D0 F5 60 N D823G": REM  58+1 chars
110 FOR X=1 TO LEN(A$): POKE 511+X,ASC(MID$(A$,X,1))+128: NEXT: REM +52+1 chars = 112 chars
120 POKE 72,0: CALL -144 : REM + 17 chars = 129 chars

As you can see, this is worse !

The simple fact that we need 3 characters to "express" one byte is intolerable ...
What if we could use hexadecimal (without spaces) right in Applesoft code ?
Here's a possibility:
The technique here is a double trick: first it uses the string stored in A$ directly from the Applesoft code (in $800), reading the bytes in A$ as stored in the program in $809 (decimal 2057).
The second trick is that A$ contains "coded" hexadecimal code. An "A" equals to a "0" and a "P" equals to an "F" (ascii of "A" + 15).
0->A, 1->B, 2->C, 3->D, 4->E, 5->F, 6->G, 7->H, 8->I, 9->J, A->K, B->L, C->M, D->N, E->O, F->P

So, A6 07 A4 06 AD 30 C0 88 D0 FD CA D0 F5 60 translates to KG AH KE AG KN DA MA II NA PN MK NA PF GA
And then we have :

0 A$="KGAHKEAGKNDAMAIINAPNMKNAPFGA" : REM 33+1 chars
1 S=768: FOR I = 2057 TO 2084 STEP 2: POKE S+N, (PEEK(I)-65)*16 + PEEK(I+1) - 65: N=N+1: NEXT: REM +74 chars = 108 chars

That could be further reduced to
0 A$="KGAHKEAGKNDAMAIINAPNMKNAPFGA" : REM 33+1 chars
1 S=768: FOR I = 2057 TO 2084 STEP 2: POKE S+N, 16*PEEK(I) + PEEK(I+1) - 1105: N=N+1 : NEXT: REM +71 chars = 105 chars

Not really helping us !

So here comes the technique I've developed for this particular case.
Notice that it can be used for all kinds of subroutines .... just be aware that we're "printing" routines and that the TEXT page lines are not sequential (line 1 is not in $400+40 chars)

This new (?) technique involves using four very simple instructions: PRINT, SCRN, COLOR and PLOT.
We will be using the GR/TEXT capabilities of Applesoft to poke a program in TEXT page 1.
How does it work ?
First we start from our 14 routine bytes: A6 07 A4 06 AD 30 C0 88 D0 FD CA D0 F5 60
We leave every number as it is, but we replace all the letters with new letters according to this:
A becomes J, B becomes K, C->L, D->M, E->N and F becomes O.
We now have J6 07 J4 06 JM 30 L0 88 M0 OM LJ M0 O5 60

We will now take advantage of the GR/TEXT screen and the SCRN function.
We are going to print every low-nibble (4 bits) of each char on line 1 of TEXT (which is line 0 of GR), this means we print "6746M0080MJ050"
we will print every high-nibble of each char on line 2 of TEXT (which is line 2 of GR), this means we print "J0J0J3L8MOLMO6"

Then, we will move/copy line 2 of GR, using SCRN to get its "value" (color), to line 1 of GR.
The result is that in line 0 of GR, we'll have our sound routine.

Here's the resulting code:
0 HOME: REM 4 chars (not counted)
1 ?"6746M0080MJ050": REM  17+1 chars
2 ?"J0J0J3L8MOLMO6": REM +17+1 chars = 36 chars
3 FOR I = 0 TO 13  : REM +10+1 chars = 47 chars     we're going to SCRN that TEXT line in VTAB 2
4 COLOR = SCRN(I,2): REM +15+1 chars = 63 chars     we have a value 0-15
5 PLOT I,1: REM +7+1 chars = 71 chars     we PLOT it on line 1, actually adding 16*color to the byte in $400+I
6 NEXT : REM +4 chars = 75 chars

Even with the "HOME" statement at first (which is needed but might already be included in your 2-liner), we have 75+4+1 chars = 80 chars

This is still better than the traditional POKE technique ...

This method can be used to POKE/PLOT longer routines ... just make sure to take into account the fact that one line is 40 chars max, so you
if you need to handle more bytes, simply add a embracing loop to repeat as needed ... don't forget you can do "NEXT I,J" instead of "NEXT:NEXT" !

Of course, if you need line 1 of TEXT or line 0 of GR, you'll see the routine ... it's probably better using Hires 2-liners....

One last thing.

Roger Wagner's assembly lines contains another routine to handle sound that might be very useful for 2-liners.
Instead of using 
POKE 6,P: POKE 7,D: CALL 1024
it's using
CALL 1024, P, D

This means saving 12 characters every time you want to emit a sound.
However, the routine itself (see page 148 of the book) is not 14 bytes but 24 bytes. That's 10 bytes more.
If you want to output just one "unsual" sound (not CHR$(7) and not PEEK(49200)), use the 14 bytes routine.
But if you need more tunes, use the 24 bytes routine !

The 24 bytes routine uses 95 characters by itself ... it's almost as good as the "usual" routine we presented first that had 92 chars but it will take 9 characters less to call it !

10 HOME : REM 4 (not counted)
20 ? "0L7660L7676746M0080MJ050"   : REM  27+1
30 ? "24N8024N80J0J0J3L8MOLMO6"   : REM +27+1 = 56
40 FOR I = 0 TO 23   : REM +10+1 chars = 67
50 COLOR = SCRN(I,2) : REM +15+1 chars = 83
60 PLOT I,1 : REM +7+1 chars = 91
70 NEXT: REM +4 chars = 95

100 REM LET'S HEAR SOMETHING
120 FOR I = 0 TO 255
130 CALL 1024 , I, 10
140 NEXT


I hope you enjoyed this little tutorial on "how I did it" ! .... 

Can you do better than this ? If so, don't hesitate to post, I'd be happy to see what you've come up with !
