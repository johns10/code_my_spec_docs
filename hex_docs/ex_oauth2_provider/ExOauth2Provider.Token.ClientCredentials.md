# ExOauth2Provider.Token.ClientCredentials

Functions for dealing with client credentials strategy.

## grant(request, config \\ [])

Will grant access token by client credentials.

## Example
    ExOauth2Provider.Token.grant(%{
      "grant_type" => "client_credentials",
      "client_id" => "Jf5rM8hQBc",
      "client_secret" => "secret"
    }, otp_app: :my_app)

## Response
    {:ok, access_token}
    {:error, %{error: error, error_description: description}, http_status}