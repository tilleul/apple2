# Applesoft: Need For Speed
So you like Applesoft ? And you think you can write an action game with it ? Or maybe a science program ? Yes, you can ... will it be fast ? ... Probably not ...

BUT ! ... Where there's light, there's hope !

Here are several tricks you can use to optimize your Applesoft code for SPEED !

# Introduction
Writing a fast action game in Applesoft is an antinomy: Applesoft is not fast enough for fast action games.

Well, that's almost always true ... but if your game
* has simple game mechanic
* does not involve too many moving objects (hero, enemies, missiles, etc.)
* uses simple/minimalist graphics or no graphics at all
* uses few calculations

then, there might be a chance that it ends up fast enough to be enjoyable.

# Methodology
Not only am I going to show you that some code is faster than other, I'm going to prove it !

In order to do that, I'm using [AppleWin](https://github.com/AppleWin/AppleWin), an Apple II emulator that has a cycle counting/difference feature. What I do is set a breakpoint within the Applesoft ``NEWSTT`` routine in ``$D801``. The ``NEWSTT`` routine is responsible for checking if there's a (new) statement to process, either on the same line (then, separated with a colon ``:``) or on a new line. In ``$D801`` a new line has been detected and is about to be executed (although there's first a check to see if ``TRACE`` is on and so if it's needed to print on the screen the line number being executed). So, except for a check here and there, setting a breakpoint in ``$D801`` will count the cycles needed to execute a whole line. It gives a good indication of the speed needed and can be used as a base for cycle counts comparisons.

So, we are going to compare code snippets speed. For example, is it faster to divide a number by 2 or to multiply it by 0.5 ? To make sure we don't enter some special cases where values of ``zero`` are treated differently, we first initiate some variables, usually in line 10. The code we actually want to test will be in line 20 most of the time, while line 30 will be a simple ``END`` statement. ``END`` is not necessary normally to end a program but remember that the breakpoint in ``$D801`` only occurs when a **new line** is found, that's why we must finish our code with an ``END`` statement, on a new line

Snippet #1:
```
10 A=18: B=2
20 C=A/B
30 END
```
Line 20 took 3959 cycles

Snippet #2
```
10 A=18: B=0.5
20 C=A*B
30 END
```
This is faster as line 20 took only 3236 cycles, a difference of **723 cycles** ! (and you already have a first technique to increase speed, I'll explain it later).

Notice that both snippets have the exact same result: variable ``C`` now holds the value ``9`` (which is 18 divided by 2 or 18 multiplied by 0.5). All our snippets will have the same final effect, otherwise we would not be comparing fairly. For example, for the second snippet, if line 20 had been ``PRINT A*B`` it would be impossible to tell if the code is faster or slower thanks to the multiplication, the division, the variable attribution or the ``PRINT`` statement or a combination of these factors.

The actual difference of **723 cycles** does not really matter. What is important is that the second snippet **actually runs** faster. Actual speed depends on several other factors which will be explained in this article.

***Remember***: 
* The cycles count on this page are only an indication of the speed of the code we want to "benchmark".
* The exact cycle count is **not** what matters. 
* **Comparison** of cycles count is what we're studying. 
* Smaller cycles counts are faster and are considered as a technique to apply whenever possible.
* Sometimes, if you're not careful, using a technique explained here could be **slower** if you don't pay attention to other factors. If that's the case, it will be explained.

# Summary
1. [Use variables as placeholders for constant values](#1-use-variables-as-placeholders-for-constant-values)
Accessing a known value in a variable is faster than deciphering values in code.
2. [Declare your most used variables first](#2-declare-your-most-used-variables-first)
Create and/or reference the variables you're going to use the most as soon as possible
4. (and many others) coming soon... 

# 1) Use variables as placeholders for constant values
Let's consider a code like ``K=PEEK(49152)`` (this code gets the ASCII code of the last key pressed, plus 128 if the keyboard probe has not been reset and store it in variable ``K``).

When this code is run , the Applesoft parser will perform the following:
1. search for a "real/float" variable named ``K``, and create one if needed
2. encountering the ``=`` sign, the parser knows that an expression will be evaluated and attributed to variable ``K``
3. the expression in this case is a memory read request (``PEEK``)
4. the parser will then collate the memory location by evaluating what's between the parenthesis (it could be a formula involving other variables for instance). In this case it will just read the number, character by character:
   * first, ``4``
   * then, ``9``
   * then ``1``
   * then ``5``
   * then ``2``
 5. Collating these, results in ``4 9 1 5 2`` as 5 ASCII characters. These represent, for us, humans, a decimal number but not yet for Applesoft.
 6. These 5 characters will then be converted to a real number (using a format known as binary floating-point format)
 7. Then, the real number is converted to an integer value (because ``PEEK`` expects a 2-bytes integer)
 8. Once this has been done, the value in the appropriate location is read, converted from byte to a binary floating-point value and attributed to variable K

The bottleneck here are the steps 4-6. Building a integer representing a memory location from characters is long.

It is probable that your game will need to read the keyboard regularly. Why do you have to repeat steps 4-6 every time you need to get the last key pressed ? Fortunately, there's a workaround.

It is actually faster for the Applesoft parser to locate a variable and use its value than to "recreate it from scratch". So, all you need to do is save in a variable the value you want to repeatedly use.

For example:
```
10 N=49152
20 K=PEEK(N)
30 END
```
Line 20 takes 2303 cycles while
```
10 N=49152
20 K=PEEK(49152)
30 END
```
line 20 here takes 7128 cycles, that's a difference of **4825 cycles** ! This is ***HUGE*** especially when it's a statement that's going to be executed every time the main game loop cycles !

Other values will produce different results. For a comparison example, let's say we want to read the value in memory location ``zero``.
```
10 N=0
20 K=PEEK(N)
30 END
```
Line 20 takes 2090 cycles, while
```
10 N=0
20 K=PEEK(0)
30 END
```
this line 20 only takes **390** more cycles. This is because ``0`` is only 1 character, while ``49152`` is 5 characters. But anyway, even if the difference is not that important, it's faster.

Should you convert all your constants to variables ? My advice is yes, particularly for the constants used in loops or repeatedly. Among those are:

* Values you might use constantly (often powers of 2) like ``4``, ``8``, ``16``, ``32``, ``64``, ``128`` and ``256`` ... or maybe their lower limits like ``3``, ``7``, ``15``, ``31``, ``63``, ``127`` and ``255``
* Other values you will certainly use like ``0``, ``1`` and ``2``. I like to put these in variables ``Z``, ``U`` ("unit(ary)") and ``T`` (as in "two")
* Limits in your game like
	*  the screen limits: think of ``VTAB 24``, ``HTAB 40``, ``SCRN(39,39)``, ``HPLOT 279,159`` or their upper boundaries like ``40``, ``280`` ``160`` and ``192``.
	* loops' low and high limits: ``0``, ``1`` up to ``9`` , ``10`` or ``19`` and ``20``, etc. Think of ``FOR I=0 TO ...`` or ``FOR I=1 TO ...``
* Usual PEEK/POKE/CALL locations like 
	* ``49152`` (last key pressed), 
	* ``49168`` (reset keyboard strobe), 
	* ``49200`` (click speaker), 
	* ``-868`` (a ``CALL`` there will clear the text line from the cursor position to the end of the line)...
	* maybe zero page locations like the collision counter in ``234``, 
	* or the next ``DATA`` address in ``125`` and ``126``, 
	* or the text window limits in ``32-35``, 
	* etc.

Whatever the value, whether it's an integer or a real <sup>(*)</sup>, this rule will **always** speed your code, except if you're not careful about the next technique ...

<sup>(*) strings are an entirely different matter</sup>

# 2) Declare your most used variables first
Applesoft variables are stored in two separate areas: 
* right after the program's last line is an area pointed by ``VARTAB`` (in zero-page vector ``$69-$6A`` -- decimal ``105-106``) where all the real, integer and string variables are defined and stored <sup>(*)</sup>. It's also where references to "functions" created by ``DEF FN`` are stored.
* just after that area is another area, pointed by the vector ``ARYTAB`` (in ``$6B-$6``, decimal ``107-108``) where all the arrays are stored.

<sup>(*) string variables are not stored in that area, but pointers to their values are stored there. The actual values of string variables being either in the program code itself or in a special area after the array storage area</sup>

You don't need to declare a variable to use it. As soon as a variable name is discovered by the Applesoft parser, the following happens:
* the type of the variable is determined so Applesoft knows where to look for the variable's name (``VARTAB`` or ``ARYTAB``)
* Applesoft scans the memory repository for the specified variable type and looks for an existing variable of the same name
	* if it's not found, it means it's a new variable and the appropriate space (variable name, type, array indices, value) is reserved at the top of the memory pile where all variables of the same type reside (optionnally moving the ``ARYTAB`` area up if a new real/integer/string/function variable needs to be declared). The new variable's value is referenced for next step
	* if the variable already exists, its value is referenced for the next step
* then the value of the variable is used/replaced/computed/etc. (depending on the actual code)

As you see, numeric (float/real and integer) variables, string variables and arrays are stored in several different ways but they all share one thing in common: once a variable is encountered and once its type has been determined, the Applesoft parser will search for the variable in one of the two memory locations in the same way: from one end to the other.

This means that variables are not "ordered" by their names ... It means that, in memory, variable Z might be stored/referenced before variable A... It also means that the time spent to look for a variable depends on how soon it was found in the code. How much time ? Let's find out.

Let's create a variable ``A`` and another named ``Z`` with equal values, then let's print the value of variable ``A`` and then in a second snippet, the value of variable ``Z``.

```
10 A=123: Z=A
20 PRINT A
30 END
```
Line 20 takes 27864 cycles. The second snippet just prints variable ``Z`` instead of ``A``.
```
10 A=123: Z=A
20 PRINT Z
30 END
```
This takes 27898 cycles. That's a difference of 34 cycles. It looks **insignificant** and, as such, **it is** ! but it has an impact on all the other techniques I'm gonna teach you.

Let's have another example. Now this time, we will declare 26 different variables named from ``A`` to ``Z`` and see the cycles count difference when accessing the first one or the last one declared.

```
10 A=0: B=1: C=1: D=1: E=1: F=1: G=1: H=1: I=1: J=1: K=1: L=1: M=1: N=1: O=1: P=1: Q=1: R=1: S=1: T=1: U=1: V=1: W=1: X=1: Y=1: Z=0
20 PRINT A
30 END
```
Line 20 took 20241 cycles. Second snippet is identical except we access variable ``Z`` instead of variable ``A``. You'll notice that the values of these two variables are identical to eliminate the possible fact that different values are handled with different speeds.

```
10 A=0: B=1: C=1: D=1: E=1: F=1: G=1: H=1: I=1: J=1: K=1: L=1: M=1: N=1: O=1: P=1: Q=1: R=1: S=1: T=1: U=1: V=1: W=1: X=1: Y=1: Z=0
20 PRINT Z
30 END
```
This took 21026 cycles. The difference is **only** 785 cycles. Let's be honest, it's not gigantic. 

But ! Wait ! Remember that snippet in the section [Use variables as placeholders for constant values](#use-variables-as-placeholders-for-constant-values) where we handled value ``0`` ? 

It had a difference of 390 cycles just by replacing a hardcoded/constant value of ``0`` with a variable name. It would mean that if we're not careful, we might lose the advantage we took for granted.

Let me rephrase this: imagine if Z was holding a value you need to use **OFTEN** ... myself I like to put **zero** in Z because it's obviously a good variable name for such a value ...

Let's see that with two other snippets. Snippet #1 will declare ``Z`` first, snippet #2 will declare ``Z`` last and snippet #3 will not use ``Z`` but a hardcoded value of ``0``

```
10 Z=0: A=0: B=1: C=1: D=1: E=1: F=1: G=1: H=1: I=1: J=1: K=1: L=1: M=1: N=1: O=1: P=1: Q=1: R=1: S=1: T=1: U=1: V=1: W=1: X=1: Y=1
20 PRINT Z
30 END
```
Line 20 took 20241 cycles (same cycle count as when ``A`` was declared first and we wanted to print the value of ``A``)

Snippet #2:
```
10 A=0: B=1: C=1: D=1: E=1: F=1: G=1: H=1: I=1: J=1: K=1: L=1: M=1: N=1: O=1: P=1: Q=1: R=1: S=1: T=1: U=1: V=1: W=1: X=1: Y=1: Z=0
20 PRINT Z
30 END
```
Line 20 took 21026 cycles, it's **slower**, with a difference of 785 cycles !

Snippet #3
```
10 A=0: B=1: C=1: D=1: E=1: F=1: G=1: H=1: I=1: J=1: K=1: L=1: M=1: N=1: O=1: P=1: Q=1: R=1: S=1: T=1: U=1: V=1: W=1: X=1: Y=1: Z=0
20 PRINT 0
30 END
```
Line 20 took 20672 cycles, a difference of only 431 cycles with the first snippet where we use ``Z=0`` as the first declared variable, but also it's 354 cycles **faster** than the version where ``Z=0`` is declared last ! Thus, negating any interest in replacing ``0`` with a variable if it's not declared in time !

Your most used variables should be declared first. In fact **you should have a line in your code where all these variables are declared/created before doing anything else**,  otherwise you might inadvertently create a variable. The most common error being to display the instructions or a splash screen for the game and then wait for a keypress with something like ``GET K$``, as ``K$`` might be your very first declared variable !

So which variables should you declare first ? and with many variables to declare, how do you know if it's best to use a variable or an actual value ? It depends on many factors.

It's best to declare the variables used in your main game loop first. Most common variables and constants are possibly:
* the player's position (typically ``X,Y``)
* previous player position (like ``OX,OY`` although you should prefer single-character variables like ``A,B`` or ``V,W``, more about that later)
* loop counters (like ``I,J``) as used in ``FOR/NEXT`` loops or other loops
* ``49152``, memory location to read a key and ``49168`` to clear the keyboard strobe (but more about that later)
* expected ASCII+128 values (``201``, ``202``, ``203`` & ``204`` are for I/J/K/L which are 4 directions keys on EVERY latin keyboard around the world), maybe ``160`` for space bar, etc.
* I like to use single variables for very common values like ``Z`` for ``0``, ``U`` (unit(ary)) for ``1`` and ``T`` for ``2`` ... it depends if you need these or not ...
* a variable to hold an energy meter (``E`` ?) or a score (``S`` ?)
* player speed (horizontal, vertical)
* a shape rotation ?
* enemies positions + previous cycle positions
* missiles/bullets positions
* etc.

Once you know which variables you use in your main game loop, you need to consider the following:
* how often do you use that variable in your game loop ? just count the occurrences ... the most used variables should be declared first and foremost
* if the variable is used after an IF/THEN statement, take into account how likely the condition will evaluate to true or not.

Final example:
In this snippet, ``X`` is incremented and checked against a maximum limit. In the extreme case where ``X`` exceeds the limit, its value is set to that limit.
This is the kind of code that typically happens when drawing a moving object on the screen.

If you consider that line 20 is part of the main loop, then ``X`` is referenced 3 times:
* two times in a calculation where the final result is stored in ``X``
* one in a comparison
If the comparison is true, then ``X`` is referenced one more time.

The limit variable ``M`` is referenced only once during the comparison, then a second time when the comparison result is true. As the comparison will probably be false most of the time, you can consider that ``X`` is referenced 3 times, while ``M`` only once. But even if the comparison was true most of the time, ``X`` would still be referenced more often than ``M``. Obviously ``X`` should be declared before ``M``.

Snippet #1:
```basic
10 X=279: U=1: M=279
20 X=X+U: IF X>M THEN X=M
30 END
```
In this case, line 20 took 5364 cycles.
The second snippet is identical except declaration of variables ``M`` and ``X`` are inverted.
```basic
10 M=279: U=1: X=279
20 X=X+U: IF X>M THEN X=M
30 END
```
Line 20 here takes 5500 cycles, that's 136 cycles more. Nothing too drastic but every cycle counts !

The same kind of process should be made with the variable ``U``. Should it be declared before ``M`` ? With these two snippets, ``U`` is referenced only once, whereas ``M`` could be referenced twice when ``X>M`` ... but it's probable that ``U`` (placeholder for the constant ``1``) is used elsewhere in the main game loop, while ``M`` has not many other uses than to check X-coordinates maximum limit ... so ``U`` will probably be more efficiently referenced if declared before ``M``.

