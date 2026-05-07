# Req.Request

The low-level API and the request struct.

Req is composed of:

  * `Req` - the high-level API

  * `Req.Request` - the low-level API and the request struct (you're here!)

  * `Req.Steps` - the collection of built-in steps

  * `Req.Test` - the testing conveniences

The low-level API and the request struct is the foundation of Req's extensibility. Virtually all
of the functionality is broken down into individual pieces - steps. Req works by running the
request struct through these steps. You can easily reuse or rearrange built-in steps or write new
ones.

To make using custom steps by others even easier, they can be packaged up into plugins.
See ["Writing Plugins"](#module-writing-plugins) section for more information.

## The Low-level API

Most Req users would use it like this:

    Req.get!("https://api.github.com/repos/wojtekmach/req").body["description"]
    #=> "Req is a batteries-included HTTP client for Elixir."

Here is the equivalent using the low-level API:

    url = "https://api.github.com/repos/wojtekmach/req"

    req =
      Req.Request.new(method: :get, url: url)
      |> Req.Request.append_request_steps(
        put_user_agent: &Req.Steps.put_user_agent/1,
        # ...
      )
      |> Req.Request.append_response_steps(
        # ...
        decompress_body: &Req.Steps.decompress_body/1,
        decode_body: &Req.Steps.decode_body/1,
        # ...
      )
      |> Req.Request.append_error_steps(
        retry: &Req.Steps.retry/1,
        # ...
      )

    {req, resp} = Req.Request.run_request(req)
    resp.body["description"]
    #=> "Req is a batteries-included HTTP client for Elixir."

By putting the request pipeline yourself you have precise control of exactly what is running and in what order.

## The Request Struct

Public fields are:

  * `:method` - the HTTP request method.

  * `:url` - the HTTP request URL.

  * `:headers` - the HTTP request headers. The header names should be downcased.
    See also "Headers" section in `Req` module documentation.

  * `:body` - the HTTP request body.

    Can be one of:

      * `iodata` - eagerly send request body

      * `enumerable` - stream request body

  * `:into` - where to send the response body. It can be one of:

      * `nil` - (default) read the whole response body and store it in the `response.body`
        field.

      * `fun` - stream response body using a function. The first argument is a `{:data, data}`
        tuple containing the chunk of the response body. The second argument is a
        `{request, response}` tuple. To continue streaming chunks, return `{:cont, {req, resp}}`.
        To cancel, return `{:halt, {req, resp}}`. For example:

            into: fn {:data, data}, {req, resp} ->
              IO.puts(data)
              {:cont, {req, resp}}
            end

      * `collectable` - stream response body into a `t:Collectable.t/0`. For example:

            into: File.stream!("path")

        Note that the collectable is only used, if the response status is 200. In other cases,
        the body is accumulated and processed as usual.

  * `:options` - the options to be used by steps. The exact representation of options is private.
    Calling `request.options[key]`, `put_in(request.options[key], value)`, and
    `update_in(request.options[key], fun)` is allowed. `get_option/3` and `delete_option/2`
    are also available for additional ways to manipulate the internal representation.

  * `:halted` - whether the request pipeline is halted. See `halt/2`.

  * `:adapter` - a request step that makes the actual HTTP request. Defaults to
    `Req.Steps.run_finch/1`. See ["Adapter"](#module-adapter) section below for more information.

  * `:request_steps` - the list of request steps

  * `:response_steps` - the list of response steps

  * `:error_steps` - the list of error steps

  * `:private` - a map reserved for libraries and frameworks to use.
    The keys must be atoms. Prefix the keys with the name of your project
    to avoid any future conflicts. The `req_` prefix is reserved for Req.

## Steps

Req has three types of steps: request, response, and error.

Request steps are used to refine the data that will be sent to the server.

After making the actual HTTP request, we'll either get a HTTP response or an error.
The request, along with the response or error, will go through response or
error steps, respectively.

Nothing is actually executed until we run the pipeline with `Req.Request.run_request/1`.

### Request Steps

A **request step** (`t:request_step/0`) is a function that accepts a `request` and returns one
of the following:

  * A `request`.

  * A `{request, response_or_error}` tuple. In this case no further request steps are executed
    and the return value goes through response or error steps.

#### Examples

A request step that adds a `user-agent` header if it's not there already:

    def put_default_headers(request) do
      Req.Request.put_new_header(request, "user-agent", "req")
    end

The next is a request step that reads the response from cache if available. Note how, if the
cached response is available, this step returns a `{request, response}` tuple so that the
request doesn't actually go through:

    def read_from_cache(request) do
      case ResponseCache.fetch(request) do
        {:ok, response} -> {request, response}
        :error -> request
      end
    end

### Response and Error Steps

A response step (`t:response_step/0`) is a function that accepts a `{request, response}` tuple
and returns one of the following:

  * A `{request, response}` tuple.

  * A `{request, exception}` tuple. In that case, no further response steps are executed but the
    exception goes through error steps.

Similarly, an error step is a function that accepts a `{request, exception}` tuple and returns one
of the following:

  * A `{request, exception}` tuple

  * A `{request, response}` tuple. In that case, no further error steps are executed but the
    response goes through response steps.

Examples:

    def decode({request, response}) do
      case Req.Response.get_header(response, "content-type") do
        ["application/json" <> _] ->
          {request, update_in(response.body, &Jason.decode!/1)}

        [] ->
          {request, response}
      end
    end

    def log_error({request, exception}) do
      Logger.error(["#{request.method} #{request.uri}: ", Exception.message(exception)])
      {request, exception}
    end

### Halting

Any step can call `halt/2` to halt the pipeline. This prevents any further steps
from being invoked.

Examples:

    def circuit_breaker(request) do
      if CircuitBreaker.open?() do
        Req.Request.halt(request, RuntimeError.exception("circuit breaker is open"))
      else
        request
      end
    end

## Writing Plugins

Custom steps can be packaged into plugins so that they are even easier to use by others.

Here's an example plugin:

    defmodule PrintHeaders do
      @doc """
      Prints request and response headers.

      ## Request Options

        * `:print_headers` - if `true`, prints the headers. Defaults to `false`.

      """
      def attach(%Req.Request{} = request, options \\ []) do
        request
        |> Req.Request.register_options([:print_headers])
        |> Req.Request.merge_options(options)
        |> Req.Request.append_request_steps(print_headers: &print_request_headers/1)
        |> Req.Request.prepend_response_steps(print_headers: &print_response_headers/1)
      end

      defp print_request_headers(request) do
        if request.options[:print_headers] do
          print_headers("> ", request.headers)
        end

        request
      end

      defp print_response_headers({request, response}) do
        if request.options[:print_headers] do
          print_headers("< ", response.headers)
        end

        {request, response}
      end

      defp print_headers(prefix, headers) do
        for {name, value} <- headers do
          IO.puts([prefix, name, ": ", value])
        end
      end
    end

And here is how we can use it:

    req = Req.new() |> PrintHeaders.attach()

    Req.get!(req, url: "https://httpbin.org/json").status
    200

    Req.get!(req, url: "https://httpbin.org/json", print_headers: true).status
    # Outputs:
    # > accept-encoding: br, gzip
    # > user-agent: req/0.3.0-dev
    # < date: Wed, 11 May 2022 11:10:47 GMT
    # < content-type: application/json
    # ...
    200

    req = Req.new() |> PrintHeaders.attach(print_headers: true)
    Req.get!(req, url: "https://httpbin.org/json").status
    # Outputs:
    # > accept-encoding: br, gzip
    # ...
    200

As you can see a plugin is simply a module. While this is not enforced, the plugin should follow
these conventions:

  * It should export an `attach/1` function that takes and returns the request struct

  * The attach functions mostly just adds steps and it is the steps that do the actual work

  * A user should be able to attach your plugin alongside other plugins. For this reason,
    plugin functionality should usually only happen on a specific "trigger": on a specific
    option, on a specific URL scheme or host, etc. This is especially important for plugins
    that perform authentication; you don't want to accidentally expose a token from service A
    when a user makes request to service B.

  * If your plugin supports custom options, register them with `register_options/2`

  * Sometimes it is useful to pass options when attaching the plugin. For that, export an
    `attach/2` function and call `merge_options/2`. Remember to first register
    options before merging!

## Adapter

As noted in the ["Request Steps"](#module-request-steps) section, a request step besides returning the request,
might also return `{request, response}` or `{request, exception}`, thus invoking either response or error steps next.
This is exactly how Req makes the underlying HTTP call, by invoking a request step that follows this contract.

The default adapter is using Finch via the `Req.Steps.run_finch/1` step.

Here is a mock adapter that always returns a successful response:

    adapter = fn request ->
      response = %Req.Response{status: 200, body: "it works!"}
      {request, response}
    end

    Req.request!(url: "http://example", adapter: adapter).body
    #=> "it works!"

Here is another one that uses the `Req.Response.json/2` function to conveniently
return a JSON response:

    adapter = fn request ->
      response = Req.Response.json(%{hello: 42})
      {request, response}
    end

    resp = Req.request!(url: "http://example", adapter: adapter)
    resp.headers
    #=> [{"content-type", "application/json"}]
    resp.body
    #=> %{"hello" => 42}

And here is a naive Hackney-based adapter:

    hackney = fn request ->
      case :hackney.request(
             request.method,
             URI.to_string(request.url),
             request.headers,
             request.body,
             [:with_body]
           ) do
        {:ok, status, headers, body} ->
          headers = for {name, value} <- headers, do: {String.downcase(name, :ascii), value}
          response = %Req.Response{status: status, headers: headers, body: body}
          {request, response}

        {:error, reason} ->
          {request, RuntimeError.exception(inspect(reason))}
      end
    end

    Req.get!("https://api.github.com/repos/wojtekmach/req", adapter: hackney).body["description"]
    #=> "Req is a batteries-included HTTP client for Elixir."

## append_error_steps(request, steps)

Appends **error steps** to the existing error steps.

See the ["Response and Error Steps"](#module-response-and-error-steps) section in the
module documentation for more information.

## Examples

    Req.Request.append_error_steps(request,
      noop: fn {request, exception} -> {request, exception} end,
      inspect: &IO.inspect/1
    )

## append_request_steps(request, steps)

Appends **request steps** to the existing request steps.

See the ["Request Steps"](#module-request-steps) section in the module documentation
for more information.

## Examples

    Req.Request.append_request_steps(request,
      noop: fn request -> request end,
      inspect: &IO.inspect/1
    )

## append_response_steps(request, steps)

Appends **response steps** to the existing response steps.

See the ["Response and Error Steps"](#module-response-and-error-steps) section in the
module documentation for more information.

## Examples

    Req.Request.append_response_steps(request,
      noop: fn {request, response} -> {request, response} end,
      inspect: &IO.inspect/1
    )

## delete_header(request, name)

Deletes the header given by `name`.

All occurrences of the header are deleted, in case the header is repeated multiple times.

See also "Headers" section in `Req` module documentation.

## Examples

    iex> Req.Request.get_header(req, "cache-control")
    ["max-age=600", "no-transform"]
    iex> req = Req.Request.delete_header(req, "cache-control")
    iex> Req.Request.get_header(req, "cache-control")
    []

## delete_option(request, key)

Deletes the given option `key`.

## Examples

    iex> req = Req.Request.new(options: [a: 1])
    iex> Req.Request.get_option(req, :a)
    1
    iex> req = Req.Request.delete_option(req, :a)
    iex> Req.Request.get_option(req, :a)
    nil

## drop_options(request, keys)

Drops the given `keys` from options.

## Examples

    iex> req = Req.Request.new(options: [a: 1, b: 2, c: 3])
    iex> req = Req.Request.drop_options(req, [:a, :b])
    iex> Req.Request.get_option(req, :a)
    nil
    iex> Req.Request.get_option(req, :c)
    3

## fetch_option(request, key)

Fetches the value for the option `key`.

See also `get_option/3`.

## Examples

    iex> req = Req.Request.new(options: [a: 1])
    iex> Req.Request.fetch_option(req, :a)
    {:ok, 1}
    iex> Req.Request.fetch_option(req, :b)
    :error

## fetch_option!(request, key)

Fetches the value for the option `key` or raises if it's not set.

See also `get_option/3`.

## Examples

    iex> req = Req.Request.new(options: [a: 1])
    iex> Req.Request.fetch_option!(req, :a)
    1
    iex> Req.Request.fetch_option!(req, :b)
    ** (KeyError) option :b is not set

## get_header(req, name)

Returns the values of the header specified by `name`.

See also "Headers" section in `Req` module documentation.

## Examples

    iex> req = Req.new(headers: [{"accept", "application/json"}])
    iex> Req.Request.get_header(req, "accept")
    ["application/json"]
    iex> Req.Request.get_header(req, "x-unknown")
    []

## get_option(request, key, default \\ nil)

Gets the value for the option `key`.

See also `fetch_option!/2`.

## Examples

    iex> req = Req.Request.new(options: [a: 1])
    iex> Req.Request.get_option(req, :a)
    1
    iex> Req.Request.get_option(req, :b)
    nil
    iex> Req.Request.get_option(req, :b, 0)
    0

## get_option_lazy(request, key, fun)

Gets the value for the option `key`.

This is useful if the default value is very expensive to calculate or generally
difficult to setup and teardown again.

See also `get_option/3`.

## Examples

    iex> req = Req.Request.new(options: [a: 1])
    iex> fun = fn ->
    ...>   # some expensive operation here
    ...>   42
    ...> end
    iex> Req.Request.get_option_lazy(req, :a, fun)
    1
    iex> Req.Request.get_option_lazy(req, :b, fun)
    42

## get_private(request, key, default \\ nil)

Gets the value for a specific private `key`.

## halt(request, response_or_exception)

Halts the request pipeline preventing any further steps from executing.

This function returns an updated request and the response or exception that caused the halt.
It's perfect when used in a request step to stop the pipeline.

See the ["Halting"](#module-halting) section in the module documentation for more information.

## Examples

    Req.Request.prepend_request_steps(request, circuit_breaker: fn request ->
      if CircuitBreaker.open?() do
        Req.Request.halt(request, RuntimeError.exception("circuit breaker is open"))
      else
        request
      end
    end)

## merge_new_options(request, options)

Merges given options into the request unless they are already set.

## Examples

    iex> req = Req.new(auth: {:basic, "alice:secret"})
    iex> req.options
    %{auth: {:basic, "alice:secret"}}
    iex> req = Req.Request.merge_new_options(req, auth: {:bearer, "abcd"}, base_url: "https://example.com")
    iex> req.options
    %{auth: {:basic, "alice:secret"}, base_url: "https://example.com"}

    iex> req = Req.new()
    iex> Req.Request.merge_new_options(req, foo: :bar)
    ** (ArgumentError) unknown option :foo

## merge_options(request, options)

Merges given options into the request.

## Examples

    iex> req = Req.new(auth: {:basic, "alice:secret"}, http_errors: :raise)
    iex> req = Req.Request.merge_options(req, auth: {:bearer, "abcd"}, base_url: "https://example.com")
    iex> req.options[:auth]
    {:bearer, "abcd"}
    iex> req.options[:http_errors]
    :raise
    iex> req.options[:base_url]
    "https://example.com"

## new(options \\ [])

Returns a new request struct.

## Options

  * `:method` - the request method, defaults to `:get`.

  * `:url` - the request URL.

  * `:headers` - the request headers, defaults to `[]`.

  * `:body` - the request body, defaults to `nil`.

  * `:adapter` - the request adapter, defaults to calling [`run_finch`](`Req.Steps.run_finch/1`).

## Examples

    iex> req = Req.Request.new(url: "https://api.github.com/repos/wojtekmach/req")
    iex> {req, resp} = Req.Request.run_request(req)
    iex> req.url.host
    "api.github.com"
    iex> resp.status
    200

## prepend_error_steps(request, steps)

Prepends **error steps** to the existing error steps.

See the ["Response and Error Steps"](#module-response-and-error-steps) section in the
module documentation for more information.

## Examples

    Req.Request.prepend_error_steps(request,
      noop: fn {request, exception} -> {request, exception} end,
      inspect: &IO.inspect/1
    )

## prepend_request_steps(request, steps)

Prepends **request steps** to the existing request steps.

See the ["Request Steps"](#module-request-steps) section in the module documentation
for more information.

## Examples

    Req.Request.prepend_request_steps(request,
      noop: fn request -> request end,
      inspect: &IO.inspect/1
    )

## prepend_response_steps(request, steps)

Prepends **response steps** to the existing response steps.

See the ["Response and Error Steps"](#module-response-and-error-steps) section in the
module documentation for more information.

## Examples

    Req.Request.prepend_response_steps(request,
      noop: fn {request, response} -> {request, response} end,
      inspect: &IO.inspect/1
    )

## put_header(request, name, value)

Sets the header `name` to `value`.

The value can be a binary or a list of binaries,

If the header was previously set, its value is overwritten.

See also "Headers" section in `Req` module documentation.

## Examples

    iex> req = Req.new()
    iex> Req.Request.get_header(req, "accept")
    []
    iex> req = Req.Request.put_header(req, "accept", "application/json")
    iex> Req.Request.get_header(req, "accept")
    ["application/json"]

## put_headers(request, headers)

Adds (or replaces) multiple request headers.

See `put_header/3` for more information.

## Examples

    iex> req = Req.new()
    iex> req = Req.Request.put_headers(req, [{"accept", "text/html"}, {"accept-encoding", "gzip"}])
    iex> Req.Request.get_header(req, "accept")
    ["text/html"]
    iex> Req.Request.get_header(req, "accept-encoding")
    ["gzip"]

## put_new_header(request, name, value)

Adds a request header `name` unless already present.

See `put_header/3` for more information.

## Examples

    iex> req =
    ...>   Req.new()
    ...>   |> Req.Request.put_new_header("accept", "application/json")
    ...>   |> Req.Request.put_new_header("accept", "application/html")
    iex> Req.Request.get_header(req, "accept")
    ["application/json"]

## put_new_option(request, key, value)

Sets the value `value` for the option `name` unless option is already set.

See also `put_option/3`, `merge_options/2`, and `merge_new_options/2`.

## Examples

    iex> req = Req.Request.new() |> Req.Request.register_options([:a])
    iex> req.options
    %{}
    iex> req = Req.Request.put_new_option(req, :a, 1)
    iex> req.options
    %{a: 1}
    iex> req = Req.Request.put_new_option(req, :a, 2)
    iex> req.options
    %{a: 1}

    iex> req = Req.Request.new()
    iex> Req.Request.put_new_option(req, :b, 2)
    ** (ArgumentError) unknown option :b

## put_option(request, key, value)

Sets the value `value` for the option `name`.

See also `put_new_option/3`, `merge_options/2`, and `merge_new_options/2`.

## Examples

    iex> req = Req.Request.new() |> Req.Request.register_options([:a])
    iex> req.options
    %{}
    iex> req = Req.Request.put_option(req, :a, 1)
    iex> req.options
    %{a: 1}

    iex> req = Req.Request.new()
    iex> Req.Request.put_option(req, :b, 2)
    ** (ArgumentError) unknown option :b

## put_private(request, key, value)

Assigns a private `key` to `value`.

## register_options(request, options)

Registers options to be used by a custom steps.

Req ensures that all used options were previously registered which helps
finding accidentally mistyped option names. If you're adding custom steps
that are accepting options, call this function to register them.

## Examples

    iex> Req.request!(urll: "https://httpbin.org")
    ** (ArgumentError) unknown option :urll. Did you mean :url?

    iex> Req.new(bas_url: "https://httpbin.org")
    ** (ArgumentError) unknown option :bas_url. Did you mean :base_url?

    req =
      Req.new(base_url: "https://httpbin.org")
      |> Req.Request.register_options([:foo])

    Req.get!(req, url: "/status/201", foo: :bar).status
    #=> 201

## run_request(request)

Runs the request pipeline.

Returns `{request, response}` or `{request, exception}`.

## Examples

    iex> req = Req.Request.new(url: "https://api.github.com/repos/wojtekmach/req")
    iex> {request, response} = Req.Request.run_request(req)
    iex> request.url.host
    "api.github.com"
    iex> response.status
    200

## update_private(request, key, default, fun)

Updates private `key` with the given function.

If `key` is present in request private map then the existing value is passed to `fun` and its
result is used as the updated value of `key`. If `key` is not present, `default` is inserted
as the value of `key`. The default value will not be passed through the update function.

## Examples

    iex> req = %Req.Request{private: %{a: 1}}
    iex> Req.Request.update_private(req, :a, 11, & &1 + 1).private
    %{a: 2}
    iex> Req.Request.update_private(req, :b, 11, & &1 + 1).private
    %{a: 1, b: 11}

## t/0

The request struct.

## request_step/0

A request step is a function that takes a request and returns a request or a tuple of request
and response/exception.

The function can be an anonymous function, or a `{module, function, args}` tuple. In the latter
case, the step is invoked as `apply(module, function, [request | args])`.

See also the ["Request Steps"](#module-request-steps) section in the module documentation.

## response_step/0

A response step is a function that takes a request/response tuple and returns a request/response
or a request/exception tuple.

The function can be an anonymous function, or a `{module, function, args}` tuple. In the latter
case, the step is invoked as `apply(module, function, [request | args])`.

See also the ["Response and Error Steps"](#module-response-and-error-steps) section in the
module documentation.

## error_step/0

An error step is a function that takes a request/exception tuple and returns a request/response
or a request/exception tuple.

The function can be an anonymous function, or a `{module, function, args}` tuple. In the latter
case, the step is invoked as `apply(module, function, [request | args])`.

See also the ["Response and Error Steps"](#module-response-and-error-steps) section in the
module documentation.