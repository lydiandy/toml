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

// implement interface
pub fn (mut c Config) from_toml(root toml.Any) {
	config_map := root.as_map()
	c.env = config_map['env'].str()
	c.port = config_map['port'].str()
	// db
	db_map := config_map['db']
	c.db.client = db_map['client'].str()
	c.db.host = db_map['host'].str()
	c.db.port = db_map['port'].int()
	c.db.name = db_map['name'].str()
	c.db.user = db_map['user'].str()
	c.db.password = db_map['password'].str()
	// redis
	redis_map := config_map['redis']
	c.redis.host = redis_map['host'].str()
	c.redis.port = redis_map['port'].str()
	c.redis.password = redis_map['password'].str()
	// jwt
	jwt_map := config_map['jwt']
	c.jwt.jwt_key = jwt_map['jwt_key'].str()
	c.jwt.jwt_cookie = jwt_map['jwt_cookie'].str()
}

fn main() {
	// file_path := './simple.toml'
	// file_path := './toml_example.toml'
	file := 'dev_config.toml'
	mut config := Config{}
	toml.decode_file(file_path, &config) or {
		panic('read config file failed:$err ')
	}
	// println(config)
}
