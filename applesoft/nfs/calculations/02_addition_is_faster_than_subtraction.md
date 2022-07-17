# Addition is faster than subtraction
Where we learn that negativity might be a positive thing even though subtraction is not.
## Summary
* [Simple cycles comparison](#-simple-cycles-comparison)
* [Adding negative numbers is only slightly faster than subtraction](#-adding-negative-numbers-is-only-slightly-faster-than-subtraction)
* [Avoiding subtraction: is it worth it ?](#-avoiding-subtraction-is-it-worth-it-)
* [When is it worth to substitute subtraction with addition then ?](#-when-is-it-worth-to-substitute-subtraction-with-addition-then-)
* [Recommendations](#-recommendations)

## 🍎 Simple cycles comparison

```basic
10 A = 123: B = 85: C = 0
20 C = A+B
30 END
```

The addition of ``A+B`` and assignment of the result to variable ``C`` in line 20 takes 2171 cycles.

Now if we had this line instead

```basic
20 C = A-B
```

It would take 2327 cycles, a difference of **156** cycles in favor of addition.

Knowing that, your initial intuition would be to replace subtraction with additions whenever possible. It's easy as all you have to do is to make the second operand negative. Unfortunately ...

## 🍎 Adding negative numbers is only slightly faster than subtraction

With the previous example, if `B` is negative, we have

```basic
10 A = 123: B = -85: C = 0
20 C = A+B
30 END
```

Line 20 takes 2307 cycles, which is marginally faster (20 cycles) than subtracting a positive number. Is it always like that ?

## 🍎 Avoiding subtraction: is it worth it ?

Here's a real life example where you might be tempted to add a negative number instead of subtracting a positive number to obtain the same result.

Let's say you're trying to center the contents of ```A$``` on screen, your code will look like

```basic
10 D=2: V=20: A$ = "APPLESOFT: THE NEED FOR SPEED"
20 HTAB V-LEN(A$)/D
30 PRINT A$
40 END
```

Line 20 takes 5846 cycles. Now, if you set `D=-2` and use addition instead of subtraction:

```basic
10 E=-2: V=20: A$ = "APPLESOFT: THE NEED FOR SPEED"
20 HTAB V+LEN(A$)/E
30 PRINT A$
40 END
```

Line 20 now takes 5826 cycles, which is only 20 cycles faster.

Even worse: it's likely you'll need the constant ``2`` somewhere in your code and so you'll probably need to assign it to a variable. So now your code looks like this:

```basic
10 D=2: V=20: A$ = "APPLESOFT: THE NEED FOR SPEED": E=-2
20 HTAB V+LEN(A$)/E
30 PRINT A$
40 END
```

Line 20 takes now 5928 cycles ! This is 82 cycles **slower** than subtraction ! Even if we declare ``E`` earlier:

```basic
10 D=2: E=-2: V=20: A$ = "APPLESOFT: THE NEED FOR SPEED"
```

(line 20 is still an addition), this again takes 5928 cycles ! It's only when we declare ``E`` before ``D`` that 

```basic
10 E=-2: D=2: V=20: A$ = "APPLESOFT: THE NEED FOR SPEED"
```

we see an improvement: 5894 cycles ! But compared to negation (5846 cycles), it is still slower ! We need to declare ``D`` last to see an advantage (because ``D`` is not used anymore in our snippets).

```basic
10 E=-2: V=20: A$ = "APPLESOFT: THE NEED FOR SPEED": D=2
```

We now have 5826 cycles for line 20, this is just 20 cycles faster than if we had used subtraction.

As you can imagine, inverting the order of declaration of ``E`` and ``D`` is not worth it. ``D`` is now declared last, which might have an impact on speed on other parts of our code where the constant ``2`` is more important than ``-2`` ...

## 🍎 When is it worth to substitute subtraction with addition then ?

Adding the negative of a number (instead of subtraction) has rarely a positive impact on speed. 

But there are other times when you can substitute negation and addition and gain something in return: in comparisons.

You certainly know that

```basic
IF A > B-C THEN ...
```

can be rewritten as

```basic
IF A+C > B THEN ...
```

This also works with any other comparison operator: ``=``, ``<>``, ``>``, `<`, `>=` and `<=`

Let's just see how much faster it is with a simple example.

```basic
10 A=10: B=20: C=9
20 IF A>B-C THEN D=A
30 END
```

Line 20 took 3253 cycles. Now if we replace line 20 with

```basic
20 IF A+C>B THEN D=A
```

it only takes 3099 cycles, which is 154 cycles faster.

## 🍎 Recommendations

* Addition is faster than subtraction, so whenever possible use addition instead of subtraction, unless it means using a negative number for the second operand of the addition <sup>(*)</sup>.

* Because of that restriction, you probably won't be able to substitute subtraction with addition much for general calculations.

* However, you will always improve the speed if the substitution occurs within a comparison.

<sup>(*) Negative constants to avoid subtraction are bad: you would need to declare those before their positive counterparts and you would only win 20 cycles. And more than that, you would probably lose more cycles because your positive constants (and others) are declared later.</sup>
