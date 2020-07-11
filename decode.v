module toml

import os

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
	is_new_group   bool
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

// because of some statement can write mulit line,for example array,multi line string
// make multi line to one line,make sure one line generate one Node
fn (mut d Decoder) merge_multi_line() {
	mut new_lines := []string{}
	for i := 0; i < d.lines.len; i++ {
		line := d.lines[i]
		// multi line array [ is the last char
		if line.ends_with('[') {
			mut merge_line := ''
			for j := i; j < d.lines.len; j++ {
				merge_line += d.lines[j]
				if d.lines[j].starts_with(']') {
					i = j
					break
				}
			}
			new_lines << merge_line
			// multi line string ''' is the last char
		} else if line.ends_with("\'\'\'") {
			mut merge_line := ''
			for j := i; j < d.lines.len; j++ {
				merge_line += d.lines[j]
				if d.lines[j].starts_with("\'\'\'") {
					i = j
					break
				}
			}
			new_lines << merge_line
			// multi line string """ is the last char
		} else if line.ends_with('"""') {
			mut merge_line := ''
			for j := i; j < d.lines.len; j++ {
				merge_line += d.lines[j]
				if d.lines[j].starts_with('"""') {
					i = j
					break
				}
			}
			new_lines << merge_line
		} else {
			new_lines << line
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
			println('-----------')
			break
		}
		match d.token.kind {
			.name {
				if d.next_token.kind == .eq {
					match d.next_token2.kind {
						.string { d.string_node() }
						.bool_true { d.bool_node(true) }
						.bool_false { d.bool_node(false) }
						.datetime { d.datetime_node() }
						.lsbr { d.array_node() }
						else { d.next() }
					}
				}
			}
			.lsbr {
				d.object_node()
			}
			.double_lsbr {
				d.array_of_object_node()
			}
			.unknown {
				println('unknown node')
				d.next()
			}
			else {
				// d.next()
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
	d.next_token = d.next_token2
	d.next_token2 = d.scanner.scan()
}

// identify bool node
fn (mut d Decoder) bool_node(b bool) {
	node := Node{
		typ: .boolean
		name: 'bool_$b'
		val: b
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

// identify number node
fn (mut d Decoder) number_node() {
	d.next()
}

// identify string node
fn (mut d Decoder) string_node() {
	d.next()
}

// identify datetime node
fn (mut d Decoder) datetime_node() {
	d.next()
}

// identify array node
fn (mut d Decoder) array_node() {
	d.next()
}

// identify object node
fn (mut d Decoder) object_node() {
	mut name := ''
	d.next()
	for d.token.kind != .rsbr {
		mut after_name:=d.token.val as string
		println(after_name)
		// name=name+after_name
		d.next()
	}
	println(name)
	node := Node{
		typ: .object
		name: name
		val: ''
		parent: d.current_parent
		pre: d.current_pre
		next: 0
		child: 0
	}
	d.nodes << node
	d.current_parent = &node
	d.current_pre = &node
	d.next()
}

// identify array_of_object node
fn (mut d Decoder) array_of_object_node() {
	d.next()
}

// scan the Node chain to target varible
fn (mut d Decoder) scan_to(target voidptr) {
	d.next()
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
