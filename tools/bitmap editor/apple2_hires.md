# Apple ]\[ hires
## Structure of the hires screen in RAM
The Apple ]\[ has 2 hires pages. One in $2000-$3FFF. The second one in $4000-$5FFF. Each page is thus 8192 bytes long.

The dimensions of one hires page is 40 bytes wide and 192 lines high. 40x192 = 7680 bytes. 512 bytes are "missing" and in fact not used/displayed.

The hires screen is divided in 3 sections of 64 lines. Each section is then divided in 8 sub-sections of 8 lines, each itself divided in 8 sub-sub-sections representing the lines themselves.

To better understand this division, it's easier to POKE bytes into RAM and see what happens.

A POKE 8192,
