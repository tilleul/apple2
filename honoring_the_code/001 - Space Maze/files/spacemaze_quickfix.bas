 3  REM  *************************
 4  REM  ** SPACE MAZE          **
 5  REM  ** MICRO-SPARC         **
 6  REM  ** P.O. BOX 325        **
 7  REM  ** LINCOLN MASS 01773  **
 8  REM  ** COPYRIGHT C 1980    **
 9  REM  *************************
 12  REM  THE FOLLOWING SUBROUTINE GOES INTO MEMORY BLOCK HEX $30E (782), THE TONES RESPOND TO POKE 0 TO 255
 13  REM  PITCH= POKE780,P   DURATION=POKE781,D
 15  POKE 782,173: POKE 783,48: POKE 784,192: POKE 785,136: POKE 786,208: POKE 787,5: POKE 788,206: POKE 789,13: POKE 790,3
 20  POKE 791,240: POKE 792,9: POKE 793,202: POKE 794,208: POKE 795,245: POKE 796,174: POKE 797,12: POKE 798,3: POKE 799,76
 25  POKE 800,14: POKE 801,3: POKE 802,96
 27  CALL  - 936
 30  VTAB 7: INVERSE : HTAB 10: PRINT "** SPACE MAZE **": VTAB 23: HTAB 4: PRINT "COPYRIGHT 1980..MICRO-SPARC, INC.": NORMAL 
 31  VTAB 9: PRINT "YOU WILL PILOT A SPACE CRUISER THRU THE": PRINT "STAR MAZE TO REACH THE PRIZED DILITHIUM": PRINT "CRYSTALS AT THE CENTER OF THE MAZE": INVERSE : PRINT 
 32  PRINT "BE CAREFUL! IN THE HARD VERSION OF THE": PRINT "GAME YOUR SHIP IS PULLED BY HOSTILE  ": PRINT "MAGNETIC FORCES.. SO TAKE CARE       "
 33  PRINT "NOT TO CRASH!!!!!!!!!!!!!!!!!!!!!!!!!!!"
 34  NORMAL : PRINT "DO YOU WANT YOUR SHIP SIGNAL SOUNDS? ": INPUT "TYPE Y OR N";NS$: INPUT "EASY OR HARD GAME? TYPE 'E' OR 'H'";HD$
 38  GOSUB 500: PRINT "DO YOU WANT STARWARS MUSIC EACH GAME?": INPUT "Y OR N ";M$
 40  HGR : GOSUB 2000
 45  IF M$ <  > "N" THEN  GOSUB 500
 50  GOTO 200
 97  REM  THE FOLLOWING SUBROUTINE TESTS WHETHER X AND Y ARE CONTAINED IN THE SERIES OF 11 RECTANGLES MAKING UP THE MAZE
 98  REM  IF X AND Y ARE SENSED, THEN Z IS SET THE NUMBER OF THE RECTANGLE.  AT THE END OF THE TEST, Z IS TESTED. IF Z IS GREATER THAN
 99  REM  ZERO IT MEANS X AND Y ARE IN BOUNDS. IF Z=0 THEN NO X AND Y HAVE BEEN SENSED IN BOUNDS AND THE PROGRAM GOES TO THE CRASH SUBRTNE.
 100  IF (X >  = 10 AND X <  = 80) AND (Y >  = 80 AND Y <  = 100) THEN Z = 1: GOTO 175
 110  IF (X >  = 60 AND X <  = 100) AND (Y >  = 100 AND Y <  = 120) THEN Z = 2: GOTO 175
 120  IF (X >  = 80 AND X <  = 100) AND (Y >  = 120 AND Y <  = 158) THEN Z = 3: GOTO 175
 125  IF (X >  = 100 AND X <  = 140) AND (Y >  = 140 AND Y <  = 158) THEN Z = 4: GOTO 175
 130  IF (X >  = 120 AND X <  = 180) AND (Y >  = 120 AND Y <  = 140) THEN Z = 5: GOTO 175
 135  IF (X >  = 160 AND X <  = 220) AND (Y >  = 140 AND Y <  = 158) THEN Z = 6: GOTO 175
 137  IF (X >  = 200 AND X <  = 220) AND (Y >  = 110 AND Y <  = 140) THEN Z = 6: GOTO 175
 138  IF (X >  = 220 AND X <  = 265) AND (Y >  = 110 AND Y <  = 130) THEN Z = 6: GOTO 175
 139  IF (X >  = 245 AND X <  = 265) AND (Y >  = 40 AND Y <  = 110) THEN Z = 6: GOTO 175
 140  IF (X >  = 215 AND X <  = 245) AND (Y >  = 40 AND Y <  = 60) THEN Z = 6: GOTO 175
 141  IF (X >  = 215 AND X <  = 235) AND (Y >  = 60 AND Y <  = 100) THEN Z = 6: GOTO 175
 142  IF (X >  = 180 AND X <  = 235) AND (Y >  = 80 AND Y <  = 100) THEN Z = 6: GOTO 175
 145  IF (X >  = 180 AND X <  = 200) AND (Y >  = 60 AND Y <  = 100) THEN Z = 8: GOTO 175
 150  IF (X >  = 140 AND X <  = 180) AND (Y >  = 60 AND Y <  = 80) THEN Z = 9: GOTO 175
 160  IF (X >  = 100 AND X <  = 160) AND (Y >  = 40 AND Y <  = 60) THEN Z = 10: GOTO 175
 162  IF (X >  = 100 AND X <  = 120) AND (Y >  = 60 AND Y <  = 80) THEN Z = 11: GOTO 175
 165  IF (X >  = 106 AND X <  = 114) AND (Y >  = 66 AND Y <  = 74) THEN 3000: REM  BRANCH TO WIN
 170  IF Z <  = 0 THEN 4000: REM  BRANCH TO CRASH...NO FLAGS WERE SET TO INDICATE PRESENCE IN THE MAZE...THEREFORE MUST BE OUTSIDE.
 175 Z = 0: RETURN : REM  RESET Z EACH TEST
 200 X = 15:Y = 90:HV = 0:VV = 0:TM = 600:XO = 15:YO = 90: CALL  - 936
 210  IF  PDL (0) >  = 165 THEN HV = HV + 1
 220  IF  PDL (0) <  = 90 THEN HV = HV - 1
 230  IF  PDL (1) >  = 165 THEN VV = VV + 1
 231  IF HD$ = "E" THEN 240
 232  IF  RND (1) < .05 THEN HV = HV + 1
 233  IF  RND (1) > .95 THEN VV = VV + 1
 240  IF  PDL (1) <  = 90 THEN VV = VV - 1
 242 X = XO + HV:Y = YO + VV
 243 TM = TM - 1: VTAB 21: PRINT  TAB( 10)"FUEL LEFT= ";TM: IF TM < 100 THEN  VTAB 21: CALL  - 868: PRINT  TAB( 10)"FUEL LEFT= ";TM
 245  VTAB 22: CALL  - 868: PRINT "HORIZ =";HV;: PRINT  TAB( 25)"VERTICAL =";VV
 260  HCOLOR= 3: HPLOT X,Y: IF PT = 0 THEN 267
 265  VTAB 23: PRINT  TAB( 4)"PREVIOUS RECORD SCORE IS: ";PT
 267  IF TM <  = 0 THEN  CALL  - 936: FLASH : PRINT  TAB( 10)"OUT OF FUEL";: PRINT  TAB( 10)" ": GOSUB 4000
 270  IF X = XO AND Y = YO THEN 300
 280  HCOLOR= 0: HPLOT XO,YO: IF NS$ = "N" THEN 300
 285  POKE 780,150: POKE 781,10: CALL 782
 300 XO = X:YO = Y: GOSUB 100: GOTO 210
 498  REM  THE 500 SUBRTNE SETS UP THE MUSIC. M1=PITCH,  M2=DURATION.  700 PLAYS IT.
 500 M1 = 230:M2 = 75: GOSUB 700:M1 = 126:M2 = 250: GOSUB 700:M1 = 170:M2 = 250: GOSUB 700:M1 = 190:M2 = 75: GOSUB 700
 510 M1 = 203:M2 = 75: GOSUB 700:M1 = 230:M2 = 75: GOSUB 700:M1 = 126:M2 = 250: GOSUB 700:M1 = 170:M2 = 250: GOSUB 700
 515 M1 = 190:M2 = 100: GOSUB 700:M1 = 203:M2 = 100: GOSUB 700:M1 = 190:M2 = 100: GOSUB 700:M1 = 230:M2 = 250: GOSUB 700: RETURN 
 700  POKE 780,M1: POKE 781,M2: CALL 782: RETURN 
 2000  HCOLOR= 3: HPLOT 0,0 TO 279,0 TO 279,159 TO 0,159 TO 0,0
 2001  HPLOT 70,10 TO 60,10 TO 60,20 TO 70,20 TO 70,30 TO 60,30: HPLOT 75,30 TO 75,10 TO 85,10 TO 85,20 TO 75,20: HPLOT 90,30 TO 90,10 TO 100,10 TO 100,30: HPLOT 90,20 TO 100,20
 2002  HPLOT 115,10 TO 105,10 TO 105,30 TO 115,30: HPLOT 130,10 TO 120,10 TO 120,30 TO 130,30: HPLOT 120,20 TO 125,20: HPLOT 140,30 TO 140,10 TO 146,20 TO 152,10 TO 152,30
 2003  HPLOT 158,30 TO 158,10 TO 168,10 TO 168,30: HPLOT 158,20 TO 168,20: HPLOT 173,10 TO 183,10 TO 173,30 TO 183,30: HPLOT 198,10 TO 188,10 TO 188,30 TO 198,30: HPLOT 188,20 TO 193,20
 2005  HPLOT 10,80 TO 80,80 TO 80,100 TO 100,100 TO 100,140 TO 120,140 TO 120,120 TO 180,120
 2010  HPLOT 180,120 TO 180,140 TO 200,140 TO 200,110 TO 245,110 TO 245,60 TO 235,60 TO 235,100 TO 180,100 TO 180,80 TO 140,80 TO 140,60 TO 120,60 TO 120,80 TO 100,80
 2015  HPLOT 100,80 TO 100,40 TO 160,40 TO 160,60 TO 200,60 TO 200,80 TO 215,80 TO 215,40 TO 265,40 TO 265,130 TO 220,130 TO 220,158 TO 160,158
 2020  HPLOT 220,158 TO 160,158 TO 160,140 TO 140,140 TO 140,158 TO 80,158 TO 80,120 TO 60,120 TO 60,100 TO 10,100
 2030  HCOLOR= 3: HPLOT 106,66 TO 114,66 TO 114,74 TO 106,74 TO 106,66
 2033  HPLOT 108,68 TO 112,72: HPLOT 108,72 TO 112,68: RETURN 
 3000  POP : TEXT : FOR NN = 250 TO 0 STEP  - 15: PRINT "** WINNER **";: POKE 780,NN: POKE 781,10
 3005  CALL 782: NEXT NN: FOR N = 1 TO 500: NEXT N: PRINT : PRINT 
 3010  IF TM > PT THEN  HOME : VTAB 10: FLASH : PRINT "CONGRATULATIONS!": NORMAL : PRINT "YOU'VE BEATEN THE PREVIOUS HIGH SCORE ": PRINT "OF ";PT;" WITH YOUR SCORE OF ";TM
 3011 GC = GC + 1: IF GC = 1 THEN  PRINT : PRINT "IF YOU'VE BEEN PLAYING THE EASY GAME": PRINT "YOU'RE A WINNER!  NOW WE'LL ADVANCE TO": PRINT "THE HARD GAME":HD$ = "H"
 3012  IF TM > PT THEN PT = TM
 3015  GOTO 4007
 4000  POP : TEXT : FLASH : FOR NN = 1 TO 100: PRINT "** CRASH **";: NEXT NN: NORMAL 
 4005  FOR NN = 1 TO 250 STEP 50: POKE 780,NN: POKE 781,50: CALL 782: NEXT NN
 4006  FOR NN = 1 TO 2000: NEXT NN: CALL  - 936
 4007  INPUT "ANOTHER MISSION? HIT RETURN";A$: HGR : GOTO 40