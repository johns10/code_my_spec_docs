# GitHub.Auth

Protocol for extracting API authentication tokens from application structs

Credentials can be passed to operations using the `auth` option as strings (for tokens) or
2-tuples (for client ID / secret or username / password). Sometimes, it's more convenient to pass
a struct — like as a user struct — and extract the auth token from that.

By implementing this protocol, the client can extract an auth token from the given struct without
additional work by the caller.

## Example

    defimpl GitHub.Auth, for: MyApp.User do
      def to_auth(%MyApp.User{github_token: token}), do: token
    end

## Provided Implementations

This library provides several implementations for the protocol based on library structs.

### GitHub.App

For app structs with `id` and `pem` fields containing the GitHub App ID and private key
(respectively), the default implementation will generate a JWT compatible with certain API
endpoints. Generally, the PEM field can only be filled in manually. To assist with this, the
helper function `GitHub.app/1` will construct a valid app struct using configured values.

Creating a JWT requires the optional dependency `JOSE`.

JWTs are made to last for several minutes, so it is prudent to cache values between requests.
See `GitHub.Auth.Cache` for a built-in caching mechanism.

## to_auth(value)

Extract an auth token from the given struct

The returned data should be in the form of a string (for a Bearer token) or a 2-tuple (for a Basic
Auth user/password pair).

## to_auth/1

Extract an auth token from the given struct

The returned data should be in the form of a string (for a Bearer token) or a 2-tuple (for a Basic
Auth user/password pair).

## auth/0

Auth token accepted by the client

## t/0

All the types that implement this protocol.