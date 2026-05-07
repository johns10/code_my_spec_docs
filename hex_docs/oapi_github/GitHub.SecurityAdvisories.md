# GitHub.SecurityAdvisories

Provides API endpoints related to security advisories

## create_fork(owner, repo, ghsa_id, opts \\ [])

Create a temporary private fork

Create a temporary private fork to collaborate on fixing a security vulnerability in your repository.

**Note**: Forking a repository happens asynchronously. You may have to wait up to 5 minutes before you can access the fork.

## Resources

  * [API method documentation](https://docs.github.com/rest/security-advisories/repository-advisories#create-a-temporary-private-fork)

## create_private_vulnerability_report(owner, repo, body, opts \\ [])

Privately report a security vulnerability

Report a security vulnerability to the maintainers of the repository.
See "[Privately reporting a security vulnerability](https://docs.github.com/code-security/security-advisories/guidance-on-reporting-and-writing/privately-reporting-a-security-vulnerability)" for more information about private vulnerability reporting.

## Resources

  * [API method documentation](https://docs.github.com/rest/security-advisories/repository-advisories#privately-report-a-security-vulnerability)

## create_repository_advisory(owner, repo, body, opts \\ [])

Create a repository security advisory

Creates a new repository security advisory.

In order to create a draft repository security advisory, the authenticated user must be a security manager or administrator of that repository.

OAuth app tokens and personal access tokens (classic) need the `repo` or `repository_advisories:write` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/security-advisories/repository-advisories#create-a-repository-security-advisory)

## create_repository_advisory_cve_request(owner, repo, ghsa_id, opts \\ [])

Request a CVE for a repository security advisory

If you want a CVE identification number for the security vulnerability in your project, and don't already have one, you can request a CVE identification number from GitHub. For more information see "[Requesting a CVE identification number](https://docs.github.com/code-security/security-advisories/repository-security-advisories/publishing-a-repository-security-advisory#requesting-a-cve-identification-number-optional)."

You may request a CVE for public repositories, but cannot do so for private repositories.

In order to request a CVE for a repository security advisory, the authenticated user must be a security manager or administrator of that repository.

OAuth app tokens and personal access tokens (classic) need the `repo` or `repository_advisories:write` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/security-advisories/repository-advisories#request-a-cve-for-a-repository-security-advisory)

## get_global_advisory(ghsa_id, opts \\ [])

Get a global security advisory

Gets a global security advisory using its GitHub Security Advisory (GHSA) identifier.

## Resources

  * [API method documentation](https://docs.github.com/rest/security-advisories/global-advisories#get-a-global-security-advisory)

## get_repository_advisory(owner, repo, ghsa_id, opts \\ [])

Get a repository security advisory

Get a repository security advisory using its GitHub Security Advisory (GHSA) identifier.

Anyone can access any published security advisory on a public repository.

The authenticated user can access an unpublished security advisory from a repository if they are a security manager or administrator of that repository, or if they are a
collaborator on the security advisory.

OAuth app tokens and personal access tokens (classic) need the `repo` or `repository_advisories:read` scope to to get a published security advisory in a private repository, or any unpublished security advisory that the authenticated user has access to.

## Resources

  * [API method documentation](https://docs.github.com/rest/security-advisories/repository-advisories#get-a-repository-security-advisory)

## list_global_advisories(opts \\ [])

List global security advisories

Lists all global security advisories that match the specified parameters. If no other parameters are defined, the request will return only GitHub-reviewed advisories that are not malware.

By default, all responses will exclude advisories for malware, because malware are not standard vulnerabilities. To list advisories for malware, you must include the `type` parameter in your request, with the value `malware`. For more information about the different types of security advisories, see "[About the GitHub Advisory database](https://docs.github.com/code-security/security-advisories/global-security-advisories/about-the-github-advisory-database#about-types-of-security-advisories)."

## Options

  * `ghsa_id`: If specified, only advisories with this GHSA (GitHub Security Advisory) identifier will be returned.
  * `type`: If specified, only advisories of this type will be returned. By default, a request with no other parameters defined will only return reviewed advisories that are not malware.
  * `cve_id`: If specified, only advisories with this CVE (Common Vulnerabilities and Exposures) identifier will be returned.
  * `ecosystem`: If specified, only advisories for these ecosystems will be returned.
  * `severity`: If specified, only advisories with these severities will be returned.
  * `cwes`: If specified, only advisories with these Common Weakness Enumerations (CWEs) will be returned.
    
    Example: `cwes=79,284,22` or `cwes[]=79&cwes[]=284&cwes[]=22`
  * `is_withdrawn`: Whether to only return advisories that have been withdrawn.
  * `affects`: If specified, only return advisories that affect any of `package` or `package@version`. A maximum of 1000 packages can be specified.
    If the query parameter causes the URL to exceed the maximum URL length supported by your client, you must specify fewer packages.
    
    Example: `affects=package1,package2@1.0.0,package3@^2.0.0` or `affects[]=package1&affects[]=package2@1.0.0`
  * `published`: If specified, only return advisories that were published on a date or date range.
    
    For more information on the syntax of the date range, see "[Understanding the search syntax](https://docs.github.com/search-github/getting-started-with-searching-on-github/understanding-the-search-syntax#query-for-dates)."
  * `updated`: If specified, only return advisories that were updated on a date or date range.
    
    For more information on the syntax of the date range, see "[Understanding the search syntax](https://docs.github.com/search-github/getting-started-with-searching-on-github/understanding-the-search-syntax#query-for-dates)."
  * `modified`: If specified, only show advisories that were updated or published on a date or date range.
    
    For more information on the syntax of the date range, see "[Understanding the search syntax](https://docs.github.com/search-github/getting-started-with-searching-on-github/understanding-the-search-syntax#query-for-dates)."
  * `before`: A cursor, as given in the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers). If specified, the query only searches for results before this cursor. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `after`: A cursor, as given in the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers). If specified, the query only searches for results after this cursor. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `direction`: The direction to sort the results by.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `sort`: The property to sort the results by.

## Resources

  * [API method documentation](https://docs.github.com/rest/security-advisories/global-advisories#list-global-security-advisories)

## list_org_repository_advisories(org, opts \\ [])

List repository security advisories for an organization

Lists repository security advisories for an organization.

The authenticated user must be an owner or security manager for the organization to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` or `repository_advisories:write` scope to use this endpoint.

## Options

  * `direction`: The direction to sort the results by.
  * `sort`: The property to sort the results by.
  * `before`: A cursor, as given in the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers). If specified, the query only searches for results before this cursor. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `after`: A cursor, as given in the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers). If specified, the query only searches for results after this cursor. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of advisories to return per page. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `state`: Filter by the state of the repository advisories. Only advisories of this state will be returned.

## Resources

  * [API method documentation](https://docs.github.com/rest/security-advisories/repository-advisories#list-repository-security-advisories-for-an-organization)

## list_repository_advisories(owner, repo, opts \\ [])

List repository security advisories

Lists security advisories in a repository.

The authenticated user can access unpublished security advisories from a repository if they are a security manager or administrator of that repository, or if they are a collaborator on any security advisory.

OAuth app tokens and personal access tokens (classic) need the `repo` or `repository_advisories:read` scope to to get a published security advisory in a private repository, or any unpublished security advisory that the authenticated user has access to.

## Options

  * `direction`: The direction to sort the results by.
  * `sort`: The property to sort the results by.
  * `before`: A cursor, as given in the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers). If specified, the query only searches for results before this cursor. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `after`: A cursor, as given in the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers). If specified, the query only searches for results after this cursor. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of advisories to return per page. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `state`: Filter by state of the repository advisories. Only advisories of this state will be returned.

## Resources

  * [API method documentation](https://docs.github.com/rest/security-advisories/repository-advisories#list-repository-security-advisories)

## update_repository_advisory(owner, repo, ghsa_id, body, opts \\ [])

Update a repository security advisory

Update a repository security advisory using its GitHub Security Advisory (GHSA) identifier.

In order to update any security advisory, the authenticated user must be a security manager or administrator of that repository,
or a collaborator on the repository security advisory.

OAuth app tokens and personal access tokens (classic) need the `repo` or `repository_advisories:write` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/security-advisories/repository-advisories#update-a-repository-security-advisory)