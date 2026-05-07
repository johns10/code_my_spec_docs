# Plug.Router.Utils



## build_host_match(host)

Builds the pattern that will be used to match against the request's host
(provided via the `:host`) option.

If `host` is `nil`, a wildcard match (`_`) will be returned. If `host` ends
with a dot, a match like `"host." <> _` will be returned.

## Examples

    iex> Plug.Router.Utils.build_host_match(nil)
    {:_, [], Plug.Router.Utils}

    iex> Plug.Router.Utils.build_host_match("foo.com")
    "foo.com"

    iex> "api." |> Plug.Router.Utils.build_host_match() |> Macro.to_string()
    "\"api.\" <> _"

## build_path_clause(path, guard, context \\ nil)

Builds a clause with match, guards, and post matches,
including the known parameters.

## build_path_match(path, context \\ nil)

Generates a representation that will only match routes
according to the given `spec`.

If a non-binary spec is given, it is assumed to be
custom match arguments and they are simply returned.

## Examples

    iex> Plug.Router.Utils.build_path_match("/foo/:id")
    {[:id], ["foo", {:id, [], nil}]}

## build_path_params_match(params, context \\ nil)

Builds a list of path param names and var match pairs.

This is used to build parameter maps from existing variables.
Excludes variables with underscore.

## Examples

    iex> Plug.Router.Utils.build_path_params_match(["id"])
    [{"id", {:id, [], nil}}]
    iex> Plug.Router.Utils.build_path_params_match(["_id"])
    []

    iex> Plug.Router.Utils.build_path_params_match([:id])
    [{"id", {:id, [], nil}}]
    iex> Plug.Router.Utils.build_path_params_match([:_id])
    []

## decode_path_info!(conn)

Decodes path information for dispatching.

## normalize_method(method)

Converts a given method to its connection representation.

The request method is stored in the `Plug.Conn` struct as an uppercase string
(like `"GET"` or `"POST"`). This function converts `method` to that
representation.

## Examples

    iex> Plug.Router.Utils.normalize_method(:get)
    "GET"

## split(bin)

Splits the given path into several segments.
It ignores both leading and trailing slashes in the path.

## Examples

    iex> Plug.Router.Utils.split("/foo/bar")
    ["foo", "bar"]

    iex> Plug.Router.Utils.split("/:id/*")
    [":id", "*"]

    iex> Plug.Router.Utils.split("/foo//*_bar")
    ["foo", "*_bar"]