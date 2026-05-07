# Phoenix.Router.Resource



## %Phoenix.Router.Resource{}

The `Phoenix.Router.Resource` struct. It stores:

  * `:path` - the path as string (not normalized)
  * `:param` - the param to be used in routes (not normalized)
  * `:controller` - the controller as an atom
  * `:actions` - a list of actions as atoms
  * `:route` - the context for resource routes
  * `:member` - the context for member routes
  * `:collection` - the context for collection routes

## build(path, controller, options)

Builds a resource struct.