# GitHub.Dependabot

Provides API endpoints related to dependabot

## add_selected_repo_to_org_secret(org, secret_name, repository_id, opts \\ [])

Add selected repository to an organization secret

Adds a repository to an organization secret when the `visibility` for
repository access is set to `selected`. The visibility is set when you [Create or
update an organization secret](https://docs.github.com/rest/dependabot/secrets#create-or-update-an-organization-secret).

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/dependabot/secrets#add-selected-repository-to-an-organization-secret)

## create_or_update_org_secret(org, secret_name, body, opts \\ [])

Create or update an organization secret

Creates or updates an organization secret with an encrypted value. Encrypt your secret using
[LibSodium](https://libsodium.gitbook.io/doc/bindings_for_other_languages). For more information, see "[Encrypting secrets for the REST API](https://docs.github.com/rest/guides/encrypting-secrets-for-the-rest-api)."

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/dependabot/secrets#create-or-update-an-organization-secret)

## create_or_update_repo_secret(owner, repo, secret_name, body, opts \\ [])

Create or update a repository secret

Creates or updates a repository secret with an encrypted value. Encrypt your secret using
[LibSodium](https://libsodium.gitbook.io/doc/bindings_for_other_languages). For more information, see "[Encrypting secrets for the REST API](https://docs.github.com/rest/guides/encrypting-secrets-for-the-rest-api)."

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/dependabot/secrets#create-or-update-a-repository-secret)

## delete_org_secret(org, secret_name, opts \\ [])

Delete an organization secret

Deletes a secret in an organization using the secret name.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/dependabot/secrets#delete-an-organization-secret)

## delete_repo_secret(owner, repo, secret_name, opts \\ [])

Delete a repository secret

Deletes a secret in a repository using the secret name.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/dependabot/secrets#delete-a-repository-secret)

## get_alert(owner, repo, alert_number, opts \\ [])

Get a Dependabot alert

OAuth app tokens and personal access tokens (classic) need the `security_events` scope to use this endpoint. If this endpoint is only used with public repositories, the token can use the `public_repo` scope instead.

## Resources

  * [API method documentation](https://docs.github.com/rest/dependabot/alerts#get-a-dependabot-alert)

## get_org_public_key(org, opts \\ [])

Get an organization public key

Gets your public key, which you need to encrypt secrets. You need to
encrypt a secret before you can create or update secrets.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/dependabot/secrets#get-an-organization-public-key)

## get_org_secret(org, secret_name, opts \\ [])

Get an organization secret

Gets a single organization secret without revealing its encrypted value.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/dependabot/secrets#get-an-organization-secret)

## get_repo_public_key(owner, repo, opts \\ [])

Get a repository public key

Gets your public key, which you need to encrypt secrets. You need to
encrypt a secret before you can create or update secrets. Anyone with read access
to the repository can use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint if the repository is private.

## Resources

  * [API method documentation](https://docs.github.com/rest/dependabot/secrets#get-a-repository-public-key)

## get_repo_secret(owner, repo, secret_name, opts \\ [])

Get a repository secret

Gets a single repository secret without revealing its encrypted value.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/dependabot/secrets#get-a-repository-secret)

## list_alerts_for_enterprise(enterprise, opts \\ [])

List Dependabot alerts for an enterprise

Lists Dependabot alerts for repositories that are owned by the specified enterprise.

The authenticated user must be a member of the enterprise to use this endpoint.

Alerts are only returned for organizations in the enterprise for which you are an organization owner or a security manager. For more information about security managers, see "[Managing security managers in your organization](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/managing-security-managers-in-your-organization)."

OAuth app tokens and personal access tokens (classic) need the `repo` or `security_events` scope to use this endpoint.

## Options

  * `state`: A comma-separated list of states. If specified, only alerts with these states will be returned.
    
    Can be: `auto_dismissed`, `dismissed`, `fixed`, `open`
  * `severity`: A comma-separated list of severities. If specified, only alerts with these severities will be returned.
    
    Can be: `low`, `medium`, `high`, `critical`
  * `ecosystem`: A comma-separated list of ecosystems. If specified, only alerts for these ecosystems will be returned.
    
    Can be: `composer`, `go`, `maven`, `npm`, `nuget`, `pip`, `pub`, `rubygems`, `rust`
  * `package`: A comma-separated list of package names. If specified, only alerts for these packages will be returned.
  * `scope`: The scope of the vulnerable dependency. If specified, only alerts with this scope will be returned.
  * `sort`: The property by which to sort the results.
    `created` means when the alert was created.
    `updated` means when the alert's state last changed.
  * `direction`: The direction to sort the results by.
  * `before`: A cursor, as given in the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers). If specified, the query only searches for results before this cursor. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `after`: A cursor, as given in the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers). If specified, the query only searches for results after this cursor. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `first`: **Deprecated**. The number of results per page (max 100), starting from the first matching result.
    This parameter must not be used in combination with `last`.
    Instead, use `per_page` in combination with `after` to fetch the first page of results.
  * `last`: **Deprecated**. The number of results per page (max 100), starting from the last matching result.
    This parameter must not be used in combination with `first`.
    Instead, use `per_page` in combination with `before` to fetch the last page of results.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/dependabot/alerts#list-dependabot-alerts-for-an-enterprise)

## list_alerts_for_org(org, opts \\ [])

List Dependabot alerts for an organization

Lists Dependabot alerts for an organization.

The authenticated user must be an owner or security manager for the organization to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `security_events` scope to use this endpoint. If this endpoint is only used with public repositories, the token can use the `public_repo` scope instead.

## Options

  * `state`: A comma-separated list of states. If specified, only alerts with these states will be returned.
    
    Can be: `auto_dismissed`, `dismissed`, `fixed`, `open`
  * `severity`: A comma-separated list of severities. If specified, only alerts with these severities will be returned.
    
    Can be: `low`, `medium`, `high`, `critical`
  * `ecosystem`: A comma-separated list of ecosystems. If specified, only alerts for these ecosystems will be returned.
    
    Can be: `composer`, `go`, `maven`, `npm`, `nuget`, `pip`, `pub`, `rubygems`, `rust`
  * `package`: A comma-separated list of package names. If specified, only alerts for these packages will be returned.
  * `scope`: The scope of the vulnerable dependency. If specified, only alerts with this scope will be returned.
  * `sort`: The property by which to sort the results.
    `created` means when the alert was created.
    `updated` means when the alert's state last changed.
  * `direction`: The direction to sort the results by.
  * `before`: A cursor, as given in the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers). If specified, the query only searches for results before this cursor. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `after`: A cursor, as given in the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers). If specified, the query only searches for results after this cursor. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `first`: **Deprecated**. The number of results per page (max 100), starting from the first matching result.
    This parameter must not be used in combination with `last`.
    Instead, use `per_page` in combination with `after` to fetch the first page of results.
  * `last`: **Deprecated**. The number of results per page (max 100), starting from the last matching result.
    This parameter must not be used in combination with `first`.
    Instead, use `per_page` in combination with `before` to fetch the last page of results.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/dependabot/alerts#list-dependabot-alerts-for-an-organization)

## list_alerts_for_repo(owner, repo, opts \\ [])

List Dependabot alerts for a repository

OAuth app tokens and personal access tokens (classic) need the `security_events` scope to use this endpoint. If this endpoint is only used with public repositories, the token can use the `public_repo` scope instead.

## Options

  * `state`: A comma-separated list of states. If specified, only alerts with these states will be returned.
    
    Can be: `auto_dismissed`, `dismissed`, `fixed`, `open`
  * `severity`: A comma-separated list of severities. If specified, only alerts with these severities will be returned.
    
    Can be: `low`, `medium`, `high`, `critical`
  * `ecosystem`: A comma-separated list of ecosystems. If specified, only alerts for these ecosystems will be returned.
    
    Can be: `composer`, `go`, `maven`, `npm`, `nuget`, `pip`, `pub`, `rubygems`, `rust`
  * `package`: A comma-separated list of package names. If specified, only alerts for these packages will be returned.
  * `manifest`: A comma-separated list of full manifest paths. If specified, only alerts for these manifests will be returned.
  * `scope`: The scope of the vulnerable dependency. If specified, only alerts with this scope will be returned.
  * `sort`: The property by which to sort the results.
    `created` means when the alert was created.
    `updated` means when the alert's state last changed.
  * `direction`: The direction to sort the results by.
  * `page`: **Deprecated**. Page number of the results to fetch. Use cursor-based pagination with `before` or `after` instead.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `before`: A cursor, as given in the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers). If specified, the query only searches for results before this cursor. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `after`: A cursor, as given in the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers). If specified, the query only searches for results after this cursor. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `first`: **Deprecated**. The number of results per page (max 100), starting from the first matching result.
    This parameter must not be used in combination with `last`.
    Instead, use `per_page` in combination with `after` to fetch the first page of results.
  * `last`: **Deprecated**. The number of results per page (max 100), starting from the last matching result.
    This parameter must not be used in combination with `first`.
    Instead, use `per_page` in combination with `before` to fetch the last page of results.

## Resources

  * [API method documentation](https://docs.github.com/rest/dependabot/alerts#list-dependabot-alerts-for-a-repository)

## list_org_secrets(org, opts \\ [])

List organization secrets

Lists all secrets available in an organization without revealing their
encrypted values.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/dependabot/secrets#list-organization-secrets)

## list_repo_secrets(owner, repo, opts \\ [])

List repository secrets

Lists all secrets available in a repository without revealing their encrypted
values.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/dependabot/secrets#list-repository-secrets)

## list_selected_repos_for_org_secret(org, secret_name, opts \\ [])

List selected repositories for an organization secret

Lists all repositories that have been selected when the `visibility`
for repository access to a secret is set to `selected`.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Options

  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/dependabot/secrets#list-selected-repositories-for-an-organization-secret)

## remove_selected_repo_from_org_secret(org, secret_name, repository_id, opts \\ [])

Remove selected repository from an organization secret

Removes a repository from an organization secret when the `visibility`
for repository access is set to `selected`. The visibility is set when you [Create
or update an organization secret](https://docs.github.com/rest/dependabot/secrets#create-or-update-an-organization-secret).

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/dependabot/secrets#remove-selected-repository-from-an-organization-secret)

## set_selected_repos_for_org_secret(org, secret_name, body, opts \\ [])

Set selected repositories for an organization secret

Replaces all repositories for an organization secret when the `visibility`
for repository access is set to `selected`. The visibility is set when you [Create
or update an organization secret](https://docs.github.com/rest/dependabot/secrets#create-or-update-an-organization-secret).

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/dependabot/secrets#set-selected-repositories-for-an-organization-secret)

## update_alert(owner, repo, alert_number, body, opts \\ [])

Update a Dependabot alert

The authenticated user must have access to security alerts for the repository to use this endpoint. For more information, see "[Granting access to security alerts](https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-security-and-analysis-settings-for-your-repository#granting-access-to-security-alerts)."

OAuth app tokens and personal access tokens (classic) need the `security_events` scope to use this endpoint. If this endpoint is only used with public repositories, the token can use the `public_repo` scope instead.

## Resources

  * [API method documentation](https://docs.github.com/rest/dependabot/alerts#update-a-dependabot-alert)