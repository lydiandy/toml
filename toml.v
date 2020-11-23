module toml

import time
import os

pub interface Serializable {
	from_toml(node Any)
	to_toml() string
}

// Any is the type of node
pub type Any = Null | []Any | bool | f32 | f64 | i64 | int | map[string]Any | string |
	time.Time

// decode
// decode from toml fie,and transfer to map[string]Any
pub fn decode_file_to_map(file string) ?Any {
}

// decode from toml file,generic function
pub fn decode_file<T>(file string) ?T {
}

// decode from string,generic function
pub fn decode<T>(src string) ?T {
	mut typ := T{}
	typ.from_toml()
	return typ
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

// decode toml string to target varible,common funtion
pub fn decode(text string, target voidptr) ? {
	mut d := Decoder{
		scanner: &Scanner{}
		text: text
		lines: []string{}
	}
	// start to decode
	d.decode()
	// scan to target variable
	d.scan_to(target)
}

// decode to map[string]Any
pub fn decode_to_map<T>(src string) ?Any {
}

// encode
// encode to toml from struct,generic function
pub fn encode<T>(typ T) ?string {
	return typ.to_toml()
}

// encode to toml from struct,,common funtion
pub fn encode(obj voidptr) ?string {
}

// null struct
pub struct Null {
}

// create null
pub fn null() Null {
	return Null{}
}
