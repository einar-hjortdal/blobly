module main

import veb

@['/public/:file_name'; get]
fn (app &App) serve_public(mut ctx Context, file_name string) veb.Result {
	return handle_serve_public(app, mut ctx, file_name)
}

@['/api/files'; get]
fn (app &App) list_files_in_root(mut ctx Context) veb.Result {
	return handle_list_files(app, mut ctx, '')
}

@['/api/files/:directory...'; get]
fn (app &App) list_files_in_dir(mut ctx Context, directory string) veb.Result {
	return handle_list_files(app, mut ctx, directory)
}

@['/api/files/:file_name...'; post]
fn (app &App) create_file(mut ctx Context, file_name string) veb.Result {
	return handle_create_file(app, mut ctx, file_name)
}

@['/api/directory/:directory_name...'; post]
fn (app &App) create_directory(mut ctx Context, directory_name string) veb.Result {
	return handle_create_directory(app, mut ctx, directory_name)
}

@['/api/health'; get]
fn (app &App) health(mut ctx Context) veb.Result {
	// health status
	return ctx.json('{}')
}
