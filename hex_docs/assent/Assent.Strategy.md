# Assent.Strategy

Used for creating strategies.

## Usage

Set up `my_strategy.ex` the following way:

    defmodule MyStrategy do
      @behaviour Assent.Strategy

      alias Assent.Strategy, as: Helpers

      @impl Assent.Strategy
      def authorize_url(config) do
        # Generate redirect URL

        {:ok, %{url: url, ...}}
      end

      @impl Assent.Strategy
      def callback(config, params) do
        # Fetch user data

        user = Helpers.normalize_userinfo(userinfo)

        {:ok, %{user: user, ...}}
      end
    end

## decode_json(response, config)

Decode a JSON string.

## Options

- `:json_library` - The JSON library to use, see
  `Assent.json_library/1`

## http_request(method, url, body, headers, config)

Makes a HTTP request.

See `Assent.HTTPAdapter.request/5`.

## normalize_userinfo(claims, extra \\ %{})

Normalize API user request response into standard claims.

The function will cast values to adhere to the following types:

```
%{
  "address" => %{
    "country" => :binary,
    "formatted" => :binary,
    "locality" => :binary,
    "postal_code" => :binary,
    "region" => :binary,
    "street_address" => :binary
  },
  "birthdate" => :binary,
  "email" => :binary,
  "email_verified" => :boolean,
  "family_name" => :binary,
  "gender" => :binary,
  "given_name" => :binary,
  "locale" => :binary,
  "middle_name" => :binary,
  "name" => :binary,
  "nickname" => :binary,
  "phone_number" => :binary,
  "phone_number_verified" => :boolean,
  "picture" => :binary,
  "preferred_username" => :binary,
  "profile" => :binary,
  "sub" => :binary,
  "updated_at" => :integer,
  "website" => :binary,
  "zoneinfo" => :binary
}
```

Returns an `Assent.CastClaimsError` if any of the above types can't be casted.

Based on https://openid.net/specs/openid-connect-core-1_0.html#rfc.section.5.1

## sign_jwt(claims, alg, secret, config)

Signs a JSON Web Token.

See `Assent.JWTAdapter.sign/3` for options.

## to_url(base_url, uri, params \\ [])

Generates a URL.

## verify_jwt(token, secret, config)

Verifies a JSON Web Token.

See `Assent.JWTAdapter.verify/3` for options.