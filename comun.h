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
	unsigned th;
    string cod;
    unsigned addr;
    unsigned dbase;
    unsigned row, col;
} TOKEN;

#define YYSTYPE TOKEN

void msgError(const ERR, const TOKEN*);
void msgError(const ERR, const unsigned, const unsigned, const string);



