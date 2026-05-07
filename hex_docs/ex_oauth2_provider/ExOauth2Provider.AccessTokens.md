# ExOauth2Provider.AccessTokens

Ecto schema for oauth access tokens

## create_application_token(application, attrs \\ %{}, config \\ [])

Creates an application access token.

## Examples

    iex> create_application_token(application, %{scopes: "read write"}, otp_app: :my_app)
    {:ok, %OauthAccessToken{}}

## create_token(resource_owner, attrs \\ %{}, config \\ [])

Creates an access token.

## Examples

    iex> create_token(resource_owner, %{application: application, scopes: "read write"}, otp_app: :my_app)
    {:ok, %OauthAccessToken{}}

    iex> create_token(resource_owner, %{scopes: "read write"}, otp_app: :my_app)
    {:ok, %OauthAccessToken{}}

    iex> create_token(resource_owner, %{expires_in: "invalid"}, otp_app: :my_app)
    {:error, %Ecto.Changeset{}}

## get_application_token_for(application, scopes, config \\ [])

Gets the most recent, acccessible, matching access token for an application.

## Examples

    iex> get_application_token_for(application, "read write", otp_app: :my_app)
    %OauthAccessToken{}

    iex> get_application_token_for(application, "read invalid", otp_app: :my_app)
    nil

## get_authorized_tokens_for(resource_owner, config \\ [])

Gets all authorized access tokens for resource owner.

## Examples

    iex> get_authorized_tokens_for(resource_owner, otp_app: :my_app)
    [%OauthAccessToken{}, ...]

## get_by_previous_refresh_token_for(map, config)

Gets an old access token by previous refresh token.

## Examples

    iex> get_by_previous_refresh_token_for(new_access_token, otp_app: :my_app)
    %OauthAccessToken{}

    iex> get_by_previous_refresh_token_for(new_access_token, otp_app: :my_app)
    nil

## get_by_refresh_token(refresh_token, config \\ [])

Gets an access token by the refresh token.

## Examples

    iex> get_by_refresh_token("c341a5c7b331ef076eb4954668d54f590e0009e06b81b100191aa22c93044f3d", otp_app: :my_app)
    %OauthAccessToken{}

    iex> get_by_refresh_token("75d72f326a69444a9287ea264617058dbbfe754d7071b8eef8294cbf4e7e0fdc", otp_app: :my_app)
    nil

## get_by_refresh_token_for(application, refresh_token, config \\ [])

Gets an access token by the refresh token belonging to an application.

## Examples

    iex> get_by_refresh_token_for(application, "c341a5c7b331ef076eb4954668d54f590e0009e06b81b100191aa22c93044f3d", otp_app: :my_app)
    %OauthAccessToken{}

    iex> get_by_refresh_token_for(application, "75d72f326a69444a9287ea264617058dbbfe754d7071b8eef8294cbf4e7e0fdc", otp_app: :my_app)
    nil

## get_by_token(token, config \\ [])

Gets a single access token.

## Examples

    iex> get_by_token("c341a5c7b331ef076eb4954668d54f590e0009e06b81b100191aa22c93044f3d", otp_app: :my_app)
    %OauthAccessToken{}

    iex> get_by_token("75d72f326a69444a9287ea264617058dbbfe754d7071b8eef8294cbf4e7e0fdc", otp_app: :my_app)
    nil

## get_token_for(resource_owner, application, scopes, config \\ [])

Gets the most recent, acccessible, matching access token for a resource owner.

## Examples

    iex> get_token_for(resource_owner, application, "read write", otp_app: :my_app)
    %OauthAccessToken{}

    iex> get_token_for(resource_owner, application, "read invalid", otp_app: :my_app)
    nil

## is_accessible?(token)

Checks if an access token can be accessed.

## Examples

    iex> is_accessible?(token)
    true

    iex> is_accessible?(inaccessible_token)
    false

## revoke_previous_refresh_token(access_token, config \\ [])

Revokes token with `refresh_token` equal to
`previous_refresh_token` and clears `:previous_refresh_token`
attribute.

## Examples

    iex> revoke_previous_refresh_token(data, otp_app: :my_app)
    {:ok, %OauthAccessToken{}}

    iex> revoke_previous_refresh_token(invalid_data, otp_app: :my_app)
    {:error, %Ecto.Changeset{}}