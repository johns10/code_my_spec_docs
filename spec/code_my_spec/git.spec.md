# CodeMySpec.Git

Context module for Git operations using authenticated credentials. Provides a thin wrapper around Git CLI operations for cloning and pulling repositories using OAuth tokens from the Integrations context.

## Delegates

- clone/3: CodeMySpec.Git.CLI.clone/3
- pull/2: CodeMySpec.Git.CLI.pull/2

## Functions

### clone/3

Clones a git repository using authenticated credentials from the user's integrations.

```elixir
@spec clone(Scope.t(), String.t(), String.t()) :: {:ok, String.t()} | {:error, :not_connected | :unsupported_provider | :invalid_url | term()}
```

**Process**:
1. Delegate to implementation module (defaults to CodeMySpec.Git.CLI)
2. Parse repository URL to determine provider (GitHub, GitLab, etc.)
3. Retrieve integration credentials for that provider from Integrations context
4. Inject credentials into repository URL using URLParser
5. Execute git clone operation via git_cli library
6. Clean up credentials from git configuration by setting remote URL without credentials
7. Return cloned path or error

**Test Assertions**:
- delegates to implementation module with correct parameters
- successfully clones public GitHub repository when integration exists
- returns error when GitHub integration not found
- returns error when GitLab integration not found
- returns error for invalid repository URL
- returns error for SSH URL format
- returns error for HTTP (non-HTTPS) URL
- returns error for nil URL
- returns error for empty URL
- returns error for unsupported providers (Bitbucket, custom domains)
- returns error when clone path is not empty
- returns error when clone path parent directory does not exist
- always creates .git directory on successful clone

### pull/2

Pulls changes from the remote repository using authenticated credentials. Temporarily injects credentials into the remote URL, performs the pull, then restores the original URL without credentials.

```elixir
@spec pull(Scope.t(), String.t()) :: :ok | {:error, :not_connected | :unsupported_provider | :invalid_url | :invalid_path | term()}
```

**Process**:
1. Delegate to implementation module (defaults to CodeMySpec.Git.CLI)
2. Validate path is not nil or empty string
3. Get current remote URL from git configuration
4. Parse remote URL to determine provider
5. Retrieve integration credentials for that provider
6. Inject credentials into remote URL using URLParser
7. Temporarily update git remote URL with authenticated URL
8. Execute git pull operation
9. Always restore original URL without credentials, even on failure
10. Return success or error

**Test Assertions**:
- delegates to implementation module with correct parameters
- successfully pulls from public GitHub repository
- restores original remote URL after pull operation
- removes token from remote URL even on git command failure
- returns error when integration not found
- returns error when path does not exist
- returns error when path is not a git repository
- returns error for nil path
- returns error for empty path
- propagates errors from implementation while cleaning up credentials

## Dependencies

- CodeMySpec.Git.CLI
- CodeMySpec.Git.Behaviour
- CodeMySpec.Users.Scope

## Components

### CodeMySpec.Git.Behaviour

Defines the behavior contract for Git operations. Specifies callbacks for clone/3 and pull/2 operations with proper type specifications and error handling patterns.

### CodeMySpec.Git.CLI

Wraps git operations for cloning and pulling repositories with authenticated URLs. Retrieves OAuth access tokens from the Integrations context, injects them into repository URLs, and delegates git operations to the git_cli library. Handles credential cleanup and URL restoration.

### CodeMySpec.Git.URLParser

Parses HTTPS git repository URLs to extract provider information and construct authenticated URLs with injected access tokens. Supports GitHub and GitLab providers. Validates URL format and normalizes host names.
