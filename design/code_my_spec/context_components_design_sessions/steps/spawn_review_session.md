# SpawnReviewSession

## Purpose

Creates a single ComponentDesignReviewSession in agentic mode that analyzes all generated component designs within the context for consistency, missing dependencies, and integration issues. The review session generates a review document identifying architectural concerns and improvement recommendations. Returns a spawn_sessions command with review_session_id in metadata for the client to start.

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

1. **Load Context Component**: Retrieve the context component from session.component_id to understand the context being reviewed
2. **Load Parent Session with Children**: Use SessionsRepository.get_session_with_children(scope, session.id)
   - Returns session with child_sessions preloaded (includes component for each child)
   - Use these child sessions to build design file paths
3. **Build Child Design File Paths**: For each child_session in session.child_sessions:
   - Access child_session.component (already preloaded)
   - Use Utils.component_files/2 to get design_file path
   - Build design summary map: %{component_id: id, name: name, module_name: module, type: type, design_path: path}
   - AI agent will read files directly during review workflow
4. **Get Context Design File Path**:
   - Use Utils.component_files/2 on context component to get context design_file path
   - Store path for AI agent to read during review
5. **Determine Review Output Path**: Calculate expected review document path:
   - Convention: `docs/review/{context_name}_components_review.md`
   - Store for session state so review workflow knows where to write output
6. **Create Review Session**: Build attrs and create session:
   ```elixir
   attrs = %{
     type: CodeMySpec.ComponentDesignReviewSessions,
     component_id: session.component_id,  # context component for scope
     session_id: session.id,              # parent relationship
     execution_mode: :agentic,            # autonomous execution
     agent: session.agent,                # inherit from parent
     environment: session.environment,    # inherit from parent
     state: %{
       context_name: context_component.name,
       context_design_path: context_design_path,
       component_design_paths: component_design_summary_list,
       review_output_path: review_output_path,
       review_instructions: "Analyze all component designs for architectural consistency..."
     }
   }
   ```
   - Call Sessions.create_session(scope, attrs)
7. **Build Spawn Command**: Create Command struct:
   - `module`: __MODULE__
   - `command`: "spawn_sessions"
   - `metadata`: %{review_session_id: review_session.id, session_type: :component_design_review}
8. **Return Command**: Return {:ok, command} tuple

### Result Processing (handle_result/4)

This step validates that the spawned review session has completed successfully before proceeding to finalize.

1. **Load Review Session**: Get review_session_id from command metadata
   - Use Sessions.get_session(scope, review_session_id) to load review session
   - Preload component association
2. **Validate Review Session Status**: Check review session
   - If status is :failed or :cancelled → return {:error, "Review session failed: [details]"}
   - If status is still :active → return {:error, "Review session still running"}
3. **Verify Review Document Exists**: Check for review output file
   - Load session.component from review session
   - Use Utils.component_files/2 or build path: `docs/review/{context_name}_components_review.md`
   - Check file existence with File.exists?/1
   - If file missing → return {:error, "Review document missing at [path]"}
4. **Build Success Result**: If all validations pass
   - Update result status to :ok
   - Return {:ok, %{}, result} (no session updates needed)
5. **Build Error Result**: If any validation fails
   - Update result status to :error with detailed error_message
   - Orchestrator will loop back to this step
   - Client will present failure information to user for intervention

## Error Handling

### Command Generation Errors
- **Missing context component**: Return {:error, "Context component not found in session"} if session.component_id is nil or invalid
- **No child sessions**: Return {:error, "No child sessions found to review"} if session.child_sessions is empty
- **Session creation failure**: Return {:error, reason} if Sessions.create_session(scope, attrs) fails

### Result Processing Errors
- **Review session still running**: Return {:error, "Review session still in progress"} - client will retry after session completes
- **Review session failed**: Return {:error, message} with failure details - requires human intervention
- **Review session cancelled**: Return {:error, message} - requires human intervention
- **Missing review document**: Return {:error, message} with expected path - requires human intervention
- **Review session not found**: Return {:error, "Review session not found"} if session lookup fails

### Human Intervention Points
When handle_result returns an error due to failure (not just "still running"), the client should present:
- Review session status and any failure messages
- Expected review document path if missing
- Suggested actions: review session logs, restart review session, manually create review document, or skip review

## Dependencies

- Sessions (for creating review session and loading in handle_result)
- SessionsRepository (for get_session_with_children/2)
- Components (for loading context component)
- Utils (for determining file paths)
- File (for checking file existence in handle_result)

## Notes

### ComponentDesignReviewSessions Workflow

The spawned ComponentDesignReviewSession is a dedicated session type with its own orchestrator and workflow optimized for reviewing multiple component designs. It will:
- Read all component design files referenced in state.component_design_paths
- Read the context design file from state.context_design_path
- Analyze for consistency, missing dependencies, and integration issues
- Generate a review document at state.review_output_path
- The workflow is distinct from ComponentDesignSessions and tailored for review activities

### Validation in handle_result

Similar to SpawnComponentDesignSessions, this step performs validation in handle_result:
- Client monitors review session until it reaches a terminal state
- Client calls handle_result on parent session
- handle_result validates review session is complete and document exists
- If validation fails, orchestrator loops back to this step for retry
- Human intervention required for failed or cancelled review sessions
