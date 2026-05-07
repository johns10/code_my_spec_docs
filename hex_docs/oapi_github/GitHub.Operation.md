# GitHub.Operation

Defines a struct that tracks client requests

> #### Note {:.info}
>
> This module is unlikely to be used directly by applications. Instead, functions in this module
> are useful for plugins. See `GitHub.Plugin` for more information.

## Fields

  * `private` (map): This field is useful for plugins that need to store information. Plugins
    should be careful to namespace their data to avoid overlap. By default, this map will include
    an `__auth__` key with the auth credentials used for the request, `__info__` containing the
    information that originated the request, and `__opts__` containing all of the options passed
    in to the original operation function.

  * `request_body` (term): For requests that support request bodies, this key will hold the data
    to be included in an outgoing request. Depending on the plugins involved, this key may have
    Elixir terms (like a map) or strings (such as a JSON-encoded string).

  * `request_headers` (list of headers): HTTP headers to be included in the outgoing request.
    These are specified as tuples with the name of the header and its value.

  * `request_method` (atom): HTTP verb of the outgoing request.

  * `request_params` (keyword): URL-based query parameters for the outgoing request.

  * `request_server` (string): URL scheme and hostname of the API server for the request.

  * `request_types` (list of types): OpenAPI type specifications for the request body. These are
    specified as tuples with the Content-Type and the type specification.

  * `request_url` (string): URL path of the outgoing request.

  * `response_body` (term): For responses that include response bodies, this key will hold the
    data from the response. Depending on the plugins involved, this key may have raw response data
    (such as a JSON-encoded string) or Elixir terms (like a map).

  * `response_code` (integer): Response status code.

  * `response_headers` (list of headers): HTTP headers from the response. These are specified as
    tuples with the name of the header and its value.

  * `response_types` (list of types): OpenAPI type specifications for the response body. These are
    specified as tuples with the status code and the type specification.

## get_caller(operation)

Get the client's calling function and original arguments

This level of introspection is meant for testing purposes, although other plugins can take
advantage of it as necessary.

## get_options(operation)

Get the options passed to the client request

## Examples

    iex> operation = %Operation{private: %{__opts__: [server: "https://api.github.com"]}}
    iex> Operation.get_options(operation)
    [server: "https://api.github.com"]

## get_response_header(operation, header)

Get the value of a response header

If response headers have not been filled in — or the response did not have the given header —
then `nil` will be returned.

## Examples

    iex> operation = %Operation{response_headers: [{"Content-Type", "application/json"}]}
    iex> Operation.get_response_header(operation, "Content-Type")
    "application/json"

    iex> operation = %Operation{response_headers: []}
    iex> Operation.get_response_header(operation, "ETag")
    nil

## put_private(operation, key, value)

Put information in the operation's private data store

Existing data with the same key will be overridden.

## Example

    iex> operation = %Operation{private: %{}}
    iex> operation = Operation.put_private(operation, :my_plugin_data, "abc123")
    %Operation{private: %{my_plugin_data: "abc123"}} = operation

## put_request_header(operation, header, value)

Add a request header to an outgoing operation

This function makes no effort to deduplicate headers.

## Example

    iex> operation = %Operation{request_headers: []}
    iex> operation = Operation.put_request_header(operation, "Content-Type", "application/json")
    %Operation{request_headers: [{"Content-Type", "application/json"}]} = operation

## type/0

Type annotation produced by [OpenAPI](https://github.com/aj-foster/open-api-generator)

## t/0

Operation struct for tracking client requests from start to finish