# Finalize

## Purpose

Completes the context components design session by creating a pull request with all generated design documentation. Collects all child component design files and the optional review document, commits them to the branch, pushes to remote, and creates a pull request for architectural review.

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

1. **Load Context Component**: Retrieve the context component from session.component_id
2. **Extract Child Components**: Get child component list from session.state.components (populated by Initialize step)
3. **Build Design File Paths**: For each child component:
   - Load full component record from Components context using component.id
   - Use Utils.component_files/2 to get design_file path for each child component
   - Strip project root prefix to create relative paths from docs directory
   - Collect into list of design file paths
4. **Check for Review Document**: Check if session.state.review_session_id exists:
   - If present, construct review document path: `docs/review/{context_name}_components_review.md`
   - Add to list of files to commit
5. **Generate Branch Name**: Create sanitized branch name using format:
   - Convert context component name to lowercase
   - Replace non-alphanumeric characters (except hyphens/underscores) with hyphens
   - Collapse multiple consecutive hyphens
   - Trim leading/trailing hyphens
   - Prefix with `"docs-context-components-design-session-for-"`
6. **Prepare PR Attributes**: Construct attribute map containing:
   - `branch_name`: Sanitized branch name from step 5
   - `working_dir`: Set to "docs" for design documentation
   - `design_file_paths`: List of relative design file paths from step 3
   - `review_file_path`: Optional review document path from step 4 (if exists)
   - `context_name`: Context component name for commit message
   - `pr_title`: "Add component designs for {context_name} context"
   - `pr_body`: Multi-line string containing:
     - Summary of generated component designs (count and list)
     - Note about review document if present
     - Generated with Claude Code footer
7. **Generate PR Command**: Build shell command string to:
   - Add all design files: `git -C docs add {design_file_paths...}`
   - Add review file if present: `git -C docs add {review_file_path}`
   - Commit with message: `git -C docs commit -m "Add component designs for {context_name} context"`
   - Push to remote: `git -C docs push -u origin {branch_name}`
   - Create PR: `gh pr create --title "{pr_title}" --body "{pr_body}"`
8. **Build Command**: Create Command struct:
   - `module`: __MODULE__
   - `command`: PR command string from step 7
   - `metadata`: %{branch_name: branch_name, pr_url: nil} (pr_url populated by client after execution)
9. **Return Command**: Return {:ok, command} tuple

### Result Processing (handle_result/4)

1. **Extract PR URL**: Parse PR URL from result output (gh pr create returns PR URL)
2. **Update Session Status**: Prepare session updates:
   - `status`: :complete (mark session as successfully completed)
   - `state`: Merge with existing state, adding:
     - `pr_url`: Extracted PR URL from step 1
     - `finalized_at`: Current UTC timestamp
3. **Prepare Session Updates**: Build map containing updated status and state
4. **Return Updates**: Return {:ok, session_updates, result} tuple

## Error Handling

- **Missing context component**: Return {:error, "Context component not found in session"} if session.component_id is nil
- **No child components**: Return {:error, "No child components to finalize"} if session.state.components is empty
- **Missing design files**: Log warning but continue (PR can be created with partial files)
- **Git command failures**: Return {:error, reason} with git error message
- **PR creation failure**: Return {:error, reason} with gh CLI error message
- **Invalid branch name**: Return {:error, "Invalid branch name"} if sanitization fails

## Dependencies

- Sessions
- Components
- Utils
- Environments (for environment-specific command generation)
- Git CLI (for commit and push operations)
- GitHub CLI (gh) (for PR creation)

## Notes

- The Finalize step assumes all child component design sessions have completed successfully (validated by ValidateComponentDesigns step)
- The review session is optional - PR creation proceeds whether or not review was performed
- PR body should provide clear context for human reviewers about the scope and purpose of the generated designs
- Branch naming follows the same convention as Initialize step to ensure consistency
- The command execution happens in the "docs" working directory, isolating documentation changes from code changes
