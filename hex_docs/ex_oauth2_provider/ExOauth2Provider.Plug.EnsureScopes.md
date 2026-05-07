# ExOauth2Provider.Plug.EnsureScopes

Use this plug to ensure that there are the correct scopes on
the token found on the connection.

### Example
    alias ExOauth2Provider.Plug.EnsureScopes

    # With custom handler
    plug EnsureScopes, scopes: ~w(read write), handler: SomeMod,

    # item:read AND item:write scopes AND :profile scope
    plug EnsureScopes, scopes: ~(item:read item:write profile)

    # iteam:read AND item: write scope OR :profile for the default set
    plug EnsureScopes, one_of: [~(item:read item:write),
                                ~(profile)]

    # item :read AND :write for the token located in the :secret location
    plug EnsureScopes, key: :secret, scopes: ~(read :write)

   If the handler option is not passed, `ExOauth2Provider.Plug.ErrorHandler`
   will provide the default behavior.