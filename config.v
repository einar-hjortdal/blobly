module main

import log
import os
import einar_hjortdal.dotenv

const env_public_directory = 'PUBLIC_DIRECTORY'
const env_port = 'PORT'
const env_debug = 'DEBUG'
const env_private_keys = 'PRIVATE_KEYS'
const env_secret_keys = 'SECRET_KEYS'

const env_required = [env_secret_keys, env_debug]
const env_defaults = {
	env_debug:            'false'
	env_port:             '8080'
	env_public_directory: 'public'
}

fn add_default_settings() {
	for k, v in env_defaults {
		os.setenv(k, v, false)
		os.setenv(k, v, false)
	}
}

fn verify_settings() {
	for i := 0; i < env_required.len; i++ {
		env_var := env_required[i]
		if os.getenv(env_var) == '' {
			panic(format_error_message('Missing environment variable ${env_var}'))
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

fn load_settings() {
	dotenv.load()
	add_default_settings()
	verify_settings()
}
