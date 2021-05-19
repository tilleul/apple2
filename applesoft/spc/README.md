# Use SPC() to repeat any character !
## Introduction
You know how `SPC()` can be used to PRINT a number of space characters. For example `PRINT SPC(10)` will print 10 space characters.

Why didn't they allow to print something else than space characters ? It would have been interesting (?) to have the ability to repeat a sequence of any character. 

Maybe like `PRINT REPT("*",10)` would print 10 asterisks.

But Applesoft does not provide such an instruction. So are we doomed to use `PRINT "**********"`?

Here's a technique that will allow you to repeat any character, even in `FLASH` and `INVERSE` without using additional 6502 routines.

## Discovery
Let's see something weird ...

<img src="spc1.png" align="left" width=200px>At the Applesoft prompt, type `FLASH`.

Then `PRINT SPC(10)`. You should now see 10 flashing space characters.
Now, press `CTRL-BREAK`. This exits the "flash" mode (do no type `NORMAL` !!).
Type `PRINT SPC(10)` again. And ...

WOW ! WHAT IS THAT ??

What are those inverted single quote characters doing here ? "Something" has replaced space characters with those inverted single quotes ...

<img src="spc2.png" align="left" width=200px>If you have a loaded Applesoft program, I encourage you to `LIST` it. If not, quickly type a short one and see the results ...

As you can see, something is messed up !

## Explanation
To understand what's happening here, you need to know how characters are printed on screen by Applesoft.

The general routine to print characters on screen is in `$DB5C`.
Here's the routine, taken from [S-C documentor website](http://www.txbobsc.com/scsc/scdocumentor/)

                   1950 *      PRINT CHAR FROM (A)
                   1960 *
                   1970 *      NOTE: POKE 243,32 ($20 IN $F3) WILL CONVERT
                   1980 *      OUTPUT TO LOWER CASE.  THIS CAN BE CANCELLED
                   1990 *      BY NORMAL, INVERSE, OR FLASH OR POKE 243,0.
                   2000 *--------------------------------
    DB5C- 09 80    2010 OUTDO  ORA #$80     PRINT (A)
    DB5E- C9 A0    2020        CMP #$A0     CONTROL CHR?
    DB60- 90 02    2030        BCC .1       SKIP IF SO
    DB62- 05 F3    2040        ORA FLASH.BIT   =$40 FOR FLASH, ELSE $00
    DB64- 20 ED FD 2050 .1     JSR MON.COUT "AND"S WITH $3F (INVERSE), $7F (FLASH)
    DB67- 29 7F    2060        AND #$7F
    DB69- 48       2070        PHA
    DB6A- A5 F1    2080        LDA SPEEDZ   COMPLEMENT OF SPEED #
    DB6C- 20 A8 FC 2090        JSR MON.WAIT   SO SPEED=255 BECOMES (A)=1
    DB6F- 68       2100        PLA
    DB70- 60       2110        RTS

The routine is called with the accumulator containing the character to print every time Applesoft needs to print something (like when using `PRINT` or `INPUT` or ... `SPC` !)

The routine that will effectively print the character on screen is `COUT` (in `$FDED`here named `MON.COUT`) but this routine here is the pre-treatment of the character to print.

As you can see, before calling `MON.COUT`, an `ORA` with zero-page memory `$F3` is executed. This `ORA` is needed to display characters in flash mode. The problem is that `$F3`, even after a `CTRL-BREAK` is not reset and still contains `#$40` (decimal 64), meaning that Applesoft is still (partially -- see below why) in flash mode.

But if it's in flash mode, how comes it prints NORMAL single quotes and not flashing characters ? Because `$F3` is just a mask and is not enough to flash the characters on screen. Another mask, in zero-page `$32` is also used, but this time by the `MON.COUT` routine. In fact `$32`is usually considered to be the memory that indicates if we are in normal (value `#$FF`, decimal `255`), flash (value `#$7F`, decimal `127`) or inverse (value `#$3F`, decimal `63`) modes. But for the flash mode, the mask in `$F3` is equally primordial. In fact, even in normal and inverse modes, the value in `$F3 `has an impact since the `ORA` is called whatever the display mode is.

So, before any character is displayed on screen by Applesoft, two masking operation occur on the ASCII value of the character.

 1. an `ORA` with the value in `$F3`
 2. an `AND` with the value in `$32`

`CTRL-BREAK` reset the value in `$32` to `255` ("normal" display mode) but it does not touch the value in `$F3`. That's why we have these display glitches if we `CTRL-BREAK` after `FLASH`. Clearly, it's a bug.

Of course Applesoft expects and uses some specific values in `$F3` and `$32`.

|  | NORMAL  | FLASH | INVERSE |
|--|--|--|--|
| **$32** |  255 ($FF)| 127 ($7F) | 63 ($3F) |
| **$F3** | 0 ($00) | 64 ($40) | 0 ($00)

Now
