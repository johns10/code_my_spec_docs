# ExOauth2Provider.Token.Password

Functions for dealing with refresh token strategy.

## grant(request, config \\ [])

Will grant access token by password authentication.

## Example
    ExOauth2Provider.Token.grant(%{
      "grant_type" => "password",
      "client_id" => "Jf5rM8hQBc",
      "client_secret" => "secret",
      "username" => "testuser@example.com",
      "password" => "secret"
    }, otp_app: :my_app)

## Response
    {:ok, access_token}
    {:error, %{error: error, error_description: description}, http_status}