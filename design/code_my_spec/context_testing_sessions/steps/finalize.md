# Finalize

## Purpose

Completes the context testing session by collecting test files from all child ComponentTestingSession workflows, committing them to git, pushing the test branch to remote, and marking the session as complete. Implements StepBehaviour to orchestrate the final git operations that persist all test artifacts generated during the context testing workflow.

## Public API

```elixir
# StepBehaviour callbacks
@spec get_command(Scope.t(), Session.t(), keyword()) :: {:ok, Command.t()} | {:error, String.t()}
@spec handle_result(Scope.t(), Session.t(), Result.t(), keyword()) :: {:ok, map(), Result.t()}
```

## Execution Flow

### get_command/3
1. **Extract Context Component**: Retrieve the context component from the session (errors if nil)
2. **Validate Child Sessions**: Verify that child sessions exist (errors if empty or nil)
3. **Collect Test Files**: Gather all test file paths from child ComponentTestingSession records
   - For each child session, load the associated component with preloaded project
   - Use `CodeMySpec.Utils.component_files/2` to get test file path
   - Accumulate all test file paths into a list
4. **Extract Branch Name**: Retrieve branch name from `session.state.branch_name` (set by Initialize step)
5. **Build Git Command**: Construct multi-step git command:
   - `git add <test_files>` - Stage all test files
   - `git commit -m "..."` - Commit with structured message using HEREDOC
   - `git push -u origin <branch_name>` - Push to remote branch
6. **Create Command Struct**: Build Command with metadata containing branch name and file count
7. **Return Success**: Return `{:ok, command}`

### handle_result/4
**Success Path (status: :ok)**
1. **Mark Session Complete**: Create session_updates map with `status: :complete`
2. **Return Success**: Return `{:ok, session_updates, result}`

**Error Path (status: :error)**
1. **Update Session State**: Merge finalized_at timestamp and error message into session state
2. **Mark Session Failed**: Create session_updates with `status: :failed` and updated state
3. **Return Success with Failed Status**: Return `{:ok, session_updates, result}`

## Test Assertions

- describe "get_command/3"
  - test "returns git command with all test files from child sessions"
  - test "includes proper commit message with context name and component list"
  - test "uses branch name from Utils.branch_name/1"
  - test "returns error when context component is nil"
  - test "returns error when context component_id is nil"
  - test "returns error when child_sessions is empty"
  - test "returns error when child_sessions is nil"
  - test "includes metadata with branch_name and committed_files count"
  - test "collects test files from multiple child sessions correctly"
  - test "preloads component and project associations for each child session"

- describe "handle_result/4"
  - test "marks session as complete when result status is ok"
  - test "returns session_updates with status complete on success"
  - test "marks session as failed when result status is error"
  - test "adds finalized_at timestamp to session state on error"
  - test "preserves existing session state when merging error data"
  - test "includes error message in session state on failure"
  - test "returns ok tuple even when marking session as failed"
