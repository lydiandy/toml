module toml

pub struct Token {
	kind Kind
	val  string // only name,string,integer,float,datetime
	len  int
}

pub enum Kind {
	unknown // unknown token
	eof // end of file
	name // ident
	eq // =
	bool_true
	bool_false
	string // string
	number
	datetime // TODO
	dot // .
	comma // ,
	lsbr // [
	rsbr // ]
	double_lsbr // [[
	double_rsbr // ]]
	lcbr // {
	rcbr // }
	plus // +
	minus // -
	backslash // \
	inf // inf or +inf
	_inf // -inf
	nan // nan or +nan
	_nan // -nan
}
