%{
  #include <stdio.h>
  #include <string.h>
  #include <stdlib.h>
  #include <stdbool.h>
  #include "ast.h"
  //#include "stack.c"
  #include "mem.c"

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

%type <ast> PROG STATEMENTS STATEMENT BASE_EXPRESSION INFIX_EXPRESSION LITERAL LITERAL_NUMBER DECLARATION DECLARATION_VAR ASSIGNMENT BUILTIN_FUNC BLOCK COND_IF COND LOOP BREAK
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

STATEMENTS: STATEMENTS STATEMENT delimiter {$$ = binode_create(stmts, $1, $2);}
          | STATEMENT delimiter
STATEMENT: DECLARATION | ASSIGNMENT | BASE_EXPRESSION | RETURN | COND_IF | LOOP | BREAK

//basic Expression Grammar Rules
BASE_EXPRESSION: INFIX_EXPRESSION | VARIABLE | LITERAL | BUILTIN_FUNC

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


BUILTIN_FUNC : next_int {$$ = node_create(next_int);}
             | out CP BASE_EXPRESSION CP 


//Literals
LITERAL: '-' LITERAL_NUMBER {$$ = unode_create($1, $2); }
       | LITERAL_NUMBER
       | LITERAL_STRING {printf("Got string from lexer: %s \n", $1);}
LITERAL_NUMBER: num {$$ = node_create(num); $$->data.number = $1;} 
LITERAL_STRING: string_literal {$$ = node_create(string_literal); $$->data.string = $1;}


//Control Statements
COND_IF: _if BASE_EXPRESSION BLOCK { $$ = create_if($2, $3, NULL); }
       | _if BASE_EXPRESSION BLOCK _else BLOCK { $$ = create_if($2, $3, $5); }

LOOP : loop BLOCK {  $$ = create_loop($2);  }
BREAK : _break { $$ = node_create(_break); }


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
VARIABLE: identifier {$$ = node_create(identifier); $$->identifier = $1;}
ASSIGNMENT: VARIABLE eq BASE_EXPRESSION {$$ = binode_create(eq, $1, $3);}

//TODO: not the biggest fan dass ich hier direkt auf den identifier des child nodes zugreife
DECLARATION_VAR: let VARIABLE ':' TYPE eq BASE_EXPRESSION {$$ = binode_create(let, $2, $6); }
TYPE: _int | _string | _double

RETURN: _return BASE_EXPRESSION 
 

// BUILTIN
//PRINTLN: println BASE_EXPRESSION {$$ = node_create(println); add_child($$, $2);}

%%

data eval(ast *ast) {
  printf("interpreting ast type: %d : ", ast->type);

switch (ast->ast_type) {

  case AST_UNOP:
    switch (ast->type) {
    case '-':
      return -eval(ast->node.unary.operand).v.number;
    }

  case AST_BINOP:
    switch (ast->type) {
    // create a check for a skip flag in here;
    case stmts: {
        printf("stmts: break_f = %d \n", break_f);
          int left = eval(ast->node.binary.left);
          int right = 0;
          if (!break_f) {
            right = eval(ast->node.binary.right);
          }
          return left,right;
    }
    case '*':
      return eval(ast->node.binary.left) * eval(ast->node.binary.right);
    case '+':
      printf("+\n");
      return eval(ast->node.binary.left) + eval(ast->node.binary.right);
    case '-':
      printf("-\n");
      return eval(ast->node.binary.left) - eval(ast->node.binary.right);
    case '<':
      return eval(ast->node.binary.left) < eval(ast->node.binary.right);
    case '>':
      return eval(ast->node.binary.left) > eval(ast->node.binary.right);
    case '%':
      return eval(ast->node.binary.left) % eval(ast->node.binary.right);
    case '/':
      return eval(ast->node.binary.left) / eval(ast->node.binary.right);
    case equal:
      printf("equal\n");
      return eval(ast->node.binary.left) == eval(ast->node.binary.right);
    case not_equal:
      printf("not_equal\n");
      return eval(ast->node.binary.left) != eval(ast->node.binary.right);
    case le:
      printf("le\n");
      return eval(ast->node.binary.left) >= eval(ast->node.binary.right);
    case ge:
      printf("ge\n");
      return eval(ast->node.binary.left) <= eval(ast->node.binary.right);
    case eq: {
      printf("eq\n");
      int val = eval(ast->node.binary.right);
      char* id = ast->node.binary.left->identifier;
      return  var_set(id, val);
      } 
    }

  case AST_LEAF:
    switch (ast->type) {
    case num:
      printf("literal_num\n");
      return ast->data.number;
    case string_literal: 
      printf("string_literal\n");
      printf("node of string literal is : %s \n", ast->data.string);
      return ast->data.string;
    case let: {
      char* id = ast->node.binary.left->identifier;
      int data = eval(ast->node.binary.right); 
      printf("let -> ");
      printf("declaring variable : %s with node %d \n", id, data);
      return var_declare(id, data);
    }
    case identifier: {
      int ret = var_get(ast->identifier);
      printf("id -> returning node: %d for id : %s \n", ret, ast->identifier);
      return ret;
    }
    case _break : {
      printf("break\n");
      break_f = true;
      return 0; 
    }
    case next_int: {
      printf("next_int\n");
      int next_int_value; 
      //*c will read the newline to discard it;
      scanf("%d%*c",&next_int_value);
      return next_int_value;
    }
    case println : {
      
    }
   }
   
   case CONDITION_IF: {
      printf("conditional_if\n");
      if (eval(ast->node.condition_if.condition)) {
        return eval(ast->node.condition_if.branch_if);
      } else {
        if (ast->node.condition_if.branch_else != NULL) {
          return eval(ast->node.condition_if.branch_else); 
        }
      }
      return 0; 
   }
   case LOOP : {
      int result = 0;
      while(!break_f) {
        result = eval(ast->node.loop.body);
      }
      break_f = false; 
      return result;
   }
   
  }

  return 0;
}

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
