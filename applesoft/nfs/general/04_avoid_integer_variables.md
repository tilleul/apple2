# Avoid integer variables
Where we learn that Applesoft's integers won't make you whole.

## Summary
- [How integer variables are handled](#-how-integer-variables-are-handled)
- [Sacrifice of the integers](#-sacrifice-of-the-integers)
- [Integer variables vs INT()](#-integer-variables-vs-INT-)
- [What's an integer good for ?](#-whats-an-integer-good-for-)
	1. [Do you really need an integer ?](#1-do-you-really-need-an-integer-)
	2. [Do you need to store theReal world examples of integer in a variable ?](#2-do-you-need-to-store-the-integer-in-a-variable-)
	3. [Storage and access of integer variables](#3-storage-and-access-of-integer-variables)
- [Recommendations](#-recommendations)

## 🍎 How integer variables are handled
Applesoft integer variables are variables whose name end with a "%" character. They can hold integer values from -32767 to 32767. That's almost the range of signed integer numbers on 2 bytes, but because of a bug in Applesoft you can't have -32768 ($8000) in an integer variable.

Integer variables are stored in memory in the same area as the other "simple" variables (floats, strings and ```DEF FN``` variables), by default right after the end of the program. If integer variables' values are limited to two bytes, they are in fact stored on five bytes, the last three being unused. These 3 unused bytes are reset to zero when the variable is created but subsequent assignments won't touch them. 

This memory is free for you to use if you want. To identify where it is, it's easy as the address of the last accessed variable is stored in $83-$84 (131-132). The only thing is you can't store the values in these memory locations directly in a variable as they will then point to the variable you're using as storage. You need to copy the values in another memory location beforehand.

```basic
10 A% = 123: REM A% IS CREATED
20 POKE 6, PEEK(131): POKE 7, PEEK(132): REM COPY ADDRESS IN $6-$7
30 A= PEEK(6) + PEEK(7)*256 + 2: REM SKIP THE FIRST TWO BYTES
40 REM MEMORY LOCATIONS POINTED BY A, A+1 AND A+2 ARE FREE TO USE
```
If you didn't pick the address at the creation of the variable, simply reuse the variable in your code. A simple `A%=A%` will do the trick.


##  🍎 Sacrifice of the integers
Applesoft considers every number as a float and can only compute mathematical expressions of float operands. In order to achieve that, Applesoft will convert any numerical value it parses to a float before doing anything else with it.

When Applesoft parses an expression, it will **not** check if that expression can be evidently evaluated to an integer number (like when using an integer constant -- as in `K=PEEK(49152)` -- or like when using an integer variable -- as in `VTAB V%`). This means that integer numbers are never treated as such by Applesoft: everything falls back **first** into the general case of floating-point numbers.

Applesoft was written to handle floats at all times and integers were sacrificed, probably because of a lack of memory space to hold dedicated integer operations/routines.

Integer numbers are not ***special*** for the Applesoft interpreter, they're just floats without a decimal point. Nothing in the Applesoft interpreter is made to specifically handle integers when they're found in the code.

A notable consequence of this is that **integer values** are more efficient in **real variables** than in **integer variables**: every time an integer variable is used, its value is first converted to a float before anything else. 

Then if the instruction it's being used in requires an integer (like it is with `PEEK`), it's converted back *internally* to an integer !

And if the result of an operation needs to be stored in an integer variable, the float result is converted back to a 16-bit integer (with limits validation), slowing down the whole process even more.

***Integer variables are slower and take as much space as real variables***. That's the thing to remember. <sup>(*)</sup>

<sup>(*) The only exception being arrays of integers -- like `A%(n)` -- where the 16-bit value is actually stored on 2 bytes and not 5, but that's all. Accessing items in arrays of integers are always slower nonetheless, because the integer is converted to a float as soon as it's accessed.</sup>

Every time you use an integer variable it will impact speed negatively. How much ? That depends on the final value that is handled and what you do with it, but every time you use an integer variable you lose around 200-350 cycles.

Let's compare
```basic
10 A=-16384
20 B=PEEK(A)
30 PRINT B
40 END
```
with 
```basic
10 A%=-16384
20 B%=PEEK(A%)
30 PRINT B%
40 END
```
Line 10 takes 6754 cycles in the first case and 7058 cycles in the second case. A difference of 304 cycles. In both cases, `-16384` is interpreted as a float number. But in the second case, that float needs to be converted to an integer to be stored in an integer variable.

Line 20 takes 2441 cycles in the first case and 3047 cycles in the second case. A difference of 606 cycles ! This is because, in the second case, `A%` is first converted to float, then to an integer (because `PEEK` requires an integer value) then the memory is read memory and the result (a byte), is converted to float. But because `B%` is an integer variable, it is again converted to integer. That's 4 conversions. In the first case, only two conversions occur: `A` (float) is converted to integer and the resulting byte of `PEEK` is converted to float to be stored into `B`.

Line 30 takes 26779 cycles in the first case and 27031 cycles in the second case. A difference of 252 cycles. 

Does it really mean that integer variables are useless ? 

Well, in fact there's one case where they're more efficient.

##  🍎 Integer variables vs INT( )

After all, this is what integer variables do ... convert numbers to integers !

```basic
10 A=17.1: B=0
20 B=INT(A)
30 END
```
Line 20 takes 2259 cycles. This is almost twice the time (1194 cycles) it takes to just assign the value of `A` to `B` (`B=A` instead of `B=INT(A)`). 

```basic
10 A=17.1: B%=0
20 B%=A
30 END
```
Line 20 now takes 1538 cycles ! That's 721 cycles **faster** than using `INT` ! Isn't it great !? Well, don't get too excited ...

Now that you have rounded down the value of ``A``, you'll probably want to do something with it. Let's say you want to `PRINT` it.

```basic
10 A=17.1: B=0
20 B=INT(A): PRINT B
30 END
```
Line 20 takes 28773 cycles.

```basic
10 A=17.1: B%=0
20 B%=A: PRINT B%
30 END
```
Line 20 takes 28274 cycles. It's 499 cycles faster but because our code uses `B%` a second time, our advance of 721 cycles has been decreased by 222 cycles.

This confirms that every time you use an integer variable (like `B%`) more than once in your code, you will lose ~200-350 cycles ... It means you can only use `B%` **two to four times** before losing the advantage of having NOT used `INT` and a real variable. That's a significant drawback you must take into account. 

Knowing that, is it relevant to use integer variables ?

## 🍎 What's an integer good for ?

### 1) Do you really need an integer ?
There are no Applesoft instruction that **require** an integer value as argument/parameter. All numeric arguments/parameters are considered as floats first,
- then, if it's needed, they are converted to integers either on 2-bytes or 1-byte
- then, their limits are validated, throwing an ILLEGAL QUANTITY ERROR if their value is out of bounds

It means, you **don't need** to convert floats to integers when using numeric expressions with Applesoft instructions as Applesoft will do the conversion for you. You don't need to use `INT` and you don't need to use integer variables for arguments/parameters.

This is true for `PEEK`, `POKE`, `CALL`, `HTAB`, `VTAB`, `PLOT`, `HPLOT`, `SCRN`, `VLIN`, `HLIN`, `(X)DRAW`, `PDL` to name a few.

This is also true for `ROT=`, `SCALE=`, `HCOLOR=`, `COLOR=` and even `SPEED=`, `LOMEM:` and `HIMEM:` !

It even applies for numeric parameters used in string-related instructions: `LEFT$`, `MID$`, `RIGHT$` and `CHR$`.

It applies for dimensioning arrays with `DIM` (e.g. `N=123.456: DIM A(N)` works).

It applies to indices of arrays. It means that an array like `M(X, Y)` representing for example the player's X-Y position in a maze can be used without worrying about `X` and `Y` being integers.

Strangely, it also works with `GOTO` and `GOSUB`, and though you'll probably never do it because you cannot use arithmetic expressions after `GOTO`/`GOSUB`, know that `GOTO 100.123456` works, as long as you have a line 100 in your code of course.

But more interestingly, it works with `ON/GOTO-GOSUB` <sup>(*)</sup> This means you can do this:
```basic
ON RND(1)*10 GOTO 100,200,300,400
```
and `INT` it totally superfluous !

<sup>(*) As we'll see in another chapter, ON/GOTO is faster than a sequence of multiple IF/THEN conditions and is the preferred method when your code needs branching.</sup>

This is very useful for random events, AI decisions, or simply branching your code based on a calculation, for example you could scale a value and react accordingly:
```basic
10 D=47: REM DISTANCE COVERED SO FAR
20 M=100: REM MAX DISTANCE
30 Q=25: REM DIVIDER (100/25 = 4 DIFFERENT MSGS + 1)
...
100 ON D/Q GOTO 120, 130, 140, 150 : REM NO NEED TO USE INT HERE !
110 PRINT "GOOD LUCK !": GOTO 160: REM 0-24
120 PRINT "KEEP GOING !": GOTO 160: REM 25-49
130 PRINT "HALFWAY THERE !": GOTO 160: REM 50-74
140 PRINT "ALMOST THERE !": GOTO 160: REM 75-99
150 PRINT "FINISH !": END
160 REM CONTINUING ...
```
### 2) Do you need to store the integer in a variable ?
Remember that snippet ?
```basic
10 A=17.1: B%=0
20 B%=A: PRINT B%
30 END
```
Line 20 took 28274 cycles and it proved more efficient than using `INT`. But if you only need an integer value once, an `INT` will be faster because, unlike integer variables, you can use it *inline* a statement. 

Replace line 20 with
```basic
20 PRINT INT(A)
```
and now line 20 takes only 27602 cycles, which is faster (672 cycles) than using integer variables.

This kind of *inline conversion* is not possible with integer variables since you actually need a variable to do the integer conversion (duh !).

Let's say the player of your game opens a treasure chest and finds 1 to 100 gold pieces in the chest. Do you need an integer variable for that ? It depends. Here are two different cases.

Using an inline `INT`:
```basic
10 G=50: H=100: U=1: V=21
20 G = G+INT(RND(U)*H+U)
30 VTAB V: PRINT "GOLD: ";G
40 END
```
In this first example, the amount of gold the player found is not important, what matters is the total of gold he has. Use of inline `INT` is therefore faster.

Second example:
```basic
10 G=50: H=100: U=1: R%=0
20 R%=RND(U)*H+U : G = G+R%
30 PRINT "YOU'VE FOUND "; R%; " GOLD COINS. YOU HAVE NOW "; G; " GOLD COINS".
40 END
```
In this example, we're interested in both the amount found and the total. It makes sense to store the result in a temporary variable and since it requires an integer **value**, using an integer **variable** (even referenced 3 times in the code) will be around ~200-400 cycles faster than a real variable and using `INT`. 

### 3) Storage and access of integer variables
As shown in the previous example, you should consider using integer variables when you need to use these integers values more than once in your code, for example for calculations in other formulas.

However, you need to be careful.

Imagine your game is played on a grid of some size. The player's XY coordinates are stored in the real variables `X` and `Y` and these are guaranteed to hold integer numbers at all times because the player can only move to one tile/square at a time.
An enemy's on the grid too and he moves randomly in both directions. To move it in the X-direction you use the following code (and a similar code to move the enemy in the Y-direction):
```basic
EX% = EX% + RND(1)*3 - 1
```
<sup>(*) Of course, as you know, all hardcoded constants should be replaced with variables. But I've left the constants here for readability.</sup>.

It looks like it's wise to use an integer variable because the same line with real variables
```basic
EX = EX + INT(RND(1)*3 - 1)
```
would be ~600-700 cycles slower.

But:
- you need to draw the enemy on screen, with 
	- `HTAB EX%: PRINT "X"` or 
	- `PLOT EX%, EY%` or 
	- `HPLOT EX%, EY%` or 
	- `(X)DRAW E AT EX%,EY%`. 
- you need to check if the player's position is the same as the enemy's
	- `IF EX%=X AND EY%=Y THEN ...`
- you need to erase the enemy on the next loop iteration, meaning 
	- you might store the enemy's previous position in another set of variables
		- `XE=EX%: YE=EY%` (no need to use integer variables like `XE%` or `YE%` since the conversion is already done)
	- you'll do another call to `HTAB+PRINT`, `PLOT`, `HPLOT`, `(X)DRAW`
- you might need to check if the enemy was hit by the player's projectile
	- `IF EX%=PX AND EY%=PY THEN ...`
- etc.

Every time you use `EX%` (and `EY%`) you'll lose 200-350 cycles and after 3-5 times, using an real variable is a better choice.



## 🍎 Recommendations

- The general rule is to **avoid** integer variables: they're much slower than real variables and take as much memory.
- Integer variables are **never** needed as parameters of Applesoft instructions, so don't bother.
- Integer variables **may be** faster than using `INT`. **But**:
	- before using `INT`, check if you really need an integer value.
	- if the result of `INT` can be used in an inline statement and is never used again, inline `INT` will be faster than using a temporary integer variable.
	- if the integer variable is used more than twice in the main loop, you might lose any speed advantage you had.
