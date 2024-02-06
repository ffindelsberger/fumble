%{
  #include <stdio.h>
  #include <string.h>
  #include <stdlib.h>
  #include <stdbool.h>
  #include "ast.h"
  //#include "stack.c"

  extern int yylineno;
  extern FILE* yyin;
  void yyerror (const char *);
  int yylex (void);
   
  struct f_table {
      int size;
      ast* funcs[];
  };

  // "REGISTERS"
  static data return_register = {};
  bool break_f = false;

  ast* func_lookup(struct f_table funcs,char *identifier) {
   for (int i = 0; i < funcs.size; i++) {
    ast* current = funcs.funcs[i];
    if(strcmp(current->identifier, identifier)){
      return current;
    }
   } 
   return NULL;
  }
%}

%union{
  int number;
  char *string;
  char infix_op;
  char *identifier;
  ast  *ast;
}

%define parse.error verbose

%start PROG 

%type <ast> PROG STATEMENTS STATEMENT BASE_EXPRESSION INFIX_EXPRESSION LITERAL LITERAL_NUMBER DECLARATION DECLARATION_VAR ASSIGNMENT BUILTIN_FUNC BLOCK COND_IF COND LOOP BREAK UNARY_EXPRESSION
%type <ast> LITERAL_STRING 
%type <ast> VARIABLE
%type <infix_op> '*' '/' '+' '-' '<' '>' '%'
%token stmts

// operators
%token ge 
       le 
       equal
       not_equal
       eq

%token <identifier>identifier
       delimiter
       ass

%token <number> num
       <string> string_literal

//Keywords
%token _if
       _else
       loop
       _break
       _return
       fn 
       let

%token <ast> next_int
       <ast> out 

// Data types
%token _int
       _string
       _double

%left println
%left '<' '>' equal not_equal le ge eq
%left '+' '-'
%left '*' '/' '%'

%%
PROG: STATEMENTS { printf("\n\n result : %d \n\n", eval($1));}

STATEMENTS: STATEMENTS STATEMENT delimiter {$$ = binode_create(STMTS, $1, $2);}
          | STATEMENT delimiter
STATEMENT: DECLARATION | ASSIGNMENT | BASE_EXPRESSION | RETURN | COND_IF | LOOP | BREAK

//basic Expression Grammar Rules
BASE_EXPRESSION: INFIX_EXPRESSION | VARIABLE | LITERAL | BUILTIN_FUNC | UNARY_EXPRESSION

INFIX_EXPRESSION: BASE_EXPRESSION '*' BASE_EXPRESSION {$$ = binode_create(MUL, $1, $3);}
                | BASE_EXPRESSION '/' BASE_EXPRESSION {$$ = binode_create(DIV, $1, $3);}
                | BASE_EXPRESSION '+' BASE_EXPRESSION {$$ = binode_create(PLUS, $1, $3);}
                | BASE_EXPRESSION '-' BASE_EXPRESSION {$$ = binode_create(MINUS, $1, $3);}
                | BASE_EXPRESSION '<' BASE_EXPRESSION {$$ = binode_create(LESS, $1, $3);}
                | BASE_EXPRESSION '>' BASE_EXPRESSION {$$ = binode_create(GREATER, $1, $3);}
                | BASE_EXPRESSION '%' BASE_EXPRESSION {$$ = binode_create(MOD, $1, $3);}
                | BASE_EXPRESSION equal BASE_EXPRESSION {$$ = binode_create(EQUAL, $1, $3);}
                | BASE_EXPRESSION not_equal BASE_EXPRESSION {$$ = binode_create(NEQUAL, $1, $3);}
                | BASE_EXPRESSION le BASE_EXPRESSION {$$ = binode_create(ELESS, $1, $3);}
                | BASE_EXPRESSION ge BASE_EXPRESSION {$$ = binode_create(EGREATER, $1, $3);}

UNARY_EXPRESSION : '-' BASE_EXPRESSION {$$ = unode_create(UNOP_MINUS, $2); }



BUILTIN_FUNC : next_int {$$ = create_leaf(NEXT_INT);}
             | out CP BASE_EXPRESSION CP 


//Literals
LITERAL: LITERAL_NUMBER
       | LITERAL_STRING {printf("Got string from lexer: %s \n", $1);}
LITERAL_NUMBER: num {$$ = create_leaf(NUMLIT); $$->data.number = $1;} 
LITERAL_STRING: string_literal {$$ = create_leaf(STRLIT); $$->data.string = $1;}


//Control Statements
COND_IF: _if BASE_EXPRESSION BLOCK { $$ = create_if($2, $3, NULL); }
       | _if BASE_EXPRESSION BLOCK _else BLOCK { $$ = create_if($2, $3, $5); }

LOOP : loop BLOCK {  $$ = create_loop($2);  }
BREAK : _break { $$ = create_leaf(BREAK); }


//FN RULES
FN_ITEM: OP ARGS CP BLOCK | identifier OP ARGS CP ':' TYPE BLOCK
FN_BODY:  OC STATEMENTS CC | OC CC
DECLARATION_FN: fn FN_ITEM
ARGS: ARGS ',' ARG | ARG
ARG: identifier ':' TYPE

BLOCK :'{' STATEMENTS '}' {  $$ = $2;  }
      |'{' '}'


// SINGLE CHAR RULES and string rules
OC: '{'
CC: '}'
OP: '('
CP: ')'

// basic Statement Grammar Rules
DECLARATION : DECLARATION_VAR | DECLARATION_FN
VARIABLE: identifier {$$ = create_leaf(IDENT); $$->identifier = $1;}
ASSIGNMENT: VARIABLE eq BASE_EXPRESSION {$$ = binode_create(ASSIGN, $1, $3);}

//TODO: not the biggest fan dass ich hier direkt auf den identifier des child nodes zugreife
DECLARATION_VAR: let VARIABLE ':' TYPE eq BASE_EXPRESSION {$$ = binode_create(DECL, $2, $6); }
TYPE: _int | _string | _double

RETURN: _return BASE_EXPRESSION 
 

// BUILTIN
//PRINTLN: println BASE_EXPRESSION {$$ = node_create(println); add_child($$, $2);}

%%

void yyerror (const char *s) {
  printf("Error in line %d: %s\n", yylineno, s);
}

int main (int argc, char** argv) {
  #ifdef YYDEBUG
   yydebug = 1;
  #endif
  
  yyin = fopen(argv[1], "r");

  return yyparse();
}
