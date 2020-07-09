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
	nextc2 := s.look_ahead(2)
	if is_name_char(c) {
		name := s.ident_name()
		match name {
			'true' {
				return s.new_token(.bool_true, true, 4)
			}
			'false' {
				return s.new_token(.bool_false, false, 5)
			}
			else {
				return s.new_token(.name, name, name.len)
			}
		}
	}
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
		`.` {
			return s.new_token(.dot, '', 1)
		}
		`"` {
			if nextc == `"` && nextc2 == `"` {
				return s.new_token(.three_double_quote, '', 3)
			}
		}
		else {
			println('unknown token')
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
		println('comment is: ${s.text[s.pos..s.text.len]}')
		for s.pos < s.text.len {
			s.pos++
		}
	}
}

// ident name
fn (mut s Scanner) ident_name() string {
	start := s.pos
	s.pos++
	for s.pos < s.text.len && (is_name_char(s.text[s.pos]) || s.text[s.pos].is_digit()) {
		s.pos++
	}
	name := s.text[start..s.pos]
	s.pos--
	return name
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

pub fn (mut s Scanner) new_token(tok_kind Kind, val Value, len int) Token {
	println('$tok_kind:$val')
	return Token{
		kind: tok_kind
		val: val
		len: len
	}
}
