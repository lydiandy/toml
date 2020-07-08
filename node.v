module toml

import time

pub enum Type {
	root // root node
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
	typ         Type
	name        string
	val         Value
	pre         &Node
	next        &Node
	first_child &Node // array and object use,point to the first child Node
	parent      &Node
	comment     string
}

pub fn new_node(name string, typ Type, val Value) &Node {
	mut n := Node{
		name: name
		typ: typ
		val: val
		pre: 0
		next: 0
		child: 0
	}
	return &n
}

pub fn remove_node() {
}