%{
  #include <stdio.h>
  #include <string.h>
  #include <stdlib.h>
  #include "ast.h"
  #include "stack.c"

  extern int yylineno;
  void yyerror (const char *);
  int yylex (void);
%}

%union{
  int number;
  char infix_op;
  char *ass;
  char *identifier;
  ast  *ast;
}

%define parse.error verbose

%type <ast> PROG STATEMENTS STATEMENT BASE_EXPRESSION INFIX_EXPRESSION LITERAL LITERAL_NUMBER 
%type <infix_op> '*' '/' '+' '-' '<' '>'

%start PROG 

%token <identifier>identifier
       delimiter
       ass
       equal
       not_equal

%token <number> num

%token _if
       _else
       loop
       _break
       _return
       fn 
       let
       println

%token _int
       _string
       _double

%left println
%left '<' '>' equal not_equal
%left '+' '-'
%left '*' '/'

%%
PROG: STATEMENTS { printf("\n\n result : %d\n\n", eval($1));}
STATEMENTS: STATEMENTS STATEMENT delimiter | STATEMENT delimiter
STATEMENT: DECLARATION | ASSIGNMENT | BASE_EXPRESSION 

//basic Expression Grammar Rules
BASE_EXPRESSION: INFIX_EXPRESSION | VARIABLE | LITERAL

INFIX_EXPRESSION: BASE_EXPRESSION '*' BASE_EXPRESSION {$$ = binode_create($2, $1, $3);}
                | BASE_EXPRESSION '/' BASE_EXPRESSION {$$ = binode_create($2, $1, $3);}
                | BASE_EXPRESSION '+' BASE_EXPRESSION {$$ = binode_create($2, $1, $3);}
                | BASE_EXPRESSION '-' BASE_EXPRESSION {$$ = binode_create($2, $1, $3);}
                | BASE_EXPRESSION '<' BASE_EXPRESSION {$$ = binode_create($2, $1, $3);}
                | BASE_EXPRESSION '>' BASE_EXPRESSION {$$ = binode_create($2, $1, $3);}
                | BASE_EXPRESSION equal BASE_EXPRESSION {$$ = binode_create(equal, $1, $3);}
                | BASE_EXPRESSION not_equal BASE_EXPRESSION {$$ = binode_create(not_equal, $1, $3);}

VARIABLE: identifier
LITERAL: '-' LITERAL_NUMBER {$$ = unode_create($1, $2); }
       | LITERAL_NUMBER
LITERAL_NUMBER: num {$$ = node_create(num); $$->data.number = yylval.number;} 

//FN RULES
FN_EXPRESSION: OP ARGS CP FN_BODY | OP ARGS CP ':' TYPE BLOCK
FN_BODY:  OC STATEMENTS CC | OC CC
DECLARATION_FN: fn FN_EXPRESSION
ARGS: ARGS ',' ARG | ARG
ARG: identifier 
TYPE: _int | _string | _double

BLOCK :'{' '}'
      |'{' STATEMENTS '}'



// SINGLE CHAR RULES
OC: '{'
CC: '}'
OP: '('
CP: ')'

// basic Statement Grammar Rules
ASSIGNMENT: VARIABLE ass BASE_EXPRESSION
DECLARATION : DECLARATION_VAR | DECLARATION_FN
DECLARATION_VAR: let VARIABLE ':' TYPE ass BASE_EXPRESSION 

// BUILTIN
//PRINTLN: println BASE_EXPRESSION {$$ = node_create(println); add_child($$, $2);}

%%

int eval(ast* node) {
  printf("interpreting node type: %d : ", node->type);

  switch (node->ast_type) {
      case AST_UNOP: switch(node->type) {
        case '-': return -eval(node->value.unary.operand);
      }
      case AST_BINOP : switch (node->type) {
        case '*' : printf("*\n");return eval(node->value.binary.left) * eval(node->value.binary.right);
        case '+' : printf("+\n");return eval(node->value.binary.left) + eval(node->value.binary.right);
        case '-' : printf("-\n");return eval(node->value.binary.left) - eval(node->value.binary.right);
        case '<' : printf("<\n");return eval(node->value.binary.left) < eval(node->value.binary.right);
        case '>' : printf(">\n");return eval(node->value.binary.left) > eval(node->value.binary.right);
        case equal : printf("equal\n");return eval(node->value.binary.left) == eval(node->value.binary.right);
        case not_equal : printf("not_equal\n");return eval(node->value.binary.left) != eval(node->value.binary.right);
      }
      case AST_LEAF: switch(node->type) {
        case num : printf("num\n");return node->data.number; 
      }
  }


  return 0;
}

void yyerror (const char *s) {
  printf("Error in line %d: %s\n", yylineno, s);
}

int main (void) {
  #ifdef YYDEBUG
   yydebug = 1;
  #endif
  return yyparse();
}
