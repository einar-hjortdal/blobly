module main

import net.http
import os
import veb

@['/public/:directory/:file_name'; get]
fn (mut app App) serve_public(mut ctx Context, directory string, file_name string) veb.Result {
	file_path := safely_join_path(app.public_directory, directory, file_name) or {
		return handle_error(mut ctx, http.Status.internal_server_error, 'Bad path name',
			err.msg())
	}

	accepted_encoding := ctx.get_header(http.CommonHeader.accept_encoding) or {
		return send_file(mut ctx, file_path)
	}

	if !accepted_encoding.contains('gzip') {
		return send_file(mut ctx, file_path)
	}

	if can_gzip(file_name) {
		compressed_file_path := '${file_path}${gzip_extension}'
		file_extension := os.file_ext(file_path).to_lower()
		if os.is_file(compressed_file_path) {
			return send_compressed_file(mut ctx, file_extension, compressed_file_path)
		}
	}
	return send_file(mut ctx, file_path)
}
