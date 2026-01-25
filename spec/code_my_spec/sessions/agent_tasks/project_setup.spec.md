# CodeMySpec.Sessions.AgentTasks.ProjectSetup

**Type**: module

Agent task that guides developers through complete Phoenix project setup for CodeMySpec integration. Generates comprehensive setup instructions and evaluates current setup state by checking prerequisites, project structure, and dependencies. Designed to be run from a target directory that will become (or already is) a Phoenix project root.

The agent approach (vs running the ScriptGenerator script directly) allows picking up setup from any point and provides flexibility for the agent to adapt to different starting states.

## Functions

### command/3

Generate setup instructions for the agent based on current environment state.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:
1. Extract environment from session to access filesystem and run commands
2. Call `check_status/2` to get current setup state as structured map
3. Build comprehensive prompt containing:
   - Current setup status summary showing completed vs pending items
   - Prerequisites section covering Elixir 1.18+, Phoenix installer, PostgreSQL
   - Phoenix project creation via `mix phx.new` if no project exists
   - CodeMySpec dependencies block to add to mix.exs:
     - `{:ngrok, git: "https://github.com/johns10/ex_ngrok", branch: "main", only: [:dev]}`
     - `{:exunit_json_formatter, git: "https://github.com/johns10/exunit_json_formatter", branch: "master"}`
     - `{:credo, "~> 1.7.13"}`
   - Documentation directory structure setup
4. Customize instructions to skip completed steps based on check_status results
5. Include verification commands after each major step
6. Return prompt that enables agent to complete remaining setup autonomously

**Test Assertions**:
- returns full setup guide when starting from empty directory
- returns partial guide omitting completed steps
- includes prerequisite installation when elixir_installed is false
- includes Phoenix installer setup when phoenix_installer_available is false
- includes project creation when phoenix_project_exists is false
- includes dependency block when codemyspec_deps_installed is false
- includes docs setup when docs_repo_configured is false

### evaluate/3

Evaluate current environment and report detailed setup completion status.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) ::
  {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Call `check_status/2` to get structured status map
2. If all required checks pass, return `{:ok, :valid}`
3. If any required check fails, return `{:ok, :invalid, feedback}` with:
   - Summary of setup progress (X of Y steps complete)
   - List of passing checks
   - List of failing checks with specific remediation hints
   - Suggested next action

**Test Assertions**:
- returns valid when all required checks pass
- returns invalid with detailed feedback when checks fail
- feedback includes progress summary
- feedback includes specific remediation for each failing check

### check_status/2

Check current environment and return structured status map. Helper used by both command/3 and evaluate/3.

```elixir
@spec check_status(Environment.t(), map()) :: map()
```

**Process**:
1. Determine working directory from environment
2. Check system prerequisites:
   - Run `elixir --version`, parse output, verify >= 1.18
   - Run `mix archive` and check for phx_new presence
   - Optionally check PostgreSQL with `psql --version` (warn only)
3. Check Phoenix project existence:
   - Verify mix.exs exists in working directory
   - Verify lib/ directory exists
   - Verify config/ directory exists
   - Extract app_name from mix.exs project definition
4. If Phoenix project exists, check compilation:
   - Run `mix compile` and check exit code
   - Capture any compilation errors for feedback
5. Check CodeMySpec dependencies in mix.exs:
   - Parse deps function for :ngrok
   - Parse deps function for :client_utils
   - Parse deps function for :credo
   - Parse deps function for :mix_machine
   - Parse deps function for :sobelow
6. Check documentation directory setup:
   - Verify docs/ directory exists
   - Verify docs/rules/ directory exists
   - Verify docs/spec/ directory exists
   - Verify docs/spec/{app_name}/ directory exists
   - Verify docs/spec/{app_name}_web/ directory exists
7. Return structured map with all check results:
   - elixir_installed: boolean
   - elixir_version: string or nil
   - phoenix_installer_available: boolean
   - postgresql_available: boolean (warning only)
   - phoenix_project_exists: boolean
   - app_name: string or nil
   - project_compiles: boolean
   - compilation_errors: string or nil
   - codemyspec_deps_installed: boolean
   - missing_deps: list of atoms
   - docs_repo_configured: boolean
   - docs_structure_complete: boolean
   - missing_docs_dirs: list of strings

**Test Assertions**:
- returns elixir_installed false when Elixir version < 1.18
- returns phoenix_installer_available false when phx_new not in archives
- returns phoenix_project_exists false when mix.exs missing
- returns project_compiles false with errors when compilation fails
- returns codemyspec_deps_installed false with missing_deps list
- returns docs_repo_configured false when docs directory missing
- returns docs_structure_complete false with missing_docs_dirs list
- extracts app_name from mix.exs project definition
- handles missing mix.exs gracefully
- warns but does not fail on PostgreSQL check failure

## Dependencies

- CodeMySpec.Environments
