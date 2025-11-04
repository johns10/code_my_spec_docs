# ExecuteReview

## Purpose

Creates a comprehensive review command that sends Claude a prompt with file paths to context design, child component designs, user stories, and project executive summary. Instructs Claude to review documents holistically, validate architectural compatibility, check for integration issues, fix any issues found, and write review findings to a specified review file path.

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

1. **Load Session with Associations**: Preload session with project, component, and child_sessions
   - Use Sessions.get_session(scope, session.id) with appropriate preloads
   - Ensures access to context component, project description, and child session data
2. **Load Context Component**: Extract context component from session.component_id
   - This is the parent context being reviewed
   - Use component.name, component.module_name to build file paths
3. **Build Context Design File Path**: Calculate context design document path
   - Use Utils.component_files/2 to get design_file path for context component
   - Example: `docs/design/code_my_spec/context_review_sessions.md`
4. **Build Child Component Design Paths**: For each child_session in session.child_sessions:
   - Preload child_session.component
   - Use Utils.component_files/2 to get design_file path
   - Build summary map: %{component_id: id, name: name, module_name: module, type: type, design_path: path}
   - AI agent will read these files during review workflow
5. **Load User Stories**: Query project stories for context
   - Use Stories.list_project_stories(scope) to get all stories for current project
   - Filter stories relevant to the context being reviewed (stories linked to context component or child components)
   - Build story summary list with id, title, description, acceptance_criteria
6. **Get Project Executive Summary**: Extract project description
   - Access session.project.description
   - This provides high-level context for architectural review
7. **Determine Review Output Path**: Calculate review document path
   - Convention: `docs/review/{context_name}_review.md`
   - Example: `docs/review/context_review_sessions_review.md`
   - Store in session state for later validation
8. **Build Review Prompt**: Compose comprehensive prompt with:
   - Project name and description (executive summary)
   - Context design file path
   - List of child component design file paths with component names and types
   - User story summaries
   - Instructions to:
     - Read all referenced design files
     - Validate architectural compatibility across components
     - Check for integration issues, missing dependencies, inconsistencies
     - Verify alignment with user stories and project requirements
     - Fix any issues found in the design files
     - Write review summary with findings to review output path
9. **Generate Agent Command**: Use Helpers.build_agent_command/5:
   - Module: __MODULE__
   - Agent type: :context_reviewer
   - Agent name: "context-design-reviewer"
   - Prompt: Built review prompt from step 8
   - Options: Pass through opts from orchestrator
10. **Return Command**: Return {:ok, command} tuple

### Result Processing (handle_result/4)

This step validates that Claude successfully completed the review and wrote the review document.

1. **Check Result Status**: Examine result.status
   - If status is :error → return {:error, result.error_message}
   - If status is :ok → proceed to validation
2. **Verify Review Document Exists**: Check for review output file
   - Get review_output_path from session.state
   - Check file existence with File.exists?/1
   - If file missing → return {:error, "Review document missing at [path]"}
3. **Read Review Document**: Load and validate review content
   - Use File.read!/1 to read review document
   - Check that file is not empty (byte_size > 0)
   - If empty → return {:error, "Review document is empty at [path]"}
4. **Update Session State**: Store review completion metadata
   - Add review_completed_at timestamp
   - Add review_file_path to state
   - Return session state updates
5. **Build Success Result**: If all validations pass
   - Return {:ok, session_updates, result}
   - Orchestrator proceeds to finalize step
6. **Build Error Result**: If any validation fails
   - Return {:error, detailed_error_message}
   - Orchestrator retries or requires human intervention

## Error Handling

### Command Generation Errors

- **Missing context component**: Return {:error, "Context component not found in session"} if session.component_id is nil or invalid
- **No child sessions**: Return {:error, "No child sessions found to review"} if session.child_sessions is empty
- **Missing project**: Return {:error, "Project not found in session"} if session.project is nil
- **Agent command creation failure**: Return {:error, reason} if Helpers.build_agent_command/5 fails

### Result Processing Errors

- **Command execution failed**: Return {:error, result.error_message} if result.status is :error
- **Missing review document**: Return {:error, "Review document not found at [path]"} if File.exists?/1 returns false
- **Empty review document**: Return {:error, "Review document is empty at [path]"} if file exists but has no content
- **File read error**: Return {:error, "Failed to read review document: [reason]"} if File.read!/1 raises exception

### Human Intervention Points

When handle_result returns an error, the client should present:
- Result status and any error messages from Claude
- Expected review document path
- Suggested actions: retry review, manually create review document, inspect design files for issues, or skip review

## Dependencies

- Sessions (for loading session with associations)
- Sessions.SessionsRepository (for get_session_with_children/2)
- Components (for loading context and child components)
- Stories (for loading project user stories)
- Rules (for loading review rules - optional, if review rules are implemented)
- Utils (for calculating file paths via component_files/2)
- File (for checking review document existence and reading content)
- Sessions.Steps.Helpers (for building agent commands)

## Notes

### Review Scope and Depth

The ExecuteReview step orchestrates a holistic architectural review that:
- Validates consistency across all component designs in the context
- Checks for missing dependencies between components
- Verifies architectural patterns align with Phoenix/Elixir best practices
- Ensures user stories are adequately addressed by designed components
- Identifies integration issues before implementation begins
- The review agent has autonomy to fix issues directly in design files

### Review Output Format

The review document written to `docs/review/{context_name}_review.md` should follow a structured format:
- Executive Summary: High-level assessment of design quality
- Architectural Consistency: Validation of context boundaries and component interactions
- Dependency Analysis: Verification of component dependencies and data flow
- Story Coverage: Mapping of user stories to implementing components
- Issues Found: List of problems identified with severity levels
- Fixes Applied: Description of corrections made to design files
- Recommendations: Suggestions for further improvements

### Validation Philosophy

This step follows the "trust but verify" pattern:
- Trusts Claude to execute the review and fix issues autonomously
- Verifies the review was completed by checking for output file
- Validates the output is substantive (not empty)
- Does not validate review content quality (assumes agent expertise)
- Relies on subsequent steps (finalize) to commit results to version control

### Integration with ContextReviewSessions Workflow

ExecuteReview is the primary step in the ContextReviewSessions workflow:
1. ExecuteReview generates and executes the comprehensive review command
2. Upon success, the review document exists with findings and applied fixes
3. Finalize step commits the review document to git and marks session complete
4. If ExecuteReview fails, orchestrator can retry or escalate to human intervention
