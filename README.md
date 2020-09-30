# Simple Ruby Scheme Intepreter
[![Actions Status](https://github.com/cuzzo/simple-ruby-scheme-interpreter/workflows/Ruby/badge.svg)](https://github.com/cuzzo/simple-ruby-scheme-interpreter/actions)

This is an implementation of a [Scheme](https://en.wikipedia.org/wiki/Scheme_(programming_language) "Scheme Programming Language") [interpreter](https://en.wikipedia.org/wiki/Interpreter_(computing)) written in a single file of [Ruby](https://en.wikipedia.org/wiki/Ruby_(programming_language) "Ruby Programming Language").

It is only 140 lines of code, 53 of which are implementing standard library functions -- like `cos` to caculate [cosine](https://en.wikipedia.org/wiki/Trigonometric_functions).

Scheme is one of the easiest programming languages to interpret. And Ruby is one of the most expressive and least-terse languages to develop in.

The goal of this repository is to make it as easy as possible to understand how a language intepreter works.

It is not a complete implementation of [The R5RS Standard](https://wiki.call-cc.org/man/4/The%20R5RS%20standard "Scheme R5R3 Standard"). 
Notably it is missing pairs.

## Known Issues

* Whitespace is stripped from inside strings.
* Space is added between parenthesis within strings.

## Acknowledgements

* [Lis.py](https://norvig.com/lispy.html) - Peter Norvig's Python Lisp Interpreter
