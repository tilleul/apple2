# Applesoft: Need For Speed

So you like Applesoft ? And you think you can write an action game with it ? Or maybe a science program ? Yes, you can ... will it be fast ? ... Probably, no ...

BUT ! ... Where there's light, there's hope !

Here are several tricks you can use to optimize your Applesoft code for SPEED !

## Summary
  * [Methodology](#methodology)
  * [Declare your most used variables first](#declare-your-most-used-variables-first)



### Methodology
Not only am I going to show you that some code is faster than other, I'm going to prove it !

In order to do that, I'm using [AppleWin](https://github.com/AppleWin/AppleWin) an Apple II emulator that has a cycle counting/difference feature. What I do is set a breakpoint on the Applesoft "RUN" statement in $D912 and another on the "END" statement in $D870. So everything between "RUN" (as detected by Applesoft) and "END" in the program is considered for cycles count.

To make sure that code snippets compare, I initialize some variables with the same content, even if they're not used in the snippet, this is only to be fair for the snippet where it will be actually used. Doing so allows me to determine by difference the fastest snippet.

For example:

```BASIC
10 B=17: C=2
20 A=B/C
30 END
```

compared with

```basic
10 B=17: C=2
20 A=B/2
30 END
```

this allows me to compare the speed of line 20. If line 10 did not include ``C=12``, then it would not be a fair comparison between the two snippets.


### Declare your most used variables first
Applesoft variables are stored in three separate areas: one for the numeric variables, one for the string variables and one for the arrays variables.

You don't need to declare a variable to use it. As soon as a new variable name is discovered by the Applesoft parser, a new variable is created. A value of zero is attributed to numeric variables and to items in numeric arrays, while an empty string is attributed to any new string variable or item in a string array.

Numeric (float/real and integer) variables, string variables and arrays are stored in several different ways but they all share one thing in common: once a variable is encountered and once its type has been determined, the Applesoft parser will search for the variable in one of the three memory locations in the same way: from the bottom to the top of memory.

This means that variables are not "ordered" by their names ... It means that, in memory, variable Z might be before variable A... It also means that the time spent to look for a variable depends on how soon it was found in the code. How much time ? Let's find out.

