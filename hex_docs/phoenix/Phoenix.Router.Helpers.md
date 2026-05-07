# Phoenix.Router.Helpers



## defhelper(route, exprs)

Receives a route and returns the quoted definition for its helper function.

In case a helper name was not given, or route is forwarded, returns nil.

## define(env, routes)

Generates the helper module for the given environment and routes.

## encode_param(str)

Callback for properly encoding parameters in routes.

## raise_route_error(mod, fun, arity, action, routes, params)

Callback for generate router catch all.