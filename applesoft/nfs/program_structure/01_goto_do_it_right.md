# GOTO: Do it right
Where we discover how to tame `GOTO` and avoid `GOSUB`.

Unless specified, everything that applies to `GOTO` applies to `GOSUB` as well. Although some of the info provided here applies to `ON X GOTO/GOSUB` and `ONERR GOTO`, these two instructions will be detailed in future articles as they also have their own particularities.

## Summary
- [How line numbers work](#-how-line-numbers-work)
- [How `GOTO/GOSUB` decode line numbers](#-how-gotogosub-decode-line-numbers)
- [Going to the line](#-going-to-the-line)
- [A word about `GOSUB`](#-a-word-about-gosub)
- [An ideal program structure](#-an-ideal-program-structure)
- [Wishes ... `GOTO` waste](#-wishes--goto-waste)
- [Recommendations](#-recommendations)

## 🍎 How line numbers work
Whenever you type a program in Applesoft, it begins in `$801` in memory. This address is stored in zero page `$67-$68` (a location known as `TXTTAB`). It's possible to modify these values and therefore make Applesoft store your program elsewhere in memory. This process is known as "relocation" but to make it persistent it requires several other things that I'm not going to discuss now. Relocation is often used when you need the hires pages (in locations `$2000-$3FFF` or `$4000-$5FFF`) but your program is so large that its code is stored beyond `$1FFF` which affects the hires pages. In this case, you'll relocate your code after the hires memory.

The byte just before the location pointed by `TXTTAB` (thus `$800` most of the time), must be zero. If it's not, you'll get a syntax error in an improbable line number when you `RUN` your code.

In `$801` the lines of your program are encoded. For each line, the structure is the same.

The first and second bytes represent the address of the next line but it's in fact more exactly the address **right after** the **end** of the **current** line. 

If there's no current line, meaning it's the end the program, these two bytes are zero. In fact, when a program is executed and that Applesoft is interpreting a line of code, only the second byte (the most significant byte of the address) is checked for zero (the first byte is not even read at this stage !). 

If these bytes are non-zero (and thus more particularly the second one), it does not mean that there is a next line, it means that the rest of the code, if any, can be found there.

These first two bytes (of each line) are **not** copied elsewhere in memory for later use (for instance they could have been copied in zero page). It means that if the interpreter needs to go to the next line (for example when an `IF/THEN` is evaluated to `FALSE`), it will have to search for the end of the current line first. And although searching for the end of a line of code is rather fast, it depends on the length of the line. If the address of the next line had been stored, not only would it be almost instantaneous but the length of the line would not matter.

The next two bytes represent the actual line number, which is a value between 0 and 63999. The line number is read by Applesoft and stored in zero page `$75-$76`, a location known as `CURLIN`. This value is used to print the line number being executed (if `TRACE` is on) or the line number where an error occurred, It is also used when handling a `GOTO/GOSUB`.

The next bytes represent the tokenized code. A byte of value zero indicates the end of the line. 

Then the next line, if any, begins: the first two bytes of this next line, as for the previous line, point to the location of the next-next line. Etc.

The end of any Applesoft program is represented by three zero bytes: the first one being the end of the current line, the two next ones being the indicator that there's no next line.

## 🍎 How `GOTO/GOSUB` decode line numbers
In Applesoft it's not possible to `GOTO/GOSUB` to a line number represented as an expression. You cannot `GOTO X*2` for instance (notice that it was possible with Wozniak's Integer Basic).

It is a limitation of the language but if it was possible to use a mathematical expression, evaluating this expression would mean converting variables to floats, calculate the expression and then convert the float result to an integer. And in the end, `GOTO/GOSUB` would be even slower than what they are.

So, after a `GOTO/GOSUB`, an integer value is expected. This integer value has not been tokenized, meaning it still consists of ASCII characters. Converting this decimal number (encoded as ASCII) to hexadecimal uses a simple algorithm: from a starting value of zero, every digit is added to the previously evaluated value multiplied by 10.

For instance, if we had the statement `GOTO 61234`, here's how the line number would be converted from decimal/ASCII to hexadecimal.

|Digit read| Intermediary computation | Estimated value | Hex | Explanation
|--|--|--|--|--|
| n/a | n/a | 0 | $0000 | The estimated value is first set to zero.
| 6 | 0*10 = 0 | 0 + 6 = 6 | $0006 | The previous value is multiplied by 10 and the digit read is added
| 1 | 6*10 = 60 | 60 + 1 = 61 | $003D |
| 2 | 61*10 = 610 | 610 + 2 = 612 | $0264 |
| 3 | 612*10 = 6120 | 6120 + 3 = 6123 | $17EB |
| 4 | 6123*10 = 61230 | 61230 + 4 = 61234 | $EF32 |

Every time a digit needs to be "decoded", it takes an additional **114 cycles**. This is only for the decoding. Going to the line number is something else. Thus, `GOTO 6` takes 114 cycles to convert the "6" (in ASCII) to hex `$0006`, while `GOTO 61234` takes 4x114 additional cycles, for a total of 570 cycles to convert the five ASCII numbers into hex `$EF32`.

### The 63999 limit
The subroutine used by `GOTO/GOSUB` to decode a line number is also used when you type a line of code at the prompt. The subroutine includes a check to see if the line number is above 63999. The check happens after having confirmed that Applesoft just read a digit (thus assuming it's part of the line number). It will compare if the most significant byte of the estimated value so far is equal or above `$19` (25) meaning we have at least a value of 6400 (`$1900`). If that's the case Applesoft throws an error since multiplying the estimated value will result in a value of 64000 which is above the limit.

We have here a probable reason why the line numbers are limited to 63999. Of course this check could have been written in another manner but it would have been unnecessarily complicated for the only meager benefit of having 1500 additional lines of code . An intermediary value of 6553 (thus allowing for numbers between 65530 and 65535) is `$1999`. It means Applesoft needs to check if it has a `$19` for the MSB and a `$99` or below for the LSB. Then, it needs to check if the last digit is equal or lower than 5. Three checks instead of one. Not only is it slower but it also eats precious memory.

### Skipping non-digit characters
It should also be noted that whatever is after the `GOTO/GOSUB` statement does not need to be an integer. If it's anything else (strings, statements, syntax errors), or even if there is nothing after the statement, the line number is evaluated to zero. This means that `GOTO 0` is in fact 114 cycles slower than just "`GOTO`". And having "`GOTO ANY_GARBAGE_TEXT_HERE`" will do the same as just "`GOTO`", except for one thing: anything after the `GOTO` statement must be skipped to find the the end of the current line.

This skip occurs every time there is a `GOTO` or a `GOSUB`: everything after the `GOTO/GOSUB` is scanned byte by byte hoping to find the indicator for the end of the line: a zero. If Applesoft had stored the next line address when it had the chance, this could have been avoided.

Searching for this zero takes 8 cycles for the next byte on the line and then 19 cycles for every other byte that needs to be checked after that (and if the byte represents a double-quote, it's even a little more than that). Thus, a `GOSUB 100: REM PRINT SCORE`  will take 3x114 cycles to decode the line number, plus an additional 255 cycles for the `: REM PRINT SCORE` as it's made of one byte for the "`:`" (8 cycles), another byte for the tokenized "`REM`" (19 cycles -- the space between the two does not count as it has not been recorded by Applesoft), then 12 more bytes for the ` PRINT SCORE` text (12x19=228 cycles -- the space between `REM` and `PRINT` **has** been recorded by Applesoft and no, the `PRINT` has not been tokenized as it's part of the `REM` string). So we have 8 + 19 + 12x19 = 255 cycles just to skip the `REM`. As you probably know: you must ban `REM`s from your main loop if you're looking for speed.

## 🍎 Going to the line
Ok now that we have a line number to go to, how do we go there ?

The Applesoft program in memory has all the lines of code in chronological order. Even if you type the line #100 before the line #10, or if you insert lines between others, Applesoft will reorder all the lines in memory: it will find the place where your new line must be inserted, move all the next lines accordingly, insert your line and recalculate all the "next line" pointers (remember: the first two bytes of each line are a pointer to the start of the next line, if any).

Since all lines are ordered, Applesoft can find the line it has to `GOTO` by starting from the very first line and check the bytes 3 and 4 of each line and see if it corresponds to the target line. If not, it uses the address of the next line and do the same check. If the line being checked has a number below the line being searched then Applesoft emits an `UNDEF'D STATEMENT` error; it does not need to check further as the lines are ordered. The line is therefore considered nonexistent. 

This process takes 55 or 65 cycles for every line (more about **when** it's 55 or 65 in a moment) . Consider the following program:
```basic
100 REM
110 GOTO 140
120 REM
130 REM
140 PRINT "HELLO"
```

In line 110, decoding the line number takes 3x114 cycles, then Applesoft goes to the top of the program and searches for line 140. Every line number that is checked takes 65 cycles, line 140 being the fifth line, it actually takes 65x5=325 cycles to go from line 110 to line 140.

This behavior is the main reason why the few books that mention optimizing Applesoft programs (and notably the Applesoft Reference Manual in appendix E, page 120) tell you to "place frequently-referenced lines as early in the program as possible".

While this is true, it's also incomplete as there is a way to tell Applesoft to search for a line from the current line and above and not from the top of the program.

If **you** were given the task to optimize `GOTO/GOSUB` search for line, you would probably use the current line as a comparison. The simplest basic thing to suggest would be to search from the top of the program if the line is **before** the current line and search from the current line if the line being searched is **after**. And as a matter of fact, it is possible with Applesoft but with a small restriction.

Let's rewrite our program:

```basic
100 REM
110 GOTO 260
120 REM
130 REM
260 PRINT "HELLO"
```
In this case, the search for line 260 will begin from the current line and only 3 lines will be checked. This process takes 55 cycles for line 120, another 55 cycles for line 130 and 65 cycles for line 260, for a total of 175 cycles, which is almost twice as fast as the previous program.

The reason why Applesoft goes "forward" is because the integer result of 260 divided by 256 equals 1 while 110 divided by 256 equals 0. Because 1 is above 0, Applesoft will go "forward". Of course, this is the easy-human-using-decimal way to explain it. The Applesoft way is that 260 in hex is `$0104` while 110 in hex is `$006E` and that the most significant byte of the current line (`$00`) is lower than the MSB of the line we want to go to (`$01`).

Now you probably guessed why sometimes it takes 55 cycles and sometimes 65 cycles, while this is not really related to the previous point. It's simply because if the most significant byte of the line number being checked is different than the most significant byte of the line being searched, it's not needed to check for the least significant bytes. This check takes an additional 10 cycles. This explains why in the first program, each line takes 65 cycles, while in the second, only the last line takes 65 cycles.

To sum up, if you organize your main loop correctly, you may spare several hundreds of cycles by forcing your `GOTO`s to go forward. Of course every time you add a digit to your line numbers you lose 114 cycles for your `GOTO`. But this is equivalent to less than two lines to check (2x65). It's worth it.

## 🍎 A word about `GOSUB`
`GOSUB` is pretty much like `GOTO`. Except that Applesoft has to remember where to go when `RETURN` is encountered. It has to save several info into the stack (you could have multiple `GOSUB`s nested, so you can't save this info in a unique location on zero page). Once this is done, it works exactly like a `GOTO`: it searches for a line number either from the top or from the current line.

When Applesoft encounters the `RETURN` instruction, it has to search the stack for the last `GOSUB` that was issued, restore all the program pointers and return where it was. This takes around 350-450 cycles.

Because of these additional steps, I advise to avoid `GOSUB/RETURN` whenever it's possible and instead rewrite the same code whenever you need it as it will be executed faster (I know, this is bad practice but you want speed or not ?). For instance if you have a subroutine that does `VTAB 21: PRINT "SCORE: "; SC: RETURN`, simply delete the subroutine, and rewrite this code every time you need it. You will go much faster than searching for a line either from the top or forward.

For more complex subroutines, you'll have to consider reworking your code so that the subroutine is part of the main loop flow and is not called as a subroutine anymore. If it's not possible, then the subroutine must be one of the first lines of your program or somewhere in your main loop and then you need to make sure that any `GOSUB` there will go "forward" and that you adequately skip the subroutine with a `GOTO` "forward" too.

## 🍎 An ideal program structure
With what we know about `GOTO/GOSUB` and line numbers we can identify some kind of ideal program structure.

### Line zero
First you'll want to use line zero to jump at the end of your code (do something like `GOTO 9999`) where you can display an introduction screen, instructions, load data files, relocate your program, etc. But most importantly: declare the most used variables first !

Then when it's time to start the game, initialize all the games variables and `GOTO 1` or another entry point in your main loop.

### Lines 1-9
Your next lines should all be below 10, because any `GOTO/GOSUB` there will require only 114 cycles to decipher the line number. 

Ideally, lines 1 to 9 should be part of your main loop but if you need to call a "complex" subroutine more often than you'll go back to the start of the loop, then the subroutine should be there. **Before** the main loop. 

But in the opposite case, you should consider putting your subroutine **right after** the main loop, or even maybe **within** the main loop (and you could skip it with a `GOTO` "forward") and make sure that the `GOSUB`s that will call it will go "forward" too.

Lines 1-9 are are ideal for multiple re-entry points in the loop. But they're also a nice place to skip lines for cheap; even though any `GOTO` there will search "from the top". 

For example, If you have 10 lines of code from 0 to 9 and that line 7 has a `GOTO 9` (to skip line 8 for instance), it takes 764 cycles (114 cycles to decipher "9" plus 10x65 cycles to go there). 

If you wanted to use a `GOTO` "forward" then you'd have line 7 with `GOTO 256` (or above -- line 256 replacing line 9). In this case it takes 3x114 cycles to decipher "256" plus 55 cycles to skip line 8 and 65 cycles to arrive to line 256; total of 462 cycles, which is shorter but you loose all your 2-digit lines (between 10 and 99) ! Except if you use them anyway. And in this case, going to line 256 will take 55-65 additional cycles per line. After 6 lines you'll exceed the initial 764 cycles.

### Lines 10-99
The problem with lines 10-99 is that although deciphering the line number for `GOTO` is "only" 2x114 cycles, using `GOTO` will **always** search from the top of the program. If lines 0-20 exist, a `GOTO 20` costs 1528 cycles (2x114 + 65x20).

### Lines 100-255
These lines are even more expensive to `GOTO` than lines 10-99. Avoid them if you need to `GOTO` in there.

### Lines 256-511 etc.
Most of the time, my main loops go from line 1 to lines 20-25 and then jump to line 260 (or 256). Between lines 256-511, I'll have probably not much more than 10 lines as I'll probably need to jump forward again soon. The same goes for lines 512-767, and so on.

Remember that you can use the `GOTO` "forward" trick more than once within the same section. For example line 20 could `GOTO 260`, but line 21 could `GOTO 300`: both will `GOTO` "forward" !

Just so you know, if there are 10 lines between line numbers 260 and 350 (both included), and if line 260 has `GOTO 520`, it will take 902 cycles (3x114 + 9x55 + 1x65) to reach line 520.

### That "complex" subroutine you need to GOSUB to from time to time
If placing the subroutine at the top of the program is not a good idea or not possible, then you need to make sure you'll `GOSUB` "forward": place the subroutine **after** any `GOSUB >there<` call, as close as possible to the last `GOSUB >there<`. Even within the main loop if needed: just skip that subroutine with an appropriate `GOTO` forward.

## 🍎 Wishes ... GOTO waste
The way `GOTO/GOSUB` searches for a line number is inefficient. Some simple things could have been made to make it a little better. Of course, the question is: was there enough memory space in the ROM to implement this ?

1. In a program, line numbers (at the start of every line) are converted into 2-bytes integers. Why isn't it the case for the line numbers to `GOTO/GOSUB` ? This would have avoided the conversion from ASCII to integer during runtime AND saved memory. By the way, this is how it's implemented in Wozniak's Integer Basic. As a side note, this would have facilitated line renumbering routines.
2. Applesoft should have stored the address of the next line in zero page. This would have sped up the search for the end of the current line (which, by the way, occurs even if the search for the line to go to will be from the top of the program).
3. The search "forward" should have considered the complete line number to go to and not just the most significant byte.
4. If the line number AND the address of the next line were in a table of their own instead of being at the start of every tokenized line, it would be possible to search for line numbers not only from the top or "forward", but also "backwards". 

For example, knowing that the current line is line 200, a `GOTO 180` is statistically faster by searching "backwards" for line 180 than searching "from the top". A hint could have even been given by the programmer if the syntax was modified. For example a `GOTO <180` would force a backwards search.

Such a table could have been placed right after the program itself, inserted between the tokenized code and the start of the variables. As a side note, it would have also sped up lines insertion as only this table needs to be modified and no address needs to be recalculated. As a consequence the lines themselves would have been unordered but that's not an issue: only the lookup table needs to be ordered.

Using a lookup table also gives another information: line count. For example line 200 could be the tenth line in the code. This could easily be detected/computed because the pointer to the lookup table would be 40 (4 bytes per line x10). And this could have been used to determine if we want to search backwards or from the top and even, "from the bottom" ...

## 🍎 Recommendations
 - Use line zero to `GOTO` the start of your program
 - Lines 1-99 is where your main loop should reside
 - `GOTO` "from the top" should target a line as close as possible to line zero.
 - Use adequate "forward" `GOTO` within your main loop to skip lines
 - Avoid `GOSUB`s by rewriting the same code again whenever possible
 - `GOSUB` to a subroutine at the very start of your code (lines 1-9) or to a close subroutine **after** the `GOSUB` using "forward" technique
