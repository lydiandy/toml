module toml

// for scan each line and generate tokens
pub struct Scanner {
pub mut:
	text             string
	pos              int
	is_inside_string bool
	is_started       bool
}

// scan once generate one token
pub fn (mut s Scanner) scan() Token {
	if s.is_started {
		s.pos++
	}
	s.is_started = true
	if s.pos >= s.text.len {
		return s.end_of_line()
	}
	if !s.is_inside_string {
		s.skip_whitespace()
		s.skip_line_comment()
	}
	if s.pos >= s.text.len {
		return s.end_of_line()
	}
	c := s.text[s.pos]
	nextc := s.look_ahead(1)
	match c {
		`=` {
			return s.new_token(.eq, '', 1)
		}
		`[` {
			if nextc == `[` {
				return s.new_token(.double_lsbr, '', 2)
			} else {
				return s.new_token(.lsbr, '', 1)
			}
		}
		`]` {
			if nextc == `]` {
				return s.new_token(.double_rsbr, '', 2)
			} else {
				return s.new_token(.rsbr, '', 1)
			}
		}
		`,` {
			return s.new_token(.comma, '', 1)
		}
		else {
			println('known token')
		}
	}
}

// skip white space
fn (mut s Scanner) skip_whitespace() {
	for s.pos < s.text.len && s.text[s.pos].is_space() {
		s.pos++
	}
}

// skip at the end of the line comment
fn (mut s Scanner) skip_line_comment() {
	if s.text[s.pos] == `#` {
		for s.pos < s.text.len {
			s.pos++
		}
	}
}

[inline]
fn (s Scanner) look_ahead(n int) byte {
	if s.pos + n < s.text.len {
		return s.text[s.pos + n]
	} else {
		return `\0`
	}
}

// reach end of line return .eol
fn (mut s Scanner) end_of_line() Token {
	s.pos = s.text.len
	return s.new_token(.eol, '', 0)
}

pub fn (mut s Scanner) new_token(tok_kind Kind, val string, len int) Token {
	if len > 0 {
		s.pos = s.pos + len - 1
	}
	return Token{
		kind: tok_kind
		val: val
		len: len
	}
}
