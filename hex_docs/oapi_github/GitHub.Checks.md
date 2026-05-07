# GitHub.Checks

Provides API endpoints related to checks

## create(owner, repo, body, opts \\ [])

Create a check run

Creates a new check run for a specific commit in a repository.

To create a check run, you must use a GitHub App. OAuth apps and authenticated users are not able to create a check suite.

In a check suite, GitHub limits the number of check runs with the same name to 1000. Once these check runs exceed 1000, GitHub will start to automatically delete older check runs.

**Note:** The Checks API only looks for pushes in the repository where the check suite or check run were created. Pushes to a branch in a forked repository are not detected and return an empty `pull_requests` array.

## Resources

  * [API method documentation](https://docs.github.com/rest/checks/runs#create-a-check-run)

## create_suite(owner, repo, body, opts \\ [])

Create a check suite

Creates a check suite manually. By default, check suites are automatically created when you create a [check run](https://docs.github.com/rest/checks/runs). You only need to use this endpoint for manually creating check suites when you've disabled automatic creation using "[Update repository preferences for check suites](https://docs.github.com/rest/checks/suites#update-repository-preferences-for-check-suites)".

**Note:** The Checks API only looks for pushes in the repository where the check suite or check run were created. Pushes to a branch in a forked repository are not detected and return an empty `pull_requests` array and a `null` value for `head_branch`.

OAuth apps and personal access tokens (classic) cannot use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/checks/suites#create-a-check-suite)

## get(owner, repo, check_run_id, opts \\ [])

Get a check run

Gets a single check run using its `id`.

**Note:** The Checks API only looks for pushes in the repository where the check suite or check run were created. Pushes to a branch in a forked repository are not detected and return an empty `pull_requests` array.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint on a private repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/checks/runs#get-a-check-run)

## get_suite(owner, repo, check_suite_id, opts \\ [])

Get a check suite

Gets a single check suite using its `id`.

**Note:** The Checks API only looks for pushes in the repository where the check suite or check run were created. Pushes to a branch in a forked repository are not detected and return an empty `pull_requests` array and a `null` value for `head_branch`.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint on a private repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/checks/suites#get-a-check-suite)

## list_annotations(owner, repo, check_run_id, opts \\ [])

List check run annotations

Lists annotations for a check run using the annotation `id`.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint on a private repository.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/checks/runs#list-check-run-annotations)

## list_for_ref(owner, repo, ref, opts \\ [])

List check runs for a Git reference

Lists check runs for a commit ref. The `ref` can be a SHA, branch name, or a tag name.

**Note:** The endpoints to manage checks only look for pushes in the repository where the check suite or check run were created. Pushes to a branch in a forked repository are not detected and return an empty `pull_requests` array.

If there are more than 1000 check suites on a single git reference, this endpoint will limit check runs to the 1000 most recent check suites. To iterate over all possible check runs, use the [List check suites for a Git reference](https://docs.github.com/rest/reference/checks#list-check-suites-for-a-git-reference) endpoint and provide the `check_suite_id` parameter to the [List check runs in a check suite](https://docs.github.com/rest/reference/checks#list-check-runs-in-a-check-suite) endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint on a private repository.

## Options

  * `check_name`: Returns check runs with the specified `name`.
  * `status`: Returns check runs with the specified `status`.
  * `filter`: Filters check runs by their `completed_at` timestamp. `latest` returns the most recent check runs.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `app_id`

## Resources

  * [API method documentation](https://docs.github.com/rest/checks/runs#list-check-runs-for-a-git-reference)

## list_for_suite(owner, repo, check_suite_id, opts \\ [])

List check runs in a check suite

Lists check runs for a check suite using its `id`.

**Note:** The endpoints to manage checks only look for pushes in the repository where the check suite or check run were created. Pushes to a branch in a forked repository are not detected and return an empty `pull_requests` array.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint on a private repository.

## Options

  * `check_name`: Returns check runs with the specified `name`.
  * `status`: Returns check runs with the specified `status`.
  * `filter`: Filters check runs by their `completed_at` timestamp. `latest` returns the most recent check runs.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/checks/runs#list-check-runs-in-a-check-suite)

## list_suites_for_ref(owner, repo, ref, opts \\ [])

List check suites for a Git reference

Lists check suites for a commit `ref`. The `ref` can be a SHA, branch name, or a tag name.

**Note:** The endpoints to manage checks only look for pushes in the repository where the check suite or check run were created. Pushes to a branch in a forked repository are not detected and return an empty `pull_requests` array and a `null` value for `head_branch`.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint on a private repository.

## Options

  * `app_id`: Filters check suites by GitHub App `id`.
  * `check_name`: Returns check runs with the specified `name`.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/checks/suites#list-check-suites-for-a-git-reference)

## rerequest_run(owner, repo, check_run_id, opts \\ [])

Rerequest a check run

Triggers GitHub to rerequest an existing check run, without pushing new code to a repository. This endpoint will trigger the [`check_run` webhook](https://docs.github.com/webhooks/event-payloads/#check_run) event with the action `rerequested`. When a check run is `rerequested`, its `status` is reset to `queued` and the `conclusion` is cleared.

For more information about how to re-run GitHub Actions jobs, see "[Re-run a job from a workflow run](https://docs.github.com/rest/actions/workflow-runs#re-run-a-job-from-a-workflow-run)".

OAuth apps and personal access tokens (classic) cannot use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/checks/runs#rerequest-a-check-run)

## rerequest_suite(owner, repo, check_suite_id, opts \\ [])

Rerequest a check suite

Triggers GitHub to rerequest an existing check suite, without pushing new code to a repository. This endpoint will trigger the [`check_suite` webhook](https://docs.github.com/webhooks/event-payloads/#check_suite) event with the action `rerequested`. When a check suite is `rerequested`, its `status` is reset to `queued` and the `conclusion` is cleared.

OAuth apps and personal access tokens (classic) cannot use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/checks/suites#rerequest-a-check-suite)

## set_suites_preferences(owner, repo, body, opts \\ [])

Update repository preferences for check suites

Changes the default automatic flow when creating check suites. By default, a check suite is automatically created each time code is pushed to a repository. When you disable the automatic creation of check suites, you can manually [Create a check suite](https://docs.github.com/rest/checks/suites#create-a-check-suite).
You must have admin permissions in the repository to set preferences for check suites.

## Resources

  * [API method documentation](https://docs.github.com/rest/checks/suites#update-repository-preferences-for-check-suites)

## update(owner, repo, check_run_id, body, opts \\ [])

Update a check run

Updates a check run for a specific commit in a repository.

**Note:** The endpoints to manage checks only look for pushes in the repository where the check suite or check run were created. Pushes to a branch in a forked repository are not detected and return an empty `pull_requests` array.

OAuth apps and personal access tokens (classic) cannot use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/checks/runs#update-a-check-run)