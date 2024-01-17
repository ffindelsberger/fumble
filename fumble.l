%{
#include "ast.h"
#include "fumble.tab.h"
%}

IDENTIFIER  [a-z]+
DEC [0-9]+
HEX 0x[0-9a-fA-F]+
STRING_LITERAL \"[^\"]*\"

OPERATOR  [-+*/]
OPERATOR_EQUAL "=="
OPERATOR_NOT_EQUAL "!="
OPERATOR_LESSER "<"
OPERATOR_GREATER ">"
OPERATOR_LE "<="
OPERATOR_GE ">="


EQ "="
DELIMITER ";"

KEY_IF "if"
KEY_ELSE "else"
KEY_LET "let"
KEY_LOOP "loop"
KEY_BREAK "break"	
KEY_FN "fn"
KEY_RETURN "return"

BUILTIN_PRINTLN "println"
BUILTIN_NEXT_INT "next_int()"

TYPE_INT "int"
TYPE_STRING "string"
TYPE_DOUBLE "double"


%option noyywrap nounput noinput
%%

{KEY_IF} { return _if; }
{KEY_ELSE} { return _else; }
{KEY_LET} { return let; }
{KEY_LOOP} { return loop; }
{KEY_FN} { return fn; }
{KEY_RETURN} { return _return; }
{TYPE_INT} { return _int;  }
{TYPE_STRING} { return _string;  }
{TYPE_DOUBLE} { return _double;  }
{BUILTIN_PRINTLN} { return println;  }
{BUILTIN_NEXT_INT} { return next_int;}

{OPERATOR_EQUAL} { yylval.infix_op = *yytext; return equal;  }
{OPERATOR_NOT_EQUAL} { yylval.infix_op = *yytext ;return not_equal;  }
{OPERATOR_LESSER} { yylval.infix_op = *yytext ;return *yytext;  }
{OPERATOR_GREATER} { yylval.infix_op = *yytext ;return *yytext;  }
{OPERATOR_LE} { yylval.infix_op = *yytext ;return le;  }
{OPERATOR_GE} { yylval.infix_op = *yytext ;return ge;  }
{EQ} { 	return eq; }

{IDENTIFIER}  { 
		yylval.identifier = strdup(yytext); 
		return identifier; }
{DEC} { 
	yylval.number = atoi(yytext); 
	return num; }
{HEX} { 
	yylval.number = strtoul(yytext+2, NULL, 16); 
	return num; }

{STRING_LITERAL} {
			printf("lexer read string %s \n\n", yytext);
			// pointer arithmetic ro remove the first "
			char* string = strdup(yytext + 1);
			string[yyleng - 2] = '\0';
			yylval.string = string;
			return string_literal;
		}
{OPERATOR}  { 
		yylval.infix_op = *yytext; 
		//return op; 
		return *yytext;}
{DELIMITER} { 
		return delimiter;}

(\n) {
	yylineno++; }
(\ )
.     return *yytext;









