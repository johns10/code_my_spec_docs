# ExAws.S3.Upload

Represents an AWS S3 Multipart Upload operation.

Implements `ExAws.Operation.perform/2`

## Examples
```
"path/to/big/file"
|> S3.Upload.stream_file
|> S3.upload("my-bucket", "path/on/s3")
|> ExAws.request! #=> :done
```

See `ExAws.S3.upload/4` for options

## stream_file(path, opts \\ [])

Open a file stream for use in an upload.

Chunk size must be at least 5 MiB. Defaults to 5 MiB

## upload_chunk!(arg, op, config)

Upload a chunk for an operation.

The first argument is a tuple with the binary contents of the chunk, and a
positive integer index indicating which chunk it is. It will return this index
along with the `etag` response from AWS necessary to complete the multipart upload.