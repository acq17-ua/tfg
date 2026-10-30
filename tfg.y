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

	bool dbg_lex=false, dbg_sem=false, dbg_sym=false;

	enum DVAR_LOCATION
	{
		out_function,
		in_function
	};

	SymbolTable tsym(nullptr);
	unsigned nextAddr = 1;
	SymbolTable temp(nullptr);
	unsigned nextTemp = 1;

	TypeTable ttypes;

%}

%%
	S 			: 	{
						$$.addr = DVAR_LOCATION::out_function;
						$$.prefix = "";
					}
					FVM
					{
						$$.cod = $2.cod;

						fprintf(stderr, "\n--------\nTRANSLATION\n--------\n%s", $$.cod.c_str());
					}
				;

	FVM 		: 	DVar
					{
						$$.prefix = $0.prefix;
					}
					FVM
					{
						$$.cod = $1.cod + $3.cod;

						if( dbg_sem )
							fprintf(stderr, "{FVM-1} : \"%s\"\n", $$.cod.c_str());
					}

 				| 	_int 
					_main 
					_pari 
					_pard 
					{
						$$.prefix = $0.prefix + "main_";
					}
					Bloque
					{
						$$.cod = "define i32 main()\n" + $6.cod;

						if( dbg_sem )
							fprintf(stderr, "{FVM-2} : \"%s\"\n", $$.cod.c_str());
					}
				;

	Tipo 		: 	_int
					{
						$$.cod = "i32";
						$$.type = INT;
						if( dbg_sem )
							fprintf(stderr, "{Tipo-1} : \"%s\"\n", $$.cod.c_str());
					}

 				| 	_float
					{
						$$.cod = "float";
						$$.type = FLOAT;
						if( dbg_sem )
							fprintf(stderr, "{Tipo-2} : \"%s\"\n", $$.cod.c_str());
					}
				;

	Bloque 		: 	_llavei
					{
						/*
						OPEN SCOPE
						*/
						tsym = SymbolTable(&tsym);
						$$.prefix = $0.prefix; // para BDecl
					}
					BDecl
					SeqInstr 
					_llaved
					{
						/*
						CLOSE SCOPE
						*/
						nextAddr = (unsigned)tsym.start_addr;
						tsym = *(tsym.parent);
	
						$$.cod = "{\n" + $3.cod + $5.cod + "\n}\n";
						if( dbg_sem )
							fprintf(stderr, "{Bloque} : \"%s\"\n", $$.cod.c_str());
					}
				;

	BDecl 		: 	BDecl
					{
						$$.addr = DVAR_LOCATION::in_function;
						$$.prefix = $0.prefix;
					}
					DVar
					{
						$$.cod = $1.cod + $3.cod;

						if( dbg_sem )
							fprintf(stderr, "{BDecl} : \"%s\"\n", $$.cod.c_str());
						
					}

		 		| 	%empty
					{
						$$.cod = "";
						if( dbg_sem )
							fprintf(stderr, "{BDecl-empty} : \"%s\"\n", $$.cod.c_str());
					}
				;

	DVar 		: 	Tipo
					{
						$$.addr = $0.addr; 	// DVAR_LOCATION
						$$.th = $1.th; 		// tipo int, float
						$$.cod = $1.cod; 	// "i32" "float"
						$$.prefix = $0.prefix;
					}
					LIdent 
					_pyc
					{
						$$.cod = $3.cod;
						if(dbg_sem)
							fprintf(stderr, "{DVar} : \"%s\"\n", $$.cod.c_str());
					}
				;

	LIdent 		: 	LIdent
					_coma
					{
						$$.addr = $0.addr; 	// DVAR_LOCATION
						$$.th = $0.th; 		// tipo int, float
						$$.cod = $-1.cod; 	// "i32" "float"
						$$.prefix = $0.prefix;
					}
					Variable
					{
						$$.cod = $1.cod + $4.cod;
						if(dbg_sem)
							fprintf(stderr, "{LIdent-1} : \"%s\"\n", $$.cod.c_str());
					}
	
	 			| 	Variable
					{
						$$.cod = $1.cod;
						if(dbg_sem)
							fprintf(stderr, "{LIdent-2} : \"%s\"\n", $$.cod.c_str());
					}
				;

	Variable 	: 	_id
					{
						$$.th = $0.th;		// tipo int, float
						$$.cod = $0.cod; 	// "i32" "float"
					}
					V
					{
						// save "[1 x [2 x ... i32]...]]" or "i32" of non array, for references
						ttypes.t.at($3.type).signature = $3.cod;

						if( $0.addr == DVAR_LOCATION::in_function )
						{
							Symbol s( 	$1.lex,
										"%" + $0.prefix + $1.lex,
										$3.type,
										nextAddr++,
										ttypes.t.at($3.type).size);

							$$.cod = s.trans + " = alloca " + $3.cod + "\n";

							if( !tsym.set(s) ) 
							{
								msgError(ERR::YADECL, &$1);
								exit(-1);
							}
						}

						else if( $0.addr == DVAR_LOCATION::out_function )
						{
							Symbol s( 	$1.lex,
										"@" + $0.prefix + $1.lex,
										$3.type,
										nextAddr++,
										ttypes.t.at($3.type).size);

							$$.cod = s.trans + " = private global " + $3.cod;
	
							if( ! ttypes.t.at($3.type).array ) 		
								$$.cod += " 0\n";
							
							else 	
								$$.cod += " zeroinitializer\n";

							if( !tsym.set(s) )
							{
								msgError(ERR::YADECL, &$1);
								exit(-1);
							}
						}
						else
						{
							fprintf(stderr, "Variable found an impossible DVAR_LOCATION value (%d). Please contact the police.\n", $0.addr);
							exit(-1);
						}


						if(dbg_sem)
							fprintf(stderr, "{Variable} : \"%s\"\n", $$.cod.c_str());
					}
				;

	V 			: 	%empty
					{
						$$.type = $0.th; // tipo int, float
						$$.cod = $0.cod; // "i32" "float"

						if(dbg_sem)
							fprintf(stderr, "{V-empty} : \"%s\"\n", $$.cod.c_str());
					}
				
				| 	_cori
					_nentero
					_cord
					{
						int dim = atoi(($2.lex).c_str());
						if( dim < 1 )
						{
							msgError(ERR::DIM, &$2);
							exit(-1);
						}

						$$.cod = $0.cod; // "i32" "float"

						// add self to type, then send down
						$$.th = ttypes.create(dim * (ttypes.t.at($0.th).size), $0.th);
					}
					V
					{
						// pass final type back up
						$$.type = $5.type;
						$$.cod = "[" + $2.lex + " x " + $5.cod + "]";

						ttypes.addSignature($4.th, $$.cod);

						if(dbg_sem)
							fprintf(stderr, "{V} : \"%s\"\n", $$.cod.c_str());
					}
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
					{
						if( ttypes.t.at($1.type).array ) 
						{
							msgError(ERR::TOOFEW, &yylval);
						}
					}
				
				| 	_nentero
					{
						$$.cod = $1.lex;

						if( dbg_sem )
							fprintf(stderr, "{F n-entero} : \"%s\"\n", $$.cod.c_str());
					}

				| 	_nreal
					{
						$$.cod = $1.lex;

						if( dbg_sem )
							fprintf(stderr, "{F n-real} : \"%s\"\n", $$.cod.c_str());
					}

				| 	_pari
					Expr
					_pard

				;

	Ref 		: 	_id
					{
						const Symbol* s = tsym.get($1.lex);
						
						if ( !s )
						{
							msgError(ERR::NODECL, &$1);
							exit(-1);
						}

						$$.type = s->type;

						/* Type signature that LLVM always needs before a register name
							i32
							[2 x i32]
							[3 x [2 x i32]]
						*/
						$$.prefix = ttypes.t.at(s->type).signature;

						/* Register name
							%1
							%myvar
							@abc
							
							We save it in .lex to leave .cod free 
						*/
						$$.lex = s->trans;

						if( dbg_sem )
							fprintf(stderr, "{Ref end} : \"%s\"\n", $$.lex.c_str());
					}

				| 	Ref
					_cori
					{
						if( !ttypes.t.at($1.type).array )
						{
							msgError(ERR::TOOMANY, &$2);
							exit(-1);
						}
					}
					Esimple
					_cord
					{
						$$.type = ttypes.t.at($1.type).subType;
							
						/*
						if( ttypes.t.at($$.type).array )
						{
							msgError(ERR::TOOFEW, &$5);
							exit(-1);
						}
						No, hay que comprobar esto despues de Ref as a whole, no aqui dentro, 
						porque esto se va a ejecutar varias veces. Siempre va a dar TOOFEW.
						*/

						// Register name
						$$.lex = $1.lex;

						// Esimple operations
						$$.cod = $4.prefix;
						
						// getelementptr... Esimple signature + full_name
						$$.cod += $1.cod + "\n";
						$$.cod += "getelementptr " + $1.prefix + ", " + $1.prefix + "* " + $$.lex + ", i64 0 i64 " + $4.cod + "\n";

						if( dbg_sem )
							fprintf(stderr, "{Ref rec} : \"%s\"\n", $$.cod.c_str());
					}
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

	if( argc == 3 )
	{
		// 0 is '-'
		for( int i=1; i<strlen(argv[2]); i++ )
		{
			if( argv[2][i] == 'l' ) 	dbg_lex = true;
			if( argv[2][i] == 'm' ) 	dbg_sem = true;
			if( argv[2][i] == 's' ) 	dbg_sym = true;
		}
	}

	if( argc == 2 || argc == 3 ) {

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
		fprintf(stderr, "Uso: ejemplo <nombre de fichero> --opts(lms)\n");
}

