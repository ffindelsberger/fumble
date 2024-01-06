%{
#include "ast.h"
#include "fumble.tab.h"
%}

IDENTIFIER  [a-z]+
DEC [0-9]+
HEX 0x[0-9a-fA-F]+

OPERATOR  [-+*/]
COMPARATOR_EQUAL "=="
COMPARATOR_NOT_EQUAL "!="
COMPARATOR_LESSER "<"
COMPARATOR_GREATER ">"


ASS "="
DELIMITER ";"

KEY_IF "if"
KEY_ELSE "else"
KEY_LET "let"
KEY_LOOP "loop"
KEY_BREAK "break"	
KEY_FN "fn"
KEY_RETURN "return"

BUILTIN_PRINTLN "println"

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

{COMPARATOR_EQUAL} { yylval.infix_op = *yytext; return equal;  }
{COMPARATOR_NOT_EQUAL} { yylval.infix_op = *yytext ;return not_equal;  }
{COMPARATOR_LESSER} { yylval.infix_op = *yytext ;return *yytext;  }
{COMPARATOR_GREATER} { yylval.infix_op = *yytext ;return *yytext;  }

{IDENTIFIER}  { 
		yylval.identifier = strdup(yytext); 
		return identifier; }
{DEC} { 
	yylval.number = atoi(yytext); 
	return num; }
{HEX} { 
	yylval.number = strtoul(yytext+2, NULL, 16); 
	return num; }
{OPERATOR}  { 
		yylval.infix_op = *yytext; 
		//return op; 
		return *yytext;}
{ASS} { 
	yylval.ass = strdup(yytext);
	return ass; }
{DELIMITER} { 
		return delimiter;}

(\n) {
	yylineno++; }
(\ )
.     return *yytext;









