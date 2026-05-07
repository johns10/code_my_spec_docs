# ExOauth2Provider.Token

Handler for dealing with generating access tokens.

## grant(request, config \\ [])

Grants an access token based on grant_type strategy.

## Example

    ExOauth2Provider.Token.authorize(resource_owner, %{
      "grant_type" => "invalid",
      "client_id" => "Jf5rM8hQBc",
      "client_secret" => "secret"
    }, otp_app: :my_app)

## Response

    {:error, %{error: error, error_description: description}, http_status}

## revoke(request, config \\ [])

Revokes an access token as per http://tools.ietf.org/html/rfc7009

## Example
    ExOauth2Provider.Token.revoke(resource_owner, %{
      "client_id" => "Jf5rM8hQBc",
      "client_secret" => "secret",
      "token" => "fi3S9u"
    }, otp_app: :my_app)

## Response

    {:ok, %{}}