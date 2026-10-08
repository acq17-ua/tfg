%token _main _int _float _printf _scanf _if _else _while _for _id _nentero _nreal
%token _coma _pyc _pari _pard
%token _opeq _oprel _opas _opmd _asig _ref _cori _cord _llavei _llaved
%token _format _incrdecr

%nonassoc _ifx
%nonassoc _else

%{
	#include "comun.h"

	int yyerror(char* s);
	extern int col, row, eof;

	extern int yylex();
	extern char* yytext;
	extern FILE* yyin;

%}

%%
	S 			: 	FVM
					{
						$$.cod = $1.cod;
					}
				;

	FVM 		: 	DVar 
					FVM
					{
						/* TODO que hago con las declaraciones fuera de funciones */
					}

 				| 	_int 
					_main 
					_pari 
					_pard 
					Bloque
					{
						$$.cod = "define i32 main()" + $5.cod;
					}
				;

	Tipo 		: 	_int
					{
						$$.cod = "i32";
						fprintf(stderr, "{Tipo-1} : %s\n", $$.cod.c_str());
					}

 				| 	_float
					{
						$$.cod = "float";
						fprintf(stderr, "{Tipo-2} : %s\n", $$.cod.c_str());
					}
				;

	Bloque 		: 	_llavei 
					BDecl 
					SeqInstr 
					_llaved
					{
						$$.cod = "{\n" + $1.cod + $2.cod + "\n}\n";
					}
				;

	BDecl 		: 	BDecl 
					DVar
					{
						$$.cod = $1.cod + $2.cod;
					}

		 		| 	%empty
					{
						$$.cod = "";
					}
				;

	DVar 		: 	Tipo
					LIdent 
					_pyc
					{
						$$.cod = $2.cod;
						fprintf(stderr, "{DVar} : %s\n", $$.cod.c_str());
					}
				;

	LIdent 		: 	LIdent
					_coma
					{
						$$.cod = $-0.cod; // tipo
						//fprintf(stderr, "LIdent-1 refs -1 : \"%s\"\n", $0.cod.c_str());
					}
					Variable
					{
						$$.cod = $4.cod;
						fprintf(stderr, "{LIdent-1} : %s\n", $$.cod.c_str());
					}
	
	 			| 	Variable
					{
						$$.cod = $1.cod;
						fprintf(stderr, "{LIdent-2} : %s\n", $$.cod.c_str());
					}
				;

	Variable 	: 	_id
					V
					{
						$$.cod 	= "%" + $1.lex + " = alloca " + $-0.cod + "\n" + $1.cod; 

						fprintf(stderr, "{Variable} : %s\n", $$.cod.c_str());
					}
				;

	V 			: 	%empty
					{
						$$.cod = "";
					}
				
				| 	_cori
					_nentero
					_cord
					V
				;

	SeqInstr 	: 	SeqInstr
					Instr

				| 	%empty
					{
						$$.cod = "";
					}
				;

	Instr 		: 	_pyc
				
				| 	Bloque

				| 	Ref
					_asig
					Expr
					_pyc

				| 	_printf
					_pari
					_format
					_coma
					Expr
					_pard
					_pyc

				| 	_scanf
					_pari
					_format
					_coma
					Ref
					_pard
					_pyc

				| 	_if
					_pari
					Expr
					_pard
					Instr
					%prec _ifx

				| 	_if
					_pari
					Expr
					_pard
					Instr
					_else
					Instr
					
	
				;

	Expr 		: 	Expr
					_oprel
					Esimple

				| 	Esimple
				;

	Esimple 	: 	Esimple
					_opas
					Term

				| 	Term
				;
	
	Term 		: 	Term	
					_opmd
					Factor

				| 	Factor
				;

	Factor		: 	Ref
				
				| 	_nentero

				| 	_nreal

				| 	_pari
					Expr
					_pard

				;

	Ref 		: 	_id
				| 	Ref
					_cori
					Esimple
					_cord
				;

%%

int yyerror(char *s)
{
	if (eof) 
	{
		msgError(ERR::EOF_, NULL);
	}
	else
	{  
		yylval.col = col - strlen(yytext);
		yylval.row = row;
		yylval.lex = strdup(yytext);
		msgError(ERR::SINT, &yylval);
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

