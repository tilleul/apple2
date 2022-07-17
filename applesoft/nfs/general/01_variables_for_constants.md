# Use variables as placeholders for constant values
Where we discover that *constantly* parsing *constants* is cycles consuming.
## Summary
- [How Applesoft works with hardcoded constants](#-how-applesoft-works-with-hardcoded-constants)
- [Use variables instead of constants](#-use-variables-instead-of-constants)
- [Recommendations](#-recommendations)

## 🍎 How Applesoft works with hardcoded constants

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

## 🍎 Use variables instead of constants

It is actually faster for the Applesoft parser to locate a variable in memory and use its value than to "recreate it from scratch". So, all you need to do is save in a variable the value you want to repeatedly use.

For example:

```basic
10 N=49152
20 K=PEEK(N)
30 END
```

Line 20 takes 2303 cycles while

```basic
10 N=49152
20 K=PEEK(49152)
30 END
```

line 20 here takes 7128 cycles, that's a difference of **4825 cycles** ! This is ***HUGE*** especially when it's a statement that's going to be executed every time the main game loop cycles !

Other values will produce different results. For a comparison example, let's say we want to read the value in memory location ``zero``.

```basic
10 N=0
20 K=PEEK(N)
30 END
```

Line 20 takes 2090 cycles, while

```basic
10 N=0
20 K=PEEK(0)
30 END
```

this line 20 only takes **390** more cycles. This is because ``0`` is only 1 character, while ``49152`` is 5 characters. But anyway, even if the difference is not that important, it's faster.

## 🍎 Recommendations

Should you convert all your constants to variables ? My advice is yes, particularly for the constants used in loops or repeatedly. Among those are:

* Values you might use constantly (often powers of 2) like ``4``, ``8``, ``16``, ``32``, ``64``, ``128`` and ``256`` ... or maybe their lower limits like ``3``, ``7``, ``15``, ``31``, ``63``, ``127`` and ``255``
* Other values you will certainly use like ``0``, ``1`` and ``2``. I like to put these in variables ``Z``, ``U`` ("unit(ary)") and ``T`` (as in "two")
* Limits in your game like
  * the screen limits: think of ``VTAB 24``, ``HTAB 40``, ``SCRN(39,39)``, ``HPLOT 279,159`` or their upper boundaries like ``40``, ``280`` ``160`` and ``192``.
  * loops' low and high limits: ``0``, ``1`` up to ``9`` , ``10`` or ``19`` and ``20``, etc. Think of ``FOR I=0 TO ...`` or ``FOR I=1 TO ...``
* Usual ``PEEK/POKE/CALL`` locations like 
  * ``49152`` (last key pressed), 
  * ``49168`` (reset keyboard strobe), 
  * ``49200`` (click speaker), 
  * ``-868`` (a ``CALL`` there will clear the text line from the cursor position to the end of the line)...
  * maybe zero page locations like the collision counter in ``234``, 
  * or the next ``DATA`` address in ``125`` and ``126``, 
  * or the text window limits in ``32-35``, 
  * etc.

Whatever the value, whether it's an integer or a real <sup>(*)</sup>, this rule will **always** speed up your code, except if you're not careful about the next technique ...

<sup>(*) strings are an entirely different matter</sup>
