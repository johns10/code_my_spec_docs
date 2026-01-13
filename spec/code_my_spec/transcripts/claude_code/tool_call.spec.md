# CodeMySpec.Transcripts.ClaudeCode.ToolCall

Struct representing a Claude Code tool invocation extracted from the transcript. Contains the tool name, input parameters map, and optional result. Used by FileExtractor to analyze transcript entries and extract file modification information.

## Fields

| Field  | Type   | Required | Description                              | Constraints                          |
| ------ | ------ | -------- | ---------------------------------------- | ------------------------------------ |
| id     | string | Yes      | Unique tool use ID for correlation       | Format: "toolu_..." - matches tool_result's tool_use_id |
| name   | string | Yes      | Name of the tool that was invoked        | e.g. "Edit", "Write", "Read", "Bash" |
| input  | map    | Yes      | Input parameters passed to the tool      | Tool-specific key-value pairs        |
| result | any    | No       | Result returned from the tool invocation | May be nil if not captured           |

## Functions

### new/1

Create a new ToolCall struct from a map of attributes.

```elixir
@spec new(map()) :: t()
```

**Process**:
1. Extract id, name, input, and result from the input map
2. Build a ToolCall struct with the extracted values
3. Default result to nil if not provided

**Test Assertions**:
- creates struct with id, name and input from map
- extracts id field for tool_use correlation
- defaults result to nil when not provided
- includes result when provided in map
- handles string keys in input map
- handles atom keys in input map

### file_path/1

Extract the file_path from a ToolCall's input if present.

```elixir
@spec file_path(t()) :: Path.t() | nil
```

**Process**:
1. Look for "file_path" key in the tool call's input map
2. Return the value if present, nil otherwise

**Test Assertions**:
- returns file_path for Edit tool call
- returns file_path for Write tool call
- returns nil for tool calls without file_path
- returns nil for empty input map

### file_modifying?/1

Check if the tool call modifies files (Edit or Write).

```elixir
@spec file_modifying?(t()) :: boolean()
```

**Process**:
1. Check if the tool name is "Edit" or "Write"
2. Return true if it matches, false otherwise

**Test Assertions**:
- returns true for Edit tool
- returns true for Write tool
- returns false for Read tool
- returns false for Bash tool
- returns false for Glob tool

## Dependencies

None.