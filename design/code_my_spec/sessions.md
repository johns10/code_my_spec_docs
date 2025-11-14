# Sessions Context

## Purpose

Manages session lifecycle and workflow orchestration for AI-assisted development tasks, coordinating step-by-step interactions between users and AI agents across different session types (context design, component design, testing, coding, integration).

## Entity Ownership

- **Session**: Primary entity tracking session metadata, status, and embedded interactions
- **Interaction**: Embedded entity representing command/result pairs within a session
- **Command**: Embedded entity defining executable commands for workflow steps
- **Result**: Embedded entity capturing command execution outcomes
- **SessionEvent**: Separate table entity capturing real-time activity between command issuance and result submission
- **Workflow Orchestration**: Coordinates multi-step session execution through pluggable step modules
- **Event Handling**: Processes and stores real-time events from AI agent activity (see [sessions_events.md](./sessions_events.md))

## Access Patterns

- All sessions are scoped by `account_id` and `user_id` via `Scope` struct
- Sessions optionally belong to a `project_id` and `component_id` for further scoping
- Data access functions accept `Scope.t()` as first parameter for automatic filtering
- PubSub broadcasts are scoped to account level: `account:#{account_id}:sessions`
- Repository functions enforce scope validation with pattern matching on both account_id and user_id

## Public API

```elixir
# Session CRUD Operations
@spec list_sessions(Scope.t()) :: [Session.t()]
@spec get_session!(Scope.t(), integer()) :: Session.t()
@spec get_session(Scope.t(), integer()) :: Session.t() | nil
@spec create_session(Scope.t(), map()) :: {:ok, Session.t()} | {:error, Changeset.t()}
@spec update_session(Scope.t(), Session.t(), map()) :: {:ok, Session.t()} | {:error, Changeset.t()}
@spec delete_session(Scope.t(), Session.t()) :: {:ok, Session.t()} | {:error, Changeset.t()}
@spec change_session(Scope.t(), Session.t(), map()) :: Changeset.t()

# Interaction Management
@spec complete_session_interaction(Scope.t(), Session.t(), map(), binary(), Result.t()) ::
  {:ok, Session.t()} | {:error, Changeset.t()}

# Orchestration Functions
@spec next_command(Scope.t(), integer(), keyword()) ::
  {:ok, Interaction.t()} | {:error, :session_not_found | :complete | :failed}
@spec handle_result(Scope.t(), integer(), binary(), map(), keyword()) ::
  {:ok, Session.t()} | {:error, term()}

# Event Management
@spec handle_event(Scope.t(), integer(), map()) :: {:ok, Session.t()} | {:error, term()}
@spec handle_events(Scope.t(), integer(), [map()]) :: {:ok, Session.t()} | {:error, term()}
@spec get_events(Scope.t(), integer(), keyword()) :: [Event.t()]

# Result Helpers
@spec create_result(Scope.t(), map()) :: {:ok, Result.t()} | {:error, Changeset.t()}
@spec update_result(Scope.t(), Result.t(), map()) :: {:ok, Result.t()} | {:error, Changeset.t()}

# PubSub Subscriptions
@spec subscribe_sessions(Scope.t()) :: :ok | {:error, term()}
```

## State Management Strategy

### Database Persistence
- Sessions persist to `sessions` table with foreign keys to `accounts`, `users`, `projects`, and `components`
- Interactions are embedded documents within the session (PostgreSQL JSONB)
- Commands and Results are embedded within Interactions
- All updates broadcast PubSub notifications after successful persistence

### Embedded Document Strategy
- Interactions stored as embedded schemas to maintain transactional consistency
- Full interaction history preserved within session for auditability
- Avoids N+1 queries when loading session workflow state

### Session State Machine
- Status field tracks lifecycle: `:active` → `:complete` or `:failed`
- Orchestrator validates status before generating next command
- Custom `state` map field allows session-type-specific state storage

## Execution Flow

### Creating a Session
1. **Scope Validation**: Extract account_id, user_id, and project_id from Scope struct
2. **Changeset Construction**: Build session changeset with type, agent, environment
3. **Database Insert**: Persist session with scope foreign keys
4. **Broadcast Notification**: Publish `{:created, session}` to account PubSub channel

### Orchestrating Next Command
1. **Session Lookup**: Retrieve session via SessionsRepository with scope filtering
2. **Status Validation**: Ensure session is active (not complete/failed)
3. **Step Module Resolution**: Call session type module's `get_next_interaction/1` to determine next step
4. **Command Generation**: Invoke step module's `get_command/3` callback with scope and session
5. **Interaction Creation**: Build new Interaction with generated Command
6. **Session Update**: Append interaction to session's embedded interactions list
7. **Broadcast Notification**: Publish `{:updated, session}` event
8. **Return Interaction**: Return interaction to caller for execution

### Processing Command Results
1. **Session Lookup**: Retrieve session by id with scope validation
2. **Result Validation**: Build Result struct from result attributes via changeset
3. **Interaction Lookup**: Find target interaction within session by interaction_id
4. **Result Processing**: Call command module's `handle_result/4` callback for custom logic
5. **Session Updates**: Apply session_attrs from handler (status changes, state updates)
6. **Complete Interaction**: Update interaction with final result and completed_at timestamp
7. **Persistence**: Update session record with modified interactions array
8. **Broadcast Notification**: Publish `{:updated, session}` event

### Deleting a Session
1. **Scope Validation**: Verify session belongs to active account and user
2. **Database Delete**: Remove session record (cascades to embedded interactions)
3. **Broadcast Notification**: Publish `{:deleted, session}` event

## Dependencies

- CodeMySpec.Users.Scope
- CodeMySpec.Users
- CodeMySpec.Projects
- CodeMySpec.Accounts
- CodeMySpec.Components

## Components

### Sessions.Session

| field | value  |
| ----- | ------ |
| type  | schema |

Ecto schema representing a session entity with type, status, agent, environment, and embedded interactions.

### Sessions.Interaction

| field | value  |
| ----- | ------ |
| type  | schema |

Embedded schema representing a command/result pair within a session workflow.

### Sessions.Command

| field | value  |
| ----- | ------ |
| type  | schema |

Embedded schema defining an executable command with module, command string, and pipe configuration.

### Sessions.Result

| field | value  |
| ----- | ------ |
| type  | schema |

Embedded schema capturing command execution results with status, data, output streams, and timing.

### Sessions.SessionsRepository

| field | value      |
| ----- | ---------- |
| type  | repository |

Provides data access functions for Session entities with scope filtering and interaction management.

### Sessions.Orchestrator

| field | value                |
| ----- | -------------------- |
| type  | coordination_context |

Coordinates session workflow by determining next steps and delegating to session-type-specific step modules.

### Sessions.ResultHandler

| field | value                |
| ----- | -------------------- |
| type  | coordination_context |

Processes command execution results by delegating to step-specific handlers and updating session state.

### Sessions.StepBehaviour

| field | value |
| ----- | ----- |
| type  | other |

Behaviour contract defining callbacks for workflow step modules (get_command/3, handle_result/4).

### Sessions.SessionType

| field | value |
| ----- | ----- |
| type  | other |

Custom Ecto.Type for polymorphic session type field, mapping between session module atoms and database strings.

### Sessions.SessionEvent

| field | value  |
| ----- | ------ |
| type  | schema |

Full Ecto schema (separate table) for real-time events capturing AI agent activity between command issuance and result submission. Stored in `session_events` table with foreign key to sessions. See [sessions_events.md](./sessions_events.md) for detailed design.

### Sessions.EventHandler

| field | value                |
| ----- | -------------------- |
| type  | coordination_context |

Processes incoming events from clients, inserts them into session_events table, applies side effects, and broadcasts updates.
