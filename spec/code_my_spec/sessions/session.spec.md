# CodeMySpec.Sessions.Session

Ecto schema representing a session that tracks AI-assisted workflows for component design, testing, and coding. Sessions maintain state, link to components/projects/accounts, and contain interactions that record commands and results.

## Fields

| Field                    | Type         | Required   | Description                                      | Constraints                          |
| ------------------------ | ------------ | ---------- | ------------------------------------------------ | ------------------------------------ |
| id                       | integer      | Yes (auto) | Primary key                                      | Auto-generated                       |
| type                     | SessionType  | Yes        | Module defining session workflow type            | Custom Ecto.Type, validated types    |
| agent                    | enum         | No         | AI agent type                                    | Values: :claude_code                 |
| environment              | enum         | No         | Execution environment                            | Values: :local, :vscode, :cli        |
| execution_mode           | enum         | No         | How session is executed                          | Values: :manual, :auto, :agentic     |
| status                   | enum         | No         | Current session status                           | Values: :active, :complete, :failed, :cancelled |
| state                    | map          | No         | Session-specific state data                      | JSON-serializable map                |
| display_name             | string       | No         | Human-readable session name                      | Virtual field, derived from type     |
| external_conversation_id | string       | No         | External conversation reference                  | Used for agent conversation tracking |
| project_id               | binary_id    | Yes        | Associated project                               | References projects.id               |
| account_id               | integer      | Yes        | Associated account                               | References accounts.id               |
| user_id                  | integer      | Yes        | User who created session                         | References users.id                  |
| component_id             | binary_id    | No         | Associated component                             | References components.id             |
| session_id               | integer      | No         | Parent session for hierarchical sessions         | References sessions.id               |
| inserted_at              | utc_datetime | Yes (auto) | Creation timestamp                               | Auto-generated                       |
| updated_at               | utc_datetime | Yes (auto) | Last update timestamp                            | Auto-generated                       |

## Functions

### changeset/3

Creates or updates a session with the given attributes, automatically setting account, project, and user from the user scope.

```elixir
@spec changeset(t(), map(), UserScope.t()) :: Ecto.Changeset.t()
```

**Process**:
1. Cast permitted attributes: type, agent, environment, execution_mode, status, state, component_id, session_id, external_conversation_id
2. Validate type is required
3. Put account_id from user_scope.active_account_id
4. Put project_id from user_scope.active_project_id
5. Put user_id from user_scope.user.id
6. Derive and set display_name from type

**Test Assertions**:
- returns valid changeset with required type field
- sets account_id from user scope
- sets project_id from user scope
- sets user_id from user scope
- derives display_name from session type
- returns invalid changeset when type is missing

### get_pending_interactions/1

Returns all interactions from a session that have not yet been completed (result is nil).

```elixir
@spec get_pending_interactions(t()) :: [Interaction.t()]
```

**Process**:
1. Filter session.interactions using Interaction.pending?/1 predicate

**Test Assertions**:
- returns empty list when no interactions exist
- returns only interactions without results
- excludes completed interactions

### get_completed_interactions/1

Returns all interactions from a session that have been completed (result is not nil).

```elixir
@spec get_completed_interactions(t()) :: [Interaction.t()]
```

**Process**:
1. Filter session.interactions using Interaction.completed?/1 predicate

**Test Assertions**:
- returns empty list when no interactions exist
- returns only interactions with results
- excludes pending interactions

### format_display_name/1

Formats a session type module into a human-readable display name by extracting and transforming the final module segment.

```elixir
@spec format_display_name(t() | atom()) :: String.t() | nil
```

**Process**:
1. Extract type atom from session struct or use atom directly
2. Split module name into segments
3. Take the last segment
4. Remove "Sessions" suffix
5. Convert to title case using Recase.to_title

**Test Assertions**:
- formats CodeMySpec.ComponentTestSessions as "Component Test"
- formats CodeMySpec.ContextSpecSessions as "Context Spec"
- returns nil for non-atom input
- handles session struct by extracting type field

## Dependencies

- CodeMySpec.Components.Component
- CodeMySpec.Projects.Project
- CodeMySpec.Accounts.Account
- CodeMySpec.Users.User
- CodeMySpec.Sessions.Interaction
- CodeMySpec.Sessions.SessionType
- Ecto.Schema
- Ecto.Changeset
- Recase
