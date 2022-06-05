# Honoring The Code, part 1: Space Maze
Space Maze by Micro-Sparc, as published in Nibble Magazine #1, Jan-Feb 1980.

For this first episode I've chosen the very first issue of Nibble magazine, dating back to Jan-Feb 1980 ! Were you one of the lucky one to own a copy of this issue back then ? Well, I wasn't. At the time, I was only 5 and I'm not even sure we had an Apple II at home then. And also, Nibble was a US magazine that came to Europe (I'm from Belgium) mostly through their Nibble Express compendiums.

Although I did not have this issue, for a reason or another, the program we'll be talking about came to me through a disk(ette) of various basic programs. I remember vividly the graphics and the Star Wars music. Unfortunately, as we will see, the game is terrible. It's terrible today but it was also terrible back then.

Let me present you **SPACE MAZE** !

## Overview

Here's a link to the DSK file that contains the code (among others): https://archive.org/download/nibbledisks_nib01/nib01.dsk

And here are two screenshots of the game...

Instructions:

![instructions](./htc1.png)

Starting screen:

![starting screen](./htc2.png)

The objective of the game is to move your spaceship (represented by a dot) to the end of the maze as fast as possible without crashing in the walls of the maze.
Using the Apple II (analaog) joystick, you carefully give your spaceship direction and speed and try to go as far as possible. You also have to make sure you don't go out of fuel: even when you're not moving your fuel runs fast, so you have to hurry.

In itself the game concept is simple and it's not very original even for the time but the idea that this game is Applesoft only (and really short in fact) is appealing. Unfortunately the joystick control is very hard to master and even in "Easy" mode (there's a "Hard" mode where your ship is sometimes pulled in a random direction) it's nearly impossible to beat. And once you beat the game, you're forced to play in Hard mode and the only thing you can do is try to break your hiscore (which means reach the end of the maze in a shorter time).

The main problem with the game is that it's not very responsive. You can turn on sound and your ship will emit a beep every time it has moved from one point to another and by hearing the beat of the beep you know that the code is too slow to offer responsive controls.

## How the code works
Here's the full original code: [spacemaze.bas](./spacemaze.bas)

The main game routine is in lines 100-300.

Lines 100-175 will detect if the spaceship is out of the maze corridors. It's a serie of IF/THEN checking if the spaceship is within the maze boundaries.

Lines 210-300 will manage the spaceship movement (reading the joystick), plotting/unplotting the spaceship dot and also print the fuel level and spaceship coordinates.

How does the program check if the spaceship has hit a wall ? My intuition was that maybe the program used the "collision counter" in $EA (234) but this only works with Hires Shape Tables (you know DRAW/XDRAW routines to draw 2D vector shapes in hires). What it does is more simple: as the maze is hardcoded, the code checks if the spaceship is within one of the maze rectangles sections. This is what lines 100-162 do. They check every rectangle and set a variable Z that contains the rectangle number where the spaceship is (among 16 rectangles).

Here's a representation of the 16 rectangle zones the maze is made of.
![rectangle zones](./htc3.png)

The main problem is that the code goes through ALL of the coordinates testing for EACH rectangle zone EVERY time, even if it has found already found the zone where the spaceship is. Each of these tests is made of 4 conditions (testing 2 limits of X and then 2 limits of Y). That's 4x16=64 conditions in a row ... and this is killing the game.

16 lines like this one will kill the game: 
```basic
100  IF (X >  = 10 AND X <  = 80) AND (Y >  = 80 AND Y <  = 100) THEN Z = 1
```

It should be noted that although Z holds the zone number where the spaceship is, this variable is not used for anything else but testing if it's non-zero (in which case the spaceship is in none of the zones, thus out of the maze) and also that Z is not even properly set as lines 135 to 142 all set Z to 6 as if it was the same zone. Also, the comments indicate that there are 11 zones when in fact there are 16. It looks like during the development the maze was modified from 11 to 16 zones. And one last thing, some zones limits overlap but that's ok.
