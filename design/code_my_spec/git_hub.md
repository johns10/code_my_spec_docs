# GitHub Context Design

## Purpose

The GitHub context provides a thin authentication wrapper around the `oapi_github` library. It retrieves GitHub access tokens from the Integrations context and passes them to `oapi_github` operations, enabling scoped GitHub API access. This context does not manage authentication, persist repository state, or duplicate GitHub API functionality—it simply bridges user scope to authenticated API calls.

## Entity Ownership

None. This context does not persist any entities. All GitHub data remains in GitHub's API.

## Access Patterns

- **Token Retrieval**: Query Integrations context for GitHub integration by `scope.user.id`
- **Scope Validation**: Verify user has connected GitHub account before API operations
- **Pass-Through Authentication**: Extract `access_token` and pass to `oapi_github` via `auth` option
- **No Local State**: No database queries or persistence within this context

## Public API

```elixir
# Repository Operations - Direct delegation to GitHub.Repos.*
@spec create_repository(Scope.t(), map()) :: {:ok, integer(), GitHub.Repository.t()} | {:error, term()}
@spec get_repository(Scope.t(), String.t(), String.t()) :: {:ok, integer(), GitHub.Repository.t()} | {:error, term()}
@spec list_repositories_for_authenticated_user(Scope.t(), keyword()) :: {:ok, integer(), [GitHub.Repository.t()]} | {:error, term()}
@spec update_repository(Scope.t(), String.t(), String.t(), map()) :: {:ok, integer(), GitHub.Repository.t()} | {:error, term()}
@spec delete_repository(Scope.t(), String.t(), String.t()) :: {:ok, integer(), any()} | {:error, term()}

# Pull Request Operations - Direct delegation to GitHub.Pulls.*
@spec create_pull_request(Scope.t(), String.t(), String.t(), map()) :: {:ok, integer(), GitHub.PullRequest.t()} | {:error, term()}
@spec get_pull_request(Scope.t(), String.t(), String.t(), integer()) :: {:ok, integer(), GitHub.PullRequest.t()} | {:error, term()}
@spec list_pull_requests(Scope.t(), String.t(), String.t(), keyword()) :: {:ok, integer(), [GitHub.PullRequest.t()]} | {:error, term()}
@spec update_pull_request(Scope.t(), String.t(), String.t(), integer(), map()) :: {:ok, integer(), GitHub.PullRequest.t()} | {:error, term()}
@spec merge_pull_request(Scope.t(), String.t(), String.t(), integer(), map()) :: {:ok, integer(), GitHub.PullRequestMergeResult.t()} | {:error, term()}

# Issue Operations - Direct delegation to GitHub.Issues.*
@spec create_issue(Scope.t(), String.t(), String.t(), map()) :: {:ok, integer(), GitHub.Issue.t()} | {:error, term()}
@spec get_issue(Scope.t(), String.t(), String.t(), integer()) :: {:ok, integer(), GitHub.Issue.t()} | {:error, term()}
@spec list_issues(Scope.t(), String.t(), String.t(), keyword()) :: {:ok, integer(), [GitHub.Issue.t()]} | {:error, term()}
@spec update_issue(Scope.t(), String.t(), String.t(), integer(), map()) :: {:ok, integer(), GitHub.Issue.t()} | {:error, term()}

# Branch Operations - Direct delegation to GitHub.Repos.*
@spec list_branches(Scope.t(), String.t(), String.t(), keyword()) :: {:ok, integer(), [GitHub.ShortBranch.t()]} | {:error, term()}
@spec get_branch(Scope.t(), String.t(), String.t(), String.t()) :: {:ok, integer(), GitHub.BranchWithProtection.t()} | {:error, term()}

# Git Operations - Direct delegation to GitHub.Git.*
@spec create_ref(Scope.t(), String.t(), String.t(), map()) :: {:ok, integer(), GitHub.GitRef.t()} | {:error, term()}
@spec delete_ref(Scope.t(), String.t(), String.t(), String.t()) :: {:ok, integer(), any()} | {:error, term()}

# Content Operations - Direct delegation to GitHub.Repos.*
@spec get_content(Scope.t(), String.t(), String.t(), String.t(), keyword()) :: {:ok, integer(), GitHub.ContentFile.t()} | {:error, term()}
@spec create_or_update_file_contents(Scope.t(), String.t(), String.t(), String.t(), map()) :: {:ok, integer(), GitHub.FileCommit.t()} | {:error, term()}
@spec delete_file(Scope.t(), String.t(), String.t(), String.t(), map()) :: {:ok, integer(), GitHub.FileCommit.t()} | {:error, term()}

# Commit Operations - Direct delegation to GitHub.Repos.*
@spec get_commit(Scope.t(), String.t(), String.t(), String.t()) :: {:ok, integer(), GitHub.Commit.t()} | {:error, term()}
@spec list_commits(Scope.t(), String.t(), String.t(), keyword()) :: {:ok, integer(), [GitHub.Commit.t()]} | {:error, term()}

# User Operations - Direct delegation to GitHub.Users.*
@spec get_authenticated_user(Scope.t()) :: {:ok, integer(), GitHub.User.t()} | {:error, term()}
```

## State Management Strategy

### Stateless Pass-Through Architecture

- **No Local Persistence**: This context stores nothing in the database
- **Token Retrieval**: Each operation fetches token from Integrations context via private `get_auth/1` helper
- **Direct Delegation**: All GitHub operations immediately call `oapi_github` functions with `auth` option
- **Response Pass-Through**: Return `oapi_github` responses directly without transformation
- **No Caching**: Every call retrieves fresh data from GitHub API

### Authentication Flow

```
1. Public function receives Scope struct
2. Call private get_auth(scope) to retrieve token from Integrations
3. Return {:error, :github_not_connected} if integration missing
4. Call corresponding GitHub.* function with auth: token
5. Return result tuple from oapi_github unchanged
```

## Execution Flow

### Standard Operation Flow

1. **Token Retrieval**: Private `get_auth/1` calls `Integrations.get_integration(scope, :github)`
2. **Validation**: Return `{:error, :github_not_connected}` if integration not found
3. **Extract Token**: Pull `access_token` from integration struct
4. **Delegate**: Use `with` statement to call `GitHub.Resource.operation(..., auth: token)`
5. **Return**: Pass through `{:ok, status, result}` or `{:error, reason}` unchanged

### Example: Create Repository

```elixir
def create_repository(%Scope{} = scope, attrs) do
  with {:ok, token} <- get_auth(scope) do
    GitHub.Repos.create_for_authenticated_user(attrs, auth: token)
  end
end
```

### Example: Create Pull Request

```elixir
def create_pull_request(%Scope{} = scope, owner, repo, params) do
  with {:ok, token} <- get_auth(scope) do
    GitHub.Pulls.create(owner, repo, params, auth: token)
  end
end
```

### Example: Get Authenticated User

```elixir
def get_authenticated_user(%Scope{} = scope) do
  with {:ok, token} <- get_auth(scope) do
    GitHub.Users.get_authenticated(auth: token)
  end
end
```

## Dependencies

- CodeMySpec.Integrations

## Components

## Test Strategies

### Fixtures

- **github_integration**: Valid GitHub integration with non-expired access token from Integrations context
- **scope_with_github**: Scope struct for user who has GitHub connected

### Mocks and Doubles

- **GitHub.Repos mock**: Use `GitHub.Testing` module's `mock_gh/2` helper for repository operations
- **GitHub.Pulls mock**: Mock pull request operations with canned responses
- **GitHub.Issues mock**: Mock issue operations with canned responses
- **Integrations.get_integration/2**: Mock to return valid/missing integrations

### Testing Approach

- **Unit Tests**: Public wrapper functions using `GitHub.Testing` helpers to mock `oapi_github` calls
- **Integration Tests**: Verify Integrations context token retrieval works correctly
- **Error Scenarios**: Test missing integration, invalid tokens, API errors from `oapi_github`
- **No Internal Testing**: Do not test `oapi_github` library internals—trust the library

### Test Helpers

- **Use `GitHub.Testing`**: Leverage `mock_gh/2` and `assert_called_gh/1` from library
- **Mock Integrations**: Provide test helper to mock `get_integration/2` responses
- **Token Helper**: `with_github_integration/1` sets up scope with valid GitHub connection

## Test Assertions

- describe "create_repository/2"
  - test "retrieves token and delegates to GitHub.Repos.create_for_authenticated_user"
  - test "passes repository attributes to oapi_github"
  - test "returns error when GitHub integration not connected"
  - test "returns result from oapi_github unchanged"

- describe "get_repository/3"
  - test "retrieves token and delegates to GitHub.Repos.get with owner and repo"
  - test "passes auth option to oapi_github"
  - test "returns error when GitHub integration missing"

- describe "list_repositories_for_authenticated_user/2"
  - test "retrieves token and delegates to GitHub.Repos.list_for_authenticated_user"
  - test "passes query parameters through opts"
  - test "returns list of repositories from oapi_github"

- describe "create_pull_request/4"
  - test "retrieves token and delegates to GitHub.Pulls.create"
  - test "passes owner, repo, and PR parameters"
  - test "returns pull request from oapi_github"
  - test "returns error when GitHub not connected"

- describe "list_pull_requests/4"
  - test "retrieves token and delegates to GitHub.Pulls.list"
  - test "passes owner, repo, and filter options"
  - test "returns list of pull requests"

- describe "merge_pull_request/5"
  - test "retrieves token and delegates to GitHub.Pulls.merge"
  - test "passes owner, repo, pull number, and merge parameters"
  - test "returns merge result from oapi_github"

- describe "create_issue/4"
  - test "retrieves token and delegates to GitHub.Issues.create"
  - test "passes owner, repo, and issue parameters"
  - test "returns created issue"

- describe "get_authenticated_user/1"
  - test "retrieves token and delegates to GitHub.Users.get_authenticated"
  - test "returns user info from GitHub"
  - test "returns error when token invalid"

- describe "create_ref/4"
  - test "retrieves token and delegates to GitHub.Git.create_ref"
  - test "creates branch with specified ref and sha"
  - test "returns git ref from oapi_github"

- describe "delete_ref/4"
  - test "retrieves token and delegates to GitHub.Git.delete_ref"
  - test "deletes branch reference"
  - test "returns result from oapi_github"

- describe "get_content/5"
  - test "retrieves token and delegates to GitHub.Repos.get_content"
  - test "returns file content or directory listing"
  - test "passes path and optional ref parameters"

- describe "create_or_update_file_contents/5"
  - test "retrieves token and delegates to GitHub.Repos.create_or_update_file_contents"
  - test "creates new file or updates existing file"
  - test "passes commit message and content"

- describe "delete_file/5"
  - test "retrieves token and delegates to GitHub.Repos.delete_file"
  - test "deletes file with commit message and sha"
  - test "returns file commit result"