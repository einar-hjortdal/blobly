module main

import log
import os
import einar_hjortdal.dotenv

const lib = 'blobly'
const env_prefix = lib.to_upper() + '_' // TODO remove prefix

const env_public_directory = 'PUBLIC_DIRECTORY'
const env_port = 'PORT'
const env_debug = 'DEBUG'
const env_keys = 'KEYS'

const env_required = [env_keys, env_debug]

const env_defaults = {
	env_debug:            'false'
	env_port:             '8080'
	env_public_directory: 'public'
}

const env_expected = [
	env_public_directory,
	env_port,
	env_debug,
	env_keys,
]

fn remove_prefix() {
	for i := 0; i < env_expected.len; i++ {
		env_var := env_expected[i]
		val := os.getenv(env_prefix + env_var)
		if val == '' {
			continue
		}

		os.unsetenv(env_prefix + env_var)
		os.setenv(env_var, val, false)
	}
}

fn add_default_settings() {
	for k, v in env_defaults {
		os.setenv(k, v, false)
	}
}

fn verify_settings() {
	for i := 0; i < env_required.len; i++ {
		env_var := env_required[i]

		if os.getenv(env_var) == '' {
			if env_var == env_keys {
				access_key, secret_key := generate_key_pair()
				log.error('Missing environment variable ${env_var}
					If you need new keys, use these:
					Secret key: ${secret_key}
					Access key: ${access_key}
					exiting...')
			}
			panic('Missing environment variable ${env_var}')
		}
	}
}

fn create_public_directory(dir_path string) {
	if os.is_file(dir_path) {
		panic('Cannot create public directory: ${dir_path} is a file')
	}

	if os.is_dir(dir_path) {
		log.info('Files are served from the directory ${dir_path}')
		return
	}

	log.info('Creating directory ${dir_path}')
	os.mkdir(dir_path) or { panic(err) }
	log.info('Public directory ${dir_path} created successfully')
}

fn set_log_level() {
	if os.getenv(env_debug) == 'true' {
		log.set_level(log.Level.debug)
	} else {
		log.set_level(log.Level.info)
	}
}

fn get_keys() map[string]string {
	key_pairs := os.getenv(env_keys).split(',')
	mut keys := map[string]string{}
	for i := 0; i < key_pairs.len; i++ {
		pair := key_pairs[i].split('=')
		if pair.len != 2 {
			panic('Malformed environemnt variable ${env_keys}')
		}
		access_key := pair[0]
		secret_key := pair[1]
		keys[access_key] = secret_key
	}
	return keys
}

struct Settings {
	keys             map[string]string
	port             int
	public_directory string
}

fn load_settings() Settings {
	dotenv.load()
	remove_prefix()
	add_default_settings()
	verify_settings()

	return Settings{
		keys:             get_keys()
		port:             os.getenv(env_port).int()
		public_directory: os.abs_path(os.getenv(env_public_directory))
	}
}
