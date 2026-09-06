module main

import veb
import os

const plausible_gzip = ['.html', '.css', '.js', '.json', '.xml', '.md', '.txt']
const gzip_extension = '.gz'

fn can_gzip(file_name string) bool {
	for i := 0; i < plausible_gzip.len; i++ {
		extension := plausible_gzip[i]
		if file_name.ends_with(extension) {
			return true
		}
	}
	return false
}

fn get_content_type(extension string) string {
	return veb.mime_types[extension]
}

fn safely_join_path(dirs ...string) !string {
	path := os.join_path(data_dir, ...dirs)
	if !path.starts_with(data_dir) {
		return 'Path resolved to a directory outside of the public directory'
	}
	return path
}
