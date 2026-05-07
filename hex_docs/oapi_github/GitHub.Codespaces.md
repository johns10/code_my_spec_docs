# GitHub.Codespaces

Provides API endpoints related to codespaces

## add_repository_for_secret_for_authenticated_user(secret_name, repository_id, opts \\ [])

Add a selected repository to a user secret

Adds a repository to the selected repositories for a user's development environment secret.

The authenticated user must have Codespaces access to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `codespace` or `codespace:secrets` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/secrets#add-a-selected-repository-to-a-user-secret)

## add_selected_repo_to_org_secret(org, secret_name, repository_id, opts \\ [])

Add selected repository to an organization secret

Adds a repository to an organization development environment secret when the `visibility` for repository access is set to `selected`. The visibility is set when you [Create or update an organization secret](https://docs.github.com/rest/codespaces/organization-secrets#create-or-update-an-organization-secret).
OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/organization-secrets#add-selected-repository-to-an-organization-secret)

## check_permissions_for_devcontainer(owner, repo, opts \\ [])

Check if permissions defined by a devcontainer have been accepted by the authenticated user

Checks whether the permissions defined by a given devcontainer configuration have been accepted by the authenticated user.

OAuth app tokens and personal access tokens (classic) need the `codespace` scope to use this endpoint.

## Options

  * `ref`: The git reference that points to the location of the devcontainer configuration to use for the permission check. The value of `ref` will typically be a branch name (`heads/BRANCH_NAME`). For more information, see "[Git References](https://git-scm.com/book/en/v2/Git-Internals-Git-References)" in the Git documentation.
  * `devcontainer_path`: Path to the devcontainer.json configuration to use for the permission check.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/codespaces#check-if-permissions-defined-by-a-devcontainer-have-been-accepted-by-the-authenticated-user)

## codespace_machines_for_authenticated_user(codespace_name, opts \\ [])

List machine types for a codespace

List the machine types a codespace can transition to use.

OAuth app tokens and personal access tokens (classic) need the `codespace` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/machines#list-machine-types-for-a-codespace)

## create_for_authenticated_user(body, opts \\ [])

Create a codespace for the authenticated user

Creates a new codespace, owned by the authenticated user.

This endpoint requires either a `repository_id` OR a `pull_request` but not both.

OAuth app tokens and personal access tokens (classic) need the `codespace` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/codespaces#create-a-codespace-for-the-authenticated-user)

## create_or_update_org_secret(org, secret_name, body, opts \\ [])

Create or update an organization secret

Creates or updates an organization development environment secret with an encrypted value. Encrypt your secret using
[LibSodium](https://libsodium.gitbook.io/doc/bindings_for_other_languages). For more information, see "[Encrypting secrets for the REST API](https://docs.github.com/rest/guides/encrypting-secrets-for-the-rest-api)."

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/organization-secrets#create-or-update-an-organization-secret)

## create_or_update_repo_secret(owner, repo, secret_name, body, opts \\ [])

Create or update a repository secret

Creates or updates a repository development environment secret with an encrypted value. Encrypt your secret using
[LibSodium](https://libsodium.gitbook.io/doc/bindings_for_other_languages). For more information, see "[Encrypting secrets for the REST API](https://docs.github.com/rest/guides/encrypting-secrets-for-the-rest-api)."

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/repository-secrets#create-or-update-a-repository-secret)

## create_or_update_secret_for_authenticated_user(secret_name, body, opts \\ [])

Create or update a secret for the authenticated user

Creates or updates a development environment secret for a user's codespace with an encrypted value. Encrypt your secret using
[LibSodium](https://libsodium.gitbook.io/doc/bindings_for_other_languages). For more information, see "[Encrypting secrets for the REST API](https://docs.github.com/rest/guides/encrypting-secrets-for-the-rest-api)."

The authenticated user must have Codespaces access to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `codespace` or `codespace:secrets` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/secrets#create-or-update-a-secret-for-the-authenticated-user)

## create_with_pr_for_authenticated_user(owner, repo, pull_number, body, opts \\ [])

Create a codespace from a pull request

Creates a codespace owned by the authenticated user for the specified pull request.

OAuth app tokens and personal access tokens (classic) need the `codespace` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/codespaces#create-a-codespace-from-a-pull-request)

## create_with_repo_for_authenticated_user(owner, repo, body, opts \\ [])

Create a codespace in a repository

Creates a codespace owned by the authenticated user in the specified repository.

OAuth app tokens and personal access tokens (classic) need the `codespace` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/codespaces#create-a-codespace-in-a-repository)

## delete_codespaces_access_users(org, body, opts \\ [])

Remove users from Codespaces access for an organization

Codespaces for the specified users will no longer be billed to the organization.

To use this endpoint, the access settings for the organization must be set to `selected_members`.
For information on how to change this setting, see "[Manage access control for organization codespaces](https://docs.github.com/rest/codespaces/organizations#manage-access-control-for-organization-codespaces)."

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/organizations#remove-users-from-codespaces-access-for-an-organization)

## delete_for_authenticated_user(codespace_name, opts \\ [])

Delete a codespace for the authenticated user

Deletes a user's codespace.

OAuth app tokens and personal access tokens (classic) need the `codespace` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/codespaces#delete-a-codespace-for-the-authenticated-user)

## delete_from_organization(org, username, codespace_name, opts \\ [])

Delete a codespace from the organization

Deletes a user's codespace.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/organizations#delete-a-codespace-from-the-organization)

## delete_org_secret(org, secret_name, opts \\ [])

Delete an organization secret

Deletes an organization development environment secret using the secret name.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/organization-secrets#delete-an-organization-secret)

## delete_repo_secret(owner, repo, secret_name, opts \\ [])

Delete a repository secret

Deletes a development environment secret in a repository using the secret name.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/repository-secrets#delete-a-repository-secret)

## delete_secret_for_authenticated_user(secret_name, opts \\ [])

Delete a secret for the authenticated user

Deletes a development environment secret from a user's codespaces using the secret name. Deleting the secret will remove access from all codespaces that were allowed to access the secret.

The authenticated user must have Codespaces access to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `codespace` or `codespace:secrets` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/secrets#delete-a-secret-for-the-authenticated-user)

## export_for_authenticated_user(codespace_name, opts \\ [])

Export a codespace for the authenticated user

Triggers an export of the specified codespace and returns a URL and ID where the status of the export can be monitored.

If changes cannot be pushed to the codespace's repository, they will be pushed to a new or previously-existing fork instead.

OAuth app tokens and personal access tokens (classic) need the `codespace` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/codespaces#export-a-codespace-for-the-authenticated-user)

## get_codespaces_for_user_in_org(org, username, opts \\ [])

List codespaces for a user in organization

Lists the codespaces that a member of an organization has for repositories in that organization.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/organizations#list-codespaces-for-a-user-in-organization)

## get_export_details_for_authenticated_user(codespace_name, export_id, opts \\ [])

Get details about a codespace export

Gets information about an export of a codespace.

OAuth app tokens and personal access tokens (classic) need the `codespace` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/codespaces#get-details-about-a-codespace-export)

## get_for_authenticated_user(codespace_name, opts \\ [])

Get a codespace for the authenticated user

Gets information about a user's codespace.

OAuth app tokens and personal access tokens (classic) need the `codespace` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/codespaces#get-a-codespace-for-the-authenticated-user)

## get_org_public_key(org, opts \\ [])

Get an organization public key

Gets a public key for an organization, which is required in order to encrypt secrets. You need to encrypt the value of a secret before you can create or update secrets.
OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/organization-secrets#get-an-organization-public-key)

## get_org_secret(org, secret_name, opts \\ [])

Get an organization secret

Gets an organization development environment secret without revealing its encrypted value.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/organization-secrets#get-an-organization-secret)

## get_public_key_for_authenticated_user(opts \\ [])

Get public key for the authenticated user

Gets your public key, which you need to encrypt secrets. You need to encrypt a secret before you can create or update secrets.

The authenticated user must have Codespaces access to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `codespace` or `codespace:secrets` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/secrets#get-public-key-for-the-authenticated-user)

## get_repo_public_key(owner, repo, opts \\ [])

Get a repository public key

Gets your public key, which you need to encrypt secrets. You need to
encrypt a secret before you can create or update secrets.

Anyone with read access to the repository can use this endpoint.

If the repository is private, OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/repository-secrets#get-a-repository-public-key)

## get_repo_secret(owner, repo, secret_name, opts \\ [])

Get a repository secret

Gets a single repository development environment secret without revealing its encrypted value.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/repository-secrets#get-a-repository-secret)

## get_secret_for_authenticated_user(secret_name, opts \\ [])

Get a secret for the authenticated user

Gets a development environment secret available to a user's codespaces without revealing its encrypted value.

The authenticated user must have Codespaces access to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `codespace` or `codespace:secrets` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/secrets#get-a-secret-for-the-authenticated-user)

## list_devcontainers_in_repository_for_authenticated_user(owner, repo, opts \\ [])

List devcontainer configurations in a repository for the authenticated user

Lists the devcontainer.json files associated with a specified repository and the authenticated user. These files
specify launchpoint configurations for codespaces created within the repository.

OAuth app tokens and personal access tokens (classic) need the `codespace` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/codespaces#list-devcontainer-configurations-in-a-repository-for-the-authenticated-user)

## list_for_authenticated_user(opts \\ [])

List codespaces for the authenticated user

Lists the authenticated user's codespaces.

OAuth app tokens and personal access tokens (classic) need the `codespace` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `repository_id`: ID of the Repository to filter on

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/codespaces#list-codespaces-for-the-authenticated-user)

## list_in_organization(org, opts \\ [])

List codespaces for the organization

Lists the codespaces associated to a specified organization.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/organizations#list-codespaces-for-the-organization)

## list_in_repository_for_authenticated_user(owner, repo, opts \\ [])

List codespaces in a repository for the authenticated user

Lists the codespaces associated to a specified repository and the authenticated user.

OAuth app tokens and personal access tokens (classic) need the `codespace` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/codespaces#list-codespaces-in-a-repository-for-the-authenticated-user)

## list_org_secrets(org, opts \\ [])

List organization secrets

Lists all Codespaces development environment secrets available at the organization-level without revealing their encrypted
values.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/organization-secrets#list-organization-secrets)

## list_repo_secrets(owner, repo, opts \\ [])

List repository secrets

Lists all development environment secrets available in a repository without revealing their encrypted
values.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/repository-secrets#list-repository-secrets)

## list_repositories_for_secret_for_authenticated_user(secret_name, opts \\ [])

List selected repositories for a user secret

List the repositories that have been granted the ability to use a user's development environment secret.

The authenticated user must have Codespaces access to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `codespace` or `codespace:secrets` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/secrets#list-selected-repositories-for-a-user-secret)

## list_secrets_for_authenticated_user(opts \\ [])

List secrets for the authenticated user

Lists all development environment secrets available for a user's codespaces without revealing their
encrypted values.

The authenticated user must have Codespaces access to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `codespace` or `codespace:secrets` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/secrets#list-secrets-for-the-authenticated-user)

## list_selected_repos_for_org_secret(org, secret_name, opts \\ [])

List selected repositories for an organization secret

Lists all repositories that have been selected when the `visibility`
for repository access to a secret is set to `selected`.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Options

  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/organization-secrets#list-selected-repositories-for-an-organization-secret)

## pre_flight_with_repo_for_authenticated_user(owner, repo, opts \\ [])

Get default attributes for a codespace

Gets the default attributes for codespaces created by the user with the repository.

OAuth app tokens and personal access tokens (classic) need the `codespace` scope to use this endpoint.

## Options

  * `ref`: The branch or commit to check for a default devcontainer path. If not specified, the default branch will be checked.
  * `client_ip`: An alternative IP for default location auto-detection, such as when proxying a request.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/codespaces#get-default-attributes-for-a-codespace)

## publish_for_authenticated_user(codespace_name, body, opts \\ [])

Create a repository from an unpublished codespace

Publishes an unpublished codespace, creating a new repository and assigning it to the codespace.

The codespace's token is granted write permissions to the repository, allowing the user to push their changes.

This will fail for a codespace that is already published, meaning it has an associated repository.

OAuth app tokens and personal access tokens (classic) need the `codespace` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/codespaces#create-a-repository-from-an-unpublished-codespace)

## remove_repository_for_secret_for_authenticated_user(secret_name, repository_id, opts \\ [])

Remove a selected repository from a user secret

Removes a repository from the selected repositories for a user's development environment secret.

The authenticated user must have Codespaces access to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `codespace` or `codespace:secrets` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/secrets#remove-a-selected-repository-from-a-user-secret)

## remove_selected_repo_from_org_secret(org, secret_name, repository_id, opts \\ [])

Remove selected repository from an organization secret

Removes a repository from an organization development environment secret when the `visibility`
for repository access is set to `selected`. The visibility is set when you [Create
or update an organization secret](https://docs.github.com/rest/codespaces/organization-secrets#create-or-update-an-organization-secret).

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/organization-secrets#remove-selected-repository-from-an-organization-secret)

## repo_machines_for_authenticated_user(owner, repo, opts \\ [])

List available machine types for a repository

List the machine types available for a given repository based on its configuration.

OAuth app tokens and personal access tokens (classic) need the `codespace` scope to use this endpoint.

## Options

  * `location`: The location to check for available machines. Assigned by IP if not provided.
  * `client_ip`: IP for location auto-detection when proxying a request
  * `ref`: The branch or commit to check for prebuild availability and devcontainer restrictions.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/machines#list-available-machine-types-for-a-repository)

## set_codespaces_access(org, body, opts \\ [])

Manage access control for organization codespaces

Sets which users can access codespaces in an organization. This is synonymous with granting or revoking codespaces access permissions for users according to the visibility.
OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/organizations#manage-access-control-for-organization-codespaces)

## set_codespaces_access_users(org, body, opts \\ [])

Add users to Codespaces access for an organization

Codespaces for the specified users will be billed to the organization.

To use this endpoint, the access settings for the organization must be set to `selected_members`.
For information on how to change this setting, see "[Manage access control for organization codespaces](https://docs.github.com/rest/codespaces/organizations#manage-access-control-for-organization-codespaces)."

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/organizations#add-users-to-codespaces-access-for-an-organization)

## set_repositories_for_secret_for_authenticated_user(secret_name, body, opts \\ [])

Set selected repositories for a user secret

Select the repositories that will use a user's development environment secret.

The authenticated user must have Codespaces access to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `codespace` or `codespace:secrets` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/secrets#set-selected-repositories-for-a-user-secret)

## set_selected_repos_for_org_secret(org, secret_name, body, opts \\ [])

Set selected repositories for an organization secret

Replaces all repositories for an organization development environment secret when the `visibility`
for repository access is set to `selected`. The visibility is set when you [Create
or update an organization secret](https://docs.github.com/rest/codespaces/organization-secrets#create-or-update-an-organization-secret).

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/organization-secrets#set-selected-repositories-for-an-organization-secret)

## start_for_authenticated_user(codespace_name, opts \\ [])

Start a codespace for the authenticated user

Starts a user's codespace.

OAuth app tokens and personal access tokens (classic) need the `codespace` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/codespaces#start-a-codespace-for-the-authenticated-user)

## stop_for_authenticated_user(codespace_name, opts \\ [])

Stop a codespace for the authenticated user

Stops a user's codespace.

OAuth app tokens and personal access tokens (classic) need the `codespace` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/codespaces#stop-a-codespace-for-the-authenticated-user)

## stop_in_organization(org, username, codespace_name, opts \\ [])

Stop a codespace for an organization user

Stops a user's codespace.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/organizations#stop-a-codespace-for-an-organization-user)

## update_for_authenticated_user(codespace_name, body, opts \\ [])

Update a codespace for the authenticated user

Updates a codespace owned by the authenticated user. Currently only the codespace's machine type and recent folders can be modified using this endpoint.

If you specify a new machine type it will be applied the next time your codespace is started.

OAuth app tokens and personal access tokens (classic) need the `codespace` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/codespaces/codespaces#update-a-codespace-for-the-authenticated-user)