# GitHub.Projects

Provides API endpoints related to projects

## add_collaborator/4

Add project collaborator

Adds a collaborator to an organization project and sets their permission level. You must be an organization owner or a project `admin` to add a collaborator.

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/collaborators#add-project-collaborator)

## create_card/3

Create a project card

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/cards#create-a-project-card)

## create_column/3

Create a project column

Creates a new project column.

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/columns#create-a-project-column)

## create_for_authenticated_user/2

Create a user project

Creates a user project board. Returns a `410 Gone` status if the user does not have existing classic projects. If you do not have sufficient privileges to perform this action, a `401 Unauthorized` or `410 Gone` status is returned.

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/projects#create-a-user-project)

## create_for_org/3

Create an organization project

Creates an organization project board. Returns a `410 Gone` status if projects are disabled in the organization or if the organization does not have existing classic projects. If you do not have sufficient privileges to perform this action, a `401 Unauthorized` or `410 Gone` status is returned.

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/projects#create-an-organization-project)

## create_for_repo/4

Create a repository project

Creates a repository project board. Returns a `410 Gone` status if projects are disabled in the repository or if the repository does not have existing classic projects. If you do not have sufficient privileges to perform this action, a `401 Unauthorized` or `410 Gone` status is returned.

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/projects#create-a-repository-project)

## delete/2

Delete a project

Deletes a project board. Returns a `404 Not Found` status if projects are disabled.

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/projects#delete-a-project)

## delete_card/2

Delete a project card

Deletes a project card

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/cards#delete-a-project-card)

## delete_column/2

Delete a project column

Deletes a project column.

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/columns#delete-a-project-column)

## get/2

Get a project

Gets a project by its `id`. Returns a `404 Not Found` status if projects are disabled. If you do not have sufficient privileges to perform this action, a `401 Unauthorized` or `410 Gone` status is returned.

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/projects#get-a-project)

## get_card/2

Get a project card

Gets information about a project card.

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/cards#get-a-project-card)

## get_column/2

Get a project column

Gets information about a project column.

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/columns#get-a-project-column)

## get_permission_for_user/3

Get project permission for a user

Returns the collaborator's permission level for an organization project. Possible values for the `permission` key: `admin`, `write`, `read`, `none`. You must be an organization owner or a project `admin` to review a user's permission level.

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/collaborators#get-project-permission-for-a-user)

## list_cards/2

List project cards

Lists the project cards in a project.

## Options

  * `archived_state`: Filters the project cards that are returned by the card's state.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/cards#list-project-cards)

## list_collaborators/2

List project collaborators

Lists the collaborators for an organization project. For a project, the list of collaborators includes outside collaborators, organization members that are direct collaborators, organization members with access through team memberships, organization members with access through default organization permissions, and organization owners. You must be an organization owner or a project `admin` to list collaborators.

## Options

  * `affiliation`: Filters the collaborators by their affiliation. `outside` means outside collaborators of a project that are not a member of the project's organization. `direct` means collaborators with permissions to a project, regardless of organization membership status. `all` means all collaborators the authenticated user can see.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/collaborators#list-project-collaborators)

## list_columns/2

List project columns

Lists the project columns in a project.

## Options

  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/columns#list-project-columns)

## list_for_org/2

List organization projects

Lists the projects in an organization. Returns a `404 Not Found` status if projects are disabled in the organization. If you do not have sufficient privileges to perform this action, a `401 Unauthorized` or `410 Gone` status is returned.

## Options

  * `state`: Indicates the state of the projects to return.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/projects#list-organization-projects)

## list_for_repo/3

List repository projects

Lists the projects in a repository. Returns a `404 Not Found` status if projects are disabled in the repository. If you do not have sufficient privileges to perform this action, a `401 Unauthorized` or `410 Gone` status is returned.

## Options

  * `state`: Indicates the state of the projects to return.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/projects#list-repository-projects)

## list_for_user/2

List user projects

Lists projects for a user.

## Options

  * `state`: Indicates the state of the projects to return.
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/projects#list-user-projects)

## move_card/3

Move a project card

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/cards#move-a-project-card)

## move_column/3

Move a project column

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/columns#move-a-project-column)

## remove_collaborator/3

Remove user as a collaborator

Removes a collaborator from an organization project. You must be an organization owner or a project `admin` to remove a collaborator.

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/collaborators#remove-user-as-a-collaborator)

## update/3

Update a project

Updates a project board's information. Returns a `404 Not Found` status if projects are disabled. If you do not have sufficient privileges to perform this action, a `401 Unauthorized` or `410 Gone` status is returned.

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/projects#update-a-project)

## update_card/3

Update an existing project card

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/cards#update-an-existing-project-card)

## update_column/3

Update an existing project column

## Resources

  * [API method documentation](https://docs.github.com/rest/projects/columns#update-an-existing-project-column)