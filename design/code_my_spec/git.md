# Git Context

## Purpose

Thin wrapper around Git CLI for local git operations using credentials from the Integrations context. Supports clone, pull, and branch operations for content sync and repository management.

## Entity Ownership

None. Stateless wrapper around git CLI commands.

## Scope Integration

- All operations require a `Scope.t()` as the first parameter
- Scope used to retrieve integration credentials (GitHub token, GitLab token, SSH keys, etc.)
- Git operations executed with token-authenticated URLs
- No database entities - operates on local filesystem

## Public API

```elixir
# Repository Operations
@spec clone(Scope.t(), repo_url :: String.t(), path :: String.t()) :: {:ok, String.t()} | {:error, term()}
@spec pull(Scope.t(), path :: String.t()) :: :ok | {:error, term()}
```

## State Management Strategy

### Credential Authentication
- Retrieves credentials from Integrations context based on repo URL
- For GitHub: `Integrations.get_integration(scope, :github)` returns access token
- For GitLab: `Integrations.get_integration(scope, :gitlab)` returns access token
- Injects token into HTTPS URLs: `https://TOKEN@github.com/owner/repo.git`
- No credential storage - fetched per operation

### Git CLI Delegation
- Uses `git_cli` library for git operations
- Returns git_cli results or normalized errors

### Error Handling
- Returns `{:error, :not_connected}` if no integration found for repo provider
- Returns git_cli errors directly for operation failures

## Components

### Git.CLI

| field | value |
| ----- | ----- |
| type  | other |

Wraps git_cli clone and pull operations. Retrieves credentials from Integrations, injects into URLs, delegates to git_cli.

### Git.URLParser

| field | value |
| ----- | ----- |
| type  | other |

Parses git repository URLs to determine provider (github.com, gitlab.com, etc.) and construct authenticated URLs with injected tokens.

## Dependencies

- Integrations

## Execution Flow

### Clone Repository
1. **URL Parsing**: Parse repo URL to determine provider (github.com, gitlab.com, etc.)
2. **Credential Retrieval**: Call `Integrations.get_integration(scope, provider)` for access token
3. **Connection Check**: Return `{:error, :not_connected}` if no integration found
4. **URL Injection**: Transform `https://github.com/owner/repo.git` to `https://TOKEN@github.com/owner/repo.git`
5. **Git Clone**: Call `Git.clone(url, path)` from git_cli
6. **Result Return**: Return `{:ok, path}` or error

### Pull Repository
1. **URL Parsing**: Read remote URL from repo at path to determine provider
2. **Credential Retrieval**: Call `Integrations.get_integration(scope, provider)` for access token
3. **Connection Check**: Return `{:error, :not_connected}` if no integration found
4. **Git Pull**: Call `Git.pull(path)` from git_cli (uses existing remote URL with token)
5. **Result Return**: Return `:ok` or error