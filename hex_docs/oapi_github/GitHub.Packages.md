# GitHub.Packages

Provides API endpoints related to packages

## delete_package_for_authenticated_user(package_type, package_name, opts \\ [])

Delete a package for the authenticated user

Deletes a package owned by the authenticated user. You cannot delete a public package if any version of the package has more than 5,000 downloads. In this scenario, contact GitHub support for further assistance.

OAuth app tokens and personal access tokens (classic) need the `read:packages` and `delete:packages` scopes to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, `repo` scope is also required. For the list these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#delete-a-package-for-the-authenticated-user)

## delete_package_for_org(package_type, package_name, org, opts \\ [])

Delete a package for an organization

Deletes an entire package in an organization. You cannot delete a public package if any version of the package has more than 5,000 downloads. In this scenario, contact GitHub support for further assistance.

The authenticated user must have admin permissions in the organization to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that supports granular permissions, the authenticated user must also have admin permissions to the package. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#granular-permissions-for-userorganization-scoped-packages)."

OAuth app tokens and personal access tokens (classic) need the `read:packages` and `delete:packages` scopes to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#delete-a-package-for-an-organization)

## delete_package_for_user(package_type, package_name, username, opts \\ [])

Delete a package for a user

Deletes an entire package for a user. You cannot delete a public package if any version of the package has more than 5,000 downloads. In this scenario, contact GitHub support for further assistance.

If the `package_type` belongs to a GitHub Packages registry that supports granular permissions, the authenticated user must have admin permissions to the package. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#granular-permissions-for-userorganization-scoped-packages)."

OAuth app tokens and personal access tokens (classic) need the `read:packages` and `delete:packages` scopes to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#delete-a-package-for-a-user)

## delete_package_version_for_authenticated_user(package_type, package_name, package_version_id, opts \\ [])

Delete a package version for the authenticated user

Deletes a specific package version for a package owned by the authenticated user.  If the package is public and the package version has more than 5,000 downloads, you cannot delete the package version. In this scenario, contact GitHub support for further assistance.

The authenticated user must have admin permissions in the organization to use this endpoint.

OAuth app tokens and personal access tokens (classic) need the `read:packages` and `delete:packages` scopes to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#delete-a-package-version-for-the-authenticated-user)

## delete_package_version_for_org(package_type, package_name, org, package_version_id, opts \\ [])

Delete package version for an organization

Deletes a specific package version in an organization. If the package is public and the package version has more than 5,000 downloads, you cannot delete the package version. In this scenario, contact GitHub support for further assistance.

The authenticated user must have admin permissions in the organization to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that supports granular permissions, the authenticated user must also have admin permissions to the package. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#granular-permissions-for-userorganization-scoped-packages)."

OAuth app tokens and personal access tokens (classic) need the `read:packages` and `delete:packages` scopes to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#delete-package-version-for-an-organization)

## delete_package_version_for_user(package_type, package_name, username, package_version_id, opts \\ [])

Delete package version for a user

Deletes a specific package version for a user. If the package is public and the package version has more than 5,000 downloads, you cannot delete the package version. In this scenario, contact GitHub support for further assistance.

If the `package_type` belongs to a GitHub Packages registry that supports granular permissions, the authenticated user must have admin permissions to the package. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#granular-permissions-for-userorganization-scoped-packages)."

OAuth app tokens and personal access tokens (classic) need the `read:packages` and `delete:packages` scopes to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#delete-package-version-for-a-user)

## get_all_package_versions_for_package_owned_by_authenticated_user(package_type, package_name, opts \\ [])

List package versions for a package owned by the authenticated user

Lists package versions for a package owned by the authenticated user.

OAuth app tokens and personal access tokens (classic) need the `read:packages` scope to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Options

  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `state`: The state of the package, either active or deleted.

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#list-package-versions-for-a-package-owned-by-the-authenticated-user)

## get_all_package_versions_for_package_owned_by_org(package_type, package_name, org, opts \\ [])

List package versions for a package owned by an organization

Lists package versions for a package owned by an organization.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint if the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Options

  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `state`: The state of the package, either active or deleted.

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#list-package-versions-for-a-package-owned-by-an-organization)

## get_all_package_versions_for_package_owned_by_user(package_type, package_name, username, opts \\ [])

List package versions for a package owned by a user

Lists package versions for a public package owned by a specified user.

OAuth app tokens and personal access tokens (classic) need the `read:packages` scope to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#list-package-versions-for-a-package-owned-by-a-user)

## get_package_for_authenticated_user(package_type, package_name, opts \\ [])

Get a package for the authenticated user

Gets a specific package for a package owned by the authenticated user.

OAuth app tokens and personal access tokens (classic) need the `read:packages` scope to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#get-a-package-for-the-authenticated-user)

## get_package_for_organization(package_type, package_name, org, opts \\ [])

Get a package for an organization

Gets a specific package in an organization.

OAuth app tokens and personal access tokens (classic) need the `read:packages` scope to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#get-a-package-for-an-organization)

## get_package_for_user(package_type, package_name, username, opts \\ [])

Get a package for a user

Gets a specific package metadata for a public package owned by a user.

OAuth app tokens and personal access tokens (classic) need the `read:packages` scope to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#get-a-package-for-a-user)

## get_package_version_for_authenticated_user(package_type, package_name, package_version_id, opts \\ [])

Get a package version for the authenticated user

Gets a specific package version for a package owned by the authenticated user.

OAuth app tokens and personal access tokens (classic) need the `read:packages` scope to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#get-a-package-version-for-the-authenticated-user)

## get_package_version_for_organization(package_type, package_name, org, package_version_id, opts \\ [])

Get a package version for an organization

Gets a specific package version in an organization.

OAuth app tokens and personal access tokens (classic) need the `read:packages` scope to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#get-a-package-version-for-an-organization)

## get_package_version_for_user(package_type, package_name, package_version_id, username, opts \\ [])

Get a package version for a user

Gets a specific package version for a public package owned by a specified user.

OAuth app tokens and personal access tokens (classic) need the `read:packages` scope to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#get-a-package-version-for-a-user)

## list_docker_migration_conflicting_packages_for_authenticated_user(opts \\ [])

Get list of conflicting packages during Docker migration for authenticated-user

Lists all packages that are owned by the authenticated user within the user's namespace, and that encountered a conflict during a Docker migration.

OAuth app tokens and personal access tokens (classic) need the `read:packages` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#get-list-of-conflicting-packages-during-docker-migration-for-authenticated-user)

## list_docker_migration_conflicting_packages_for_organization(org, opts \\ [])

Get list of conflicting packages during Docker migration for organization

Lists all packages that are in a specific organization, are readable by the requesting user, and that encountered a conflict during a Docker migration.

OAuth app tokens and personal access tokens (classic) need the `read:packages` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#get-list-of-conflicting-packages-during-docker-migration-for-organization)

## list_docker_migration_conflicting_packages_for_user(username, opts \\ [])

Get list of conflicting packages during Docker migration for user

Lists all packages that are in a specific user's namespace, that the requesting user has access to, and that encountered a conflict during Docker migration.

OAuth app tokens and personal access tokens (classic) need the `read:packages` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#get-list-of-conflicting-packages-during-docker-migration-for-user)

## list_packages_for_authenticated_user(opts \\ [])

List packages for the authenticated user's namespace

Lists packages owned by the authenticated user within the user's namespace.

OAuth app tokens and personal access tokens (classic) need the `read:packages` scope to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Options

  * `package_type`: The type of supported package. Packages in GitHub's Gradle registry have the type `maven`. Docker images pushed to GitHub's Container registry (`ghcr.io`) have the type `container`. You can use the type `docker` to find images that were pushed to GitHub's Docker registry (`docker.pkg.github.com`), even if these have now been migrated to the Container registry.
  * `visibility`: The selected visibility of the packages.  This parameter is optional and only filters an existing result set.
    
    The `internal` visibility is only supported for GitHub Packages registries that allow for granular permissions. For other ecosystems `internal` is synonymous with `private`.
    For the list of GitHub Packages registries that support granular permissions, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#granular-permissions-for-userorganization-scoped-packages)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#list-packages-for-the-authenticated-users-namespace)

## list_packages_for_organization(org, opts \\ [])

List packages for an organization

Lists packages in an organization readable by the user.

OAuth app tokens and personal access tokens (classic) need the `read:packages` scope to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Options

  * `package_type`: The type of supported package. Packages in GitHub's Gradle registry have the type `maven`. Docker images pushed to GitHub's Container registry (`ghcr.io`) have the type `container`. You can use the type `docker` to find images that were pushed to GitHub's Docker registry (`docker.pkg.github.com`), even if these have now been migrated to the Container registry.
  * `visibility`: The selected visibility of the packages.  This parameter is optional and only filters an existing result set.
    
    The `internal` visibility is only supported for GitHub Packages registries that allow for granular permissions. For other ecosystems `internal` is synonymous with `private`.
    For the list of GitHub Packages registries that support granular permissions, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#granular-permissions-for-userorganization-scoped-packages)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#list-packages-for-an-organization)

## list_packages_for_user(username, opts \\ [])

List packages for a user

Lists all packages in a user's namespace for which the requesting user has access.

OAuth app tokens and personal access tokens (classic) need the `read:packages` scope to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Options

  * `package_type`: The type of supported package. Packages in GitHub's Gradle registry have the type `maven`. Docker images pushed to GitHub's Container registry (`ghcr.io`) have the type `container`. You can use the type `docker` to find images that were pushed to GitHub's Docker registry (`docker.pkg.github.com`), even if these have now been migrated to the Container registry.
  * `visibility`: The selected visibility of the packages.  This parameter is optional and only filters an existing result set.
    
    The `internal` visibility is only supported for GitHub Packages registries that allow for granular permissions. For other ecosystems `internal` is synonymous with `private`.
    For the list of GitHub Packages registries that support granular permissions, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#granular-permissions-for-userorganization-scoped-packages)."
  * `page`: The page number of the results to fetch. For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."
  * `per_page`: The number of results per page (max 100). For more information, see "[Using pagination in the REST API](https://docs.github.com/rest/using-the-rest-api/using-pagination-in-the-rest-api)."

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#list-packages-for-a-user)

## restore_package_for_authenticated_user(package_type, package_name, opts \\ [])

Restore a package for the authenticated user

Restores a package owned by the authenticated user.

You can restore a deleted package under the following conditions:
  - The package was deleted within the last 30 days.
  - The same package namespace and version is still available and not reused for a new package. If the same package namespace is not available, you will not be able to restore your package. In this scenario, to restore the deleted package, you must delete the new package that uses the deleted package's namespace first.

OAuth app tokens and personal access tokens (classic) need the `read:packages` and `write:packages` scopes to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Options

  * `token`: package token

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#restore-a-package-for-the-authenticated-user)

## restore_package_for_org(package_type, package_name, org, opts \\ [])

Restore a package for an organization

Restores an entire package in an organization.

You can restore a deleted package under the following conditions:
  - The package was deleted within the last 30 days.
  - The same package namespace and version is still available and not reused for a new package. If the same package namespace is not available, you will not be able to restore your package. In this scenario, to restore the deleted package, you must delete the new package that uses the deleted package's namespace first.

The authenticated user must have admin permissions in the organization to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that supports granular permissions, the authenticated user must also have admin permissions to the package. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#granular-permissions-for-userorganization-scoped-packages)."

OAuth app tokens and personal access tokens (classic) need the `read:packages` and `write:packages` scopes to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Options

  * `token`: package token

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#restore-a-package-for-an-organization)

## restore_package_for_user(package_type, package_name, username, opts \\ [])

Restore a package for a user

Restores an entire package for a user.

You can restore a deleted package under the following conditions:
  - The package was deleted within the last 30 days.
  - The same package namespace and version is still available and not reused for a new package. If the same package namespace is not available, you will not be able to restore your package. In this scenario, to restore the deleted package, you must delete the new package that uses the deleted package's namespace first.

If the `package_type` belongs to a GitHub Packages registry that supports granular permissions, the authenticated user must have admin permissions to the package. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#granular-permissions-for-userorganization-scoped-packages)."

OAuth app tokens and personal access tokens (classic) need the `read:packages` and `write:packages` scopes to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Options

  * `token`: package token

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#restore-a-package-for-a-user)

## restore_package_version_for_authenticated_user(package_type, package_name, package_version_id, opts \\ [])

Restore a package version for the authenticated user

Restores a package version owned by the authenticated user.

You can restore a deleted package version under the following conditions:
  - The package was deleted within the last 30 days.
  - The same package namespace and version is still available and not reused for a new package. If the same package namespace is not available, you will not be able to restore your package. In this scenario, to restore the deleted package, you must delete the new package that uses the deleted package's namespace first.

OAuth app tokens and personal access tokens (classic) need the `read:packages` and `write:packages` scopes to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#restore-a-package-version-for-the-authenticated-user)

## restore_package_version_for_org(package_type, package_name, org, package_version_id, opts \\ [])

Restore package version for an organization

Restores a specific package version in an organization.

You can restore a deleted package under the following conditions:
  - The package was deleted within the last 30 days.
  - The same package namespace and version is still available and not reused for a new package. If the same package namespace is not available, you will not be able to restore your package. In this scenario, to restore the deleted package, you must delete the new package that uses the deleted package's namespace first.

The authenticated user must have admin permissions in the organization to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that supports granular permissions, the authenticated user must also have admin permissions to the package. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#granular-permissions-for-userorganization-scoped-packages)."

OAuth app tokens and personal access tokens (classic) need the `read:packages` and `write:packages` scopes to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#restore-package-version-for-an-organization)

## restore_package_version_for_user(package_type, package_name, username, package_version_id, opts \\ [])

Restore package version for a user

Restores a specific package version for a user.

You can restore a deleted package under the following conditions:
  - The package was deleted within the last 30 days.
  - The same package namespace and version is still available and not reused for a new package. If the same package namespace is not available, you will not be able to restore your package. In this scenario, to restore the deleted package, you must delete the new package that uses the deleted package's namespace first.

If the `package_type` belongs to a GitHub Packages registry that supports granular permissions, the authenticated user must have admin permissions to the package. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#granular-permissions-for-userorganization-scoped-packages)."

OAuth app tokens and personal access tokens (classic) need the `read:packages` and `write:packages` scopes to use this endpoint. If the `package_type` belongs to a GitHub Packages registry that only supports repository-scoped permissions, the `repo` scope is also required. For the list of these registries, see "[About permissions for GitHub Packages](https://docs.github.com/packages/learn-github-packages/about-permissions-for-github-packages#permissions-for-repository-scoped-packages)."

## Resources

  * [API method documentation](https://docs.github.com/rest/packages/packages#restore-package-version-for-a-user)