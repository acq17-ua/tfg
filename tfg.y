%token _main _int _float _printf _scanf _if _else _while _for _id _nentero _nreal
%token _coma _pyc _pari _pard
%token _opeq _oprel _opas _opmd _asig _ref _cori _cord _llavei _llaved
%token _format _incrdecr

%{
	#include "comun.h"

	int yyerror(char* s);
	extern int col, row, eof;

	extern int yylex();
	extern char* yytext;
	extern FILE* yyin;

%}

%%
	// ETDS
	S : _main;
%%

int yyerror(char *s)
{
	if (eof) 
	{
		msgError(ERR::_EOF);
	}
	else
	{  
		yylval.ncol = col - strlen(yytext);
		yylval.nlin = row;
		yylval.lexema = strdup(yytext);
		msgError(ERR::SINT, yylval);
	}
	return 0;
}

int main(int argc, char* argv[])
{
	FILE* fent;
	
	if( argc == 2 )
	{
		fent = fopen(argv[1], "rt");
		if(fent)
		{
			yyin = fent;
			yyparse();
			fclose(fent);
		}
		else
			fprintf(stderr, "No puedo abrir el fichero\n");

	}
	else
		fprintf(stderr, "Uso: ejemplo <nombre de fichero>\n");
}

