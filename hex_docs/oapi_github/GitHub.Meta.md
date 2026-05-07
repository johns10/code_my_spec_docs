# GitHub.Meta

Provides API endpoints related to meta

## get(opts \\ [])

Get GitHub meta information

Returns meta information about GitHub, including a list of GitHub's IP addresses. For more information, see "[About GitHub's IP addresses](https://docs.github.com/articles/about-github-s-ip-addresses/)."

The API's response also includes a list of GitHub's domain names.

The values shown in the documentation's response are example values. You must always query the API directly to get the latest values.

**Note:** This endpoint returns both IPv4 and IPv6 addresses. However, not all features support IPv6. You should refer to the specific documentation for each feature to determine if IPv6 is supported.

## Resources

  * [API method documentation](https://docs.github.com/rest/meta/meta#get-apiname-meta-information)

## get_all_versions(opts \\ [])

Get all API versions

Get all supported GitHub API versions.

## Resources

  * [API method documentation](https://docs.github.com/rest/meta/meta#get-all-api-versions)

## get_octocat(opts \\ [])

Get Octocat

Get the octocat as ASCII art

## Options

  * `s`: The words to show in Octocat's speech bubble

## Resources

  * [API method documentation](https://docs.github.com/rest/meta/meta#get-octocat)

## get_zen(opts \\ [])

Get the Zen of GitHub

Get a random sentence from the Zen of GitHub

## Resources

  * [API method documentation](https://docs.github.com/rest/meta/meta#get-the-zen-of-github)

## root(opts \\ [])

GitHub API Root

Get Hypermedia links to resources accessible in GitHub's REST API

## Resources

  * [API method documentation](https://docs.github.com/rest/meta/meta#github-api-root)