# ExOauth2Provider.Token.AuthorizationCode

Functions for dealing with authorization code strategy.

## grant(request, config \\ [])

Will grant access token by client credentials.

## Example
    ExOauth2Provider.Token.grant(%{
      "code" => "1jf6a",
      "client_id" => "Jf5rM8hQBc",
      "client_secret" => "secret",
      "redirect_uri" => "https://example.com/",
      "grant_type" => "authorization_code"
    }, otp_app: :my_app)

## Response
    {:ok, access_token}
    {:error, %{error: error, error_description: description}, http_status}