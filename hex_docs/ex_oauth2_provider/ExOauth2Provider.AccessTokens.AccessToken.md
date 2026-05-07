# ExOauth2Provider.AccessTokens.AccessToken

Handles the Ecto schema for access token.

## Usage

Configure `lib/my_project/oauth_access_tokens/oauth_access_token.ex` the following way:

    defmodule MyApp.OauthAccessTokens.OauthAccessToken do
      use Ecto.Schema
      use ExOauth2Provider.AccessTokens.AccessToken

      schema "oauth_access_tokens" do
        access_token_fields()

        timestamps()
      end
    end