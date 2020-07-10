module toml

pub struct Token {
	kind    Kind
	val     Value  //only string,integer,float,datetime have val
	len 	int
}

pub enum Kind {
	eol 				//end of line
	name 				//ident
	eq					//=
	bool_true				
	bool_false
	string				//string
	number
	// integer		
	// float
	datetime
	dot 				// .
	comma				// ,
	lsbr 				// [
	rsbr 				// ]
	double_lsbr 		// [[
	double_rsbr 		// ]]
	lcbr				// {
	rcbr 				// }
	plus   				// +
	minus				// -
	// underline			// _
	// three_single_quote 	// '''
	// three_double_quote 	// """
	backslash			// \
	inf         		// inf or +inf
	_inf				// -inf
	nan					// nan or +nan
	_nan				// -nan
}
