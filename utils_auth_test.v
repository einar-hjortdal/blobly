module main

fn test_validate_header_content() ! {
	access_key, secret_key := generate_key_pair()
	keys := {
		access_key: secret_key
	}
	content := new_header_content(access_key, secret_key)
	validate_header_content(content, keys)!
}
