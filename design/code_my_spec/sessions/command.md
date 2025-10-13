# Sessions.Command Schema

## Purpose

Defines an executable command within a session workflow, specifying the step module responsible for execution, the command configuration, and optional pipe operations as an embedded document within Interaction schemas.

## Fields

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| id | binary_id | Yes (auto) | Primary key (UUID) | Auto-generated UUID |
| module | CommandModuleType | Yes | Step module implementing StepBehaviour | Custom Ecto.Type for module atom |
| command | string | Yes | Command string or identifier | Shell command, "claude", "spawn_sessions", etc. |
| pipe | string | No | (Deprecated) Pipe operation | Legacy field for prompts, use metadata instead |
| metadata | map | No | Flexible command metadata | JSONB map for prompts, options, session IDs, etc. |
| timestamp | utc_datetime_usec | No | Command creation timestamp | Auto-set to current time with microsecond precision |

## Validation Rules

### Required Fields
- `module` - Must be a valid module implementing StepBehaviour callbacks
- `command` - Must be present, contains command string or identifier

### Optional Fields with Defaults
- `metadata` - Defaults to empty map `%{}`

### Automatic Timestamping
- `timestamp` - Set to DateTime.utc_now() with microsecond precision if not provided

### Module Validation
- `module` - Validated through CommandModuleType custom Ecto.Type
- Must reference a module that implements get_command/3 and handle_result/4 callbacks

## Constructor Function

### new/3
```elixir
Command.new(module, command, opts \\ [])
```

Creates new Command with:
- `module` - Step module atom implementing StepBehaviour
- `command` - Command string (shell command, "claude", "spawn_sessions", etc.)
- `opts` - Keyword list with optional:
  - `:metadata` - Map of command metadata
- `timestamp` - Auto-set to current UTC time

## Usage Patterns

### Shell Command
```elixir
Command.new(
  MyApp.Steps.RunTests,
  "mix test path/to/test.exs"
)
```

### Claude SDK Command
```elixir
Command.new(
  MyApp.Steps.GenerateDesign,
  "claude",
  metadata: %{
    prompt: "Generate component design for...",
    options: %{model: "claude-3-opus", max_turns: 10}
  }
)
```

### Spawn Child Sessions Command
```elixir
Command.new(
  MyApp.Steps.SpawnComponentDesigns,
  "spawn_sessions",
  metadata: %{
    child_session_ids: [1, 2, 3],
    session_type: :component_design
  }
)
```

## Execution Based on Session Mode

The session's `execution_mode` field determines how the client executes commands:

### Manual Mode (default)
- Shell commands → Executed in user's terminal (interactive)
- Claude commands → Executed via `claude` CLI in terminal (interactive)
- All execution is synchronous and user-controlled

### Agentic Mode
- Shell commands → Executed in subprocess (background)
- Claude commands → Executed via Anthropic JavaScript SDK (background)
- Spawn commands → Client autonomously executes child sessions
- Client loops through `next_command` automatically until session complete

### Module Responsibility
- The `module` field references a StepBehaviour implementation
- That module's `get_command/3` callback generates the Command
- That module's `handle_result/4` callback processes the Result
- This enables polymorphic workflow execution based on session type