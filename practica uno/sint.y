
%{
#define _GNU_SOURCE
#include <stdio.h>
#include <string.h>
#include "listaCodigo.h"
#include "listaSimbolos.h"
Lista tablaSimb;
ListaC tablaCod;
Tipo tipo; 
void yyerror();
void introducirSimbolo();
int perteneceLista();
void imprimirTabla();
void imprimirTablaLC();
void escribirSimbenFichero();
void escribirCodigenFichero();
void insertafinalLC();
void liberaReg();
void liberaRegLit();
int contCadenas=0; 
char * getReg();
char * getSalto();
char * concatenar();
char * concatenarInt();
extern int yylex();
extern int yylineno;
int reg = 0;
int salto_check = 1;
int regs[10] = {0,0,0,0,0,0,0,0,0,0};
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
%type <codigo> expression statement_list statement print_list print_item read_list const_list declarations var_list



%%

program : {tablaSimb = creaLS(); tablaCod = creaLC();} ID LPAREN RPAREN LKEY declarations statement_list RKEY {escribirSimbenFichero(tablaSimb); concatenaLC(tablaCod, $6); concatenaLC(tablaCod, $7); insertafinalLC(tablaCod); escribirCodigenFichero(tablaCod); liberaLS(tablaSimb); liberaLC(tablaCod);}

declarations : declarations VAR {tipo = VARIABLE;} tipo var_list SEMICOLON	{
	$$ = $1;
	concatenaLC($$, $5);
	liberaLC($5);
}
	| declarations CONST {tipo = CONSTANTE;} tipo const_list SEMICOLON{
		$$ = $1;
		concatenaLC($$, $5);
		liberaLC($5);
	}
	| {$$ = creaLC();};
	
tipo : INT;

var_list : ID { if(!perteneceLista($1)) {introducirSimbolo($1, tipo, 0);}
										else printf("Ya está en la lista\n");
										$$ = creaLC();}
	| var_list COMMA ID { if(!perteneceLista($3)) {introducirSimbolo($3, tipo, 0);}
										else printf("Ya está en la lista\n");
										$$ = creaLC();
										}

const_list : ID ASSIGNOP expression { if(!perteneceLista($1)) introducirSimbolo($1, tipo, 0);
										else printf("Ya está en la lista\n");
										$$ = $3;
										
									
										Operacion oper1;
										oper1.op = "sw";
										oper1.res = recuperaResLC($3);
										oper1.arg1 =  concatenar("_", $1);
										oper1.arg2 = NULL;
										insertaLC($$, finalLC($$), oper1);

										liberaReg($3);
									
										}
	| const_list COMMA ID ASSIGNOP expression { if(!perteneceLista($3)) {introducirSimbolo($3, tipo, 0);}
										else printf("Ya está en la lista\n");
										
										$$ = $1;
										concatenaLC($$, $5);
										
										

										Operacion oper1;
										oper1.op = "sw";
										oper1.res = recuperaResLC($5);
										oper1.arg1 =  concatenar("_", $3);
										oper1.arg2 = NULL;
										insertaLC($$, finalLC($$), oper1);

										liberaReg($5);
										liberaLC($5);
										
										}
	
statement_list : statement_list statement {
		$$ = $1;
		concatenaLC($$, $2);
		liberaLC($2);
		}
	| {$$ = creaLC();};

statement : ID ASSIGNOP expression SEMICOLON{ 
		if(!perteneceLista($1)) printf("ID no está en la lista\n");
		$$ = $3;
		Operacion oper;
		oper.op = "sw"; 
		oper.res = recuperaResLC($3); 
		oper.arg1 = concatenar("_", $1);
		oper.arg2 = NULL; 
		insertaLC($$, finalLC($$), oper);	
		liberaRegLit(oper.res);
	}
	| LKEY statement_list RKEY {$$ = $2;}
	| IF LPAREN expression RPAREN statement  {
		
		$$ = $3;
		Operacion oper;
		oper.op = "beqz";
		oper.res = recuperaResLC($3);
		oper.arg1 = getSalto();
		oper.arg2 = NULL;
		
		liberaReg($3);
		insertaLC($$, finalLC($$), oper);
		concatenaLC($$, $5);
		
		
		liberaLC($5);
	
		Operacion oper1;
		oper1.op = concatenar(oper.arg1, ":");
		oper1.res = NULL;
		oper1.arg1 = NULL;
		oper1.arg2 = NULL;
		insertaLC($$, finalLC($$), oper1);
		

	}
	| IF LPAREN expression RPAREN statement ELSE statement{

		$$ = $3; 
		Operacion oper;
		oper.op = "beqz";
		oper.res = recuperaResLC($3);
		oper.arg1 = getSalto();
		oper.arg2 = NULL;

		insertaLC($$, finalLC($$), oper); 

		liberaReg($3);

		concatenaLC($$, $5); 
		liberaLC($5); 

		Operacion oper1;
		oper1.op = "j";
		oper1.res = getSalto();
		oper1.arg1 = NULL;
		oper1.arg2 = NULL;

		insertaLC($$, finalLC($$), oper1);


		Operacion oper2;
		oper2.op = concatenar(oper.arg1, ":");
		oper2.res = NULL;
		oper2.arg1 = NULL;
		oper2.arg2 = NULL;
		insertaLC($$, finalLC($$), oper2);

		concatenaLC($$, $7); 
		liberaLC($7);

		Operacion oper3;
		oper3.op = concatenar(oper1.res, ":");
		oper3.res = NULL;
		oper3.arg1 = NULL;
		oper3.arg2 = NULL;
		insertaLC($$, finalLC($$), oper3);
		

		}

	| WHILE LPAREN expression RPAREN statement {

		char * salto1 = getSalto();
		char * salto2 = getSalto();

		$$ = creaLC();
		Operacion oper;
		oper.op = concatenar(salto1, ":");
		oper.res = NULL;
		oper.arg1 = NULL;
		oper.arg2 = NULL;
		insertaLC($$, finalLC($$), oper);

		concatenaLC($$, $3);
		
		
		Operacion oper1;
		oper1.op = "beqz";
		oper1.res = recuperaResLC($3);
		oper1.arg1 = salto2;
		oper1.arg2 = NULL;

		liberaReg($3);
		liberaLC($3);
		insertaLC($$, finalLC($$), oper1); 

		concatenaLC($$, $5); 
		liberaLC($5); 

		Operacion oper2;
		oper2.op = "j";
		oper2.res = salto1;
		oper2.arg1 = NULL;
		oper2.arg2 = NULL;

		insertaLC($$, finalLC($$), oper2);

		Operacion oper3;
		oper3.op = concatenar(salto2, ":");
		oper3.res = NULL;
		oper3.arg1 = NULL;
		oper3.arg2 = NULL;
		insertaLC($$, finalLC($$), oper3);



	}
	| PRINT LPAREN print_list RPAREN SEMICOLON{$$ = $3;}
	| READ LPAREN read_list RPAREN SEMICOLON{$$ = $3;}
	
print_list : print_item {
			$$ = $1;
		}
	| print_list COMMA print_item{
			$$ = $1;
			concatenaLC($$,$3);
			liberaLC($3);
		}
	
print_item : expression {
				$$ = $1;
	
				Operacion oper1;
				oper1.op = "li";
				oper1.res = "$v0";
				oper1.arg1 = concatenarInt("", 1);
				oper1.arg2 = NULL;
				insertaLC($$, finalLC($$), oper1);

				Operacion oper2;
				oper2.op = "move";
				oper2.res = "$a0";
				oper2.arg1 = recuperaResLC($1);
				oper2.arg2 = NULL;
				insertaLC($$, finalLC($$), oper2);

				Operacion oper3;
				oper3.op = "syscall";
				oper3.res = NULL;
				oper3.arg1 = NULL;
				oper3.arg2 = NULL;
				insertaLC($$, finalLC($$), oper3);

	}
	| CHARCHAIN {if(!perteneceLista($1)){
					tipo = CADENA; contCadenas++; introducirSimbolo($1, tipo, contCadenas);
				}

				Simbolo simb = recuperaLS(tablaSimb, buscaLS(tablaSimb, $1));

				$$ = creaLC();
				Operacion oper;
				oper.op = "la";
				oper.res = "$a0";
				oper.arg1 = concatenarInt("$str", simb.valor);
				oper.arg2 = NULL;
				insertaLC($$, finalLC($$), oper);
				guardaResLC($$, oper.res);
				
				Operacion oper1;
				oper1.op = "li";
				oper1.res = "$v0";
				oper1.arg1 = concatenarInt("", 4);
				oper1.arg2 = NULL;
				insertaLC($$, finalLC($$), oper1);

		

				Operacion oper3;
				oper3.op = "syscall";
				oper3.res = NULL;
				oper3.arg1 = NULL;
				oper3.arg2 = NULL;
				insertaLC($$, finalLC($$), oper3);

	}
	
read_list : ID {  if(!perteneceLista($1)) printf("ID no está en la lista\n");
				$$ = creaLC();
				Operacion oper1;
				oper1.op = "li";
				oper1.res = "$v0";
				oper1.arg1 = concatenarInt("", 5);
				oper1.arg2 = NULL;
				insertaLC($$, finalLC($$), oper1);

				Operacion oper2;
				oper2.op = "syscall";
				oper2.res = NULL;
				oper2.arg1 = NULL;
				oper2.arg2 = NULL;
				insertaLC($$, finalLC($$), oper2);

				Operacion oper3;
				oper3.op = "sw"; 
				oper3.res = "$v0"; 
				oper3.arg1 = concatenar("_", $1);
				oper3.arg2 = NULL; 
				insertaLC($$, finalLC($$), oper3);
}
	| read_list COMMA ID {  if(!perteneceLista($3)) printf("ID no está en la lista\n");
				$$ = $1;
				Operacion oper1;
				oper1.op = "li";
				oper1.res = "$v0";
				oper1.arg1 = concatenarInt("", 5);
				oper1.arg2 = NULL;
				insertaLC($$, finalLC($$), oper1);

				Operacion oper2;
				oper2.op = "syscall";
				oper2.res = NULL;
				oper2.arg1 = NULL;
				oper2.arg2 = NULL;
				insertaLC($$, finalLC($$), oper2);

				Operacion oper3;
				oper3.op = "sw"; 
				oper3.res = "$v0"; 
				oper3.arg1 = concatenar("_", $3);
				oper3.arg2 = NULL; 
				insertaLC($$, finalLC($$), oper3);
	}
	
expression : expression PLUSOP expression {$$ = $1;
			concatenaLC($$, $3);
			Operacion oper;
			oper.op = "add";
			oper.res = recuperaResLC($1);
			oper.arg1 = recuperaResLC($1);
			oper.arg2 = recuperaResLC($3);
			insertaLC($$, finalLC($$), oper);
			liberaReg($3);
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
			liberaReg($3);
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
			liberaReg($3);
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
			liberaReg($3);
			liberaLC($3);
			}
		| LPAREN expression INTERROGANT expression TWODOTS expression RPAREN{$$ = $2;
			Operacion oper;
			oper.op = "beqz";
			oper.res = getSalto();
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
			oper3.res = getSalto();
			oper3.arg1 = NULL;
			oper3.arg2 = NULL;
			insertaLC($$, finalLC($$), oper3);
			liberaReg($4);
			liberaLC($4);

			Operacion oper4; 
			oper4.op = concatenar(oper.res, ":");
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
			liberaReg($6);
			liberaLC($6); 
		
			Operacion oper6; 
			oper6.op = concatenar(oper3.res, ":");
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
		| INTLITERAL{ 
			$$ = creaLC();
			Operacion oper;  
			oper.op = "li"; 
			oper.res = getReg(); 
			oper.arg1 = concatenarInt("", $1);
			oper.arg2 = NULL; 
			insertaLC($$, finalLC($$), oper);
			guardaResLC($$, oper.res);			
			}
		| ID { 
			if(!perteneceLista($1)) printf("ID no está en la lista\n");
			$$ = creaLC();
			Operacion oper;  
			oper.op = "lw"; 
			oper.res = getReg(); 
			oper.arg1 = concatenar("_", $1);
			oper.arg2 = NULL; 
			insertaLC($$, finalLC($$), oper);
			guardaResLC($$, oper.res);			
			}


%%
void yyerror()
{
printf("Se ha producido un error en esta expresion en la linea %d\n", yylineno);
}

char *getReg(){


	int i = 0;
	while(regs[i] != 0){
		i = (i+1) % 10;
	}
	regs[i] = 1;
	char* retval;
	asprintf(&retval, "$t%d", i); 

	reg++;

	return retval;

}

void liberaReg(ListaC l){

	char* regchar = recuperaResLC(l);
	int reg = regchar[2] -'0';
	regs[reg] = 0;
}

void liberaRegLit(char * r){
	int reg = r[2]-'0';
	regs[reg] = 0;

}

char * getSalto(){
	char* retval;
	asprintf(&retval, "$l%d", salto_check);
	salto_check++;
	return retval;
}

char * concatenar(char * s1, char * s2){
	char * retval;
	asprintf(&retval, "%s%s", s1, s2);
	return retval;
}

char * concatenarInt(char * s1, int n){
	char * retval;
	asprintf(&retval, "%s%d", s1, n);
	return retval;
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

void imprimirTablaLC(ListaC tabla){
	printf("Codigo1 contiene %d operaciones\n",longitudLC(tabla));

  	PosicionListaC p = inicioLC(tabla);
  	while (p != finalLC(tabla)) {
    Operacion oper = recuperaLC(tabla,p);
    printf("%s",oper.op);
    if (oper.res) printf(" %s",oper.res);
    if (oper.arg1) printf(", %s",oper.arg1);
    if (oper.arg2) printf(", %s",oper.arg2);
    printf("\n");
    p = siguienteLC(tabla,p);
  }
}

void escribirSimbenFichero(Lista tabla){
	
	PosicionLista in = inicioLS(tabla);
	int n = longitudLS(tabla);

	printf("\t.data\n\n");
	
	for(int i = 0; i < n; i++){
		Simbolo s = recuperaLS(tabla, in);
		if(s.tipo == CADENA){
			printf("$str%d:\n", s.valor);
			printf("\t.asciiz %s\n\n", s.nombre);
		
		}
		in = siguienteLS(tabla, in);
	}
	
	in = inicioLS(tabla);
	n = longitudLS(tabla);
	
	for(int i = 0; i < n; i++){
		Simbolo s = recuperaLS(tabla, in);
		if(s.tipo != CADENA){
			printf("_%s:\n", s.nombre);
			printf("\t.word 0\n\n");
		
		}
		in = siguienteLS(tabla, in);
	}
	


}

void insertafinalLC(ListaC t){
	Operacion oper;
	oper.op = "li";
	oper.res = "$v0";
	oper.arg1 = concatenarInt("", 10);
	oper.arg2 = NULL;
	insertaLC(t, finalLC(t), oper);

	Operacion oper2;
	oper2.op = "syscall";
	oper2.res = NULL;	
	oper2.arg1 = NULL;
	oper2.arg2 = NULL;
	insertaLC(t, finalLC(t), oper2);

}

void escribirCodigenFichero(ListaC tabla){
	

	printf("\t.text\n");
	printf("\t.globl main\n\n");
	printf("main:\n\n");
	
	PosicionListaC in = inicioLC(tabla);
	int n = longitudLC(tabla);
	
	for(int i = 0; i < n; i++){
		Operacion oper = recuperaLC(tabla, in);
		
		if(oper.res == NULL && oper.arg1 == NULL && oper.arg2 == NULL && oper.op != "syscall"){
			printf("%s ", oper.op);
		}
		else{
			printf("\t%s ", oper.op);
		}

		if(oper.res != NULL){
			printf("%s ", oper.res);
		}

		if(oper.arg1 != NULL){
			printf("%s ", oper.arg1);
		}

		if(oper.arg2 != NULL){
			printf("%s ", oper.arg2);
		}

		printf("\n");
		
		in = siguienteLC(tabla, in);
	}
	

	
	

}
