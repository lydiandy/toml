module main

import toml

struct Config {
	env   string
	port  string
	db    Db
	redis Redis
	jwt   Jwt
}

struct Db {
	client   string
	host     string
	port     int
	name     string
	user     string
	password string
}

struct Redis {
	host     string
	port     int
	password string
}

struct Jwt {
	jwt_key    string
	jwt_cookie string
}

fn main() {
	// file := 'simple.toml'
	// file := 'toml_example.toml'
	file := 'dev_config.toml'
	mut config := Config{}
	toml.decode_file(file, &config) or {
		panic('read config file failed:$err ')
	}
	// println(config)
}