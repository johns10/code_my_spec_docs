# ExAws.S3

[![CI](https://github.com/ex-aws/ex_aws_s3/workflows/on-push/badge.svg)](https://github.com/ex-aws/ex_aws_s3/actions?query=workflow%3Aon-push)
[![Module Version](https://img.shields.io/hexpm/v/ex_aws_s3.svg)](https://hex.pm/packages/ex_aws_s3)
[![Hex Docs](https://img.shields.io/badge/hex-docs-lightgreen.svg)](https://hexdocs.pm/ex_aws_s3/)
[![Total Download](https://img.shields.io/hexpm/dt/ex_aws_s3.svg)](https://hex.pm/packages/ex_aws_s3)
[![License](https://img.shields.io/hexpm/l/ex_aws_s3.svg)](https://github.com/ex-aws/ex_aws_s3/blob/master/LICENSE)
[![Last Updated](https://img.shields.io/github/last-commit/ex-aws/ex_aws_s3.svg)](https://github.com/ex-aws/ex_aws_s3/commits/master)

Service module for https://github.com/ex-aws/ex_aws

## Installation

The package can be installed by adding `:ex_aws_s3` to your list of dependencies in `mix.exs`
along with `:ex_aws`, your preferred JSON codec / HTTP client, and optionally `:sweet_xml`
to support operations like `list_objects` that require XML parsing.

```elixir
def deps do
  [
    {:ex_aws, "~> 2.0"},
    {:ex_aws_s3, "~> 2.0"},
    {:poison, "~> 3.0"},
    {:hackney, "~> 1.9"},
    {:sweet_xml, "~> 0.6.6"}, # optional dependency
  ]
end
```

## Operations on AWS S3

### Basic Operations

The vast majority of operations here represent a single operation on S3.

#### Examples
```elixir
S3.list_objects("my-bucket") |> ExAws.request! #=> %{body: [list, of, objects]}
S3.list_objects("my-bucket") |> ExAws.stream! |> Enum.to_list #=> [list, of, objects]

S3.put_object("my-bucket", "path/to/bucket", contents) |> ExAws.request!
```

### Higher Level Operations

There are also some operations which operate at a higher level to make it easier
to download and upload very large files.

Multipart uploads
```elixir
"path/to/big/file"
|> S3.Upload.stream_file
|> S3.upload("my-bucket", "path/on/s3")
|> ExAws.request #=> {:ok, :done}
```
See `ExAws.S3.upload/4` for options

Download large file to disk
```elixir
S3.download_file("my-bucket", "path/on/s3", "path/to/dest/file")
|> ExAws.request #=> {:ok, :done}
```

### More high level functionality

Task.async_stream makes some high level flows so easy you don't need explicit ExAws support.

For example, here is how to concurrently upload many files.

```elixir
upload_file = fn {src_path, dest_path} ->
  S3.put_object("my_bucket", dest_path, File.read!(src_path))
  |> ExAws.request!
end

paths = %{"path/to/src0" => "path/to/dest0", "path/to/src1" => "path/to/dest1"}

paths
|> Task.async_stream(upload_file, max_concurrency: 10)
|> Stream.run
```

### Bucket as host functionality
#### Examples
```elixir
opts = [virtual_host: true, bucket_as_host: true]

ExAws.Config.new(:s3)
|> S3.presigned_url(:get, "bucket.custom-domain.com", "foo.txt", opts)

{:ok, "https://bucket.custom-domain.com/foo.txt"}
```

### Configuration

The `scheme`, `host`, and `port` can be configured to hit alternate endpoints.

For example, this is how to use a local minio instance:

```elixir
# config.exs
config :ex_aws, :s3,
  scheme: "http://",
  host: "localhost",
  port: 9000
```

An alternate `content_hash_algorithm` can be specified as well. The default is `:md5`. It may be necessary to change this when operating in a FIPS-compliant environment where MD5 isn't available, for instance. At this time, only `:sha256`, `:sha`, and `:md5` are supported by both Erlang and S3.

``` elixir
# config.exs
config :ex_aws_s3, :content_hash_algorithm, :sha256
```

## abort_multipart_upload(bucket, object, upload_id)

Abort a multipart upload

## complete_multipart_upload(bucket, object, upload_id, parts)

Complete a multipart upload

## delete_all_objects(bucket, objects, opts \\ [])

Delete all listed objects.

When performed, this function will continue making `delete_multiple_objects`
requests deleting 1000 objects at a time until all are deleted.

Can be streamed.

## Example
```
stream = ExAws.S3.list_objects(bucket(), prefix: "some/prefix") |> ExAws.stream!() |> Stream.map(& &1.key)
ExAws.S3.delete_all_objects(bucket(), stream) |> ExAws.request()
```

## delete_bucket(bucket)

Delete a bucket

## delete_bucket_cors(bucket)

Delete a bucket cors

## delete_bucket_lifecycle(bucket)

Delete a bucket lifecycle

## delete_bucket_policy(bucket)

Delete a bucket policy

## delete_bucket_replication(bucket)

Delete a bucket replication

## delete_bucket_tagging(bucket)

Delete a bucket tagging

## delete_bucket_website(bucket)

Delete a bucket website

## delete_multiple_objects(bucket, objects, opts \\ [])

Delete multiple objects within a bucket

Limited to 1000 objects.

## delete_object(bucket, object, opts \\ [])

Delete an object within a bucket

## delete_object_tagging(bucket, object, opts \\ [])

Remove the entire tag set from the specified object

## download_file(bucket, path, dest, opts \\ [])

Download an S3 object to a file.

This operation downloads multiple parts of an S3 object concurrently, allowing
you to maximize throughput.

Defaults to a concurrency of 8, chunk size of 1MB, and a timeout of 1 minute.

### Streaming to memory

In order to use `ExAws.stream!/2`, the third `dest` parameter must be set to `:memory`.
An example would be like the following:

    ExAws.S3.download_file("example-bucket", "path/to/file.txt", :memory)
    |> ExAws.stream!()

Note that **this won't start fetching anything immediately** since it returns an Elixir `Stream`.

#### Streaming by line

Streaming by line can be done with `Stream.chunk_while/4`. Here is an example:

    # Returns a stream which grabs chunks of data from S3 as specified in `opts`
    # but processes the stream line by line. For example, the default chunk
    # size of 1MB means requests for bytes from S3 will ask for 1MB sizes (to be downloaded)
    # however each element of the stream will be a single line.
    def generate_stream(bucket, file, opts \\ []) do
      bucket
      |> ExAws.S3.download_file(file, :memory, opts)
      |> ExAws.stream!()
      # Uncomment if you need to gunzip (and add dependency :stream_gzip)
      # |> StreamGzip.gunzip()
      |> Stream.chunk_while("", &chunk_fun/2, &to_line_stream_after_fun/1)
      |> Stream.concat()
    end

    def chunk_fun(chunk, acc) do
      to_try = acc <> chunk
      {elements, acc} = chunk_by_newline(to_try, "\n", [], {0, byte_size(to_try)})
      {:cont, elements, acc}
    end

    defp chunk_by_newline(_string, _newline, elements, {_offset, 0}) do
      {Enum.reverse(elements), ""}
    end

    defp chunk_by_newline(string, newline, elements, {offset, length}) do
      case :binary.match(string, newline, scope: {offset, length}) do
        {newline_offset, newline_length} ->
          difference = newline_length + newline_offset - offset
          element = binary_part(string, offset, difference)

          chunk_by_newline(
            string,
            newline,
            [element | elements],
            {newline_offset + newline_length, length - difference}
          )
        :nomatch ->
          {Enum.reverse(elements), binary_part(string, offset, length)}
      end
    end

    defp to_line_stream_after_fun(""), do: {:cont, []}
    defp to_line_stream_after_fun(acc), do: {:cont, [acc], []}

## get_bucket_acl(bucket)

Get bucket acl

## get_bucket_cors(bucket)

Get bucket cors

## get_bucket_lifecycle(bucket)

Get bucket lifecycle

## get_bucket_location(bucket)

Get bucket location

## get_bucket_logging(bucket)

Get bucket logging

## get_bucket_notification(bucket)

Get bucket notification

## get_bucket_object_versions(bucket, opts \\ [])

List metadata about all versions of the objects in a bucket.

## get_bucket_policy(bucket)

Get bucket policy

## get_bucket_replication(bucket)

Get bucket replication

## get_bucket_request_payment(bucket)

Get bucket payment configuration

## get_bucket_tagging(bucket)

Get bucket tagging

## get_bucket_versioning(bucket)

Get bucket versioning

## get_bucket_website(bucket)

Get bucket website

## get_object(bucket, object, opts \\ [])

Get an object from a bucket

## Examples
```
S3.get_object("my-bucket", "image.png")
S3.get_object("my-bucket", "image.png", version_id: "ae57ekgXPpdiVZLkYVWoTAGRhGJ5swt9")
```

## get_object_acl(bucket, object, opts \\ [])

Get an object's access control policy

## get_object_tagging(bucket, object, opts \\ [])

Get object tagging

## get_object_torrent(bucket, object)

Get a torrent for a bucket

## head_bucket(bucket)

Determine if a bucket exists

## head_object(bucket, object, opts \\ [])

Determine if an object exists

## initiate_multipart_upload(bucket, object, opts \\ [])

Initiate a multipart upload

## list_buckets(opts \\ [])

List buckets

## list_multipart_uploads(bucket, opts \\ [])

List multipart uploads for a bucket

## list_object_versions(bucket, opts \\ [])

List metadata about all versions of the objects in a bucket.

Can be streamed.

## Examples
```
S3.list_object_versions("my-bucket") |> ExAws.request

S3.list_object_versions("my-bucket") |> ExAws.stream!
S3.list_object_versions("my-bucket", prefix: "backup/") |> ExAws.stream!
```

## list_objects(bucket, opts \\ [])

List objects in bucket

Can be streamed.

## Examples
```
S3.list_objects("my-bucket") |> ExAws.request

S3.list_objects("my-bucket") |> ExAws.stream!
S3.list_objects("my-bucket", delimiter: "/", prefix: "backup") |> ExAws.stream!
S3.list_objects("my-bucket", prefix: "some/inner/location/path") |> ExAws.stream!
S3.list_objects("my-bucket", max_keys: 5, encoding_type: "url") |> ExAws.stream!
```

## list_objects_v2(bucket, opts \\ [])

List objects in bucket

Can be streamed.

## Examples
```
S3.list_objects_v2("my-bucket") |> ExAws.request

S3.list_objects_v2("my-bucket") |> ExAws.stream!
S3.list_objects_v2("my-bucket", delimiter: "/", prefix: "backup") |> ExAws.stream!
S3.list_objects_v2("my-bucket", prefix: "some/inner/location/path") |> ExAws.stream!
S3.list_objects_v2("my-bucket", max_keys: 5, encoding_type: "url") |> ExAws.stream!
```

## list_parts(bucket, object, upload_id, opts \\ [])

List the parts of a multipart upload

## options_object(bucket, object, origin, request_method, request_headers \\ [])

Determine the CORS configuration for an object

## post_object_restore(bucket, object, number_of_days, opts \\ [])

Restore an object to a particular version

## presigned_post(config, bucket, key, opts \\ [])

Generate a pre-signed post for an object.

When option param `:virtual_host` is `true`, the bucket name will be used in
the hostname, along with the s3 default host which will look like -
`<bucket>.s3.<region>.amazonaws.com` host.

When option param `:s3_accelerate` is `true`, the bucket name will be used as
the hostname, along with the `s3-accelerate.amazonaws.com` host.

When option param `:bucket_as_host` is `true`, the bucket name will be used as the full hostname.
In this case, bucket must be set to a full hostname, for example `mybucket.example.com`.
The `bucket_as_host` must be passed along with `virtual_host=true`

## presigned_url(config, http_method, bucket, object, opts \\ [])

Generate a pre-signed URL for an object.
This is a local operation and does not check whether the bucket or object exists.

When option param `:virtual_host` is `true`, the bucket name will be used in
the hostname, along with the s3 default host which will look like -
`<bucket>.s3.<region>.amazonaws.com` host.

When option param `:s3_accelerate` is `true`, the bucket name will be used as
the hostname, along with the `s3-accelerate.amazonaws.com` host.

When option param `:bucket_as_host` is `true`, the bucket name will be used as the full hostname.
In this case, bucket must be set to a full hostname, for example `mybucket.example.com`.
The `bucket_as_host` must be passed along with `virtual_host=true`

Option param `:start_datetime` can be used to modify the start date for the presigned url, which
allows for cache friendly urls.

Additional (signed) query parameters can be added to the url by setting option param
`:query_params` to a list of `{"key", "value"}` pairs. Useful if you are uploading parts of
a multipart upload directly from the browser.

Signed headers can be added to the url by setting option param `:headers` to
a list of `{"key", "value"}` pairs.

## Example
```
:s3
|> ExAws.Config.new([])
|> ExAws.S3.presigned_url(:get, "my-bucket", "my-object", [])
```

## put_bucket(bucket, region, opts \\ [])

Creates a bucket in the specified region

## put_bucket_acl(bucket, grants)

Update or create a bucket access control policy

## put_bucket_cors(bucket, cors_rules)

Update or create a bucket CORS policy

## put_bucket_lifecycle(bucket, lifecycle_rules)

Update or create a bucket lifecycle configuration

## Live-Cycle Rule Format

    %{
      # Unique id for the rule (max. 255 chars, max. 1000 rules allowed)
      id: "123",

      # Disabled rules are not executed
      enabled: true,

      # Filters
      # Can be based on prefix, object tag(s), both or none
      filter: %{
        prefix: "prefix/",
        tags: %{
          "key" => "value"
        }
      },

      # Actions
      # https://docs.aws.amazon.com/AmazonS3/latest/dev/intro-lifecycle-rules.html#intro-lifecycle-rules-actions
      actions: %{
        transition: %{
          trigger: {:date, ~D[2020-03-26]}, # Date or days based
          storage: ""
        },
        expiration: %{
          trigger: {:days, 2}, # Date or days based
          expired_object_delete_marker: true
        },
        noncurrent_version_transition: %{
          trigger: {:days, 2}, # Only days based
          storage: ""
        },
        noncurrent_version_expiration: %{
          trigger: {:days, 2} # Only days based
          newer_noncurrent_versions: 10
        },
        abort_incomplete_multipart_upload: %{
          trigger: {:days, 2} # Only days based
        }
      }
    }

## put_bucket_logging(bucket, logging_config)

Update or create a bucket logging configuration

Enables server access logging for the bucket.

## Examples
```
# Simple logging to another bucket
ExAws.S3.put_bucket_logging("my-bucket", target_bucket: "my-logs-bucket")

# With custom prefix
ExAws.S3.put_bucket_logging("my-bucket",
  target_bucket: "my-logs-bucket",
  target_prefix: "access-logs/"
)

# Using a map
ExAws.S3.put_bucket_logging("my-bucket", %{
  target_bucket: "my-logs-bucket",
  target_prefix: "logs/my-bucket/"
})
```

## put_bucket_notification(bucket, notification_config)

Update or create a bucket notification configuration

Configures notifications when certain events happen in the bucket.

## Simple Examples
```
# SNS notification
ExAws.S3.put_bucket_notification("my-bucket",
  topic_arn: "arn:aws:sns:us-east-1:123456789012:my-topic",
  events: ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
)

# Lambda notification with filters
ExAws.S3.put_bucket_notification("my-bucket",
  lambda_function_arn: "arn:aws:lambda:us-east-1:123456789012:function:my-function",
  events: ["s3:ObjectCreated:Put"],
  prefix: "uploads/",
  suffix: ".jpg"
)

# SQS notification
ExAws.S3.put_bucket_notification("my-bucket",
  queue_arn: "arn:aws:sqs:us-east-1:123456789012:my-queue",
  events: ["s3:ObjectCreated:*"]
)
```

## Advanced Examples
```
# Multiple notification types
ExAws.S3.put_bucket_notification("my-bucket", %{
  topic_configurations: [%{
    id: "image-processing",
    topic_arn: "arn:aws:sns:us-east-1:123456789012:image-topic",
    events: ["s3:ObjectCreated:*"],
    filter: %{key: %{filter_rules: [%{name: "prefix", value: "images/"}]}}
  }],
  lambda_configurations: [%{
    id: "thumbnail-generator",
    lambda_function_arn: "arn:aws:lambda:us-east-1:123456789012:function:thumbs",
    events: ["s3:ObjectCreated:Put", "s3:ObjectCreated:Post"]
  }]
})

# MinIO webhook configuration (uses QueueConfiguration with special ARN)
ExAws.S3.put_bucket_notification("my-bucket", %{
  queue_configurations: [%{
    id: "webhook-notifier",
    queue_arn: "arn:minio:sqs::webhook-target:webhook",
    events: ["s3:ObjectCreated:*"],
    filter: %{key: %{filter_rules: [
      %{name: "prefix", value: "uploads/"},
      %{name: "suffix", value: ".jpg"}
    ]}}
  }]
})
```

## put_bucket_policy(bucket, policy)

Update or create a bucket policy configuration

## put_bucket_replication(bucket, replication_config)

Update or create a bucket replication configuration

Configures cross-region replication for the bucket.

## Simple Example
```
# Simple replication to another region
ExAws.S3.put_bucket_replication("my-bucket",
  role: "arn:aws:iam::123456789012:role/replication-role",
  destination_bucket: "arn:aws:s3:::backup-bucket",
  storage_class: "STANDARD_IA"
)
```

## Advanced Example
```
ExAws.S3.put_bucket_replication("my-bucket", %{
  role: "arn:aws:iam::123456789012:role/replication-role",
  rules: [%{
    id: "ReplicateEverything",
    status: "Enabled",
    filter: %{prefix: "documents/"},
    destination: %{
      bucket: "arn:aws:s3:::backup-bucket",
      storage_class: "STANDARD_IA",
      access_control_translation: %{owner: "Destination"},
      account: "123456789012"
    }
  }]
})
```

## put_bucket_request_payment(bucket, payer)

Update or create a bucket requestPayment configuration

Sets who pays for requests and data transfer costs for this bucket.

## Examples
```
# Make requesters pay for downloads
ExAws.S3.put_bucket_request_payment("my-bucket", :requester)

# Bucket owner pays (default)
ExAws.S3.put_bucket_request_payment("my-bucket", :bucket_owner)
```

## put_bucket_tagging(bucket, tags)

Update or create a bucket tagging configuration

## Examples
```
# Using a map
ExAws.S3.put_bucket_tagging("my-bucket", %{"Environment" => "prod", "Team" => "data"})

# Using a keyword list
ExAws.S3.put_bucket_tagging("my-bucket", Environment: "prod", Team: "data")
```

## put_bucket_versioning(bucket, version_config)

Update or create a bucket versioning configuration

## Example
```
ExAws.S3.put_bucket_versioning(
 "my-bucket",
 "<VersioningConfiguration><Status>Enabled</Status></VersioningConfiguration>"
)
|> ExAws.request()
```

## put_bucket_website(bucket, website_config)

Update or create a bucket website configuration

Enables static website hosting for the bucket.

## Examples
```
# Simple website with defaults
ExAws.S3.put_bucket_website("my-bucket", index_document: "index.html")

# With error document
ExAws.S3.put_bucket_website("my-bucket",
  index_document: "index.html",
  error_document: "error.html"
)

# Full configuration with redirects
ExAws.S3.put_bucket_website("my-bucket", %{
  index_document: "index.html",
  error_document: "error.html",
  routing_rules: [%{
    condition: %{key_prefix_equals: "docs/"},
    redirect: %{replace_key_prefix_with: "documents/"}
  }]
})

# Redirect all requests to another host
ExAws.S3.put_bucket_website("my-bucket",
  redirect_all_requests_to: %{host_name: "example.com", protocol: "https"}
)
```

## put_object(bucket, object, body, opts \\ [])

Create an object within a bucket

## put_object_acl(bucket, object, acl)

Create or update an object's access control policy

## put_object_copy(dest_bucket, dest_object, src_bucket, src_object, opts \\ [])

Copy an object

## put_object_tagging(bucket, object, tags, opts \\ [])

Add a set of tags to an existing object

## Options

- `:version_id` - The versionId of the object that the tag-set will be added to.

## upload(source, bucket, path, opts \\ [])

Multipart upload to S3.

Handles initialization, uploading parts concurrently, and multipart upload completion.

## Uploading a stream

Streams that emit binaries may be uploaded directly to S3. Each binary will be uploaded
as a chunk, so it must be at least 5 megabytes in size. The `S3.Upload.stream_file`
helper takes care of reading the file in 5 megabyte chunks.
```
"path/to/big/file"
|> S3.Upload.stream_file
|> S3.upload("my-bucket", "path/on/s3")
|> ExAws.request! #=> :done
```

## Options

These options are specific to this function
* See `Task.async_stream/5`'s `:max_concurrency` and `:timeout` options.
  * `:max_concurrency` - only applies when uploading a stream. Sets the maximum number of tasks to run at the same time. Defaults to `4`
  * `:timeout` - the maximum amount of time (in milliseconds) each task is allowed to execute for. Defaults to `30_000`.
  * `:refetch_auth_on_request` - re-fetch the auth from the library config on each request in the upload process instead of using
    the initial auth. Fixes an edge case uploading large files when using a strategy from `ex_aws_sts` that provides short lived tokens,
    where uploads could fail if the token expires before the upload is completed. Defaults to `false`.

All other options (ex. `:content_type`) are passed through to
`ExAws.S3.initiate_multipart_upload/3`.

## upload_part(bucket, object, upload_id, part_number, body, opts \\ [])

Upload a part for a multipart upload

## upload_part_copy(dest_bucket, dest_object, src_bucket, src_object, upload_id, part_number, source_range, opts \\ [])

Upload a part for a multipart copy

## hash_algorithm/0

The hashing algorithms that both S3 and Erlang support.

https://docs.aws.amazon.com/AmazonS3/latest/userguide/checking-object-integrity.html
https://www.erlang.org/doc/man/crypto.html#type-hash_algorithm