# GitHub.Issues

Provides API endpoints related to issues

## add_assignees(owner, repo, issue_number, body, opts \\ [])

Add assignees to an issue

Adds up to 10 assignees to an issue. Users already assigned to an issue are not replaced.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/assignees#add-assignees-to-an-issue)

## add_labels(owner, repo, issue_number, body, opts \\ [])

Add labels to an issue

Adds labels to an issue. If you provide an empty array of labels, all labels are removed from the issue. 

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/labels#add-labels-to-an-issue)

## check_user_can_be_assigned(owner, repo, assignee, opts \\ [])

Check if a user can be assigned

Checks if a user has permission to be assigned to an issue in this repository.

If the `assignee` can be assigned to issues in the repository, a `204` header with no content is returned.

Otherwise a `404` status code is returned.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/assignees#check-if-a-user-can-be-assigned)

## check_user_can_be_assigned_to_issue(owner, repo, issue_number, assignee, opts \\ [])

Check if a user can be assigned to a issue

Checks if a user has permission to be assigned to a specific issue.

If the `assignee` can be assigned to this issue, a `204` status code with no content is returned.

Otherwise a `404` status code is returned.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/assignees#check-if-a-user-can-be-assigned-to-a-issue)

## create(owner, repo, body, opts \\ [])

Create an issue

Any user with pull access to a repository can create an issue. If [issues are disabled in the repository](https://docs.github.com/articles/disabling-issues/), the API returns a `410 Gone` status.

This endpoint triggers [notifications](https://docs.github.com/github/managing-subscriptions-and-notifications-on-github/about-notifications). Creating content too quickly using this endpoint may result in secondary rate limiting. For more information, see "[Rate limits for the API](https://docs.github.com/rest/overview/rate-limits-for-the-rest-api#about-secondary-rate-limits)"
and "[Best practices for using the REST API](https://docs.github.com/rest/guides/best-practices-for-using-the-rest-api)."

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw markdown body. Response will include `body`. This is the default if you do not pass any specific media type.
- **`application/vnd.github.text+json`**: Returns a text only representation of the markdown body. Response will include `body_text`.
- **`application/vnd.github.html+json`**: Returns HTML rendered from the body's markdown. Response will include `body_html`.
- **`application/vnd.github.full+json`**: Returns raw, text, and HTML representations. Response will include `body`, `body_text`, and `body_html`.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/issues#create-an-issue)

## create_comment(owner, repo, issue_number, body, opts \\ [])

Create an issue comment

You can use the REST API to create comments on issues and pull requests. Every pull request is an issue, but not every issue is a pull request.

This endpoint triggers [notifications](https://docs.github.com/github/managing-subscriptions-and-notifications-on-github/about-notifications).
Creating content too quickly using this endpoint may result in secondary rate limiting.
For more information, see "[Rate limits for the API](https://docs.github.com/rest/overview/rate-limits-for-the-rest-api#about-secondary-rate-limits)"
and "[Best practices for using the REST API](https://docs.github.com/rest/guides/best-practices-for-using-the-rest-api)."

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw markdown body. Response will include `body`. This is the default if you do not pass any specific media type.
- **`application/vnd.github.text+json`**: Returns a text only representation of the markdown body. Response will include `body_text`.
- **`application/vnd.github.html+json`**: Returns HTML rendered from the body's markdown. Response will include `body_html`.
- **`application/vnd.github.full+json`**: Returns raw, text, and HTML representations. Response will include `body`, `body_text`, and `body_html`.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/comments#create-an-issue-comment)

## create_label(owner, repo, body, opts \\ [])

Create a label

Creates a label for the specified repository with the given name and color. The name and color parameters are required. The color must be a valid [hexadecimal color code](http://www.color-hex.com/).

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/labels#create-a-label)

## create_milestone(owner, repo, body, opts \\ [])

Create a milestone

Creates a milestone.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/milestones#create-a-milestone)

## delete_comment(owner, repo, comment_id, opts \\ [])

Delete an issue comment

You can use the REST API to delete comments on issues and pull requests. Every pull request is an issue, but not every issue is a pull request.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/comments#delete-an-issue-comment)

## delete_label(owner, repo, name, opts \\ [])

Delete a label

Deletes a label using the given label name.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/labels#delete-a-label)

## delete_milestone(owner, repo, milestone_number, opts \\ [])

Delete a milestone

Deletes a milestone using the given milestone number.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/milestones#delete-a-milestone)

## get(owner, repo, issue_number, opts \\ [])

Get an issue

The API returns a [`301 Moved Permanently` status](https://docs.github.com/rest/guides/best-practices-for-using-the-rest-api#follow-redirects) if the issue was
[transferred](https://docs.github.com/articles/transferring-an-issue-to-another-repository/) to another repository. If
the issue was transferred to or deleted from a repository where the authenticated user lacks read access, the API
returns a `404 Not Found` status. If the issue was deleted from a repository where the authenticated user has read
access, the API returns a `410 Gone` status. To receive webhook events for transferred and deleted issues, subscribe
to the [`issues`](https://docs.github.com/webhooks/event-payloads/#issues) webhook.

**Note**: GitHub's REST API considers every pull request an issue, but not every issue is a pull request. For this
reason, "Issues" endpoints may return both issues and pull requests in the response. You can identify pull requests by
the `pull_request` key. Be aware that the `id` of a pull request returned from "Issues" endpoints will be an _issue id_. To find out the pull
request id, use the "[List pull requests](https://docs.github.com/rest/pulls/pulls#list-pull-requests)" endpoint.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw markdown body. Response will include `body`. This is the default if you do not pass any specific media type.
- **`application/vnd.github.text+json`**: Returns a text only representation of the markdown body. Response will include `body_text`.
- **`application/vnd.github.html+json`**: Returns HTML rendered from the body's markdown. Response will include `body_html`.
- **`application/vnd.github.full+json`**: Returns raw, text, and HTML representations. Response will include `body`, `body_text`, and `body_html`.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/issues#get-an-issue)

## get_comment(owner, repo, comment_id, opts \\ [])

Get an issue comment

You can use the REST API to get comments on issues and pull requests. Every pull request is an issue, but not every issue is a pull request.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw markdown body. Response will include `body`. This is the default if you do not pass any specific media type.
- **`application/vnd.github.text+json`**: Returns a text only representation of the markdown body. Response will include `body_text`.
- **`application/vnd.github.html+json`**: Returns HTML rendered from the body's markdown. Response will include `body_html`.
- **`application/vnd.github.full+json`**: Returns raw, text, and HTML representations. Response will include `body`, `body_text`, and `body_html`.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/comments#get-an-issue-comment)

## get_event(owner, repo, event_id, opts \\ [])

Get an issue event

Gets a single event by the event id.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/events#get-an-issue-event)

## get_label(owner, repo, name, opts \\ [])

Get a label

Gets a label using the given name.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/labels#get-a-label)

## get_milestone(owner, repo, milestone_number, opts \\ [])

Get a milestone

Gets a milestone using the given milestone number.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/milestones#get-a-milestone)

## list(opts \\ [])

List issues assigned to the authenticated user

List issues assigned to the authenticated user across all visible repositories including owned repositories, member
repositories, and organization repositories. You can use the `filter` query parameter to fetch issues that are not
necessarily assigned to you.

**Note**: GitHub's REST API considers every pull request an issue, but not every issue is a pull request. For this
reason, "Issues" endpoints may return both issues and pull requests in the response. You can identify pull requests by
the `pull_request` key. Be aware that the `id` of a pull request returned from "Issues" endpoints will be an _issue id_. To find out the pull
request id, use the "[List pull requests](https://docs.github.com/rest/pulls/pulls#list-pull-requests)" endpoint.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw markdown body. Response will include `body`. This is the default if you do not pass any specific media type.
- **`application/vnd.github.text+json`**: Returns a text only representation of the markdown body. Response will include `body_text`.
- **`application/vnd.github.html+json`**: Returns HTML rendered from the body's markdown. Response will include `body_html`.
- **`application/vnd.github.full+json`**: Returns raw, text, and HTML representations. Response will include `body`, `body_text`, and `body_html`.

## Options

  * `filter`: Indicates which sorts of issues to return. `assigned` means issues assigned to you. `created` means issues created by you. `mentioned` means issues mentioning you. `subscribed` means issues you're subscribed to updates for. `all` or `repos` means all issues you can see, regardless of participation or creation.
  * `state`: Indicates the state of the issues to return.
  * `labels`: A list of comma separated label names. Example: `bug,ui,@high`
  * `sort`: What to sort results by.
  * `direction`: The direction to sort the results by.
  * `since`: Only show results that were last updated after the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
  * `collab`
  * `orgs`
  * `owned`
  * `pulls`
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/issues#list-issues-assigned-to-the-authenticated-user)

## list_assignees(owner, repo, opts \\ [])

List assignees

Lists the [available assignees](https://docs.github.com/articles/assigning-issues-and-pull-requests-to-other-github-users/) for issues in a repository.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/assignees#list-assignees)

## list_comments(owner, repo, issue_number, opts \\ [])

List issue comments

You can use the REST API to list comments on issues and pull requests. Every pull request is an issue, but not every issue is a pull request.

Issue comments are ordered by ascending ID.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw markdown body. Response will include `body`. This is the default if you do not pass any specific media type.
- **`application/vnd.github.text+json`**: Returns a text only representation of the markdown body. Response will include `body_text`.
- **`application/vnd.github.html+json`**: Returns HTML rendered from the body's markdown. Response will include `body_html`.
- **`application/vnd.github.full+json`**: Returns raw, text, and HTML representations. Response will include `body`, `body_text`, and `body_html`.

## Options

  * `since`: Only show results that were last updated after the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/comments#list-issue-comments)

## list_comments_for_repo(owner, repo, opts \\ [])

List issue comments for a repository

You can use the REST API to list comments on issues and pull requests for a repository. Every pull request is an issue, but not every issue is a pull request.

By default, issue comments are ordered by ascending ID.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw markdown body. Response will include `body`. This is the default if you do not pass any specific media type.
- **`application/vnd.github.text+json`**: Returns a text only representation of the markdown body. Response will include `body_text`.
- **`application/vnd.github.html+json`**: Returns HTML rendered from the body's markdown. Response will include `body_html`.
- **`application/vnd.github.full+json`**: Returns raw, text, and HTML representations. Response will include `body`, `body_text`, and `body_html`.

## Options

  * `sort`: The property to sort the results by.
  * `direction`: Either `asc` or `desc`. Ignored without the `sort` parameter.
  * `since`: Only show results that were last updated after the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/comments#list-issue-comments-for-a-repository)

## list_events(owner, repo, issue_number, opts \\ [])

List issue events

Lists all events for an issue.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/events#list-issue-events)

## list_events_for_repo(owner, repo, opts \\ [])

List issue events for a repository

Lists events for a repository.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/events#list-issue-events-for-a-repository)

## list_events_for_timeline(owner, repo, issue_number, opts \\ [])

List timeline events for an issue

List all timeline events for an issue.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/timeline#list-timeline-events-for-an-issue)

## list_for_authenticated_user(opts \\ [])

List user account issues assigned to the authenticated user

List issues across owned and member repositories assigned to the authenticated user.

**Note**: GitHub's REST API considers every pull request an issue, but not every issue is a pull request. For this
reason, "Issues" endpoints may return both issues and pull requests in the response. You can identify pull requests by
the `pull_request` key. Be aware that the `id` of a pull request returned from "Issues" endpoints will be an _issue id_. To find out the pull
request id, use the "[List pull requests](https://docs.github.com/rest/pulls/pulls#list-pull-requests)" endpoint.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw markdown body. Response will include `body`. This is the default if you do not pass any specific media type.
- **`application/vnd.github.text+json`**: Returns a text only representation of the markdown body. Response will include `body_text`.
- **`application/vnd.github.html+json`**: Returns HTML rendered from the body's markdown. Response will include `body_html`.
- **`application/vnd.github.full+json`**: Returns raw, text, and HTML representations. Response will include `body`, `body_text`, and `body_html`.

## Options

  * `filter`: Indicates which sorts of issues to return. `assigned` means issues assigned to you. `created` means issues created by you. `mentioned` means issues mentioning you. `subscribed` means issues you're subscribed to updates for. `all` or `repos` means all issues you can see, regardless of participation or creation.
  * `state`: Indicates the state of the issues to return.
  * `labels`: A list of comma separated label names. Example: `bug,ui,@high`
  * `sort`: What to sort results by.
  * `direction`: The direction to sort the results by.
  * `since`: Only show results that were last updated after the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/issues#list-user-account-issues-assigned-to-the-authenticated-user)

## list_for_org(org, opts \\ [])

List organization issues assigned to the authenticated user

List issues in an organization assigned to the authenticated user.

**Note**: GitHub's REST API considers every pull request an issue, but not every issue is a pull request. For this
reason, "Issues" endpoints may return both issues and pull requests in the response. You can identify pull requests by
the `pull_request` key. Be aware that the `id` of a pull request returned from "Issues" endpoints will be an _issue id_. To find out the pull
request id, use the "[List pull requests](https://docs.github.com/rest/pulls/pulls#list-pull-requests)" endpoint.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw markdown body. Response will include `body`. This is the default if you do not pass any specific media type.
- **`application/vnd.github.text+json`**: Returns a text only representation of the markdown body. Response will include `body_text`.
- **`application/vnd.github.html+json`**: Returns HTML rendered from the body's markdown. Response will include `body_html`.
- **`application/vnd.github.full+json`**: Returns raw, text, and HTML representations. Response will include `body`, `body_text`, and `body_html`.

## Options

  * `filter`: Indicates which sorts of issues to return. `assigned` means issues assigned to you. `created` means issues created by you. `mentioned` means issues mentioning you. `subscribed` means issues you're subscribed to updates for. `all` or `repos` means all issues you can see, regardless of participation or creation.
  * `state`: Indicates the state of the issues to return.
  * `labels`: A list of comma separated label names. Example: `bug,ui,@high`
  * `sort`: What to sort results by.
  * `direction`: The direction to sort the results by.
  * `since`: Only show results that were last updated after the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/issues#list-organization-issues-assigned-to-the-authenticated-user)

## list_for_repo(owner, repo, opts \\ [])

List repository issues

List issues in a repository. Only open issues will be listed.

**Note**: GitHub's REST API considers every pull request an issue, but not every issue is a pull request. For this
reason, "Issues" endpoints may return both issues and pull requests in the response. You can identify pull requests by
the `pull_request` key. Be aware that the `id` of a pull request returned from "Issues" endpoints will be an _issue id_. To find out the pull
request id, use the "[List pull requests](https://docs.github.com/rest/pulls/pulls#list-pull-requests)" endpoint.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw markdown body. Response will include `body`. This is the default if you do not pass any specific media type.
- **`application/vnd.github.text+json`**: Returns a text only representation of the markdown body. Response will include `body_text`.
- **`application/vnd.github.html+json`**: Returns HTML rendered from the body's markdown. Response will include `body_html`.
- **`application/vnd.github.full+json`**: Returns raw, text, and HTML representations. Response will include `body`, `body_text`, and `body_html`.

## Options

  * `milestone`: If an `integer` is passed, it should refer to a milestone by its `number` field. If the string `*` is passed, issues with any milestone are accepted. If the string `none` is passed, issues without milestones are returned.
  * `state`: Indicates the state of the issues to return.
  * `assignee`: Can be the name of a user. Pass in `none` for issues with no assigned user, and `*` for issues assigned to any user.
  * `creator`: The user that created the issue.
  * `mentioned`: A user that's mentioned in the issue.
  * `labels`: A list of comma separated label names. Example: `bug,ui,@high`
  * `sort`: What to sort results by.
  * `direction`: The direction to sort the results by.
  * `since`: Only show results that were last updated after the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/issues#list-repository-issues)

## list_labels_for_milestone(owner, repo, milestone_number, opts \\ [])

List labels for issues in a milestone

Lists labels for issues in a milestone.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/labels#list-labels-for-issues-in-a-milestone)

## list_labels_for_repo(owner, repo, opts \\ [])

List labels for a repository

Lists all labels for a repository.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/labels#list-labels-for-a-repository)

## list_labels_on_issue(owner, repo, issue_number, opts \\ [])

List labels for an issue

Lists all labels for an issue.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/labels#list-labels-for-an-issue)

## list_milestones(owner, repo, opts \\ [])

List milestones

Lists milestones for a repository.

## Options

  * `state`: The state of the milestone. Either `open`, `closed`, or `all`.
  * `sort`: What to sort results by. Either `due_on` or `completeness`.
  * `direction`: The direction of the sort. Either `asc` or `desc`.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/milestones#list-milestones)

## lock(owner, repo, issue_number, body, opts \\ [])

Lock an issue

Users with push access can lock an issue or pull request's conversation.

Note that, if you choose not to pass any parameters, you'll need to set `Content-Length` to zero when calling out to this endpoint. For more information, see "[HTTP method](https://docs.github.com/rest/guides/getting-started-with-the-rest-api#http-method)."

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/issues#lock-an-issue)

## remove_all_labels(owner, repo, issue_number, opts \\ [])

Remove all labels from an issue

Removes all labels from an issue.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/labels#remove-all-labels-from-an-issue)

## remove_assignees(owner, repo, issue_number, body, opts \\ [])

Remove assignees from an issue

Removes one or more assignees from an issue.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/assignees#remove-assignees-from-an-issue)

## remove_label(owner, repo, issue_number, name, opts \\ [])

Remove a label from an issue

Removes the specified label from the issue, and returns the remaining labels on the issue. This endpoint returns a `404 Not Found` status if the label does not exist.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/labels#remove-a-label-from-an-issue)

## set_labels(owner, repo, issue_number, body, opts \\ [])

Set labels for an issue

Removes any previous labels and sets the new labels for an issue.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/labels#set-labels-for-an-issue)

## unlock(owner, repo, issue_number, opts \\ [])

Unlock an issue

Users with push access can unlock an issue's conversation.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/issues#unlock-an-issue)

## update(owner, repo, issue_number, body, opts \\ [])

Update an issue

Issue owners and users with push access can edit an issue.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw markdown body. Response will include `body`. This is the default if you do not pass any specific media type.
- **`application/vnd.github.text+json`**: Returns a text only representation of the markdown body. Response will include `body_text`.
- **`application/vnd.github.html+json`**: Returns HTML rendered from the body's markdown. Response will include `body_html`.
- **`application/vnd.github.full+json`**: Returns raw, text, and HTML representations. Response will include `body`, `body_text`, and `body_html`.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/issues#update-an-issue)

## update_comment(owner, repo, comment_id, body, opts \\ [])

Update an issue comment

You can use the REST API to update comments on issues and pull requests. Every pull request is an issue, but not every issue is a pull request.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw markdown body. Response will include `body`. This is the default if you do not pass any specific media type.
- **`application/vnd.github.text+json`**: Returns a text only representation of the markdown body. Response will include `body_text`.
- **`application/vnd.github.html+json`**: Returns HTML rendered from the body's markdown. Response will include `body_html`.
- **`application/vnd.github.full+json`**: Returns raw, text, and HTML representations. Response will include `body`, `body_text`, and `body_html`.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/comments#update-an-issue-comment)

## update_label(owner, repo, name, body, opts \\ [])

Update a label

Updates a label using the given label name.

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/labels#update-a-label)

## update_milestone(owner, repo, milestone_number, body, opts \\ [])

Update a milestone

## Resources

  * [API method documentation](https://docs.github.com/rest/issues/milestones#update-a-milestone)