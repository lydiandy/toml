module toml

pub type Any = Null | []Any | bool | f32 | f64 | i64 | int | map[string]Any | string

// decode from toml file
pub fn decode_file<T>(file string) ?T {
}

// decode from string
pub fn decode<T>(src string) ?T {
	mut typ := T{}
	typ.from_toml()
	return typ
}

// decode to map[string]Any
pub fn decode_to_map<T>(src string) ?Any {
}

// encode to toml from struct
pub fn encode<T>(typ T) ?string {
	return typ.to_toml()
}

// null struct
pub struct Null {
}

// create null
pub fn null() Null {
	return Null{}
}
