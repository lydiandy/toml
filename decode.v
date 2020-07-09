module toml

import os

pub struct Decoder {
pub:
	text           string // toml text
pub mut:
	lines          []string // split toml text to lines
	root           &Node // the root of Node
	// temp field
	current_parent &Node
	pre            &Node
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
		root: &Node{
			typ: Type.object
			name: 'root'
			parent: 0
			pre: 0
			next: 0
			child: 0
		}
		current_parent:0
		pre: 0
	}
	d.current_parent=d.root
	d.decode()
	d.scan_to(target)
}

// decode the text to Node chain
fn (mut d Decoder) decode() {
	d.lines = d.text.split('\n')
	d.remove_empty_and_comment_line()
	d.merge_multi_line()
	d.parse_line()
	println(d.lines)
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

// parse each line,one line generate one Node and under root Node
fn (mut d Decoder) parse_line() {
	for line in d.lines {
	}
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
