# Use one-letter variables names whenever possible
Where it's clear that longer is not better.
## Summary
- [Forget about meaningful variables names](#-forget-about-meaningful-variables-names)
- [Recommendations](#-recommendations)

## 🍎 Forget about meaningful variables names

Applesoft only supports variables names made of one or two characters. The first character **must** be a letter, while the second character may be a letter **or** a number.

It is allowed to name variables with more characters but these are ignored, meaning that variable ``ABRACADABRA`` is really stored as ``AB`` and maybe referenced later in the code with that name. It also means that you can't really have a variable named ``A10`` as it will be in fact variable ``A1``.

This behavior is true for any kind of variable (float, integer, string, array of (float/integer/strings), and even ``DEF FN`` which are just referenced as another kind of variable). It means that for every variable type, you can't have more than 26 + 26 * (26+10) variables = 962 different variables names.

The problem is that the Applesoft parser will take 56 cycles for every extra character in a variable name.

```basic
10 A=17
20 END
```

Line 10 takes 2776 cycles. Now, let's use variable ``AB`` instead of ``A``:

```basic
10 AB=17
20 END
```

Line 10 now takes 2832 cycles, that's 56 more cycles. Now, for the extreme example:

```basic
10 ABRACADABRA = 17
20 END
```

Line 10 takes now 3336 cycles, which is 504 cycles slower, which is exactly 56 cycles for each of the extra 9 characters after ``AB``.

Every time a variable is parsed, it takes 56 more cycles to parse a 2-characters variable name than if the variable name was only 1 character. And this is true for every use of the variable: assignment, calculation, print, memory read/write, 6502 subroutine call, etc.

## 🍎 Recommendations

- Use one-letter variable names as much as possible in your main loop. 
  
  - It means, **yes**, you need to avoid ``OX,OY`` for the previous cycle's ``X,Y`` coordinates. 
  
  - If needed, re-use variables names declared before starting the main loop if these variables hold values you don't care about anymore.
  
  - Remember to [declare your most used variables first](02_declare_most_used_variables_first.md) !

- Use as few two-characters variables names as possible in your main loop, as each 2-characters variable name will take 56 more cycles **just** to parse the name of the variable in the code.

- **NEVER** use more than two-characters variables names in your main loop <sup>(*)</sup>.

<sup>(*) you should apply this rule even if you're not looking for speed as confusion is waiting behind the corner: variable ``LEVEL`` and variable ``LENGTH`` both refer to variable ``LE`` ...</sup>
