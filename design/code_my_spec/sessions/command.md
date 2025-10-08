# Sessions.Command Schema

## Purpose

Defines an executable command within a session workflow, specifying the step module responsible for execution, the command configuration, and optional pipe operations as an embedded document within Interaction schemas.

## Fields

| Field | Type | Required | Description | Constraints |
|-------|------|----------|-------------|-------------|
| id | binary_id | Yes (auto) | Primary key (UUID) | Auto-generated UUID |
| module | CommandModuleType | Yes | Step module implementing StepBehaviour | Custom Ecto.Type for module atom |
| command | string | Yes | Command configuration or serialized data | Flexible string for command details |
| pipe | string | Yes | Pipe operation or processing configuration | Required for command composition |
| timestamp | utc_datetime_usec | No | Command creation timestamp | Auto-set to current time with microsecond precision |

## Validation Rules

### Required Fields
- `module` - Must be a valid module implementing StepBehaviour callbacks
- `command` - Must be present, contains command-specific configuration
- `pipe` - Must be present, defines how command output is processed

### Automatic Timestamping
- `timestamp` - Set to DateTime.utc_now() with microsecond precision if not provided

### Module Validation
- `module` - Validated through CommandModuleType custom Ecto.Type
- Must reference a module that implements get_command/3 and handle_result/4 callbacks

## Constructor Function

### new/3
```elixir
Command.new(module, command \\ %{}, pipe \\ nil)
```

Creates new Command with:
- `module` - Step module atom implementing StepBehaviour
- `command` - Command configuration (map or string)
- `pipe` - Pipe operation configuration
- `timestamp` - Auto-set to current UTC time

## Usage Patterns

### Creating Command for Workflow Step
```elixir
Command.new(
  MyApp.ComponentDesign.AnalyzeStep,
  %{component_id: 123, depth: "full"},
  "process_analysis"
)
```

### Module Responsibility
- The `module` field references a StepBehaviour implementation
- That module's `get_command/3` callback generates the Command
- That module's `handle_result/4` callback processes the Result
- This enables polymorphic workflow execution based on session type