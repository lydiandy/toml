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
	array_of_object
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

pub fn new_node(name string, typ Type, val Value, parent, pre, next, child &Node) &Node {
	n := &Node{
		name: name
		typ: typ
		val: val
		parent: parent
		pre: pre
		next: next
		child: child
	}
	return n
}
