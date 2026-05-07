# Mix.Phoenix.Scope



## default_scope(otp_app)

Returns the default scope.

## new!(name, opts)

Creates a new scope struct.

## route_prefix(scope_key, schema)

Generates a route prefix string with placeholders for the access path.

Takes a scope_key (what to use for accessing the scope) and a schema with scope information.
If the schema doesn't have a scope with route_prefix, returns an empty string.
Otherwise, it processes the route_prefix, replacing param segments with dynamic path elements.

## Examples

    route_prefix("socket.assigns.current_scope", schema_with_scope)
    # => "/orgs/#{socket.assigns.current_scope.organization.slug}"

    route_prefix("@current_scope", schema_with_scope)
    # => "/orgs/#{@current_scope.organization.slug}"

    route_prefix("scope", schema_with_scope)
    # => "/orgs/#{scope.organization.slug}"

## scope_from_opts(otp_app, bin, arg3)

Returns the configured scope for the given --scope parameter.

Returns `nil` for `--no-scope` and raises if a specific scope is not configured.

## scopes_from_config(otp_app)

Returns a `%{name: scope}` map of configured scopes.