# Mint.HTTP1

Process-less HTTP/1.1 client connection.

This module provides a data structure that represents an HTTP/1 or HTTP/1.1 connection to
a given server. The connection is represented as an opaque struct `%Mint.HTTP1{}`.
The connection is a data structure and is not backed by a process, and all the
connection handling happens in the process that creates the struct.

This module and data structure work exactly like the ones described in the `Mint`
module, with the exception that `Mint.HTTP1` specifically deals with HTTP/1 and HTTP/1.1 while
`Mint` deals seamlessly with HTTP/1, HTTP/1.1, and HTTP/2. For more information on
how to use the data structure and client architecture, see `Mint`.

## close(conn)

See `Mint.HTTP.close/1`.

## connect(scheme, address, port, opts \\ [])

Same as `Mint.HTTP.connect/4`, but forces an HTTP/1 or HTTP/1.1 connection.

This function doesn't support proxying.

## Additional Options

  * `:case_sensitive_headers` - (boolean) if set to `true` the case of the supplied
     headers in requests will be preserved. The default is to lowercase the headers
     because HTTP/1.1 header names are case-insensitive. *Available since v1.6.0*.
  * `:skip_target_validation` - (boolean) if set to `true` the target of a request
     will not be validated. You might want this if you deal with non standard-
     conforming URIs but need to preserve them. The default is to validate the request
     target. *Available since v1.7.0*.

## controlling_process(conn, new_pid)

See `Mint.HTTP.controlling_process/2`.

## delete_private(conn, key)

See `Mint.HTTP.delete_private/2`.

## get_private(conn, key, default \\ nil)

See `Mint.HTTP.get_private/3`.

## get_proxy_headers(http1)

See `Mint.HTTP.get_proxy_headers/1`.

## get_socket(conn)

See `Mint.HTTP.get_socket/1`.

## open?(conn, type \\ :write)

See `Mint.HTTP.open?/1`.

## open_request_count(conn)

See `Mint.HTTP.open_request_count/1`.

In HTTP/1, the number of open requests is the number of pipelined requests.

## put_log(conn, log?)

See `Mint.HTTP.put_log/2`.

## put_private(conn, key, value)

See `Mint.HTTP.put_private/3`.

## recv(conn, byte_count, timeout)

See `Mint.HTTP.recv/3`.

## request(conn, method, path, headers, body)

See `Mint.HTTP.request/5`.

In HTTP/1 and HTTP/1.1, you can't open a new request if you're streaming the body of
another request. If you try, an error will be returned.

## set_mode(conn, mode)

See `Mint.HTTP.set_mode/2`.

## stream(conn, message)

See `Mint.HTTP.stream/2`.

## stream_request_body(conn, ref, body)

See `Mint.HTTP.stream_request_body/3`.

In HTTP/1, sending an empty chunk is a no-op.

## Transfer encoding and content length

When streaming the request body, Mint cannot send a precalculated `content-length`
request header because it doesn't know the body that you'll stream. However, Mint
will transparently handle the presence of a `content-length` header using this logic:

  * if you specifically set a `content-length` header, then transfer encoding and
    making sure the content length is correct for what you'll stream is up to you.

  * if you specifically set the transfer encoding (`transfer-encoding` header)
    to `chunked`, then it's up to you to
    [properly encode chunks](https://en.wikipedia.org/wiki/Chunked_transfer_encoding).

  * if you don't set the transfer encoding to `chunked` and don't provide a
    `content-length` header, Mint will do implicit `chunked` transfer encoding
    (setting the `transfer-encoding` header appropriately) and will take care
    of properly encoding the chunks.

## error_reason/0

An HTTP/1-specific error reason.

The values can be:

  * `:closed` - when you try to make a request or stream a body chunk but the connection
    is closed.

  * `:request_body_is_streaming` - when you call `request/5` to send a new
    request but another request is already streaming.

  * `{:unexpected_data, data}` - when unexpected data is received from the server.

  * `:invalid_status_line` - when the HTTP/1 status line is invalid.

  * `{:invalid_request_target, target}` - when the request target is invalid.

  * `:invalid_header` - when headers can't be parsed correctly.

  * `{:invalid_header_name, name}` - when a header name is invalid.

  * `{:invalid_header_value, name, value}` - when a header value is invalid. `name`
    is the name of the header and `value` is the invalid value.

  * `:invalid_chunk_size` - when the chunk size is invalid.

  * `:missing_crlf_after_chunk` - when the CRLF after a chunk is missing.

  * `:invalid_trailer_header` - when trailer headers can't be parsed.

  * `:more_than_one_content_length_header` - when more than one `content-length`
    headers are in the response.

  * `:transfer_encoding_and_content_length` - when both the `content-length` as well
    as the `transfer-encoding` headers are in the response.

  * `{:invalid_content_length_header, value}` - when the value of the `content-length`
    header is invalid, that is, is not an non-negative integer.

  * `:empty_token_list` - when a header that is supposed to contain a list of tokens
    (such as the `connection` header) doesn't contain any.

  * `{:invalid_token_list, string}` - when a header that is supposed to contain a list
    of tokens (such as the `connection` header) contains a malformed list of tokens.

  * `:trailing_headers_but_not_chunked_encoding` - when you try to send trailer
    headers through `stream_request_body/3` but the transfer encoding of the request
    was not `chunked`.

## t/0

A Mint HTTP/1 connection struct.

The struct's fields are private.