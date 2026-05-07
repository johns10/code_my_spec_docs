# GitHub.Interactions

Provides API endpoints related to interactions

## get_restrictions_for_authenticated_user(opts \\ [])

Get interaction restrictions for your public repositories

Shows which type of GitHub user can interact with your public repositories and when the restriction expires.

## Resources

  * [API method documentation](https://docs.github.com/rest/interactions/user#get-interaction-restrictions-for-your-public-repositories)

## get_restrictions_for_org(org, opts \\ [])

Get interaction restrictions for an organization

Shows which type of GitHub user can interact with this organization and when the restriction expires. If there is no restrictions, you will see an empty response.

## Resources

  * [API method documentation](https://docs.github.com/rest/interactions/orgs#get-interaction-restrictions-for-an-organization)

## get_restrictions_for_repo(owner, repo, opts \\ [])

Get interaction restrictions for a repository

Shows which type of GitHub user can interact with this repository and when the restriction expires. If there are no restrictions, you will see an empty response.

## Resources

  * [API method documentation](https://docs.github.com/rest/interactions/repos#get-interaction-restrictions-for-a-repository)

## remove_restrictions_for_authenticated_user(opts \\ [])

Remove interaction restrictions from your public repositories

Removes any interaction restrictions from your public repositories.

## Resources

  * [API method documentation](https://docs.github.com/rest/interactions/user#remove-interaction-restrictions-from-your-public-repositories)

## remove_restrictions_for_org(org, opts \\ [])

Remove interaction restrictions for an organization

Removes all interaction restrictions from public repositories in the given organization. You must be an organization owner to remove restrictions.

## Resources

  * [API method documentation](https://docs.github.com/rest/interactions/orgs#remove-interaction-restrictions-for-an-organization)

## remove_restrictions_for_repo(owner, repo, opts \\ [])

Remove interaction restrictions for a repository

Removes all interaction restrictions from the given repository. You must have owner or admin access to remove restrictions. If the interaction limit is set for the user or organization that owns this repository, you will receive a `409 Conflict` response and will not be able to use this endpoint to change the interaction limit for a single repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/interactions/repos#remove-interaction-restrictions-for-a-repository)

## set_restrictions_for_authenticated_user(body, opts \\ [])

Set interaction restrictions for your public repositories

Temporarily restricts which type of GitHub user can interact with your public repositories. Setting the interaction limit at the user level will overwrite any interaction limits that are set for individual repositories owned by the user.

## Resources

  * [API method documentation](https://docs.github.com/rest/interactions/user#set-interaction-restrictions-for-your-public-repositories)

## set_restrictions_for_org(org, body, opts \\ [])

Set interaction restrictions for an organization

Temporarily restricts interactions to a certain type of GitHub user in any public repository in the given organization. You must be an organization owner to set these restrictions. Setting the interaction limit at the organization level will overwrite any interaction limits that are set for individual repositories owned by the organization.

## Resources

  * [API method documentation](https://docs.github.com/rest/interactions/orgs#set-interaction-restrictions-for-an-organization)

## set_restrictions_for_repo(owner, repo, body, opts \\ [])

Set interaction restrictions for a repository

Temporarily restricts interactions to a certain type of GitHub user within the given repository. You must have owner or admin access to set these restrictions. If an interaction limit is set for the user or organization that owns this repository, you will receive a `409 Conflict` response and will not be able to use this endpoint to change the interaction limit for a single repository.

## Resources

  * [API method documentation](https://docs.github.com/rest/interactions/repos#set-interaction-restrictions-for-a-repository)