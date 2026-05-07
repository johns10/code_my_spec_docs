# ExOauth2Provider.Token.RefreshToken

Functions for dealing with refresh token strategy.

## grant(request, config \\ [])

Will grant access token by refresh token.

## Example
    ExOauth2Provider.Token.authorize(%{
      "grant_type" => "refresh_token",
      "client_id" => "Jf5rM8hQBc",
      "client_secret" => "secret",
      "refresh_token" => "1jf6a"
    }, otp_app: :my_app)

## Response
    {:ok, access_token}
    {:error, %{error: error, error_description: description}, http_status}