%{
    #include <stdio.h>
    #include <stdlib.h>
    #include <stdbool.h>
    #include <string.h>
    #include <iostream>
    #include <sstream>
    #include <fstream>
    #include <vector>
    #include <string>

    namespace patch // used to solve a bug that doesn't recognize std::string
    {
        template < typename T > std::string to_string( const T& n )
        {
            std::ostringstream stm;
            stm << n;
            return stm.str();
        }
    }

    void yyerror(const char* msg);
    int yylex();
    extern int currLine;
    extern int currPos;
    extern FILE *yyin;

    int numTemps = 0, numLabels = 0, numRegs = 0;
    std::vector<std::string> funcs;
    std::vector<std::string> idents;
    bool beginFunc = true;
    bool isRoot = true;
    bool mainDeclared = false;
    bool initialVars = true;
    bool EQ_flag = false, NEQ_flag = false, LT_flag = false, GT_flag = false, LTE_flag = false, GTE_flag = false;
    bool ADD_flag = false, SUB_flag = false, MULT_flag = false, DIV_flag = false, MOD_flag = false;
    std::string output = "";

    std::string makeTemp() {
        return "t" + patch::to_string(numTemps++);
    }
    std::string makeLabel() {
        return "L" + patch::to_string(numLabels++);
    }
%}

%union {
    int num;
    char* ident;
}

%error-verbose
%start program
%token SUB ADD MULT DIV MOD
%token EQ NEQ LT GT LTE GTE
%token SEMICOLON COLON COMMA L_PAREN R_PAREN L_SQUARE_BRACKET R_SQUARE_BRACKET
%token FUNCTION BEGIN_PARAMS END_PARAMS BEGIN_LOCALS END_LOCALS BEGIN_BODY END_BODY
%token ARRAY ENUM OF IF THEN ENDIF ELSE WHILE DO BEGINLOOP ENDLOOP CONTINUE READ WRITE
%token TRUE FALSE RETURN
%token <ident> IDENTIFIER
%token <num> NUMBER
%token <num> INTEGER
%left SUB ADD 
%left MULT DIV MOD
%right EQ NEQ LT GT LTE GTE
%left AND OR
%right NOT
%right ASSIGN

%%

program                     : functions                                             {}
                            ;

functions                   : function functions                                    
                            {
                                if (!mainDeclared) {
                                    std::cout << "ERROR: No main function declared!" << std::endl;
                                    exit(0);
                                }
                            }
                            | /* epsilon */                                         {}
                            ;
    
function                    : FUNCTION identifiers SEMICOLON 
                              BEGIN_PARAMS declarations END_PARAMS 
                              BEGIN_LOCALS declarations END_LOCALS 
                              BEGIN_BODY statements END_BODY                        
                            {
                                if (!beginFunc) {
                                    output += "endfunc\n\n";
                                }
                                beginFunc = true; 
                            }
                            ;

declarations                : declaration SEMICOLON declarations                    
                            { 
                                initialVars = true; 
                            }
                            | /* epsilon */                                         
                            { 
                                initialVars = false; 
                            }
                            ;

declaration                 : identifiers COLON declaration_params INTEGER          
                            {
                                isRoot = false;
                            }
                            ;

declaration_params          : ENUM L_PAREN identifiers R_PAREN                      {}
                            | ARRAY L_SQUARE_BRACKET NUMBER R_SQUARE_BRACKET OF     
                            {
                                output += ".[] " + idents.at(idents.size()-1) + ", " + patch::to_string($3) + "\n";
                            }
                            | /* epsilon */                                         {}
                            ;

identifiers                 : IDENTIFIER identifiers                                
                            {  
                                std::string s($1), tmp;
                                if (beginFunc) {
                                    beginFunc = false;
                                    output += "func ";
                                    for (unsigned i = 0; i < s.size() && s.at(i) != ' ' && s.at(i) != '(' && s.at(i) != ')' && s.at(i) != ';'; i++) {
                                        output += s.at(i); tmp += s.at(i);
                                    }
                                    output += "\n";
                                    if (tmp == "main") { mainDeclared = true; }
                                    for (unsigned i = 0; i < funcs.size(); i++) {
                                        if (tmp == funcs.at(i)) {
                                            std::cout << "ERROR: Same function name used multiple times!" << std::endl;
                                            exit(0);
                                        }
                                    }
                                    funcs.push_back(tmp);
                                    
                                }
                                else if (isRoot) {
                                    output += ". ";
                                    for (unsigned i = 0; i < s.size() && s.at(i) != ' ' && s.at(i) != '(' && s.at(i) != ')' && s.at(i) != ';'; i++) {
                                        output += s.at(i); tmp += s.at(i);
                                    }
                                    output += "\n";
                                    output += "= " + tmp + ", $" + patch::to_string(numRegs++) + "\n";
                                }
                                else {
                                    output += ". ";
                                    for (unsigned i = 0; i < s.size() && s.at(i) != ' ' && s.at(i) != '(' && s.at(i) != ')' && s.at(i) != ';'; i++) {
                                        output += s.at(i); tmp += s.at(i);
                                    }
                                    output += "\n";
                                }
                                idents.push_back(tmp);
                            }
                            | COMMA IDENTIFIER identifiers                          {}
                            | /* epsilon */                                         {}
                            ;

statements                  : statement SEMICOLON statements                        {}
                            | /* epsilon */                                         {}
                            ;

statement                   : var ASSIGN expr                                       
                            {
                                output += "= " + idents.at(idents.size()-1) + ", t" + patch::to_string(numTemps-1) + "\n";
                            }
                            | IF bool_expr THEN statements ENDIF                    
                            {
                                output += ": L" + patch::to_string(numLabels-1) + "\n";
                            }
                            | IF bool_expr THEN statements ELSE statements ENDIF    {}
                            | WHILE bool_expr BEGINLOOP statements ENDLOOP          {}
                            | DO BEGINLOOP statements ENDLOOP WHILE bool_expr       {}
                            | READ vars                                             
                            {
                                output += ".< " + idents.at(idents.size()-2) + "\n";
                                std::string temp = makeTemp();
                                output += ". " + temp + "\n";
                                output += "= " + temp + ", " + idents.at(idents.size()-2) + "\n";
                            }
                            | WRITE vars                                            
                            {
                                output += ".> " + idents.at(idents.size()-1) + "\n";
                            }
                            | CONTINUE                                              {}
                            | RETURN expr                                           
                            {
                                output += "ret t" + patch::to_string(numTemps-1) + "\n";
                            }
                            | /* epsilon */                                         {}
                            ;

vars                        : var                                                   {}
                            | var COMMA vars                                        {}
                            | /* epsilon */                                         {}
                            ;
                    
var                         : IDENTIFIER                                            
                            {
                                if (!initialVars) {
                                    std::string temp = makeTemp();
                                    output += ". " + temp + "\n";
                                    output += "= " + temp + ", ";
                                    std::string s($1), tmp;
                                    for (unsigned i = 0; i < s.size() && s.at(i) != ' ' && s.at(i) != '(' && s.at(i) != ')' && s.at(i) != ';'; i++) {
                                        output += s.at(i); tmp += s.at(i);
                                    }
                                    output += "\n";
                                }
                            }
                            | IDENTIFIER L_SQUARE_BRACKET expr R_SQUARE_BRACKET     
                            {
                                output += ".[] ";
                                std::string s($1);
                                for (unsigned i = 0; i < s.size() && s.at(i) != ' ' && s.at(i) != '('; i++) {
                                    output += s.at(i);
                                }
                                output += "\n";
                            }
                            ;

bool_expr                   : relation_and_expr bool_expr_params                    {}
                            ;

bool_expr_params            : OR relation_and_expr bool_expr_params                 
                            {
                                std::string temp = makeTemp();
                                std::string label = makeLabel();
                                output += ". " + temp + "\n";
                                output += "|| " + temp + ", t" + patch::to_string(numTemps-3) + ", t" + patch::to_string(numTemps-2) + "\n";
                                output += "?: " + label + ", " + temp + "\n";
                                output += ":= " + makeLabel() + "\n";
                                output += ": " + label + "\n";
                            }
                            | /* epsilon */                                         {}
                            ;

relation_and_expr           : relation_expr relation_and_expr_params                {}
                            ;

relation_and_expr_params    : AND relation_expr relation_and_expr_params            
                            {
                                std::string temp = makeTemp();
                                std::string label = makeLabel();
                                output += ". " + temp + "\n";
                                output += "&& " + temp + ", t" + patch::to_string(numTemps-3) + ", t" + patch::to_string(numTemps-2) + "\n";
                                output += "?: " + label + ", " + temp + "\n";
                                output += ":= " + makeLabel() + "\n";
                                output += ": " + label + "\n";
                            }
                            | /* epsilon */                                         {}
                            ;
                        
relation_expr               : relation_exprs                                        {}
                            | NOT relation_exprs                                    
                            {
                                std::string temp = makeTemp();
                                std::string label = makeLabel();
                                output += ". " + temp + "\n";
                                output += "! " + temp + ", t" + patch::to_string(numTemps-2) + "\n";
                                output += "?: " + label + ", " + temp + "\n";
                                output += ":= " + makeLabel() + "\n";
                                output += ": " + label + "\n";
                            }
                            ;   

relation_exprs              : expr comp expr                                        {}
                            | TRUE                                                  {}
                            | FALSE                                                 {}
                            | L_PAREN bool_expr R_PAREN                             {}
                            ;

comp                        : EQ                                                    
                            {
                                EQ_flag = true;
                            }
                            | NEQ                                                   
                            {
                                NEQ_flag = true;
                            }
                            | LT                                                    
                            {
                                LT_flag = true;
                            }
                            | GT                                                    
                            {   
                                GT_flag = true;
                            }
                            | LTE                                                   
                            {
                                LTE_flag = true;
                            }
                            | GTE                                                   
                            {
                                GTE_flag = true;
                            }
                            ;

expr                        : mult_expr expr_ops                                    
                            {
                                if (EQ_flag) {
                                    EQ_flag = false;
                                    std::string temp = makeTemp();
                                    std::string label = makeLabel();
                                    output += ". " + temp + "\n";
                                    output += "== " + temp + ", t" + patch::to_string(numTemps-3) + ", t" + patch::to_string(numTemps-2) + "\n";
                                    output += "?: " + label + ", " + temp + "\n";
                                    output += ":= " + makeLabel() + "\n";
                                    output += ": " + label + "\n";
                                }
                                if (NEQ_flag) {
                                    NEQ_flag = false;
                                    std::string temp = makeTemp();
                                    std::string label = makeLabel();
                                    output += ". " + temp + "\n";
                                    output += "!= " + temp + ", t" + patch::to_string(numTemps-3) + ", t" + patch::to_string(numTemps-2) + "\n";
                                    output += "?: " + label + ", " + temp + "\n";
                                    output += ":= " + makeLabel() + "\n";
                                    output += ": " + label + "\n";
                                }
                                if (LT_flag) {
                                    LT_flag = false;
                                    std::string temp = makeTemp();
                                    std::string label = makeLabel();
                                    output += ". " + temp + "\n";
                                    output += "< " + temp + ", t" + patch::to_string(numTemps-3) + ", t" + patch::to_string(numTemps-2) + "\n";
                                    output += "?: " + label + ", " + temp + "\n";
                                    output += ":= " + makeLabel() + "\n";
                                    output += ": " + label + "\n";
                                }
                                if (GT_flag) {
                                    GT_flag = false;
                                    std::string temp = makeTemp();
                                    std::string label = makeLabel();
                                    output += ". " + temp + "\n";
                                    output += "> " + temp + ", t" + patch::to_string(numTemps-3) + ", t" + patch::to_string(numTemps-2) + "\n";
                                    output += "?: " + label + ", " + temp + "\n";
                                    output += ":= " + makeLabel() + "\n";
                                    output += ": " + label + "\n";
                                }
                                if (LTE_flag) {
                                    LTE_flag = false;
                                    std::string temp = makeTemp();
                                    std::string label = makeLabel();
                                    output += ". " + temp + "\n";
                                    output += "<= " + temp + ", t" + patch::to_string(numTemps-3) + ", t" + patch::to_string(numTemps-2) + "\n";
                                    output += "?: " + label + ", " + temp + "\n";
                                    output += ":= " + makeLabel() + "\n";
                                    output += ": " + label + "\n";
                                }
                                if (GTE_flag) {
                                    GTE_flag = false;
                                    std::string temp = makeTemp();
                                    std::string label = makeLabel();
                                    output += ". " + temp + "\n";
                                    output += ">= " + temp + ", t" + patch::to_string(numTemps-3) + ", t" + patch::to_string(numTemps-2) + "\n";
                                    output += "?: " + label + ", " + temp + "\n";
                                    output += ":= " + makeLabel() + "\n";
                                    output += ": " + label + "\n";
                                }
                                if (ADD_flag) {
                                    ADD_flag = false;
                                    std::string temp = makeTemp();
                                    output += ". " + temp + "\n";
                                    output += "+ " + temp + ", t" + patch::to_string(numTemps-3) + ", t" + patch::to_string(numTemps-2) + "\n";
                                }
                                if (SUB_flag) {
                                    SUB_flag = false;
                                    std::string temp = makeTemp();
                                    output += ". " + temp + "\n";
                                    output += "- " + temp + ", t" + patch::to_string(numTemps-3) + ", t" + patch::to_string(numTemps-2) + "\n";
                                }
                                if (MULT_flag) {
                                    MULT_flag = false;
                                    std::string temp = makeTemp();
                                    output += ". " + temp + "\n";
                                    output += "* " + temp + ", t" + patch::to_string(numTemps-3) + ", t" + patch::to_string(numTemps-2) + "\n";
                                }
                                if (DIV_flag) {
                                    DIV_flag = false;
                                    std::string temp = makeTemp();
                                    output += ". " + temp + "\n";
                                    output += "/ " + temp + ", t" + patch::to_string(numTemps-3) + ", t" + patch::to_string(numTemps-2) + "\n";
                                }
                                if (MOD_flag) {
                                    MOD_flag = false;
                                    std::string temp = makeTemp();
                                    output += ". " + temp + "\n";
                                    output += "% " + temp + ", t" + patch::to_string(numTemps-3) + ", t" + patch::to_string(numTemps-2) + "\n";
                                }
                            }
                            ;

expr_ops                    : ADD mult_expr expr_ops                                
                            {
                                ADD_flag = true;
                            }
                            | SUB mult_expr expr_ops                                
                            {
                                SUB_flag = true;
                            }
                            | /* epsilon */                                         {}
                            ;

mult_expr                   : term mult_expr_ops                                    {}
                            ;

mult_expr_ops               : MULT term mult_expr_ops                               
                            {
                                MULT_flag = true;
                            }
                            | DIV term mult_expr_ops                                
                            {
                                DIV_flag = true;
                            }
                            | MOD term mult_expr_ops                                
                            {
                                MOD_flag = true;
                            }
                            | /* epsilon */                                         {}
                            ;

term                        : terms                                                 {}
                            | SUB terms                                             {}
                            | IDENTIFIER L_PAREN exprs R_PAREN                      
                            {
                                output += "param t" + patch::to_string(numTemps-1) + "\n";
                                std::string temp = makeTemp();
                                output += ". " + temp + "\n";
                                output += "call ";
                                std::string s(patch::to_string($1)), tmp;
                                for (unsigned i = 0; i < s.size() && s.at(i) != ' ' && s.at(i) != '(' && s.at(i) != ')' && s.at(i) != ';'; i++) {
                                    output += s.at(i); tmp += s.at(i);
                                }
                                output += ", " + temp + "\n";
                            }
                            ;

terms                       : var                                                   {}
                            | NUMBER                                                
                            {
                                std::string temp = makeTemp();
                                output += ". " + temp + "\n";
                                output += "= " + temp + ", ";
                                std::string s(patch::to_string($1)), tmp;
                                for (unsigned i = 0; i < s.size() && s.at(i) != ' ' && s.at(i) != '(' && s.at(i) != ')' && s.at(i) != ';'; i++) {
                                    output += s.at(i); tmp += s.at(i);
                                }
                                output += "\n";
                            }
                            | L_PAREN expr R_PAREN                                  {}
                            ;

exprs                       : expr                                                  {}
                            | expr COMMA exprs                                      {}
                            | /* epsilon */                                         {}
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

    std::ofstream o;
    o.open("mil_code.mil");
    o << output;
    o.close();

    return 0;
}

void yyerror (const char* msg) {
    printf("** Line %d, position %d: %s\n", currLine, currPos, msg);
}