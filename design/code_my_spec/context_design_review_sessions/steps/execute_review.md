# ExecuteReview

## Purpose

Generates a comprehensive review command that instructs Claude to analyze Phoenix context documentation and all child component designs holistically. Gathers file paths for context design, child component designs, user stories, and project executive summary, then constructs a detailed prompt that directs Claude to validate architectural compatibility, check for integration issues, fix any issues found, and write a review summary to a specified file path. The review file is written by the client and not validated by the server until the Requirements System checks for its existence.

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

1. **Extract Context Component**: Retrieve the context component from the session
   - Session must have an associated component (the context being reviewed)
   - Return error if component is missing

2. **Get Context Design File Path**: Use `Utils.component_files/2` to determine the context design file path
   - Input: context component and project
   - Output: map containing `:design_file` key with path like `docs/design/code_my_spec/sessions.md`

3. **List Child Components**: Query all components that are children of the context
   - Use `Components.list_child_components/2` with scope and context component ID
   - Returns list of child components (repositories, schemas, liveviews, etc.)

4. **Build Child Component File Paths**: Map each child component to its design file path
   - For each child component, call `Utils.component_files/2`
   - Extract `:design_file` from the result map
   - Results in a list of file paths like `["docs/design/code_my_spec/sessions/sessions_repository.md", ...]`

5. **Get User Stories**: Retrieve all user stories associated with the context
   - Use `Stories.list_component_stories/2` with scope and context component ID
   - Format stories with title, description, and acceptance criteria for inclusion in prompt

6. **Determine Project Executive Summary**: Get from Project object on Session.

7. **Calculate Review File Path**: Derive the review output file path from context design path
   - Place in context directory, name `design_review.md`
   - Example: `docs/design/code_my_spec/sessions.md` → `docs/design/code_my_spec/sessions/design_review.md`

8.  **Build Review Prompt**: Construct comprehensive prompt containing:
   - Project name and description
   - Context name, description, and type
   - Context design file path for reading
   - List of child component design file paths
   - Formatted user stories the context satisfies
   - Project executive summary file path
   - Instructions to:
     - Read all design files to understand architecture
     - Validate consistency between context and child components
     - Check for missing dependencies or integration issues
     - Verify alignment with user stories and project goals
     - Fix any issues found in the design documents
     - Write comprehensive review summary to specified review file path
   - Review file output path

9.  **Create Agent Command**: Build command using agent helper
    - Use `Helpers.build_agent_command/5` with:
      - Step module: `__MODULE__`
      - Agent type: `:context_reviewer`
      - Agent name: `"context-design-reviewer"`
      - Prompt: the constructed review prompt
      - Options: passed through from orchestrator
    - Returns `{:ok, Command.t()}`

### handle_result/3

1. **Pass-through Result**: Return session updates as empty map and result unchanged
   - No session state modifications needed
   - Result status and output determined by agent execution
   - Returns `{:ok, %{}, result}`
