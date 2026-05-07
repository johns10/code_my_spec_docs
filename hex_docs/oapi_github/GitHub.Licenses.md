# GitHub.Licenses

Provides API endpoints related to licenses

## get(license, opts \\ [])

Get a license

Gets information about a specific license. For more information, see "[Licensing a repository ](https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)."

## Resources

  * [API method documentation](https://docs.github.com/rest/licenses/licenses#get-a-license)

## get_all_commonly_used(opts \\ [])

Get all commonly used licenses

Lists the most commonly used licenses on GitHub. For more information, see "[Licensing a repository ](https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/licensing-a-repository)."

## Options

  * `featured`
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/licenses/licenses#get-all-commonly-used-licenses)

## get_for_repo(owner, repo, opts \\ [])

Get the license for a repository

This method returns the contents of the repository's license file, if one is detected.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw contents of the license.
- **`application/vnd.github.html+json`**: Returns the license contents in HTML. Markup languages are rendered to HTML using GitHub's open-source [Markup library](https://github.com/github/markup).

## Options

  * `ref`: The Git reference for the results you want to list. The `ref` for a branch can be formatted either as `refs/heads/<branch name>` or simply `<branch name>`. To reference a pull request use `refs/pull/<number>/merge`.

## Resources

  * [API method documentation](https://docs.github.com/rest/licenses/licenses#get-the-license-for-a-repository)