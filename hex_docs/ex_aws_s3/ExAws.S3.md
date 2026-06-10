# ExAws.S3



## list_buckets/1

List buckets

## delete_bucket/1

Delete a bucket

## delete_bucket_cors/1

Delete a bucket cors

## delete_bucket_lifecycle/1

Delete a bucket lifecycle

## delete_bucket_policy/1

Delete a bucket policy

## delete_bucket_replication/1

Delete a bucket replication

## delete_bucket_tagging/1

Delete a bucket tagging

## delete_bucket_website/1

Delete a bucket website

## list_objects/2

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

## list_objects_v2/2

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

## list_object_versions/2

List metadata about all versions of the objects in a bucket.

Can be streamed.

## Examples
```
S3.list_object_versions("my-bucket") |> ExAws.request

S3.list_object_versions("my-bucket") |> ExAws.stream!
S3.list_object_versions("my-bucket", prefix: "backup/") |> ExAws.stream!
```

## get_bucket_acl/1

Get bucket acl

## get_bucket_cors/1

Get bucket cors

## get_bucket_lifecycle/1

Get bucket lifecycle

## get_bucket_policy/1

Get bucket policy

## get_bucket_location/1

Get bucket location

## get_bucket_logging/1

Get bucket logging

## get_bucket_notification/1

Get bucket notification

## get_bucket_replication/1

Get bucket replication

## get_bucket_tagging/1

Get bucket tagging

## get_bucket_object_versions/2

List metadata about all versions of the objects in a bucket.

## get_bucket_request_payment/1

Get bucket payment configuration

## get_bucket_versioning/1

Get bucket versioning

## get_bucket_website/1

Get bucket website

## head_bucket/1

Determine if a bucket exists

## list_multipart_uploads/2

List multipart uploads for a bucket

## put_bucket/3

Creates a bucket in the specified region

## put_bucket_acl/2

Update or create a bucket access control policy

## put_bucket_cors/2

Update or create a bucket CORS policy

## put_bucket_lifecycle/2

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

## put_bucket_policy/2

Update or create a bucket policy configuration

## put_bucket_logging/2

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

## put_bucket_notification/2

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

## put_bucket_replication/2

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

## put_bucket_tagging/2

Update or create a bucket tagging configuration

## Examples
```
# Using a map
ExAws.S3.put_bucket_tagging("my-bucket", %{"Environment" => "prod", "Team" => "data"})

# Using a keyword list
ExAws.S3.put_bucket_tagging("my-bucket", Environment: "prod", Team: "data")
```

## put_bucket_request_payment/2

Update or create a bucket requestPayment configuration

Sets who pays for requests and data transfer costs for this bucket.

## Examples
```
# Make requesters pay for downloads
ExAws.S3.put_bucket_request_payment("my-bucket", :requester)

# Bucket owner pays (default)
ExAws.S3.put_bucket_request_payment("my-bucket", :bucket_owner)
```

## put_bucket_versioning/2

Update or create a bucket versioning configuration

## Example
```
ExAws.S3.put_bucket_versioning(
 "my-bucket",
 "<VersioningConfiguration><Status>Enabled</Status></VersioningConfiguration>"
)
|> ExAws.request()
```

## put_bucket_website/2

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

## delete_object/3

Delete an object within a bucket

## delete_object_tagging/3

Remove the entire tag set from the specified object

## delete_multiple_objects/3

Delete multiple objects within a bucket

Limited to 1000 objects.

## delete_all_objects/3

Delete all listed objects.

When performed, this function will continue making `delete_multiple_objects`
requests deleting 1000 objects at a time until all are deleted.

Can be streamed.

## Example
```
stream = ExAws.S3.list_objects(bucket(), prefix: "some/prefix") |> ExAws.stream!() |> Stream.map(& &1.key)
ExAws.S3.delete_all_objects(bucket(), stream) |> ExAws.request()
```

## get_object/3

Get an object from a bucket

## Examples
```
S3.get_object("my-bucket", "image.png")
S3.get_object("my-bucket", "image.png", version_id: "ae57ekgXPpdiVZLkYVWoTAGRhGJ5swt9")
```

## upload/4

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

## get_object_acl/3

Get an object's access control policy

## get_object_torrent/2

Get a torrent for a bucket

## get_object_tagging/3

Get object tagging

## head_object/3

Determine if an object exists

## options_object/5

Determine the CORS configuration for an object

## post_object_restore/4

Restore an object to a particular version

## put_object/4

Create an object within a bucket

## put_object_acl/3

Create or update an object's access control policy

## put_object_tagging/4

Add a set of tags to an existing object

## Options

- `:version_id` - The versionId of the object that the tag-set will be added to.

## put_object_copy/5

Copy an object

## initiate_multipart_upload/3

Initiate a multipart upload

## upload_part/6

Upload a part for a multipart upload

## upload_part_copy/8

Upload a part for a multipart copy

## complete_multipart_upload/4

Complete a multipart upload

## abort_multipart_upload/3

Abort a multipart upload

## list_parts/4

List the parts of a multipart upload

## presigned_url/5

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

## presigned_post/4

Generate a pre-signed post for an object.

When option param `:virtual_host` is `true`, the bucket name will be used in
the hostname, along with the s3 default host which will look like -
`<bucket>.s3.<region>.amazonaws.com` host.

When option param `:s3_accelerate` is `true`, the bucket name will be used as
the hostname, along with the `s3-accelerate.amazonaws.com` host.

When option param `:bucket_as_host` is `true`, the bucket name will be used as the full hostname.
In this case, bucket must be set to a full hostname, for example `mybucket.example.com`.
The `bucket_as_host` must be passed along with `virtual_host=true`