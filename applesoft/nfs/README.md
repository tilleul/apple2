
# Applesoft: Need For Speed

### So you like Applesoft ? And you think you can write an action game with it ?  Or maybe a science program ? Yes, you can ... will it be fast ? ... Probably not ...
 
### BUT, WAIT ! ... Where there's light, there's hope !
 
### Here are several tricks you can use to optimize your Applesoft code for SPEED !


Writing a fast action game in Applesoft is an antinomy: Applesoft is not fast enough for fast action games.

Well, that's almost always true ... but if your game

* has simple game mechanic
* does not involve too many moving objects (hero, enemies, missiles, etc.)
* uses simple/minimalist graphics or no graphics at all
* uses few calculations

then, there might be a chance that it ends up fast enough to be enjoyable.

Applesoft: The Need For Speed is a series of articles that explain why some coding techniques are faster than others.

## Summary
### Methodology
1. [Methodology explained](#methodology): learn how I've compared code snippets' speed
### General tips
1. [Use variables as placeholders for constant values](general/01_variables_for_constants.md): accessing a known value in a variable is faster than deciphering values in code.
2. [Declare your most used variables first](general/02_declare_most_used_variables_first.md): create and/or reference the variables you're going to use the most as soon1 as possible
3. [Use one-letter variables names whenever possible](general/03_use_one_letter_variables_names.md): longer variables names take longer to parse.
4. [Never use integer variables](04_never_use_integer_variables.md): they are always slower to use than float variables, even when you think they're not
### Calculations
1. [Use addition instead of multiplication by 2](calculations/01_use_addition_instead_of_mul2.md): double addition of the same variable is faster than multiplying the variable by 2
2. [Addition is faster than subtraction](calculations/02_addition_is_faster_than_subtraction.md): avoid subtraction whenever possible but don't use negative constants.

(and many others) coming soon... 

## Methodology
Not only am I going to show you that some code is faster than other, I'm going to prove it !

In order to do that, I'm using [AppleWin](https://github.com/AppleWin/AppleWin), an Apple II emulator that has a cycle counting/difference feature. What I do is set a breakpoint within the Applesoft ``NEWSTT`` routine in ``$D801``. The ``NEWSTT`` routine is responsible for checking if there's a (new) statement to process, either on the same line (then, separated with a colon ``:``) or on a new line. In ``$D801`` a new line has been detected and is about to be executed (although there's first a check to see if ``TRACE`` is on and so if it's needed to print on the screen the line number being executed). So, except for a check here and there, setting a breakpoint in ``$D801`` will count the cycles needed to execute a whole line. It gives a good indication of the speed needed and can be used as a base for cycle counts comparisons.

So, we are going to compare code snippets speed. For example, is it faster to divide a number by 2 or to multiply it by 0.5 ? To make sure we don't enter some special cases where values of ``zero`` are treated differently, we first initiate some variables, usually in line 10. The code we actually want to test will be in line 20 most of the time, while line 30 will be a simple ``END`` statement. ``END`` is not necessary normally to end a program but remember that the breakpoint in ``$D801`` only occurs when a **new line** is found, that's why we must finish our code with an ``END`` statement, on a new line

Snippet #1:

```basic
10 A=18: B=2
20 C=A/B
30 END
```

Line 20 took 3959 cycles

Snippet #2

```basic
10 A=18: B=0.5
20 C=A*B
30 END
```

This is faster as line 20 took only 3236 cycles, a difference of **723 cycles** ! (and you already have a first technique to increase speed, I'll explain it later).

Notice that both snippets have the exact same result: variable ``C`` now holds the value ``9`` (which is 18 divided by 2 or 18 multiplied by 0.5). 

All our snippets will have the same final effect, otherwise we would not be comparing fairly. For example, the first snippet used a variable assignment in line 20 (``C=A/B``). For the second snippet, it's important we use another variable assignment (``C=A*B``) because we want to compare the speed of the multiplication and the speed of the division. If we had used ``A*B`` with a statement like ``PRINT A*B`` or ``K=PEEK(A*B)`` or ``HTAB A*B``, the cycles taken to handle the statement would disturb our measure and we would be comparing apples and oranges.

It is also important that we did not use ``A=A*B``: even though it's a variable assignment, we would be reusing ``A`` and it has an impact on speed. If we want to reuse ``A`` then we need to do it in both snippets.

The actual difference of **723 cycles** does not really matter. What is important is that the second snippet **actually runs** faster. Actual speed depends on several other factors which will be explained in this article.

### 🍎 Keep in mind the following

* The cycles count on this page are only an indication of the speed of the code we want to "benchmark".
* The exact cycle count is **not** what matters. 
* **Comparison** of cycles count is what we're studying. 
* Smaller cycles counts are faster and are considered as a technique to apply whenever possible.
* Sometimes, if you're not careful, using a technique explained here could be **slower** if you don't pay attention to other factors. If that's the case, it will be explained.
