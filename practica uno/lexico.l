%{
#include "sint.tab.h"
#include "listaCodigo.h"
#include "listaSimbolos.h"
%}

digito              [0-9]
letra               [a-zA-Z]

%option yylineno

%%
[ \r\n\t]+                                  ;
var											return VAR;
const										return CONST;
int 										return INT;
if 											return IF; 
else 										return ELSE; 
while 										return WHILE;
print 										return PRINT; 
read										return READ;
{digito}+                                    {if(atoll(yytext) > 2147483648) printf("Error léxico en la línea %d, entero fuera de rango", yylineno); yylval.ent=atoi(yytext);return INTLITERAL;}
"/*"([^*]|[*]+[^*/])*[*]*"*/"				return COMMENT1;
"//"(.*)\n									return COMMENT2;
\"([^"\n\\]|\\.)*\"						    yylval.cad=strdup(yytext);return CHARCHAIN;
({letra}|_)({letra}|{digito}|_)*			{if(yyleng > 31) printf("Error léxico en la línea %d, ID demasiado largo", yylineno); yylval.cad=strdup(yytext);return ID;}
"("                                         return LPAREN;		
")"                                         return RPAREN;
"="                                        	return ASSIGNOP;
";"                                         return SEMICOLON;
"+"                                         return PLUSOP;
"-"                                         return MINUSOP;
"*"											return MULTOP; 
"/"											return DIVOP;
","                                         return COMMA;
"{"											return LKEY;
"}"											return RKEY;
"?"											return INTERROGANT;
":" 										return TWODOTS;
[^a-zA-Z0-9" \n\r\t()=;+\-/*,{}?:]+			{printf("Error, cadena incorrecta: %s" ,yytext);}
%%
