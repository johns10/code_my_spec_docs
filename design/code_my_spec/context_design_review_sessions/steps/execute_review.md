# ExecuteReview

## Purpose

Generates a comprehensive review command that instructs Claude to analyze context design, child component designs, user stories, and project executive summary. Composes a structured prompt with file paths and validation criteria, then returns a Command struct for AI agent execution. Claude reads the files, validates architectural compatibility, checks for integration issues, and writes findings to the specified review file path.

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

1. **Load Session State**: Extract review-related paths from session.state:
   - `context_design_path` - absolute path to context design document
   - `child_component_paths` - list of component design file paths with metadata
   - `user_story_paths` - list of user story file paths (if available)
   - `executive_summary_path` - path to project executive summary
   - `review_output_path` - where Claude should write review findings

2. **Load Review Rules**: Query Rules context for rules matching:
   - session_type: "review" or "*"
   - component_type: session.component.type or "*"
   - Concatenate rule content with appropriate separators

3. **Compose Review Prompt**: Build comprehensive prompt including:
   - **Header**: "You are conducting an architectural review of a Phoenix context and its child components."
   - **Objective**: "Validate architectural compatibility, identify integration issues, verify requirement alignment, and ensure Phoenix best practices."
   - **Context Design Section**:
     - "Read the context design at: `{context_design_path}`"
     - "Analyze the context's purpose, API boundaries, and architectural decisions"
   - **Child Components Section**:
     - For each child component: "Read component `{name}` design at: `{path}`"
     - "Validate each component integrates properly with the context"
     - "Check for dependency conflicts or circular dependencies"
   - **User Stories Section** (if available):
     - "Review user stories at: `{story_paths}`"
     - "Verify that component designs address all story requirements"
   - **Executive Summary Section** (if available):
     - "Review project context at: `{executive_summary_path}`"
     - "Ensure designs align with project goals and constraints"
   - **Review Criteria**:
     - Context boundary coherence and separation of concerns
     - Component dependency resolution and order
     - Data flow patterns and consistency
     - Error handling strategy alignment
     - Test coverage feasibility
     - Phoenix/Elixir conventions and best practices
     - Public API design and usability
   - **Output Instructions**:
     - "Write your findings to: `{review_output_path}`"
     - "Structure your review with these sections:"
       - "## Executive Summary: 2-3 sentence overview"
       - "## Issues: Blocking problems that must be fixed (numbered list)"
       - "## Warnings: Concerns or potential problems (numbered list)"
       - "## Recommendations: Suggested improvements (numbered list)"
     - "At the end include: `Issues Found: N` and `Warnings Found: M`"
   - **Review Rules**: Append concatenated rules from step 2

4. **Create AI Agent Command**: Build Command struct:
   - module: `__MODULE__`
   - command: "claude"
   - metadata:
     - prompt: composed review prompt from step 3
     - options: %{model: "claude-3-5-sonnet-20241022"}
     - review_output_path: for verification in handle_result

5. **Return Command**: Return `{:ok, command}` tuple

### Result Processing (handle_result/4)

1. **Check Result Status**: Examine result.status
   - If `:error` → return `{:error, result.error_message}` (orchestrator will retry or fail)
   - If `:warning` → proceed but note warning in session state
   - If `:ok` → continue validation

2. **Verify Review File Created**: Extract review_output_path from command metadata
   - Check if file exists at review_output_path using File.exists?/1
   - If missing → return `{:error, "Review file not created at #{review_output_path}"}`

3. **Parse Review Metadata** (optional): Attempt to extract issue/warning counts
   - Read review file content
   - Search for "Issues Found: N" and "Warnings Found: M" patterns
   - Store counts in session state for reporting (not required for success)

4. **Build Session Updates**: Create map with review completion data:
   - `review_completed_at`: DateTime.utc_now()
   - `review_file_path`: review_output_path
   - `issues_found`: extracted count or nil
   - `warnings_found`: extracted count or nil

5. **Return Success**: Return `{:ok, session_updates, result}` tuple
   - Session updates merged into session.state
   - Orchestrator proceeds to next step (Finalize)

## Error Handling

### Command Generation Errors
- **Missing session state**: Return `{:error, "Required paths not found in session state"}` if context_design_path or review_output_path are missing
- **Invalid component**: Return `{:error, "Session component not loaded"}` if session.component is nil or not loaded
- **Rules query failure**: Log warning and proceed with empty rules (not a blocking error)

### Result Processing Errors
- **Agent execution failed**: Return `{:error, result.error_message}` - orchestrator retries or presents to user
- **Review file missing**: Return `{:error, "Review file not created"}` - indicates agent didn't complete task
- **File system errors**: Return `{:error, "Could not verify review file: #{reason}"}` - requires investigation

### Human Intervention Points
When handle_result returns an error:
- Client presents error message to user
- User can: retry step, manually create review file, or cancel session
- Orchestrator waits for user decision before proceeding

## Dependencies

- Sessions (for accessing session state and component)
- Rules (for loading review-specific rules)
- Command (for building AI agent commands)
- File (stdlib - for verifying review file existence)
