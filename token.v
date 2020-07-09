module toml

pub struct Token {
	kind    Kind
	val     string  //only string,integer,float,datetime have val
}

pub enum Kind {
	eol 				//end of line
	name 				//ident
	eq					//=
	bool_true				
	bool_false
	string				//string
	integer		
	float
	datetime
	dot 				// .
	comma				// ,
	lsbr 				// [
	rsbr 				// ]
	double_lsbr 		// [[
	double_rsbl 		// ]]
	lcbr				// {
	rcbr 				// }
	plus   				// +
	minus				// -
	underline			// _
	three_single_quote 	// '''
	three_double_quote 	// """
	backslash			// \
	e 					// e or E
	num_0x 				// 0x
	num_0o				// 0o
	num_0b				// 0b
	inf         		// inf or +inf
	-inf				// -inf
	nan					// nan or +nan
	-nan				// -nan
}
