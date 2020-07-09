module toml

// for scan each line and generate tokens
pub struct Scanner {
pub mut:
	text string
	pos  int
}

// scan once generate one token
pub fn (mut s Scanner) scan() Token {
		// mut pos := 0 // current pos
		// for pos
		// mut c, nextc := line[pos], line[pos + 1]
		// match c {
		// '[' {
		// // if nextc == '[' {
		// // } else {
		// // }
		// }
		// double_quote {}
		// '=' {}
		// '#' {}
		// '.' {}
		// else {
		// println('unknown c')
		// }
		// }
}

pub fn (s Scanner) new_token(tok_king Kind, val string) Token {
	return Token{
		kind: tok_kind
		val: val
	}
}

