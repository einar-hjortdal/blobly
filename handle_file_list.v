module main

import veb
import os

// handle_list_files returns a list of files available to be served.
// Requires authorization. (TODO)
fn handle_list_files(mut app App, mut ctx Context, directory string) veb.Result {
	fn_name := 'handle_list_files'

	directory_path := safely_join_path(app.public_directory, directory) or {
		return ctx.send_error(err, fn_name)
	}

	entries := os.ls(directory_path) or { return ctx.send_error(err, fn_name) }
	return ctx.json(entries)
}
