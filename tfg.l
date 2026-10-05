D 	[0-9]
L 	[a-zA-Z]
LD 	[0-9a-zA-Z]

%{
	#include "comun.h"
	#include "tfg.tab.h"

	int col=1, row=1, eof=0;

	// Update col/row, return token
	int ret(int token, string s="");
%}

%%

" " 		{ col++; }
[\t] 		{ col++; }
[\n] 		{ col=1; row++; }
"//(.)*" 	{ ; /*comment*/ }

"main" 		{ return ret(_main); }
"int" 		{ return ret(_int); }
"float" 	{ return ret(_float); }
"printf" 	{ return ret(_printf); }
"scanf" 	{ return ret(_scanf); }
"if" 		{ return ret(_if); }
"else" 		{ return ret(_else); }
"while" 	{ return ret(_while); }
"for" 		{ return ret(_for); }

"[A-Za-z][0-9A-Za-z]*" 	{ return ret(_id); }
"[0-9]+" 				{ return ret(_nentero); }
"([0-9]+)"."([0-9]+)" 	{ return ret(_nreal); }

"," 	{ return ret(_coma); }
";" 	{ return ret(_pyc); }
"(" 	{ return ret(_pari); }
")" 	{ return ret(_pard); }
"==" 	{ return ret(_opeq, "eq"); }
"!=" 	{ return ret(_opeq, "ne"); }
"<" 	{ return ret(_oprel, "lt"); }
"<=" 	{ return ret(_oprel, "le"); }
">" 	{ return ret(_oprel, "gt"); }
">=" 	{ return ret(_oprel, "ge"); }
"+" 	{ return ret(_opas, "add"); }
"-" 	{ return ret(_opas, "sub"); }
"*" 	{ return ret(_opmd, "mul"); }
"/" 	{ return ret(_opmd, "div"); }
"=" 	{ return ret(_asig); }
"&" 	{ return ret(_ref); }
"[" 	{ return ret(_cori); }
"]" 	{ return ret(_cord); }
"{" 	{ return ret(_llavei); }
"}" 	{ return ret(_llaved); }

"\"%d\"" 	{ return ret(_format); }
"\"%g\"" 	{ return ret(_format); } 
"++" 		{ return ret(_incrdecr); }
"--" 		{ return ret(_incrdecr); }

.		{ 	yylval.col = col;
			yylval.row = row;
			yylval.lex = strdup(yytext);
			msgError(ERR::LEXICO, yylval); }

%%

int yywrap(void) { eof=1; return 1; }

int ret(int token, string s)
{
	yylval.lex = strdup(yytext);
	yylval.row = row;
	yylval.col = col;
	col += (strlen(yytext));
	yylval.cod = s;

	//cout << yylval.lexema << "(" << yylval.nlin << "," << yylval.ncol << ")\n";

	return token;
}

void msgError(ERR nerror,int nlin,int ncol,const char *s) {

	switch(nerror)
	{
		case ERR::LEXICO:
			fprintf(stderr, "Lexic error at [%d, %d] -- Unexpected character '%s'\n", 
					culprit.row, 
					culprit.col, 
					culprit.lex.c_str());
			break;

		case ERR::SINT:
			fprintf(stderr, "Semantic error at [%d, %d] -- ", 
					culprit.row, 
					culprit.col);
			break;

		case ERR::EOF_:
			fprintf(stderr, "Lexic error -- Unexpected end of file.\n");
			break;

		default:
			fprintf(stderr, "Semantic error at: [%d, %d] -- ", culprit.row, culprit.col);
			break;
	}

	switch(nerror)
	{
		case ERR::YADECL:
			fprintf(stderr, "Symbol '%s' was declared twice.\n", 
					culprit.lex.c_str());
			break;

		case ERR::NODECL:
			fprintf(stderr, "Symbol '%s' used before declaration.\n", 
					culprit.lex.c_str());
			break;

		case ERR::DIM:
			fprintf(stderr, "Array access requires a positive index.\n"); 
			break;

		case ERR::OUTOFMEMORY:
			fprintf(stderr, "Out of memory for variable %s.\n", 
					culprit.lex.c_str());
			break;

		case ERR::TOOMANY:
			fprintf(stderr, "Too many indexes provided for array.\n");
			break;

		case ERR::TOOFEW:
			fprintf(stderr, "Too few indexes provided for array.\n");
			break;

		case ERR::FLOATINGINDEX:
			fprintf(stderr, "Provided a non-integer index.\n");
			break;

		case ERR::NUM:
			fprintf(stderr, "Provided a non-numerical operand.\n");
			break;

		case ERR::TYPES:
			fprintf(stderr, "Incompatible types provided for operation led by '%s'\n",
					culprit.lex.c_str());
			break;

		case ERR::MAXTMP:
			fprintf(stderr, "Out of memory por temps.\n");
			break;
	}

}


void msgError(ERR nerror) { return; }
void msgError(ERR nerror, const TOKEN culprit) { return; }
