module main

import veb
import os

// get_gzippable_file_extension returns the extension of the file that could be gzipped, if it could.
fn get_gzippable_file_extension(file_name string) !string {
	for extension in plausible_gzip {
		if file_name.ends_with(extension) {
			return extension
		}
	}
	return error('This file should not be compressed')
}

// could_gzip wraps get_gzippable_file_extension and returns a boolean. Useful when the extension is
// not needed.
fn could_gzip(file_name string) bool {
	if _ := get_gzippable_file_extension(file_name) {
		return true
	}
	return false
}

fn get_content_type(extension string) string {
	return veb.mime_types[extension]
}

fn safely_join_path(public_directory string, provided_path string) !string {
	file_path := os.join_path(public_directory, provided_path)
	if !file_path.starts_with(public_directory) {
		return 'Path resolved to a directory outside of the public directory'
	}
	return file_path
}
