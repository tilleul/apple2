# Declare your most used variables first
Where we learn that first come is first served.
## Summary
- [How Applesoft variables work](#-how-applesoft-variables-work)
- [Variables declared later in the code are recovered last](#-variables-declared-later-in-the-code-are-recovered-last)
- [With many variables, it's essential to follow this rule](#-with-many-variables-its-essential-to-follow-this-rule)
- [Recommendations](#-recommendations)

## 🍎 How Applesoft variables work

Applesoft variables are stored in two separate areas: 

* right after the program's last line is an area pointed by ``VARTAB`` (in zero-page vector ``$69-$6A`` -- decimal ``105-106``) where all the real, integer and string variables are defined and stored <sup>(*)</sup>. It's also where references to "functions" created by ``DEF FN`` are stored.
* just after that area is another area, pointed by the vector ``ARYTAB`` (in ``$6B-$6``, decimal ``107-108``) where all the arrays are stored.

<sup>(*) string variables are not stored in that area, but pointers to their values are stored there. The actual values of string variables being either in the program code itself or in a special area after the array storage area</sup>

You don't need to declare a variable to use it. As soon as a variable name is discovered by the Applesoft parser, the following happens:

* the type of the variable is determined so Applesoft knows where to look for the variable's name (``VARTAB`` or ``ARYTAB``)
* Applesoft scans the memory repository for the specified variable type and looks for an existing variable of the same name
  * if it's not found, it means it's a new variable. 
    * If the code where it appears is a variable assignment, then the appropriate space (variable name, type, array indices, value) is reserved at the top of the memory pile where all variables of the same type reside (optionally moving the ``ARYTAB`` area up if a new real/integer/string/function variable needs to be declared). 
    * If it's not a variable assignment, then the variable type's default value is referenced for next step but the variable IS NOT created.
  * if the variable already exists, its value is referenced for the next step
* then the value of the variable is used/replaced/computed/etc. (depending on the actual code)

As you see, numeric (float/real and integer) variables, string variables and arrays are stored in several different ways but they all share one thing in common: once a variable is encountered and once its type has been determined, the Applesoft parser will search for the variable in one of the two memory locations in the same way: from one end to the other.

This means that variables are not "ordered" by their names ... It means that, in memory, variable Z might be stored/referenced before variable A... It also means that the time spent to look for a variable depends on how soon it was found in the code. How much time ? Let's find out.

## 🍎 Variables declared later in the code are recovered last

Let's create a variable ``A`` and another named ``Z`` with equal values, then let's print the value of variable ``A`` and then in a second snippet, the value of variable ``Z``.

```basic
10 A=123: Z=A
20 PRINT A
30 END
```

Line 20 takes 27864 cycles. The second snippet just prints variable ``Z`` instead of ``A``.

```basic
10 A=123: Z=A
20 PRINT Z
30 END
```

This takes 27898 cycles. That's a difference of 34 cycles. It looks **insignificant** and, as such, **it is** ! but it has an impact on all the other techniques I'm gonna teach you.

Let's have another example. Now this time, we will declare 26 different variables named from ``A`` to ``Z`` and see the cycles count difference when accessing the first one or the last one declared.

```basic
10 A=0: B=1: C=1: D=1: E=1: F=1: G=1: H=1: I=1: J=1: K=1: L=1: M=1: N=1: O=1: P=1: Q=1: R=1: S=1: T=1: U=1: V=1: W=1: X=1: Y=1: Z=0
20 PRINT A
30 END
```

Line 20 took 20241 cycles. Second snippet is identical except we access variable ``Z`` instead of variable ``A``. You'll notice that the values of these two variables are identical to eliminate the possible fact that different values are handled with different speeds.

```basic
10 A=0: B=1: C=1: D=1: E=1: F=1: G=1: H=1: I=1: J=1: K=1: L=1: M=1: N=1: O=1: P=1: Q=1: R=1: S=1: T=1: U=1: V=1: W=1: X=1: Y=1: Z=0
20 PRINT Z
30 END
```

This took 21026 cycles. The difference is **only** 785 cycles. Let's be honest, it's not gigantic. 

But ! Wait ! Remember that snippet in the section [Use variables as placeholders for constant values](#use-variables-as-placeholders-for-constant-values) where we handled value ``0`` ? 

It had a difference of 390 cycles just by replacing a hardcoded/constant value of ``0`` with a variable name. It would mean that if we're not careful, we might lose the advantage we took for granted.

## 🍎 With many variables, it's essential to follow this rule

Let me rephrase this: imagine if Z was holding a value you need to use **OFTEN** ... myself I like to put **zero** in Z because it's obviously a good variable name for such a value ...

Let's see that with two other snippets. Snippet #1 will declare ``Z`` first, snippet #2 will declare ``Z`` last and snippet #3 will not use ``Z`` but a hardcoded value of ``0``

```basic
10 Z=0: A=0: B=1: C=1: D=1: E=1: F=1: G=1: H=1: I=1: J=1: K=1: L=1: M=1: N=1: O=1: P=1: Q=1: R=1: S=1: T=1: U=1: V=1: W=1: X=1: Y=1
20 PRINT Z
30 END
```

Line 20 took 20241 cycles (same cycle count as when ``A`` was declared first and we wanted to print the value of ``A``)

Snippet #2:

```basic
10 A=0: B=1: C=1: D=1: E=1: F=1: G=1: H=1: I=1: J=1: K=1: L=1: M=1: N=1: O=1: P=1: Q=1: R=1: S=1: T=1: U=1: V=1: W=1: X=1: Y=1: Z=0
20 PRINT Z
30 END
```

Line 20 took 21026 cycles, it's **slower**, with a difference of 785 cycles !

Snippet #3

```basic
10 A=0: B=1: C=1: D=1: E=1: F=1: G=1: H=1: I=1: J=1: K=1: L=1: M=1: N=1: O=1: P=1: Q=1: R=1: S=1: T=1: U=1: V=1: W=1: X=1: Y=1: Z=0
20 PRINT 0
30 END
```

Line 20 took 20672 cycles, a difference of only 431 cycles with the first snippet where we use ``Z=0`` as the first declared variable, but also it's 354 cycles **faster** than the version where ``Z=0`` is declared last ! Thus, negating any interest in replacing ``0`` with a variable if it's not declared in time !

## 🍎 Recommendations

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
* if the variable is used after an ``IF/THEN`` statement, take into account how likely the condition will evaluate to true or not.

## 🍎 Final example to sum it all up

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
