#include <stdio.h>
#include <stdlib.h>
#include "lexico.h"

extern char *yytext;
extern int  yyleng;
extern FILE *yyin;
extern int yylex();
extern int yyparse();
int err = 0;
FILE *fich;
int main(int argc, char * argv[])
{
    
    if(argc < 2){
        fprintf(stderr, "FALTAN ARGUMENTOS. INCLUYE NOMBRE DE FICHERO DE ENTRADA\n");
        return 1;
    }

   
    if ((fich=fopen(argv[1],"r"))== NULL) {
        printf("***ERROR, no puedo abrir el fichero\n");
        exit(1);		}
        
    yyin=fich;
 
    yyparse();
    fclose(fich);
    return 0;
}
