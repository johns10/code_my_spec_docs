# Initialize

## Purpose

Prepares the development environment for context-wide test generation by creating a git branch for the testing session and setting up the working directory at the project root. Component data is queried on-demand by subsequent steps rather than stored in session state.

## Public API

```elixir
# StepBehaviour callbacks
@spec get_command(scope :: Scope.t(), session :: Session.t(), opts :: keyword()) ::
  {:ok, Command.t()} | {:error, String.t()}

@spec handle_result(scope :: Scope.t(), session :: Session.t(), result :: Result.t(), opts :: keyword()) ::
  {:ok, session_updates :: map(), updated_result :: Result.t()} | {:error, String.t()}
```

## Execution Flow

### get_command/3

1. **Generate Branch Name**: Use `ContextTestingSessions.Utils.branch_name/1` to create sanitized branch name:
   - Convert context component name to lowercase
   - Replace non-alphanumeric characters (except hyphens/underscores) with hyphens
   - Collapse multiple consecutive hyphens
   - Trim leading/trailing hyphens
   - Prefix with `"test-context-testing-session-for-"`

2. **Build Environment Attributes**: Construct map with:
   - `branch_name`: Sanitized branch name from step 1
   - `repo_url`: From `session.project.code_repo`
   - `working_dir`: Set to `"."` for project root (writing test files to test directory)

3. **Generate Setup Command**: Delegate to `Environments.environment_setup_command/2`:
   - For `:local` environment: Clone repo, switch to new branch, install dependencies
   - For `:vscode` environment: Switch to new branch in existing workspace
   - Command string handles git operations and dependency installation

4. **Create Command**: Build Command struct using `Command.new/2`:
   - `module`: `__MODULE__` (reference to this step module)
   - `command`: Command string from step 3
   - Command includes automatic timestamp from Command.new

5. **Return Command**: Return `{:ok, command}` tuple for execution

### handle_result/4

1. **Return Empty Updates**: Return `{:ok, %{}, result}` tuple:
   - No session state updates required
   - Subsequent steps query component data on-demand from the database
   - Result is passed through unchanged for status tracking

## Test Assertions

- describe "get_command/3"
  - test "generates sanitized branch name from context component name"
  - test "uses project code_repo URL from session"
  - test "sets working_dir to project root (.)"
  - test "creates branch name with test-context-testing-session-for- prefix"
  - test "sanitizes component name by replacing special characters with hyphens"
  - test "collapses multiple consecutive hyphens in branch name"
  - test "trims leading and trailing hyphens from branch name"
  - test "converts component name to lowercase for branch name"
  - test "delegates to Environments.environment_setup_command/2"
  - test "returns Command struct with module reference"
  - test "returns error when session missing project.code_repo"

- describe "handle_result/4"
  - test "returns empty session updates map"
  - test "returns result unchanged"
  - test "returns success tuple with empty updates"
