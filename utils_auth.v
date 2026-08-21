module main

import crypto.hmac
import crypto.rand
import crypto.sha256
import encoding.hex

// returns (access_key, secret_key)
fn generate_key_pair() (string, string) {
	access_key_bytes := rand.bytes(64) or { panic(err) }
	secret_key_bytes := rand.bytes(64) or { panic(err) }
	access_key := hex.encode(access_key_bytes)
	secret_key := hex.encode(secret_key_bytes)
	return access_key, secret_key
}

fn new_signature(access_key string, secret_key string) []u8 {
	return hmac.new(secret_key.bytes(), access_key.bytes(), sha256.sum, sha256.block_size)
}

fn new_header_content(access_key string, secret_key string) string {
	signature := new_signature(access_key, secret_key)
	encoded := hex.encode(signature)
	return '${access_key}$${encoded}'
}

fn validate_header_content(header_content string, keys map[string]string) !string {
	split_content := header_content.split('$')
	access_key := split_content[0]
	signature := split_content[1]
	decoded := hex.decode(signature)!
	secret_key := keys[access_key]
	signature_mirror := new_signature(access_key, secret_key)
	if hmac.equal(decoded, signature_mirror) {
		return split_content[0]
	}
	return error('Signature not valid')
}
