miniC: main.c sint.tab.c lex.yy.c sint.tab.h listaCodigo.c listaCodigo.h listaSimbolos.c listaSimbolos.h
	gcc lex.yy.c main.c sint.tab.c listaCodigo.c listaSimbolos.c -lfl -o miniC
sint.tab.c sint.tab.h: sint.y
	bison -d -v sint.y
lex.yy.c: lexico.l
	flex lexico.l
limpia:
	rm lex.yy.c sint.tab.c sint.tab.h miniC
run: 
	./miniC
