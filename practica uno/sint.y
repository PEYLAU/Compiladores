
%{
#include <stdio.h>
#include "listaCodigo.h"
#include "listaSimbolos.h"
Lista tablaSimb;
Tipo tipo; 
void yyerror();
void introducirSimbolo();
int perteneceLista();
void imprimirTabla();
void escribirSimbenFichero();
void escribirCodigenFichero();
int contCadenas=0; 
extern int yylex();
extern int yylineno;
int reg = 0;
int salto_check = 1;
%}
%union{
int ent;
char * cad;
ListaC codigo;
}

%code requires{
	#include "listaCodigo.h"
}

%expect 1
%token ASSIGNOP LPAREN RPAREN LKEY RKEY VAR CONST SEMICOLON COMMA ELSE WHILE IF PRINT READ INTERROGANT TWODOTS NUM INT COMMENT1 COMMENT2 ID CHARCHAIN
%token <ent> INTLITERAL
%left PLUSOP MINUSOP
%left MULTOP DIVOP
%left UMENOS


%type <cad> program ID CHARCHAIN
%type <codigo> expression



%%

program : {tablaSimb = creaLS();} ID LPAREN RPAREN LKEY declarations statement_list RKEY {imprimirTabla(tablaSimb); escribirSimbenFichero(tablaSimb); liberaLS(tablaSimb);}

declarations : declarations VAR {tipo = VARIABLE;} tipo var_list SEMICOLON
	| declarations CONST {tipo = CONSTANTE;} tipo const_list SEMICOLON
	| ;
	
tipo : INT;

var_list : ID { if(!perteneceLista($1)) {introducirSimbolo($1, tipo, 0);}
										else printf("Ya está en la lista\n");}
	| var_list COMMA ID { if(!perteneceLista($3)) {introducirSimbolo($3, tipo, 0);}
										else printf("Ya está en la lista\n");}

const_list : ID ASSIGNOP expression { if(!perteneceLista($1)) introducirSimbolo($1, tipo, 0);
										else printf("Ya está en la lista\n");}
	| const_list COMMA ID ASSIGNOP expression { if(!perteneceLista($3)) {introducirSimbolo($3, tipo, 0);}
										else printf("Ya está en la lista\n");}
	
statement_list : statement_list statement
	| ;

statement : ID ASSIGNOP expression SEMICOLON{ if(!perteneceLista($1)) printf("Esta super mal joder\n");}
	| LKEY statement_list RKEY
	| IF LPAREN expression RPAREN statement  
	| IF LPAREN expression RPAREN statement ELSE statement
	| WHILE LPAREN expression RPAREN statement
	| PRINT LPAREN print_list RPAREN SEMICOLON
	| READ LPAREN read_list RPAREN SEMICOLON;
	
print_list : print_item
	| print_list COMMA print_item;
	
print_item : expression
	| CHARCHAIN {tipo = CADENA; contCadenas++; introducirSimbolo($1, tipo, contCadenas);};
	
read_list : ID {  if(!perteneceLista($1)) printf("Esta super mal joder\n");}
	| read_list COMMA ID {  if(!perteneceLista($3)) printf("Esta super mal joder\n");}
	
expression : expression PLUSOP expression {$$ = $1;
			concatenaLC($$, $3);
			Operacion oper;
			oper.op = "add";
			oper.res = recuperaResLC($1);
			oper.arg1 = recuperaResLC($1);
			oper.arg2 = recuperaResLC($3);
			insertaLC($$, finalLC($$), oper);
			liberaLC($3);
			}
        | expression MINUSOP expression{$$ = $1;
			concatenaLC($$, $3);
			Operacion oper;
			oper.op = "sub";
			oper.res = recuperaResLC($1);
			oper.arg1 = recuperaResLC($1);
			oper.arg2 = recuperaResLC($3);
			insertaLC($$, finalLC($$), oper);
			liberaLC($3);
			}
        | expression MULTOP expression{$$ = $1;
			concatenaLC($$, $3);
			Operacion oper;
			oper.op = "mul";
			oper.res = recuperaResLC($1);
			oper.arg1 = recuperaResLC($1);
			oper.arg2 = recuperaResLC($3);
			insertaLC($$, finalLC($$), oper);
			liberaLC($3);
			}
       	| expression DIVOP expression{$$ = $1;
			concatenaLC($$, $3);
			Operacion oper;
			oper.op = "div";
			oper.res = recuperaResLC($1);
			oper.arg1 = recuperaResLC($1);
			oper.arg2 = recuperaResLC($3);
			insertaLC($$, finalLC($$), oper);
			liberaLC($3);
			}
		| LPAREN expression INTERROGANT expression TWODOTS expression RPAREN{$$ = $2;
			Operacion oper;
			oper.op = "beqz";
			sprintf(oper.res,"$l%d", salto_check);
			salto_check++;
			oper.arg1 = NULL;
			oper.arg2 = NULL;
			insertaLC($$, finalLC($$), oper);
			concatenaLC($$, $4);
		
			Operacion oper2;
			oper2.op = "move";
			oper2.res = recuperaResLC($2);
			oper2.arg1 = recuperaResLC($4);
			oper2.arg2 = NULL;
			insertaLC($$, finalLC($$), oper2);
		
			Operacion oper3;
			oper3.op = "b";
			sprintf(oper3.res,"$l%d", salto_check);
			salto_check++;
			oper3.arg1 = NULL;
			oper3.arg2 = NULL;
			insertaLC($$, finalLC($$), oper3);
			liberaLC($4);

			Operacion oper4; 
			sprintf(oper4.op, "$l%d:", salto_check-2);
			oper4.res = NULL;
			oper4.arg1 = NULL;
			oper4.arg2 = NULL; 
			insertaLC($$, finalLC($$), oper4);
		
			concatenaLC($$,$6); 
		
			Operacion oper5;
			oper5.op = "move";
			oper5.res = recuperaResLC($2);
			oper5.arg1 = recuperaResLC($6);
			oper5.arg2 = NULL;
			insertaLC($$, finalLC($$), oper5);
			liberaLC($6); 
		
			Operacion oper6; 
			sprintf(oper6.op, "$l%d:", salto_check-1);
			oper6.res = NULL;
			oper6.arg1 = NULL;
			oper6.arg2 = NULL; 
			insertaLC($$, finalLC($$), oper6);
		
		
		
		
		
		
		}
		| MINUSOP expression %prec UMENOS{$$ = $2;
			Operacion oper;
			oper.op = "neg";
			oper.res = recuperaResLC($2);
			oper.arg1 = recuperaResLC($2);
			oper.arg2 = NULL;
			insertaLC($$, finalLC($$), oper);
			}
        | LPAREN expression RPAREN{$$ = $2;}
		| INTLITERAL {$$ = creaLC();
			Operacion oper;
			oper.op = "li";
			sprintf(oper.res, "$t%d", reg);
			reg++;
			sprintf(oper.arg1, "%d", $1);
			oper.arg2 = NULL;
			insertaLC($$, finalLC($$), oper);
			guardaResLC($$, oper.res);
			}
		| ID { if(!perteneceLista($1)) printf("Esta super mal joder\n");
			$$ = creaLC();
			Operacion oper;  
			oper.op = "lw"; 
			sprintf(oper.res, "$t%d", reg);
			reg++; 
			sprintf(oper.arg1, "_%s", $1);
			oper.arg2 = NULL; 
			insertaLC($$, finalLC($$), oper);
			guardaResLC($$, oper.res);				
			}


%%
void yyerror()
{
printf("Se ha producido un error en esta expresion en la linea %d\n", yylineno);
}

int perteneceLista(char * nombre){
	if(buscaLS(tablaSimb, nombre) == NULL){
		return 0; 
	}
	
	return 1; 
	
}

void introducirSimbolo(char *nombre, Tipo t, int valor){

Simbolo s = {nombre, tipo, valor}; 
insertaLS(tablaSimb, finalLS(tablaSimb), s);

}

void imprimirTabla(Lista tabla){

	PosicionLista in = inicioLS(tabla);
	int n = longitudLS(tabla);
	
	for(int i = 0; i < n; i++){
		printf("%d\n", i+1);
		Simbolo s = recuperaLS(tabla, in);
		printf("Nombre: %s\n", s.nombre);
		printf("Tipo: %d\n", s.tipo);
		printf("Valor: %d\n", s.valor);
		in = siguienteLS(tabla, in);
	}

}

void escribirSimbenFichero(Lista tabla){
	FILE * f = fopen("ensamb", "w");
	if(f == NULL){
		printf("EL fichero no existe");
	}
	else{
		fprintf(f, "\t.data\n\n");
	}
	
	PosicionLista in = inicioLS(tabla);
	int n = longitudLS(tabla);
	
	for(int i = 0; i < n; i++){
		Simbolo s = recuperaLS(tabla, in);
		if(s.tipo == CADENA){
			fprintf(f, "$str%d:\n", s.valor);
			fprintf(f, "\t.asciiz %s\n\n", s.nombre);
		
		}
		in = siguienteLS(tabla, in);
	}
	
	in = inicioLS(tabla);
	n = longitudLS(tabla);
	
	for(int i = 0; i < n; i++){
		Simbolo s = recuperaLS(tabla, in);
		if(s.tipo != CADENA){
			fprintf(f, "_%s:\n", s.nombre);
			fprintf(f, "\t.word 0\n\n");
		
		}
		in = siguienteLS(tabla, in);
	}
	
	
	fclose(f);

}

void escribirCodigenFichero(ListaC tabla){
	FILE * f = fopen("codigo", "w");
	if(f == NULL){
		printf("EL fichero no existe");
	}
	else{
		fprintf(f, "\t.globl main\n\n");
		fprintf(f, "main:\n\n");
	}
	
	PosicionLista in = inicioLC(tabla);
	int n = longitudLC(tabla);
	
	for(int i = 0; i < n; i++){
		Operacion oper = recuperaLC(tabla, in);
		fprintf(f, "%s %s %s %s\n", oper.op, oper.res, oper.arg1, oper.arg2);
	}
	

	
	
	fclose(f);

}
