# ProjectSetupWizard

## Purpose
Orchestrates environment setup for existing projects by coordinating GitHub integration, repository creation/linking, VS Code extension presence tracking, and script generation for submodule initialization.

## Entity Ownership
- Setup wizard state (transient, not persisted)
- Script generation for docs/content submodule configuration

## Access Patterns
- All operations scoped by user_id and active_account_id from Scope struct
- GitHub operations authenticated via Integrations context
- Project updates filtered by account_id foreign key
- VS Code extension presence tracked via Phoenix.Presence (no persistence)

## Public API

```elixir
# GitHub Integration
@spec github_connected?(Scope.t()) :: boolean()
@spec connect_github(Scope.t(), redirect_uri :: String.t()) :: {:ok, authorization_url :: String.t()} | {:error, term()}

# Repository Operations
@spec create_code_repo(Scope.t(), project :: Project.t()) :: {:ok, Project.t()} | {:error, term()}
@spec create_docs_repo(Scope.t(), project :: Project.t()) :: {:ok, Project.t()} | {:error, term()}
@spec configure_repositories(Scope.t(), project :: Project.t(), repo_urls :: map()) :: {:ok, Project.t()} | {:error, Changeset.t()}

# Script Generation
@spec generate_setup_script(project :: Project.t()) :: {:ok, script :: String.t()}

# Setup Status
@spec get_setup_status(Scope.t(), project :: Project.t()) :: setup_status()
@spec vscode_extension_connected?(project :: Project.t()) :: boolean()

# Custom Types
@type setup_status :: %{
  github_connected: boolean(),
  code_repo_configured: boolean(),
  docs_repo_configured: boolean(),
  vscode_extension_connected: boolean(),
  setup_complete: boolean()
}
```

## State Management Strategy

### Transient Orchestration
- No dedicated wizard state table - stateless coordination layer
- Delegates to Projects context for repository URL persistence
- Delegates to Integrations context for GitHub OAuth state
- VS Code extension presence tracked via Phoenix.Presence (real-time, no persistence)

### Repository Configuration
- Text field for manual URL entry OR "Create" button for GitHub API creation
- Validates repository URLs before persistence using Git.UrlParser
- GitHub repository creation delegates to GitHub context with Integrations auth
- Both code_repo and docs_repo nullable on Projects schema

### Extension Presence Tracking
- VS Code extension joins VSCodeChannel and registers presence
- Presence.track tracks extension with project_id in metadata
- LiveView subscribes to presence events for real-time status updates
- No database persistence - presence disappears when extension disconnects
- Query presence via Presence.list to check current connection status

## Execution Flow

### GitHub Connection Check
1. **Check Integration**: Call `Integrations.connected?(scope, :github)`
2. **Return Status**: Boolean indicating GitHub connection state

### Initiate GitHub Connection
1. **Generate OAuth URL**: Call `Integrations.authorize_url(scope, :github, redirect_uri)`
2. **Return URL**: Client redirects user to GitHub authorization
3. **Handle Callback**: Standard OAuth flow handled by Integrations context

### Create Code Repository
1. **Validate Connection**: Call `github_connected?(scope)` - error if false
2. **Sanitize Name**: Convert project name to `{sanitized-name}-code`
3. **Build Attributes**: Construct repo attrs with name, description, private: true
4. **Create via API**: Call `GitHub.create_repository(scope, attrs)` (authenticated via Integrations)
5. **Update Project**: Call `Projects.update_project(scope, project, %{code_repo: html_url})`
6. **Return Updated Project**: Provide project with code_repo configured

### Create Docs Repository
1. **Validate Connection**: Call `github_connected?(scope)` - error if false
2. **Sanitize Name**: Convert project name to `{sanitized-name}-docs`
3. **Create Repository**: Call `GitHub.create_repository(scope, attrs)` for blank repo
4. **Initialize Structure**: Create initial commit with:
   - `/content` directory (placeholder README.md)
   - `/design` directory (placeholder README.md)
   - `/rules` directory (placeholder README.md)
   - `.gitignore` (local/, .DS_Store)
5. **Update Project**: Call `Projects.update_project(scope, project, %{docs_repo: html_url})`
6. **Return Updated Project**: Provide project with docs_repo configured

### Configure Repository URLs
1. **Validate URLs**: Parse code_repo and docs_repo URLs using Git.UrlParser
2. **Update Project**: Call `Projects.update_project(scope, project, %{code_repo: url1, docs_repo: url2})`
3. **Return Updated**: Provide updated project to client

### Generate Setup Script
1. **Extract Repository URLs**: Get code_repo and docs_repo from project
2. **Generate Git Checks**: Verify running in git repository root
3. **Generate Submodule Commands**: Build `git submodule add` for code and docs repos (if configured)
4. **Generate Phoenix Project**: Add `mix phx.new` command for creating Phoenix application
5. **Generate Submodule Init**: Add `git submodule update --init --recursive`
6. **Compose Script**: Combine with header, validation, and success messaging
7. **Return Script**: Executable bash script as string

### Track Extension Presence
1. **Extension Joins**: VS Code extension joins VSCodeChannel with project_id
2. **Track Presence**: Channel calls `Presence.track(socket, extension_id, %{project_id: project.id})`
3. **LiveView Subscribes**: Setup wizard LiveView subscribes to presence for project
4. **Presence Events**: handle_info receives {:join, presence} and {:leave, presence}
5. **Update UI**: LiveView updates status indicator in real-time

### Check Extension Connection
1. **List Presences**: Call `Presence.list("vscode:project:#{project.id}")`
2. **Check Empty**: Return false if empty map, true if entries exist
3. **No Database Query**: Entirely in-memory check via Presence

### Get Setup Status
1. **Check GitHub**: Call `Integrations.connected?(scope, :github)`
2. **Check Code Repo**: Verify project.code_repo is not nil
3. **Check Docs Repo**: Verify project.docs_repo is not nil
4. **Check Extension**: Call `vscode_extension_connected?(project)` via Presence
5. **Calculate Complete**: All four checks must pass for setup_complete: true
6. **Return Status Map**: Provide boolean status for each component

## Dependencies
- Integrations
- Projects
- GitHub
- Git

## Components

## Test Strategies

### Fixtures
- **existing_project**: Project fixture without repository configuration
- **github_integrated_user**: User with GitHub integration established
- **github_repo_response**: Recorded GitHub API response for repository creation

### Mocks and Doubles
- Use VCR (ExVCR) to record GitHub API interactions for repository creation
- Create authenticated test session for recording actual GitHub API calls
- Stub Integrations.connected?/2 for unit tests
- Mock Presence.list/1 for extension presence tests
- Mock Presence.track/3 for channel integration tests

### Testing Approach
- Unit tests for script generation (pure functions)
- Integration tests with recorded GitHub API responses (VCR)
- Test scope-based access control for all operations
- Separate integration test suite for authenticated GitHub API recording
- Test presence tracking without persistence

## Test Assertions

- describe "github_connected?/1"
  - test "returns true when GitHub integration exists"
  - test "returns false when no GitHub integration exists"
  - test "respects scope user_id filtering"

- describe "connect_github/2"
  - test "returns authorization URL for GitHub OAuth"
  - test "includes correct redirect_uri in URL"
  - test "delegates to Integrations context"

- describe "create_code_repo/2"
  - test "creates blank GitHub repository with -code suffix"
  - test "updates project.code_repo with repository URL"
  - test "returns updated project"
  - test "returns error when GitHub not connected"
  - test "sanitizes project name for GitHub naming rules"
  - test "uses VCR recording for GitHub API response"
  - test "handles API errors gracefully"

- describe "create_docs_repo/2"
  - test "creates GitHub repository with -docs suffix"
  - test "initializes repo with /content, /design, /rules directories"
  - test "creates .gitignore in repository"
  - test "creates placeholder README.md files in directories"
  - test "updates project.docs_repo with repository URL"
  - test "returns updated project"
  - test "returns error when GitHub not connected"
  - test "uses VCR recording for GitHub API response"

- describe "configure_repositories/3"
  - test "updates project with code_repo URL"
  - test "updates project with docs_repo URL"
  - test "validates repository URLs before saving"
  - test "returns error for invalid URLs"
  - test "respects scope account_id filtering"

- describe "generate_setup_script/1"
  - test "generates bash script with git submodule commands"
  - test "includes Phoenix project creation command"
  - test "includes git submodule initialization"
  - test "handles missing repository URLs gracefully"
  - test "script is idempotent and safe to re-run"
  - test "validates git repository before running"

- describe "vscode_extension_connected?/1"
  - test "returns true when extension present for project"
  - test "returns false when no extension connected"
  - test "queries Presence not database"

- describe "get_setup_status/2"
  - test "returns all true when fully configured"
  - test "returns github_connected false when not integrated"
  - test "returns code_repo_configured false when nil"
  - test "returns docs_repo_configured false when nil"
  - test "returns vscode_extension_connected false when not present"
  - test "returns setup_complete false when any component missing"
  - test "returns setup_complete true when all components present"