# Apple ]\[ hires
## Structure of the hires screen in RAM
The Apple ]\[ has 2 hires pages. One in $2000-$3FFF. The second one in $4000-$5FFF. Each page is thus 8192 bytes long.

The dimensions of one hires page is 40 bytes wide and 192 lines high. 40x192 = 7680 bytes. 512 bytes are "missing" and in fact not used/displayed.

The hires screen is divided in 3 sections of 64 lines. Each section is then divided in 8 sub-sections of 8 lines, each itself divided in 8 sub-sub-sections representing the lines themselves.

To better understand this division, it's easier to POKE bytes into RAM and see what happens.

A `POKE 8192,255`will plot 7 pixels on the top left corner of the hires screen (page 1). Poking the next memory address (8193), will plot 7 more pixels on line 0 of the hires screen.

So to draw the entire line 0 we could `RUN` this code

    10 HGR
    20 FOR I = 0 TO 39: POKE 8192+I, 255: NEXT

![screenshot](img/apple2_hires_line0.png)

8192 + 40 = 8232 ($2028) is the next byte in memory. But

    POKE 8232,255

will not plot 7 pixels on line 1 but on line 64 !
If we slightly modify the above code to POKE the first 3 lines in memory, we have

    10 HGR
    20 A = 8192: REM $2000
    30 FOR J = 0 TO 2
    40 FOR I = 0 TO 39
    50 POKE A, 255
    60 A = A+ 1
    70 NEXT I,J
    80 PRINT A

The result is this

![screenshot](img/apple2_hires_lines0-64-128.png)
