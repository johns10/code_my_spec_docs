# GitHub.Apps

Provides API endpoints related to apps

## add_repo_to_installation_for_authenticated_user(installation_id, repository_id, opts \\ [])

Add a repository to an app installation

Add a single repository to an installation. The authenticated user must have admin access to the repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/installations#add-a-repository-to-an-app-installation)

## check_token(client_id, body, opts \\ [])

Check a token

OAuth applications and GitHub applications with OAuth authorizations can use this API method for checking OAuth token validity without exceeding the normal rate limits for failed login attempts. Authentication works differently with this particular endpoint. You must use [Basic Authentication](https://docs.github.com/rest/overview/other-authentication-methods#basic-authentication) to use this endpoint, where the username is the application `client_id` and the password is its `client_secret`. Invalid tokens will return `404 NOT FOUND`.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/oauth-applications#check-a-token)

## create_from_manifest(code, opts \\ [])

Create a GitHub App from a manifest

Use this endpoint to complete the handshake necessary when implementing the [GitHub App Manifest flow](https://docs.github.com/apps/building-github-apps/creating-github-apps-from-a-manifest/). When you create a GitHub App with the manifest flow, you receive a temporary `code` used to retrieve the GitHub App's `id`, `pem` (private key), and `webhook_secret`.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/apps#create-a-github-app-from-a-manifest)

## create_installation_access_token(installation_id, body, opts \\ [])

Create an installation access token for an app

Creates an installation access token that enables a GitHub App to make authenticated API requests for the app's installation on an organization or individual account. Installation tokens expire one hour from the time you create them. Using an expired token produces a status code of `401 - Unauthorized`, and requires creating a new installation token. By default the installation token has access to all repositories that the installation can access.

Optionally, you can use the `repositories` or `repository_ids` body parameters to specify individual repositories that the installation access token can access. If you don't use `repositories` or `repository_ids` to grant access to specific repositories, the installation access token will have access to all repositories that the installation was granted access to. The installation access token cannot be granted access to repositories that the installation was not granted access to. Up to 500 repositories can be listed in this manner.

Optionally, use the `permissions` body parameter to specify the permissions that the installation access token should have. If `permissions` is not specified, the installation access token will have all of the permissions that were granted to the app. The installation access token cannot be granted permissions that the app was not granted.

When using the repository or permission parameters to reduce the access of the token, the complexity of the token is increased due to both the number of permissions in the request and the number of repositories the token will have access to. If the complexity is too large, the token will fail to be issued. If this occurs, the error message will indicate the maximum number of repositories that should be requested. For the average application requesting 8 permissions, this limit is around 5000 repositories. With fewer permissions requested, more repositories are supported.

You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/apps#create-an-installation-access-token-for-an-app)

## delete_authorization(client_id, body, opts \\ [])

Delete an app authorization

OAuth and GitHub application owners can revoke a grant for their application and a specific user. You must use [Basic Authentication](https://docs.github.com/rest/overview/other-authentication-methods#basic-authentication) when accessing this endpoint, using the OAuth application's `client_id` and `client_secret` as the username and password. You must also provide a valid OAuth `access_token` as an input parameter and the grant for the token's owner will be deleted.
Deleting an application's grant will also delete all OAuth tokens associated with the application for the user. Once deleted, the application will have no access to the user's account and will no longer be listed on [the application authorizations settings screen within GitHub](https://github.com/settings/applications#authorized).

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/oauth-applications#delete-an-app-authorization)

## delete_installation(installation_id, opts \\ [])

Delete an installation for the authenticated app

Uninstalls a GitHub App on a user, organization, or business account. If you prefer to temporarily suspend an app's access to your account's resources, then we recommend the "[Suspend an app installation](https://docs.github.com/rest/apps/apps#suspend-an-app-installation)" endpoint.

You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/apps#delete-an-installation-for-the-authenticated-app)

## delete_token(client_id, body, opts \\ [])

Delete an app token

OAuth  or GitHub application owners can revoke a single token for an OAuth application or a GitHub application with an OAuth authorization. You must use [Basic Authentication](https://docs.github.com/rest/overview/other-authentication-methods#basic-authentication) when accessing this endpoint, using the application's `client_id` and `client_secret` as the username and password.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/oauth-applications#delete-an-app-token)

## get_authenticated(opts \\ [])

Get the authenticated app

Returns the GitHub App associated with the authentication credentials used. To see how many app installations are associated with this GitHub App, see the `installations_count` in the response. For more details about your app's installations, see the "[List installations for the authenticated app](https://docs.github.com/rest/apps/apps#list-installations-for-the-authenticated-app)" endpoint.

You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/apps#get-the-authenticated-app)

## get_by_slug(app_slug, opts \\ [])

Get an app

**Note**: The `:app_slug` is just the URL-friendly name of your GitHub App. You can find this on the settings page for your GitHub App (e.g., `https://github.com/settings/apps/:app_slug`).

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/apps#get-an-app)

## get_installation(installation_id, opts \\ [])

Get an installation for the authenticated app

Enables an authenticated GitHub App to find an installation's information using the installation id.

You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/apps#get-an-installation-for-the-authenticated-app)

## get_org_installation(org, opts \\ [])

Get an organization installation for the authenticated app

Enables an authenticated GitHub App to find the organization's installation information.

You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/apps#get-an-organization-installation-for-the-authenticated-app)

## get_repo_installation(owner, repo, opts \\ [])

Get a repository installation for the authenticated app

Enables an authenticated GitHub App to find the repository's installation information. The installation's account type will be either an organization or a user account, depending which account the repository belongs to.

You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/apps#get-a-repository-installation-for-the-authenticated-app)

## get_subscription_plan_for_account(account_id, opts \\ [])

Get a subscription plan for an account

Shows whether the user or organization account actively subscribes to a plan listed by the authenticated GitHub App. When someone submits a plan change that won't be processed until the end of their billing cycle, you will also see the upcoming pending change.

GitHub Apps must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint. OAuth apps must use [basic authentication](https://docs.github.com/rest/overview/other-authentication-methods#basic-authentication) with their client ID and client secret to access this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/marketplace#get-a-subscription-plan-for-an-account)

## get_subscription_plan_for_account_stubbed(account_id, opts \\ [])

Get a subscription plan for an account (stubbed)

Shows whether the user or organization account actively subscribes to a plan listed by the authenticated GitHub App. When someone submits a plan change that won't be processed until the end of their billing cycle, you will also see the upcoming pending change.

GitHub Apps must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint. OAuth apps must use [basic authentication](https://docs.github.com/rest/overview/other-authentication-methods#basic-authentication) with their client ID and client secret to access this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/marketplace#get-a-subscription-plan-for-an-account-stubbed)

## get_user_installation(username, opts \\ [])

Get a user installation for the authenticated app

Enables an authenticated GitHub App to find the user’s installation information.

You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/apps#get-a-user-installation-for-the-authenticated-app)

## get_webhook_config_for_app(opts \\ [])

Get a webhook configuration for an app

Returns the webhook configuration for a GitHub App. For more information about configuring a webhook for your app, see "[Creating a GitHub App](https://docs.github.com/developers/apps/creating-a-github-app)."

You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/webhooks#get-a-webhook-configuration-for-an-app)

## get_webhook_delivery(delivery_id, opts \\ [])

Get a delivery for an app webhook

Returns a delivery for the webhook configured for a GitHub App.

You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/webhooks#get-a-delivery-for-an-app-webhook)

## list_accounts_for_plan(plan_id, opts \\ [])

List accounts for a plan

Returns user and organization accounts associated with the specified plan, including free plans. For per-seat pricing, you see the list of accounts that have purchased the plan, including the number of seats purchased. When someone submits a plan change that won't be processed until the end of their billing cycle, you will also see the upcoming pending change.

GitHub Apps must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint. OAuth apps must use [basic authentication](https://docs.github.com/rest/overview/other-authentication-methods#basic-authentication) with their client ID and client secret to access this endpoint.

## Options

  * `sort`: The property to sort the results by.
  * `direction`: To return the oldest accounts first, set to `asc`. Ignored without the `sort` parameter.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/marketplace#list-accounts-for-a-plan)

## list_accounts_for_plan_stubbed(plan_id, opts \\ [])

List accounts for a plan (stubbed)

Returns repository and organization accounts associated with the specified plan, including free plans. For per-seat pricing, you see the list of accounts that have purchased the plan, including the number of seats purchased. When someone submits a plan change that won't be processed until the end of their billing cycle, you will also see the upcoming pending change.

GitHub Apps must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint. OAuth apps must use [basic authentication](https://docs.github.com/rest/overview/other-authentication-methods#basic-authentication) with their client ID and client secret to access this endpoint.

## Options

  * `sort`: The property to sort the results by.
  * `direction`: To return the oldest accounts first, set to `asc`. Ignored without the `sort` parameter.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/marketplace#list-accounts-for-a-plan-stubbed)

## list_installation_repos_for_authenticated_user(installation_id, opts \\ [])

List repositories accessible to the user access token

List repositories that the authenticated user has explicit permission (`:read`, `:write`, or `:admin`) to access for an installation.

The authenticated user has explicit permission to access repositories they own, repositories where they are a collaborator, and repositories that they can access through an organization membership.

The access the user has to each repository is included in the hash under the `permissions` key.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/installations#list-repositories-accessible-to-the-user-access-token)

## list_installation_requests_for_authenticated_app(opts \\ [])

List installation requests for the authenticated app

Lists all the pending installation requests for the authenticated GitHub App.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/apps#list-installation-requests-for-the-authenticated-app)

## list_installations(opts \\ [])

List installations for the authenticated app

The permissions the installation has are included under the `permissions` key.

You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `since`: Only show results that were last updated after the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
  * `outdated`

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/apps#list-installations-for-the-authenticated-app)

## list_installations_for_authenticated_user(opts \\ [])

List app installations accessible to the user access token

Lists installations of your GitHub App that the authenticated user has explicit permission (`:read`, `:write`, or `:admin`) to access.

The authenticated user has explicit permission to access repositories they own, repositories where they are a collaborator, and repositories that they can access through an organization membership.

You can find the permissions for the installation under the `permissions` key.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/installations#list-app-installations-accessible-to-the-user-access-token)

## list_plans(opts \\ [])

List plans

Lists all plans that are part of your GitHub Marketplace listing.

GitHub Apps must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint. OAuth apps must use [basic authentication](https://docs.github.com/rest/overview/other-authentication-methods#basic-authentication) with their client ID and client secret to access this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/marketplace#list-plans)

## list_plans_stubbed(opts \\ [])

List plans (stubbed)

Lists all plans that are part of your GitHub Marketplace listing.

GitHub Apps must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint. OAuth apps must use [basic authentication](https://docs.github.com/rest/overview/other-authentication-methods#basic-authentication) with their client ID and client secret to access this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/marketplace#list-plans-stubbed)

## list_repos_accessible_to_installation(opts \\ [])

List repositories accessible to the app installation

List repositories that an app installation can access.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/installations#list-repositories-accessible-to-the-app-installation)

## list_subscriptions_for_authenticated_user(opts \\ [])

List subscriptions for the authenticated user

Lists the active subscriptions for the authenticated user.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/marketplace#list-subscriptions-for-the-authenticated-user)

## list_subscriptions_for_authenticated_user_stubbed(opts \\ [])

List subscriptions for the authenticated user (stubbed)

Lists the active subscriptions for the authenticated user.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/marketplace#list-subscriptions-for-the-authenticated-user-stubbed)

## list_webhook_deliveries(opts \\ [])

List deliveries for an app webhook

Returns a list of webhook deliveries for the webhook configured for a GitHub App.

You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `cursor`: Used for pagination: the starting delivery from which the page of deliveries is fetched. Refer to the `link` header for the next and previous page cursors.
  * `redelivery`

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/webhooks#list-deliveries-for-an-app-webhook)

## redeliver_webhook_delivery(delivery_id, opts \\ [])

Redeliver a delivery for an app webhook

Redeliver a delivery for the webhook configured for a GitHub App.

You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/webhooks#redeliver-a-delivery-for-an-app-webhook)

## remove_repo_from_installation_for_authenticated_user(installation_id, repository_id, opts \\ [])

Remove a repository from an app installation

Remove a single repository from an installation. The authenticated user must have admin access to the repository. The installation must have the `repository_selection` of `selected`.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/installations#remove-a-repository-from-an-app-installation)

## reset_token(client_id, body, opts \\ [])

Reset a token

OAuth applications and GitHub applications with OAuth authorizations can use this API method to reset a valid OAuth token without end-user involvement. Applications must save the "token" property in the response because changes take effect immediately. You must use [Basic Authentication](https://docs.github.com/rest/overview/other-authentication-methods#basic-authentication) when accessing this endpoint, using the application's `client_id` and `client_secret` as the username and password. Invalid tokens will return `404 NOT FOUND`.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/oauth-applications#reset-a-token)

## revoke_installation_access_token(opts \\ [])

Revoke an installation access token

Revokes the installation token you're using to authenticate as an installation and access this endpoint.

Once an installation token is revoked, the token is invalidated and cannot be used. Other endpoints that require the revoked installation token must have a new installation token to work. You can create a new token using the "[Create an installation access token for an app](https://docs.github.com/rest/apps/apps#create-an-installation-access-token-for-an-app)" endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/installations#revoke-an-installation-access-token)

## scope_token(client_id, body, opts \\ [])

Create a scoped access token

Use a non-scoped user access token to create a repository-scoped and/or permission-scoped user access token. You can specify
which repositories the token can access and which permissions are granted to the
token.

Invalid tokens will return `404 NOT FOUND`.

You must use [Basic Authentication](https://docs.github.com/rest/overview/other-authentication-methods#basic-authentication)
when accessing this endpoint, using the `client_id` and `client_secret` of the GitHub App
as the username and password.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/apps#create-a-scoped-access-token)

## suspend_installation(installation_id, opts \\ [])

Suspend an app installation

Suspends a GitHub App on a user, organization, or business account, which blocks the app from accessing the account's resources. When a GitHub App is suspended, the app's access to the GitHub API or webhook events is blocked for that account.

You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/apps#suspend-an-app-installation)

## unsuspend_installation(installation_id, opts \\ [])

Unsuspend an app installation

Removes a GitHub App installation suspension.

You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/apps#unsuspend-an-app-installation)

## update_webhook_config_for_app(body, opts \\ [])

Update a webhook configuration for an app

Updates the webhook configuration for a GitHub App. For more information about configuring a webhook for your app, see "[Creating a GitHub App](https://docs.github.com/developers/apps/creating-a-github-app)."

You must use a [JWT](https://docs.github.com/apps/building-github-apps/authenticating-with-github-apps/#authenticating-as-a-github-app) to access this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/apps/webhooks#update-a-webhook-configuration-for-an-app)