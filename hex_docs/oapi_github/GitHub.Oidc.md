# GitHub.Oidc

Provides API endpoints related to oidc

## get_oidc_custom_sub_template_for_org(org, opts \\ [])

Get the customization template for an OIDC subject claim for an organization

Gets the customization template for an OpenID Connect (OIDC) subject claim.

OAuth app tokens and personal access tokens (classic) need the `read:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/oidc#get-the-customization-template-for-an-oidc-subject-claim-for-an-organization)

## update_oidc_custom_sub_template_for_org(org, body, opts \\ [])

Set the customization template for an OIDC subject claim for an organization

Creates or updates the customization template for an OpenID Connect (OIDC) subject claim.

OAuth app tokens and personal access tokens (classic) need the `write:org` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/actions/oidc#set-the-customization-template-for-an-oidc-subject-claim-for-an-organization)