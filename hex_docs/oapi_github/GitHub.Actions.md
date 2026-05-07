# GitHub.Actions

Provides API endpoints related to actions

## add_custom_labels_to_self_hosted_runner_for_org(org, runner_id, body, opts \\ [])

Add custom labels to a self-hosted runner for an organization

Adds custom labels to a self-hosted runner configured in an organization.

Authenticated users must have admin access to the organization to use this endpoint.

OAuth tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#add-custom-labels-to-a-self-hosted-runner-for-an-organization)

## add_custom_labels_to_self_hosted_runner_for_repo(owner, repo, runner_id, body, opts \\ [])

Add custom labels to a self-hosted runner for a repository

Adds custom labels to a self-hosted runner configured in a repository.

Authenticated users must have admin access to the organization to use this endpoint.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#add-custom-labels-to-a-self-hosted-runner-for-a-repository)

## add_selected_repo_to_org_secret(org, secret_name, repository_id, opts \\ [])

Add selected repository to an organization secret

Adds a repository to an organization secret when the `visibility` for
repository access is set to `selected`. For more information about setting the visibility, see [Create or
update an organization secret](https://docs.github.com/rest/actions/secrets#create-or-update-an-organization-secret).

Authenticated users must have collaborator access to a repository to create, update, or read secrets.

OAuth tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/secrets#add-selected-repository-to-an-organization-secret)

## add_selected_repo_to_org_variable(org, name, repository_id, opts \\ [])

Add selected repository to an organization variable

Adds a repository to an organization variable that is available to selected repositories.
Organization variables that are available to selected repositories have their `visibility` field set to `selected`.

Authenticated users must have collaborator access to a repository to create, update, or read secrets.

OAuth tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/variables#add-selected-repository-to-an-organization-variable)

## approve_workflow_run(owner, repo, run_id, opts \\ [])

Approve a workflow run for a fork pull request

Approves a workflow run for a pull request from a public fork of a first time contributor. For more information, see ["Approving workflow runs from public forks](https://docs.github.com/actions/managing-workflow-runs/approving-workflow-runs-from-public-forks)."

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-runs#approve-a-workflow-run-for-a-fork-pull-request)

## cancel_workflow_run(owner, repo, run_id, opts \\ [])

Cancel a workflow run

Cancels a workflow run using its `id`.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-runs#cancel-a-workflow-run)

## create_environment_variable(owner, repo, environment_name, body, opts \\ [])

Create an environment variable

Create an environment variable that you can reference in a GitHub Actions workflow.

Authenticated users must have collaborator access to a repository to create, update, or read variables.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/variables#create-an-environment-variable)

## create_or_update_environment_secret(owner, repo, environment_name, secret_name, body, opts \\ [])

Create or update an environment secret

Creates or updates an environment secret with an encrypted value. Encrypt your secret using
[LibSodium](https://libsodium.gitbook.io/doc/bindings_for_other_languages). For more information, see "[Encrypting secrets for the REST API](https://docs.github.com/rest/guides/encrypting-secrets-for-the-rest-api)."

Authenticated users must have collaborator access to a repository to create, update, or read secrets.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/secrets#create-or-update-an-environment-secret)

## create_or_update_org_secret(org, secret_name, body, opts \\ [])

Create or update an organization secret

Creates or updates an organization secret with an encrypted value. Encrypt your secret using
[LibSodium](https://libsodium.gitbook.io/doc/bindings_for_other_languages). For more information, see "[Encrypting secrets for the REST API](https://docs.github.com/rest/guides/encrypting-secrets-for-the-rest-api)."

Authenticated users must have collaborator access to a repository to create, update, or read secrets.

OAuth tokens and personal access tokens (classic) need the`admin:org` scope to use this endpoint. If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/secrets#create-or-update-an-organization-secret)

## create_or_update_repo_secret(owner, repo, secret_name, body, opts \\ [])

Create or update a repository secret

Creates or updates a repository secret with an encrypted value. Encrypt your secret using
[LibSodium](https://libsodium.gitbook.io/doc/bindings_for_other_languages). For more information, see "[Encrypting secrets for the REST API](https://docs.github.com/rest/guides/encrypting-secrets-for-the-rest-api)."

Authenticated users must have collaborator access to a repository to create, update, or read secrets.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/secrets#create-or-update-a-repository-secret)

## create_org_variable(org, body, opts \\ [])

Create an organization variable

Creates an organization variable that you can reference in a GitHub Actions workflow.

Authenticated users must have collaborator access to a repository to create, update, or read variables.

OAuth tokens and personal access tokens (classic) need the`admin:org` scope to use this endpoint. If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/variables#create-an-organization-variable)

## create_registration_token_for_org(org, opts \\ [])

Create a registration token for an organization

Returns a token that you can pass to the `config` script. The token expires after one hour.

For example, you can replace `TOKEN` in the following example with the registration token provided by this endpoint to configure your self-hosted runner:

```
./config.sh --url https://github.com/octo-org --token TOKEN
```

Authenticated users must have admin access to the organization to use this endpoint.

OAuth tokens and personal access tokens (classic) need the`admin:org` scope to use this endpoint. If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#create-a-registration-token-for-an-organization)

## create_registration_token_for_repo(owner, repo, opts \\ [])

Create a registration token for a repository

Returns a token that you can pass to the `config` script. The token expires after one hour.

For example, you can replace `TOKEN` in the following example with the registration token provided by this endpoint to configure your self-hosted runner:

```
./config.sh --url https://github.com/octo-org --token TOKEN
```

Authenticated users must have admin access to the repository to use this endpoint.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#create-a-registration-token-for-a-repository)

## create_remove_token_for_org(org, opts \\ [])

Create a remove token for an organization

Returns a token that you can pass to the `config` script to remove a self-hosted runner from an organization. The token expires after one hour.

For example, you can replace `TOKEN` in the following example with the registration token provided by this endpoint to remove your self-hosted runner from an organization:

```
./config.sh remove --token TOKEN
```

Authenticated users must have admin access to the organization to use this endpoint.

OAuth tokens and personal access tokens (classic) need the`admin:org` scope to use this endpoint. If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#create-a-remove-token-for-an-organization)

## create_remove_token_for_repo(owner, repo, opts \\ [])

Create a remove token for a repository

Returns a token that you can pass to the `config` script to remove a self-hosted runner from an repository. The token expires after one hour.

For example, you can replace `TOKEN` in the following example with the registration token provided by this endpoint to remove your self-hosted runner from an organization:

```
./config.sh remove --token TOKEN
```

Authenticated users must have admin access to the repository to use this endpoint.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#create-a-remove-token-for-a-repository)

## create_repo_variable(owner, repo, body, opts \\ [])

Create a repository variable

Creates a repository variable that you can reference in a GitHub Actions workflow.

Authenticated users must have collaborator access to a repository to create, update, or read variables.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/variables#create-a-repository-variable)

## create_workflow_dispatch(owner, repo, workflow_id, body, opts \\ [])

Create a workflow dispatch event

You can use this endpoint to manually trigger a GitHub Actions workflow run. You can replace `workflow_id` with the workflow file name. For example, you could use `main.yaml`.

You must configure your GitHub Actions workflow to run when the [`workflow_dispatch` webhook](https://docs.github.com/developers/webhooks-and-events/webhook-events-and-payloads#workflow_dispatch) event occurs. The `inputs` are configured in the workflow file. For more information about how to configure the `workflow_dispatch` event in the workflow file, see "[Events that trigger workflows](https://docs.github.com/actions/reference/events-that-trigger-workflows#workflow_dispatch)."

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflows#create-a-workflow-dispatch-event)

## delete_actions_cache_by_id(owner, repo, cache_id, opts \\ [])

Delete a GitHub Actions cache for a repository (using a cache ID)

Deletes a GitHub Actions cache for a repository, using a cache ID.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/cache#delete-a-github-actions-cache-for-a-repository-using-a-cache-id)

## delete_actions_cache_by_key(owner, repo, opts \\ [])

Delete GitHub Actions caches for a repository (using a cache key)

Deletes one or more GitHub Actions caches for a repository, using a complete cache key. By default, all caches that match the provided key are deleted, but you can optionally provide a Git ref to restrict deletions to caches that match both the provided key and the Git ref.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Options

  * `key`: A key for identifying the cache.
  * `ref`: The full Git reference for narrowing down the cache. The `ref` for a branch should be formatted as `refs/heads/<branch name>`. To reference a pull request use `refs/pull/<number>/merge`.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/cache#delete-github-actions-caches-for-a-repository-using-a-cache-key)

## delete_artifact(owner, repo, artifact_id, opts \\ [])

Delete an artifact

Deletes an artifact for a workflow run.
OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/artifacts#delete-an-artifact)

## delete_environment_secret(owner, repo, environment_name, secret_name, opts \\ [])

Delete an environment secret

Deletes a secret in an environment using the secret name.

Authenticated users must have collaborator access to a repository to create, update, or read secrets.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/secrets#delete-an-environment-secret)

## delete_environment_variable(owner, repo, name, environment_name, opts \\ [])

Delete an environment variable

Deletes an environment variable using the variable name.

Authenticated users must have collaborator access to a repository to create, update, or read variables.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/variables#delete-an-environment-variable)

## delete_org_secret(org, secret_name, opts \\ [])

Delete an organization secret

Deletes a secret in an organization using the secret name.

Authenticated users must have collaborator access to a repository to create, update, or read secrets.

OAuth tokens and personal access tokens (classic) need the`admin:org` scope to use this endpoint. If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/secrets#delete-an-organization-secret)

## delete_org_variable(org, name, opts \\ [])

Delete an organization variable

Deletes an organization variable using the variable name.

Authenticated users must have collaborator access to a repository to create, update, or read variables.

OAuth tokens and personal access tokens (classic) need the`admin:org` scope to use this endpoint. If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/variables#delete-an-organization-variable)

## delete_repo_secret(owner, repo, secret_name, opts \\ [])

Delete a repository secret

Deletes a secret in a repository using the secret name.

Authenticated users must have collaborator access to a repository to create, update, or read secrets.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/secrets#delete-a-repository-secret)

## delete_repo_variable(owner, repo, name, opts \\ [])

Delete a repository variable

Deletes a repository variable using the variable name.

Authenticated users must have collaborator access to a repository to create, update, or read variables.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/variables#delete-a-repository-variable)

## delete_self_hosted_runner_from_org(org, runner_id, opts \\ [])

Delete a self-hosted runner from an organization

Forces the removal of a self-hosted runner from an organization. You can use this endpoint to completely remove the runner when the machine you were using no longer exists.

Authenticated users must have admin access to the organization to use this endpoint.

OAuth tokens and personal access tokens (classic) need the`admin:org` scope to use this endpoint. If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#delete-a-self-hosted-runner-from-an-organization)

## delete_self_hosted_runner_from_repo(owner, repo, runner_id, opts \\ [])

Delete a self-hosted runner from a repository

Forces the removal of a self-hosted runner from a repository. You can use this endpoint to completely remove the runner when the machine you were using no longer exists.

Authenticated users must have admin access to the repository to use this endpoint.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#delete-a-self-hosted-runner-from-a-repository)

## delete_workflow_run(owner, repo, run_id, opts \\ [])

Delete a workflow run

Deletes a specific workflow run.

Anyone with write access to the repository can use this endpoint.

If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-runs#delete-a-workflow-run)

## delete_workflow_run_logs(owner, repo, run_id, opts \\ [])

Delete workflow run logs

Deletes all logs for a workflow run.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-runs#delete-workflow-run-logs)

## disable_selected_repository_github_actions_organization(org, repository_id, opts \\ [])

Disable a selected repository for GitHub Actions in an organization

Removes a repository from the list of selected repositories that are enabled for GitHub Actions in an organization. To use this endpoint, the organization permission policy for `enabled_repositories` must be configured to `selected`. For more information, see "[Set GitHub Actions permissions for an organization](#set-github-actions-permissions-for-an-organization)."

OAuth tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/permissions#disable-a-selected-repository-for-github-actions-in-an-organization)

## disable_workflow(owner, repo, workflow_id, opts \\ [])

Disable a workflow

Disables a workflow and sets the `state` of the workflow to `disabled_manually`. You can replace `workflow_id` with the workflow file name. For example, you could use `main.yaml`.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflows#disable-a-workflow)

## download_artifact(owner, repo, artifact_id, archive_format, opts \\ [])

Download an artifact

Gets a redirect URL to download an archive for a repository. This URL expires after 1 minute. Look for `Location:` in
the response header to find the URL for the download. The `:archive_format` must be `zip`.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/artifacts#download-an-artifact)

## download_job_logs_for_workflow_run(owner, repo, job_id, opts \\ [])

Download job logs for a workflow run

Gets a redirect URL to download a plain text file of logs for a workflow job. This link expires after 1 minute. Look
for `Location:` in the response header to find the URL for the download.

Anyone with read access to the repository can use this endpoint.

If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-jobs#download-job-logs-for-a-workflow-run)

## download_workflow_run_attempt_logs(owner, repo, run_id, attempt_number, opts \\ [])

Download workflow run attempt logs

Gets a redirect URL to download an archive of log files for a specific workflow run attempt. This link expires after
1 minute. Look for `Location:` in the response header to find the URL for the download.

Anyone with read access to the repository can use this endpoint.

If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-runs#download-workflow-run-attempt-logs)

## download_workflow_run_logs(owner, repo, run_id, opts \\ [])

Download workflow run logs

Gets a redirect URL to download an archive of log files for a workflow run. This link expires after 1 minute. Look for
`Location:` in the response header to find the URL for the download.

Anyone with read access to the repository can use this endpoint.

If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-runs#download-workflow-run-logs)

## enable_selected_repository_github_actions_organization(org, repository_id, opts \\ [])

Enable a selected repository for GitHub Actions in an organization

Adds a repository to the list of selected repositories that are enabled for GitHub Actions in an organization. To use this endpoint, the organization permission policy for `enabled_repositories` must be must be configured to `selected`. For more information, see "[Set GitHub Actions permissions for an organization](#set-github-actions-permissions-for-an-organization)."

OAuth tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/permissions#enable-a-selected-repository-for-github-actions-in-an-organization)

## enable_workflow(owner, repo, workflow_id, opts \\ [])

Enable a workflow

Enables a workflow and sets the `state` of the workflow to `active`. You can replace `workflow_id` with the workflow file name. For example, you could use `main.yaml`.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflows#enable-a-workflow)

## force_cancel_workflow_run(owner, repo, run_id, opts \\ [])

Force cancel a workflow run

Cancels a workflow run and bypasses conditions that would otherwise cause a workflow execution to continue, such as an `always()` condition on a job.
You should only use this endpoint to cancel a workflow run when the workflow run is not responding to [`POST /repos/{owner}/{repo}/actions/runs/{run_id}/cancel`](https://docs.github.com/rest/actions/workflow-runs#cancel-a-workflow-run).

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-runs#force-cancel-a-workflow-run)

## generate_runner_jitconfig_for_org(org, body, opts \\ [])

Create configuration for a just-in-time runner for an organization

Generates a configuration that can be passed to the runner application at startup.

The authenticated user must have admin access to the organization.

OAuth tokens and personal access tokens (classic) need the`admin:org` scope to use this endpoint. If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#create-configuration-for-a-just-in-time-runner-for-an-organization)

## generate_runner_jitconfig_for_repo(owner, repo, body, opts \\ [])

Create configuration for a just-in-time runner for a repository

Generates a configuration that can be passed to the runner application at startup.

The authenticated user must have admin access to the repository.

OAuth tokens and personal access tokens (classic) need the`repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#create-configuration-for-a-just-in-time-runner-for-a-repository)

## get_actions_cache_list(owner, repo, opts \\ [])

List GitHub Actions caches for a repository

Lists the GitHub Actions caches for a repository.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `ref`: The full Git reference for narrowing down the cache. The `ref` for a branch should be formatted as `refs/heads/<branch name>`. To reference a pull request use `refs/pull/<number>/merge`.
  * `key`: An explicit key or prefix for identifying the cache
  * `sort`: The property to sort the results by. `created_at` means when the cache was created. `last_accessed_at` means when the cache was last accessed. `size_in_bytes` is the size of the cache in bytes.
  * `direction`: The direction to sort the results by.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/cache#list-github-actions-caches-for-a-repository)

## get_actions_cache_usage(owner, repo, opts \\ [])

Get GitHub Actions cache usage for a repository

Gets GitHub Actions cache usage for a repository.
The data fetched using this API is refreshed approximately every 5 minutes, so values returned from this endpoint may take at least 5 minutes to get updated.

Anyone with read access to the repository can use this endpoint.

If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/cache#get-github-actions-cache-usage-for-a-repository)

## get_actions_cache_usage_by_repo_for_org(org, opts \\ [])

List repositories with GitHub Actions cache usage for an organization

Lists repositories and their GitHub Actions cache usage for an organization.
The data fetched using this API is refreshed approximately every 5 minutes, so values returned from this endpoint may take at least 5 minutes to get updated.

OAuth tokens and personal access tokens (classic) need the `read:org` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/cache#list-repositories-with-github-actions-cache-usage-for-an-organization)

## get_actions_cache_usage_for_org(org, opts \\ [])

Get GitHub Actions cache usage for an organization

Gets the total GitHub Actions cache usage for an organization.
The data fetched using this API is refreshed approximately every 5 minutes, so values returned from this endpoint may take at least 5 minutes to get updated.

OAuth tokens and personal access tokens (classic) need the `read:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/cache#get-github-actions-cache-usage-for-an-organization)

## get_allowed_actions_organization(org, opts \\ [])

Get allowed actions and reusable workflows for an organization

Gets the selected actions and reusable workflows that are allowed in an organization. To use this endpoint, the organization permission policy for `allowed_actions` must be configured to `selected`. For more information, see "[Set GitHub Actions permissions for an organization](#set-github-actions-permissions-for-an-organization)."

OAuth tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/permissions#get-allowed-actions-and-reusable-workflows-for-an-organization)

## get_allowed_actions_repository(owner, repo, opts \\ [])

Get allowed actions and reusable workflows for a repository

Gets the settings for selected actions and reusable workflows that are allowed in a repository. To use this endpoint, the repository policy for `allowed_actions` must be configured to `selected`. For more information, see "[Set GitHub Actions permissions for a repository](#set-github-actions-permissions-for-a-repository)."

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/permissions#get-allowed-actions-and-reusable-workflows-for-a-repository)

## get_artifact(owner, repo, artifact_id, opts \\ [])

Get an artifact

Gets a specific artifact for a workflow run.

Anyone with read access to the repository can use this endpoint.

If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/artifacts#get-an-artifact)

## get_custom_oidc_sub_claim_for_repo(owner, repo, opts \\ [])

Get the customization template for an OIDC subject claim for a repository

Gets the customization template for an OpenID Connect (OIDC) subject claim.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/oidc#get-the-customization-template-for-an-oidc-subject-claim-for-a-repository)

## get_environment_public_key(owner, repo, environment_name, opts \\ [])

Get an environment public key

Get the public key for an environment, which you need to encrypt environment
secrets. You need to encrypt a secret before you can create or update secrets.

Anyone with read access to the repository can use this endpoint.

If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/secrets#get-an-environment-public-key)

## get_environment_secret(owner, repo, environment_name, secret_name, opts \\ [])

Get an environment secret

Gets a single environment secret without revealing its encrypted value.

Authenticated users must have collaborator access to a repository to create, update, or read secrets.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/secrets#get-an-environment-secret)

## get_environment_variable(owner, repo, environment_name, name, opts \\ [])

Get an environment variable

Gets a specific variable in an environment.

Authenticated users must have collaborator access to a repository to create, update, or read variables.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/variables#get-an-environment-variable)

## get_github_actions_default_workflow_permissions_organization(org, opts \\ [])

Get default workflow permissions for an organization

Gets the default workflow permissions granted to the `GITHUB_TOKEN` when running workflows in an organization,
as well as whether GitHub Actions can submit approving pull request reviews. For more information, see
"[Setting the permissions of the GITHUB_TOKEN for your organization](https://docs.github.com/organizations/managing-organization-settings/disabling-or-limiting-github-actions-for-your-organization#setting-the-permissions-of-the-github_token-for-your-organization)."

OAuth tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/permissions#get-default-workflow-permissions-for-an-organization)

## get_github_actions_default_workflow_permissions_repository(owner, repo, opts \\ [])

Get default workflow permissions for a repository

Gets the default workflow permissions granted to the `GITHUB_TOKEN` when running workflows in a repository,
as well as if GitHub Actions can submit approving pull request reviews.
For more information, see "[Setting the permissions of the GITHUB_TOKEN for your repository](https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository#setting-the-permissions-of-the-github_token-for-your-repository)."

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/permissions#get-default-workflow-permissions-for-a-repository)

## get_github_actions_permissions_organization(org, opts \\ [])

Get GitHub Actions permissions for an organization

Gets the GitHub Actions permissions policy for repositories and allowed actions and reusable workflows in an organization.

OAuth tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/permissions#get-github-actions-permissions-for-an-organization)

## get_github_actions_permissions_repository(owner, repo, opts \\ [])

Get GitHub Actions permissions for a repository

Gets the GitHub Actions permissions policy for a repository, including whether GitHub Actions is enabled and the actions and reusable workflows allowed to run in the repository.

OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/permissions#get-github-actions-permissions-for-a-repository)

## get_job_for_workflow_run(owner, repo, job_id, opts \\ [])

Get a job for a workflow run

Gets a specific job in a workflow run.

Anyone with read access to the repository can use this endpoint.

If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-jobs#get-a-job-for-a-workflow-run)

## get_org_public_key(org, opts \\ [])

Get an organization public key

Gets your public key, which you need to encrypt secrets. You need to
encrypt a secret before you can create or update secrets.

The authenticated user must have collaborator access to a repository to create, update, or read secrets.

OAuth tokens and personal access tokens (classic) need the`admin:org` scope to use this endpoint. If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/secrets#get-an-organization-public-key)

## get_org_secret(org, secret_name, opts \\ [])

Get an organization secret

Gets a single organization secret without revealing its encrypted value.

The authenticated user must have collaborator access to a repository to create, update, or read secrets

OAuth tokens and personal access tokens (classic) need the`admin:org` scope to use this endpoint. If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/secrets#get-an-organization-secret)

## get_org_variable(org, name, opts \\ [])

Get an organization variable

Gets a specific variable in an organization.

The authenticated user must have collaborator access to a repository to create, update, or read variables.

OAuth tokens and personal access tokens (classic) need the`admin:org` scope to use this endpoint. If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/variables#get-an-organization-variable)

## get_pending_deployments_for_run(owner, repo, run_id, opts \\ [])

Get pending deployments for a workflow run

Get all deployment environments for a workflow run that are waiting for protection rules to pass.

Anyone with read access to the repository can use this endpoint.

If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-runs#get-pending-deployments-for-a-workflow-run)

## get_repo_public_key(owner, repo, opts \\ [])

Get a repository public key

Gets your public key, which you need to encrypt secrets. You need to
encrypt a secret before you can create or update secrets.

Anyone with read access to the repository can use this endpoint.

If the repository is private, OAuth tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/secrets#get-a-repository-public-key)

## get_repo_secret(owner, repo, secret_name, opts \\ [])

Get a repository secret

Gets a single repository secret without revealing its encrypted value.

The authenticated user must have collaborator access to the repository to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/secrets#get-a-repository-secret)

## get_repo_variable(owner, repo, name, opts \\ [])

Get a repository variable

Gets a specific variable in a repository.

The authenticated user must have collaborator access to the repository to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/variables#get-a-repository-variable)

## get_reviews_for_run(owner, repo, run_id, opts \\ [])

Get the review history for a workflow run

Anyone with read access to the repository can use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-runs#get-the-review-history-for-a-workflow-run)

## get_self_hosted_runner_for_org(org, runner_id, opts \\ [])

Get a self-hosted runner for an organization

Gets a specific self-hosted runner configured in an organization.

Authenticated users must have admin access to the organization to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, the `repo` scope is also required.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#get-a-self-hosted-runner-for-an-organization)

## get_self_hosted_runner_for_repo(owner, repo, runner_id, opts \\ [])

Get a self-hosted runner for a repository

Gets a specific self-hosted runner configured in a repository.

Authenticated users must have admin access to the repository to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#get-a-self-hosted-runner-for-a-repository)

## get_workflow(owner, repo, workflow_id, opts \\ [])

Get a workflow

Gets a specific workflow. You can replace `workflow_id` with the workflow
file name. For example, you could use `main.yaml`.

Anyone with read access to the repository can use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflows#get-a-workflow)

## get_workflow_access_to_repository(owner, repo, opts \\ [])

Get the level of access for workflows outside of the repository

Gets the level of access that workflows outside of the repository have to actions and reusable workflows in the repository.
This endpoint only applies to private repositories.
For more information, see "[Allowing access to components in a private repository](https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository#allowing-access-to-components-in-a-private-repository)."

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/permissions#get-the-level-of-access-for-workflows-outside-of-the-repository)

## get_workflow_run(owner, repo, run_id, opts \\ [])

Get a workflow run

Gets a specific workflow run.

Anyone with read access to the repository can use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.

## Options

  * `exclude_pull_requests`: If `true` pull requests are omitted from the response (empty array).

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-runs#get-a-workflow-run)

## get_workflow_run_attempt(owner, repo, run_id, attempt_number, opts \\ [])

Get a workflow run attempt

Gets a specific workflow run attempt.

Anyone with read access to the repository can use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.

## Options

  * `exclude_pull_requests`: If `true` pull requests are omitted from the response (empty array).

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-runs#get-a-workflow-run-attempt)

## get_workflow_run_usage(owner, repo, run_id, opts \\ [])

Get workflow run usage

Gets the number of billable minutes and total run time for a specific workflow run. Billable minutes only apply to workflows in private repositories that use GitHub-hosted runners. Usage is listed for each GitHub-hosted runner operating system in milliseconds. Any job re-runs are also included in the usage. The usage does not include the multiplier for macOS and Windows runners and is not rounded up to the nearest whole minute. For more information, see "[Managing billing for GitHub Actions](https://docs.github.com/github/setting-up-and-managing-billing-and-payments-on-github/managing-billing-for-github-actions)".

Anyone with read access to the repository can use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-runs#get-workflow-run-usage)

## get_workflow_usage(owner, repo, workflow_id, opts \\ [])

Get workflow usage

Gets the number of billable minutes used by a specific workflow during the current billing cycle. Billable minutes only apply to workflows in private repositories that use GitHub-hosted runners. Usage is listed for each GitHub-hosted runner operating system in milliseconds. Any job re-runs are also included in the usage. The usage does not include the multiplier for macOS and Windows runners and is not rounded up to the nearest whole minute. For more information, see "[Managing billing for GitHub Actions](https://docs.github.com/github/setting-up-and-managing-billing-and-payments-on-github/managing-billing-for-github-actions)".

You can replace `workflow_id` with the workflow file name. For example, you could use `main.yaml`.

Anyone with read access to the repository can use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflows#get-workflow-usage)

## list_artifacts_for_repo(owner, repo, opts \\ [])

List artifacts for a repository

Lists all artifacts for a repository.

Anyone with read access to the repository can use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `name`: The name field of an artifact. When specified, only artifacts with this name will be returned.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/artifacts#list-artifacts-for-a-repository)

## list_environment_secrets(owner, repo, environment_name, opts \\ [])

List environment secrets

Lists all secrets available in an environment without revealing their
encrypted values.

Authenticated users must have collaborator access to a repository to create, update, or read secrets.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/secrets#list-environment-secrets)

## list_environment_variables(owner, repo, environment_name, opts \\ [])

List environment variables

Lists all environment variables.

Authenticated users must have collaborator access to a repository to create, update, or read variables.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 30). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/variables#list-environment-variables)

## list_jobs_for_workflow_run(owner, repo, run_id, opts \\ [])

List jobs for a workflow run

Lists jobs for a workflow run. You can use parameters to narrow the list of results. For more information
about using parameters, see [Parameters](https://docs.github.com/rest/guides/getting-started-with-the-rest-api#parameters).

Anyone with read access to the repository can use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.

## Options

  * `filter`: Filters jobs by their `completed_at` timestamp. `latest` returns jobs from the most recent execution of the workflow run. `all` returns all jobs for a workflow run, including from old executions of the workflow run.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-jobs#list-jobs-for-a-workflow-run)

## list_jobs_for_workflow_run_attempt(owner, repo, run_id, attempt_number, opts \\ [])

List jobs for a workflow run attempt

Lists jobs for a specific workflow run attempt. You can use parameters to narrow the list of results. For more information
about using parameters, see [Parameters](https://docs.github.com/rest/guides/getting-started-with-the-rest-api#parameters).

Anyone with read access to the repository can use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint  with a private repository.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-jobs#list-jobs-for-a-workflow-run-attempt)

## list_labels_for_self_hosted_runner_for_org(org, runner_id, opts \\ [])

List labels for a self-hosted runner for an organization

Lists all labels for a self-hosted runner configured in an organization.

Authenticated users must have admin access to the organization to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, the `repo` scope is also required.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#list-labels-for-a-self-hosted-runner-for-an-organization)

## list_labels_for_self_hosted_runner_for_repo(owner, repo, runner_id, opts \\ [])

List labels for a self-hosted runner for a repository

Lists all labels for a self-hosted runner configured in a repository.

Authenticated users must have admin access to the repository to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#list-labels-for-a-self-hosted-runner-for-a-repository)

## list_org_secrets(org, opts \\ [])

List organization secrets

Lists all secrets available in an organization without revealing their
encrypted values.

Authenticated users must have collaborator access to a repository to create, update, or read secrets.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, the `repo` scope is also required.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/secrets#list-organization-secrets)

## list_org_variables(org, opts \\ [])

List organization variables

Lists all organization variables.

Authenticated users must have collaborator access to a repository to create, update, or read variables.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, the `repo` scope is also required.

## Options

  * `per_page`: The number of results per page (max 30). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/variables#list-organization-variables)

## list_repo_organization_secrets(owner, repo, opts \\ [])

List repository organization secrets

Lists all organization secrets shared with a repository without revealing their encrypted
values.

Authenticated users must have collaborator access to a repository to create, update, or read secrets.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/secrets#list-repository-organization-secrets)

## list_repo_organization_variables(owner, repo, opts \\ [])

List repository organization variables

Lists all organization variables shared with a repository.

Authenticated users must have collaborator access to a repository to create, update, or read variables.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 30). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/variables#list-repository-organization-variables)

## list_repo_secrets(owner, repo, opts \\ [])

List repository secrets

Lists all secrets available in a repository without revealing their encrypted
values.

Authenticated users must have collaborator access to a repository to create, update, or read secrets.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/secrets#list-repository-secrets)

## list_repo_variables(owner, repo, opts \\ [])

List repository variables

Lists all repository variables.

Authenticated users must have collaborator access to a repository to create, update, or read variables.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 30). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/variables#list-repository-variables)

## list_repo_workflows(owner, repo, opts \\ [])

List repository workflows

Lists the workflows in a repository.

Anyone with read access to the repository can use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflows#list-repository-workflows)

## list_runner_applications_for_org(org, opts \\ [])

List runner applications for an organization

Lists binaries for the runner application that you can download and run.

Authenticated users must have admin access to the organization to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.  If the repository is private, the `repo` scope is also required.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#list-runner-applications-for-an-organization)

## list_runner_applications_for_repo(owner, repo, opts \\ [])

List runner applications for a repository

Lists binaries for the runner application that you can download and run.

Authenticated users must have admin access to the repository to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#list-runner-applications-for-a-repository)

## list_selected_repos_for_org_secret(org, secret_name, opts \\ [])

List selected repositories for an organization secret

Lists all repositories that have been selected when the `visibility`
for repository access to a secret is set to `selected`.

Authenticated users must have collaborator access to a repository to create, update, or read secrets.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, the `repo` scope is also required.

## Options

  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/secrets#list-selected-repositories-for-an-organization-secret)

## list_selected_repos_for_org_variable(org, name, opts \\ [])

List selected repositories for an organization variable

Lists all repositories that can access an organization variable
that is available to selected repositories.

Authenticated users must have collaborator access to a repository to create, update, or read variables.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, the `repo` scope is also required.

## Options

  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/variables#list-selected-repositories-for-an-organization-variable)

## list_selected_repositories_enabled_github_actions_organization(org, opts \\ [])

List selected repositories enabled for GitHub Actions in an organization

Lists the selected repositories that are enabled for GitHub Actions in an organization. To use this endpoint, the organization permission policy for `enabled_repositories` must be configured to `selected`. For more information, see "[Set GitHub Actions permissions for an organization](#set-github-actions-permissions-for-an-organization)."

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/permissions#list-selected-repositories-enabled-for-github-actions-in-an-organization)

## list_self_hosted_runners_for_org(org, opts \\ [])

List self-hosted runners for an organization

Lists all self-hosted runners configured in an organization.

Authenticated users must have admin access to the organization to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, the `repo` scope is also required.

## Options

  * `name`: The name of a self-hosted runner.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#list-self-hosted-runners-for-an-organization)

## list_self_hosted_runners_for_repo(owner, repo, opts \\ [])

List self-hosted runners for a repository

Lists all self-hosted runners configured in a repository.

Authenticated users must have admin access to the repository to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Options

  * `name`: The name of a self-hosted runner.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#list-self-hosted-runners-for-a-repository)

## list_workflow_run_artifacts(owner, repo, run_id, opts \\ [])

List workflow run artifacts

Lists artifacts for a workflow run.

Anyone with read access to the repository can use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `name`: The name field of an artifact. When specified, only artifacts with this name will be returned.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/artifacts#list-workflow-run-artifacts)

## list_workflow_runs(owner, repo, workflow_id, opts \\ [])

List workflow runs for a workflow

List all workflow runs for a workflow. You can replace `workflow_id` with the workflow file name. For example, you could use `main.yaml`. You can use parameters to narrow the list of results. For more information about using parameters, see [Parameters](https://docs.github.com/rest/guides/getting-started-with-the-rest-api#parameters).

Anyone with read access to the repository can use this endpoint

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.

## Options

  * `actor`: Returns someone's workflow runs. Use the login for the user who created the `push` associated with the check suite or workflow run.
  * `branch`: Returns workflow runs associated with a branch. Use the name of the branch of the `push`.
  * `event`: Returns workflow run triggered by the event you specify. For example, `push`, `pull_request` or `issue`. For more information, see "[Events that trigger workflows](https://docs.github.com/actions/automating-your-workflow-with-github-actions/events-that-trigger-workflows)."
  * `status`: Returns workflow runs with the check run `status` or `conclusion` that you specify. For example, a conclusion can be `success` or a status can be `in_progress`. Only GitHub Actions can set a status of `waiting`, `pending`, or `requested`.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `created`: Returns workflow runs created within the given date-time range. For more information on the syntax, see "[Understanding the search syntax](https://docs.github.com/search-github/getting-started-with-searching-on-github/understanding-the-search-syntax#query-for-dates)."
  * `exclude_pull_requests`: If `true` pull requests are omitted from the response (empty array).
  * `check_suite_id`: Returns workflow runs with the `check_suite_id` that you specify.
  * `head_sha`: Only returns workflow runs that are associated with the specified `head_sha`.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-runs#list-workflow-runs-for-a-workflow)

## list_workflow_runs_for_repo(owner, repo, opts \\ [])

List workflow runs for a repository

Lists all workflow runs for a repository. You can use parameters to narrow the list of results. For more information about using parameters, see [Parameters](https://docs.github.com/rest/guides/getting-started-with-the-rest-api#parameters).

Anyone with read access to the repository can use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.

This API will return up to 1,000 results for each search when using the following parameters: `actor`, `branch`, `check_suite_id`, `created`, `event`, `head_sha`, `status`.

## Options

  * `actor`: Returns someone's workflow runs. Use the login for the user who created the `push` associated with the check suite or workflow run.
  * `branch`: Returns workflow runs associated with a branch. Use the name of the branch of the `push`.
  * `event`: Returns workflow run triggered by the event you specify. For example, `push`, `pull_request` or `issue`. For more information, see "[Events that trigger workflows](https://docs.github.com/actions/automating-your-workflow-with-github-actions/events-that-trigger-workflows)."
  * `status`: Returns workflow runs with the check run `status` or `conclusion` that you specify. For example, a conclusion can be `success` or a status can be `in_progress`. Only GitHub Actions can set a status of `waiting`, `pending`, or `requested`.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `created`: Returns workflow runs created within the given date-time range. For more information on the syntax, see "[Understanding the search syntax](https://docs.github.com/search-github/getting-started-with-searching-on-github/understanding-the-search-syntax#query-for-dates)."
  * `exclude_pull_requests`: If `true` pull requests are omitted from the response (empty array).
  * `check_suite_id`: Returns workflow runs with the `check_suite_id` that you specify.
  * `head_sha`: Only returns workflow runs that are associated with the specified `head_sha`.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-runs#list-workflow-runs-for-a-repository)

## re_run_job_for_workflow_run(owner, repo, job_id, body, opts \\ [])

Re-run a job from a workflow run

Re-run a job and its dependent jobs in a workflow run.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-runs#re-run-a-job-from-a-workflow-run)

## re_run_workflow(owner, repo, run_id, body, opts \\ [])

Re-run a workflow

Re-runs your workflow run using its `id`.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-runs#re-run-a-workflow)

## re_run_workflow_failed_jobs(owner, repo, run_id, body, opts \\ [])

Re-run failed jobs from a workflow run

Re-run all of the failed jobs and their dependent jobs in a workflow run using the `id` of the workflow run.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-runs#re-run-failed-jobs-from-a-workflow-run)

## remove_all_custom_labels_from_self_hosted_runner_for_org(org, runner_id, opts \\ [])

Remove all custom labels from a self-hosted runner for an organization

Remove all custom labels from a self-hosted runner configured in an
organization. Returns the remaining read-only labels from the runner.

Authenticated users must have admin access to the organization to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, the `repo` scope is also required.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#remove-all-custom-labels-from-a-self-hosted-runner-for-an-organization)

## remove_all_custom_labels_from_self_hosted_runner_for_repo(owner, repo, runner_id, opts \\ [])

Remove all custom labels from a self-hosted runner for a repository

Remove all custom labels from a self-hosted runner configured in a
repository. Returns the remaining read-only labels from the runner.

Authenticated users must have admin access to the repository to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#remove-all-custom-labels-from-a-self-hosted-runner-for-a-repository)

## remove_custom_label_from_self_hosted_runner_for_org(org, runner_id, name, opts \\ [])

Remove a custom label from a self-hosted runner for an organization

Remove a custom label from a self-hosted runner configured
in an organization. Returns the remaining labels from the runner.

This endpoint returns a `404 Not Found` status if the custom label is not
present on the runner.

Authenticated users must have admin access to the organization to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, the `repo` scope is also required.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#remove-a-custom-label-from-a-self-hosted-runner-for-an-organization)

## remove_custom_label_from_self_hosted_runner_for_repo(owner, repo, runner_id, name, opts \\ [])

Remove a custom label from a self-hosted runner for a repository

Remove a custom label from a self-hosted runner configured
in a repository. Returns the remaining labels from the runner.

This endpoint returns a `404 Not Found` status if the custom label is not
present on the runner.

Authenticated users must have admin access to the repository to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#remove-a-custom-label-from-a-self-hosted-runner-for-a-repository)

## remove_selected_repo_from_org_secret(org, secret_name, repository_id, opts \\ [])

Remove selected repository from an organization secret

Removes a repository from an organization secret when the `visibility`
for repository access is set to `selected`. The visibility is set when you [Create
or update an organization secret](https://docs.github.com/rest/actions/secrets#create-or-update-an-organization-secret).

Authenticated users must have collaborator access to a repository to create, update, or read secrets.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, the `repo` scope is also required.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/secrets#remove-selected-repository-from-an-organization-secret)

## remove_selected_repo_from_org_variable(org, name, repository_id, opts \\ [])

Remove selected repository from an organization variable

Removes a repository from an organization variable that is
available to selected repositories. Organization variables that are available to
selected repositories have their `visibility` field set to `selected`.

Authenticated users must have collaborator access to a repository to create, update, or read variables.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, the `repo` scope is also required.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/variables#remove-selected-repository-from-an-organization-variable)

## review_custom_gates_for_run(owner, repo, run_id, body, opts \\ [])

Review custom deployment protection rules for a workflow run

Approve or reject custom deployment protection rules provided by a GitHub App for a workflow run. For more information, see "[Using environments for deployment](https://docs.github.com/actions/deployment/targeting-different-environments/using-environments-for-deployment)."

**Note:** GitHub Apps can only review their own custom deployment protection rules.
To approve or reject pending deployments that are waiting for review from a specific person or team, see [`POST /repos/{owner}/{repo}/actions/runs/{run_id}/pending_deployments`](https://docs.github.com/rest/actions/workflow-runs#review-pending-deployments-for-a-workflow-run).

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-runs#review-custom-deployment-protection-rules-for-a-workflow-run)

## review_pending_deployments_for_run(owner, repo, run_id, body, opts \\ [])

Review pending deployments for a workflow run

Approve or reject pending deployments that are waiting on approval by a required reviewer.

Required reviewers with read access to the repository contents and deployments can use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/workflow-runs#review-pending-deployments-for-a-workflow-run)

## set_allowed_actions_organization(org, body, opts \\ [])

Set allowed actions and reusable workflows for an organization

Sets the actions and reusable workflows that are allowed in an organization. To use this endpoint, the organization permission policy for `allowed_actions` must be configured to `selected`. For more information, see "[Set GitHub Actions permissions for an organization](#set-github-actions-permissions-for-an-organization)."

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/permissions#set-allowed-actions-and-reusable-workflows-for-an-organization)

## set_allowed_actions_repository(owner, repo, body, opts \\ [])

Set allowed actions and reusable workflows for a repository

Sets the actions and reusable workflows that are allowed in a repository. To use this endpoint, the repository permission policy for `allowed_actions` must be configured to `selected`. For more information, see "[Set GitHub Actions permissions for a repository](#set-github-actions-permissions-for-a-repository)."

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/permissions#set-allowed-actions-and-reusable-workflows-for-a-repository)

## set_custom_labels_for_self_hosted_runner_for_org(org, runner_id, body, opts \\ [])

Set custom labels for a self-hosted runner for an organization

Remove all previous custom labels and set the new custom labels for a specific
self-hosted runner configured in an organization.

Authenticated users must have admin access to the organization to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, the `repo` scope is also required.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#set-custom-labels-for-a-self-hosted-runner-for-an-organization)

## set_custom_labels_for_self_hosted_runner_for_repo(owner, repo, runner_id, body, opts \\ [])

Set custom labels for a self-hosted runner for a repository

Remove all previous custom labels and set the new custom labels for a specific
self-hosted runner configured in a repository.

Authenticated users must have admin access to the repository to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/self-hosted-runners#set-custom-labels-for-a-self-hosted-runner-for-a-repository)

## set_custom_oidc_sub_claim_for_repo(owner, repo, body, opts \\ [])

Set the customization template for an OIDC subject claim for a repository

Sets the customization template and `opt-in` or `opt-out` flag for an OpenID Connect (OIDC) subject claim for a repository.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/oidc#set-the-customization-template-for-an-oidc-subject-claim-for-a-repository)

## set_github_actions_default_workflow_permissions_organization(org, body, opts \\ [])

Set default workflow permissions for an organization

Sets the default workflow permissions granted to the `GITHUB_TOKEN` when running workflows in an organization, and sets if GitHub Actions
can submit approving pull request reviews. For more information, see
"[Setting the permissions of the GITHUB_TOKEN for your organization](https://docs.github.com/organizations/managing-organization-settings/disabling-or-limiting-github-actions-for-your-organization#setting-the-permissions-of-the-github_token-for-your-organization)."

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/permissions#set-default-workflow-permissions-for-an-organization)

## set_github_actions_default_workflow_permissions_repository(owner, repo, body, opts \\ [])

Set default workflow permissions for a repository

Sets the default workflow permissions granted to the `GITHUB_TOKEN` when running workflows in a repository, and sets if GitHub Actions
can submit approving pull request reviews.
For more information, see "[Setting the permissions of the GITHUB_TOKEN for your repository](https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository#setting-the-permissions-of-the-github_token-for-your-repository)."

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/permissions#set-default-workflow-permissions-for-a-repository)

## set_github_actions_permissions_organization(org, body, opts \\ [])

Set GitHub Actions permissions for an organization

Sets the GitHub Actions permissions policy for repositories and allowed actions and reusable workflows in an organization.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/permissions#set-github-actions-permissions-for-an-organization)

## set_github_actions_permissions_repository(owner, repo, body, opts \\ [])

Set GitHub Actions permissions for a repository

Sets the GitHub Actions permissions policy for enabling GitHub Actions and allowed actions and reusable workflows in the repository.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/permissions#set-github-actions-permissions-for-a-repository)

## set_selected_repos_for_org_secret(org, secret_name, body, opts \\ [])

Set selected repositories for an organization secret

Replaces all repositories for an organization secret when the `visibility`
for repository access is set to `selected`. The visibility is set when you [Create
or update an organization secret](https://docs.github.com/rest/actions/secrets#create-or-update-an-organization-secret).

Authenticated users must have collaborator access to a repository to create, update, or read secrets.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, the `repo` scope is also required.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/secrets#set-selected-repositories-for-an-organization-secret)

## set_selected_repos_for_org_variable(org, name, body, opts \\ [])

Set selected repositories for an organization variable

Replaces all repositories for an organization variable that is available
to selected repositories. Organization variables that are available to selected
repositories have their `visibility` field set to `selected`.

Authenticated users must have collaborator access to a repository to create, update, or read variables.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, the `repo` scope is also required.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/variables#set-selected-repositories-for-an-organization-variable)

## set_selected_repositories_enabled_github_actions_organization(org, body, opts \\ [])

Set selected repositories enabled for GitHub Actions in an organization

Replaces the list of selected repositories that are enabled for GitHub Actions in an organization. To use this endpoint, the organization permission policy for `enabled_repositories` must be configured to `selected`. For more information, see "[Set GitHub Actions permissions for an organization](#set-github-actions-permissions-for-an-organization)."


OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/permissions#set-selected-repositories-enabled-for-github-actions-in-an-organization)

## set_workflow_access_to_repository(owner, repo, body, opts \\ [])

Set the level of access for workflows outside of the repository

Sets the level of access that workflows outside of the repository have to actions and reusable workflows in the repository.
This endpoint only applies to private repositories.
For more information, see "[Allowing access to components in a private repository](https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/enabling-features-for-your-repository/managing-github-actions-settings-for-a-repository#allowing-access-to-components-in-a-private-repository)".

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/permissions#set-the-level-of-access-for-workflows-outside-of-the-repository)

## update_environment_variable(owner, repo, name, environment_name, body, opts \\ [])

Update an environment variable

Updates an environment variable that you can reference in a GitHub Actions workflow.

Authenticated users must have collaborator access to a repository to create, update, or read variables.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/variables#update-an-environment-variable)

## update_org_variable(org, name, body, opts \\ [])

Update an organization variable

Updates an organization variable that you can reference in a GitHub Actions workflow.

Authenticated users must have collaborator access to a repository to create, update, or read variables.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint. If the repository is private, the `repo` scope is also required.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/variables#update-an-organization-variable)

## update_repo_variable(owner, repo, name, body, opts \\ [])

Update a repository variable

Updates a repository variable that you can reference in a GitHub Actions workflow.

Authenticated users must have collaborator access to a repository to create, update, or read variables.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/variables#update-a-repository-variable)