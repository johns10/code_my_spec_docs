# CodeMySpec.Git.Behaviour

Behaviour defining the contract for Git operations with authenticated credentials.

This behaviour establishes the interface that Git implementations must provide for cloning and pulling repositories using OAuth integration credentials. It enables dependency injection and testing by allowing different implementations (production Git CLI wrapper vs test fixture adapter).

Implementations are configured via application environment:
- Production: `CodeMySpec.Git.CLI`
- Test: `CodeMySpec.Support.TestAdapter`
- Mock: `CodeMySpec.MockGit` (Mox)

## Functions

This module is a behaviour definition only and contains no public functions. It defines two callbacks that implementing modules must provide.

### clone/3

Clones a git repository using authenticated credentials from the user's integrations.

```elixir
@spec clone(Scope.t(), String.t(), String.t()) :: {:ok, String.t()} | {:error, :not_connected | :unsupported_provider | :invalid_url | term()}
```

**Process**:
1. Parse repository URL to determine provider (GitHub, GitLab, etc.)
2. Retrieve integration credentials for that provider from scope
3. Inject credentials into repository URL
4. Execute git clone operation
5. Clean up credentials from git configuration
6. Return path to cloned repository

**Test Assertions**:
- successfully clones repository with valid credentials
- returns error tuple with :not_connected when integration is not found
- returns error tuple with :unsupported_provider for unsupported providers
- returns error tuple with :invalid_url for invalid URL format
- returns error tuple when git operation fails
- removes credentials from git configuration after operation

### pull/2

Pulls changes from the remote repository using authenticated credentials.

```elixir
@spec pull(Scope.t(), String.t()) :: :ok | {:error, :not_connected | :unsupported_provider | :invalid_url | term()}
```

**Process**:
1. Get current remote URL from repository
2. Parse URL to determine provider
3. Retrieve integration credentials for that provider from scope
4. Inject credentials into remote URL
5. Execute git pull operation
6. Restore original URL without credentials

**Test Assertions**:
- successfully pulls changes with valid credentials
- returns error tuple with :not_connected when integration is not found
- returns error tuple with :unsupported_provider for unsupported providers
- restores original URL without credentials even on failure
- returns error tuple when git operation fails
- handles nil or empty path with error

## Dependencies

- CodeMySpec.Users.Scope
