# SpawnComponentTestingSessions

## Purpose

Creates child ComponentTestingSession records for each component within the target context, configured for agentic execution mode. Returns a spawn_sessions command containing child_session_ids in metadata, enabling the client to orchestrate parallel autonomous test generation across all context components. Implements StepBehaviour to coordinate session spawning and validate that all child sessions complete with passing tests.

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

1. **Load Context Component**: Retrieve the context component from session.component
   - Used to establish parent-child relationships and provide architectural context
   - Return {:error, "Context component not found"} if session.component is nil

2. **Load Parent Session**: Retrieve full parent session with preloaded child_sessions
   - Use SessionsRepository.get_session(scope, session.id)
   - Enables idempotency check for existing child sessions
   - Return {:error, "Session not found"} if parent session not found

3. **Check for Existing Child Sessions**: Determine if child sessions already exist
   - If parent_session.child_sessions is empty → proceed to create new child sessions
   - If parent_session.child_sessions has entries → validate they are correct type (CodeMySpec.ComponentTestSessions)
   - If validation passes → return existing session IDs (idempotent behavior)
   - If validation fails → return {:error, "Invalid child session type: expected ComponentTestSessions, got #{type}"}

4. **Query Child Components**: Load all components where parent_component_id == context_component.id
   - Use Components.list_child_components(scope, context_component.id)
   - Order by priority (descending), then name (ascending)
   - Return {:error, "No child components found for context"} if query returns empty list

5. **Create Child Sessions**: For each child component, create a ComponentTestingSession:
   - Build attrs map:
     ```elixir
     attrs = %{
       type: CodeMySpec.ComponentTestSessions,
       component_id: component.id,
       session_id: parent_session.id,      # establishes parent-child relationship
       execution_mode: :agentic,           # critical for autonomous execution
       agent: parent_session.agent,        # inherit from parent
       environment: parent_session.environment,  # inherit from parent
       project_id: scope.active_project_id
     }
     ```
   - Call Sessions.create_session(scope, attrs)
   - Collect session creation results with error handling per component
   - Log errors with component name and changeset details

6. **Handle Session Creation Errors**: For any failed session creation
   - Log error with component name and reason using Logger.error/1
   - Continue creating remaining sessions (partial success acceptable)
   - Return {:error, "Failed to spawn any child sessions"} if all sessions failed

7. **Extract Session IDs**: Collect all successfully created session IDs into array
   - Map created sessions to extract id field: Enum.map(sessions, & &1.id)
   - Store for return in command metadata

8. **Build Spawn Command**: Create Command struct
   - `module`: __MODULE__
   - `command`: "spawn_sessions"
   - `metadata`: %{child_session_ids: [list of session IDs]}

9. **Return Command**: Return {:ok, command} tuple

### Result Processing (handle_result/4)

This step validates that all spawned child sessions have completed successfully before proceeding to finalize. It is the responsibility of each individual ComponentTestSession to ensure its test file exists and tests pass - this step only validates that all child sessions reached completion status.

1. **Load Parent Session with Children**: Use SessionsRepository.get_session(scope, session.id)
   - Returns session with child_sessions preloaded (includes component for each child)
   - Return {:error, "Session not found"} if parent session is nil

2. **Validate Child Session Status**: Check each child session status
   - Filter active sessions: filter_by_status(child_sessions, :active)
   - Filter failed sessions: filter_by_status(child_sessions, :failed)
   - Filter cancelled sessions: filter_by_status(child_sessions, :cancelled)
   - If any child session has status :active → return {:error, "Child sessions still running: [names]"}
   - If any child session has status :failed → return {:error, "Child sessions failed: [details with reasons]"}
   - If any child session has status :cancelled → return {:error, "Child sessions cancelled: [names]"}
   - Only proceed if all child sessions have status :complete

3. **Build Success Result**: If all child sessions are complete
   - Update result status to :ok
   - Return {:ok, %{}, result} (no session state updates needed)

4. **Build Error Result**: If any child session is not complete
   - Update result status to :error with detailed error_message
   - Orchestrator will loop back to this step
   - Client will present failure information to user for intervention

## Test Assertions

- describe "get_command/3"
  - test "returns spawn_sessions command with child_session_ids in metadata"
  - test "creates child sessions for each component with correct attributes"
  - test "sets execution_mode to :agentic for all child sessions"
  - test "inherits agent and environment from parent session"
  - test "establishes parent-child relationship via session_id foreign key"
  - test "orders child components by priority descending, then name ascending"
  - test "returns error when context component has no children"
  - test "returns error when context component not found"
  - test "returns error when session.component is nil"
  - test "returns error when parent session not found"
  - test "handles partial session creation failures gracefully (logs but continues)"
  - test "returns error when all session creations fail"
  - test "returns existing child_session_ids when child sessions already exist (idempotent)"
  - test "validates existing child session types match ComponentTestSessions"
  - test "returns error when existing child sessions have invalid type"
  - test "command metadata includes timestamp"
  - test "logs session creation failures with component details"

- describe "handle_result/4"
  - test "returns success when all child sessions complete"
  - test "returns error when child sessions still active (with component names)"
  - test "returns error when any child session failed (with failure details)"
  - test "returns error when any child session cancelled (with component names)"
  - test "returns error when parent session not found"
  - test "returns no session updates when validation succeeds"
  - test "updates result status to :ok when all validations pass"
  - test "updates result status to :error when validations fail"
  - test "includes detailed error messages with component names and reasons"
  - test "handles multiple failure types in single error message"
