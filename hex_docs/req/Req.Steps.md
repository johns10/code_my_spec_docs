# Req.Steps

The collection of built-in steps.

Req is composed of:

  * `Req` - the high-level API

  * `Req.Request` - the low-level API and the request struct

  * `Req.Steps` - the collection of built-in steps (you're here!)

  * `Req.Test` - the testing conveniences

## put_base_url/1

Sets base URL for all requests.

## Request Options

  * `:base_url` - if set, the request URL is merged with this base URL.

    The base url can be a string, a `%URI{}` struct, a 0-arity function,
    or a `{mod, fun, args}` tuple describing a function to call.

## Examples

    iex> req = Req.new(base_url: "https://httpbin.org")
    iex> Req.get!(req, url: "/status/200").status
    200
    iex> Req.get!(req, url: "/status/201").status
    201

## auth/1

Sets request authentication.

## Request Options

  * `:auth` - sets the `authorization` header:

      * `string` - sets to this value;

      * `{:basic, userinfo}` - uses Basic HTTP authentication;

      * `{:digest, userinfo}` - uses Digest HTTP authentication;

      * `{:bearer, token}` - uses Bearer HTTP authentication;

      * `:netrc` - load credentials from `.netrc` at path specified in `NETRC` environment variable.
        If `NETRC` is not set, load `.netrc` in user's home directory;

      * `{:netrc, path}` - load credentials from `path`

      * `fn -> {:bearer, "eyJ0eXAi..." } end` - a 0-arity function that returns one of the aforementioned types.

      * `{mod, fun, args}` - an MFArgs tuple that returns one of the aforementioned types.

## Examples

    iex> Req.get!("https://httpbin.org/basic-auth/foo/bar", auth: {:basic, "foo:foo"}).status
    401
    iex> Req.get!("https://httpbin.org/basic-auth/foo/bar", auth: {:basic, "foo:bar"}).status
    200
    iex> Req.get!("https://httpbin.org/basic-auth/foo/bar", auth: fn -> {:basic, "foo:bar"} end).status
    200
    iex> Req.get!("https://httpbin.org/basic-auth/foo/bar", auth: {Authentication, :fetch_token, []}).status
    200

    iex> Req.get!("https://httpbin.org/digest-auth/auth/user/pass", auth: {:digest, "user:pass"}).status
    200

    iex> Req.get!("https://httpbin.org/bearer", auth: {:bearer, ""}).status
    401
    iex> Req.get!("https://httpbin.org/bearer", auth: {:bearer, "foo"}).status
    200
    iex> Req.get!("https://httpbin.org/bearer", auth: fn -> {:bearer, "foo"} end).status
    200

    iex> System.put_env("NETRC", "./test/my_netrc")
    iex> Req.get!("https://httpbin.org/basic-auth/foo/bar", auth: :netrc).status
    200

    iex> Req.get!("https://httpbin.org/basic-auth/foo/bar", auth: {:netrc, "./test/my_netrc"}).status
    200
    iex> Req.get!("https://httpbin.org/basic-auth/foo/bar", auth: fn -> {:netrc, "./test/my_netrc"} end).status
    200

## compressed/1

Asks the server to return compressed response.

This step also enables the [`decompress_body`](`Req.Steps.decompress_body/1`) step, which
decompresses the response body. Both steps are off by default; set `compressed: true` to opt in.

Supported formats:

  * `gzip`

  * `br` (if [brotli] is installed)

  * `zstd` (requires Erlang/OTP 28+)

> #### Only enable compression for trusted servers {: .info}
>
> The `decompress_body/1` step decompresses the whole response body into memory with no size
> limit, so a small response can expand into many gigabytes. A malicious or compromised server
> can exploit this to exhaust memory and crash the client (a decompression bomb / denial of
> service). For this reason compression is off by default; only set `compressed: true` for
> endpoints you trust.

## Request Options

  * `:compressed` - if set to `true`, sets the `accept-encoding` header with compression
    algorithms that Req supports and decompresses the response body. Defaults to `false`.

    This option has no effect when streaming the response body (`into: fun | collectable`).

## Examples

By default, Req does not ask for a compressed response. Pass `compressed: true` to request one
and have Req decompress the body, so we get back the decompressed content:

    iex> response = Req.get!("https://elixir-lang.org", compressed: true)
    iex> response.body |> binary_part(0, 15)
    "<!DOCTYPE html>"

To inspect the raw compressed bytes the server sent, additionally pass `raw: true`, which
disables decompression. Notice the body now starts with `<<31, 139>>`, the "magic bytes"
for gzip:

    iex> response = Req.get!("https://elixir-lang.org", compressed: true, raw: true)
    iex> Req.Response.get_header(response, "content-encoding")
    ["gzip"]
    iex> response.body |> binary_part(0, 2)
    <<31, 139>>

Zstandard is supported out of the box on Erlang/OTP 28+ (via the built-in `:zstd` module).
Brotli is supported if the optional [brotli] package is installed:

    Mix.install([
      :req,
      {:brotli, "~> 0.3.0"}
    ])

    response = Req.get!("https://httpbin.org/anything", compressed: true)
    response.body["headers"]["Accept-Encoding"]
    #=> "zstd, br, gzip"

[brotli]: https://hex.pm/packages/brotli

## encode_body/1

Encodes the request body.

## Request Options

  * `:form` - if set, encodes the request body as `application/x-www-form-urlencoded`
    (using `URI.encode_query/1`).

  * `:form_multipart` - if set, encodes the request body as `multipart/form-data`.

    It accepts `name` / `value` pairs. `value` can be one of:

      * integer (automatically encoded as string)

      * iodata

      * `File.Stream`

      * `Enumerable`

      * `{value, options}` tuple.

         `value` can be any of the values mentioned above.

         Supported options are: `:filename`, `:content_type`, and `:size`.

         When `value` is an `Enumerable`, option `:size` can be set with
         the binary size of the `value`. The size will be used to calculate
         and send the `content-length` header which might be required for
         some servers. There is no need to pass `:size` for `integer`,
         `iodata`, and `File.Stream` values as it's automatically calculated.

  * `:json` - if set, encodes the request body as JSON (using `Jason.encode_to_iodata!/1`), sets
    the `accept` header to `application/json`, and the `content-type` header to `application/json`.

When the request has the default HTTP method, GET, and the request body is set, this step
automatically changes HTTP method to POST.

## Examples

Encoding form (`application/x-www-form-urlencoded`):

    iex> Req.post!("https://httpbin.org/anything", form: [a: 1]).body["form"]
    %{"a" => "1"}

Encoding form (`multipart/form-data`):

    iex> fields = [a: 1, b: {"2", filename: "b.txt"}]
    iex> resp = Req.post!("https://httpbin.org/anything", form_multipart: fields)
    iex> resp.body["form"]
    %{"a" => "1"}
    iex> resp.body["files"]
    %{"b" => "2"}

Encoding streaming form (`multipart/form-data`):

    iex> stream = Stream.cycle(["abc"]) |> Stream.take(3)
    iex> fields = [file: {stream, filename: "b.txt"}]
    iex> resp = Req.post!("https://httpbin.org/anything", form_multipart: fields)
    iex> resp.body["files"]
    %{"file" => "abcabcabc"}

    # with explicit :size
    iex> stream = Stream.cycle(["abc"]) |> Stream.take(3)
    iex> fields = [file: {stream, filename: "b.txt", size: 9}]
    iex> resp = Req.post!("https://httpbin.org/anything", form_multipart: fields)
    iex> resp.body["files"]
    %{"file" => "abcabcabc"}

Encoding JSON:

    iex> Req.post!("https://httpbin.org/post", json: %{a: 1}).body["json"]
    %{"a" => 1}

Automatically change GET to POST when body is set:

    iex> Req.request!("https://httpbin.org/post", json: %{a: 1}).body["json"]
    %{"a" => 1}

## put_path_params/1

Uses a templated request path.

By default, params in the URL path are expressed as strings prefixed with `:`. For example,
`:code` in `https://httpbin.org/status/:code`. If you want to use the `{code}` syntax,
set `path_params_style: :curly`. Param names must start with a letter and can contain letters,
digits, and underscores; this is true both for `:colon_params` as well as `{curly_params}`.

Path params are replaced in the request URL path. The path params are specified as a keyword
list of parameter names and values, as in the examples below. The values of the parameters are
converted to strings using the `String.Chars` protocol (`to_string/1`).

## Request Options

  * `:path_params` - if set, params to add to the templated path. Defaults to `nil`.

  * `:path_params_style` (*available since v0.5.1*) - how path params are expressed. Can be one of:

       * `:colon` - (default) for Plug-style parameters, such as `:code` in
         `https://httpbin.org/status/:code`.

       * `:curly` - for [OpenAPI](https://swagger.io/specification/)-style parameters, such as
         `{code}` in `https://httpbin.org/status/{code}`.

## Examples

    iex> Req.get!("https://httpbin.org/status/:code", path_params: [code: 201]).status
    201

    iex> Req.get!("https://httpbin.org/status/{code}", path_params: [code: 201], path_params_style: :curly).status
    201

## put_params/1

Adds params to request query string.

## Request Options

  * `:params` - params to add to the request query string. Defaults to `[]`.

## Examples

    iex> Req.get!("https://httpbin.org/anything/query", params: [x: 1, y: 2]).body["args"]
    %{"x" => "1", "y" => "2"}

## put_range/1

Sets the "Range" request header.

## Request Options

  * `:range` - can be one of the following:

      * a string - returned as is

      * a `first..last` range - converted to `"bytes=<first>-<last>"`

## Examples

    iex> response = Req.get!("https://httpbin.org/range/100", range: 0..3)
    iex> response.status
    206
    iex> response.body
    "abcd"
    iex> Req.Response.get_header(response, "content-range")
    ["bytes 0-3/100"]

## compress_body/1

Compresses the request body.

## Request Options

  * `:compress_body` - if set to `true`, compresses the request body using gzip.
    Defaults to `false`.

## checksum/1

Sets expected response body checksum.

## Request Options

  * `:checksum` - if set, this is the expected response body checksum.

    Can be one of:

      * `"md5:(...)"`
      * `"sha1:(...)"`
      * `"sha256:(...)"`

## Examples

    iex> resp = Req.get!("https://httpbin.org/json", checksum: "sha1:9274ffd9cf273d4a008750f44540c4c5d4c8227c")
    iex> resp.status
    200

    iex> Req.get!("https://httpbin.org/json", checksum: "sha1:bad")
    ** (Req.ChecksumMismatchError) checksum mismatch
    expected: sha1:bad
    actual:   sha1:9274ffd9cf273d4a008750f44540c4c5d4c8227c

## put_aws_sigv4/1

Signs request with AWS Signature Version 4.

## Request Options

  * `:aws_sigv4` - if set, the AWS options to sign request:

      * `:access_key_id` - the AWS access key id.

      * `:secret_access_key` - the AWS secret access key.

      * `:token` - if set, the AWS security token, for example returned from AWS STS.

      * `:service` - the AWS service. We try to automatically detect the service (e.g.
        `s3.amazonaws.com` host sets service to `:s3`)

      * `:region` - the AWS region. Defaults to `"us-east-1"`.

      * `:datetime` - the request datetime, defaults to `DateTime.utc_now(:second)`.

    Additionally, it can be an `{mod, fun, args}` tuple that returns the above
    options.

## Examples

    iex> req =
    ...>   Req.new(
    ...>     base_url: "https://s3.amazonaws.com",
    ...>     aws_sigv4: [
    ...>       access_key_id: System.get_env("AWS_ACCESS_KEY_ID"),
    ...>       secret_access_key: System.get_env("AWS_SECRET_ACCESS_KEY")
    ...>     ]
    ...>   )
    iex>
    iex> %{status: 200} = Req.put!(req, url: "/bucket1/key1", body: "Hello, World!")
    iex> resp = Req.get!(req, url: "/bucket1/key1").body
    "Hello, World!"

Request body streaming also works though `content-length` header must be explicitly set:

    iex> path = "a.txt"
    iex> File.write!(path, String.duplicate("a", 100_000))
    iex> size = File.stat!(path).size
    iex> chunk_size = 10 * 1024
    iex> stream = File.stream!(path, chunk_size)
    iex> %{status: 200} = Req.put!(req, url: "/key1", headers: [content_length: size], body: stream)
    iex> byte_size(Req.get!(req, "/bucket1/key1").body)
    100_000

## verify_checksum/1

Verifies the response body checksum.

See `checksum/1` for more information.

## decompress_body/1

Decompresses the response body based on the `content-encoding` header.

This step only runs when the `:compressed` option is set to `true` (see the `compressed/1`
step); otherwise the body is left as is. This guards against decompression bombs, where a
small compressed response expands into a much larger body in memory.

This step is disabled on response body streaming. If response body is not a binary, in other
words it has been transformed by another step, it is left as is.

Supported formats:

| Format        | Decoder                                      |
| ------------- | -------------------------------------------- |
| gzip, x-gzip  | [`:zlib`](`:zlib`)                           |
| br            | [`:brotli`](`:brotli`) (requires [brotli])   |
| zstd          | [`:zstd`](`:zstd`) (requires Erlang/OTP 28+) |
| _other_       | Returns data as is                           |

This step updates the following headers to reflect the changes:

  * `content-encoding` is removed
  * `content-length` is removed

## Options

  * `:compressed` - if set to `true`, decompresses the response body. Defaults to `false`.
    See also the `compressed/1` step.

  * `:raw` - if set to `true`, disables response body decompression. Defaults to `false`.

    Note: setting `raw: true` also disables response body decoding in the `decode_body/1` step.

## Examples

    iex> response = Req.get!("https://httpbin.org/gzip", compressed: true)
    iex> response.body["gzipped"]
    true

If the [brotli] package is installed, Brotli is also supported:

    Mix.install([
      :req,
      {:brotli, "~> 0.3.0"}
    ])

    response = Req.get!("https://httpbin.org/brotli", compressed: true)
    Req.Response.get_header(response, "content-encoding")
    #=> ["br"]
    response.body["brotli"]
    #=> true

[brotli]: https://hex.pm/packages/brotli

## decode_body/1

Decodes response body based on the detected format.

By default, only JSON responses are decoded. To decode other formats, or to add support for
custom ones, use the `:decoders` option.

## Built-in decoders

| Format               | Decoder                                       |
| -------------------- | --------------------------------------------- |
| `:json`, `:json_api` | `Jason` (enabled by default)                  |
| `:zip`               | [`:zip`](`:zip`)                              |
| `:tar`, `:tgz`       | [`:erl_tar`](`:erl_tar`)                      |
| `:gz`                | [`:zlib`](`:zlib`)                            |
| `:zst`               | [`:zstd`](`:zstd`) (requires Erlang/OTP 28+)  |
| `:csv`               | `NimbleCSV.RFC4180` (requires [nimble_csv]) |

The format is determined by the response `content-type` header. See `MIME` for registering
content-type/format mapping.

This step is disabled on response body streaming. If response body is not a binary, in other
words it has been transformed by another step, it is left as is.

> #### Decompression Bombs {: .warning}
>
> The archive and compression decoders (`:zip`, `:tar`, `:tgz`, `:gz`, and `:zst`) decompress
> the whole response body into memory with no size limit, so a small response can expand to
> many gigabytes. For this reason they are **not** enabled by default; only opt into them via
> the `:decoders` option for endpoints you trust.

## Request Options

  * `:decoders` - the list of decoders to use. Defaults to `[:json, :json_api]`.

    Each element is either:

      * a format (atom) handled by a [built-in decoder](#decode_body/1-built-in-decoders),
        e.g. `:json` or `:zip`;

      * a `{format, codec}` tuple, where `format` is an atom and `codec` is one of:

          * another format (atom), to reuse a built-in decoder, e.g. `{:json5, :json}`;

          * a module exporting `decode/1` that returns `{:ok, term}` or `{:error, exception}`;

          * a 1-arity function that returns `{:ok, term}` or `{:error, exception}`.

    Setting `:decoders` replaces the default, so include `:json` if you still want JSON decoded:

        # handles json, zip, and tar:
        Req.new(decoders: [:json, :zip, :tar])

    Set `:decoders` to `false` to disable all decoding, including JSON. A custom decoder:

        Req.get!(url, decoders: [ics: &{:ok, ICal.from_ics(&1)}])

  * `:decode_body` - if set to `false`, disables automatic response body decoding.
    Defaults to `true`.

  * `:decode_json` - (deprecated) options to pass to `Jason.decode/2`. Deprecated in favour
    of passing a custom JSON decoder via the `:decoders` option, e.g.
    `decoders: [json: &Jason.decode(&1, keys: :atoms)]`.

  * `:raw` - if set to `true`, disables response body decoding. Defaults to `false`.

    Note: setting `raw: true` also disables response body decompression in the
    `decompress_body/1` step.

## Examples

Decode JSON:

    iex> response = Req.get!("https://httpbin.org/json")
    ...> response.body["slideshow"]["title"]
    "Sample Slide Show"

Decode a ZIP archive (opt-in):

    iex> response = Req.get!("https://example.com/archive.zip", decoders: [:zip])
    ...> response.body["file.txt"]
    "contents"

[nimble_csv]: https://hex.pm/packages/nimble_csv

## redirect/1

Follows redirects.

The original request method may be changed to GET depending on the status code:

| Code          | Method handling    |
| ------------- | ------------------ |
| 301, 302, 303 | Changed to GET     |
| 307, 308      | Method not changed |

## Request Options

  * `:redirect` - if set to `false`, disables automatic response redirects.
    Defaults to `true`.

  * `:redirect_trusted` - by default, authorization credentials are only sent
    on redirects with the same host, scheme and port. If `:redirect_trusted` is set
    to `true`, credentials will be sent to any host.

  * `:redirect_log_level` - the log level to emit redirect logs at. Can also be set
    to `false` to disable logging these messages. Defaults to `:debug`.

  * `:max_redirects` - the maximum number of redirects, defaults to `10`. If the
    limit is reached, the pipeline is halted and a `Req.TooManyRedirectsError`
    exception is returned.

## Examples

    iex> Req.get!("http://api.github.com").status
    # 23:24:11.670 [debug] redirecting to https://api.github.com/
    200

    iex> Req.get!("https://httpbin.org/redirect/4", max_redirects: 3)
    # 23:07:59.570 [debug] redirecting to /relative-redirect/3
    # 23:08:00.068 [debug] redirecting to /relative-redirect/2
    # 23:08:00.206 [debug] redirecting to /relative-redirect/1
    ** (RuntimeError) too many redirects (3)

    iex> Req.get!("http://api.github.com", redirect_log_level: false)
    200

    iex> Req.get!("http://api.github.com", redirect_log_level: :error)
    # 23:24:11.670 [error]  redirecting to https://api.github.com/
    200

## handle_http_errors/1

Handles HTTP 4xx/5xx error responses.

## Request Options

  * `:http_errors` - how to handle HTTP 4xx/5xx error responses. Can be one of the following:

    * `:return` (default) - return the response

    * `:raise` - raise an error

## Examples

    iex> Req.get!("https://httpbin.org/status/404").status
    404

    iex> Req.get!("https://httpbin.org/status/404", http_errors: :raise)
    ** (RuntimeError) The requested URL returned error: 404
    Response body: ""

## handle_http_digest/1

Handles HTTP Digest authentication.

This step is invoked when setting `:auth` option with `{:digest, ...}`. When response is HTTP 401 with `www-authenticate` header, this step will calculate `authorization: Digest ...` header and make another request.

See `auth/1`.

## Examples

    iex> resp = Req.get!("https://httpbin.org/digest-auth/auth/user/pass", auth: {:digest, "user:pass"})
    iex> resp.status
    200

## retry/1

Retries a request in face of errors.

This function can be used as either or both response and error step.

## Request Options

  * `:retry` - can be one of the following:

      * `:safe_transient` (default) - retry safe (GET/HEAD) requests on one of:

          * HTTP 408/429/500/502/503/504 responses

          * `Req.TransportError` with `reason: :timeout | :econnrefused | :closed`

          * `Req.HTTPError` with `protocol: :http2, reason: :unprocessed | :pool_not_available`

      * `:transient` - same as `:safe_transient` except retries all HTTP methods (POST, DELETE, etc.)

      * `fun` - a 2-arity function that accepts a `Req.Request` and either a `Req.Response` or an exception struct
        and returns one of the following:

          * `true` - retry with the default delay controller by default delay option described below.

          * `{:delay, milliseconds}` - retry with the given delay.

          * `false/nil` - don't retry.

      * `false` - don't retry.

  * `:retry_delay` - if not set, which is the default, the retry delay is determined by
    the value of the `Retry-After` header on HTTP 429/503 responses. If the header is not set,
    or the header value is negative, the default delay follows a simple exponential backoff
    with jitter, for example: 0.949s, 1.97s, 3.87s, 7.55s, ...

    `:retry_delay` can be set to a function that receives the retry count (starting at 0)
    and returns the delay, the number of milliseconds to sleep before making another attempt.

  * `:retry_log_level` - the log level to emit retry logs at. Can also be set to `false` to disable
    logging these messages. Defaults to `:warning`.

  * `:max_retries` - maximum number of retry attempts, defaults to `3` (for a total of `4`
    requests to the server, including the initial one.)

## Examples

    iex> Req.get!("https://httpbin.org/status/500,200").status
    # 08:43:19.101 [warning] retry: got response with status 500, will retry in 941ms, 2 attempts left
    # 08:43:22.958 [warning] retry: got response with status 500, will retry in 1877ms, 1 attempt left
    200