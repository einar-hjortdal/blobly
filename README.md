This project is active: new features are being developed, bugs are being fixed.

# blobly

Central file server

## Features

- Accepts BLOBs
- Stores BLOBs on file system
- Serves BLOBS
- Compresses BLOBs with gzip*

*toggle

## Usage

This application is built to run on Linux. The `/var/blobly/data` directory must be manually created before running blobly. The user running the application must have appropriate permissions to read and write in this directory.

Environment variables for configuration, see [.env.template](.env.template)

Requests to `/api/` routes require a `Blobly-Authorization` header containing the *access key* signed with its related *secret key*, using a `$` separator like this: `<access_key>$<signature>`. The signature is done with hmac, using the sha256 hash function with a block size of 64, hex encoded.

Use FreeNGINX as reverse proxy to terminate SSL.
