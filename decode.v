module toml

import os

pub struct Decoder {
pub mut:
	text          string
	lines         []string
	root          Node // the root of node
	// the following are temp field
	parent        &Node
	pre           &Node
	current_group string
}

pub fn decode_file(path string, target voidptr) ? {
	a_path := get_abs_path(path)
	if !os.exists(a_path) {
		return error('$path is not exists')
	}
	text := os.read_file(a_path) or {
		return error('read file $a_path failed')
	}
	return decode(text, target)
}

// the same with json.decode
pub fn decode(text string, target voidptr) ? {
	mut d := Decoder{
		text: text
		lines: []string{}
		root: Node{
			typ: Type.root
			name: 'root'
			pre: 0
			next: 0
			child: 0
		}
	}
	d.decode()
	d.scan_to(target)
}
//decode the text to Node chain
fn (d Decoder) decode() {
}

// scan the Node chain to target varible
fn (d Decode) scan_to(target voidptr) {
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
