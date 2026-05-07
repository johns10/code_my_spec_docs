# ExOauth2Provider.Applications.Application

Handles the Ecto schema for application.

## Usage

Configure `lib/my_project/oauth_applications/oauth_application.ex` the following way:

    defmodule MyApp.OauthApplications.OauthApplication do
      use Ecto.Schema
      use ExOauth2Provider.Applications.Application

      schema "oauth_applications" do
        application_fields()

        timestamps()
      end
    end

## Application owner

By default the application owner will be will be the `:resource_owner`
configuration setting. You can override this by overriding the `:owner`
belongs to association:

    defmodule MyApp.OauthApplications.OauthApplication do
      use Ecto.Schema
      use ExOauth2Provider.Applications.Application

      schema "oauth_applications" do
        belongs_to :owner, MyApp.Users.User

        application_fields()

        timestamps()
      end
    end