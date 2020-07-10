module toml

const (
	single_quote = `\'`
	double_quote = `"`
	three_single_quote ='\'\'\''
	three_double_quote ='"""'
	num_sep      = `_`
)

// for scan each line and generate tokens
pub struct Scanner {
pub mut:
	text       string
	pos        int
	is_inside_string bool
	is_started bool
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
	// ident name
	if is_name_char(c) {
		name := s.ident_name()
		match name {
			'true' { return s.new_token(.bool_true, true, 4) }
			'false' { return s.new_token(.bool_false, false, 5) }
			else { return s.new_token(.name, name, name.len) }
		}
	}
	// ident string
	if c == single_quote {
		//there single quote
		if nextc==single_quote && nextc2==single_quote {
			ident_string := s.ident_string(three_single_quote)
			return s.new_token(.string, ident_string, ident_string.len + 6)
		} else {
		ident_string := s.ident_string(single_quote.str())
		return s.new_token(.string, ident_string, ident_string.len + 2)
		}

	}
	if c == double_quote {
		//three double quote
		if nextc==double_quote && nextc2==double_quote {
			ident_string := s.ident_string(three_double_quote)
			return s.new_token(.string, ident_string, ident_string.len + 6)
		} else {
			ident_string := s.ident_string(double_quote.str())
			return s.new_token(.string, ident_string, ident_string.len + 2)
		}


	}
	// ident number
	if c.is_digit() || (c == `.` && nextc.is_digit()) {
		num := s.ident_number()
		return s.new_token(.number, num, num.len)
	}
	// other char
	match c {
		// single_quote {
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
		else {
			println('unknown token')
		}
	}
	return s.new_token(.eol,'',1)
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

// ident string
fn (mut s Scanner) ident_string(quote string) string {
	s.pos+=quote.len
	start := s.pos
	for s.pos < s.text.len && s.text[s.pos..s.pos+quote.len] != quote {
		s.pos++
	}
	ident_string := s.text[start..s.pos]
	s.pos--
	return ident_string
}

// ident number
fn filter_num_sep(txt byteptr, start, end int) string {
	unsafe {
		mut b := malloc(end - start + 1) // add a byte for the endstring 0
		mut i1 := 0
		for i := start; i < end; i++ {
			if txt[i] != num_sep {
				b[i1] = txt[i]
				i1++
			}
		}
		b[i1] = 0 // C string compatibility
		return string(b)
	}
}

fn (mut s Scanner) ident_bin_number() string {
	mut has_wrong_digit := false
	mut first_wrong_digit_pos := 0
	mut first_wrong_digit := `\0`
	start_pos := s.pos
	s.pos += 2 // skip '0b'
	for s.pos < s.text.len {
		c := s.text[s.pos]
		if !c.is_bin_digit() && c != num_sep {
			if (!c.is_digit() && !c.is_letter()) || s.is_inside_string {
				break
			} else if !has_wrong_digit {
				has_wrong_digit = true
				first_wrong_digit_pos = s.pos
				first_wrong_digit = c
			}
		}
		s.pos++
	}
	if start_pos + 2 == s.pos {
		s.pos-- // adjust error position
		error('number part of this binary is not provided')
	} else if has_wrong_digit {
		s.pos = first_wrong_digit_pos // adjust error position
		error('this binary number has unsuitable digit `$first_wrong_digit.str()`')
	}
	number := filter_num_sep(s.text.str, start_pos, s.pos)
	s.pos--
	return number
}

fn (mut s Scanner) ident_hex_number() string {
	mut has_wrong_digit := false
	mut first_wrong_digit_pos := 0
	mut first_wrong_digit := `\0`
	start_pos := s.pos
	s.pos += 2 // skip '0x'
	for s.pos < s.text.len {
		c := s.text[s.pos]
		if !c.is_hex_digit() && c != num_sep {
			if !c.is_letter() || s.is_inside_string {
				break
			} else if !has_wrong_digit {
				has_wrong_digit = true
				first_wrong_digit_pos = s.pos
				first_wrong_digit = c
			}
		}
		s.pos++
	}
	if start_pos + 2 == s.pos {
		s.pos-- // adjust error position
		error('number part of this hexadecimal is not provided')
	} else if has_wrong_digit {
		s.pos = first_wrong_digit_pos // adjust error position
		error('this hexadecimal number has unsuitable digit `$first_wrong_digit.str()`')
	}
	number := filter_num_sep(s.text.str, start_pos, s.pos)
	s.pos--
	return number
}

fn (mut s Scanner) ident_oct_number() string {
	mut has_wrong_digit := false
	mut first_wrong_digit_pos := 0
	mut first_wrong_digit := `\0`
	start_pos := s.pos
	s.pos += 2 // skip '0o'
	for s.pos < s.text.len {
		c := s.text[s.pos]
		if !c.is_oct_digit() && c != num_sep {
			if (!c.is_digit() && !c.is_letter()) || s.is_inside_string {
				break
			} else if !has_wrong_digit {
				has_wrong_digit = true
				first_wrong_digit_pos = s.pos
				first_wrong_digit = c
			}
		}
		s.pos++
	}
	if start_pos + 2 == s.pos {
		s.pos-- // adjust error position
		error('number part of this octal is not provided')
	} else if has_wrong_digit {
		s.pos = first_wrong_digit_pos // adjust error position
		error('this octal number has unsuitable digit `$first_wrong_digit.str()`')
	}
	number := filter_num_sep(s.text.str, start_pos, s.pos)
	s.pos--
	return number
}

fn (mut s Scanner) ident_dec_number() string {
	mut has_wrong_digit := false
	mut first_wrong_digit_pos := 0
	mut first_wrong_digit := `\0`
	start_pos := s.pos
	// scan integer part
	for s.pos < s.text.len {
		c := s.text[s.pos]
		if !c.is_digit() && c != num_sep {
			if !c.is_letter() || c in [`e`, `E`] || s.is_inside_string {
				break
			} else if !has_wrong_digit {
				has_wrong_digit = true
				first_wrong_digit_pos = s.pos
				first_wrong_digit = c
			}
		}
		s.pos++
	}
	mut call_method := false // true for, e.g., 5.str(), 5.5.str(), 5e5.str()
	mut is_range := false // true for, e.g., 5..10
	mut is_float_without_fraction := false // true for, e.g. 5.
	// scan fractional part
	if s.pos < s.text.len && s.text[s.pos] == `.` {
		s.pos++
		if s.pos < s.text.len {
			// 5.5, 5.5.str()
			if s.text[s.pos].is_digit() {
				for s.pos < s.text.len {
					c := s.text[s.pos]
					if !c.is_digit() {
						if !c.is_letter() || c in [`e`, `E`] || s.is_inside_string {
							// 5.5.str()
							if c == `.` && s.pos + 1 < s.text.len && s.text[s.pos + 1].is_letter() {
								call_method = true
							}
							break
						} else if !has_wrong_digit {
							has_wrong_digit = true
							first_wrong_digit_pos = s.pos
							first_wrong_digit = c
						}
					}
					s.pos++
				}
			} else if s.text[s.pos] == `.` {
				// 5.. (a range)
				is_range = true
				s.pos--
			} else if s.text[s.pos] in [`e`, `E`] {
				// 5.e5
			} else if s.text[s.pos].is_letter() {
				// 5.str()
				call_method = true
				s.pos--
			} else if s.text[s.pos] != `)` {
				// 5.
				is_float_without_fraction = true
				s.pos--
			}
		}
	}
	// scan exponential part
	mut has_exp := false
	if s.pos < s.text.len && s.text[s.pos] in [`e`, `E`] {
		has_exp = true
		s.pos++
		if s.pos < s.text.len && s.text[s.pos] in [`-`, `+`] {
			s.pos++
		}
		for s.pos < s.text.len {
			c := s.text[s.pos]
			if !c.is_digit() {
				if !c.is_letter() || s.is_inside_string {
					// 5e5.str()
					if c == `.` && s.pos + 1 < s.text.len && s.text[s.pos + 1].is_letter() {
						call_method = true
					}
					break
				} else if !has_wrong_digit {
					has_wrong_digit = true
					first_wrong_digit_pos = s.pos
					first_wrong_digit = c
				}
			}
			s.pos++
		}
	}
	if has_wrong_digit {
		// error check: wrong digit
		s.pos = first_wrong_digit_pos // adjust error position
		error('this number has unsuitable digit `$first_wrong_digit.str()`')
	} else if s.text[s.pos - 1] in [`e`, `E`] {
		// error check: 5e
		s.pos-- // adjust error position
		error('exponent has no digits')
	} else if s.pos < s.text.len &&
		s.text[s.pos] == `.` && !is_range && !is_float_without_fraction && !call_method {
		// error check: 1.23.4, 123.e+3.4
		if has_exp {
			error('exponential part should be integer')
		} else {
			error('too many decimal points in number')
		}
	}
	number := filter_num_sep(s.text.str, start_pos, s.pos)
	s.pos--
	return number
}

fn (mut s Scanner) ident_number() string {
	if s.expect('0b', s.pos) {
		return s.ident_bin_number()
	} else if s.expect('0x', s.pos) {
		return s.ident_hex_number()
	} else if s.expect('0o', s.pos) {
		return s.ident_oct_number()
	} else {
		return s.ident_dec_number()
	}
}

//
fn (s Scanner) expect(want string, start_pos int) bool {
	end_pos := start_pos + want.len
	if start_pos < 0 || start_pos >= s.text.len {
		return false
	}
	if end_pos < 0 || end_pos > s.text.len {
		return false
	}
	for pos in start_pos .. end_pos {
		if s.text[pos] != want[pos - start_pos] {
			return false
		}
	}
	return true
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
