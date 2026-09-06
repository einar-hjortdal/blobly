module main

import compress.gzip
import log
import net.http
import os
import veb

@['/api/directories'; get]
fn (mut app App) api_directories_get(mut ctx Context) veb.Result {
	entries := os.ls(data_dir) or {
		return handle_error(mut ctx, http.Status.internal_server_error, 'Could not list data directory contents', err.msg())
	}

	return ctx.json(Entries{
		entries: entries
	})
}

@['/api/files/:directory'; get]
fn (mut app App) api_files_directory_get(mut ctx Context, directory string) veb.Result {
	directory_path := safely_join_path( directory) or {
		return handle_error(mut ctx, http.Status.bad_request, 'Bad path', err.msg())
	}

	entries := os.ls(directory_path) or {
		return handle_error(mut ctx, http.Status.internal_server_error, 'Could not list directory contents', err.msg())
	}

	return ctx.json(Entries{
		entries: entries
	})
}

@['/api/files/:directory'; post]
fn (mut app App) api_files_directory_post(mut ctx Context, directory string) veb.Result {
	directory_path := safely_join_path(directory) or {
		return handle_error(mut ctx, http.Status.bad_request, 'Bad path', err.msg())
	}

	os.mkdir(directory_path) or {
		return handle_error(mut ctx, http.Status.internal_server_error, 'Could not create directory', err.msg())
	}

	return ctx.json(BloblySuccess{
		success: true
	})
}

@['/api/files/:directory'; delete]
fn (mut app App) api_files_directory_delete(mut ctx Context, directory string) veb.Result {
	directory_path := safely_join_path(directory) or {
		return handle_error(mut ctx, http.Status.bad_request, 'Bad path', err.msg())
	}

	entries := os.ls(directory_path) or {
		return handle_error(mut ctx, http.Status.internal_server_error, 'Could not list directory contents', err.msg())
	}

	if entries.len != 0 {
		return handle_error(mut ctx, http.Status.bad_request, 'Directory contains ${entries.len} files', 'Refusing to delete non-empty directory')
	}

	return ctx.json(BloblySuccess{
		success: true
	})
}

@['/api/files/:directory/:file_name'; post]
fn (mut app App) api_files_directory_filename_post(mut ctx Context, directory string, file_name string) veb.Result {
	p := extract_create_file_request_params(ctx.query)

	file_path := safely_join_path(directory, file_name) or {
		return handle_error(mut ctx, http.Status.bad_request, 'Bad path name', err.msg())
	}

	mut file := os.create(file_path) or {
		log.debug('failed os.create call with error: ${err.msg()}')
		return handle_error(mut ctx, http.Status.internal_server_error, 'Could not create file', err.msg())
	}

	file.write(ctx.req.data.bytes()) or {
		file.close()
		os.rm(file_path) or {}
		return handle_error(mut ctx, http.Status.internal_server_error, 'Could not write file contents', err.msg())
	}
	file.close()

	// early exit if no gzipping to be done
	if !(p.gzip.v && can_gzip(file_name)) {
		return ctx.json(BloblySuccess{
			success: true
			file_name: file_name
		})
	}

	gzip_file_path := '${file_path}${gzip_extension}'
	gzip_file_data := gzip.compress(ctx.req.data.bytes()) or {
		os.rm(file_path) or {}
		return handle_error(mut ctx, http.Status.internal_server_error, 'Could not compress file', err.msg())
	}

	mut gzip_file := os.create(gzip_file_path) or {
		os.rm(file_path) or {}
		return handle_error(mut ctx, http.Status.internal_server_error, 'Could not create compressed file', err.msg())
	}

	gzip_file.write(gzip_file_data) or {
		gzip_file.close()
		os.rm(file_path) or {}
		os.rm(gzip_file_path) or {}
		return handle_error(mut ctx, http.Status.internal_server_error, 'Could not write compressed file contents', err.msg())
	}
	gzip_file.close()

	return ctx.json(BloblySuccess{
		success: true
		file_name: file_name
		file_name_compressed: '${file_name}${gzip_extension}'
	})
}

@['/api/files/:directory/:file_name'; delete]
fn (mut app App) api_files_directory_filename_delete(mut ctx Context, directory string, file_name string) veb.Result {
	file_path := safely_join_path(directory, file_name) or {
		return handle_error(mut ctx, http.Status.bad_request, 'Bad path name', err.msg())
	}

	os.rm(file_path) or {
		return handle_error(mut ctx, http.Status.internal_server_error, 'Could not delete file', err.msg())
	}

	if can_gzip(file_name) {
		gzip_file_path := '${file_path}${gzip_extension}'
		os.rm(gzip_file_path) or {
			return handle_error(mut ctx, http.Status.internal_server_error, 'Could not delete compressed file', err.msg())
		}
	}

	return ctx.json(BloblySuccess{
		success: true
	})
}
