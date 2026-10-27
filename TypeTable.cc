#include "TypeTable.h"

TypeTable::TypeTable()
{
	// int
	this->types.push_back( TType(false, 1, 0) );
	// float
	this->types.push_back( TType(false, 1, 1) );
}
