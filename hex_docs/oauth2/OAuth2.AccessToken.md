# OAuth2.AccessToken

This module defines the `OAuth2.AccessToken` struct and provides functionality
to make authorized requests to an OAuth2 provider using the AccessToken
returned by the provider.

The `OAuth2.AccessToken` struct is created for you when you use the
`OAuth2.Client.get_token`

## expired?(token)

Determines if the access token has expired.

## expires?(token)

Determines if the access token will expire or not.

Returns `true` unless `expires_at` is `nil`.

## expires_at(val)

Returns a unix timestamp based on now + expires_at (in seconds).

## new(token)

Returns a new `OAuth2.AccessToken` struct given the access token `string` or a response `map`.

Note if giving a map, please be sure to make the key a `string` no an `atom`.

This is used by `OAuth2.Client.get_token/4` to create the `OAuth2.AccessToken` struct.

### Example

    iex> OAuth2.AccessToken.new("abc123")
    %OAuth2.AccessToken{access_token: "abc123", expires_at: nil, other_params: %{}, refresh_token: nil, token_type: "Bearer"}

    iex> OAuth2.AccessToken.new(%{"access_token" => "abc123"})
    %OAuth2.AccessToken{access_token: "abc123", expires_at: nil, other_params: %{}, refresh_token: nil, token_type: "Bearer"}