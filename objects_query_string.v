module main

// parse_bool returns true if the string represents a true bool, or false if the string represents a
// false bool.
// Any of the following are accepted values: 1, t, T, TRUE, true, True, 0, f, F, FALSE, false, False
// Always call `can_parse_bool` before `parse_bool` to handle strings that cannot be parsed to bool.
fn parse_bool(s string) bool {
	string_true := ['1', 't', 'T', 'TRUE', 'true', 'True']
	for value in string_true {
		if s == value {
			return true
		}
	}
	return false
}

struct ZeroString {
	v      string
	is_set bool
}

fn zero_string(m map[string]string, k string) ZeroString {
	if k in m {
		return ZeroString{
			v:      m[k]
			is_set: true
		}
	}
	return ZeroString{}
}

struct ZeroBool {
	v      bool
	is_set bool
}

fn zero_bool(m map[string]string, k string) ZeroBool {
	s := zero_string(m, k)
	if s.is_set {
		if s.v == '' { // ?gzip
			return ZeroBool{
				v:      true
				is_set: true
			}
		}

		return ZeroBool{ // ?gzip=true
			v:      parse_bool(s.v)
			is_set: true
		}
	}

	return ZeroBool{}
}

struct CreateFileRequest {
	gzip ZeroBool
}

fn extract_create_file_request_params(m map[string]string) CreateFileRequest {
	return CreateFileRequest{
		gzip: zero_bool(m, 'gzip')
	}
}
