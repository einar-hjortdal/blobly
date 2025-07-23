# blobly

Central file server

## Features

- Accepts BLOBs
- Stores BLOBs on file system
- Serves BLOBS
- Compresses BLOBs with gzip*

*toggle

## Usage

Build and run the application. Environment variables for configuration, see [.env.template](.env.template)

Requests to `/api/` routes require a `Blobly-Authorization` header containing the *access key* signed 
with its related *secret key*, using a `$` separator like this: `<access_key>$<signature>`. The signature 
is done with hmac, using the sha256 hash function with a block size of 64.
