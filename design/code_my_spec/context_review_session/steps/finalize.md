# Finalize

## Purpose

Completes the context review session by executing git add for the review file and marking the session status as complete. This step finalizes the review workflow by staging the generated review document for commit.

## Public API

```elixir
# StepBehaviour callbacks
@spec get_command(scope :: Scope.t(), session :: Session.t(), opts :: keyword()) ::
  {:ok, Command.t()} | {:error, String.t()}

@spec handle_result(scope :: Scope.t(), session :: Session.t(), result :: Result.t(), opts :: keyword()) ::
  {:ok, session_updates :: map(), updated_result :: Result.t()} | {:error, String.t()}
```

## Execution Flow

### Command Generation (get_command/3)

1. **Extract Review File Path**: Retrieve review_output_path from session.state
   - The ExecuteReview step stored this path in the session state
   - Path format: `docs/review/{context_name}_context_review.md`
   - Validate path exists in state, return error if missing
2. **Verify Review File Exists**: Check file existence before staging
   - Use File.exists?/1 to verify review document was created
   - If file missing, return {:error, "Review file not found at {path}"}
   - This catches cases where ExecuteReview step failed to generate output
3. **Extract Working Directory**: Get working_dir from session.state or default to "docs"
   - The working directory is where git operations will be executed
4. **Calculate Relative File Path**: Strip project root to get relative path
   - Remove leading path segments to get path relative to working_dir
   - Example: "/project/docs/review/file.md" → "review/file.md"
5. **Get Environment**: Extract environment from session
   - Environment determines command format (VSCode vs Local)
   - Use session.environment field
6. **Build Command Attributes**: Construct attribute map containing:
   - `working_dir`: "docs" (where git operations execute)
   - `review_file_name`: Relative path to review file
7. **Generate Git Command**: Use Environments.docs_environment_teardown_command/2
   - Pass environment and attributes
   - Returns environment-specific git add command
   - VSCode environment: Simple git add without commit/merge
   - Local environment: May include commit and merge operations
8. **Build Command Struct**: Create Command with:
   - `module`: __MODULE__
   - `command`: Git command string from step 7
   - `metadata`: %{review_file_path: full_path, working_dir: working_dir}
9. **Return Command**: Return {:ok, command} tuple

### Result Processing (handle_result/4)

1. **Check Result Status**: Verify git command succeeded
   - If result.status is :error, return error to retry
   - Extract error message from result.stderr or result.error_message
2. **Prepare Session Updates**: Build map containing:
   - `status`: :complete (mark session as successfully completed)
   - `state`: Merge with existing state, adding:
     - `finalized_at`: DateTime.utc_now()
     - `git_status`: "staged" or command exit code
3. **Update Result**: Keep result as-is for audit trail
4. **Return Updates**: Return {:ok, session_updates, result} tuple

## Error Handling

### Command Generation Errors
- **Missing review_output_path**: Return {:error, "Review output path not found in session state"} if state missing key
- **Review file not found**: Return {:error, "Review file not found at {path}"} if File.exists? returns false
- **Invalid working directory**: Return {:error, "Invalid working directory"} if working_dir is nil or invalid
- **Missing environment**: Return {:error, "Environment not specified in session"} if session.environment is nil

### Result Processing Errors
- **Git command failure**: Return {:error, "Failed to stage review file: {stderr}"} if git add fails
- **Non-zero exit code**: Return {:error, "Git command failed with code {code}"} if command exits with error

### Recovery
- If git add fails due to file not existing, the orchestrator will keep the session in error state
- Human intervention required to investigate why review file is missing
- Session remains in active state until successful completion

## Dependencies

- Sessions (session state management)
- Environments (environment-specific command generation)
- File (file existence validation)
- CodeMySpec.Utils (for path manipulation if needed)

## Notes

### Minimal Finalization
Unlike ComponentDesignSessions or ContextComponentsDesignSessions which create pull requests, this step performs minimal finalization:
- Only stages the review file with git add
- Does not commit, merge, or create PRs
- This allows the review document to be committed alongside other design changes

### Environment-Specific Behavior
The behavior varies by environment:
- **VSCode**: Simple git add, expecting user to commit manually
- **Local**: May include automatic commit and merge to main branch

### Integration with Parent Workflow
This session is typically spawned from ContextComponentsDesignSessions:
- Parent session waits for review completion
- Parent session's Finalize step will include review document in final PR
- This ensures review is part of the complete design documentation package

### State Dependencies
The session state must contain:
- `review_output_path`: Set by ExecuteReview step or Initialize step
- `context_name`: Used for error messages and logging
- `working_dir`: Optional, defaults to "docs"
