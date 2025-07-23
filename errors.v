module main

import veb
import json
import time
import net.http

const lib = 'blobly'

fn format_error_message(msg string) string {
	return '[${lib}: ${msg}]'
}

struct BloblyError {
	Error
	status    http.Status
	code      int
	msg       string
	timestamp time.Time
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

fn (e BloblyError) timestamp() time.Time {
	return e.timestamp
}

// TODO should encode timestamp to iso8601
fn (e BloblyError) to_string() string {
	return json.encode(e)
}

fn new_blobly_error(status http.Status, msg string) BloblyError {
	return BloblyError{
		status:    status
		code:      int(status)
		msg:       msg
		timestamp: time.now()
	}
}

fn (mut ctx Context) send_error(error IError, function_name string) veb.Result {
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
