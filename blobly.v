module main

import veb

struct Context {
	veb.Context
}

@[heap]
pub struct App {
	veb.Middleware[Context]
	keys             map[string]string
	public_directory string
}

fn main() {
	settings := load_settings()
	set_log_level()

	create_public_directory(settings.public_directory)

	mut app := App{
		public_directory: settings.public_directory
		keys:             settings.keys
	}

	app.use(handler: app.middleware_debug)
	app.route_use('/api/:path...', handler: app.middleware_auth)

	veb.run[App, Context](mut app, settings.port)
}
