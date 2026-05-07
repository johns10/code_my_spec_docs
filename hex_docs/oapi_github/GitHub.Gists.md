# GitHub.Gists

Provides API endpoints related to gists

## check_is_starred(gist_id, opts \\ [])

Check if a gist is starred

## Resources

  * [API method documentation](https://docs.github.com/rest/gists/gists#check-if-a-gist-is-starred)

## create(body, opts \\ [])

Create a gist

Allows you to add a new gist with one or more files.

**Note:** Don't name your files "gistfile" with a numerical suffix. This is the format of the automatic naming scheme that Gist uses internally.

## Resources

  * [API method documentation](https://docs.github.com/rest/gists/gists#create-a-gist)

## create_comment(gist_id, body, opts \\ [])

Create a gist comment

Creates a comment on a gist.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw markdown. This is the default if you do not pass any specific media type.
- **`application/vnd.github.base64+json`**: Returns the base64-encoded contents. This can be useful if your gist contains any invalid UTF-8 sequences.

## Resources

  * [API method documentation](https://docs.github.com/rest/gists/comments#create-a-gist-comment)

## delete(gist_id, opts \\ [])

Delete a gist

## Resources

  * [API method documentation](https://docs.github.com/rest/gists/gists#delete-a-gist)

## delete_comment(gist_id, comment_id, opts \\ [])

Delete a gist comment

## Resources

  * [API method documentation](https://docs.github.com/rest/gists/comments#delete-a-gist-comment)

## fork(gist_id, opts \\ [])

Fork a gist

## Resources

  * [API method documentation](https://docs.github.com/rest/gists/gists#fork-a-gist)

## get(gist_id, opts \\ [])

Get a gist

Gets a specified gist.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw markdown. This is the default if you do not pass any specific media type.
- **`application/vnd.github.base64+json`**: Returns the base64-encoded contents. This can be useful if your gist contains any invalid UTF-8 sequences.

## Resources

  * [API method documentation](https://docs.github.com/rest/gists/gists#get-a-gist)

## get_comment(gist_id, comment_id, opts \\ [])

Get a gist comment

Gets a comment on a gist.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw markdown. This is the default if you do not pass any specific media type.
- **`application/vnd.github.base64+json`**: Returns the base64-encoded contents. This can be useful if your gist contains any invalid UTF-8 sequences.

## Resources

  * [API method documentation](https://docs.github.com/rest/gists/comments#get-a-gist-comment)

## get_revision(gist_id, sha, opts \\ [])

Get a gist revision

Gets a specified gist revision.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw markdown. This is the default if you do not pass any specific media type.
- **`application/vnd.github.base64+json`**: Returns the base64-encoded contents. This can be useful if your gist contains any invalid UTF-8 sequences.

## Resources

  * [API method documentation](https://docs.github.com/rest/gists/gists#get-a-gist-revision)

## list(opts \\ [])

List gists for the authenticated user

Lists the authenticated user's gists or if called anonymously, this endpoint returns all public gists:

## Options

  * `since`: Only show results that were last updated after the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/gists/gists#list-gists-for-the-authenticated-user)

## list_comments(gist_id, opts \\ [])

List gist comments

Lists the comments on a gist.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw markdown. This is the default if you do not pass any specific media type.
- **`application/vnd.github.base64+json`**: Returns the base64-encoded contents. This can be useful if your gist contains any invalid UTF-8 sequences.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/gists/comments#list-gist-comments)

## list_commits(gist_id, opts \\ [])

List gist commits

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/gists/gists#list-gist-commits)

## list_for_user(username, opts \\ [])

List gists for a user

Lists public gists for the specified user:

## Options

  * `since`: Only show results that were last updated after the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/gists/gists#list-gists-for-a-user)

## list_forks(gist_id, opts \\ [])

List gist forks

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/gists/gists#list-gist-forks)

## list_public(opts \\ [])

List public gists

List public gists sorted by most recently updated to least recently updated.

Note: With [pagination](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api), you can fetch up to 3000 gists. For example, you can fetch 100 pages with 30 gists per page or 30 pages with 100 gists per page.

## Options

  * `since`: Only show results that were last updated after the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/gists/gists#list-public-gists)

## list_starred(opts \\ [])

List starred gists

List the authenticated user's starred gists:

## Options

  * `since`: Only show results that were last updated after the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/gists/gists#list-starred-gists)

## star(gist_id, opts \\ [])

Star a gist

Note that you'll need to set `Content-Length` to zero when calling out to this endpoint. For more information, see "[HTTP method](https://docs.github.com/rest/guides/getting-started-with-the-rest-api#http-method)."

## Resources

  * [API method documentation](https://docs.github.com/rest/gists/gists#star-a-gist)

## unstar(gist_id, opts \\ [])

Unstar a gist

## Resources

  * [API method documentation](https://docs.github.com/rest/gists/gists#unstar-a-gist)

## update(gist_id, body, opts \\ [])

Update a gist

Allows you to update a gist's description and to update, delete, or rename gist files. Files
from the previous version of the gist that aren't explicitly changed during an edit
are unchanged.

At least one of `description` or `files` is required.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw markdown. This is the default if you do not pass any specific media type.
- **`application/vnd.github.base64+json`**: Returns the base64-encoded contents. This can be useful if your gist contains any invalid UTF-8 sequences.

## Resources

  * [API method documentation](https://docs.github.com/rest/gists/gists#update-a-gist)

## update_comment(gist_id, comment_id, body, opts \\ [])

Update a gist comment

Updates a comment on a gist.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw markdown. This is the default if you do not pass any specific media type.
- **`application/vnd.github.base64+json`**: Returns the base64-encoded contents. This can be useful if your gist contains any invalid UTF-8 sequences.

## Resources

  * [API method documentation](https://docs.github.com/rest/gists/comments#update-a-gist-comment)