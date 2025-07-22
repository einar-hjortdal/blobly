module main

import log
// import net.http

fn (mut app App) middleware_debug(mut ctx Context) bool {
	log.debug('Received request: ${ctx.req.url} ${ctx.req.method}')
	return true
}

fn parse_authorization_header(authorization string) {
}

// fn validate_signature() {
//	authorization := ctx.get_header(http.CommonHeader.authorization) or { return error }
// parse_authorization_header(authorization) or { return error }
// }
