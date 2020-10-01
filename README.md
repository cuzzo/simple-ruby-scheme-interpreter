# Simple Ruby Scheme Intepreter
[![Actions Status](https://github.com/cuzzo/simple-ruby-scheme-interpreter/workflows/Ruby/badge.svg)](https://github.com/cuzzo/simple-ruby-scheme-interpreter/actions)

This is an implementation of a [Scheme](https://en.wikipedia.org/wiki/Scheme_(programming_language) "Scheme Programming Language") [interpreter](https://en.wikipedia.org/wiki/Interpreter_(computing)) written in a single file of [Ruby](https://en.wikipedia.org/wiki/Ruby_(programming_language) "Ruby Programming Language").

It is only 140 lines of code, 53 of which are implementing standard library functions -- like `cos` to caculate [cosine](https://en.wikipedia.org/wiki/Trigonometric_functions).

Scheme is one of the easiest programming languages to interpret. And Ruby is one of the most expressive and least-terse languages to develop in.

The goal of this repository is to make it as easy as possible to understand how a language intepreter works.

It is not a complete implementation of [The R5RS Standard](https://wiki.call-cc.org/man/4/The%20R5RS%20standard "Scheme R5R3 Standard"). 
Notably it is missing pairs and inexact numbers.


## How Small/Fast/Complete is this Scheme interpreter?

### Small
As mentioned above, the first iteration of this interpreter was 140 lines of code -- 53 of which implemented standard library functions.

### Fast
On my machine, it can calculate `(fact 1000)` 0.00534 seconds. That's fast enough for playing around with, although Ruby can do the same calculation in 0.00038 -- about 15 times faster.

### Complete
This interpreter is not very complete. Several missing features include:

* **Syntax**: Missing `#` literals, derived expression types `cond` from `if` and `let` from `lambda`, the `.` list notation,  and numerical constants like `3.1415926535F0`, `0.6L0`, `6/10`, `3+4i`.
* **Symatntics**: Missing call/cc and tail recursion.
* **Data Types**: Missing characters, ports, pairs, and exact/inexact numbers.
* **Procedures**: Missing several primitive procedures like `complex?`, `real?`, `rational?`, `exact?`, and `inexact?`.
* **Error Recovery**: This interpreter has very little error detection, reporting, or error recovery. Good luck [=

## Acknowledgements

* [Lis.py](https://norvig.com/lispy.html) - Peter Norvig's Python Lisp Interpreter
