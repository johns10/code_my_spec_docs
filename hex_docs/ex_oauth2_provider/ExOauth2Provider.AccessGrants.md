# ExOauth2Provider.AccessGrants

The boundary for the OauthAccessGrants system.

## get_active_grant_for/3

Gets a single access grant registered with an application.

## Examples

    iex> get_active_grant_for(application, "jE9dk", otp_app: :my_app)
    %OauthAccessGrant{}

    iex> get_active_grant_for(application, "jE9dk", otp_app: :my_app)
    ** nil

## create_grant/4

Creates an access grant.

## Examples

    iex> create_grant(resource_owner, application, attrs)
    {:ok, %OauthAccessGrant{}}

    iex> create_grant(resource_owner, application, attrs)
    {:error, %Ecto.Changeset{}}