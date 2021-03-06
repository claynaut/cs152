%{
    #include <stdio.h>
    #include <stdlib.h>
    void yyerror(const char* msg);
    extern int currLine;
    extern int currPos;
    extern FILE *yyin;
%}

%union {
    int ival;
    char* ident;
}

%start program
%token SUB ADD MULT DIV MOD
%token EQ NEQ LT GT LTE GTE
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY
%token ARRAY ENUM OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE
%token TRUE FALSE RETURN
%token <ident> IDENTIFIER
%token <ival> NUMBER
%token <ival> INTEGER
%left SUB ADD 
%left MULT DIV MOD
%right EQ NEQ LT GT LTE GTE
%left AND OR
%right NOT
%right ASSIGN

%%

program                     : functions                                             { printf("program -> functions\n"); }
                            ;

functions                   : function functions                                    { printf("functions -> function functions\n"); }
                            | /* epsilon */                                         { printf("functions -> epsilon\n"); }
                            ;
    
function                    : FUNCTION identifiers SEMICOLON 
                              BEGIN_PARAMS declarations END_PARAMS 
                              BEGIN_LOCALS declarations END_LOCALS 
                              BEGIN_BODY statements END_BODY                        { printf("function -> FUNCTION IDENTIFIER SEMICOLON BEGIN_PARAMS declarations END_PARAMS BEGIN_LOCALS BEGIN_BODY statements END_BODY\n"); }
                            ;

declarations                : declaration SEMICOLON declarations                    { printf("declarations -> declaration SEMICOLON declarations\n"); }
                            | /* epsilon */                                         { printf("declarations -> epsilon\n"); }
                            ;

declaration                 : identifiers COLON declaration_params INTEGER          { printf("declaration -> identifiers COLON declaration_params INTEGER\n"); }
                            ;

declaration_params          : ENUM L_PAREN identifiers R_PAREN                      { printf("declaration_params -> ENUM L_PAREN identifiers R_PAREN\n"); }
                            | ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF     { printf("declaration_params -> ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF\n"); }
                            | /* epsilon */                                         { printf("declaration_params -> epsilon\n"); }
                            ;

identifiers                 : IDENTIFIER identifiers                                { printf("identifiers -> IDENTIFIER identifiers\n"); }
                            | COMMA IDENTIFIER identifiers                          { printf("identifiers -> COMMA IDENTIFIER identifiers\n"); }
                            | /* epsilon */                                         { printf("identifiers -> epsilon\n"); }
                            ;

statements                  : statement SEMICOLON statements                        { printf("statements -> statement SEMICOLON statements\n"); }
                            | /* epsilon */                                         { printf("statements -> epsilon\n"); }
                            ;

statement                   : var ASSIGN expr                                       { printf("statement -> var ASSIGN expr\n"); }
                            | IF bool_expr THEN statements ENDIF                    { printf("statement -> IF bool_expr THEN statements ENDIF\n"); }
                            | IF bool_expr THEN statements ELSE statements ENDIF    { printf("statement -> IF bool_expr THEN statements ELSE statements ENDIF\n"); }
                            | WHILE bool_expr BEGINLOOP statements ENDLOOP          { printf("statement -> WHILE bool_expr BEGINLOOP statements ENDLOOP\n"); }
                            | DO BEGINLOOP statements ENDLOOP WHILE bool_expr       { printf("statement -> DO BEGINLOOP statements ENDLOOP WHILE bool_expr\n"); }
                            | READ vars                                             { printf("statement -> READ vars\n"); }
                            | WRITE vars                                            { printf("statement -> WRITE vars\n"); }
                            | CONTINUE                                              { printf("statement -> CONTINUE\n"); }
                            | RETURN expr                                           { printf("statement -> RETURN expr\n"); }
                            | /* epsilon */                                         { printf("statement -> epsilon\n"); }
                            ;

vars                        : var                                                   { printf("vars -> var\n"); }
                            | var COMMA vars                                        { printf("vars -> var COMMA vars\n"); }
                            | /* epsilon */                                         { printf("vars -> epsilon\n"); }
                            ;
                    
var                         : IDENTIFIER                                            { printf("var -> IDENTIFIER\n"); }
                            | IDENTIFIER L_SQUARE_BRACKET expr R_SQUARE_BRACKET     { printf("var -> IDENTIFIER L_SQUARE_BRACKET expr R_SQUARE_BRACKET\n"); }
                            ;

bool_expr                   : relation_and_expr bool_expr_params                    { printf("bool_expr -> relation_and_expr bool_expr_params\n"); }
                            ;

bool_expr_params            : OR relation_and_expr bool_expr_params                 { printf("bool_expr_params -> OR relation_and_expr bool_expr_params\n"); }
                            | /* epsilon */                                         { printf("bool_expr_params -> epsilon\n"); }
                            ;

relation_and_expr           : relation_expr relation_and_expr_params                { printf("relation_and_expr -> relation_expr relation_and_expr_params\n"); }
                            ;

relation_and_expr_params    : AND relation_expr relation_and_expr_params            { printf("relation_and_expr_params -> AND relation_expr relation_and_expr_params\n"); }
                            | /* epsilon */                                         { printf("relation_and_expr_params -> epsilon\n"); }
                            ;
                        
relation_expr               : relation_exprs                                        { printf("relation_expr -> relation_exprs\n"); }
                            | NOT relation_exprs                                    { printf("relation_expr -> NOT relation_exprs\n"); }
                            ;   

relation_exprs              : expr comp expr                                        { printf("relation_exprs -> expr comp expr\n"); }
                            | TRUE                                                  { printf("relation_exprs -> TRUE\n"); }
                            | FALSE                                                 { printf("relation_exprs -> FALSE\n"); }
                            | L_PAREN bool_expr R_PAREN                             { printf("relation_exprs -> L_PAREN bool_expr R_PAREN\n"); }
                            ;

comp                        : EQ                                                    { printf("comp -> EQ\n"); }
                            | NEQ                                                   { printf("comp -> NEQ\n"); }
                            | LT                                                    { printf("comp -> LT\n"); }
                            | GT                                                    { printf("comp -> GT\n"); }
                            | LTE                                                   { printf("comp -> LTE\n"); }
                            | GTE                                                   { printf("comp -> GTE\n"); }
                            ;

expr                        : mult_expr expr_ops                                    { printf("expr -> mult_expr expr_ops\n"); }
                            ;

expr_ops                    : ADD mult_expr expr_ops                                { printf("expr_ops -> ADD mult_expr expr_ops\n"); }
                            | SUB mult_expr expr_ops                                { printf("expr_ops -> SUB mult_expr expr_ops\n"); }
                            | /* epsilon */                                         { printf("expr_ops -> epsilon\n"); }
                            ;

mult_expr                   : term mult_expr_ops                                    { printf("mult_expr -> term mult_expr_ops\n"); }
                            ;

mult_expr_ops               : MULT term mult_expr_ops                               { printf("mult_expr_ops -> MULT term mult_expr_ops \n"); }
                            | DIV term mult_expr_ops                                { printf("mult_expr_ops -> DIV term mult_expr_ops \n"); }
                            | MOD term mult_expr_ops                                { printf("mult_expr_ops -> MOD term mult_expr_ops \n"); }
                            | /* epsilon */                                         { printf("mult_expr_ops -> epsilon\n"); }
                            ;

term                        : terms                                                 { printf("term -> terms\n"); }
                            | SUB terms                                             { printf("term -> SUB terms\n"); }
                            | IDENTIFIER L_PAREN exprs R_PAREN                      { printf("term -> IDENTIFIER L_PAREN exprs R_PAREN\n"); }
                            ;

terms                       : var                                                   { printf("terms -> var\n"); }
                            | NUMBER                                                { printf("terms -> NUMBER\n"); }
                            | L_PAREN expr R_PAREN                                  { printf("terms -> L_PAREN expr R_PAREN\n"); }
                            ;

exprs                       : expr                                                  { printf("exprs -> expr\n"); }
                            | expr COMMA exprs                                      { printf("exprs -> expr COMMA exprs\n"); }
                            | /* epsilon */                                         { printf("exprs -> epsilon\n"); }
                            ;

%%

int main (int argc, char** argv) {
    if (argc >= 2) {
        yyin = fopen(argv[1], "r");
        if (yyin == NULL) yyin = stdin;
    }
    else {
        yyin = stdin;
    }
    yyparse();
    return 0;
}

void yyerror (const char* msg) {
    printf("** Line %d, position %d: %s\n", currLine, currPos, msg);
}