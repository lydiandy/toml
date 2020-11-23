module token

pub struct Position {
pub:
	pos     int
	line_nr int
	len     int
}

pub fn (pos Position) str() string {
	return 'Position{ line_nr: $pos.line_nr, pos: $pos.pos, len: $pos.len }'
}

pub fn (tok &Token) position() Position {
	return Position{
		pos: tok.pos
		line_nr: tok.line_nr - 1
		len: tok.len
	}
}
