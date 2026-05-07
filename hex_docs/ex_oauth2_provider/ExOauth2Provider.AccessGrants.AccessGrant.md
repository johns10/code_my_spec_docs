# ExOauth2Provider.AccessGrants.AccessGrant

Handles the Ecto schema for access grant.

## Usage

Configure `lib/my_project/oauth_access_grants/oauth_access_grant.ex` the following way:

    defmodule MyApp.OauthAccessGrants.OauthAccessGrant do
      use Ecto.Schema
      use ExOauth2Provider.AccessGrants.AccessGrant

      schema "oauth_access_grants" do
        access_grant_fields()

        timestamps()
      end
    end