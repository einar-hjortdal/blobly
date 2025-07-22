module main

import veb

@['/public/:file_name'; get]
fn (mut app App) serve_public(mut ctx Context, file_name string) veb.Result {
	return handle_serve_public(mut app, mut ctx, file_name)
}

@['/api/files'; get]
fn (mut app App) list_files_in_root(mut ctx Context) veb.Result {
	return handle_list_files(mut app, mut ctx, '')
}

@['/api/files/:directory...'; get]
fn (mut app App) list_files_in_dir(mut ctx Context, directory string) veb.Result {
	return handle_list_files(mut app, mut ctx, directory)
}

@['/api/files/:file_name...'; post]
fn (mut app App) create_file(mut ctx Context, file_name string) veb.Result {
	return handle_create_file(mut app, mut ctx, file_name)
}

@['/api/directory/:directory_name...'; post]
fn (mut app App) create_directory(mut ctx Context, directory_name string) veb.Result {
	return handle_create_directory(mut app, mut ctx, directory_name)
}
