# ExOauth2Provider.Plug.VerifyHeader

Use this plug to authenticate a token contained in the header.
You should set the value of the Authorization header to:
    Authorization: <token>

## Example
    plug ExOauth2Provider.Plug.VerifyHeader, otp_app: :my_app

A "realm" can be specified when using the plug.
Realms are like the name of the token and allow many tokens
to be sent with a single request.

    plug ExOauth2Provider.Plug.VerifyHeader, otp_app: :my_app, realm: "Bearer"

When a realm is not specified, the first authorization header
found is used, and assumed to be a raw token

#### example
    plug ExOauth2Provider.Plug.VerifyHeader, otp_app: :my_app

    # will take the first auth header
    # Authorization: <token>