module main

import os
import veb

struct Context {
	veb.Context
}

pub struct App {
	public_directory string
	private_keys     []string
	secret_keys      []string
}

fn main() {
	load_settings()

	public_directory := os.getenv(env_public_directory)
	public_directory_abs_path := os.abs_path(public_directory)
	port := os.getenv(env_port).int()
	private_keys := os.getenv(env_private_keys).split(',')
	secret_keys := os.getenv(env_secret_keys).split(',')

	mut app := App{
		public_directory: public_directory_abs_path
		private_keys:     private_keys
		secret_keys:      secret_keys
	}

	create_public_directory(app.public_directory)
	veb.run[App, Context](mut app, port)
}
