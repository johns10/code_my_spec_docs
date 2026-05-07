# ExOauth2Provider.Plug.EnsureAuthenticated

This plug ensures that the request has been authenticated with an access token.

If one is not found, the `unauthenticated/2` function is invoked with the
`Plug.Conn.t` object and its params.

## Example

    # Will call the unauthenticated/2 function on your handler
    plug ExOauth2Provider.Plug.EnsureAuthenticated, handler: SomeModule

    # look in the :secret location.  You can also do simple claim checks:
    plug ExOauth2Provider.Plug.EnsureAuthenticated, handler: SomeModule, key: :secret

    plug ExOauth2Provider.Plug.EnsureAuthenticated, handler: SomeModule, typ: "access"

If the handler option is not passed, `ExOauth2Provider.Plug.ErrorHandler` will provide
the default behavior.