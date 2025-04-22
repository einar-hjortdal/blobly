module blobly

import x.vweb
import json
import time
import net.http

struct BloblyError {
	status    http.Status
	code      int
	msg       string
	timestamp string
}

fn (e BloblyError) status() http.Status {
	return e.status
}

fn (e BloblyError) code() int {
	return e.code
}

fn (e BloblyError) msg() string {
	return e.msg
}

fn (e BloblyError) timestamp() string {
	return e.timestamp
}

fn (e BloblyError) to_string() string {
	return json.encode(e)
}

fn new_blobly_error(status http.Status, msg string) BloblyError {
	return BloblyError{
		status:    status
		code:      int(status)
		msg:       msg
		timestamp: time.now().format_rfc3339()
	}
}

fn (mut ctx Context) send_error(error IError, function_name string) vweb.Result {
	if error is BloblyError {
		// app.logger.debug('${function_name}: ${error}')
		ctx.res.set_status(error.status)
		return ctx.json(error)
	}
	blobly_error := new_blobly_error(http.Status.internal_server_error, error.msg())
	// app.logger.debug('${function_name} (unhandled): ${error.msg()}')
	ctx.res.set_status(blobly_error.status)
	return ctx.json(blobly_error)
}
