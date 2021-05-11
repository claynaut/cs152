# CS152 Project Phase 1: Lexical Analyzer Generation Using flex
This is Phase 1 for a compiler project for CS152. Original specifications are authored by the TA for the course.

## Prerequisites

Run flex to generate the lexical analyzer for MINI-L. 
- Example: `flex mini_l.lex`

Compile the MINI-L lexical analyzer. 
- Example: `gcc -o lexer lex.yy.c -lfl`

## Usage
The lexical analyzer can be invoked by the following command.
- Example: `cat [.min file] | lexer`

## Example Outputs
A list of tokens the lexical analyzer can identify are specified [here](https://www.cs.ucr.edu/~mafar001/compiler/webpages1/token_list_format.html).

Test files for this project can be found as .min files (e.g. `fibonnaci.min`). 

Outputs for the test files can be found as .txt files (e.g. `fibonnaci_output.txt`).

## Example Outputs for Lexical Errors
#### Unrecognizable Symbols
The following will be printed if the lexical analyzer does not recognize any of the inputted tokens as specified [here](https://www.cs.ucr.edu/~mafar001/compiler/webpages1/token_list_format.html):
- Example: `Error at line 9, column 14: unrecognized symbol "?"`

#### Invalid Identifiers
The following will be printed if the lexical analyzer encounters an invalid identifier. Invalid identifiers include identifiers that begin with a number or end with an underscore.
- Example: `Error at line 5, column 0: identifier "2n" must begin with a letter`
- Example: `Error at line 5	, column 0: identifier "n_" cannot end with an underscore`
