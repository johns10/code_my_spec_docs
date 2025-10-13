# SpawnComponentDesignSessions

## Purpose

Creates child ComponentDesignSession records for each component within the target context, configured for agentic execution mode. Returns a spawn_sessions command containing child_session_ids in metadata, enabling the client to orchestrate parallel autonomous design generation across all context components. Implements StepBehaviour to coordinate session spawning and track child session identifiers in parent session state.

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
   - Used to establish parent-child relationships and provide architectural context
   - Preload project association for component file path resolution
2. **Query Child Components**: Load all components where parent_component_id == session.component_id
   - Use Components context to query child components
   - Order by priority (descending), then name (ascending)
   - If no child components found → return {:error, "No child components found for context"}
3. **Get Context Design File Path**: Determine path to context design file for AI agent reference
   - Use Utils.component_files/2 on context component to get design_file path
   - Store path for injection into each child session's initial state
   - AI agents will read the file directly as needed during their workflow
4. **Create Child Sessions**: For each child component, create a ComponentDesignSession:
   - Build attrs map:
     ```elixir
     attrs = %{
       type: CodeMySpec.ComponentDesignSessions,
       component_id: component.id,  # from session.state.components
       session_id: session.id,      # establishes parent-child relationship
       execution_mode: :agentic,    # critical for autonomous execution
       agent: session.agent,        # inherit from parent
       environment: session.environment,  # inherit from parent
       state: %{
         parent_context_name: context_component.name,
         context_design_path: context_design_path  # AI will read file as needed
       }
     }
     ```
   - Call Sessions.create_session(scope, attrs)
   - Collect session creation results with error handling per component
5. **Handle Session Creation Errors**: For any failed session creation:
   - Log error with component name and reason
   - Continue creating remaining sessions (partial success acceptable)
   - Include failed component details in command metadata
6. **Extract Session IDs**: Collect all successfully created session IDs into array
   - Map created sessions to extract id field: Enum.map(sessions, & &1.id)
   - Store for return in command metadata
7. **Build Spawn Command**: Create Command struct:
   - `module`: __MODULE__
   - `command`: "spawn_sessions"
   - `metadata`: %{child_session_ids: [list of session IDs]}
8. **Return Command**: Return {:ok, command} tuple

### Result Processing (handle_result/4)

This step validates that all spawned child sessions have completed successfully before proceeding to the review step.

1. **Load Parent Session with Children**: Use SessionsRepository.get_session_with_children(scope, session.id)
   - Returns session with child_sessions preloaded (includes component for each child)
   - Avoids N+1 queries
2. **Validate Child Session Status**: Check each child session
   - If any child session has status :failed or :cancelled → return {:error, "Child sessions failed: [details]"}
   - If any child session still has status :active → return {:error, "Child sessions still running"}
   - Collect status information for error messages
3. **Verify Design Files Exist**: For each child session
   - Access child_session.component (already preloaded)
   - Use Utils.component_files/2 to get design_file path
   - Check file existence with File.exists?/1
   - If any files missing → return {:error, "Design files missing: [paths]"}
4. **Build Success Result**: If all validations pass
   - Update result status to :ok
   - Return {:ok, %{}, result} (no session updates needed)
5. **Build Error Result**: If any validation fails
   - Update result status to :error with detailed error_message
   - Orchestrator will loop back to this step
   - Client will present failure information to user for intervention

## Error Handling

### Command Generation Errors
- **No child components**: Return {:error, "No child components found for context"} if component query returns empty
- **Context component not found**: Return {:error, "Context component not found"} if session.component_id lookup fails
- **Session creation failures**: Log error with component details, continue with remaining components, include failure details in metadata
- **All sessions failed**: Return {:error, "Failed to spawn any child sessions"} if no sessions were successfully created
- **Partial failures**: Return {:ok, command} with both successful and failed spawns in metadata

### Result Processing Errors
- **Child sessions still running**: Return {:error, "Child sessions still in progress"} - client will retry after sessions complete
- **Child sessions failed**: Return {:error, message} with details about which sessions failed and why - requires human intervention
- **Child sessions cancelled**: Return {:error, message} with details - requires human intervention
- **Missing design files**: Return {:error, message} with list of missing file paths - requires human intervention
- **Parent session not found**: Return {:error, "Session not found"} if get_session_with_children returns nil

### Human Intervention Points
When handle_result returns an error due to failures (not just "still running"), the client should present:
- List of failed sessions with component names and failure reasons
- List of cancelled sessions
- List of missing design files with expected paths
- Suggested actions: review session logs, restart failed sessions, manually fix issues, or skip components

## Dependencies

- Sessions (for creating child ComponentDesignSession records)
- SessionsRepository (for get_session_with_children/2 in handle_result)
- Components (for querying child components and loading context component)
- Utils (for determining design file paths)
- File (for checking file existence in handle_result)

## Notes

### Parent-Child Session Relationships

Child sessions are linked to parent via `session_id` foreign key:
- Enables cascading queries and cleanup via get_session_with_children/2
- Provides audit trail of session hierarchy
- Supports nested session coordination patterns

### Agentic Execution Mode

Child sessions execute autonomously in the background:
- Client uses Anthropic JavaScript SDK for Claude commands
- Shell commands (git, file operations) run in subprocesses
- Client loops through next_command automatically until session completes
- No human intervention required for child session workflows (unless they fail)

### Parallel Execution and Validation Strategy

The spawn_sessions command signals client to start all sessions concurrently:
- Client receives child_session_ids array from command metadata
- Client initiates all child sessions in parallel (Promise.all pattern)
- Each child session runs independently through its full workflow
- Client monitors all child sessions until they reach terminal states
- Client calls handle_result on parent session once all children are done
- handle_result validates all sessions are complete and files exist
- If validation fails, orchestrator loops back to this step for retry

### Context Design Path Injection

Context design file path is injected into child session state for AI agent reference:
- Ensures component designs align with context architecture
- AI agents read the file directly when needed (e.g., during GenerateComponentDesign)
- Child sessions access path via session.state.context_design_path
- Avoids unnecessary pre-reading of content
- Design validation steps can also read the file when validating alignment
