module toml

import os

const (
	single_quote = `\'`
	double_quote = `"`
	num_sep      = `_`
)

pub struct Decoder {
pub:
	text           string // toml text
pub mut:
	lines          []string // split toml text to lines
	nodes          []Node // all nodes are stored here,the first one is root node
	scanner        &Scanner // when scanner new line the scanner will be new one
	// temp field
	token          Token
	next_token     Token
	next_token2    Token
	//
	current_parent &Node
	current_pre    &Node
}

// decode toml file to target varible
pub fn decode_file(file string, target voidptr) ? {
	abs_path := get_abs_path(file)
	if !os.exists(abs_path) {
		return error('$file is not exists')
	}
	text := os.read_file(abs_path) or {
		return error('read file $abs_path failed')
	}
	return decode(text, target)
}

// decode toml string to target varible
pub fn decode(text string, target voidptr) ? {
	mut d := Decoder{
		scanner: &Scanner{}
		text: text
		lines: []string{}
		nodes: []Node{}
		current_parent: 0
		current_pre: 0
	}
	root := Node{
		typ: Type.object
		name: 'root'
		parent: 0
		pre: 0
		next: 0
		child: 0
	}
	d.nodes << root
	d.current_parent = &root
	// start to decode
	d.decode()
	// scan to target variable
	d.scan_to(target)
}

// decode the text to Node chain
fn (mut d Decoder) decode() {
	d.lines = d.text.split('\n')
	d.remove_empty_and_comment_line()
	d.merge_multi_line()
	d.parse_lines()
}

// remove empty line and comment line
fn (mut d Decoder) remove_empty_and_comment_line() {
	mut new_lines := []string{}
	for line in d.lines {
		trim_line := line.trim_space()
		if trim_line == '' || trim_line.starts_with('#') {
			continue
		} else {
			new_lines << trim_line
		}
	}
	d.lines = new_lines
}

// because of some statement can write mulit line,for example array,
// make multi line to one line,make sure one line generate one Node
fn (mut d Decoder) merge_multi_line() {
	mut new_lines := []string{}
	for i := 0; i < d.lines.len; i++ {
		if d.lines[i].ends_with('[') {
			mut merge_line := ''
			for j := i; j < d.lines.len; j++ {
				merge_line += d.lines[j]
				if d.lines[j].starts_with(']') {
					i = j
					break
				}
			}
			new_lines << merge_line
		} else {
			new_lines << d.lines[i]
		}
	}
	d.lines = new_lines
}

fn (mut d Decoder) parse_lines() {
	for i := 0; i < d.lines.len; i++ {
		line := d.lines[i]
		d.parse_line(line)
	}
}

// parse each line,one line generate one Node and under root Node
fn (mut d Decoder) parse_line(line string) {
	d.reset_temp_varible()
	d.scanner = &Scanner{
		text: line
		pos: 0
	}
	d.read_first_token()
	for {
		if d.token.kind == .eol {
			println('end of line')
			break
		}
		match d.token.kind {
			.name {
				if d.next_token.kind == .eq {
					match d.next_token2.kind {
						.string { d.ident_string() }
						.bool_true { d.ident_bool_true() }
						.bool_false { d.ident_bool_false() }
						.integer { d.ident_integer() }
						.float { d.ident_float() }
						.datetime { d.ident_datetime() }
						.lsbr { d.ident_array() }
						.three_single_quote { d.ident_three_single_quote() }
						.three_double_quote { d.ident_three_double_quote() }
						else { println('known node') }
					}
				}
			}
			.lsbr {
				d.ident_group()
			}
			.double_lsbr {
				d.ident_array_of_object()
			}
			else {
				println('known node')
			}
		}
	}
}

fn (mut d Decoder) reset_temp_varible() {
	d.token = Token{}
	d.next_token = Token{}
	d.next_token2 = Token{}
}

// the first time,init the token,next_token,next_token2
fn (mut d Decoder) read_first_token() {
	d.next()
	d.next()
	d.next()
}

// next token
fn (mut d Decoder) next() {
	d.token = d.next_token
	d.next_token = d.next_token
	d.next_token2 = d.scanner.scan()
}

// identify string
fn (mut d Decoder) ident_string() {
}

// identify bool true
fn (mut d Decoder) ident_bool_true() {
	node := Node{
		typ: .boolean
		name: 'bool_true'
		val: true
		parent: d.current_parent
		pre: d.current_pre
		next: 0
		child: 0
	}
	d.nodes << node
	d.current_pre.next = &node
	d.current_pre = &node
	d.next()
}

// identify bool false
fn (mut d Decoder) ident_bool_false() {
	node := Node{
		typ: .boolean
		name: 'bool_false'
		val: false
		parent: &d.current_parent
		pre: d.current_pre
		next: 0
		child: 0
	}
	d.nodes << node
	d.current_pre.next = &node
	d.current_pre = &node
	d.next()
}

// identify integer
fn (mut d Decoder) ident_integer() {
}

// identify float
fn (mut d Decoder) ident_float() {
}

// identify datetime
fn (mut d Decoder) ident_datetime() {
}

// identify array
fn (mut d Decoder) ident_array() {
}

// identify three_single_quote
fn (mut d Decoder) ident_three_single_quote() {
}

// identify three_double_quote
fn (mut d Decoder) ident_three_double_quote() {
}

// identify group
fn (mut d Decoder) ident_group() {
}

// identify array_of_object
fn (mut d Decoder) ident_array_of_object() {
}

// reach end of line
fn (mut d Decoder) end_of_line() {
}

// scan the Node chain to target varible
fn (mut d Decoder) scan_to(target voidptr) {
}

//
[inline]
pub fn is_name_char(c byte) bool {
	return (c >= `a` && c <= `z`) || (c >= `A` && c <= `Z`) || c == `_`
}

// get absolute path for file
fn get_abs_path(path string) string {
	if os.is_abs_path(path) {
		return path
	} else if path.starts_with('./') {
		return os.join_path(os.getwd(), path[2..])
	} else {
		return os.join_path(os.getwd(), path)
	}
}
