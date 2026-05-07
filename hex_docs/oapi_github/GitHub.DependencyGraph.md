# GitHub.DependencyGraph

Provides API endpoints related to dependency graph

## create_repository_snapshot(owner, repo, body, opts \\ [])

Create a snapshot of dependencies for a repository

Create a new snapshot of a repository's dependencies.

The authenticated user must have access to the repository.

OAuth app tokens and personal access tokens (classic) need the `repo` scope to use this endpoint.

## Resources

  * [API method documentation](https://docs.github.com/rest/dependency-graph/dependency-submission#create-a-snapshot-of-dependencies-for-a-repository)

## diff_range(owner, repo, basehead, opts \\ [])

Get a diff of the dependencies between commits

Gets the diff of the dependency changes between two commits of a repository, based on the changes to the dependency manifests made in those commits.

## Options

  * `name`: The full path, relative to the repository root, of the dependency manifest file.

## Resources

  * [API method documentation](https://docs.github.com/rest/dependency-graph/dependency-review#get-a-diff-of-the-dependencies-between-commits)

## export_sbom(owner, repo, opts \\ [])

Export a software bill of materials (SBOM) for a repository.

Exports the software bill of materials (SBOM) for a repository in SPDX JSON format.

## Resources

  * [API method documentation](https://docs.github.com/rest/dependency-graph/sboms#export-a-software-bill-of-materials-sbom-for-a-repository)