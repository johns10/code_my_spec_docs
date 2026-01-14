# CodeMySpec.Sessions

**Type**: context

Phoenix context for managing sessions. Provides the public API for session lifecycle, execution, and result handling. Delegates execution flow to SessionServer for concurrency control. Sessions represent structured workflows for AI-assisted development tasks (component design, test generation, spec creation) with discrete steps managed through interactions.

## Delegates

- get_session/2: CodeMySpec.Sessions.SessionsRepository.get_session/2
- get_session!/2: CodeMySpec.Sessions.SessionsRepository.get_session!/2
- update_external_conversation_id/3: CodeMySpec.Sessions.SessionsRepository.update_external_conversation_id/3

## Functions

### subscribe_sessions/1

Subscribe to scoped notifications about session changes for an account.

```elixir
@spec subscribe_sessions(Scope.t()) :: :ok | {:error, term()}
```

**Process**:
1. Extract active_account_id from scope
2. Subscribe to PubSub topic "account:{account_id}:sessions"
3. Return :ok on successful subscription

**Test Assertions**:
- subscribes to account-scoped session events
- receives {:created, session} messages when sessions are created
- receives {:updated, session} messages when sessions are updated
- receives {:deleted, session} messages when sessions are deleted

### subscribe_user_sessions/1

Subscribe to user-level notifications about session changes.

```elixir
@spec subscribe_user_sessions(Scope.t() | integer()) :: :ok | {:error, term()}
```

**Process**:
1. Extract user_id from scope struct or use provided integer directly
2. Subscribe to PubSub topic "user:{user_id}:sessions"
3. Return :ok on successful subscription

**Test Assertions**:
- subscribes to user-scoped session events
- accepts Scope struct and extracts user.id
- accepts integer user_id directly
- receives session change notifications for user's sessions

### list_sessions/2

List sessions filtered by scope and options.

```elixir
@spec list_sessions(Scope.t(), keyword()) :: [Session.t()]
```

**Process**:
1. Extract status filter from opts (default: [:active])
2. Query sessions filtered by project_id and user_id from scope
3. Filter by status using provided list
4. Preload associations: project, component, interactions
5. Populate display names via SessionsRepository.populate_display_names/1
6. Return list of sessions ordered by insertion time

**Test Assertions**:
- returns sessions for active project and user
- filters by status defaulting to :active only
- accepts multiple status values in list (e.g., [:active, :complete])
- preloads project, component, and interactions associations
- populates virtual display_name field
- returns empty list when no sessions match

### create_session/2

Create a new session.

```elixir
@spec create_session(Scope.t(), map()) :: {:ok, Session.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Create new Session struct
2. Apply changeset with attrs and scope
3. Set account_id, project_id, user_id from scope
4. Insert into database via Repo
5. Broadcast :created event via SessionsBroadcaster
6. Return {:ok, session} or {:error, changeset}

**Test Assertions**:
- creates session with valid attrs
- requires type field
- sets account_id from scope.active_account_id
- sets project_id from scope.active_project_id
- sets user_id from scope.user.id
- broadcasts {:created, session} event
- returns {:error, changeset} for invalid attrs

### update_session/3

Update an existing session.

```elixir
@spec update_session(Scope.t(), Session.t(), map()) :: {:ok, Session.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Verify session.account_id matches scope.active_account_id
2. Verify session.user_id matches scope.user.id
3. Apply changeset with attrs and scope
4. Update in database via Repo
5. Broadcast :updated event via SessionsBroadcaster
6. Return {:ok, session} or {:error, changeset}

**Test Assertions**:
- updates session with valid attrs
- raises on account_id mismatch
- raises on user_id mismatch
- broadcasts {:updated, session} event
- returns {:error, changeset} for invalid attrs

### delete_session/2

Delete a session.

```elixir
@spec delete_session(Scope.t(), Session.t()) :: {:ok, Session.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Verify session.account_id matches scope.active_account_id
2. Verify session.user_id matches scope.user.id
3. Delete from database via Repo
4. Broadcast :deleted event via SessionsBroadcaster
5. Return {:ok, session}

**Test Assertions**:
- deletes session successfully
- raises on account_id mismatch
- raises on user_id mismatch
- broadcasts {:deleted, session} event
- cascades delete to interactions

### change_session/3

Return a changeset for tracking session changes.

```elixir
@spec change_session(Scope.t(), Session.t(), map()) :: Ecto.Changeset.t()
```

**Process**:
1. Verify session ownership via scope
2. Apply Session.changeset with attrs and scope
3. Return changeset without persisting

**Test Assertions**:
- returns valid changeset for valid attrs
- returns invalid changeset for invalid attrs
- verifies session ownership

### handle_result/5

Handle interaction result and update session state.

```elixir
@spec handle_result(Scope.t(), integer(), binary(), map(), keyword()) :: {:ok, Session.t()} | {:error, term()}
```

**Process**:
1. Delegate to ResultHandler.handle_result/5
2. ResultHandler finds session and interaction
3. Creates Result struct from attrs
4. Calls command module's handle_result callback
5. Completes interaction with result
6. Updates session state if needed
7. Checks orchestrator.complete? to mark session complete if appropriate
8. Broadcast :updated event via SessionsBroadcaster
9. Return {:ok, session}

**Test Assertions**:
- processes result via ResultHandler
- broadcasts updated event
- returns updated session with completed interaction
- marks session complete when orchestrator.complete? returns true
- returns {:error, :session_not_found} for invalid session_id
- returns {:error, :interaction_not_found} for invalid interaction_id

### next_command/3

Get next command for a session.

```elixir
@spec next_command(Scope.t(), integer(), keyword()) :: {:ok, Session.t()} | {:error, term()}
```

**Process**:
1. Delegate to CommandResolver.next_command/3
2. Validate session status is not complete or failed
3. Clear any existing pending interaction
4. Get next step module from session type's get_next_interaction
5. Generate command via step module's get_command callback
6. Create new Interaction with command
7. Broadcast step_started event
8. Broadcast :updated event
9. Return {:ok, session} with new interaction

**Test Assertions**:
- creates next interaction with command
- broadcasts step_started event
- broadcasts updated event
- returns {:error, :complete} if session is complete
- returns {:error, :failed} if session is failed
- returns existing pending interaction if one exists

### execute/3

Execute a session step synchronously using SessionServer.

```elixir
@spec execute(Scope.t(), integer(), keyword()) :: {:ok, map()} | {:error, term()}
```

**Process**:
1. Get or start SessionServer for session_id
2. Call GenServer with {:run, scope, opts}
3. SessionServer creates interaction synchronously
4. SessionServer spawns task for execution
5. Block until task completes
6. Return result

**Test Assertions**:
- starts SessionServer if not running
- executes step synchronously
- returns interaction info with task_pid
- returns {:error, :execution_in_progress} if task already running

### run/3

Run a session step asynchronously using SessionServer.

```elixir
@spec run(Scope.t(), integer(), keyword()) :: {:ok, map()} | {:error, term()}
```

**Process**:
1. Get or start SessionServer for session_id
2. Call GenServer with {:run, scope, opts}
3. SessionServer creates interaction synchronously
4. SessionServer spawns task for execution
5. Return immediately with interaction_id, command_module, and task_pid

**Test Assertions**:
- starts SessionServer if not running
- creates interaction synchronously before returning
- returns interaction_id, command_module, and task_pid
- returns {:error, :execution_in_progress} if task already running
- task_pid can be used for sandbox access in tests

### deliver_result_to_server/4

Deliver an external result to a waiting SessionServer.

```elixir
@spec deliver_result_to_server(integer(), binary(), map(), keyword()) :: :ok | {:error, :session_server_not_found}
```

**Process**:
1. Look up SessionServer in Registry by session_id
2. If found, cast {:deliver_result, interaction_id, result, opts} message
3. SessionServer forwards to waiting task via send
4. Return :ok on success

**Test Assertions**:
- delivers result to running SessionServer
- returns {:error, :session_server_not_found} if no server running
- result is forwarded to waiting task

### update_execution_mode/3

Update session execution mode and regenerate pending command.

```elixir
@spec update_execution_mode(Scope.t(), integer(), String.t()) :: {:ok, Session.t()} | {:error, term()}
```

**Process**:
1. Load session by id
2. Update execution_mode field
3. Check for pending interaction (command without result)
4. If pending exists:
   a. Get next step module from session type
   b. Build opts based on new execution mode (:auto -> [auto: true], :manual -> [], :agentic -> [agentic: true])
   c. Regenerate command via step module
   d. Delete old pending interaction
   e. Create new interaction with regenerated command
5. Broadcast :updated event
6. Broadcast :mode_change event with new mode
7. Return {:ok, session}

**Test Assertions**:
- updates execution_mode to :auto, :manual, or :agentic
- regenerates pending command with new mode settings
- broadcasts updated event
- broadcasts mode_change event
- handles sessions without pending interactions gracefully
- returns {:error, :session_not_found} for invalid session_id

### create_result/2

Create a Result struct from attributes (virtual, not persisted).

```elixir
@spec create_result(Scope.t(), map()) :: {:ok, Result.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Create Result changeset from attrs
2. Apply changeset action :insert
3. Return {:ok, result} or {:error, changeset}

**Test Assertions**:
- creates result struct with valid attrs
- validates required :status field
- returns {:error, changeset} for invalid attrs

### update_result/3

Update a Result struct with new attributes (virtual, not persisted).

```elixir
@spec update_result(Scope.t(), Result.t(), map()) :: {:ok, Result.t()} | {:error, Ecto.Changeset.t()}
```

**Process**:
1. Apply Result changeset to existing result with new attrs
2. Apply changeset action :update
3. Return {:ok, result} or {:error, changeset}

**Test Assertions**:
- updates result struct with valid attrs
- validates result structure
- returns {:error, changeset} for invalid attrs

## Dependencies

- CodeMySpec.Repo
- CodeMySpec.Users.Scope
- CodeMySpec.Sessions.Session
- CodeMySpec.Sessions.Result
- CodeMySpec.Sessions.Interaction
- CodeMySpec.Sessions.SessionsRepository
- CodeMySpec.Sessions.SessionsBroadcaster
- CodeMySpec.Sessions.SessionServer
- CodeMySpec.Sessions.ResultHandler
- CodeMySpec.Sessions.CommandResolver
- CodeMySpec.Sessions.InteractionsRepository

## Components

### CodeMySpec.Sessions.Session

Ecto schema representing a session. Contains type (session workflow module), agent (:claude_code), environment (:local, :vscode, :cli), execution_mode (:manual, :auto, :agentic), status (:active, :complete, :failed, :cancelled), state map, external_conversation_id, and associations to project, account, user, component, parent/child sessions, and interactions.

### CodeMySpec.Sessions.SessionServer

GenServer managing session execution task lifecycle and message delivery. One server process per active session, registered by session_id via SessionRegistry. Creates interactions synchronously, spawns tasks for execution, handles async result delivery via message passing, and supports auto-continuation in :auto mode.

### CodeMySpec.Sessions.SessionsRepository

Repository module for session data access operations. Handles database queries with scope filtering, session preloading with associations (project, component, interactions, component.parent_component, child_sessions), display name population, status updates, and external_conversation_id updates.

### CodeMySpec.Sessions.SessionsBroadcaster

Centralized broadcasting for session-related events. Handles PubSub broadcasting for session lifecycle events (created, updated, deleted), step events (started, completed), mode changes, and activity notifications to both account-level and user-level channels.

### CodeMySpec.Sessions.Interaction

Ecto schema representing an interaction within a session. Contains a command (embedded), result (embedded, nil until executed), step_name, completed_at timestamp, and has_many interaction_events. Provides predicates: pending?/1, completed?/1, successful?/1, failed?/1.

### CodeMySpec.Sessions.InteractionsRepository

Repository module for managing Interaction records. Provides CRUD operations: create/2, get/1, get!/1, complete/2 (add result), delete/1, and list_for_session/1.

### CodeMySpec.Sessions.Command

Embedded schema representing a command to be executed during a session. Contains module (step module), execution_strategy (:sync, :task, :async), command string, pipe, metadata map, and timestamp. Provides new/3 factory function and runs_in_terminal?/1 predicate.

### CodeMySpec.Sessions.Result

Embedded schema representing the result of executing a command. Contains status (:ok, :pending, :error, :warning), data map, code, error_message, stdout, stderr, duration_ms, and timestamp. Provides factory functions: success/2, error/2, warning/3, pending/2.

### CodeMySpec.Sessions.CommandResolver

Resolves and creates the next command for a session. Validates session status (not complete or failed), clears pending interactions, gets next step module from session type's get_next_interaction callback, generates command via step module's get_command callback, creates interaction, and broadcasts step_started event.

### CodeMySpec.Sessions.ResultHandler

Handles interaction results and session state updates. Finds session and interaction, creates result struct, delegates to command module's handle_result callback, completes interaction via InteractionsRepository.complete/2, optionally updates session state, and checks orchestrator.complete? to mark session complete.

### CodeMySpec.Sessions.Executor

Executes commands to completion, handling all concurrency patterns. Takes InteractionContext and executes via Environments.run_command/3, handling sync (immediate result), task (spawned by command, awaited here), and async (external, wait for {:interaction_result, ...} message with 30-minute timeout) execution patterns.

### CodeMySpec.Sessions.InteractionContext

Context struct prepared for executing an interaction. Contains environment, command, execution_opts, session, and interaction. Provides prepare/3 to build context from scope, session, and opts, creating execution environment and building execution_opts with session_id and interaction_id.

### CodeMySpec.Sessions.EventHandler

Processes incoming events from CLI/VSCode clients, persists them to interaction_events table, applies session-level side effects (status changes from data.new_status, external_conversation_id from session_start, notification broadcasting, session_end result handling), updates InteractionRegistry with runtime status, and broadcasts notifications to connected clients.

### CodeMySpec.Sessions.InteractionEvent

Ecto schema for events capturing real-time activity during interaction execution. Append-only log with event_type (:proxy_request, :proxy_response, :session_start, :session_end, :notification_hook, :session_stop_hook, :post_tool_use, :user_prompt_submit, :stop), data map, metadata map, sent_at timestamp.

### CodeMySpec.Sessions.SessionEvent

Legacy Ecto schema for session-level events with event_type, data, metadata, and sent_at. Being superseded by InteractionEvent for finer-grained event tracking at the interaction level.

### CodeMySpec.Sessions.InteractionRegistry

GenServer maintaining ephemeral runtime state for interactions executing asynchronously. Provides real-time visibility into interaction status through non-durable status updates from agent hook callbacks. Operations: register_status/1, update_status/2, get_status/1, clear_status/1, clear_all/0, list_active/0. State cleared when users interact in TUI.

### CodeMySpec.Sessions.RuntimeInteraction

Ephemeral embedded schema for runtime interaction state. Contains interaction_id, agent_state, last_notification, last_activity, last_stopped, conversation_id, timestamp. Not persisted - lives only in InteractionRegistry. Uses changeset pattern for partial updates.

### CodeMySpec.Sessions.StepBehaviour

Behaviour for workflow step modules in session orchestration. Defines callbacks: get_command/3 (scope, session, opts -> {:ok, Command.t()} | {:error, String.t()}) and handle_result/4 (scope, session, result, opts -> {:ok, session_updates, updated_result} | {:error, String.t()}).

### CodeMySpec.Sessions.OrchestratorBehaviour

Behaviour for session type orchestrators. Defines callbacks: steps/0 for ordered list of step modules, get_next_interaction/1 (session -> {:ok, module} | {:error, :session_complete | atom()}), complete?/1 (session_or_interaction -> boolean) for completion determination.

### CodeMySpec.Sessions.SessionType

Custom Ecto type for session type atoms. Maps between atom module names and string database values. Supports orchestrator types (ComponentSpecSessions, ComponentTestSessions, etc.) and agent task types (AgentTasks.ContextSpec, AgentTasks.ComponentSpec, etc.).

### CodeMySpec.Sessions.CommandModuleType

Custom Ecto type for command module atoms. Maps between atom module names and string database values for step/command modules.

### CodeMySpec.Sessions.EventType

Custom Ecto type for event_type atoms. Maps between event type atoms and string database values.

### CodeMySpec.Sessions.Utils

Utility functions for working with sessions and interactions. Provides find_last_completed_interaction/1 to locate the most recent completed interaction in an active session, returning nil for complete/failed sessions.

### CodeMySpec.Sessions.AgentTasks.ContextSpec

Agent task session type for generating context specifications. Implements OrchestratorBehaviour for single-step specification generation workflow.

### CodeMySpec.Sessions.AgentTasks.ContextComponentSpecs

Agent task session type for generating specifications for all child components of a context. Orchestrates multi-component specification generation.

### CodeMySpec.Sessions.AgentTasks.ComponentSpec

Agent task session type for generating component specifications. Implements OrchestratorBehaviour for component-level spec generation workflow.

### CodeMySpec.Sessions.AgentTasks.ComponentCode

Agent task session type for generating component implementation code from specifications. Implements OrchestratorBehaviour for code generation workflow.

### CodeMySpec.Sessions.AgentTasks.ComponentTest

Agent task session type for generating component tests from specifications. Implements OrchestratorBehaviour for test generation workflow.