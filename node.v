module toml

import time

pub enum Type {
	boolean
	integer
	float
	string_
	datetime
	array
	object
}

pub type Value = bool | f64 | int | string | time.Time

// use chain to save the parse result
pub struct Node {
pub mut:
	typ    Type
	name   string
	val    Value
	parent &Node
	pre    &Node
	next   &Node
	child  &Node // just array and object use,point to the first child Node
}

pub fn new_node(name string, typ Type, val Value) &Node {
	mut n := Node{
		name: name
		typ: typ
		val: val
		parent: 0
		pre: 0
		next: 0
		child: 0
	}
	return &n
}

pub fn remove_node() {
}
