# Use addition instead of multiplication by 2
Where fundamentals in mathematics might be useful for speed.
## Summary
* [Multiplication is just another form of addition](#-multiplication-is-just-another-form-of-addition)
* [Restrictions](#-restrictions)


## 🍎 Multiplication is just another form of addition.

And when you're multiplying by 2, it's faster to use the addition counterpart. 

This is **always** true if what you want to do is ``A=2*B`` and that you use variables and replace hardcoded constants with variables. If you don't, you might get mitigated results.

Demonstration:

```basic
10 A=123: B=2
20 C = A*B
30 END
```

Line 20 takes 3236 cycles.

Snippet #2:

```basic
10 A=123: B=2
20 C = A+A
30 END
```

Line 20 takes now 2321 cycles, a bonus of 915 cycles.

Of course it would be even more drastic if you didn't store (and use !) the constant ``2`` in variable ``B``

```basic
10 A=123: B=2
20 C = A*2
30 END
```

Line 20 takes 3599 cycles, that's 1278 cycles more than using an addition !

Unfortunately, this tip does not work for anything else than multiplication by 2. Let's see what happens with multiplication by 3:

```basic
10 A=123: B=3
20 C = A*B
30 END
```

Line 20 takes 3236 cycles (again)
While line 20 of snippet #2:

```basic
10 A=123: B=2
20 C = A+A+A
30 END
```

takes 3287 cycles, that is 51 cycles slower. Of course it gets worse with higher multiplication values.

## 🍎 Restrictions

It's also important to notice that this will work only if you already have a variable with the value you want to double.

Let's consider the following, you want to double the result of another calculation, like a division with code like ``D=2*A/B``

Snippet #1

```basic
10 A=123: B=45: C=2: D=0: E=0
20 E=C*A/B
30 END
```

Line 20 takes 6795 cycles. Notice how line 10 declares five variables ``A-E``. These variables will be used in the subsequent snippets. Declaring them, even though they're not used, allows us to ignore the extra cycles needed to create a new variable.

Now let's try with the addition:

```basic
10 A=123: B=45: C=2: D=0: E=0
20 D=A/B+A/B
30 END
```

Line 20 takes 9072 cycles, which is slower (2277 cycles slower).
Now you might think that storing the result of ``A/B`` would be faster. It's not. Except, maybe if you intend to use that result elsewhere in your code in which case it might be worth to spend those cycles storing a result in a variable.

First snippet demonstrates the speed if you don't care about the result of ``A/B``

```basic
10 A=123: B=45: C=2: D=0: E=0
20 D=A/B: E=D+D
30 END
```

Line 20 takes 7090 cycles, it's 295 cycles slower than using directly ``E=C*A/B``.

This second snippet illustrates the speed if the result of ``A/B`` is of any interest and is meant to be reused several other times: it's thus calculated on line 10 and excluded from cycles count.

```basic
10 A=123: B=45: C=2: D=A/B: E=0
20 E=D+D
30 END
```

line 20 takes only 2409 cycles. Using ``20 E=C*D`` would take 2283 cycles more.
