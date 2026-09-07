module main

import encoding.hex

fn new_header_content(access_key string, secret_key string) string {
	signature := new_signature(access_key, secret_key)
	encoded := hex.encode(signature)
	return '${access_key}\$${encoded}'
}

fn test_validate_header_content() ! {
	access_key, secret_key := generate_key_pair()
	keys := {
		access_key: secret_key
	}
	content := new_header_content(access_key, secret_key)
	validate_header_content(content, keys)!
}
