10 HOME
20 X = 255: Y=0: REM INIT VALUES
30 POKE 243,0: REM RESET ORA MASK
40 POKE 50, X: REM RESET AND MASK
50 VTAB 1
60 INPUT "ASCII (1-255; 0 EXITS) ? ";Z
70 IF NOT Z THEN END
80 INPUT "NORMAL/FLASH/INVERSE (N/F/I) ? ";N$
90 IF N$ = "F" THEN Y=128
100 IF N$ = "I" THEN Y=192
110 IF (Z>=64 AND Z<=95) OR (Z>=192 AND Z<=223) THEN X = 223: REM PREPARE END MASK FOR ASCII 64-95 OR 192-223
120 POKE 50,X-Y: REM SET NORMAL/FLASH/INVERSE MASK
130 POKE 243, Z: REM SET ORA MASK
140 VTAB 1
150 PRINT SPC(240): REM FILL THE SCREEN !
160 PRINT SPC(240)
170 PRINT SPC(240)
180 PRINT SPC(240)
190 GOTO 20