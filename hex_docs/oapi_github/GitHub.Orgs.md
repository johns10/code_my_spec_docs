# GitHub.Orgs

Provides API endpoints related to orgs

## add_security_manager_team(org, team_slug, opts \\ [])

Add a security manager team

Adds a team as a security manager for an organization. For more information, see "[Managing security for an organization](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/managing-security-managers-in-your-organization) for an organization."

The authenticated user must be an administrator for the organization to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `write:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/security-managers#add-a-security-manager-team)

## assign_team_to_org_role(org, team_slug, role_id, opts \\ [])

Assign an organization role to a team

Assigns an organization role to a team in an organization. For more information on organization roles, see "[Managing people's access to your organization with roles](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/about-custom-organization-roles)."

The authenticated user must be an administrator for the organization to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/organization-roles#assign-an-organization-role-to-a-team)

## assign_user_to_org_role(org, username, role_id, opts \\ [])

Assign an organization role to a user

Assigns an organization role to a member of an organization. For more information on organization roles, see "[Managing people's access to your organization with roles](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/about-custom-organization-roles)."

The authenticated user must be an administrator for the organization to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/organization-roles#assign-an-organization-role-to-a-user)

## block_user(org, username, opts \\ [])

Block a user from an organization

Blocks the given user on behalf of the specified organization and returns a 204. If the organization cannot block the given user a 422 is returned.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/blocking#block-a-user-from-an-organization)

## cancel_invitation(org, invitation_id, opts \\ [])

Cancel an organization invitation

Cancel an organization invitation. In order to cancel an organization invitation, the authenticated user must be an organization owner.

This endpoint triggers [notifications](https://docs.github.com/github/managing-subscriptions-and-notifications-on-github/about-notifications).

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/members#cancel-an-organization-invitation)

## check_blocked_user(org, username, opts \\ [])

Check if a user is blocked by an organization

Returns a 204 if the given user is blocked by the given organization. Returns a 404 if the organization is not blocking the user, or if the user account has been identified as spam by GitHub.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/blocking#check-if-a-user-is-blocked-by-an-organization)

## check_membership_for_user(org, username, opts \\ [])

Check organization membership for a user

Check if a user is, publicly or privately, a member of the organization.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/members#check-organization-membership-for-a-user)

## check_public_membership_for_user(org, username, opts \\ [])

Check public organization membership for a user

Check if the provided user is a public member of the organization.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/members#check-public-organization-membership-for-a-user)

## convert_member_to_outside_collaborator(org, username, body, opts \\ [])

Convert an organization member to outside collaborator

When an organization member is converted to an outside collaborator, they'll only have access to the repositories that their current team membership allows. The user will no longer be a member of the organization. For more information, see "[Converting an organization member to an outside collaborator](https://docs.github.com/articles/converting-an-organization-member-to-an-outside-collaborator/)". Converting an organization member to an outside collaborator may be restricted by enterprise administrators. For more information, see "[Enforcing repository management policies in your enterprise](https://docs.github.com/admin/policies/enforcing-policies-for-your-enterprise/enforcing-repository-management-policies-in-your-enterprise#enforcing-a-policy-for-inviting-outside-collaborators-to-repositories)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/outside-collaborators#convert-an-organization-member-to-outside-collaborator)

## create_custom_organization_role(org, body, opts \\ [])

Create a custom organization role

Creates a custom organization role that can be assigned to users and teams, granting them specific permissions over the organization. For more information on custom organization roles, see "[Managing people's access to your organization with roles](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/about-custom-organization-roles)."

To use this endpoint, the authenticated user must be one of:

- An administrator for the organization.
- A user, or a user on a team, with the fine-grained permissions of `write_organization_custom_org_role` in the organization.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/organization-roles#create-a-custom-organization-role)

## create_invitation(org, body, opts \\ [])

Create an organization invitation

Invite people to an organization by using their GitHub user ID or their email address. In order to create invitations in an organization, the authenticated user must be an organization owner.

This endpoint triggers [notifications](https://docs.github.com/github/managing-subscriptions-and-notifications-on-github/about-notifications). Creating content too quickly using this endpoint may result in secondary rate limiting. For more information, see "[Rate limits for the API](https://docs.github.com/rest/overview/rate-limits-for-the-rest-api#about-secondary-rate-limits)"
and "[Best practices for using the REST API](https://docs.github.com/rest/guides/best-practices-for-using-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/members#create-an-organization-invitation)

## create_or_update_custom_properties(org, body, opts \\ [])

Create or update custom properties for an organization

Creates new or updates existing custom properties defined for an organization in a batch.

To use this endpoint, the authenticated user must be one of:
  - An administrator for the organization.
  - A user, or a user on a team, with the fine-grained permission of `custom_properties_org_definitions_manager` in the organization.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/custom-properties#create-or-update-custom-properties-for-an-organization)

## create_or_update_custom_properties_values_for_repos(org, body, opts \\ [])

Create or update custom property values for organization repositories

Create new or update existing custom property values for repositories in a batch that belong to an organization.
Each target repository will have its custom property values updated to match the values provided in the request.

A maximum of 30 repositories can be updated in a single request.

Using a value of `null` for a custom property will remove or 'unset' the property value from the repository.

To use this endpoint, the authenticated user must be one of:
  - An administrator for the organization.
  - A user, or a user on a team, with the fine-grained permission of `custom_properties_org_values_editor` in the organization.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/custom-properties#create-or-update-custom-property-values-for-organization-repositories)

## create_or_update_custom_property(org, custom_property_name, body, opts \\ [])

Create or update a custom property for an organization

Creates a new or updates an existing custom property that is defined for an organization.

To use this endpoint, the authenticated user must be one of:
- An administrator for the organization.
- A user, or a user on a team, with the fine-grained permission of `custom_properties_org_definitions_manager` in the organization.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/custom-properties#create-or-update-a-custom-property-for-an-organization)

## create_webhook(org, body, opts \\ [])

Create an organization webhook

Create a hook that posts payloads in JSON format.

You must be an organization owner to use this endpoint.

OAuth app tokens and personal access tokens (classic) need `admin:org_hook` scope. OAuth apps cannot list, view, or
edit webhooks that they did not create and users cannot list, view, or edit webhooks that were created by OAuth apps.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/webhooks#create-an-organization-webhook)

## delete(org, opts \\ [])

Delete an organization

Deletes an organization and all its repositories.

The organization login will be unavailable for 90 days after deletion.

Please review the Terms of Service regarding account deletion before using this endpoint:

https://docs.github.com/site-policy/github-terms/github-terms-of-service

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/orgs#delete-an-organization)

## delete_custom_organization_role(org, role_id, opts \\ [])

Delete a custom organization role.

Deletes a custom organization role. For more information on custom organization roles, see "[Managing people's access to your organization with roles](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/about-custom-organization-roles)."

To use this endpoint, the authenticated user must be one of:

- An administrator for the organization.
- A user, or a user on a team, with the fine-grained permissions of `write_organization_custom_org_role` in the organization.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/organization-roles#delete-a-custom-organization-role)

## delete_webhook(org, hook_id, opts \\ [])

Delete an organization webhook

You must be an organization owner to use this endpoint.

OAuth app tokens and personal access tokens (classic) need `admin:org_hook` scope. OAuth apps cannot list, view, or edit
webhooks that they did not create and users cannot list, view, or edit webhooks that were created by OAuth apps.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/webhooks#delete-an-organization-webhook)

## enable_or_disable_security_product_on_all_org_repos(org, security_product, enablement, body, opts \\ [])

Enable or disable a security feature for an organization

Enables or disables the specified security feature for all eligible repositories in an organization. For more information, see "[Managing security managers in your organization](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/managing-security-managers-in-your-organization)."

The authenticated user must be an organization owner or be member of a team with the security manager role to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `write:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/orgs#enable-or-disable-a-security-feature-for-an-organization)

## get(org, opts \\ [])

Get an organization

Gets information about an organization.

When the value of `two_factor_requirement_enabled` is `true`, the organization requires all members, billing managers, and outside collaborators to enable [two-factor authentication](https://docs.github.com/articles/securing-your-account-with-two-factor-authentication-2fa/).

To see the full details about an organization, the authenticated user must be an organization owner.

The values returned by this endpoint are set by the "Update an organization" endpoint. If your organization set a default security configuration (beta), the following values retrieved from the "Update an organization" endpoint have been overwritten by that configuration:

- advanced_security_enabled_for_new_repositories
- dependabot_alerts_enabled_for_new_repositories
- dependabot_security_updates_enabled_for_new_repositories
- dependency_graph_enabled_for_new_repositories
- secret_scanning_enabled_for_new_repositories
- secret_scanning_push_protection_enabled_for_new_repositories

For more information on security configurations, see "[Enabling security features at scale](https://docs.github.com/code-security/securing-your-organization/introduction-to-securing-your-organization-at-scale/about-enabling-security-features-at-scale)."

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to see the full details about an organization.

To see information about an organization's GitHub plan, GitHub Apps need the `Organization plan` permission.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/orgs#get-an-organization)

## get_all_custom_properties(org, opts \\ [])

Get all custom properties for an organization

Gets all custom properties defined for an organization.
Organization members can read these properties.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/custom-properties#get-all-custom-properties-for-an-organization)

## get_custom_property(org, custom_property_name, opts \\ [])

Get a custom property for an organization

Gets a custom property that is defined for an organization.
Organization members can read these properties.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/custom-properties#get-a-custom-property-for-an-organization)

## get_membership_for_authenticated_user(org, opts \\ [])

Get an organization membership for the authenticated user

If the authenticated user is an active or pending member of the organization, this endpoint will return the user's membership. If the authenticated user is not affiliated with the organization, a `404` is returned. This endpoint will return a `403` if the request is made by a GitHub App that is blocked by the organization.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/members#get-an-organization-membership-for-the-authenticated-user)

## get_membership_for_user(org, username, opts \\ [])

Get organization membership for a user

In order to get a user's membership with an organization, the authenticated user must be an organization member. The `state` parameter in the response can be used to identify the user's membership status.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/members#get-organization-membership-for-a-user)

## get_org_role(org, role_id, opts \\ [])

Get an organization role

Gets an organization role that is available to this organization. For more information on organization roles, see "[Managing people's access to your organization with roles](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/about-custom-organization-roles)."

To use this endpoint, the authenticated user must be one of:

- An administrator for the organization.
- A user, or a user on a team, with the fine-grained permissions of `read_organization_custom_org_role` in the organization.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/organization-roles#get-an-organization-role)

## get_webhook(org, hook_id, opts \\ [])

Get an organization webhook

Returns a webhook configured in an organization. To get only the webhook
`config` properties, see "[Get a webhook configuration for an organization](https://docs.github.com/rest/orgs/webhooks#get-a-webhook-configuration-for-an-organization).

You must be an organization owner to use this endpoint.

OAuth app tokens and personal access tokens (classic) need `admin:org_hook` scope. OAuth apps cannot list, view, or edit
webhooks that they did not create and users cannot list, view, or edit webhooks that were created by OAuth apps.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/webhooks#get-an-organization-webhook)

## get_webhook_config_for_org(org, hook_id, opts \\ [])

Get a webhook configuration for an organization

Returns the webhook configuration for an organization. To get more information about the webhook, including the `active` state and `events`, use "[Get an organization webhook ](https://docs.github.com/rest/orgs/webhooks#get-an-organization-webhook)."

You must be an organization owner to use this endpoint.

OAuth app tokens and personal access tokens (classic) need `admin:org_hook` scope. OAuth apps cannot list, view, or edit
webhooks that they did not create and users cannot list, view, or edit webhooks that were created by OAuth apps.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/webhooks#get-a-webhook-configuration-for-an-organization)

## get_webhook_delivery(org, hook_id, delivery_id, opts \\ [])

Get a webhook delivery for an organization webhook

Returns a delivery for a webhook configured in an organization.

You must be an organization owner to use this endpoint.

OAuth app tokens and personal access tokens (classic) need `admin:org_hook` scope. OAuth apps cannot list, view, or edit
webhooks that they did not create and users cannot list, view, or edit webhooks that were created by OAuth apps.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/webhooks#get-a-webhook-delivery-for-an-organization-webhook)

## list(opts \\ [])

List organizations

Lists all organizations, in the order that they were created.

**Note:** Pagination is powered exclusively by the `since` parameter. Use the [Link header](https://docs.github.com/rest/guides/using-pagination-in-the-rest-api#using-link-headers) to get the URL for the next page of organizations.

## Options

  * `since`: An organization ID. Only return organizations with an ID greater than this ID.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/orgs#list-organizations)

## list_app_installations(org, opts \\ [])

List app installations for an organization

Lists all GitHub Apps in an organization. The installation count includes
all GitHub Apps installed on repositories in the organization.

The authenticated user must be an organization owner to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `admin:read` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/orgs#list-app-installations-for-an-organization)

## list_blocked_users(org, opts \\ [])

List users blocked by an organization

List the users blocked by an organization.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/blocking#list-users-blocked-by-an-organization)

## list_custom_properties_values_for_repos(org, opts \\ [])

List custom property values for organization repositories

Lists organization repositories with all of their custom property values.
Organization members can read these properties.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `repository_query`: Finds repositories in the organization with a query containing one or more search keywords and qualifiers. Qualifiers allow you to limit your search to specific areas of GitHub. The REST API supports the same qualifiers as the web interface for GitHub. To learn more about the format of the query, see [Constructing a search query](https://docs.github.com/rest/search/search#constructing-a-search-query). See "[Searching for repositories](https://docs.github.com/articles/searching-for-repositories/)" for a detailed list of qualifiers.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/custom-properties#list-custom-property-values-for-organization-repositories)

## list_failed_invitations(org, opts \\ [])

List failed organization invitations

The return hash contains `failed_at` and `failed_reason` fields which represent the time at which the invitation failed and the reason for the failure.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/members#list-failed-organization-invitations)

## list_for_authenticated_user(opts \\ [])

List organizations for the authenticated user

List organizations for the authenticated user.

For OAuth app tokens and personal access tokens (classic), this endpoint only lists organizations that your authorization allows you to operate on in some way (e.g., you can list teams with `read:org` scope, you can publicize your organization membership with `user` scope, etc.). Therefore, this API requires at least `user` or `read:org` scope for OAuth app tokens and personal access tokens (classic). Requests with insufficient scope will receive a `403 Forbidden` response.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/orgs#list-organizations-for-the-authenticated-user)

## list_for_user(username, opts \\ [])

List organizations for a user

List [public organization memberships](https://docs.github.com/articles/publicizing-or-concealing-organization-membership) for the specified user.

This method only lists _public_ memberships, regardless of authentication. If you need to fetch all of the organization memberships (public and private) for the authenticated user, use the [List organizations for the authenticated user](https://docs.github.com/rest/orgs/orgs#list-organizations-for-the-authenticated-user) API instead.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/orgs#list-organizations-for-a-user)

## list_invitation_teams(org, invitation_id, opts \\ [])

List organization invitation teams

List all teams associated with an invitation. In order to see invitations in an organization, the authenticated user must be an organization owner.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/members#list-organization-invitation-teams)

## list_members(org, opts \\ [])

List organization members

List all users who are members of an organization. If the authenticated user is also a member of this organization then both concealed and public members will be returned.

## Options

  * `filter`: Filter members returned in the list. `2fa_disabled` means that only members without [two-factor authentication](https://github.com/blog/1614-two-factor-authentication) enabled will be returned. This options is only available for organization owners.
  * `role`: Filter members returned by their role.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/members#list-organization-members)

## list_memberships_for_authenticated_user(opts \\ [])

List organization memberships for the authenticated user

Lists all of the authenticated user's organization memberships.

## Options

  * `state`: Indicates the state of the memberships to return. If not specified, the API returns both active and pending memberships.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/members#list-organization-memberships-for-the-authenticated-user)

## list_org_role_teams(org, role_id, opts \\ [])

List teams that are assigned to an organization role

Lists the teams that are assigned to an organization role. For more information on organization roles, see "[Managing people's access to your organization with roles](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/about-custom-organization-roles)."

To use this endpoint, you must be an administrator for the organization.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/organization-roles#list-teams-that-are-assigned-to-an-organization-role)

## list_org_role_users(org, role_id, opts \\ [])

List users that are assigned to an organization role

Lists organization members that are assigned to an organization role. For more information on organization roles, see "[Managing people's access to your organization with roles](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/about-custom-organization-roles)."

To use this endpoint, you must be an administrator for the organization.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/organization-roles#list-users-that-are-assigned-to-an-organization-role)

## list_org_roles(org, opts \\ [])

Get all organization roles for an organization

Lists the organization roles available in this organization. For more information on organization roles, see "[Managing people's access to your organization with roles](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/about-custom-organization-roles)."

To use this endpoint, the authenticated user must be one of:

- An administrator for the organization.
- A user, or a user on a team, with the fine-grained permissions of `read_organization_custom_org_role` in the organization.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/organization-roles#get-all-organization-roles-for-an-organization)

## list_organization_fine_grained_permissions(org, opts \\ [])

List organization fine-grained permissions for an organization

Lists the fine-grained permissions that can be used in custom organization roles for an organization. For more information, see "[Managing people's access to your organization with roles](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/about-custom-organization-roles)."

To list the fine-grained permissions that can be used in custom repository roles for an organization, see "[List repository fine-grained permissions for an organization](https://docs.github.com/rest/orgs/organization-roles#list-repository-fine-grained-permissions-for-an-organization)."

To use this endpoint, the authenticated user must be one of:

- An administrator for the organization.
- A user, or a user on a team, with the fine-grained permissions of `read_organization_custom_org_role` in the organization.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/organization-roles#list-organization-fine-grained-permissions-for-an-organization)

## list_outside_collaborators(org, opts \\ [])

List outside collaborators for an organization

List all users who are outside collaborators of an organization.

## Options

  * `filter`: Filter the list of outside collaborators. `2fa_disabled` means that only outside collaborators without [two-factor authentication](https://github.com/blog/1614-two-factor-authentication) enabled will be returned.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/outside-collaborators#list-outside-collaborators-for-an-organization)

## list_pat_grant_repositories(org, pat_id, opts \\ [])

List repositories a fine-grained personal access token has access to

Lists the repositories a fine-grained personal access token has access to.

Only GitHub Apps can use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/personal-access-tokens#list-repositories-a-fine-grained-personal-access-token-has-access-to)

## list_pat_grant_request_repositories(org, pat_request_id, opts \\ [])

List repositories requested to be accessed by a fine-grained personal access token

Lists the repositories a fine-grained personal access token request is requesting access to.

Only GitHub Apps can use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/personal-access-tokens#list-repositories-requested-to-be-accessed-by-a-fine-grained-personal-access-token)

## list_pat_grant_requests(org, opts \\ [])

List requests to access organization resources with fine-grained personal access tokens

Lists requests from organization members to access organization resources with a fine-grained personal access token.

Only GitHub Apps can use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `sort`: The property by which to sort the results.
  * `direction`: The direction to sort the results by.
  * `owner`: A list of owner usernames to use to filter the results.
  * `repository`: The name of the repository to use to filter the results.
  * `permission`: The permission to use to filter the results.
  * `last_used_before`: Only show fine-grained personal access tokens used before the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
  * `last_used_after`: Only show fine-grained personal access tokens used after the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/personal-access-tokens#list-requests-to-access-organization-resources-with-fine-grained-personal-access-tokens)

## list_pat_grants(org, opts \\ [])

List fine-grained personal access tokens with access to organization resources

Lists approved fine-grained personal access tokens owned by organization members that can access organization resources.

Only GitHub Apps can use this endpoint.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `sort`: The property by which to sort the results.
  * `direction`: The direction to sort the results by.
  * `owner`: A list of owner usernames to use to filter the results.
  * `repository`: The name of the repository to use to filter the results.
  * `permission`: The permission to use to filter the results.
  * `last_used_before`: Only show fine-grained personal access tokens used before the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.
  * `last_used_after`: Only show fine-grained personal access tokens used after the given time. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format: `YYYY-MM-DDTHH:MM:SSZ`.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/personal-access-tokens#list-fine-grained-personal-access-tokens-with-access-to-organization-resources)

## list_pending_invitations(org, opts \\ [])

List pending organization invitations

The return hash contains a `role` field which refers to the Organization Invitation role and will be one of the following values: `direct_member`, `admin`, `billing_manager`, or `hiring_manager`. If the invitee is not a GitHub member, the `login` field in the return hash will be `null`.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `role`: Filter invitations by their member role.
  * `invitation_source`: Filter invitations by their invitation source.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/members#list-pending-organization-invitations)

## list_public_members(org, opts \\ [])

List public organization members

Members of an organization can choose to have their membership publicized or not.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/members#list-public-organization-members)

## list_security_manager_teams(org, opts \\ [])

List security manager teams

Lists teams that are security managers for an organization. For more information, see "[Managing security managers in your organization](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/managing-security-managers-in-your-organization)."

The authenticated user must be an administrator or security manager for the organization to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `read:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/security-managers#list-security-manager-teams)

## list_webhook_deliveries(org, hook_id, opts \\ [])

List deliveries for an organization webhook

Returns a list of webhook deliveries for a webhook configured in an organization.

You must be an organization owner to use this endpoint.

OAuth app tokens and personal access tokens (classic) need `admin:org_hook` scope. OAuth apps cannot list, view, or edit
webhooks that they did not create and users cannot list, view, or edit webhooks that were created by OAuth apps.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `cursor`: Used for pagination: the starting delivery from which the page of deliveries is fetched. Refer to the `link` header for the next and previous page cursors.
  * `redelivery`

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/webhooks#list-deliveries-for-an-organization-webhook)

## list_webhooks(org, opts \\ [])

List organization webhooks

You must be an organization owner to use this endpoint.

OAuth app tokens and personal access tokens (classic) need `admin:org_hook` scope. OAuth apps cannot list, view, or edit
webhooks that they did not create and users cannot list, view, or edit webhooks that were created by OAuth apps.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/webhooks#list-organization-webhooks)

## patch_custom_organization_role(org, role_id, body, opts \\ [])

Update a custom organization role

Updates an existing custom organization role. Permission changes will apply to all assignees. For more information on custom organization roles, see "[Managing people's access to your organization with roles](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/about-custom-organization-roles)."


To use this endpoint, the authenticated user must be one of:

- An administrator for the organization.
- A user, or a user on a team, with the fine-grained permissions of `write_organization_custom_org_role` in the organization.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/organization-roles#update-a-custom-organization-role)

## ping_webhook(org, hook_id, opts \\ [])

Ping an organization webhook

This will trigger a [ping event](https://docs.github.com/webhooks/#ping-event)
to be sent to the hook.

You must be an organization owner to use this endpoint.

OAuth app tokens and personal access tokens (classic) need `admin:org_hook` scope. OAuth apps cannot list, view, or edit
webhooks that they did not create and users cannot list, view, or edit webhooks that were created by OAuth apps.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/webhooks#ping-an-organization-webhook)

## redeliver_webhook_delivery(org, hook_id, delivery_id, opts \\ [])

Redeliver a delivery for an organization webhook

Redeliver a delivery for a webhook configured in an organization.

You must be an organization owner to use this endpoint.

OAuth app tokens and personal access tokens (classic) need `admin:org_hook` scope. OAuth apps cannot list, view, or edit
webhooks that they did not create and users cannot list, view, or edit webhooks that were created by OAuth apps.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/webhooks#redeliver-a-delivery-for-an-organization-webhook)

## remove_custom_property(org, custom_property_name, opts \\ [])

Remove a custom property for an organization

Removes a custom property that is defined for an organization.

To use this endpoint, the authenticated user must be one of:
  - An administrator for the organization.
  - A user, or a user on a team, with the fine-grained permission of `custom_properties_org_definitions_manager` in the organization.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/custom-properties#remove-a-custom-property-for-an-organization)

## remove_member(org, username, opts \\ [])

Remove an organization member

Removing a user from this list will remove them from all teams and they will no longer have any access to the organization's repositories.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/members#remove-an-organization-member)

## remove_membership_for_user(org, username, opts \\ [])

Remove organization membership for a user

In order to remove a user's membership with an organization, the authenticated user must be an organization owner.

If the specified user is an active member of the organization, this will remove them from the organization. If the specified user has been invited to the organization, this will cancel their invitation. The specified user will receive an email notification in both cases.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/members#remove-organization-membership-for-a-user)

## remove_outside_collaborator(org, username, opts \\ [])

Remove outside collaborator from an organization

Removing a user from this list will remove them from all the organization's repositories.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/outside-collaborators#remove-outside-collaborator-from-an-organization)

## remove_public_membership_for_authenticated_user(org, username, opts \\ [])

Remove public organization membership for the authenticated user

Removes the public membership for the authenticated user from the specified organization, unless public visibility is enforced by default.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/members#remove-public-organization-membership-for-the-authenticated-user)

## remove_security_manager_team(org, team_slug, opts \\ [])

Remove a security manager team

Removes the security manager role from a team for an organization. For more information, see "[Managing security managers in your organization](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/managing-security-managers-in-your-organization) team from an organization."

The authenticated user must be an administrator for the organization to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/security-managers#remove-a-security-manager-team)

## review_pat_grant_request(org, pat_request_id, body, opts \\ [])

Review a request to access organization resources with a fine-grained personal access token

Approves or denies a pending request to access organization resources via a fine-grained personal access token.

Only GitHub Apps can use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/personal-access-tokens#review-a-request-to-access-organization-resources-with-a-fine-grained-personal-access-token)

## review_pat_grant_requests_in_bulk(org, body, opts \\ [])

Review requests to access organization resources with fine-grained personal access tokens

Approves or denies multiple pending requests to access organization resources via a fine-grained personal access token.

Only GitHub Apps can use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/personal-access-tokens#review-requests-to-access-organization-resources-with-fine-grained-personal-access-tokens)

## revoke_all_org_roles_team(org, team_slug, opts \\ [])

Remove all organization roles for a team

Removes all assigned organization roles from a team. For more information on organization roles, see "[Managing people's access to your organization with roles](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/about-custom-organization-roles)."

The authenticated user must be an administrator for the organization to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/organization-roles#remove-all-organization-roles-for-a-team)

## revoke_all_org_roles_user(org, username, opts \\ [])

Remove all organization roles for a user

Revokes all assigned organization roles from a user. For more information on organization roles, see "[Managing people's access to your organization with roles](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/about-custom-organization-roles)."

The authenticated user must be an administrator for the organization to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/organization-roles#remove-all-organization-roles-for-a-user)

## revoke_org_role_team(org, team_slug, role_id, opts \\ [])

Remove an organization role from a team

Removes an organization role from a team. For more information on organization roles, see "[Managing people's access to your organization with roles](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/about-custom-organization-roles)."

The authenticated user must be an administrator for the organization to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/organization-roles#remove-an-organization-role-from-a-team)

## revoke_org_role_user(org, username, role_id, opts \\ [])

Remove an organization role from a user

Remove an organization role from a user. For more information on organization roles, see "[Managing people's access to your organization with roles](https://docs.github.com/organizations/managing-peoples-access-to-your-organization-with-roles/about-custom-organization-roles)."

The authenticated user must be an administrator for the organization to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `admin:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/organization-roles#remove-an-organization-role-from-a-user)

## set_membership_for_user(org, username, body, opts \\ [])

Set organization membership for a user

Only authenticated organization owners can add a member to the organization or update the member's role.

*   If the authenticated user is _adding_ a member to the organization, the invited user will receive an email inviting them to the organization. The user's [membership status](https://docs.github.com/rest/orgs/members#get-organization-membership-for-a-user) will be `pending` until they accept the invitation.
    
*   Authenticated users can _update_ a user's membership by passing the `role` parameter. If the authenticated user changes a member's role to `admin`, the affected user will receive an email notifying them that they've been made an organization owner. If the authenticated user changes an owner's role to `member`, no email will be sent.

**Rate limits**

To prevent abuse, the authenticated user is limited to 50 organization invitations per 24 hour period. If the organization is more than one month old or on a paid plan, the limit is 500 invitations per 24 hour period.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/members#set-organization-membership-for-a-user)

## set_public_membership_for_authenticated_user(org, username, opts \\ [])

Set public organization membership for the authenticated user

The user can publicize their own membership. (A user cannot publicize the membership for another user.)

Note that you'll need to set `Content-Length` to zero when calling out to this endpoint. For more information, see "[HTTP method](https://docs.github.com/rest/guides/getting-started-with-the-rest-api#http-method)."

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/members#set-public-organization-membership-for-the-authenticated-user)

## unblock_user(org, username, opts \\ [])

Unblock a user from an organization

Unblocks the given user on behalf of the specified organization.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/blocking#unblock-a-user-from-an-organization)

## update(org, body, opts \\ [])

Update an organization

**Parameter Deprecation Notice:** GitHub will replace and discontinue `members_allowed_repository_creation_type` in favor of more granular permissions. The new input parameters are `members_can_create_public_repositories`, `members_can_create_private_repositories` for all organizations and `members_can_create_internal_repositories` for organizations associated with an enterprise account using GitHub Enterprise Cloud or GitHub Enterprise Server 2.20+. For more information, see the [blog post](https://developer.github.com/changes/2019-12-03-internal-visibility-changes).

Updates the organization's profile and member privileges.

With security configurations (beta), your organization can choose a default security configuration which will automatically apply a set of security enablement settings to new repositories in your organization based on their visibility. For targeted repositories, the following attributes will be overridden by the default security configuration:

- advanced_security_enabled_for_new_repositories
- dependabot_alerts_enabled_for_new_repositories
- dependabot_security_updates_enabled_for_new_repositories
- dependency_graph_enabled_for_new_repositories
- secret_scanning_enabled_for_new_repositories
- secret_scanning_push_protection_enabled_for_new_repositories

For more information on setting a default security configuration, see "[Enabling security features at scale](https://docs.github.com/code-security/securing-your-organization/introduction-to-securing-your-organization-at-scale/about-enabling-security-features-at-scale)."

The authenticated user must be an organization owner to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `admin:org` or `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/orgs#update-an-organization)

## update_membership_for_authenticated_user(org, body, opts \\ [])

Update an organization membership for the authenticated user

Converts the authenticated user to an active member of the organization, if that user has a pending invitation from the organization.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/members#update-an-organization-membership-for-the-authenticated-user)

## update_pat_access(org, pat_id, body, opts \\ [])

Update the access a fine-grained personal access token has to organization resources

Updates the access an organization member has to organization resources via a fine-grained personal access token. Limited to revoking the token's existing access. Limited to revoking a token's existing access.

Only GitHub Apps can use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/personal-access-tokens#update-the-access-a-fine-grained-personal-access-token-has-to-organization-resources)

## update_pat_accesses(org, body, opts \\ [])

Update the access to organization resources via fine-grained personal access tokens

Updates the access organization members have to organization resources via fine-grained personal access tokens. Limited to revoking a token's existing access.

Only GitHub Apps can use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/personal-access-tokens#update-the-access-to-organization-resources-via-fine-grained-personal-access-tokens)

## update_webhook(org, hook_id, body, opts \\ [])

Update an organization webhook

Updates a webhook configured in an organization. When you update a webhook,
the `secret` will be overwritten. If you previously had a `secret` set, you must
provide the same `secret` or set a new `secret` or the secret will be removed. If
you are only updating individual webhook `config` properties, use "[Update a webhook
configuration for an organization](https://docs.github.com/rest/orgs/webhooks#update-a-webhook-configuration-for-an-organization)".

You must be an organization owner to use this endpoint.

OAuth app tokens and personal access tokens (classic) need `admin:org_hook` scope. OAuth apps cannot list, view, or edit
webhooks that they did not create and users cannot list, view, or edit webhooks that were created by OAuth apps.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/webhooks#update-an-organization-webhook)

## update_webhook_config_for_org(org, hook_id, body, opts \\ [])

Update a webhook configuration for an organization

Updates the webhook configuration for an organization. To update more information about the webhook, including the `active` state and `events`, use "[Update an organization webhook ](https://docs.github.com/rest/orgs/webhooks#update-an-organization-webhook)."

You must be an organization owner to use this endpoint.

OAuth app tokens and personal access tokens (classic) need `admin:org_hook` scope. OAuth apps cannot list, view, or edit
webhooks that they did not create and users cannot list, view, or edit webhooks that were created by OAuth apps.

## Resources

  * [API method documentation](https://docs.github.com/rest/orgs/webhooks#update-a-webhook-configuration-for-an-organization)