module main

import log
import net.http

fn (mut app App) middleware_debug(mut ctx Context) bool {
	log.debug('Received request: ${ctx.req.url} ${ctx.req.method}')
	return true
}

fn (mut app App) middleware_auth(mut ctx Context) bool {
	header_content := ctx.get_custom_header('Blobly-Authorization') or {
		ctx.res.set_status(http.Status.unauthorized)
		ctx.json(new_blobly_error('Unauthorized', 'Missing Blobly-Authorization header'))
		return false
	}

	validate_header_content(header_content, app.keys) or {
		ctx.res.set_status(http.Status.unauthorized)
		ctx.json(new_blobly_error('Unauthorized', 'Invalid signature'))
		return false
	}
	return true
}
