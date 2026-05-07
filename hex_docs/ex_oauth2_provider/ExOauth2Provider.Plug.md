# ExOauth2Provider.Plug

ExOauth2Provider.Plug contains functions that assist with interacting with
ExOauth2Provider via Plugs.

ExOauth2Provider.Plug is not itself a plug.

Use the helpers to look up current_access_token and current_resource_owner.

## Example
    ExOauth2Provider.Plug.current_access_token(conn)
    ExOauth2Provider.Plug.current_resource_owner(conn)

## authenticated?(conn, type \\ :default)

Check if a request is authenticated

## current_access_token(conn, the_key \\ :default)

Fetch the currently verified token from the request.
Optionally located at a key

## current_resource_owner(conn, the_key \\ :default)

Fetch the currently authenticated resource if loaded,
optionally located at a key