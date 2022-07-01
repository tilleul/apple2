# Applesoft: Need For Speed

So you like Applesoft ? And you think you can write an action game with it ? Or maybe a science program ? Yes, you can ... will it be fast ? ... Probably, no ...

BUT ! ... Where there's light, there's hope !

Here are several tricks you can use to optimize your Applesoft code for SPEED !

## Summary
  * [Methodology](#methodology)
  * [Declare your most used variables first](#declare-your-most-used-variables-first)



### Methodology
Not only am I going to show you that some code is faster than other, I'm going to prove it !

In order to do that, I'm using [AppleWin](https://github.com/AppleWin/AppleWin), an Apple II emulator that has a cycle counting/difference feature. What I do is set a breakpoint on the Applesoft "RUN" statement in $D912 and another on the "END" statement in $D870. So everything between "RUN" (as detected by Applesoft) and "END" in the program is considered for cycles count.

To make sure that code snippets compare, I initialize some variables with the same content, even if they're not used in the snippet, this is only to be fair for the snippet where it will be actually used. Doing so allows me to determine by difference the fastest snippet.

For example, this snippet:

```BASIC
10 B=17: C=2
20 A=B/C
30 END
```

is compared with

```basic
10 B=17: C=2
20 A=B/2
30 END
```

Having the same line 10 for both snippets allows me to compare the speed of line 20. If line 10 did not include ``C=12``, then it would not be a fair comparison between the two snippets.

Snippet #1 takes 8821 cycles from "RUN" to "END", while snippet #2 takes 9184 cycles. It means that the difference between ``A=B/C`` and ``A=B/2`` is **363 cycles**. It does not mean that using a variable instead of a actual number in the code is 363 cycles faster, it just means it **IS** faster. The exact cycle difference depends on several other factors, the first one, although it's probably not the most important one, being [the order in which your variables are declared](#declare-your-most-used-variables-first).

All the examples here will specify cycles count, those cycles are ALWAYS from "RUN" to "END".

### Declare your most used variables first
Applesoft variables are stored in three separate areas: one for the numeric variables, one for the string variables and one for the arrays variables.

You don't need to declare a variable to use it. As soon as a variable name is discovered by the Applesoft parser, the following happens:
* the type of the variable is determined so Applesoft knows where to look for the variable
* Applesoft scans the memory repository for the specified variable type and looks for an existing variable of the same name
* if it's not found, it means it's a new variable and the appropriate space (variable name, type, array indices, value) is reserved at the top of the memory pile where all variables of the same type reside.
* if it's found or if the variable has just been created, its value is used/replaced/computed/etc (depending on the actual code)

As you see, numeric (float/real and integer) variables, string variables and arrays are stored in several different ways but they all share one thing in common: once a variable is encountered and once its type has been determined, the Applesoft parser will search for the variable in one of the three memory locations in the same way: from the bottom to the top of memory.

This means that variables are not "ordered" by their names ... It means that, in memory, variable Z might be before variable A... It also means that the time spent to look for a variable depends on how soon it was found in the code. How much time ? Let's find out.

Let's create a variable ``A`` and another named ``Z`` with equal values, then let's print the value of variable ``A`` and then in a second snippet, the value of variable ``Z``.

```
10 A=123: Z=A
20 PRINT A
30 END
```
This takes 32389 cycles. Second snippet just prints variable ``Z`` instead of ``A``.

```
10 A=123: Z=A
20 PRINT Z
30 END
```
This takes 32423 cycles. That's a difference of 34 cycles. It looks insignificant and it is ... but it has an impact on all the other techniques I'm gonna teach you.

Let's have another example. Now this time, we will declare 26 different variables named from ``A`` to ``Z`` and see the cycles count difference when accessing the first one or the last one declared.

```
10 A=1: B=1: C=1: D=1: E=1: F=1: G=1: H=1: I=1: J=1: K=1: L=1: M=1: N=1: O=1: P=1: Q=1: R=1: S=1: T=1: U=1: V=1: W=1: X=1: Y=1: Z=1
20 PRINT A
30 END
```
This took 82980 cycles. Second snippet is identical except we access variable ``Z`` instead of variable ``A``.

```
10 A=1: B=1: C=1: D=1: E=1: F=1: G=1: H=1: I=1: J=1: K=1: L=1: M=1: N=1: O=1: P=1: Q=1: R=1: S=1: T=1: U=1: V=1: W=1: X=1: Y=1: Z=1
20 PRINT Z
30 END
```
This took 83765 cycles. The difference is 785 cycles. Again, it's not gigantic. But ! Wait ! Remember that snippet in the first section ([Methodology](#methodology)) ? It had a difference of 363 cycles just by replacing a harcoded value of ``2`` with a variable name. It would mean that if we're not careful, we might lose the advantage we took for granted.

Let me rephrase this: imagine if Z was holding a value you need to use **OFTEN** ... myself I like to put **zero** in Z because it's obviously a good variable name for such a value ...

Let's see that with two other snippets. Snippet #1 will declare ``Z`` first, snippet #2 will declare ``Z`` last and snippet #3 will not use ``Z`` but hardcoded value of ``0``

```
10 Z=0: A=1: B=1: C=1: D=1: E=1: F=1: G=1: H=1: I=1: J=1: K=1: L=1: M=1: N=1: O=1: P=1: Q=1: R=1: S=1: T=1: U=1: V=1: W=1: X=1: Y=1
20 PRINT Z
30 END
```
This took 75459 cycles

Snippet #2:
```
10 A=1: B=1: C=1: D=1: E=1: F=1: G=1: H=1: I=1: J=1: K=1: L=1: M=1: N=1: O=1: P=1: Q=1: R=1: S=1: T=1: U=1: V=1: W=1: X=1: Y=1: Z=0
20 PRINT Z
30 END
```
This took 76244 cycles, a difference of 785 cycles !

Snippet #3
```
10 A=1: B=1: C=1: D=1: E=1: F=1: G=1: H=1: I=1: J=1: K=1: L=1: M=1: N=1: O=1: P=1: Q=1: R=1: S=1: T=1: U=1: V=1: W=1: X=1: Y=1: Z=0
20 PRINT 0
30 END
```
This took 75890 cycles, a difference of only 431 cycles with the first snippet where we use Z=0 as the first declared variable, but also it's 354 cycles slower than the version where Z=0 is declared last ! Thus, negating any interest in replacing ``0`` with a variable if it's not declared in time !

So which variables should you declare first ? and with many variables to declare, how do you know if it's best to use a variable or an actual value ?
