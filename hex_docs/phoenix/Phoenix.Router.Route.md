# Phoenix.Router.Route



## %Phoenix.Router.Route{}

The `Phoenix.Router.Route` struct. It stores:

  * `:verb` - the HTTP verb as an atom
  * `:line` - the line the route was defined
  * `:kind` - the kind of route, either `:match` or `:forward`
  * `:path` - the normalized path as string
  * `:hosts` - the list of request hosts or host prefixes
  * `:plug` - the plug module
  * `:plug_opts` - the plug options
  * `:helper` - the name of the helper as a string (may be nil)
  * `:private` - the private route info
  * `:assigns` - the route info
  * `:pipe_through` - the pipeline names as a list of atoms
  * `:metadata` - general metadata used on telemetry events and route info
  * `:trailing_slash?` - whether or not the helper functions append a trailing slash
  * `:warn_on_verify?` - whether or not to warn on route verification

## build(line, kind, verb, path, hosts, plug, plug_opts, helper, pipe_through, private, assigns, metadata, trailing_slash?, warn_on_verify?)

Receives the verb, path, plug, options and helper
and returns a `Phoenix.Router.Route` struct.

## call(conn, arg)

Used as a plug on forwarding

## exprs(route)

Builds the compiled expressions used by the route.

## init(opts)

Used as a plug on forwarding

## merge_params(params, path_params)

Merges params from router.