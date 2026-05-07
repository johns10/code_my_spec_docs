# ExOauth2Provider

A module that provides OAuth 2 capabilities for Elixir applications.

## Configuration
    config :my_app, ExOauth2Provider,
      repo: App.Repo,
      resource_owner: App.Users.User,
      default_scopes: ~w(public),
      optional_scopes: ~w(write update),
      native_redirect_uri: "urn:ietf:wg:oauth:2.0:oob",
      authorization_code_expires_in: 600,
      access_token_expires_in: 7200,
      use_refresh_token: false,
      revoke_refresh_token_on_use: false,
      force_ssl_in_redirect_uri: true,
      grant_flows: ~w(authorization_code client_credentials),
      password_auth: nil,
      access_token_response_body_handler: nil

If `revoke_refresh_token_on_use` is set to true,
refresh tokens will be revoked after a related access token is used.

If `revoke_refresh_token_on_use` is not set to true,
previous tokens are revoked as soon as a new access token is created.

If `use_refresh_token` is set to true, the refresh_token grant flow
is automatically enabled.

If `password_auth` is set to a {module, method} tuple, the password
grant flow is automatically enabled.

If access_token_expires_in is set to nil, access tokens will never
expire.

## authenticate_token(token, config \\ [])

Authenticate an access token.

## Example

    ExOauth2Provider.authenticate_token("Jf5rM8hQBc", otp_app: :my_app)

## Response

    {:ok, access_token}
    {:error, reason}