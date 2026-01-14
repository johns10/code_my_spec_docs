# CodeMySpec.Git.CLI

Wraps git operations for cloning and pulling repositories with authenticated URLs. Retrieves OAuth access tokens from the Integrations context, injects them into repository URLs, and delegates git operations to the git_cli library.

## Delegates

None - this module directly implements all its public functions.

## Functions

### clone/3

Clones a git repository using authenticated credentials from the user's integrations.

```elixir
@spec clone(Scope.t(), String.t(), String.t()) :: {:ok, String.t()} | {:error, :not_connected | :unsupported_provider | :invalid_url | term()}
```

**Process**:
1. Parse the repository URL to extract the provider (GitHub, GitLab, etc.)
2. Retrieve the user's integration for that provider from the Integrations context
3. Inject the access token from the integration into the repository URL
4. Execute git clone operation using the authenticated URL
5. Set the remote URL back to the original URL without credentials
6. Return the cloned repository path on success

**Test Assertions**:
- successfully clones public GitHub repository when integration exists
- returns error when GitHub integration not found
- returns error when GitLab integration not found
- returns error for invalid repository URL
- returns error for SSH URL format
- returns error for HTTP (non-HTTPS) URL
- returns error for nil URL
- returns error for empty URL
- returns error for Bitbucket URL when only GitHub integration exists
- returns error for custom domain git hosting
- returns error when clone path is not empty
- returns error when clone path parent directory doesn't exist
- always creates .git directory on success
- clone fails predictably for invalid inputs

### pull/2

Pulls changes from the remote repository using authenticated credentials. Temporarily injects credentials into the remote URL, performs the pull, then restores the original URL without credentials.

```elixir
@spec pull(Scope.t(), String.t()) :: :ok | {:error, :not_connected | :unsupported_provider | :invalid_url | :invalid_path | term()}
```

**Process**:
1. Validate path is not nil or empty string (guard clauses)
2. Retrieve the current remote URL from the git repository
3. Parse the remote URL to extract the provider
4. Retrieve the user's integration for that provider
5. Inject the access token into the remote URL
6. Update the git remote URL to the authenticated URL
7. Execute git pull operation
8. Always restore the original remote URL (even on failure)
9. Return ok on success or error reason on failure

**Test Assertions**:
- successfully pulls from public GitHub repository
- restores original remote URL after pull operation
- returns error when integration not found
- returns error when path doesn't exist
- returns error when path is not a git repository
- returns error for nil path
- returns error for empty path
- removes token from remote URL even on git command failure
- pull fails predictably for invalid paths

## Dependencies

- CodeMySpec.Git.URLParser
- CodeMySpec.Integrations
- CodeMySpec.Users.Scope
- Git (external library)