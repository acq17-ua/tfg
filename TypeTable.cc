#include "TypeTable.h"

TypeTable::TypeTable()
{
	// int
	this->t.push_back( TType{false, 1, 0} );
	// float
	this->t.push_back( TType{false, 1, 1} );
}

unsigned TypeTable::create(const unsigned size, const unsigned subType)
{
	TType newtype{true, size, subType};
	this->t.push_back(newtype);
	return this->t.size()-1;
}

bool TypeTable::addSignature(const unsigned id, const string sign)
{
	if( id < this->t.size() )
		return false;

	this->t.at(id).signature = sign;
	return true;
}
