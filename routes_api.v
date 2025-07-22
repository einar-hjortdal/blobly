module main

import veb
import os
import compress.gzip

@['/api/directories'; get]
fn (mut app App) api_directories_get(mut ctx Context) veb.Result {
	entries := os.ls(app.public_directory) or {
		// TODO rewrite errors
		ctx.res.set_status(.internal_server_error)
		return ctx.json('')
	}
	return ctx.json(entries)
}

@['/api/files/:directory'; get]
fn (mut app App) list_files_in_dir(mut ctx Context, directory string) veb.Result {
	directory_path := safely_join_path(app.public_directory, directory) or {
		ctx.res.set_status(.bad_request)
		return ctx.json('')
	}

	entries := os.ls(directory_path) or {
		ctx.res.set_status(.internal_server_error)
		return ctx.json('')
	}

	return ctx.json(entries)
}

@['/api/files/:directory/:file_name'; post]
fn (mut app App) create_file(mut ctx Context, file_name string) veb.Result {
	fn_name := 'handle_create_file'

	should_gzip := 'gzip' in ctx.query || ctx.query['gzip'] == 'true'

	file_path := safely_join_path(app.public_directory, file_name) or {
		return ctx.send_error(err, fn_name)
	}

	mut file := os.create(file_path) or { return ctx.send_error(err, fn_name) }
	file.write(ctx.req.data.bytes()) or {
		file.close()
		return ctx.send_error(err, fn_name)
	}
	file.close()

	if should_gzip && could_gzip(file_name) {
		gzip_file_path := '${file_path}/${gzip_extension}'
		gzip_file_data := gzip.compress(ctx.req.data.bytes()) or {
			os.rm(file_path) or { return ctx.send_error(err, fn_name) }
			return ctx.send_error(err, fn_name)
		}
		mut gzip_file := os.create(gzip_file_path) or { return ctx.send_error(err, fn_name) }
		gzip_file.write(gzip_file_data) or {
			gzip_file.close()
			os.rm(file_path) or { return ctx.send_error(err, fn_name) }
			return ctx.send_error(err, fn_name)
		}
		gzip_file.close()
	}

	return ctx.ok('OK')
}

@['/api/directory/:directory_name...'; post]
fn (mut app App) create_directory(mut ctx Context, directory_name string) veb.Result {
	fn_name := 'handle_create_directory'

	directory_path := safely_join_path(app.public_directory, directory_name) or {
		return ctx.send_error(err, fn_name)
	}

	os.mkdir(directory_path) or { return ctx.send_error(err, fn_name) }
	return ctx.ok('OK')
}
