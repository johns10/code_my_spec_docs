# MIME

Maps MIME types to its file extensions and vice versa.

MIME types can be extended in your application configuration
as follows:

    config :mime, :types, %{
      "application/vnd.api+json" => ["json-api"]
    }

Note that defining a new type will completely override all
previous extensions. You can use `MIME.extensions/1` to get
the existing extension to keep when redefining.

You can also customize the extensions for suffixes. For example,
the mime type "application/custom+gzip" returns the extension
`".gz"` because the suffix "gzip" maps to `["gz"]`:

    config :mime, :suffixes, %{
      "gzip" => ["gz"]
    }

After adding the configuration, MIME needs to be recompiled
if you are using an Elixir version earlier than v1.15. In such
cases, it can be done with:

    $ mix deps.clean mime --build

## compiled_custom_types()

Returns the custom types compiled into the MIME module.

## extensions(type)

Returns the extensions associated with a given MIME type.

## Examples

    iex> MIME.extensions("text/html")
    ["html", "htm"]

    iex> MIME.extensions("application/json")
    ["json"]

    iex> MIME.extensions("application/vnd.custom+xml")
    ["xml"]

    iex> MIME.extensions("foo/bar")
    []

## from_path(path)

Guesses the MIME type based on the path's extension. See `type/1`.

## Examples

    iex> MIME.from_path("index.html")
    "text/html"

## has_type?(file_extension)

Returns whether an extension has a MIME type registered.

## Examples

    iex> MIME.has_type?("html")
    true

    iex> MIME.has_type?("foobarbaz")
    false

## known_types()

Returns a mapping of all known types to their extensions,
including custom types compiled into the MIME module.

## Examples

    known_types()
    #=> %{"application/json" => ["json"], ...}

## type(file_extension)

Returns the MIME type associated with a file extension.

If no MIME type is known for `file_extension`,
`"application/octet-stream"` is returned.

## Examples

    iex> MIME.type("html")
    "text/html"

    iex> MIME.type("foobarbaz")
    "application/octet-stream"