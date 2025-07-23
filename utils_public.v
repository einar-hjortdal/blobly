module main

import veb
import net.http
import os

fn send_file(mut ctx Context, file_path string) veb.Result {
	if os.is_file(file_path) {
		return ctx.file(file_path)
	}
	return ctx.not_found()
}

fn send_compressed_file(mut ctx Context, file_extension string, file_path string) veb.Result {
	content_type := get_content_type(file_extension)
	ctx.set_header(http.CommonHeader.content_encoding, 'gzip')
	ctx.set_header(http.CommonHeader.vary, 'Accept-Encoding')
	ctx.set_content_type(content_type)
	return ctx.file(file_path)
}
