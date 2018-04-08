%{
#include <stdio.h>
#include <string.h>
#include "y.tab.h"
#include<iostream>
using namespace std;
%}

DIGIT  [0-9]+
ID [a-zA-Z_][0-9a-zA-Z_]*
FLOAT [0-9]+[.][0-9]*
OTHERS ['=' ';' '(' ')' '{' '}']
TYPE ["int" "float"]
ARITHMETIC_OPERATORS [ '+' '\-' '*' '/' '%' '^' ]
RELATIONAL_OPERATORS [ "==" ">=" "<=" "<" ">" "!="]
%%

                        
[ \t] ;
[\n] ;											 
{DIGIT}  							{ yylval.i_num=atoi(yytext);  return DIGIT; }												 
{FLOAT}               { yylval.f_num=atoi(yytext);  return FLOAT; }
{OTHERS}              { char a= yytext[0];
                        return(a); }
"int"                 { return (TYPE);}
"float"               { return (TYPE);}
{ARITHMETIC_OPERATORS} { char a=yytext[0]; return a;}
">"	{yylval.str = strdup(yytext);
		return (RELATIONAL_OP);}
"<"	{yylval.str = strdup(yytext);
		return (RELATIONAL_OP);}
">="	{yylval.str = strdup(yytext);
		return (RELATIONAL_OP);}
"<="	{yylval.str = strdup(yytext);
		return (RELATIONAL_OP); }
"!="	{yylval.str = strdup(yytext);
		return (RELATIONAL_OP);}
"=="	{yylval.str = strdup(yytext);
		return (RELATIONAL_OP);}
		
"||"	{yylval.str = strdup(yytext);
		return (OR);}
"&&"	{yylval.str = strdup(yytext);
		return (AND);}
"!"	{yylval.str = strdup(yytext);
		return (NOT);}
"true"	{yylval.str = strdup(yytext);
		return (TRUE);}
"false"	{yylval.str = strdup(yytext);
		return (FALSE);}		
		
		
{ID} 										{ yylval.str=strdup(yytext);
                       		return ID;}	
                       									             



%%


