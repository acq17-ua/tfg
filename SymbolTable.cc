#include "SymbolTable.h"

bool operator==(const Symbol& l, const Symbol& r)
{
	return 	(l.fullName == r.fullName); 
}

SymbolTable::SymbolTable(SymbolTable* pa)
{
	this->parent = pa;
}

bool SymbolTable::set(const Symbol s)
{
	
	SymbolTable* it = parent;

	if( this->scope_syms.count(s) )
		return false;

	while( it )
	{
		if( it->scope_syms.count(s) ) 		
			return false;
		it = it->parent;
	}
	this->scope_syms.insert(s);
	return true;
}

const Symbol* SymbolTable::get(const string q) 
{
	const Symbol s(q, basic::INT, 0, 0);

	SymbolTable* it = this;
	unordered_set<Symbol>::iterator found;

	found = this->scope_syms.find(s);
	if( found != this->scope_syms.end() )
		return &(*found);

	while( it )
	{
		found = it->scope_syms.find(s);

		if( found != it->scope_syms.end() )
			return &(*found);

		it = it->parent;
	}
	return nullptr;
}
