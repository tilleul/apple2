# Applesoft: Need For Speed

So you like Applesoft ? And you think you can write an action game with it ? Or maybe a science program ? Yes, you can ... will it be fast ? ... Probably, no ...

BUT ! ... Where there's light, there's hope !

Here are several tricks you can use to optimize your Applesoft code for SPEED !

## Summary
  * [Declare your most used variables first](#declare-your-most-used-variables-first)



### Declare your most used variables first
Applesoft variables are stored in three separate areas: one for the numeric variables, one for the string variables and one for the arrays variables.

You don't need to declare a variable to use it. As soon as a new variable name is discovered by the Applesoft parser, a new variable is created. A value of zero is attributed to numeric variables and to items in numeric arrays, while an empty string is attributed to any new string variable or item in a string array.

Numeric (float/real and integer) variables, string variables and arrays are stored in several different ways but they all share one thing in common: once a variable is encountered and once its type has been determined, the Applesoft parser will search for the variable in one of the three memory locations in the same way: from the bottom to the top of memory.

This means that variables are not "ordered" by their names ... It means that variable Z might be before variable A... It also means that the time spent to look for a variable depends on how soon it was found in the code.

