module main

import veb

@['/public/:file_name'; get]
fn (mut app App) serve_public(mut ctx Context, file_name string) veb.Result {
	return handle_serve_public(mut app, mut ctx, file_name)
}
