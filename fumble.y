%{
  #include <stdio.h>
  #include <string.h>
  #include <stdlib.h>
  #include "ast.h"
  //#include "stack.c"
  #include "mem.c"

  extern int yylineno;
  void yyerror (const char *);
  int yylex (void);
   
  struct f_table {
      int size;
      ast* funcs[];
  };

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

%type <ast> PROG STATEMENTS STATEMENT BASE_EXPRESSION INFIX_EXPRESSION LITERAL LITERAL_NUMBER DECLARATION DECLARATION_VAR ASSIGNMENT
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
       println

// Data types
%token _int
       _string
       _double

%left println
%left '<' '>' equal not_equal le ge
%left '+' '-'
%left '*' '/' '%'

%%
PROG: STATEMENTS { printf("\n\n result : %d\n\n", eval($1));}

//TODO: wenn mein programm nur aus einer zeile besteht dann executed der die glaub ich ned
STATEMENTS: STATEMENTS STATEMENT delimiter {$$ = binode_create(stmts, $1, $2);}
          | STATEMENT delimiter
STATEMENT: DECLARATION | ASSIGNMENT | BASE_EXPRESSION | RETURN

//basic Expression Grammar Rules
BASE_EXPRESSION: INFIX_EXPRESSION | VARIABLE | LITERAL

INFIX_EXPRESSION: BASE_EXPRESSION '*' BASE_EXPRESSION {$$ = binode_create($2, $1, $3);}
                | BASE_EXPRESSION '/' BASE_EXPRESSION {$$ = binode_create($2, $1, $3);}
                | BASE_EXPRESSION '+' BASE_EXPRESSION {$$ = binode_create($2, $1, $3);}
                | BASE_EXPRESSION '-' BASE_EXPRESSION {$$ = binode_create($2, $1, $3);}
                | BASE_EXPRESSION '<' BASE_EXPRESSION {$$ = binode_create($2, $1, $3);}
                | BASE_EXPRESSION '>' BASE_EXPRESSION {$$ = binode_create($2, $1, $3);}
                | BASE_EXPRESSION '%' BASE_EXPRESSION {$$ = binode_create($2, $1, $3);}
                | BASE_EXPRESSION equal BASE_EXPRESSION {$$ = binode_create(equal, $1, $3);}
                | BASE_EXPRESSION not_equal BASE_EXPRESSION {$$ = binode_create(not_equal, $1, $3);}
                | BASE_EXPRESSION le BASE_EXPRESSION {$$ = binode_create(le, $1, $3);}
                | BASE_EXPRESSION ge BASE_EXPRESSION {$$ = binode_create(ge, $1, $3);}


//Literals
LITERAL: '-' LITERAL_NUMBER {$$ = unode_create($1, $2); }
       | LITERAL_NUMBER
       | LITERAL_STRING
LITERAL_NUMBER: num {$$ = node_create(num); $$->data.number = yylval.number;} 
LITERAL_STRING: string_literal { printf("%s", $1);}


//FN RULES
FN_ITEM: OP ARGS CP BLOCK | identifier OP ARGS CP ':' TYPE BLOCK
FN_BODY:  OC STATEMENTS CC | OC CC
DECLARATION_FN: fn FN_ITEM
ARGS: ARGS ',' ARG | ARG
ARG: identifier ':' TYPE

BLOCK :'{' STATEMENTS '}'
      |'{' '}'


// SINGLE CHAR RULES and string rules
OC: '{'
CC: '}'
OP: '('
CP: ')'

// basic Statement Grammar Rules
DECLARATION : DECLARATION_VAR | DECLARATION_FN
VARIABLE: identifier {$$ = node_create(identifier); $$->identifier = $1;}
ASSIGNMENT: VARIABLE eq BASE_EXPRESSION {$$ = binode_create(eq, $1, $3);}

//TODO: not the biggest fan dass ich hier direkt auf den identifier des child nodes zugreife
DECLARATION_VAR: let VARIABLE ':' TYPE eq BASE_EXPRESSION {$$ = binode_create(let, $2, $6); }
TYPE: _int | _string | _double

RETURN: _return BASE_EXPRESSION 
 

// BUILTIN
//PRINTLN: println BASE_EXPRESSION {$$ = node_create(println); add_child($$, $2);}

%%

int eval(ast *node) {
  printf("interpreting node type: %d :", node->type);

switch (node->ast_type) {

  case AST_UNOP:
    switch (node->type) {
    case '-':
      return -eval(node->value.unary.operand);
    }

  case AST_BINOP:
    switch (node->type) {
    case stmts:
      return eval(node->value.binary.left), eval(node->value.binary.right);
    case '*':
      return eval(node->value.binary.left) * eval(node->value.binary.right);
    case '+':
      printf("+\n");
      return eval(node->value.binary.left) + eval(node->value.binary.right);
    case '-':
      return eval(node->value.binary.left) - eval(node->value.binary.right);
    case '<':
      return eval(node->value.binary.left) < eval(node->value.binary.right);
    case '>':
      return eval(node->value.binary.left) > eval(node->value.binary.right);
    case '%':
      return eval(node->value.binary.left) % eval(node->value.binary.right);
    case equal:
      return eval(node->value.binary.left) == eval(node->value.binary.right);
    case not_equal:
      printf("not_equal\n");
      return eval(node->value.binary.left) != eval(node->value.binary.right);
    case le:
      printf("le\n");
      return eval(node->value.binary.left) >= eval(node->value.binary.right);
    case ge:
      printf("ge\n");
      return eval(node->value.binary.left) <= eval(node->value.binary.right);
    case eq: {
      printf("eq\n");
      int val = eval(node->value.binary.right);
      char* id = node->value.binary.left->identifier;
      return  var_set(id, val);
      } 
    }

  case AST_LEAF:
    switch (node->type) {
    case num:
      printf("num\n");
      return node->data.number;
    case let: {
      char* id = node->value.binary.left->identifier;
      int data = eval(node->value.binary.right); 
      printf("let -> ");
      printf("declaring variable : %s with value %d \n", id, data);
      return var_declare(id, data);
    }
    case identifier: {
      int ret = var_get(node->identifier);
      printf("id -> returning value: %d for id : %s \n", ret, node->identifier);
      return ret;
    }
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
