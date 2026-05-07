# ExOauth2Provider.Applications

The boundary for the applications system.

## change_application(application, attrs \\ %{}, config \\ [])

Create application changeset.

## Examples

    iex> change_application(application, %{}, otp_app: :my_app)
    {:ok, %OauthApplication{}}

## create_application(owner, attrs \\ %{}, config \\ [])

Creates an application.

## Examples

    iex> create_application(user, %{name: "App", redirect_uri: "http://example.com"}, otp_app: :my_app)
    {:ok, %OauthApplication{}}

    iex> create_application(user, %{name: ""}, otp_app: :my_app)
    {:error, %Ecto.Changeset{}}

## delete_application(application, config \\ [])

Deletes an application.

## Examples

    iex> delete_application(application, otp_app: :my_app)
    {:ok, %OauthApplication{}}

    iex> delete_application(application, otp_app: :my_app)
    {:error, %Ecto.Changeset{}}

## get_application(uid, config \\ [])

Gets a single application by uid.

## Examples

    iex> get_application("c341a5c7b331ef076eb4954668d54f590e0009e06b81b100191aa22c93044f3d", otp_app: :my_app)
    %OauthApplication{}

    iex> get_application("75d72f326a69444a9287ea264617058dbbfe754d7071b8eef8294cbf4e7e0fdc", otp_app: :my_app)
    nil

## get_application!(uid, config \\ [])

Gets a single application by uid.

Raises `Ecto.NoResultsError` if the Application does not exist.

## Examples

    iex> get_application!("c341a5c7b331ef076eb4954668d54f590e0009e06b81b100191aa22c93044f3d", otp_app: :my_app)
    %OauthApplication{}

    iex> get_application!("75d72f326a69444a9287ea264617058dbbfe754d7071b8eef8294cbf4e7e0fdc", otp_app: :my_app)
    ** (Ecto.NoResultsError)

## get_application_for!(resource_owner, uid, config \\ [])

Gets a single application for a resource owner.

Raises `Ecto.NoResultsError` if the OauthApplication does not exist for resource owner.

## Examples

    iex> get_application_for!(owner, "c341a5c7b331ef076eb4954668d54f590e0009e06b81b100191aa22c93044f3d", otp_app: :my_app)
    %OauthApplication{}

    iex> get_application_for!(owner, "75d72f326a69444a9287ea264617058dbbfe754d7071b8eef8294cbf4e7e0fdc", otp_app: :my_app)
    ** (Ecto.NoResultsError)

## get_applications_for(resource_owner, config \\ [])

Returns all applications for a owner.

## Examples

    iex> get_applications_for(resource_owner, otp_app: :my_app)
    [%OauthApplication{}, ...]

## get_authorized_applications_for(resource_owner, config \\ [])

Gets all authorized applications for a resource owner.

## Examples

    iex> get_authorized_applications_for(owner, otp_app: :my_app)
    [%OauthApplication{},...]

## load_application(uid, secret, config \\ [])

Gets a single application by uid and secret.

## Examples

    iex> load_application("c341a5c7b331ef076eb4954668d54f590e0009e06b81b100191aa22c93044f3d", "SECRET", otp_app: :my_app)
    %OauthApplication{}

    iex> load_application("75d72f326a69444a9287ea264617058dbbfe754d7071b8eef8294cbf4e7e0fdc", "SECRET", otp_app: :my_app)
    nil

## revoke_all_access_tokens_for(application, resource_owner, config \\ [])

Revokes all access tokens for an application and resource owner.

## Examples

    iex> revoke_all_access_tokens_for(application, resource_owner, otp_app: :my_app)
    {:ok, [ok: %OauthAccessToken{}]}

## update_application(application, attrs, config \\ [])

Updates an application.

## Examples

    iex> update_application(application, %{name: "Updated App"}, otp_app: :my_app)
    {:ok, %OauthApplication{}}

    iex> update_application(application, %{name: ""}, otp_app: :my_app)
    {:error, %Ecto.Changeset{}}