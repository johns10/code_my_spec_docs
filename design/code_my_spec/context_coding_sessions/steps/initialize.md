# Initialize

## Purpose

Prepares the development environment for context-wide implementation by creating a git branch for the coding session, and setting up the working directory at the project root for code implementation.

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

1. **Generate Branch Name**: Use `Utils.branch_name/1` to create sanitized branch name:
   - Convert context component name to lowercase
   - Replace non-alphanumeric characters (except hyphens/underscores) with hyphens
   - Collapse multiple consecutive hyphens
   - Trim leading/trailing hyphens
   - Prefix with `"code-context-coding-session-for-"`

2. **Build Environment Attributes**: Construct map with:
   - `branch_name`: Sanitized branch name from step 1
   - `repo_url`: From `session.project.code_repo`
   - `working_dir`: Set to `"."` for project root (implementing code, not docs)

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

1. **Extract Branch Name**: Get branch name from session using `Utils.branch_name/1`

2. **Build Session Updates**: Create session updates map:
   - `:state` - Merge existing session state with new metadata:
     - `branch_name`: Sanitized branch name for use by Finalize step
     - `initialized_at`: Current UTC timestamp

3. **Return Updates**: Return `{:ok, session_updates, result}` tuple:
   - Session updates will be persisted by orchestrator
   - Result is passed through unchanged for status tracking

## Test Assertions

- describe "get_command/3"
  - test "generates sanitized branch name from context component name"
  - test "uses project code_repo URL from session"
  - test "sets working_dir to project root (.)"
  - test "creates branch name with code-context-coding-session-for- prefix"
  - test "sanitizes component name by replacing special characters with hyphens"
  - test "collapses multiple consecutive hyphens in branch name"
  - test "trims leading and trailing hyphens from branch name"
  - test "converts component name to lowercase for branch name"

- describe "handle_result/4"
  - test "stores branch name in session state"
  - test "stores initialized_at timestamp in session state"
  - test "merges with existing session state without overwriting"
  - test "returns result unchanged"
  - test "returns success tuple with session updates"
