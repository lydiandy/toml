module toml

import os

pub struct Decoder {
pub:
	text          string // toml text
pub mut:
	lines         []string // split toml text to lines
	root          Node // the root of Node
	// temp field
	parent        &Node
	pre           &Node
	current_group string
}

// decode toml file to target varible
pub fn decode_file(path string, target voidptr) ? {
	abs_path := get_abs_path(path)
	if !os.exists(abs_path) {
		return error('$path is not exists')
	}
	text := os.read_file(abs_path) or {
		return error('read file $abs_path failed')
	}
	return decode(text, target)
}

// decode toml string to target varible
pub fn decode(text string, target voidptr) ? {
	mut d := Decoder{
		text: text
		lines: []string{}
		root: Node{
			typ: Type.root
			name: 'root'
			parent: 0
			pre: 0
			next: 0
			first_child: 0
		}
		parent: 0
		pre: 0
	}
	d.decode()
	d.scan_to(target)
}

// decode the text to Node chain
fn (mut d Decoder) decode() {
	d.lines = d.text.split('\n')
	d.remove_empty_and_comment_line()
	println(d.lines)
}

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

// scan the Node chain to target varible
fn (mut d Decoder) scan_to(target voidptr) {
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
