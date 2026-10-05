#include <iostream>
#include <cstring>
using namespace std;

enum ERR 
{
	LEXICO,
	SINT,
	EOF_,
	LEXEOF,
	YADECL,
	NODECL,
	DIM,
	OUTOFMEMORY,
	TOOFEW,
	TOOMANY,
	FLOATINGINDEX,
	NUM,
	TYPES,
	MAXTMP
};

typedef struct {
	string lex;
	unsigned type;
    string cod;
    unsigned addr;
    unsigned dbase;
    unsigned row, col;
} TOKEN;

#define YYSTYPE TOKEN

void msgError(ERR nerror);
void msgError(ERR nerror, const TOKEN culprit);
void msgError(ERR nerror,int row,int col,const char *s);



