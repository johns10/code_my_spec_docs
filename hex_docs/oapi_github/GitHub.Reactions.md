# GitHub.Reactions

Provides API endpoints related to reactions

## create_for_commit_comment(owner, repo, comment_id, body, opts \\ [])

Create reaction for a commit comment

Create a reaction to a [commit comment](https://docs.github.com/rest/commits/comments#get-a-commit-comment). A response with an HTTP `200` status means that you already added the reaction type to this commit comment.

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#create-reaction-for-a-commit-comment)

## create_for_issue(owner, repo, issue_number, body, opts \\ [])

Create reaction for an issue

Create a reaction to an [issue](https://docs.github.com/rest/issues/issues#get-an-issue). A response with an HTTP `200` status means that you already added the reaction type to this issue.

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#create-reaction-for-an-issue)

## create_for_issue_comment(owner, repo, comment_id, body, opts \\ [])

Create reaction for an issue comment

Create a reaction to an [issue comment](https://docs.github.com/rest/issues/comments#get-an-issue-comment). A response with an HTTP `200` status means that you already added the reaction type to this issue comment.

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#create-reaction-for-an-issue-comment)

## create_for_pull_request_review_comment(owner, repo, comment_id, body, opts \\ [])

Create reaction for a pull request review comment

Create a reaction to a [pull request review comment](https://docs.github.com/rest/pulls/comments#get-a-review-comment-for-a-pull-request). A response with an HTTP `200` status means that you already added the reaction type to this pull request review comment.

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#create-reaction-for-a-pull-request-review-comment)

## create_for_release(owner, repo, release_id, body, opts \\ [])

Create reaction for a release

Create a reaction to a [release](https://docs.github.com/rest/releases/releases#get-a-release). A response with a `Status: 200 OK` means that you already added the reaction type to this release.

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#create-reaction-for-a-release)

## create_for_team_discussion_comment_in_org(org, team_slug, discussion_number, comment_number, body, opts \\ [])

Create reaction for a team discussion comment

Create a reaction to a [team discussion comment](https://docs.github.com/rest/teams/discussion-comments#get-a-discussion-comment).

A response with an HTTP `200` status means that you already added the reaction type to this team discussion comment.

**Note:** You can also specify a team by `org_id` and `team_id` using the route `POST /organizations/:org_id/team/:team_id/discussions/:discussion_number/comments/:comment_number/reactions`.

OAuth app tokens and personal access tokens (classic) need the `write:discussion` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#create-reaction-for-a-team-discussion-comment)

## create_for_team_discussion_comment_legacy(team_id, discussion_number, comment_number, body, opts \\ [])

Create reaction for a team discussion comment (Legacy)

**Deprecation Notice:** This endpoint route is deprecated and will be removed from the Teams API. We recommend migrating your existing code to use the new "[Create reaction for a team discussion comment](https://docs.github.com/rest/reactions/reactions#create-reaction-for-a-team-discussion-comment)" endpoint.

Create a reaction to a [team discussion comment](https://docs.github.com/rest/teams/discussion-comments#get-a-discussion-comment).

A response with an HTTP `200` status means that you already added the reaction type to this team discussion comment.

OAuth app tokens and personal access tokens (classic) need the `write:discussion` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#create-reaction-for-a-team-discussion-comment-legacy)

## create_for_team_discussion_in_org(org, team_slug, discussion_number, body, opts \\ [])

Create reaction for a team discussion

Create a reaction to a [team discussion](https://docs.github.com/rest/teams/discussions#get-a-discussion).

A response with an HTTP `200` status means that you already added the reaction type to this team discussion.

**Note:** You can also specify a team by `org_id` and `team_id` using the route `POST /organizations/:org_id/team/:team_id/discussions/:discussion_number/reactions`.

OAuth app tokens and personal access tokens (classic) need the `write:discussion` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#create-reaction-for-a-team-discussion)

## create_for_team_discussion_legacy(team_id, discussion_number, body, opts \\ [])

Create reaction for a team discussion (Legacy)

**Deprecation Notice:** This endpoint route is deprecated and will be removed from the Teams API. We recommend migrating your existing code to use the new [`Create reaction for a team discussion`](https://docs.github.com/rest/reactions/reactions#create-reaction-for-a-team-discussion) endpoint.

Create a reaction to a [team discussion](https://docs.github.com/rest/teams/discussions#get-a-discussion).

A response with an HTTP `200` status means that you already added the reaction type to this team discussion.

OAuth app tokens and personal access tokens (classic) need the `write:discussion` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#create-reaction-for-a-team-discussion-legacy)

## delete_for_commit_comment(owner, repo, comment_id, reaction_id, opts \\ [])

Delete a commit comment reaction

**Note:** You can also specify a repository by `repository_id` using the route `DELETE /repositories/:repository_id/comments/:comment_id/reactions/:reaction_id`.

Delete a reaction to a [commit comment](https://docs.github.com/rest/commits/comments#get-a-commit-comment).

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#delete-a-commit-comment-reaction)

## delete_for_issue(owner, repo, issue_number, reaction_id, opts \\ [])

Delete an issue reaction

**Note:** You can also specify a repository by `repository_id` using the route `DELETE /repositories/:repository_id/issues/:issue_number/reactions/:reaction_id`.

Delete a reaction to an [issue](https://docs.github.com/rest/issues/issues#get-an-issue).

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#delete-an-issue-reaction)

## delete_for_issue_comment(owner, repo, comment_id, reaction_id, opts \\ [])

Delete an issue comment reaction

**Note:** You can also specify a repository by `repository_id` using the route `DELETE delete /repositories/:repository_id/issues/comments/:comment_id/reactions/:reaction_id`.

Delete a reaction to an [issue comment](https://docs.github.com/rest/issues/comments#get-an-issue-comment).

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#delete-an-issue-comment-reaction)

## delete_for_pull_request_comment(owner, repo, comment_id, reaction_id, opts \\ [])

Delete a pull request comment reaction

**Note:** You can also specify a repository by `repository_id` using the route `DELETE /repositories/:repository_id/pulls/comments/:comment_id/reactions/:reaction_id.`

Delete a reaction to a [pull request review comment](https://docs.github.com/rest/pulls/comments#get-a-review-comment-for-a-pull-request).

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#delete-a-pull-request-comment-reaction)

## delete_for_release(owner, repo, release_id, reaction_id, opts \\ [])

Delete a release reaction

**Note:** You can also specify a repository by `repository_id` using the route `DELETE delete /repositories/:repository_id/releases/:release_id/reactions/:reaction_id`.

Delete a reaction to a [release](https://docs.github.com/rest/releases/releases#get-a-release).

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#delete-a-release-reaction)

## delete_for_team_discussion(org, team_slug, discussion_number, reaction_id, opts \\ [])

Delete team discussion reaction

**Note:** You can also specify a team or organization with `team_id` and `org_id` using the route `DELETE /organizations/:org_id/team/:team_id/discussions/:discussion_number/reactions/:reaction_id`.

Delete a reaction to a [team discussion](https://docs.github.com/rest/teams/discussions#get-a-discussion).

OAuth app tokens and personal access tokens (classic) need the `write:discussion` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#delete-team-discussion-reaction)

## delete_for_team_discussion_comment(org, team_slug, discussion_number, comment_number, reaction_id, opts \\ [])

Delete team discussion comment reaction

**Note:** You can also specify a team or organization with `team_id` and `org_id` using the route `DELETE /organizations/:org_id/team/:team_id/discussions/:discussion_number/comments/:comment_number/reactions/:reaction_id`.

Delete a reaction to a [team discussion comment](https://docs.github.com/rest/teams/discussion-comments#get-a-discussion-comment).

OAuth app tokens and personal access tokens (classic) need the `write:discussion` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#delete-team-discussion-comment-reaction)

## list_for_commit_comment(owner, repo, comment_id, opts \\ [])

List reactions for a commit comment

List the reactions to a [commit comment](https://docs.github.com/rest/commits/comments#get-a-commit-comment).

## Options

  * `content`: Returns a single [reaction type](https://docs.github.com/rest/reactions/reactions#about-reactions). Omit this parameter to list all reactions to a commit comment.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#list-reactions-for-a-commit-comment)

## list_for_issue(owner, repo, issue_number, opts \\ [])

List reactions for an issue

List the reactions to an [issue](https://docs.github.com/rest/issues/issues#get-an-issue).

## Options

  * `content`: Returns a single [reaction type](https://docs.github.com/rest/reactions/reactions#about-reactions). Omit this parameter to list all reactions to an issue.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#list-reactions-for-an-issue)

## list_for_issue_comment(owner, repo, comment_id, opts \\ [])

List reactions for an issue comment

List the reactions to an [issue comment](https://docs.github.com/rest/issues/comments#get-an-issue-comment).

## Options

  * `content`: Returns a single [reaction type](https://docs.github.com/rest/reactions/reactions#about-reactions). Omit this parameter to list all reactions to an issue comment.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#list-reactions-for-an-issue-comment)

## list_for_pull_request_review_comment(owner, repo, comment_id, opts \\ [])

List reactions for a pull request review comment

List the reactions to a [pull request review comment](https://docs.github.com/rest/pulls/comments#get-a-review-comment-for-a-pull-request).

## Options

  * `content`: Returns a single [reaction type](https://docs.github.com/rest/reactions/reactions#about-reactions). Omit this parameter to list all reactions to a pull request review comment.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#list-reactions-for-a-pull-request-review-comment)

## list_for_release(owner, repo, release_id, opts \\ [])

List reactions for a release

List the reactions to a [release](https://docs.github.com/rest/releases/releases#get-a-release).

## Options

  * `content`: Returns a single [reaction type](https://docs.github.com/rest/reactions/reactions#about-reactions). Omit this parameter to list all reactions to a release.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#list-reactions-for-a-release)

## list_for_team_discussion_comment_in_org(org, team_slug, discussion_number, comment_number, opts \\ [])

List reactions for a team discussion comment

List the reactions to a [team discussion comment](https://docs.github.com/rest/teams/discussion-comments#get-a-discussion-comment).

**Note:** You can also specify a team by `org_id` and `team_id` using the route `GET /organizations/:org_id/team/:team_id/discussions/:discussion_number/comments/:comment_number/reactions`.

OAuth app tokens and personal access tokens (classic) need the `read:discussion` scope to use this endpoint.

## Options

  * `content`: Returns a single [reaction type](https://docs.github.com/rest/reactions/reactions#about-reactions). Omit this parameter to list all reactions to a team discussion comment.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#list-reactions-for-a-team-discussion-comment)

## list_for_team_discussion_comment_legacy(team_id, discussion_number, comment_number, opts \\ [])

List reactions for a team discussion comment (Legacy)

**Deprecation Notice:** This endpoint route is deprecated and will be removed from the Teams API. We recommend migrating your existing code to use the new [`List reactions for a team discussion comment`](https://docs.github.com/rest/reactions/reactions#list-reactions-for-a-team-discussion-comment) endpoint.

List the reactions to a [team discussion comment](https://docs.github.com/rest/teams/discussion-comments#get-a-discussion-comment).

OAuth app tokens and personal access tokens (classic) need the `read:discussion` scope to use this endpoint.

## Options

  * `content`: Returns a single [reaction type](https://docs.github.com/rest/reactions/reactions#about-reactions). Omit this parameter to list all reactions to a team discussion comment.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#list-reactions-for-a-team-discussion-comment-legacy)

## list_for_team_discussion_in_org(org, team_slug, discussion_number, opts \\ [])

List reactions for a team discussion

List the reactions to a [team discussion](https://docs.github.com/rest/teams/discussions#get-a-discussion).

**Note:** You can also specify a team by `org_id` and `team_id` using the route `GET /organizations/:org_id/team/:team_id/discussions/:discussion_number/reactions`.

OAuth app tokens and personal access tokens (classic) need the `read:discussion` scope to use this endpoint.

## Options

  * `content`: Returns a single [reaction type](https://docs.github.com/rest/reactions/reactions#about-reactions). Omit this parameter to list all reactions to a team discussion.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#list-reactions-for-a-team-discussion)

## list_for_team_discussion_legacy(team_id, discussion_number, opts \\ [])

List reactions for a team discussion (Legacy)

**Deprecation Notice:** This endpoint route is deprecated and will be removed from the Teams API. We recommend migrating your existing code to use the new [`List reactions for a team discussion`](https://docs.github.com/rest/reactions/reactions#list-reactions-for-a-team-discussion) endpoint.

List the reactions to a [team discussion](https://docs.github.com/rest/teams/discussions#get-a-discussion).

OAuth app tokens and personal access tokens (classic) need the `read:discussion` scope to use this endpoint.

## Options

  * `content`: Returns a single [reaction type](https://docs.github.com/rest/reactions/reactions#about-reactions). Omit this parameter to list all reactions to a team discussion.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/reactions/reactions#list-reactions-for-a-team-discussion-legacy)