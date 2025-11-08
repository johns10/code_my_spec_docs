# SpawnComponentCodingSessions

## Purpose

Creates child ComponentCodingSession records for each component within the target context, configured for agentic execution mode. Returns a spawn_sessions command containing child_session_ids in metadata, enabling the client to orchestrate parallel autonomous implementation generation across all context components. Implements StepBehaviour to coordinate session spawning and track child session identifiers in parent session state.

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
   - Return {:error, "Context component not found"} if session.component is nil

2. **Check for Existing Child Sessions**: Determine if child sessions already exist
   - If parent_session.child_sessions is empty → proceed to create new child sessions
   - If parent_session.child_sessions has entries → validate they are correct type (CodeMySpec.ComponentCodingSessions)
   - If validation passes → return existing session IDs (idempotent behavior)
   - If validation fails → return {:error, "Invalid child session type: expected ComponentCodingSessions, got #{type}"}

3. **Query Child Components**: Load all components where parent_component_id == session.component_id
   - Use Components.list_child_components(scope, context_component.id)
   - Order by priority (descending), then name (ascending)
   - Return {:error, "No child components found for context"} if query returns empty list

4. **Get Branch Name**: Extract branch name from session state
   - Access session.state.branch_name set by Initialize step
   - Branch will be inherited by child sessions for git operations
   - Used in child sessions for creating implementation branches

5. **Create Child Sessions**: For each child component, create a ComponentCodingSession:
   - Build attrs map:
     ```elixir
     attrs = %{
       type: CodeMySpec.ComponentCodingSessions,
       component_id: component.id,
       session_id: parent_session.id,      # establishes parent-child relationship
       execution_mode: :agentic,           # critical for autonomous execution
       agent: parent_session.agent,        # inherit from parent
       environment: parent_session.environment,  # inherit from parent
       state: %{
         parent_branch_name: branch_name   # child inherits parent's git branch
       }
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

9.  **Return Command**: Return {:ok, command} tuple

### Result Processing (handle_result/4)

This step validates that all spawned child sessions have completed successfully before proceeding to finalize.

1. **Validate Child Session Status**: Check each child session status
   - Filter active sessions: filter_by_status(child_sessions, :active)
   - Filter failed sessions: filter_by_status(child_sessions, :failed)
   - Filter cancelled sessions: filter_by_status(child_sessions, :cancelled)
   - If any child session has status :active → return {:error, "Child sessions still running: [names]"}
   - If any child session has status :failed → return {:error, "Child sessions failed: [details with reasons]"}
   - If any child session has status :cancelled → return {:error, "Child sessions cancelled: [names]"}
   - Only proceed if all child sessions have status :complete

2. **Build Success Result**: If all validations pass
   - Update result status to :ok
   - Return {:ok, %{}, result} (no session state updates needed)

3. **Build Error Result**: If any validation fails
   - Update result status to :error with detailed error_message
   - Orchestrator will loop back to SpawnComponentCodingSessions step
   - Client will present failure information to user for intervention

## Error Handling

### Command Generation Errors
- **No child components**: Return {:error, "No child components found for context"} if component query returns empty
- **Context component not found**: Return {:error, "Context component not found"} if session.component is nil
- **Parent session not found**: Return {:error, "Session not found"} if get_session_with_children returns nil during idempotency check
- **Invalid child session types**: Return {:error, "Invalid child session type: expected ComponentCodingSessions, got #{type}"} if existing children have wrong type
- **Session creation failures**: Log error with component details, continue with remaining components, include failure details in logs
- **All sessions failed**: Return {:error, "Failed to spawn any child sessions"} if no sessions were successfully created
- **Partial failures**: Return {:ok, command} with successfully created session IDs (log failures but don't block)

### Result Processing Errors
- **Child sessions still running**: Return {:error, "Child sessions still running: [names]"} - client will retry after sessions complete
- **Child sessions failed**: Return {:error, "Child sessions failed: [details]"} with component names and reasons - requires human intervention
- **Child sessions cancelled**: Return {:error, "Child sessions cancelled: [names]"} - requires human intervention
- **Parent session not found**: Return {:error, "Session not found"} if get_session_with_children returns nil

### Human Intervention Points
When handle_result returns an error due to failures (not just "still running"), the client should present:
- List of failed sessions with component names and failure reasons
- List of cancelled sessions with component names
- List of missing implementation files with expected paths
- List of missing test files with expected paths
- List of failing tests with component names and error summaries
- Suggested actions: review session logs, restart failed sessions, manually fix implementations, manually fix tests, or skip components

## Dependencies

- Sessions
- SessionsRepository
- Components
- Utils
- File
- Logger

## Notes

### Parent-Child Session Relationships

Child sessions are linked to parent via `session_id` foreign key:
- Enables cascading queries and cleanup via get_session_with_children/2
- Provides audit trail of session hierarchy for troubleshooting
- Supports nested session coordination patterns for complex workflows

### Agentic Execution Mode

Child sessions execute autonomously in the background:
- Client uses Anthropic JavaScript SDK for Claude commands (agent interactions)
- Shell commands (git, mix test, file operations) run in subprocesses
- Client loops through next_command automatically until session reaches terminal state
- No human intervention required for child session workflows (unless they fail or encounter errors)
- Each child session runs ComponentCodingSessions orchestrator workflow independently

### Client Coordination Mechanism

The client is responsible for orchestrating the parallel execution of child sessions and triggering validation:

**Client Workflow:**
1. Client receives `spawn_sessions` command from parent session with `child_session_ids` in metadata
2. Client starts all child sessions in parallel (using async execution patterns)
3. Client monitors all child session statuses (polling or event-based)
4. When all child sessions reach terminal state (:complete, :failed, or :cancelled):
   - Client calls handle_result on parent session with empty result
   - This triggers validation in SpawnComponentCodingSessions.handle_result/4
5. If validation fails (handle_result returns :error):
   - Client presents failure details to user for intervention
   - User can fix issues (restart failed sessions, fix code, fix tests)
   - User triggers next_command on parent to retry (idempotent - reuses existing sessions)
6. If validation succeeds (handle_result returns :ok):
   - Orchestrator proceeds to Finalize step

### Parallel Execution and Validation Strategy

The spawn_sessions command signals client to start all sessions concurrently:
- Client receives child_session_ids array from command metadata
- Client initiates all child sessions in parallel (Promise.all pattern or similar)
- Each child session runs independently through its full ComponentCodingSessions workflow:
  1. Initialize (checkout branch, prepare environment)
  2. GenerateImplementation (AI generates code)
  3. RunTests (execute mix test)
  4. FixTestFailures (iterative AI fixes, loops with RunTests until pass)
  5. Finalize (commit implementation)
- Client monitors all child sessions until they reach terminal states (:complete, :failed, :cancelled)
- Client calls handle_result on parent session once all children are done
- handle_result validates all sessions completed, files exist, and unit tests pass
- If validation fails, orchestrator loops back to SpawnComponentCodingSessions for retry or intervention

### Branch Inheritance

Parent branch name is inherited by child sessions:
- Parent session creates branch in Initialize step, stores in session.state.branch_name
- Child sessions receive parent_branch_name in their initial state
- Child ComponentCodingSession workflows use inherited branch for git operations
- All component implementations committed to same branch for atomic context implementation
- Finalize step commits all child implementations together on parent branch

### Idempotency Considerations

The step supports idempotent behavior:
- On first execution → creates new child sessions for all child components
- On retry (after loop back) → detects existing child sessions, validates types, returns existing IDs
- Allows orchestrator to loop back to this step without creating duplicate sessions
- Failed sessions remain failed and are reported in handle_result validation
- Client can manually restart failed child sessions or delete and retry parent step

### Validation Loop

If handle_result fails validation, the orchestrator loops back to SpawnComponentCodingSessions:
- User reviews failure details (failed sessions, missing files, test failures)
- User can take corrective action:
  - Manually restart failed child sessions (change status from :failed to :active)
  - Manually fix missing implementation or test files
  - Manually fix failing tests
  - Delete failed child sessions to exclude components from context implementation
- User triggers next_command on parent session to re-execute SpawnComponentCodingSessions
- Step detects existing child sessions (idempotency), validates again
- If all children now complete successfully → handle_result passes, orchestrator proceeds to Finalize

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
  - test "returns error when parent session not found during idempotency check"
  - test "handles partial session creation failures gracefully (logs but continues)"
  - test "returns error when all session creations fail"
  - test "returns existing child_session_ids when child sessions already exist (idempotent)"
  - test "validates existing child session types match ComponentCodingSessions"
  - test "returns error when existing child sessions have invalid type"
  - test "command metadata includes timestamp"
  - test "logs session creation failures with component details"

- describe "handle_result/4"
  - test "returns success when all child sessions complete and files exist and tests pass"
  - test "returns error when child sessions still active (with component names)"
  - test "returns error when any child session failed (with failure details)"
  - test "returns error when any child session cancelled (with component names)"
  - test "returns error when parent session not found"
  - test "returns no session updates when validation succeeds"
  - test "updates result status to :ok when all validations pass"
  - test "updates result status to :error when validations fail"
  - test "includes detailed error messages with component names and reasons"
  - test "handles multiple failure types in single error message"
