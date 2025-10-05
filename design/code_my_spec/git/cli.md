# Git.CLI

## Purpose

Wraps git_cli library operations for cloning and pulling repositories with authenticated URLs. Retrieves OAuth access tokens from the Integrations context, injects them into repository URLs, and delegates git operations to the git_cli library.

## Public API

```elixir
# Repository Operations
@spec clone(Scope.t(), repo_url :: String.t(), path :: String.t()) ::
  {:ok, String.t()} | {:error, :not_connected | :unsupported_provider | term()}

@spec pull(Scope.t(), path :: String.t()) ::
  :ok | {:error, :not_connected | :unsupported_provider | term()}
```

## Execution Flow

### Clone Repository

1. **URL Parsing**: Parse `repo_url` using `Git.URLParser.provider/1` to extract provider (`:github`, `:gitlab`, etc.)
2. **Credential Retrieval**: Call `Integrations.get_integration(scope, provider)` to retrieve integration struct
3. **Connection Check**: Return `{:error, :not_connected}` if integration not found
4. **URL Authentication**: Call `Git.URLParser.inject_token/2` with `repo_url` and `integration.access_token` to construct authenticated URL (e.g., `https://TOKEN@github.com/owner/repo.git`)
5. **Git Clone**: Delegate to `Git.clone(authenticated_url, path)` from git_cli library
6. **Result Return**: Return `{:ok, cloned_path}` on success or `{:error, reason}` on failure (propagates URLParser errors like `:invalid_url`, `:unsupported_provider`)

### Pull Repository

1. **Remote URL Discovery**: Execute `git -C path config --get remote.origin.url` to retrieve repository's remote URL
2. **URL Parsing**: Parse remote URL using `Git.URLParser.provider/1` to extract provider
3. **Credential Retrieval**: Call `Integrations.get_integration(scope, provider)` to retrieve integration struct
4. **Connection Check**: Return `{:error, :not_connected}` if integration not found
5. **URL Authentication**: Call `Git.URLParser.inject_token/2` with remote URL and `integration.access_token`
6. **Temporary Remote Update**: Execute `git -C path remote set-url origin authenticated_url` to update remote URL with token
7. **Git Pull**: Delegate to `Git.pull(path)` from git_cli library
8. **Remote Restoration**: Execute `git -C path remote set-url origin original_url` to restore original URL without token
9. **Result Return**: Return `:ok` on success or `{:error, reason}` on failure (propagates URLParser errors like `:invalid_url`, `:unsupported_provider`)
