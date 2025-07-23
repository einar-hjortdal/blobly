module main

import compress.gzip
import net.http
import os
import veb

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
		return handle_error(mut ctx, http.Status.bad_request, 'Bad path', err.msg())
	}

	entries := os.ls(directory_path) or {
		return handle_error(mut ctx, http.Status.internal_server_error, 'Could not list directory contents',
			err.msg())
	}

	return ctx.json(entries)
}

@['/api/files/:directory/:file_name'; post]
fn (mut app App) create_file(mut ctx Context, file_name string) veb.Result {
	should_gzip := 'gzip' in ctx.query || ctx.query['gzip'] == 'true'

	file_path := safely_join_path(app.public_directory, file_name) or {
		return handle_error(mut ctx, http.Status.bad_request, 'Bad path name', err.msg())
	}

	mut file := os.create(file_path) or {
		return handle_error(mut ctx, http.Status.internal_server_error, 'Could not create file',
			err.msg())
	}
	file.write(ctx.req.data.bytes()) or {
		file.close()
		return handle_error(mut ctx, http.Status.internal_server_error, 'Could not write file contents',
			err.msg())
	}
	file.close()

	if should_gzip && could_gzip(file_name) {
		gzip_file_path := '${file_path}/${gzip_extension}'
		gzip_file_data := gzip.compress(ctx.req.data.bytes()) or {
			os.rm(file_path) or {}
			return handle_error(mut ctx, http.Status.internal_server_error, 'Could not compress file',
				err.msg())
		}
		mut gzip_file := os.create(gzip_file_path) or {
			return handle_error(mut ctx, http.Status.internal_server_error, 'Could not create compressed file',
				err.msg())
		}
		gzip_file.write(gzip_file_data) or {
			gzip_file.close()
			os.rm(file_path) or {}
			return handle_error(mut ctx, http.Status.internal_server_error, 'Could not write compressed file contents',
				err.msg())
		}
		gzip_file.close()
	}

	return ctx.ok('OK')
}
