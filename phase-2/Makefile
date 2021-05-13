all: lex.yy.c lexer y_files parser

lex.yy.c: y_files
	flex mini_l.lex

lexer: lex.yy.c
	gcc -o lexer lex.yy.c -lfl

y_files: 
	bison -v -d --file-prefix=y mini_l.y

parser: y_files
	gcc -o parser y.tab.c lex.yy.c -lfl

clean: 
	rm -f lex.yy.c y.* parser lexer