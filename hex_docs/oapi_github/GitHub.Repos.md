# GitHub.Repos

Provides API endpoints related to repos

## accept_invitation_for_authenticated_user(invitation_id, opts \\ [])

Accept a repository invitation

## Resources

  * [API method documentation](https://docs.github.com/rest/collaborators/invitations#accept-a-repository-invitation)

## add_app_access_restrictions(owner, repo, branch, body, opts \\ [])

Add app access restrictions

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

Grants the specified apps push access for this branch. Only GitHub Apps that are installed on the repository and that have been granted write access to the repository contents can be added as authorized actors on a protected branch.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#add-app-access-restrictions)

## add_collaborator(owner, repo, username, body, opts \\ [])

Add a repository collaborator

This endpoint triggers [notifications](https://docs.github.com/github/managing-subscriptions-and-notifications-on-github/about-notifications). Creating content too quickly using this endpoint may result in secondary rate limiting. For more information, see "[Rate limits for the API](https://docs.github.com/rest/overview/rate-limits-for-the-rest-api#about-secondary-rate-limits)" and "[Best practices for using the REST API](https://docs.github.com/rest/guides/best-practices-for-using-the-rest-api)."

Adding an outside collaborator may be restricted by enterprise administrators. For more information, see "[Enforcing repository management policies in your enterprise](https://docs.github.com/admin/policies/enforcing-policies-for-your-enterprise/enforcing-repository-management-policies-in-your-enterprise#enforcing-a-policy-for-inviting-outside-collaborators-to-repositories)."

For more information on permission levels, see "[Repository permission levels for an organization](https://docs.github.com/github/setting-up-and-managing-organizations-and-teams/repository-permission-levels-for-an-organization#permission-levels-for-repositories-owned-by-an-organization)". There are restrictions on which permissions can be granted to organization members when an organization base role is in place. In this case, the permission being given must be equal to or higher than the org base permission. Otherwise, the request will fail with:

```
Cannot assign {member} permission of {role name}
```

Note that, if you choose not to pass any parameters, you'll need to set `Content-Length` to zero when calling out to this endpoint. For more information, see "[HTTP method](https://docs.github.com/rest/guides/getting-started-with-the-rest-api#http-method)."

The invitee will receive a notification that they have been invited to the repository, which they must accept or decline. They may do this via the notifications page, the email they receive, or by using the [API](https://docs.github.com/rest/collaborators/invitations).

**Updating an existing collaborator's permission level**

The endpoint can also be used to change the permissions of an existing collaborator without first removing and re-adding the collaborator. To change the permissions, use the same endpoint and pass a different `permission` parameter. The response will be a `204`, with no other indication that the permission level changed.

**Rate limits**

You are limited to sending 50 invitations to a repository per 24 hour period. Note there is no limit if you are inviting organization members to an organization repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/collaborators/collaborators#add-a-repository-collaborator)

## add_status_check_contexts(owner, repo, branch, body, opts \\ [])

Add status check contexts

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#add-status-check-contexts)

## add_team_access_restrictions(owner, repo, branch, body, opts \\ [])

Add team access restrictions

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

Grants the specified teams push access for this branch. You can also give push access to child teams.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#add-team-access-restrictions)

## add_user_access_restrictions(owner, repo, branch, body, opts \\ [])

Add user access restrictions

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

Grants the specified people push access for this branch.

| Type    | Description                                                                                                                   |
| ------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `array` | Usernames for people who can have push access. **Note**: The list of users, apps, and teams in total is limited to 100 items. |

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#add-user-access-restrictions)

## cancel_pages_deployment(owner, repo, pages_deployment_id, opts \\ [])

Cancel a GitHub Pages deployment

Cancels a GitHub Pages deployment.

The authenticated user must have write permissions for the GitHub Pages site.

## Resources

  * [API method documentation](https://docs.github.com/rest/pages/pages#cancel-a-github-pages-deployment)

## check_automated_security_fixes(owner, repo, opts \\ [])

Check if automated security fixes are enabled for a repository

Shows whether automated security fixes are enabled, disabled or paused for a repository. The authenticated user must have admin read access to the repository. For more information, see "[Configuring automated security fixes](https://docs.github.com/articles/configuring-automated-security-fixes)".

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#check-if-automated-security-fixes-are-enabled-for-a-repository)

## check_collaborator(owner, repo, username, opts \\ [])

Check if a user is a repository collaborator

For organization-owned repositories, the list of collaborators includes outside collaborators, organization members that are direct collaborators, organization members with access through team memberships, organization members with access through default organization permissions, and organization owners.

Team members will include the members of child teams.

The authenticated user must have push access to the repository to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `read:org` and `repo` scopes to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/collaborators/collaborators#check-if-a-user-is-a-repository-collaborator)

## check_private_vulnerability_reporting(owner, repo, opts \\ [])

Check if private vulnerability reporting is enabled for a repository

Returns a boolean indicating whether or not private vulnerability reporting is enabled for the repository. For more information, see "[Evaluating the security settings of a repository](https://docs.github.com/code-security/security-advisories/working-with-repository-security-advisories/evaluating-the-security-settings-of-a-repository)".

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#check-if-private-vulnerability-reporting-is-enabled-for-a-repository)

## check_vulnerability_alerts(owner, repo, opts \\ [])

Check if vulnerability alerts are enabled for a repository

Shows whether dependency alerts are enabled or disabled for a repository. The authenticated user must have admin read access to the repository. For more information, see "[About security alerts for vulnerable dependencies](https://docs.github.com/articles/about-security-alerts-for-vulnerable-dependencies)".

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#check-if-vulnerability-alerts-are-enabled-for-a-repository)

## codeowners_errors(owner, repo, opts \\ [])

List CODEOWNERS errors

List any syntax errors that are detected in the CODEOWNERS
file.

For more information about the correct CODEOWNERS syntax,
see "[About code owners](https://docs.github.com/repositories/managing-your-repositorys-settings-and-features/customizing-your-repository/about-code-owners)."

## Options

  * `ref`: A branch, tag or commit name used to determine which version of the CODEOWNERS file to use. Default: the repository's default branch (e.g. `main`)

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#list-codeowners-errors)

## compare_commits(owner, repo, basehead, opts \\ [])

Compare two commits

Compares two commits against one another. You can compare refs (branches or tags) and commit SHAs in the same repository, or you can compare refs and commit SHAs that exist in different repositories within the same repository network, including fork branches. For more information about how to view a repository's network, see "[Understanding connections between repositories](https://docs.github.com/repositories/viewing-activity-and-data-for-your-repository/understanding-connections-between-repositories)."

This endpoint is equivalent to running the `git log BASE..HEAD` command, but it returns commits in a different order. The `git log BASE..HEAD` command returns commits in reverse chronological order, whereas the API returns commits in chronological order.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.diff`**: Returns the diff of the commit.
- **`application/vnd.github.patch`**: Returns the patch of the commit. Diffs with binary data will have no `patch` property.

The API response includes details about the files that were changed between the two commits. This includes the status of the change (if a file was added, removed, modified, or renamed), and details of the change itself. For example, files with a `renamed` status have a `previous_filename` field showing the previous filename of the file, and files with a `modified` status have a `patch` field showing the changes made to the file.

When calling this endpoint without any paging parameter (`per_page` or `page`), the returned list is limited to 250 commits, and the last commit in the list is the most recent of the entire comparison.

**Working with large comparisons**

To process a response with a large number of commits, use a query parameter (`per_page` or `page`) to paginate the results. When using pagination:

- The list of changed files is only shown on the first page of results, but it includes all changed files for the entire comparison.
- The results are returned in chronological order, but the last commit in the returned list may not be the most recent one in the entire set if there are more pages of results.

For more information on working with pagination, see "[Using pagination in the REST API](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api)."

**Signature verification object**

The response will include a `verification` object that describes the result of verifying the commit's signature. The `verification` object includes the following fields:

| Name | Type | Description |
| ---- | ---- | ----------- |
| `verified` | `boolean` | Indicates whether GitHub considers the signature in this commit to be verified. |
| `reason` | `string` | The reason for verified value. Possible values and their meanings are enumerated in table below. |
| `signature` | `string` | The signature that was extracted from the commit. |
| `payload` | `string` | The value that was signed. |

These are the possible values for `reason` in the `verification` object:

| Value | Description |
| ----- | ----------- |
| `expired_key` | The key that made the signature is expired. |
| `not_signing_key` | The "signing" flag is not among the usage flags in the GPG key that made the signature. |
| `gpgverify_error` | There was an error communicating with the signature verification service. |
| `gpgverify_unavailable` | The signature verification service is currently unavailable. |
| `unsigned` | The object does not include a signature. |
| `unknown_signature_type` | A non-PGP signature was found in the commit. |
| `no_user` | No user was associated with the `committer` email address in the commit. |
| `unverified_email` | The `committer` email address in the commit was associated with a user, but the email address is not verified on their account. |
| `bad_email` | The `committer` email address in the commit is not included in the identities of the PGP key that made the signature. |
| `unknown_key` | The key that made the signature has not been registered with any user's account. |
| `malformed_signature` | There was an error parsing the signature. |
| `invalid` | The signature could not be cryptographically verified using the key whose key-id was found in the signature. |
| `valid` | None of the above errors applied, so the signature is considered to be verified. |

## Options

  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/commits/commits#compare-two-commits)

## create_autolink(owner, repo, body, opts \\ [])

Create an autolink reference for a repository

Users with admin access to the repository can create an autolink.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/autolinks#create-an-autolink-reference-for-a-repository)

## create_commit_comment(owner, repo, commit_sha, body, opts \\ [])

Create a commit comment

Create a comment for a commit using its `:commit_sha`.

This endpoint triggers [notifications](https://docs.github.com/github/managing-subscriptions-and-notifications-on-github/about-notifications). Creating content too quickly using this endpoint may result in secondary rate limiting. For more information, see "[Rate limits for the API](https://docs.github.com/rest/overview/rate-limits-for-the-rest-api#about-secondary-rate-limits)" and "[Best practices for using the REST API](https://docs.github.com/rest/guides/best-practices-for-using-the-rest-api)."

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github-commitcomment.raw+json`**: Returns the raw markdown body. Response will include `body`. This is the default if you do not pass any specific media type.
- **`application/vnd.github-commitcomment.text+json`**: Returns a text only representation of the markdown body. Response will include `body_text`.
- **`application/vnd.github-commitcomment.html+json`**: Returns HTML rendered from the body's markdown. Response will include `body_html`.
- **`application/vnd.github-commitcomment.full+json`**: Returns raw, text, and HTML representations. Response will include `body`, `body_text`, and `body_html`.

## Resources

  * [API method documentation](https://docs.github.com/rest/commits/comments#create-a-commit-comment)

## create_commit_signature_protection(owner, repo, branch, opts \\ [])

Create commit signature protection

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

When authenticated with admin or owner permissions to the repository, you can use this endpoint to require signed commits on a branch. You must enable branch protection to require signed commits.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#create-commit-signature-protection)

## create_commit_status(owner, repo, sha, body, opts \\ [])

Create a commit status

Users with push access in a repository can create commit statuses for a given SHA.

Note: there is a limit of 1000 statuses per `sha` and `context` within a repository. Attempts to create more than 1000 statuses will result in a validation error.

## Resources

  * [API method documentation](https://docs.github.com/rest/commits/statuses#create-a-commit-status)

## create_deploy_key(owner, repo, body, opts \\ [])

Create a deploy key

You can create a read-only deploy key.

## Resources

  * [API method documentation](https://docs.github.com/rest/deploy-keys/deploy-keys#create-a-deploy-key)

## create_deployment(owner, repo, body, opts \\ [])

Create a deployment

Deployments offer a few configurable parameters with certain defaults.

The `ref` parameter can be any named branch, tag, or SHA. At GitHub we often deploy branches and verify them
before we merge a pull request.

The `environment` parameter allows deployments to be issued to different runtime environments. Teams often have
multiple environments for verifying their applications, such as `production`, `staging`, and `qa`. This parameter
makes it easier to track which environments have requested deployments. The default environment is `production`.

The `auto_merge` parameter is used to ensure that the requested ref is not behind the repository's default branch. If
the ref _is_ behind the default branch for the repository, we will attempt to merge it for you. If the merge succeeds,
the API will return a successful merge commit. If merge conflicts prevent the merge from succeeding, the API will
return a failure response.

By default, [commit statuses](https://docs.github.com/rest/commits/statuses) for every submitted context must be in a `success`
state. The `required_contexts` parameter allows you to specify a subset of contexts that must be `success`, or to
specify contexts that have not yet been submitted. You are not required to use commit statuses to deploy. If you do
not require any contexts or create any commit statuses, the deployment will always succeed.

The `payload` parameter is available for any extra information that a deployment system might need. It is a JSON text
field that will be passed on when a deployment event is dispatched.

The `task` parameter is used by the deployment system to allow different execution paths. In the web world this might
be `deploy:migrations` to run schema changes on the system. In the compiled world this could be a flag to compile an
application with debugging enabled.

Merged branch response:

You will see this response when GitHub automatically merges the base branch into the topic branch instead of creating
a deployment. This auto-merge happens when:
*   Auto-merge option is enabled in the repository
*   Topic branch does not include the latest changes on the base branch, which is `master` in the response example
*   There are no merge conflicts

If there are no new commits in the base branch, a new request to create a deployment should give a successful
response.

Merge conflict response:

This error happens when the `auto_merge` option is enabled and when the default branch (in this case `master`), can't
be merged into the branch that's being deployed (in this case `topic-branch`), due to merge conflicts.

Failed commit status checks:

This error happens when the `required_contexts` parameter indicates that one or more contexts need to have a `success`
status for the commit to be deployed, but one or more of the required contexts do not have a state of `success`.

OAuth app tokens and personal access tokens (classic) need the `repo` or `repo_deployment` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/deployments#create-a-deployment)

## create_deployment_branch_policy(owner, repo, environment_name, body, opts \\ [])

Create a deployment branch policy

Creates a deployment branch or tag policy for an environment.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/branch-policies#create-a-deployment-branch-policy)

## create_deployment_protection_rule(environment_name, repo, owner, body, opts \\ [])

Create a custom deployment protection rule on an environment

Enable a custom deployment protection rule for an environment.

The authenticated user must have admin or owner permissions to the repository to use this endpoint.

For more information about the app that is providing this custom deployment rule, see the [documentation for the `GET /apps/{app_slug}` endpoint](https://docs.github.com/rest/apps/apps#get-an-app).

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/protection-rules#create-a-custom-deployment-protection-rule-on-an-environment)

## create_deployment_status(owner, repo, deployment_id, body, opts \\ [])

Create a deployment status

Users with `push` access can create deployment statuses for a given deployment.

OAuth app tokens and personal access tokens (classic) need the `repo_deployment` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/statuses#create-a-deployment-status)

## create_dispatch_event(owner, repo, body, opts \\ [])

Create a repository dispatch event

You can use this endpoint to trigger a webhook event called `repository_dispatch` when you want activity that happens outside of GitHub to trigger a GitHub Actions workflow or GitHub App webhook. You must configure your GitHub Actions workflow or GitHub App to run when the `repository_dispatch` event occurs. For an example `repository_dispatch` webhook payload, see "[RepositoryDispatchEvent](https://docs.github.com/webhooks/event-payloads/#repository_dispatch)."

The `client_payload` parameter is available for any extra information that your workflow might need. This parameter is a JSON payload that will be passed on when the webhook event is dispatched. For example, the `client_payload` can include a message that a user would like to send using a GitHub Actions workflow. Or the `client_payload` can be used as a test to debug your workflow.

This input example shows how you can use the `client_payload` as a test to debug your workflow.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#create-a-repository-dispatch-event)

## create_for_authenticated_user(body, opts \\ [])

Create a repository for the authenticated user

Creates a new repository for the authenticated user.

OAuth app tokens and personal access tokens (classic) need the `public_repo` or `repo` scope to create a public repository, and `repo` scope to create a private repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#create-a-repository-for-the-authenticated-user)

## create_fork(owner, repo, body, opts \\ [])

Create a fork

Create a fork for the authenticated user.

**Note**: Forking a Repository happens asynchronously. You may have to wait a short period of time before you can access the git objects. If this takes longer than 5 minutes, be sure to contact [GitHub Support](https://support.github.com/contact?tags=dotcom-rest-api).

**Note**: Although this endpoint works with GitHub Apps, the GitHub App must be installed on the destination account with access to all repositories and on the source account with access to the source repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/forks#create-a-fork)

## create_in_org(org, body, opts \\ [])

Create an organization repository

Creates a new repository in the specified organization. The authenticated user must be a member of the organization.

OAuth app tokens and personal access tokens (classic) need the `public_repo` or `repo` scope to create a public repository, and `repo` scope to create a private repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#create-an-organization-repository)

## create_or_update_custom_properties_values(owner, repo, body, opts \\ [])

Create or update custom property values for a repository

Create new or update existing custom property values for a repository.
Using a value of `null` for a custom property will remove or 'unset' the property value from the repository.

Repository admins and other users with the repository-level "edit custom property values" fine-grained permission can use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/custom-properties#create-or-update-custom-property-values-for-a-repository)

## create_or_update_environment(owner, repo, environment_name, body, opts \\ [])

Create or update an environment

Create or update an environment with protection rules, such as required reviewers. For more information about environment protection rules, see "[Environments](https://docs.github.com/actions/reference/environments#environment-protection-rules)."

**Note:** To create or update name patterns that branches must match in order to deploy to this environment, see "[Deployment branch policies](https://docs.github.com/rest/deployments/branch-policies)."

**Note:** To create or update secrets for an environment, see "[GitHub Actions secrets](https://docs.github.com/rest/actions/secrets)."

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/environments#create-or-update-an-environment)

## create_or_update_file_contents(owner, repo, path, body, opts \\ [])

Create or update file contents

Creates a new file or replaces an existing file in a repository.

**Note:** If you use this endpoint and the "[Delete a file](https://docs.github.com/rest/repos/contents/#delete-a-file)" endpoint in parallel, the concurrent requests will conflict and you will receive errors. You must use these endpoints serially instead.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint. The `workflow` scope is also required in order to modify files in the `.github/workflows` directory.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/contents#create-or-update-file-contents)

## create_org_ruleset(org, body, opts \\ [])

Create an organization repository ruleset

Create a repository ruleset for an organization.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/rules#create-an-organization-repository-ruleset)

## create_pages_deployment(owner, repo, body, opts \\ [])

Create a GitHub Pages deployment

Create a GitHub Pages deployment for a repository.

The authenticated user must have write permission to the repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/pages/pages#create-a-github-pages-deployment)

## create_pages_site(owner, repo, body, opts \\ [])

Create a GitHub Pages site

Configures a GitHub Pages site. For more information, see "[About GitHub Pages](https://docs.github.com/github/working-with-github-pages/about-github-pages)."

The authenticated user must be a repository administrator, maintainer, or have the 'manage GitHub Pages settings' permission.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/pages/pages#create-a-apiname-pages-site)

## create_release(owner, repo, body, opts \\ [])

Create a release

Users with push access to the repository can create a release.

This endpoint triggers [notifications](https://docs.github.com/github/managing-subscriptions-and-notifications-on-github/about-notifications). Creating content too quickly using this endpoint may result in secondary rate limiting. For more information, see "[Rate limits for the API](https://docs.github.com/rest/overview/rate-limits-for-the-rest-api#about-secondary-rate-limits)" and "[Best practices for using the REST API](https://docs.github.com/rest/guides/best-practices-for-using-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/releases/releases#create-a-release)

## create_repo_ruleset(owner, repo, body, opts \\ [])

Create a repository ruleset

Create a ruleset for a repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/rules#create-a-repository-ruleset)

## create_tag_protection(owner, repo, body, opts \\ [])

Create a tag protection state for a repository

This creates a tag protection state for a repository.
This endpoint is only available to repository administrators.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/tags#create-a-tag-protection-state-for-a-repository)

## create_using_template(template_owner, template_repo, body, opts \\ [])

Create a repository using a template

Creates a new repository using a repository template. Use the `template_owner` and `template_repo` route parameters to specify the repository to use as the template. If the repository is not public, the authenticated user must own or be a member of an organization that owns the repository. To check if a repository is available to use as a template, get the repository's information using the [Get a repository](https://docs.github.com/rest/repos/repos#get-a-repository) endpoint and check that the `is_template` key is `true`.

OAuth app tokens and personal access tokens (classic) need the `public_repo` or `repo` scope to create a public repository, and `repo` scope to create a private repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#create-a-repository-using-a-template)

## create_webhook(owner, repo, body, opts \\ [])

Create a repository webhook

Repositories can have multiple webhooks installed. Each webhook should have a unique `config`. Multiple webhooks can
share the same `config` as long as those webhooks do not have any `events` that overlap.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/webhooks#create-a-repository-webhook)

## decline_invitation_for_authenticated_user(invitation_id, opts \\ [])

Decline a repository invitation

## Resources

  * [API method documentation](https://docs.github.com/rest/collaborators/invitations#decline-a-repository-invitation)

## delete(owner, repo, opts \\ [])

Delete a repository

Deleting a repository requires admin access.

If an organization owner has configured the organization to prevent members from deleting organization-owned
repositories, you will get a `403 Forbidden` response.

OAuth app tokens and personal access tokens (classic) need the `delete_repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#delete-a-repository)

## delete_access_restrictions(owner, repo, branch, opts \\ [])

Delete access restrictions

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

Disables the ability to restrict who can push to this branch.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#delete-access-restrictions)

## delete_admin_branch_protection(owner, repo, branch, opts \\ [])

Delete admin branch protection

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

Removing admin enforcement requires admin or owner permissions to the repository and branch protection to be enabled.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#delete-admin-branch-protection)

## delete_an_environment(owner, repo, environment_name, opts \\ [])

Delete an environment

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/environments#delete-an-environment)

## delete_autolink(owner, repo, autolink_id, opts \\ [])

Delete an autolink reference from a repository

This deletes a single autolink reference by ID that was configured for the given repository.

Information about autolinks are only available to repository administrators.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/autolinks#delete-an-autolink-reference-from-a-repository)

## delete_branch_protection(owner, repo, branch, opts \\ [])

Delete branch protection

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#delete-branch-protection)

## delete_commit_comment(owner, repo, comment_id, opts \\ [])

Delete a commit comment

## Resources

  * [API method documentation](https://docs.github.com/rest/commits/comments#delete-a-commit-comment)

## delete_commit_signature_protection(owner, repo, branch, opts \\ [])

Delete commit signature protection

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

When authenticated with admin or owner permissions to the repository, you can use this endpoint to disable required signed commits on a branch. You must enable branch protection to require signed commits.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#delete-commit-signature-protection)

## delete_deploy_key(owner, repo, key_id, opts \\ [])

Delete a deploy key

Deploy keys are immutable. If you need to update a key, remove the key and create a new one instead.

## Resources

  * [API method documentation](https://docs.github.com/rest/deploy-keys/deploy-keys#delete-a-deploy-key)

## delete_deployment(owner, repo, deployment_id, opts \\ [])

Delete a deployment

If the repository only has one deployment, you can delete the deployment regardless of its status. If the repository has more than one deployment, you can only delete inactive deployments. This ensures that repositories with multiple deployments will always have an active deployment.

To set a deployment as inactive, you must:

*   Create a new deployment that is active so that the system has a record of the current state, then delete the previously active deployment.
*   Mark the active deployment as inactive by adding any non-successful deployment status.

For more information, see "[Create a deployment](https://docs.github.com/rest/deployments/deployments/#create-a-deployment)" and "[Create a deployment status](https://docs.github.com/rest/deployments/statuses#create-a-deployment-status)."

OAuth app tokens and personal access tokens (classic) need the `repo` or `repo_deployment` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/deployments#delete-a-deployment)

## delete_deployment_branch_policy(owner, repo, environment_name, branch_policy_id, opts \\ [])

Delete a deployment branch policy

Deletes a deployment branch or tag policy for an environment.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/branch-policies#delete-a-deployment-branch-policy)

## delete_file(owner, repo, path, body, opts \\ [])

Delete a file

Deletes a file in a repository.

You can provide an additional `committer` parameter, which is an object containing information about the committer. Or, you can provide an `author` parameter, which is an object containing information about the author.

The `author` section is optional and is filled in with the `committer` information if omitted. If the `committer` information is omitted, the authenticated user's information is used.

You must provide values for both `name` and `email`, whether you choose to use `author` or `committer`. Otherwise, you'll receive a `422` status code.

**Note:** If you use this endpoint and the "[Create or update file contents](https://docs.github.com/rest/repos/contents/#create-or-update-file-contents)" endpoint in parallel, the concurrent requests will conflict and you will receive errors. You must use these endpoints serially instead.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/contents#delete-a-file)

## delete_invitation(owner, repo, invitation_id, opts \\ [])

Delete a repository invitation

## Resources

  * [API method documentation](https://docs.github.com/rest/collaborators/invitations#delete-a-repository-invitation)

## delete_org_ruleset(org, ruleset_id, opts \\ [])

Delete an organization repository ruleset

Delete a ruleset for an organization.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/rules#delete-an-organization-repository-ruleset)

## delete_pages_site(owner, repo, opts \\ [])

Delete a GitHub Pages site

Deletes a GitHub Pages site. For more information, see "[About GitHub Pages](https://docs.github.com/github/working-with-github-pages/about-github-pages).

The authenticated user must be a repository administrator, maintainer, or have the 'manage GitHub Pages settings' permission.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/pages/pages#delete-a-apiname-pages-site)

## delete_pull_request_review_protection(owner, repo, branch, opts \\ [])

Delete pull request review protection

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#delete-pull-request-review-protection)

## delete_release(owner, repo, release_id, opts \\ [])

Delete a release

Users with push access to the repository can delete a release.

## Resources

  * [API method documentation](https://docs.github.com/rest/releases/releases#delete-a-release)

## delete_release_asset(owner, repo, asset_id, opts \\ [])

Delete a release asset

## Resources

  * [API method documentation](https://docs.github.com/rest/releases/assets#delete-a-release-asset)

## delete_repo_ruleset(owner, repo, ruleset_id, opts \\ [])

Delete a repository ruleset

Delete a ruleset for a repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/rules#delete-a-repository-ruleset)

## delete_tag_protection(owner, repo, tag_protection_id, opts \\ [])

Delete a tag protection state for a repository

This deletes a tag protection state for a repository.
This endpoint is only available to repository administrators.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/tags#delete-a-tag-protection-state-for-a-repository)

## delete_webhook(owner, repo, hook_id, opts \\ [])

Delete a repository webhook

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/webhooks#delete-a-repository-webhook)

## disable_automated_security_fixes(owner, repo, opts \\ [])

Disable automated security fixes

Disables automated security fixes for a repository. The authenticated user must have admin access to the repository. For more information, see "[Configuring automated security fixes](https://docs.github.com/articles/configuring-automated-security-fixes)".

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#disable-automated-security-fixes)

## disable_deployment_protection_rule(environment_name, repo, owner, protection_rule_id, opts \\ [])

Disable a custom protection rule for an environment

Disables a custom deployment protection rule for an environment.

The authenticated user must have admin or owner permissions to the repository to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/protection-rules#disable-a-custom-protection-rule-for-an-environment)

## disable_private_vulnerability_reporting(owner, repo, opts \\ [])

Disable private vulnerability reporting for a repository

Disables private vulnerability reporting for a repository. The authenticated user must have admin access to the repository. For more information, see "[Privately reporting a security vulnerability](https://docs.github.com/code-security/security-advisories/guidance-on-reporting-and-writing/privately-reporting-a-security-vulnerability)".

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#disable-private-vulnerability-reporting-for-a-repository)

## disable_vulnerability_alerts(owner, repo, opts \\ [])

Disable vulnerability alerts

Disables dependency alerts and the dependency graph for a repository.
The authenticated user must have admin access to the repository. For more information,
see "[About security alerts for vulnerable dependencies](https://docs.github.com/articles/about-security-alerts-for-vulnerable-dependencies)".

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#disable-vulnerability-alerts)

## download_tarball_archive(owner, repo, ref, opts \\ [])

Download a repository archive (tar)

Gets a redirect URL to download a tar archive for a repository. If you omit `:ref`, the repository’s default branch (usually
`main`) will be used. Please make sure your HTTP framework is configured to follow redirects or you will need to use
the `Location` header to make a second `GET` request.
**Note**: For private repositories, these links are temporary and expire after five minutes.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/contents#download-a-repository-archive-tar)

## download_zipball_archive(owner, repo, ref, opts \\ [])

Download a repository archive (zip)

Gets a redirect URL to download a zip archive for a repository. If you omit `:ref`, the repository’s default branch (usually
`main`) will be used. Please make sure your HTTP framework is configured to follow redirects or you will need to use
the `Location` header to make a second `GET` request.

**Note**: For private repositories, these links are temporary and expire after five minutes. If the repository is empty, you will receive a 404 when you follow the redirect.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/contents#download-a-repository-archive-zip)

## enable_automated_security_fixes(owner, repo, opts \\ [])

Enable automated security fixes

Enables automated security fixes for a repository. The authenticated user must have admin access to the repository. For more information, see "[Configuring automated security fixes](https://docs.github.com/articles/configuring-automated-security-fixes)".

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#enable-automated-security-fixes)

## enable_private_vulnerability_reporting(owner, repo, opts \\ [])

Enable private vulnerability reporting for a repository

Enables private vulnerability reporting for a repository. The authenticated user must have admin access to the repository. For more information, see "[Privately reporting a security vulnerability](https://docs.github.com/code-security/security-advisories/guidance-on-reporting-and-writing/privately-reporting-a-security-vulnerability)."

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#enable-private-vulnerability-reporting-for-a-repository)

## enable_vulnerability_alerts(owner, repo, opts \\ [])

Enable vulnerability alerts

Enables dependency alerts and the dependency graph for a repository. The authenticated user must have admin access to the repository. For more information, see "[About security alerts for vulnerable dependencies](https://docs.github.com/articles/about-security-alerts-for-vulnerable-dependencies)".

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#enable-vulnerability-alerts)

## generate_release_notes(owner, repo, body, opts \\ [])

Generate release notes content for a release

Generate a name and body describing a [release](https://docs.github.com/rest/releases/releases#get-a-release). The body content will be markdown formatted and contain information like the changes since last release and users who contributed. The generated release notes are not saved anywhere. They are intended to be generated and used when creating a new release.

## Resources

  * [API method documentation](https://docs.github.com/rest/releases/releases#generate-release-notes-content-for-a-release)

## get(owner, repo, opts \\ [])

Get a repository

The `parent` and `source` objects are present when the repository is a fork. `parent` is the repository this repository was forked from, `source` is the ultimate source for the network.

**Note:** In order to see the `security_and_analysis` block for a repository you must have admin permissions for the repository or be an owner or security manager for the organization that owns the repository. For more information, see "[Managing security managers in your organization](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/managing-security-managers-in-your-organization)."

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#get-a-repository)

## get_access_restrictions(owner, repo, branch, opts \\ [])

Get access restrictions

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

Lists who has access to this protected branch.

**Note**: Users, apps, and teams `restrictions` are only available for organization-owned repositories.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#get-access-restrictions)

## get_admin_branch_protection(owner, repo, branch, opts \\ [])

Get admin branch protection

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#get-admin-branch-protection)

## get_all_deployment_protection_rules(environment_name, repo, owner, opts \\ [])

Get all deployment protection rules for an environment

Gets all custom deployment protection rules that are enabled for an environment. Anyone with read access to the repository can use this endpoint. For more information about environments, see "[Using environments for deployment](https://docs.github.com/actions/deployment/targeting-different-environments/using-environments-for-deployment)."

For more information about the app that is providing this custom deployment rule, see the [documentation for the `GET /apps/{app_slug}` endpoint](https://docs.github.com/rest/apps/apps#get-an-app).

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/protection-rules#get-all-deployment-protection-rules-for-an-environment)

## get_all_environments(owner, repo, opts \\ [])

List environments

Lists the environments for a repository.

Anyone with read access to the repository can use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/environments#list-environments)

## get_all_status_check_contexts(owner, repo, branch, opts \\ [])

Get all status check contexts

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#get-all-status-check-contexts)

## get_all_topics(owner, repo, opts \\ [])

Get all repository topics

## Options

  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#get-all-repository-topics)

## get_apps_with_access_to_protected_branch(owner, repo, branch, opts \\ [])

Get apps with access to the protected branch

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

Lists the GitHub Apps that have push access to this branch. Only GitHub Apps that are installed on the repository and that have been granted write access to the repository contents can be added as authorized actors on a protected branch.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#get-apps-with-access-to-the-protected-branch)

## get_autolink(owner, repo, autolink_id, opts \\ [])

Get an autolink reference of a repository

This returns a single autolink reference by ID that was configured for the given repository.

Information about autolinks are only available to repository administrators.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/autolinks#get-an-autolink-reference-of-a-repository)

## get_branch(owner, repo, branch, opts \\ [])

Get a branch

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branches#get-a-branch)

## get_branch_protection(owner, repo, branch, opts \\ [])

Get branch protection

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#get-branch-protection)

## get_branch_rules(owner, repo, branch, opts \\ [])

Get rules for a branch

Returns all active rules that apply to the specified branch. The branch does not need to exist; rules that would apply
to a branch with that name will be returned. All active rules that apply will be returned, regardless of the level
at which they are configured (e.g. repository or organization). Rules in rulesets with "evaluate" or "disabled"
enforcement statuses are not returned.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/rules#get-rules-for-a-branch)

## get_clones(owner, repo, opts \\ [])

Get repository clones

Get the total number of clones and breakdown per day or week for the last 14 days. Timestamps are aligned to UTC midnight of the beginning of the day or week. Week begins on Monday.

## Options

  * `per`: The time frame to display results for.

## Resources

  * [API method documentation](https://docs.github.com/rest/metrics/traffic#get-repository-clones)

## get_code_frequency_stats(owner, repo, opts \\ [])

Get the weekly commit activity


Returns a weekly aggregate of the number of additions and deletions pushed to a repository.

**Note:** This endpoint can only be used for repositories with fewer than 10,000 commits. If the repository contains
10,000 or more commits, a 422 status code will be returned.


## Resources

  * [API method documentation](https://docs.github.com/rest/metrics/statistics#get-the-weekly-commit-activity)

## get_collaborator_permission_level(owner, repo, username, opts \\ [])

Get repository permissions for a user

Checks the repository permission of a collaborator. The possible repository
permissions are `admin`, `write`, `read`, and `none`.

*Note*: The `permission` attribute provides the legacy base roles of `admin`, `write`, `read`, and `none`, where the
`maintain` role is mapped to `write` and the `triage` role is mapped to `read`. To determine the role assigned to the
collaborator, see the `role_name` attribute, which will provide the full role name, including custom roles. The
`permissions` hash can also be used to determine which base level of access the collaborator has to the repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/collaborators/collaborators#get-repository-permissions-for-a-user)

## get_combined_status_for_ref(owner, repo, ref, opts \\ [])

Get the combined status for a specific reference

Users with pull access in a repository can access a combined view of commit statuses for a given ref. The ref can be a SHA, a branch name, or a tag name.


Additionally, a combined `state` is returned. The `state` is one of:

*   **failure** if any of the contexts report as `error` or `failure`
*   **pending** if there are no statuses or a context is `pending`
*   **success** if the latest status for all contexts is `success`

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/commits/statuses#get-the-combined-status-for-a-specific-reference)

## get_commit(owner, repo, ref, opts \\ [])

Get a commit

Returns the contents of a single commit reference. You must have `read` access for the repository to use this endpoint.

**Note:** If there are more than 300 files in the commit diff and the default JSON media type is requested, the response will include pagination link headers for the remaining files, up to a limit of 3000 files. Each page contains the static commit information, and the only changes are to the file listing.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)." Pagination query parameters are not supported for these media types.

- **`application/vnd.github.diff`**: Returns the diff of the commit. Larger diffs may time out and return a 5xx status code.
- **`application/vnd.github.patch`**: Returns the patch of the commit. Diffs with binary data will have no `patch` property. Larger diffs may time out and return a 5xx status code.
- **`application/vnd.github.sha`**: Returns the commit's SHA-1 hash. You can use this endpoint to check if a remote reference's SHA-1 hash is the same as your local reference's SHA-1 hash by providing the local SHA-1 reference as the ETag.

**Signature verification object**

The response will include a `verification` object that describes the result of verifying the commit's signature. The following fields are included in the `verification` object:

| Name | Type | Description |
| ---- | ---- | ----------- |
| `verified` | `boolean` | Indicates whether GitHub considers the signature in this commit to be verified. |
| `reason` | `string` | The reason for verified value. Possible values and their meanings are enumerated in table below. |
| `signature` | `string` | The signature that was extracted from the commit. |
| `payload` | `string` | The value that was signed. |

These are the possible values for `reason` in the `verification` object:

| Value | Description |
| ----- | ----------- |
| `expired_key` | The key that made the signature is expired. |
| `not_signing_key` | The "signing" flag is not among the usage flags in the GPG key that made the signature. |
| `gpgverify_error` | There was an error communicating with the signature verification service. |
| `gpgverify_unavailable` | The signature verification service is currently unavailable. |
| `unsigned` | The object does not include a signature. |
| `unknown_signature_type` | A non-PGP signature was found in the commit. |
| `no_user` | No user was associated with the `committer` email address in the commit. |
| `unverified_email` | The `committer` email address in the commit was associated with a user, but the email address is not verified on their account. |
| `bad_email` | The `committer` email address in the commit is not included in the identities of the PGP key that made the signature. |
| `unknown_key` | The key that made the signature has not been registered with any user's account. |
| `malformed_signature` | There was an error parsing the signature. |
| `invalid` | The signature could not be cryptographically verified using the key whose key-id was found in the signature. |
| `valid` | None of the above errors applied, so the signature is considered to be verified. |

## Options

  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/commits/commits#get-a-commit)

## get_commit_activity_stats(owner, repo, opts \\ [])

Get the last year of commit activity

Returns the last year of commit activity grouped by week. The `days` array is a group of commits per day, starting on `Sunday`.

## Resources

  * [API method documentation](https://docs.github.com/rest/metrics/statistics#get-the-last-year-of-commit-activity)

## get_commit_comment(owner, repo, comment_id, opts \\ [])

Get a commit comment

Gets a specified commit comment.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github-commitcomment.raw+json`**: Returns the raw markdown body. Response will include `body`. This is the default if you do not pass any specific media type.
- **`application/vnd.github-commitcomment.text+json`**: Returns a text only representation of the markdown body. Response will include `body_text`.
- **`application/vnd.github-commitcomment.html+json`**: Returns HTML rendered from the body's markdown. Response will include `body_html`.
- **`application/vnd.github-commitcomment.full+json`**: Returns raw, text, and HTML representations. Response will include `body`, `body_text`, and `body_html`.

## Resources

  * [API method documentation](https://docs.github.com/rest/commits/comments#get-a-commit-comment)

## get_commit_signature_protection(owner, repo, branch, opts \\ [])

Get commit signature protection

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

When authenticated with admin or owner permissions to the repository, you can use this endpoint to check whether a branch requires signed commits. An enabled status of `true` indicates you must sign commits on this branch. For more information, see [Signing commits with GPG](https://docs.github.com/articles/signing-commits-with-gpg) in GitHub Help.

**Note**: You must enable branch protection to require signed commits.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#get-commit-signature-protection)

## get_community_profile_metrics(owner, repo, opts \\ [])

Get community profile metrics

Returns all community profile metrics for a repository. The repository cannot be a fork.

The returned metrics include an overall health score, the repository description, the presence of documentation, the
detected code of conduct, the detected license, and the presence of ISSUE_TEMPLATE, PULL_REQUEST_TEMPLATE,
README, and CONTRIBUTING files.

The `health_percentage` score is defined as a percentage of how many of
the recommended community health files are present. For more information, see
"[About community profiles for public repositories](https://docs.github.com/communities/setting-up-your-project-for-healthy-contributions/about-community-profiles-for-public-repositories)."

`content_reports_enabled` is only returned for organization-owned repositories.

## Resources

  * [API method documentation](https://docs.github.com/rest/metrics/community#get-community-profile-metrics)

## get_content(owner, repo, path, opts \\ [])

Get repository content

Gets the contents of a file or directory in a repository. Specify the file path or directory with the `path` parameter. If you omit the `path` parameter, you will receive the contents of the repository's root directory.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw file contents for files and symlinks.
- **`application/vnd.github.html+json`**: Returns the file contents in HTML. Markup languages are rendered to HTML using GitHub's open-source [Markup library](https://github.com/github/markup).
- **`application/vnd.github.object+json`**: Returns the contents in a consistent object format regardless of the content type. For example, instead of an array of objects for a directory, the response will be an object with an `entries` attribute containing the array of objects.

If the content is a directory, the response will be an array of objects, one object for each item in the directory. When listing the contents of a directory, submodules have their "type" specified as "file". Logically, the value _should_ be "submodule". This behavior exists [for backwards compatibility purposes](https://git.io/v1YCW). In the next major version of the API, the type will be returned as "submodule".

If the content is a symlink and the symlink's target is a normal file in the repository, then the API responds with the content of the file. Otherwise, the API responds with an object describing the symlink itself.

If the content is a submodule, the `submodule_git_url` field identifies the location of the submodule repository, and the `sha` identifies a specific commit within the submodule repository. Git uses the given URL when cloning the submodule repository, and checks out the submodule at that specific commit. If the submodule repository is not hosted on github.com, the Git URLs (`git_url` and `_links["git"]`) and the github.com URLs (`html_url` and `_links["html"]`) will have null values.

**Notes**:

- To get a repository's contents recursively, you can [recursively get the tree](https://docs.github.com/rest/git/trees#get-a-tree).
- This API has an upper limit of 1,000 files for a directory. If you need to retrieve
more files, use the [Git Trees API](https://docs.github.com/rest/git/trees#get-a-tree).
- Download URLs expire and are meant to be used just once. To ensure the download URL does not expire, please use the contents API to obtain a fresh download URL for each download.
- If the requested file's size is:
  - 1 MB or smaller: All features of this endpoint are supported.
  - Between 1-100 MB: Only the `raw` or `object` custom media types are supported. Both will work as normal, except that when using the `object` media type, the `content` field will be an empty
string and the `encoding` field will be `"none"`. To get the contents of these larger files, use the `raw` media type.
  - Greater than 100 MB: This endpoint is not supported.

## Options

  * `ref`: The name of the commit/branch/tag. Default: the repository’s default branch.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/contents#get-repository-content)

## get_contributors_stats(owner, repo, opts \\ [])

Get all contributor commit activity


Returns the `total` number of commits authored by the contributor. In addition, the response includes a Weekly Hash (`weeks` array) with the following information:

*   `w` - Start of the week, given as a [Unix timestamp](https://en.wikipedia.org/wiki/Unix_time).
*   `a` - Number of additions
*   `d` - Number of deletions
*   `c` - Number of commits

**Note:** This endpoint will return `0` values for all addition and deletion counts in repositories with 10,000 or more commits.

## Resources

  * [API method documentation](https://docs.github.com/rest/metrics/statistics#get-all-contributor-commit-activity)

## get_custom_deployment_protection_rule(owner, repo, environment_name, protection_rule_id, opts \\ [])

Get a custom deployment protection rule

Gets an enabled custom deployment protection rule for an environment. Anyone with read access to the repository can use this endpoint. For more information about environments, see "[Using environments for deployment](https://docs.github.com/actions/deployment/targeting-different-environments/using-environments-for-deployment)."

For more information about the app that is providing this custom deployment rule, see [`GET /apps/{app_slug}`](https://docs.github.com/rest/apps/apps#get-an-app).

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/protection-rules#get-a-custom-deployment-protection-rule)

## get_custom_properties_values(owner, repo, opts \\ [])

Get all custom property values for a repository

Gets all custom property values that are set for a repository.
Users with read access to the repository can use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/custom-properties#get-all-custom-property-values-for-a-repository)

## get_deploy_key(owner, repo, key_id, opts \\ [])

Get a deploy key

## Resources

  * [API method documentation](https://docs.github.com/rest/deploy-keys/deploy-keys#get-a-deploy-key)

## get_deployment(owner, repo, deployment_id, opts \\ [])

Get a deployment

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/deployments#get-a-deployment)

## get_deployment_branch_policy(owner, repo, environment_name, branch_policy_id, opts \\ [])

Get a deployment branch policy

Gets a deployment branch or tag policy for an environment.

Anyone with read access to the repository can use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/branch-policies#get-a-deployment-branch-policy)

## get_deployment_status(owner, repo, deployment_id, status_id, opts \\ [])

Get a deployment status

Users with pull access can view a deployment status for a deployment:

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/statuses#get-a-deployment-status)

## get_environment(owner, repo, environment_name, opts \\ [])

Get an environment

**Note:** To get information about name patterns that branches must match in order to deploy to this environment, see "[Get a deployment branch policy](https://docs.github.com/rest/deployments/branch-policies#get-a-deployment-branch-policy)."

Anyone with read access to the repository can use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/environments#get-an-environment)

## get_latest_pages_build(owner, repo, opts \\ [])

Get latest Pages build

Gets information about the single most recent build of a GitHub Pages site.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/pages/pages#get-latest-pages-build)

## get_latest_release(owner, repo, opts \\ [])

Get the latest release

View the latest published full release for the repository.

The latest release is the most recent non-prerelease, non-draft release, sorted by the `created_at` attribute. The `created_at` attribute is the date of the commit used for the release, and not the date when the release was drafted or published.

## Resources

  * [API method documentation](https://docs.github.com/rest/releases/releases#get-the-latest-release)

## get_org_rule_suite(org, rule_suite_id, opts \\ [])

Get an organization rule suite

Gets information about a suite of rule evaluations from within an organization.
For more information, see "[Managing rulesets for repositories in your organization](https://docs.github.com/organizations/managing-organization-settings/managing-rulesets-for-repositories-in-your-organization#viewing-insights-for-rulesets)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/rule-suites#get-an-organization-rule-suite)

## get_org_rule_suites(org, opts \\ [])

List organization rule suites

Lists suites of rule evaluations at the organization level.
For more information, see "[Managing rulesets for repositories in your organization](https://docs.github.com/organizations/managing-organization-settings/managing-rulesets-for-repositories-in-your-organization#viewing-insights-for-rulesets)."

## Options

  * `repository_name`: The name of the repository to filter on. When specified, only rule evaluations from this repository will be returned.
  * `time_period`: The time period to filter by.
    
    For example, `day` will filter for rule suites that occurred in the past 24 hours, and `week` will filter for insights that occurred in the past 7 days (168 hours).
  * `actor_name`: The handle for the GitHub user account to filter on. When specified, only rule evaluations triggered by this actor will be returned.
  * `rule_suite_result`: The rule results to filter on. When specified, only suites with this result will be returned.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/rule-suites#list-organization-rule-suites)

## get_org_ruleset(org, ruleset_id, opts \\ [])

Get an organization repository ruleset

Get a repository ruleset for an organization.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/rules#get-an-organization-repository-ruleset)

## get_org_rulesets(org, opts \\ [])

Get all organization repository rulesets

Get all the repository rulesets for an organization.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/rules#get-all-organization-repository-rulesets)

## get_pages(owner, repo, opts \\ [])

Get a GitHub Pages site

Gets information about a GitHub Pages site.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/pages/pages#get-a-apiname-pages-site)

## get_pages_build(owner, repo, build_id, opts \\ [])

Get GitHub Pages build

Gets information about a GitHub Pages build.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/pages/pages#get-apiname-pages-build)

## get_pages_deployment(owner, repo, pages_deployment_id, opts \\ [])

Get the status of a GitHub Pages deployment

Gets the current status of a GitHub Pages deployment.

The authenticated user must have read permission for the GitHub Pages site.

## Resources

  * [API method documentation](https://docs.github.com/rest/pages/pages#get-the-status-of-a-github-pages-deployment)

## get_pages_health_check(owner, repo, opts \\ [])

Get a DNS health check for GitHub Pages

Gets a health check of the DNS settings for the `CNAME` record configured for a repository's GitHub Pages.

The first request to this endpoint returns a `202 Accepted` status and starts an asynchronous background task to get the results for the domain. After the background task completes, subsequent requests to this endpoint return a `200 OK` status with the health check results in the response.

The authenticated user must be a repository administrator, maintainer, or have the 'manage GitHub Pages settings' permission to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/pages/pages#get-a-dns-health-check-for-github-pages)

## get_participation_stats(owner, repo, opts \\ [])

Get the weekly commit count

Returns the total commit counts for the `owner` and total commit counts in `all`. `all` is everyone combined, including the `owner` in the last 52 weeks. If you'd like to get the commit counts for non-owners, you can subtract `owner` from `all`.

The array order is oldest week (index 0) to most recent week.

The most recent week is seven days ago at UTC midnight to today at UTC midnight.

## Resources

  * [API method documentation](https://docs.github.com/rest/metrics/statistics#get-the-weekly-commit-count)

## get_pull_request_review_protection(owner, repo, branch, opts \\ [])

Get pull request review protection

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#get-pull-request-review-protection)

## get_punch_card_stats(owner, repo, opts \\ [])

Get the hourly commit count for each day

Each array contains the day number, hour number, and number of commits:

*   `0-6`: Sunday - Saturday
*   `0-23`: Hour of day
*   Number of commits

For example, `[2, 14, 25]` indicates that there were 25 total commits, during the 2:00pm hour on Tuesdays. All times are based on the time zone of individual commits.

## Resources

  * [API method documentation](https://docs.github.com/rest/metrics/statistics#get-the-hourly-commit-count-for-each-day)

## get_readme(owner, repo, opts \\ [])

Get a repository README

Gets the preferred README for a repository.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw file contents. This is the default if you do not specify a media type.
- **`application/vnd.github.html+json`**: Returns the README in HTML. Markup languages are rendered to HTML using GitHub's open-source [Markup library](https://github.com/github/markup).

## Options

  * `ref`: The name of the commit/branch/tag. Default: the repository’s default branch.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/contents#get-a-repository-readme)

## get_readme_in_directory(owner, repo, dir, opts \\ [])

Get a repository README for a directory

Gets the README from a repository directory.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github.raw+json`**: Returns the raw file contents. This is the default if you do not specify a media type.
- **`application/vnd.github.html+json`**: Returns the README in HTML. Markup languages are rendered to HTML using GitHub's open-source [Markup library](https://github.com/github/markup).

## Options

  * `ref`: The name of the commit/branch/tag. Default: the repository’s default branch.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/contents#get-a-repository-readme-for-a-directory)

## get_release(owner, repo, release_id, opts \\ [])

Get a release

Gets a public release with the specified release ID.

**Note:** This returns an `upload_url` key corresponding to the endpoint
for uploading release assets. This key is a hypermedia resource. For more information, see
"[Getting started with the REST API](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#hypermedia)."

## Resources

  * [API method documentation](https://docs.github.com/rest/releases/releases#get-a-release)

## get_release_asset(owner, repo, asset_id, opts \\ [])

Get a release asset

To download the asset's binary content, set the `Accept` header of the request to [`application/octet-stream`](https://docs.github.com/rest/overview/media-types). The API will either redirect the client to the location, or stream it directly if possible. API clients should handle both a `200` or `302` response.

## Resources

  * [API method documentation](https://docs.github.com/rest/releases/assets#get-a-release-asset)

## get_release_by_tag(owner, repo, tag, opts \\ [])

Get a release by tag name

Get a published release with the specified tag.

## Resources

  * [API method documentation](https://docs.github.com/rest/releases/releases#get-a-release-by-tag-name)

## get_repo_rule_suite(owner, repo, rule_suite_id, opts \\ [])

Get a repository rule suite

Gets information about a suite of rule evaluations from within a repository.
For more information, see "[Managing rulesets for a repository](https://docs.github.com/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/managing-rulesets-for-a-repository#viewing-insights-for-rulesets)."

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/rule-suites#get-a-repository-rule-suite)

## get_repo_rule_suites(owner, repo, opts \\ [])

List repository rule suites

Lists suites of rule evaluations at the repository level.
For more information, see "[Managing rulesets for a repository](https://docs.github.com/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/managing-rulesets-for-a-repository#viewing-insights-for-rulesets)."

## Options

  * `ref`: The name of the ref. Cannot contain wildcard characters. When specified, only rule evaluations triggered for this ref will be returned.
  * `time_period`: The time period to filter by.
    
    For example, `day` will filter for rule suites that occurred in the past 24 hours, and `week` will filter for insights that occurred in the past 7 days (168 hours).
  * `actor_name`: The handle for the GitHub user account to filter on. When specified, only rule evaluations triggered by this actor will be returned.
  * `rule_suite_result`: The rule results to filter on. When specified, only suites with this result will be returned.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/rule-suites#list-repository-rule-suites)

## get_repo_ruleset(owner, repo, ruleset_id, opts \\ [])

Get a repository ruleset

Get a ruleset for a repository.

## Options

  * `includes_parents`: Include rulesets configured at higher levels that apply to this repository

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/rules#get-a-repository-ruleset)

## get_repo_rulesets(owner, repo, opts \\ [])

Get all repository rulesets

Get all the rulesets for a repository.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `includes_parents`: Include rulesets configured at higher levels that apply to this repository

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/rules#get-all-repository-rulesets)

## get_status_checks_protection(owner, repo, branch, opts \\ [])

Get status checks protection

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#get-status-checks-protection)

## get_teams_with_access_to_protected_branch(owner, repo, branch, opts \\ [])

Get teams with access to the protected branch

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

Lists the teams who have push access to this branch. The list includes child teams.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#get-teams-with-access-to-the-protected-branch)

## get_top_paths(owner, repo, opts \\ [])

Get top referral paths

Get the top 10 popular contents over the last 14 days.

## Resources

  * [API method documentation](https://docs.github.com/rest/metrics/traffic#get-top-referral-paths)

## get_top_referrers(owner, repo, opts \\ [])

Get top referral sources

Get the top 10 referrers over the last 14 days.

## Resources

  * [API method documentation](https://docs.github.com/rest/metrics/traffic#get-top-referral-sources)

## get_users_with_access_to_protected_branch(owner, repo, branch, opts \\ [])

Get users with access to the protected branch

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

Lists the people who have push access to this branch.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#get-users-with-access-to-the-protected-branch)

## get_views(owner, repo, opts \\ [])

Get page views

Get the total number of views and breakdown per day or week for the last 14 days. Timestamps are aligned to UTC midnight of the beginning of the day or week. Week begins on Monday.

## Options

  * `per`: The time frame to display results for.

## Resources

  * [API method documentation](https://docs.github.com/rest/metrics/traffic#get-page-views)

## get_webhook(owner, repo, hook_id, opts \\ [])

Get a repository webhook

Returns a webhook configured in a repository. To get only the webhook `config` properties, see "[Get a webhook configuration for a repository](https://docs.github.com/rest/webhooks/repo-config#get-a-webhook-configuration-for-a-repository)."

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/webhooks#get-a-repository-webhook)

## get_webhook_config_for_repo(owner, repo, hook_id, opts \\ [])

Get a webhook configuration for a repository

Returns the webhook configuration for a repository. To get more information about the webhook, including the `active` state and `events`, use "[Get a repository webhook](https://docs.github.com/rest/webhooks/repos#get-a-repository-webhook)."

OAuth app tokens and personal access tokens (classic) need the `read:repo_hook` or `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/webhooks#get-a-webhook-configuration-for-a-repository)

## get_webhook_delivery(owner, repo, hook_id, delivery_id, opts \\ [])

Get a delivery for a repository webhook

Returns a delivery for a webhook configured in a repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/webhooks#get-a-delivery-for-a-repository-webhook)

## list_activities(owner, repo, opts \\ [])

List repository activities

Lists a detailed history of changes to a repository, such as pushes, merges, force pushes, and branch changes, and associates these changes with commits and users.

For more information about viewing repository activity,
see "[Viewing activity and data for your repository](https://docs.github.com/repositories/viewing-activity-and-data-for-your-repository)."

## Options

  * `direction`: The direction to sort the results by.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `before`: A cursor, as given in the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers). If specified, the query only searches for results before this cursor. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `after`: A cursor, as given in the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers). If specified, the query only searches for results after this cursor. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `ref`: The Git reference for the activities you want to list.
    
    The `ref` for a branch can be formatted either as `refs/heads/BRANCH_NAME` or `BRANCH_NAME`, where `BRANCH_NAME` is the name of your branch.
  * `actor`: The GitHub username to use to filter by the actor who performed the activity.
  * `time_period`: The time period to filter by.
    
    For example, `day` will filter for activity that occurred in the past 24 hours, and `week` will filter for activity that occurred in the past 7 days (168 hours).
  * `activity_type`: The activity type to filter by.
    
    For example, you can choose to filter by "force_push", to see all force pushes to the repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#list-repository-activities)

## list_autolinks(owner, repo, opts \\ [])

Get all autolinks of a repository

Gets all autolinks that are configured for a repository.

Information about autolinks are only available to repository administrators.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/autolinks#get-all-autolinks-of-a-repository)

## list_branches(owner, repo, opts \\ [])

List branches

## Options

  * `protected`: Setting to `true` returns only protected branches. When set to `false`, only unprotected branches are returned. Omitting this parameter returns all branches.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branches#list-branches)

## list_branches_for_head_commit(owner, repo, commit_sha, opts \\ [])

List branches for HEAD commit

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

Returns all branches where the given commit SHA is the HEAD, or latest commit for the branch.

## Resources

  * [API method documentation](https://docs.github.com/rest/commits/commits#list-branches-for-head-commit)

## list_collaborators(owner, repo, opts \\ [])

List repository collaborators

For organization-owned repositories, the list of collaborators includes outside collaborators, organization members that are direct collaborators, organization members with access through team memberships, organization members with access through default organization permissions, and organization owners.
Organization members with write, maintain, or admin privileges on the organization-owned repository can use this endpoint.

Team members will include the members of child teams.

The authenticated user must have push access to the repository to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `read:org` and `repo` scopes to use this endpoint.

## Options

  * `affiliation`: Filter collaborators returned by their affiliation. `outside` means all outside collaborators of an organization-owned repository. `direct` means all collaborators with permissions to an organization-owned repository, regardless of organization membership status. `all` means all collaborators the authenticated user can see.
  * `permission`: Filter collaborators by the permissions they have on the repository. If not specified, all collaborators will be returned.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/collaborators/collaborators#list-repository-collaborators)

## list_comments_for_commit(owner, repo, commit_sha, opts \\ [])

List commit comments

Lists the comments for a specified commit.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github-commitcomment.raw+json`**: Returns the raw markdown body. Response will include `body`. This is the default if you do not pass any specific media type.
- **`application/vnd.github-commitcomment.text+json`**: Returns a text only representation of the markdown body. Response will include `body_text`.
- **`application/vnd.github-commitcomment.html+json`**: Returns HTML rendered from the body's markdown. Response will include `body_html`.
- **`application/vnd.github-commitcomment.full+json`**: Returns raw, text, and HTML representations. Response will include `body`, `body_text`, and `body_html`.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/commits/comments#list-commit-comments)

## list_commit_comments_for_repo(owner, repo, opts \\ [])

List commit comments for a repository

Lists the commit comments for a specified repository. Comments are ordered by ascending ID.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github-commitcomment.raw+json`**: Returns the raw markdown body. Response will include `body`. This is the default if you do not pass any specific media type.
- **`application/vnd.github-commitcomment.text+json`**: Returns a text only representation of the markdown body. Response will include `body_text`.
- **`application/vnd.github-commitcomment.html+json`**: Returns HTML rendered from the body's markdown. Response will include `body_html`.
- **`application/vnd.github-commitcomment.full+json`**: Returns raw, text, and HTML representations. Response will include `body`, `body_text`, and `body_html`.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/commits/comments#list-commit-comments-for-a-repository)

## list_commit_statuses_for_ref(owner, repo, ref, opts \\ [])

List commit statuses for a reference

Users with pull access in a repository can view commit statuses for a given ref. The ref can be a SHA, a branch name, or a tag name. Statuses are returned in reverse chronological order. The first status in the list will be the latest one.

This resource is also available via a legacy route: `GET /repos/:owner/:repo/statuses/:ref`.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/commits/statuses#list-commit-statuses-for-a-reference)

## list_commits(owner, repo, opts \\ [])

List commits

**Signature verification object**

The response will include a `verification` object that describes the result of verifying the commit's signature. The following fields are included in the `verification` object:

| Name | Type | Description |
| ---- | ---- | ----------- |
| `verified` | `boolean` | Indicates whether GitHub considers the signature in this commit to be verified. |
| `reason` | `string` | The reason for verified value. Possible values and their meanings are enumerated in table below. |
| `signature` | `string` | The signature that was extracted from the commit. |
| `payload` | `string` | The value that was signed. |

These are the possible values for `reason` in the `verification` object:

| Value | Description |
| ----- | ----------- |
| `expired_key` | The key that made the signature is expired. |
| `not_signing_key` | The "signing" flag is not among the usage flags in the GPG key that made the signature. |
| `gpgverify_error` | There was an error communicating with the signature verification service. |
| `gpgverify_unavailable` | The signature verification service is currently unavailable. |
| `unsigned` | The object does not include a signature. |
| `unknown_signature_type` | A non-PGP signature was found in the commit. |
| `no_user` | No user was associated with the `committer` email address in the commit. |
| `unverified_email` | The `committer` email address in the commit was associated with a user, but the email address is not verified on their account. |
| `bad_email` | The `committer` email address in the commit is not included in the identities of the PGP key that made the signature. |
| `unknown_key` | The key that made the signature has not been registered with any user's account. |
| `malformed_signature` | There was an error parsing the signature. |
| `invalid` | The signature could not be cryptographically verified using the key whose key-id was found in the signature. |
| `valid` | None of the above errors applied, so the signature is considered to be verified. |

## Options

  * `sha`: SHA or branch to start listing commits from. Default: the repository’s default branch (usually `main`).
  * `path`: Only commits containing this file path will be returned.
  * `author`: GitHub username or email address to use to filter by commit author.
  * `committer`: GitHub username or email address to use to filter by commit committer.
  * `since`: Only show results that were last updated after the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
  * `until`: Only commits before this date will be returned. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/commits/commits#list-commits)

## list_contributors(owner, repo, opts \\ [])

List repository contributors

Lists contributors to the specified repository and sorts them by the number of commits per contributor in descending order. This endpoint may return information that is a few hours old because the GitHub REST API caches contributor data to improve performance.

GitHub identifies contributors by author email address. This endpoint groups contribution counts by GitHub user, which includes all associated email addresses. To improve performance, only the first 500 author email addresses in the repository link to GitHub users. The rest will appear as anonymous contributors without associated GitHub user information.

## Options

  * `anon`: Set to `1` or `true` to include anonymous contributors in results.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#list-repository-contributors)

## list_custom_deployment_rule_integrations(environment_name, repo, owner, opts \\ [])

List custom deployment rule integrations available for an environment

Gets all custom deployment protection rule integrations that are available for an environment. Anyone with read access to the repository can use this endpoint.

For more information about environments, see "[Using environments for deployment](https://docs.github.com/actions/deployment/targeting-different-environments/using-environments-for-deployment)."

For more information about the app that is providing this custom deployment rule, see "[GET an app](https://docs.github.com/rest/apps/apps#get-an-app)".

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.

## Options

  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/protection-rules#list-custom-deployment-rule-integrations-available-for-an-environment)

## list_deploy_keys(owner, repo, opts \\ [])

List deploy keys

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/deploy-keys/deploy-keys#list-deploy-keys)

## list_deployment_branch_policies(owner, repo, environment_name, opts \\ [])

List deployment branch policies

Lists the deployment branch policies for an environment.

Anyone with read access to the repository can use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint with a private repository.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/branch-policies#list-deployment-branch-policies)

## list_deployment_statuses(owner, repo, deployment_id, opts \\ [])

List deployment statuses

Users with pull access can view deployment statuses for a deployment:

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/statuses#list-deployment-statuses)

## list_deployments(owner, repo, opts \\ [])

List deployments

Simple filtering of deployments is available via query parameters:

## Options

  * `sha`: The SHA recorded at creation time.
  * `ref`: The name of the ref. This can be a branch, tag, or SHA.
  * `task`: The name of the task for the deployment (e.g., `deploy` or `deploy:migrations`).
  * `environment`: The name of the environment that was deployed to (e.g., `staging` or `production`).
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/deployments#list-deployments)

## list_for_authenticated_user(opts \\ [])

List repositories for the authenticated user

Lists repositories that the authenticated user has explicit permission (`:read`, `:write`, or `:admin`) to access.

The authenticated user has explicit permission to access repositories they own, repositories where they are a collaborator, and repositories that they can access through an organization membership.

## Options

  * `visibility`: Limit results to repositories with the specified visibility.
  * `affiliation`: Comma-separated list of values. Can include:  
     * `owner`: Repositories that are owned by the authenticated user.  
     * `collaborator`: Repositories that the user has been added to as a collaborator.  
     * `organization_member`: Repositories that the user has access to through being a member of an organization. This includes every repository on every team that the user is on.
  * `type`: Limit results to repositories of the specified type. Will cause a `422` error if used in the same request as **visibility** or **affiliation**.
  * `sort`: The property to sort the results by.
  * `direction`: The order to sort by. Default: `asc` when using `full_name`, otherwise `desc`.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `since`: Only show repositories updated after the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
  * `before`: Only show repositories updated before the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#list-repositories-for-the-authenticated-user)

## list_for_org(org, opts \\ [])

List organization repositories

Lists repositories for the specified organization.

**Note:** In order to see the `security_and_analysis` block for a repository you must have admin permissions for the repository or be an owner or security manager for the organization that owns the repository. For more information, see "[Managing security managers in your organization](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/managing-security-managers-in-your-organization)."

## Options

  * `type`: Specifies the types of repositories you want returned.
  * `sort`: The property to sort the results by.
  * `direction`: The order to sort by. Default: `asc` when using `full_name`, otherwise `desc`.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#list-organization-repositories)

## list_for_user(username, opts \\ [])

List repositories for a user

Lists public repositories for the specified user.

## Options

  * `type`: Limit results to repositories of the specified type.
  * `sort`: The property to sort the results by.
  * `direction`: The order to sort by. Default: `asc` when using `full_name`, otherwise `desc`.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#list-repositories-for-a-user)

## list_forks(owner, repo, opts \\ [])

List forks

## Options

  * `sort`: The sort order. `stargazers` will sort by star count.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/forks#list-forks)

## list_invitations(owner, repo, opts \\ [])

List repository invitations

When authenticating as a user with admin rights to a repository, this endpoint will list all currently open repository invitations.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/collaborators/invitations#list-repository-invitations)

## list_invitations_for_authenticated_user(opts \\ [])

List repository invitations for the authenticated user

When authenticating as a user, this endpoint will list all currently open repository invitations for that user.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/collaborators/invitations#list-repository-invitations-for-the-authenticated-user)

## list_languages(owner, repo, opts \\ [])

List repository languages

Lists languages for the specified repository. The value shown for each language is the number of bytes of code written in that language.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#list-repository-languages)

## list_pages_builds(owner, repo, opts \\ [])

List GitHub Pages builds

Lists builts of a GitHub Pages site.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/pages/pages#list-apiname-pages-builds)

## list_public(opts \\ [])

List public repositories

Lists all public repositories in the order that they were created.

Note:
- For GitHub Enterprise Server, this endpoint will only list repositories available to all users on the enterprise.
- Pagination is powered exclusively by the `since` parameter. Use the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers) to get the URL for the next page of repositories.

## Options

  * `since`: A repository ID. Only return repositories with an ID greater than this ID.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#list-public-repositories)

## list_pull_requests_associated_with_commit(owner, repo, commit_sha, opts \\ [])

List pull requests associated with a commit

Lists the merged pull request that introduced the commit to the repository. If the commit is not present in the default branch, will only return open pull requests associated with the commit.

To list the open or merged pull requests associated with a branch, you can set the `commit_sha` parameter to the branch name.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/commits/commits#list-pull-requests-associated-with-a-commit)

## list_release_assets(owner, repo, release_id, opts \\ [])

List release assets

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/releases/assets#list-release-assets)

## list_releases(owner, repo, opts \\ [])

List releases

This returns a list of releases, which does not include regular Git tags that have not been associated with a release. To get a list of Git tags, use the [Repository Tags API](https://docs.github.com/rest/repos/repos#list-repository-tags).

Information about published releases are available to everyone. Only users with push access will receive listings for draft releases.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/releases/releases#list-releases)

## list_tag_protection(owner, repo, opts \\ [])

List tag protection states for a repository

This returns the tag protection states of a repository.

This information is only available to repository administrators.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/tags#list-tag-protection-states-for-a-repository)

## list_tags(owner, repo, opts \\ [])

List repository tags

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#list-repository-tags)

## list_teams(owner, repo, opts \\ [])

List repository teams

Lists the teams that have access to the specified repository and that are also visible to the authenticated user.

For a public repository, a team is listed only if that team added the public repository explicitly.

OAuth app tokens and personal access tokens (classic) need the `public_repo` or `repo` scope to use this endpoint with a public repository, and `repo` scope to use this endpoint with a private repository.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#list-repository-teams)

## list_webhook_deliveries(owner, repo, hook_id, opts \\ [])

List deliveries for a repository webhook

Returns a list of webhook deliveries for a webhook configured in a repository.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `cursor`: Used for pagination: the starting delivery from which the page of deliveries is fetched. Refer to the `link` header for the next and previous page cursors.
  * `redelivery`

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/webhooks#list-deliveries-for-a-repository-webhook)

## list_webhooks(owner, repo, opts \\ [])

List repository webhooks

Lists webhooks for a repository. `last response` may return null if there have not been any deliveries within 30 days.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/webhooks#list-repository-webhooks)

## merge(owner, repo, body, opts \\ [])

Merge a branch

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branches#merge-a-branch)

## merge_upstream(owner, repo, body, opts \\ [])

Sync a fork branch with the upstream repository

Sync a branch of a forked repository to keep it up-to-date with the upstream repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branches#sync-a-fork-branch-with-the-upstream-repository)

## ping_webhook(owner, repo, hook_id, opts \\ [])

Ping a repository webhook

This will trigger a [ping event](https://docs.github.com/webhooks/#ping-event) to be sent to the hook.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/webhooks#ping-a-repository-webhook)

## redeliver_webhook_delivery(owner, repo, hook_id, delivery_id, opts \\ [])

Redeliver a delivery for a repository webhook

Redeliver a webhook delivery for a webhook configured in a repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/webhooks#redeliver-a-delivery-for-a-repository-webhook)

## remove_app_access_restrictions(owner, repo, branch, body, opts \\ [])

Remove app access restrictions

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

Removes the ability of an app to push to this branch. Only GitHub Apps that are installed on the repository and that have been granted write access to the repository contents can be added as authorized actors on a protected branch.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#remove-app-access-restrictions)

## remove_collaborator(owner, repo, username, opts \\ [])

Remove a repository collaborator

Removes a collaborator from a repository.

To use this endpoint, the authenticated user must either be an administrator of the repository or target themselves for removal.

This endpoint also:
- Cancels any outstanding invitations
- Unasigns the user from any issues
- Removes access to organization projects if the user is not an organization member and is not a collaborator on any other organization repositories.
- Unstars the repository
- Updates access permissions to packages

Removing a user as a collaborator has the following effects on forks:
 - If the user had access to a fork through their membership to this repository, the user will also be removed from the fork.
 - If the user had their own fork of the repository, the fork will be deleted.
 - If the user still has read access to the repository, open pull requests by this user from a fork will be denied.

**Note**: A user can still have access to the repository through organization permissions like base repository permissions.

Although the API responds immediately, the additional permission updates might take some extra time to complete in the background.

For more information on fork permissions, see "[About permissions and visibility of forks](https://docs.github.com/pull-requests/collaborating-with-pull-requests/working-with-forks/about-permissions-and-visibility-of-forks)".

## Resources

  * [API method documentation](https://docs.github.com/rest/collaborators/collaborators#remove-a-repository-collaborator)

## remove_status_check_contexts(owner, repo, branch, body, opts \\ [])

Remove status check contexts

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#remove-status-check-contexts)

## remove_status_check_protection(owner, repo, branch, opts \\ [])

Remove status check protection

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#remove-status-check-protection)

## remove_team_access_restrictions(owner, repo, branch, body, opts \\ [])

Remove team access restrictions

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

Removes the ability of a team to push to this branch. You can also remove push access for child teams.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#remove-team-access-restrictions)

## remove_user_access_restrictions(owner, repo, branch, body, opts \\ [])

Remove user access restrictions

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

Removes the ability of a user to push to this branch.

| Type    | Description                                                                                                                                   |
| ------- | --------------------------------------------------------------------------------------------------------------------------------------------- |
| `array` | Usernames of the people who should no longer have push access. **Note**: The list of users, apps, and teams in total is limited to 100 items. |

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#remove-user-access-restrictions)

## rename_branch(owner, repo, branch, body, opts \\ [])

Rename a branch

Renames a branch in a repository.

**Note:** Although the API responds immediately, the branch rename process might take some extra time to complete in the background. You won't be able to push to the old branch name while the rename process is in progress. For more information, see "[Renaming a branch](https://docs.github.com/github/administering-a-repository/renaming-a-branch)".

The authenticated user must have push access to the branch. If the branch is the default branch, the authenticated user must also have admin or owner permissions.

In order to rename the default branch, fine-grained access tokens also need the `administration:write` repository permission.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branches#rename-a-branch)

## replace_all_topics(owner, repo, body, opts \\ [])

Replace all repository topics

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#replace-all-repository-topics)

## request_pages_build(owner, repo, opts \\ [])

Request a GitHub Pages build

You can request that your site be built from the latest revision on the default branch. This has the same effect as pushing a commit to your default branch, but does not require an additional commit. Manually triggering page builds can be helpful when diagnosing build warnings and failures.

Build requests are limited to one concurrent build per repository and one concurrent build per requester. If you request a build while another is still in progress, the second request will be queued until the first completes.

## Resources

  * [API method documentation](https://docs.github.com/rest/pages/pages#request-a-apiname-pages-build)

## set_admin_branch_protection(owner, repo, branch, opts \\ [])

Set admin branch protection

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

Adding admin enforcement requires admin or owner permissions to the repository and branch protection to be enabled.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#set-admin-branch-protection)

## set_app_access_restrictions(owner, repo, branch, body, opts \\ [])

Set app access restrictions

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

Replaces the list of apps that have push access to this branch. This removes all apps that previously had push access and grants push access to the new list of apps. Only GitHub Apps that are installed on the repository and that have been granted write access to the repository contents can be added as authorized actors on a protected branch.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#set-app-access-restrictions)

## set_status_check_contexts(owner, repo, branch, body, opts \\ [])

Set status check contexts

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#set-status-check-contexts)

## set_team_access_restrictions(owner, repo, branch, body, opts \\ [])

Set team access restrictions

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

Replaces the list of teams that have push access to this branch. This removes all teams that previously had push access and grants push access to the new list of teams. Team restrictions include child teams.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#set-team-access-restrictions)

## set_user_access_restrictions(owner, repo, branch, body, opts \\ [])

Set user access restrictions

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

Replaces the list of people that have push access to this branch. This removes all people that previously had push access and grants push access to the new list of people.

| Type    | Description                                                                                                                   |
| ------- | ----------------------------------------------------------------------------------------------------------------------------- |
| `array` | Usernames for people who can have push access. **Note**: The list of users, apps, and teams in total is limited to 100 items. |

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#set-user-access-restrictions)

## test_push_webhook(owner, repo, hook_id, opts \\ [])

Test the push repository webhook

This will trigger the hook with the latest push to the current repository if the hook is subscribed to `push` events. If the hook is not subscribed to `push` events, the server will respond with 204 but no test POST will be generated.

**Note**: Previously `/repos/:owner/:repo/hooks/:hook_id/test`

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/webhooks#test-the-push-repository-webhook)

## transfer(owner, repo, body, opts \\ [])

Transfer a repository

A transfer request will need to be accepted by the new owner when transferring a personal repository to another user. The response will contain the original `owner`, and the transfer will continue asynchronously. For more details on the requirements to transfer personal and organization-owned repositories, see [about repository transfers](https://docs.github.com/articles/about-repository-transfers/).

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#transfer-a-repository)

## update(owner, repo, body, opts \\ [])

Update a repository

**Note**: To edit a repository's topics, use the [Replace all repository topics](https://docs.github.com/rest/repos/repos#replace-all-repository-topics) endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/repos#update-a-repository)

## update_branch_protection(owner, repo, branch, body, opts \\ [])

Update branch protection

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

Protecting a branch requires admin or owner permissions to the repository.

**Note**: Passing new arrays of `users` and `teams` replaces their previous values.

**Note**: The list of users, apps, and teams in total is limited to 100 items.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#update-branch-protection)

## update_commit_comment(owner, repo, comment_id, body, opts \\ [])

Update a commit comment

Updates the contents of a specified commit comment.

This endpoint supports the following custom media types. For more information, see "[Media types](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#media-types)."

- **`application/vnd.github-commitcomment.raw+json`**: Returns the raw markdown body. Response will include `body`. This is the default if you do not pass any specific media type.
- **`application/vnd.github-commitcomment.text+json`**: Returns a text only representation of the markdown body. Response will include `body_text`.
- **`application/vnd.github-commitcomment.html+json`**: Returns HTML rendered from the body's markdown. Response will include `body_html`.
- **`application/vnd.github-commitcomment.full+json`**: Returns raw, text, and HTML representations. Response will include `body`, `body_text`, and `body_html`.

## Resources

  * [API method documentation](https://docs.github.com/rest/commits/comments#update-a-commit-comment)

## update_deployment_branch_policy(owner, repo, environment_name, branch_policy_id, body, opts \\ [])

Update a deployment branch policy

Updates a deployment branch or tag policy for an environment.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/deployments/branch-policies#update-a-deployment-branch-policy)

## update_information_about_pages_site(owner, repo, body, opts \\ [])

Update information about a GitHub Pages site

Updates information for a GitHub Pages site. For more information, see "[About GitHub Pages](https://docs.github.com/github/working-with-github-pages/about-github-pages).

The authenticated user must be a repository administrator, maintainer, or have the 'manage GitHub Pages settings' permission.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/pages/pages#update-information-about-a-apiname-pages-site)

## update_invitation(owner, repo, invitation_id, body, opts \\ [])

Update a repository invitation

## Resources

  * [API method documentation](https://docs.github.com/rest/collaborators/invitations#update-a-repository-invitation)

## update_org_ruleset(org, ruleset_id, body, opts \\ [])

Update an organization repository ruleset

Update a ruleset for an organization.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/rules#update-an-organization-repository-ruleset)

## update_pull_request_review_protection(owner, repo, branch, body, opts \\ [])

Update pull request review protection

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

Updating pull request review enforcement requires admin or owner permissions to the repository and branch protection to be enabled.

**Note**: Passing new arrays of `users` and `teams` replaces their previous values.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#update-pull-request-review-protection)

## update_release(owner, repo, release_id, body, opts \\ [])

Update a release

Users with push access to the repository can edit a release.

## Resources

  * [API method documentation](https://docs.github.com/rest/releases/releases#update-a-release)

## update_release_asset(owner, repo, asset_id, body, opts \\ [])

Update a release asset

Users with push access to the repository can edit a release asset.

## Resources

  * [API method documentation](https://docs.github.com/rest/releases/assets#update-a-release-asset)

## update_repo_ruleset(owner, repo, ruleset_id, body, opts \\ [])

Update a repository ruleset

Update a ruleset for a repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/rules#update-a-repository-ruleset)

## update_status_check_protection(owner, repo, branch, body, opts \\ [])

Update status check protection

Protected branches are available in public repositories with GitHub Free and GitHub Free for organizations, and in public and private repositories with GitHub Pro, GitHub Team, GitHub Enterprise Cloud, and GitHub Enterprise Server. For more information, see [GitHub's products](https://docs.github.com/github/getting-started-with-github/githubs-products) in the GitHub Help documentation.

Updating required status checks requires admin or owner permissions to the repository and branch protection to be enabled.

## Resources

  * [API method documentation](https://docs.github.com/rest/branches/branch-protection#update-status-check-protection)

## update_webhook(owner, repo, hook_id, body, opts \\ [])

Update a repository webhook

Updates a webhook configured in a repository. If you previously had a `secret` set, you must provide the same `secret` or set a new `secret` or the secret will be removed. If you are only updating individual webhook `config` properties, use "[Update a webhook configuration for a repository](https://docs.github.com/rest/webhooks/repo-config#update-a-webhook-configuration-for-a-repository)."

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/webhooks#update-a-repository-webhook)

## update_webhook_config_for_repo(owner, repo, hook_id, body, opts \\ [])

Update a webhook configuration for a repository

Updates the webhook configuration for a repository. To update more information about the webhook, including the `active` state and `events`, use "[Update a repository webhook](https://docs.github.com/rest/webhooks/repos#update-a-repository-webhook)."

OAuth app tokens and personal access tokens (classic) need the `write:repo_hook` or `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/repos/webhooks#update-a-webhook-configuration-for-a-repository)

## upload_release_asset(owner, repo, release_id, body, opts \\ [])

Upload a release asset

This endpoint makes use of a [Hypermedia relation](https://docs.github.com/rest/using-the-rest-api/getting-started-with-the-rest-api#hypermedia) to determine which URL to access. The endpoint you call to upload release assets is specific to your release. Use the `upload_url` returned in
the response of the [Create a release endpoint](https://docs.github.com/rest/releases/releases#create-a-release) to upload a release asset.

You need to use an HTTP client which supports [SNI](http://en.wikipedia.org/wiki/Server_Name_Indication) to make calls to this endpoint.

Most libraries will set the required `Content-Length` header automatically. Use the required `Content-Type` header to provide the media type of the asset. For a list of media types, see [Media Types](https://www.iana.org/assignments/media-types/media-types.xhtml). For example: 

`application/zip`

GitHub expects the asset data in its raw binary form, rather than JSON. You will send the raw binary content of the asset as the request body. Everything else about the endpoint is the same as the rest of the API. For example,
you'll still need to pass your authentication to be able to upload an asset.

When an upstream failure occurs, you will receive a `502 Bad Gateway` status. This may leave an empty asset with a state of `starter`. It can be safely deleted.

**Notes:**
*   GitHub renames asset filenames that have special characters, non-alphanumeric characters, and leading or trailing periods. The "[List release assets](https://docs.github.com/rest/releases/assets#list-release-assets)"
endpoint lists the renamed filenames. For more information and help, contact [GitHub Support](https://support.github.com/contact?tags=dotcom-rest-api).
*   To find the `release_id` query the [`GET /repos/{owner}/{repo}/releases/latest` endpoint](https://docs.github.com/rest/releases/releases#get-the-latest-release). 
*   If you upload an asset with the same filename as another uploaded asset, you'll receive an error and must delete the old file before you can re-upload the new asset.

## Options

  * `name`
  * `label`

## Resources

  * [API method documentation](https://docs.github.com/rest/releases/assets#upload-a-release-asset)