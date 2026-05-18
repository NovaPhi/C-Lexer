# C++Lexer
# Lexical Categories
 
- Reserved Word
- Identifier
- Integer
- String
- Operator
- Comment
- Preprocessor
- Whitespace


## Algorithm & Complexity
 
The tokenizer works by scanning the source string from left to right. At each position, it tries each regex pattern in order, takes the first match, advances past it, and repeats until the string is empty.
 
Let `n` = length of the input in characters and `k` = number of token patterns (here `k = 7`, a constant).
 
Each character is consumed exactly once. For each position, at most `k` regex attempts are made, each anchored at the start of the remaining string O(1) per attempt for simple patterns. The overall complexity is therefore **O(n·k) = O(n)**.
 
HTML rendering is a second pass over the token list (length ≤ n), so it is also **O(n)**. Memory is **O(n)** for the token list.


## Ethical Implications
 
Tools for lexical analysis and syntax highlighting make code easier to understand and improve the overall readability of computer programs, thus serving a good purpose in education.
However, tools that analyze code pose certain risks to programmers' privacy if the source code contains information of a private nature, sending it via a third-party lexer or AI-based lexer means exposing it.
Moreover, these types of tools can be used for surveillance purposes, as the use of them may allow employers to keep track of the code written by employees without the latter even knowing about it.
Finally, as artificial intelligence starts generating code for people, tools for parsing and lexical analysis become critical components of AI-based programming automation tools that will eventually take away jobs from programmers.
 
run with elixir filename.ex filename.cpp

