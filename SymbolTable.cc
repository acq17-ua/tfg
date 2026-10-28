#include "SymbolTable.h"

bool operator==(const Symbol& l, const Symbol& r)
{
	return 	(l.name == r.name); 
}

SymbolTable& SymbolTable::operator=(const SymbolTable& s) 
{
	if( this != &s ) {
		
		this->scope_syms = s.scope_syms;
		this->parent = s.parent;
		this->start_addr = s.start_addr;
	}
	return *this;
}

SymbolTable::SymbolTable(SymbolTable* pa)
{
	this->parent = pa;
}

bool SymbolTable::set(const Symbol s)
{
	if( this->scope_syms.count(s) )
		return false;

	this->scope_syms.insert(s);
	return true;
}

const Symbol* SymbolTable::get(const string q) 
{
	const Symbol s(q, "", 0, 0, 0);

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
