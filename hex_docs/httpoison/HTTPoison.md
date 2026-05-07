# HTTPoison

The HTTP client for Elixir.

The `HTTPoison` module can be used to issue HTTP requests and parse HTTP responses to arbitrary URLs.

    iex> HTTPoison.get!("https://api.github.com")
    %HTTPoison.Response{status_code: 200,
                        headers: [{"content-type", "application/json"}],
                        body: "{...}"}

It's very common to use HTTPoison in order to wrap APIs, which is when the
`HTTPoison.Base` module shines. Visit the documentation for `HTTPoison.Base`
for more information.

Under the hood, the `HTTPoison` module just uses `HTTPoison.Base` (as
described in the documentation for `HTTPoison.Base`) without overriding any
default function.

See `request/5` for more details on how to issue HTTP requests

## delete(url, headers \\ [], options \\ [])

Issues a DELETE request to the given url.

Returns `{:ok, response}` if the request is successful, `{:error, reason}`
otherwise.

See `request/5` for more detailed information.

## delete!(url, headers \\ [], options \\ [])

Issues a DELETE request to the given url, raising an exception in case of
failure.

If the request does not fail, the response is returned.

See `request!/5` for more detailed information.

## get(url, headers \\ [], options \\ [])

Issues a GET request to the given url.

Returns `{:ok, response}` if the request is successful, `{:error, reason}`
otherwise.

See `request/5` for more detailed information.

## get!(url, headers \\ [], options \\ [])

Issues a GET request to the given url, raising an exception in case of
failure.

If the request does not fail, the response is returned.

See `request!/5` for more detailed information.

## head(url, headers \\ [], options \\ [])

Issues a HEAD request to the given url.

Returns `{:ok, response}` if the request is successful, `{:error, reason}`
otherwise.

See `request/5` for more detailed information.

## head!(url, headers \\ [], options \\ [])

Issues a HEAD request to the given url, raising an exception in case of
failure.

If the request does not fail, the response is returned.

See `request!/5` for more detailed information.

## options(url, headers \\ [], options \\ [])

Issues an OPTIONS request to the given url.

Returns `{:ok, response}` if the request is successful, `{:error, reason}`
otherwise.

See `request/5` for more detailed information.

## options!(url, headers \\ [], options \\ [])

Issues a OPTIONS request to the given url, raising an exception in case of
failure.

If the request does not fail, the response is returned.

See `request!/5` for more detailed information.

## patch(url, body, headers \\ [], options \\ [])

Issues a PATCH request to the given url.

Returns `{:ok, response}` if the request is successful, `{:error, reason}`
otherwise.

See `request/5` for more detailed information.

## patch!(url, body, headers \\ [], options \\ [])

Issues a PATCH request to the given url, raising an exception in case of
failure.

If the request does not fail, the response is returned.

See `request!/5` for more detailed information.

## post(url, body, headers \\ [], options \\ [])

Issues a POST request to the given url.

Returns `{:ok, response}` if the request is successful, `{:error, reason}`
otherwise.

See `request/5` for more detailed information.

## post!(url, body, headers \\ [], options \\ [])

Issues a POST request to the given url, raising an exception in case of
failure.

If the request does not fail, the response is returned.

See `request!/5` for more detailed information.

## put(url, body \\ "", headers \\ [], options \\ [])

Issues a PUT request to the given url.

Returns `{:ok, response}` if the request is successful, `{:error, reason}`
otherwise.

See `request/5` for more detailed information.

## put!(url, body \\ "", headers \\ [], options \\ [])

Issues a PUT request to the given url, raising an exception in case of
failure.

If the request does not fail, the response is returned.

See `request!/5` for more detailed information.

## request(request)

Issues an HTTP request using an `HTTPoison.Request` struct.

This function returns `{:ok, response}`, `{:ok, async_response}`, or `{:ok, maybe_redirect}`
if the request is successful, `{:error, reason}` otherwise.

## Redirect handling

If the option `:follow_redirect` is given, HTTP redirects are automatically follow if
the method is set to `:get` or `:head` and the response's `status_code` is `301`, `302` or
`307`.

If the method is set to `:post`, then the only `status_code` that gets automatically
followed is `303`.

If any other method or `status_code` is returned, then this function
returns a `{:ok, %HTTPoison.MaybeRedirect{}}` containing the `redirect_url` for you to
re-request with the method set to `:get`.

## Examples

    request = %HTTPoison.Request{
      method: :post,
      url: "https://my.website.com",
      body: "{\"foo\": 3}",
      headers: [{"Accept", "application/json"}]
    }

    request(request)

## request(method, url, body \\ "", headers \\ [], options \\ [])

Issues an HTTP request with the given method to the given url.

This function is usually used indirectly by `get/3`, `post/4`, `put/4`, etc

Args:
  * `method` - HTTP method as an atom (`:get`, `:head`, `:post`, `:put`,
    `:delete`, etc.)
  * `url` - target url as a binary string or char list
  * `body` - request body. See more below
  * `headers` - HTTP headers as an orddict (e.g., `[{"Accept", "application/json"}]`)
  * `options` - Keyword list of options

Body: see type `HTTPoison.Request`

Options: see type `HTTPoison.Request`

This function returns `{:ok, response}`, `{:ok, async_response}`, or `{:ok, maybe_redirect}`
if the request is successful, `{:error, reason}` otherwise.

## Redirect handling

If the option `:follow_redirect` is given, HTTP redirects are automatically follow if
the method is set to `:get` or `:head` and the response's `status_code` is `301`, `302` or
`307`.

If the method is set to `:post`, then the only `status_code` that gets automatically
followed is `303`.

If any other method or `status_code` is returned, then this function returns a
returns a `{:ok, %HTTPoison.MaybeRedirect{}}` containing the `redirect_url` for you to
re-request with the method set to `:get`.

## Examples

    request(:post, "https://my.website.com", "{\"foo\": 3}", [{"Accept", "application/json"}])

## request!(request)

Issues an HTTP request an `HTTPoison.Request` struct.
exception in case of failure.

`request!/1` works exactly like `request/1` but it returns just the
response in case of a successful request, raising an exception in case the
request fails.

## request!(method, url, body \\ "", headers \\ [], options \\ [])

Issues an HTTP request with the given method to the given url, raising an
exception in case of failure.

`request!/5` works exactly like `request/5` but it returns just the
response in case of a successful request, raising an exception in case the
request fails.

## start()

Starts HTTPoison and its dependencies.

## stream_next(resp)

Requests the next message to be streamed for a given `HTTPoison.AsyncResponse`.

See `request!/5` for more detailed information.