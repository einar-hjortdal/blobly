module main

import veb
import os
import strconv
import einar_hjortdal.dotenv

struct Context {
	veb.Context
}

pub struct App {
	mode             string
	public_directory string
}

fn create_app_instance() !&App {
	mode := string_default_if_empty(os.getenv('MODE'), 'development')
	public_directory := string_default_if_empty(os.getenv('PUBLIC_DIRECTORY'), 'public')
	public_directory_abs_path := os.abs_path(public_directory)

	if mode != 'development' && mode != 'production' {
		return error(format_error_message('Options.mode must be either `development` or `production`'))
	}

	return &App{
		mode:             mode
		public_directory: public_directory_abs_path
	}
}

fn create_public_directory(dir_path string) {
	if _ := os.stat(dir_path) {
		if os.is_file(dir_path) {
			panic('Cannot create public directory: ${dir_path} is a file')
		}
		if os.is_dir(dir_path) {
			println('Files are served from the directory ${dir_path}')
		}
	} else {
		os.mkdir(dir_path) or { panic(err) }
		println('Public directory ${dir_path} created successfully')
	}
}

fn main() {
	dotenv.load()
	mut app := create_app_instance() or { panic(err) }
	create_public_directory(app.public_directory)
	env_run_at_port := strconv.atoi(os.getenv('PORT')) or { 8080 }
	veb.run[App, Context](mut app, env_run_at_port)
}
