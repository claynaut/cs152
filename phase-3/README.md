# CS152 Project Phase 3: Code Generation
This is Phase 3 for a compiler project for CS152. Original specifications are authored by the TA for the course.


## Prerequisites

Run flex to generate the lexical analyzer for MINI-L. 
- Example: `flex mini_l.lex`

Compile the MINI-L lexical analyzer. 
- Example: `gcc -o lexer lex.yy.c -lfl`

Run bison to generate the necessary files for the parser.
- Example: `bison -v -d --file-prefix=y mini_l.y`

Gernate the compiler.
- Example: `gcc -o compiler y.tab.c lex.yy.c -lfl`

## Usage
The parser can be invoked by the following command.
- Example: `cat [.min file] | compiler`
