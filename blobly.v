module main

import os
import veb

struct Context {
	veb.Context
}

@[heap]
pub struct App {
	veb.Middleware[Context]
	public_directory string
	keys             map[string]string
}

fn main() {
	load_settings()

	public_directory := os.getenv(env_public_directory)
	public_directory_abs_path := os.abs_path(public_directory)
	port := os.getenv(env_port).int()
	keys := get_keys()

	mut app := App{
		public_directory: public_directory_abs_path
		keys:             keys
	}

	app.use(handler: app.middleware_debug)
	app.route_use('/api/:path...', handler: app.middleware_auth)

	create_public_directory(app.public_directory)
	veb.run[App, Context](mut app, port)
}
