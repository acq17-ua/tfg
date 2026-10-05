OPTS=-Wall -g -Wno-write-strings -Wno-unused-function -Wno-sign-compare -std=c++11
OBJS=lex.yy.o tfg.tab.o #TablaSimbolos.o TablaTipos.o VariablesMemoria.o
CC=g++
TAR = tar -cvzf

tfg: $(OBJS)
	$(CC) $(OPTS) $(OBJS) -o tfg

lex.yy.o: lex.yy.c comun.h tfg.tab.h
	$(CC) $(OPTS) -c lex.yy.c

tfg.tab.o: tfg.tab.c lex.yy.c comun.h
	$(CC) $(OPTS) -c tfg.tab.c

#TablaSimbolos.o: TablaSimbolos.cc TablaSimbolos.h
#	$(CC) $(OPTS) -c TablaSimbolos.cc

#TablaTipos.o: TablaTipos.cc TablaTipos.h TablaSimbolos.h 
#	$(CC) $(OPTS) -c TablaTipos.cc

#VariablesMemoria.o: VariablesMemoria.cc VariablesMemoria.h

lex.yy.c : tfg.l comun.h
	flex tfg.l
	
tfg.tab.c tfg.tab.h: tfg.y lex.yy.c comun.h #TablaSimbolos.h TablaTipos.h VariablesMemoria.h
	bison -d tfg.y	

entrega:
	$(TAR) tfg.tgz Makefile tfg.l tfg.y comun.h TablaSimbolos.h TablaSimbolos.cc TablaTipos.h TablaTipos.cc VariablesMemoria.h VariablesMemoria.cc 

clean:
	rm -f $(OBJS)
	rm -f tfg.tab.c tfg.tab.h lex.yy.c
	rm -f tfg
