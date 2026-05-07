# ExOauth2Provider.Token.Revoke

Functions for dealing with revocation.

## revoke(request, config \\ [])

Revokes access token.

The authorization server, if applicable, first authenticates the client
and checks its ownership of the provided token.

ExOauth2Provider does not use the token_type_hint logic described in the
RFC 7009 due to the refresh token implementation that is a field in
the access token schema.

## Example confidential client
    ExOauth2Provider.Token.revoke(%{
      "client_id" => "Jf5rM8hQBc",
      "client_secret" => "secret",
      "token" => "fi3S9u"
    }, otp_app: :my_app)

## Response
    {:ok, %{}}

## Example public client
    ExOauth2Provider.Token.revoke(%{
      "token" => "fi3S9u"
    }, otp_app: :my_app)

## Response
    {:ok, %{}}