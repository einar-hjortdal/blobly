module main

import veb
import net.http

struct BloblyError {
	Error
	message string
	details string
}

fn new_blobly_error(message string, details string) BloblyError {
	return BloblyError{
		message: message
		details: details
	}
}

fn handle_error(mut ctx Context, status http.Status, message string, details string) veb.Result {
	ctx.res.set_status(status)
	return ctx.json(new_blobly_error(message, details))
}

struct BloblySuccess {
	success              bool
	file_name            string @[json: 'fileName'; omitempty]
	file_name_compressed string @[omitempty]
}

struct Entries {
	entries []string
}
