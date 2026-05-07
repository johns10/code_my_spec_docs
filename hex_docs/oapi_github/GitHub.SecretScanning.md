# GitHub.SecretScanning

Provides API endpoints related to secret scanning

## get_alert(owner, repo, alert_number, opts \\ [])

Get a secret scanning alert

Gets a single secret scanning alert detected in an eligible repository.

The authenticated user must be an administrator for the repository or for the organization that owns the repository to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` or `security_events` scope to use this endpoint. If this endpoint is only used with public repositories, the token can use the `public_repo` scope instead.

## Resources

  * [API method documentation](https://docs.github.com/rest/secret-scanning/secret-scanning#get-a-secret-scanning-alert)

## list_alerts_for_enterprise(enterprise, opts \\ [])

List secret scanning alerts for an enterprise

Lists secret scanning alerts for eligible repositories in an enterprise, from newest to oldest.

Alerts are only returned for organizations in the enterprise for which the authenticated user is an organization owner or a [security manager](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/managing-security-managers-in-your-organization).

The authenticated user must be a member of the enterprise in order to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope or `security_events` scope to use this endpoint.

## Options

  * `state`: Set to `open` or `resolved` to only list secret scanning alerts in a specific state.
  * `secret_type`: A comma-separated list of secret types to return. By default all secret types are returned.
    See "[Secret scanning patterns](https://docs.github.com/code-security/secret-scanning/secret-scanning-patterns#supported-secrets-for-advanced-security)"
    for a complete list of secret types.
  * `resolution`: A comma-separated list of resolutions. Only secret scanning alerts with one of these resolutions are listed. Valid resolutions are `false_positive`, `wont_fix`, `revoked`, `pattern_edited`, `pattern_deleted` or `used_in_tests`.
  * `sort`: The property to sort the results by. `created` means when the alert was created. `updated` means when the alert was updated or resolved.
  * `direction`: The direction to sort the results by.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `before`: A cursor, as given in the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers). If specified, the query only searches for results before this cursor. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `after`: A cursor, as given in the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers). If specified, the query only searches for results after this cursor. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `validity`: A comma-separated list of validities that, when present, will return alerts that match the validities in this list. Valid options are `active`, `inactive`, and `unknown`.

## Resources

  * [API method documentation](https://docs.github.com/rest/secret-scanning/secret-scanning#list-secret-scanning-alerts-for-an-enterprise)

## list_alerts_for_org(org, opts \\ [])

List secret scanning alerts for an organization

Lists secret scanning alerts for eligible repositories in an organization, from newest to oldest.

The authenticated user must be an administrator or security manager for the organization to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` or `security_events` scope to use this endpoint. If this endpoint is only used with public repositories, the token can use the `public_repo` scope instead.

## Options

  * `state`: Set to `open` or `resolved` to only list secret scanning alerts in a specific state.
  * `secret_type`: A comma-separated list of secret types to return. By default all secret types are returned.
    See "[Secret scanning patterns](https://docs.github.com/code-security/secret-scanning/secret-scanning-patterns#supported-secrets-for-advanced-security)"
    for a complete list of secret types.
  * `resolution`: A comma-separated list of resolutions. Only secret scanning alerts with one of these resolutions are listed. Valid resolutions are `false_positive`, `wont_fix`, `revoked`, `pattern_edited`, `pattern_deleted` or `used_in_tests`.
  * `sort`: The property to sort the results by. `created` means when the alert was created. `updated` means when the alert was updated or resolved.
  * `direction`: The direction to sort the results by.
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `before`: A cursor, as given in the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers). If specified, the query only searches for events before this cursor. To receive an initial cursor on your first request, include an empty "before" query string.
  * `after`: A cursor, as given in the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers). If specified, the query only searches for events after this cursor.  To receive an initial cursor on your first request, include an empty "after" query string.
  * `validity`: A comma-separated list of validities that, when present, will return alerts that match the validities in this list. Valid options are `active`, `inactive`, and `unknown`.

## Resources

  * [API method documentation](https://docs.github.com/rest/secret-scanning/secret-scanning#list-secret-scanning-alerts-for-an-organization)

## list_alerts_for_repo(owner, repo, opts \\ [])

List secret scanning alerts for a repository

Lists secret scanning alerts for an eligible repository, from newest to oldest.

The authenticated user must be an administrator for the repository or for the organization that owns the repository to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` or `security_events` scope to use this endpoint. If this endpoint is only used with public repositories, the token can use the `public_repo` scope instead.

## Options

  * `state`: Set to `open` or `resolved` to only list secret scanning alerts in a specific state.
  * `secret_type`: A comma-separated list of secret types to return. By default all secret types are returned.
    See "[Secret scanning patterns](https://docs.github.com/code-security/secret-scanning/secret-scanning-patterns#supported-secrets-for-advanced-security)"
    for a complete list of secret types.
  * `resolution`: A comma-separated list of resolutions. Only secret scanning alerts with one of these resolutions are listed. Valid resolutions are `false_positive`, `wont_fix`, `revoked`, `pattern_edited`, `pattern_deleted` or `used_in_tests`.
  * `sort`: The property to sort the results by. `created` means when the alert was created. `updated` means when the alert was updated or resolved.
  * `direction`: The direction to sort the results by.
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `before`: A cursor, as given in the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers). If specified, the query only searches for events before this cursor. To receive an initial cursor on your first request, include an empty "before" query string.
  * `after`: A cursor, as given in the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers). If specified, the query only searches for events after this cursor.  To receive an initial cursor on your first request, include an empty "after" query string.
  * `validity`: A comma-separated list of validities that, when present, will return alerts that match the validities in this list. Valid options are `active`, `inactive`, and `unknown`.

## Resources

  * [API method documentation](https://docs.github.com/rest/secret-scanning/secret-scanning#list-secret-scanning-alerts-for-a-repository)

## list_locations_for_alert(owner, repo, alert_number, opts \\ [])

List locations for a secret scanning alert

Lists all locations for a given secret scanning alert for an eligible repository.

The authenticated user must be an administrator for the repository or for the organization that owns the repository to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` or `security_events` scope to use this endpoint. If this endpoint is only used with public repositories, the token can use the `public_repo` scope instead.

## Options

  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/secret-scanning/secret-scanning#list-locations-for-a-secret-scanning-alert)

## update_alert(owner, repo, alert_number, body, opts \\ [])

Update a secret scanning alert

Updates the status of a secret scanning alert in an eligible repository.

The authenticated user must be an administrator for the repository or for the organization that owns the repository to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` or `security_events` scope to use this endpoint. If this endpoint is only used with public repositories, the token can use the `public_repo` scope instead.

## Resources

  * [API method documentation](https://docs.github.com/rest/secret-scanning/secret-scanning#update-a-secret-scanning-alert)