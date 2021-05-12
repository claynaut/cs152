# CS152 Project Phase 2: Parser Generation Using bison
This is Phase 2 for a compiler project for CS152. Original specifications are authored by the TA for the course.


## Grammar for the MINI-L Language
The grammar is derived from the syntax diagrams provided by the TA, located [here](https://www.cs.ucr.edu/~mafar001/compiler/webpages2/syntax.html). 

## Prerequisites

Run flex to generate the lexical analyzer for MINI-L. 
- Example: `flex mini_l.lex`

Compile the MINI-L lexical analyzer. 
- Example: `gcc -o lexer lex.yy.c -lfl`

Run bison to generate the necessary files for the parser for MINI-L.
- Example: `bison -v -d --file-prefix=y mini_l.y`

Compile the MINI-L parser.
- Example: `gcc -o parser y.tab.c lex.yy.c -lfl`

## Usage
The parser can be invoked by the following command.
- Example: `cat [.min file] | parser`
