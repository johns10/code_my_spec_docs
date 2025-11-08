# Finalize

## Purpose

Completes the context coding session by committing all implementation code from child ComponentCodingSession workflows, pushing the implementation branch to remote, and marking the session as complete. This step consolidates all component implementations and test files created during the context-wide coding workflow into a single commit ready for pull request creation.

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

1. **Extract Branch Name**: Retrieve branch name from `session.state.branch_name`
   - Return `{:error, "Branch name not found in session state"}` if missing
   - Branch was created and stored by Initialize step

2. **Load Context Component**: Retrieve the context component from `session.component_id`
   - Return `{:error, "Context component not found in session"}` if component is missing
   - Context component represents the Phoenix context being implemented

3. **Query Child Sessions**: Load all child ComponentCodingSession records
   - Filter by `parent_session_id = session.id`
   - Use Sessions context to retrieve child sessions with scope
   - Return `{:error, "No child sessions found"}` if no children exist

4. **Collect Implementation Files**: For each child session:
   - Load component from child session's component_id
   - Use `Utils.component_files/2` to get code_file and test_file paths
   - Strip project root prefix to create relative paths from project directory
   - Collect into two lists: code_files and test_files

5. **Build Commit Message**: Construct multi-line commit message:
   - Title: "Implement {context_name} context"
   - Body: List of implemented components (one per line)
   - Footer: Standard Claude Code attribution and co-authorship

6. **Generate Git Command**: Build shell command string to:
   - Add all implementation files: `git add {code_files...}`
   - Add all test files: `git add {test_files...}`
   - Commit with heredoc message: `git commit -m "$(cat <<'EOF'\n{commit_message}\nEOF\n)"`
   - Push to remote: `git push -u origin {branch_name}`

7. **Build Command**: Create Command struct using session helpers:
   - `module`: __MODULE__
   - `command`: Git command string from step 6
   - `metadata`: %{branch_name: branch_name, committed_files: file_count}

8. **Return Command**: Return `{:ok, command}` tuple

### handle_result/4

1. **Check Result Status**: Determine if git operations succeeded
   - If result.status is `:error` → handle failure path
   - If result.status is `:ok` → handle success path

2. **Handle Error Result**: If git operations failed:
   - Update session status to `:failed`
   - Add error details to session state:
     - `finalized_at`: Current UTC timestamp
     - `error`: Error message from result
   - Return `{:ok, session_updates, result}`

3. **Handle Success Result**: If git operations succeeded:
   - Update session status to `:complete`
   - Merge session state with finalization metadata:
     - `finalized_at`: Current UTC timestamp
     - `committed_at`: Current UTC timestamp
     - `files_committed`: Count of files committed
   - Return `{:ok, session_updates, result}`

4. **Session Updates Map**: Build session updates containing:
   - `:status` - Set to `:complete` (success) or `:failed` (error)
   - `:state` - Merge existing state with finalization timestamps and metadata

## Error Handling

- **Missing branch name**: Return `{:error, "Branch name not found in session state"}` if session.state.branch_name is nil
- **Missing context component**: Return `{:error, "Context component not found in session"}` if session.component_id is nil
- **No child sessions**: Return `{:error, "No child sessions found"}` if no ComponentCodingSession children exist
- **Incomplete child sessions**: This should not occur as SpawnComponentCodingSessions.handle_result/4 validates all children are complete before proceeding to Finalize
- **Git add failures**: Result status will be `:error`, handle_result marks session as `:failed`
- **Git commit failures**: Result status will be `:error`, handle_result marks session as `:failed` with commit error details
- **Git push failures**: Result status will be `:error`, handle_result marks session as `:failed` with push error details
- **Missing implementation files**: Git add will fail if files don't exist (SpawnComponentCodingSessions.handle_result/4 validation should prevent this)

## Dependencies

- Sessions
- Components
- Utils

## Notes

- The Finalize step assumes SpawnComponentCodingSessions.handle_result/4 has verified all child sessions completed successfully
- All implementation files (code and tests) are committed together in a single atomic commit
- Branch is pushed to remote with `-u` flag to set up tracking relationship
- The commit message lists all implemented components for clear audit trail
- Session status is updated to `:complete` on success to signal end of context coding workflow
- Session state tracks finalization timestamp and commit metadata for reporting
- Unlike component-level finalize steps, this consolidates multiple component implementations
- The branch created by Initialize step is now ready for pull request creation (could be done by parent session or manual step)
- Git command execution happens in project root working directory
- Uses heredoc for commit message to ensure proper formatting and avoid shell escaping issues
- Child session count and file count should match component count (each component has one code file and one test file)

## Test Assertions

- describe "get_command/3"
  - test "returns git command with all child component files when child sessions exist"
  - test "includes code files and test files from all child components"
  - test "generates proper commit message with context name and component list"
  - test "includes git push command with branch name from session state"
  - test "strips project root from file paths for relative paths"
  - test "returns error when branch_name not in session state"
  - test "returns error when context component not found"
  - test "returns error when no child sessions exist"
  - test "returns error when session.component_id is nil"

- describe "handle_result/4"
  - test "marks session as complete when git operations succeed"
  - test "adds finalized_at timestamp to session state on success"
  - test "adds committed_at timestamp to session state on success"
  - test "adds files_committed count to session state on success"
  - test "marks session as failed when git add fails"
  - test "marks session as failed when git commit fails"
  - test "marks session as failed when git push fails"
  - test "includes error details in session state when operations fail"
  - test "preserves existing session state when updating"
  - test "returns updated result unchanged"
