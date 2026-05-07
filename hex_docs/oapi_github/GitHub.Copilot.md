# GitHub.Copilot

Provides API endpoints related to copilot

## add_copilot_seats_for_teams(org, body, opts \\ [])

Add teams to the Copilot subscription for an organization

**Note**: This endpoint is in beta and is subject to change.

Purchases a GitHub Copilot seat for all users within each specified team.
The organization will be billed accordingly. For more information about Copilot pricing, see "[Pricing for GitHub Copilot](https://docs.github.com/billing/managing-billing-for-github-copilot/about-billing-for-github-copilot#about-billing-for-github-copilot)".

Only organization owners can configure GitHub Copilot in their organization.

In order for an admin to use this endpoint, the organization must have a Copilot Business or Enterprise subscription and a configured suggestion matching policy.
For more information about setting up a Copilot subscription, see "[Setting up a Copilot subscription for your organization](https://docs.github.com/billing/managing-billing-for-github-copilot/managing-your-github-copilot-subscription-for-your-organization-or-enterprise)".
For more information about setting a suggestion matching policy, see "[Configuring suggestion matching policies for GitHub Copilot in your organization](https://docs.github.com/copilot/managing-copilot/managing-policies-for-github-copilot-in-your-organization#configuring-suggestion-matching-policies-for-github-copilot-in-your-organization)".

OAuth app tokens and personal access tokens (classic) need the `manage_billing:copilot` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/copilot/copilot-user-management#add-teams-to-the-copilot-subscription-for-an-organization)

## add_copilot_seats_for_users(org, body, opts \\ [])

Add users to the Copilot subscription for an organization

**Note**: This endpoint is in beta and is subject to change.

Purchases a GitHub Copilot seat for each user specified.
The organization will be billed accordingly. For more information about Copilot pricing, see "[Pricing for GitHub Copilot](https://docs.github.com/billing/managing-billing-for-github-copilot/about-billing-for-github-copilot#about-billing-for-github-copilot)".

Only organization owners can configure GitHub Copilot in their organization.

In order for an admin to use this endpoint, the organization must have a Copilot Business or Enterprise subscription and a configured suggestion matching policy.
For more information about setting up a Copilot subscription, see "[Setting up a Copilot subscription for your organization](https://docs.github.com/billing/managing-billing-for-github-copilot/managing-your-github-copilot-subscription-for-your-organization-or-enterprise)".
For more information about setting a suggestion matching policy, see "[Configuring suggestion matching policies for GitHub Copilot in your organization](https://docs.github.com/copilot/managing-copilot/managing-policies-for-github-copilot-in-your-organization#configuring-suggestion-matching-policies-for-github-copilot-in-your-organization)".

OAuth app tokens and personal access tokens (classic) need the `manage_billing:copilot` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/copilot/copilot-user-management#add-users-to-the-copilot-subscription-for-an-organization)

## cancel_copilot_seat_assignment_for_teams(org, body, opts \\ [])

Remove teams from the Copilot subscription for an organization

**Note**: This endpoint is in beta and is subject to change.

Cancels the Copilot seat assignment for all members of each team specified.
This will cause the members of the specified team(s) to lose access to GitHub Copilot at the end of the current billing cycle, and the organization will not be billed further for those users.

For more information about Copilot pricing, see "[Pricing for GitHub Copilot](https://docs.github.com/billing/managing-billing-for-github-copilot/about-billing-for-github-copilot#about-billing-for-github-copilot)".

For more information about disabling access to Copilot Business or Enterprise, see "[Revoking access to GitHub Copilot for specific users in your organization](https://docs.github.com/copilot/managing-copilot/managing-access-for-copilot-in-your-organization#revoking-access-to-github-copilot-for-specific-users-in-your-organization)".

Only organization owners can configure GitHub Copilot in their organization.

OAuth app tokens and personal access tokens (classic) need the `manage_billing:copilot` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/copilot/copilot-user-management#remove-teams-from-the-copilot-subscription-for-an-organization)

## cancel_copilot_seat_assignment_for_users(org, body, opts \\ [])

Remove users from the Copilot subscription for an organization

**Note**: This endpoint is in beta and is subject to change.

Cancels the Copilot seat assignment for each user specified.
This will cause the specified users to lose access to GitHub Copilot at the end of the current billing cycle, and the organization will not be billed further for those users.

For more information about Copilot pricing, see "[Pricing for GitHub Copilot](https://docs.github.com/billing/managing-billing-for-github-copilot/about-billing-for-github-copilot#about-billing-for-github-copilot)".

For more information about disabling access to Copilot Business or Enterprise, see "[Revoking access to GitHub Copilot for specific users in your organization](https://docs.github.com/copilot/managing-copilot/managing-access-for-copilot-in-your-organization#revoking-access-to-github-copilot-for-specific-users-in-your-organization)".

Only organization owners can configure GitHub Copilot in their organization.

OAuth app tokens and personal access tokens (classic) need the `manage_billing:copilot` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/copilot/copilot-user-management#remove-users-from-the-copilot-subscription-for-an-organization)

## get_copilot_organization_details(org, opts \\ [])

Get Copilot seat information and settings for an organization

**Note**: This endpoint is in beta and is subject to change.

Gets information about an organization's Copilot subscription, including seat breakdown
and code matching policies. To configure these settings, go to your organization's settings on GitHub.com.
For more information, see "[Managing policies for Copilot in your organization](https://docs.github.com/copilot/managing-copilot/managing-policies-for-copilot-business-in-your-organization)".

Only organization owners can configure and view details about the organization's Copilot Business subscription.

OAuth app tokens and personal access tokens (classic) need the `manage_billing:copilot` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/copilot/copilot-user-management#get-copilot-seat-information-and-settings-for-an-organization)

## get_copilot_seat_details_for_user(org, username, opts \\ [])

Get Copilot seat assignment details for a user

**Note**: This endpoint is in beta and is subject to change.

Gets the GitHub Copilot seat assignment details for a member of an organization who currently has access to GitHub Copilot.

Organization owners can view GitHub Copilot seat assignment details for members in their organization.

OAuth app tokens and personal access tokens (classic) need the `manage_billing:copilot` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/copilot/copilot-user-management#get-copilot-seat-assignment-details-for-a-user)

## list_copilot_seats(org, opts \\ [])

List all Copilot seat assignments for an organization

**Note**: This endpoint is in beta and is subject to change.

Lists all Copilot seat assignments for an organization that are currently being billed (either active or pending cancellation at the start of the next billing cycle).

Only organization owners can configure and view details about the organization's Copilot Business or Enterprise subscription.

OAuth app tokens and personal access tokens (classic) need the `manage_billing:copilot` scope to use this endpoint.

## Options

  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/copilot/copilot-user-management#list-all-copilot-seat-assignments-for-an-organization)

## usage_metrics_for_enterprise(enterprise, opts \\ [])

Get a summary of Copilot usage for enterprise members

**Note**: This endpoint is in beta and is subject to change.

You can use this endpoint to see a daily breakdown of aggregated usage metrics for Copilot completions and Copilot Chat in the IDE
for all users across organizations with access to Copilot within your enterprise, with a further breakdown of suggestions, acceptances,
and number of active users by editor and language for each day. See the response schema tab for detailed metrics definitions.

The response contains metrics for the prior 28 days. Usage metrics are processed once per day for the previous day,
and the response will only include data up until yesterday. In order for an end user to be counted towards these metrics,
they must have telemetry enabled in their IDE.

Only the owners and billing managers of enterprises with a Copilot Business or Enterprise subscription can view Copilot usage
metrics for the enterprise.

OAuth app tokens and personal access tokens (classic) need the `copilot`, `manage_billing:copilot`, `admin:enterprise`, or `manage_billing:enterprise` scope to use this endpoint.

## Options

  * `since`: Show usage metrics since this date. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format (`YYYY-MM-DDTHH:MM:SSZ`). Maximum value is 28 days ago.
  * `until`: Show usage metrics until this date. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format (`YYYY-MM-DDTHH:MM:SSZ`) and should not preceed the `since` date if it is passed.
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of days of metrics to display per page (max 28). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/copilot/copilot-usage#get-a-summary-of-copilot-usage-for-enterprise-members)

## usage_metrics_for_org(org, opts \\ [])

Get a summary of Copilot usage for organization members

**Note**: This endpoint is in beta and is subject to change.

You can use this endpoint to see a daily breakdown of aggregated usage metrics for Copilot completions and Copilot Chat in the IDE
across an organization, with a further breakdown of suggestions, acceptances, and number of active users by editor and language for each day.
See the response schema tab for detailed metrics definitions.

The response contains metrics for the prior 28 days. Usage metrics are processed once per day for the previous day,
and the response will only include data up until yesterday. In order for an end user to be counted towards these metrics,
they must have telemetry enabled in their IDE.

Copilot Business or Copilot Enterprise organization owners, and owners and billing managers of their parent enterprises, can view
Copilot usage metrics.

OAuth app tokens and personal access tokens (classic) need the `copilot`, `manage_billing:copilot`, `admin:org`, `admin:enterprise`, or `manage_billing:enterprise` scope to use this endpoint.

## Options

  * `since`: Show usage metrics since this date. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format (`YYYY-MM-DDTHH:MM:SSZ`). Maximum value is 28 days ago.
  * `until`: Show usage metrics until this date. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format (`YYYY-MM-DDTHH:MM:SSZ`) and should not preceed the `since` date if it is passed.
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of days of metrics to display per page (max 28). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/copilot/copilot-usage#get-a-summary-of-copilot-usage-for-organization-members)

## usage_metrics_for_team(org, team_slug, opts \\ [])

Get a summary of Copilot usage for a team

**Note**: This endpoint is in beta and is subject to change.

You can use this endpoint to see a daily breakdown of aggregated usage metrics for Copilot completions and Copilot Chat in the IDE
for users within a team, with a further breakdown of suggestions, acceptances, and number of active users by editor and language for each day.
See the response schema tab for detailed metrics definitions.

The response contains metrics for the prior 28 days. Usage metrics are processed once per day for the previous day,
and the response will only include data up until yesterday. In order for an end user to be counted towards these metrics,
they must have telemetry enabled in their IDE.

**Note**: This endpoint will only return results for a given day if the team had five or more members on that day.

Copilot Business or Copilot Enterprise organization owners for the organization that contains this team,
and owners and billing managers of their parent enterprises, can view Copilot usage metrics for a team.

OAuth app tokens and personal access tokens (classic) need the `copilot`, `manage_billing:copilot`, `admin:org`, `admin:enterprise`, or `manage_billing:enterprise` scope to use this endpoint.

## Options

  * `since`: Show usage metrics since this date. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format (`YYYY-MM-DDTHH:MM:SSZ`). Maximum value is 28 days ago.
  * `until`: Show usage metrics until this date. This is a timestamp in [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) format (`YYYY-MM-DDTHH:MM:SSZ`) and should not preceed the `since` date if it is passed.
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of days of metrics to display per page (max 28). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/copilot/copilot-usage#get-a-summary-of-copilot-usage-for-a-team)