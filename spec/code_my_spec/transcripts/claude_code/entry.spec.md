# CodeMySpec.Transcripts.ClaudeCode.Entry

Struct representing a single line entry in the Claude Code transcript JSONL. Maps to the raw JSON structure with type, role, and content fields. Each entry captures either a user message or an assistant response with associated metadata like timestamps, UUIDs for threading, and session context.

## Fields

| Field        | Type    | Required | Description                                       | Constraints                       |
| ------------ | ------- | -------- | ------------------------------------------------- | --------------------------------- |
| type         | string  | Yes      | Entry type indicating message origin              | Values: "user", "assistant"       |
| uuid         | string  | Yes      | Unique identifier for this entry                  | UUID format                       |
| parent_uuid  | string  | No       | UUID of parent entry for threading                | UUID format, nil for root entries |
| timestamp    | string  | Yes      | ISO 8601 timestamp of when entry was created      |                                   |
| session_id   | string  | Yes      | Session identifier grouping related entries       | UUID format                       |
| agent_id     | string  | No       | Agent identifier for the session                  |                                   |
| cwd          | string  | No       | Current working directory at time of entry        |                                   |
| version      | string  | No       | Claude Code version that created the entry        |                                   |
| git_branch   | string  | No       | Git branch active at time of entry                |                                   |
| is_sidechain | boolean | No       | Whether entry is part of a sidechain conversation | Default: false                    |
| user_type    | string  | No       | Classification of user type                       | Values: "external", "internal"    |
| request_id   | string  | No       | API request ID (assistant entries only)           | Format: "req_..."                 |
| message      | map     | Yes      | Message content structure                         |                                   |

## Functions

### new/1

Create a new Entry struct from a decoded JSON map.

```elixir
@spec new(map()) :: t()
```

**Process**:
1. Extract and transform keys from snake_case JSON to struct fields
2. Map parentUuid to parent_uuid, sessionId to session_id, etc.
3. Return a new Entry struct with all fields populated

**Test Assertions**:
- creates Entry from valid user message JSON
- creates Entry from valid assistant message JSON
- converts camelCase keys to snake_case struct fields
- preserves message map structure
- handles nil optional fields

### user?/1

Check if entry is a user message.

```elixir
@spec user?(t()) :: boolean()
```

**Process**:
1. Check if entry type equals "user"

**Test Assertions**:
- returns true for user type entries
- returns false for assistant type entries

### assistant?/1

Check if entry is an assistant message.

```elixir
@spec assistant?(t()) :: boolean()
```

**Process**:
1. Check if entry type equals "assistant"

**Test Assertions**:
- returns true for assistant type entries
- returns false for user type entries

### content/1

Extract the content from an entry's message.

```elixir
@spec content(t()) :: String.t() | [map()] | nil
```

**Process**:
1. Access the message map
2. Return the "content" field value (string for user, list of content blocks for assistant)

**Test Assertions**:
- returns string content for user entries
- returns list of content blocks for assistant entries
- returns nil when message has no content field

### role/1

Extract the role from an entry's message.

```elixir
@spec role(t()) :: String.t() | nil
```

**Process**:
1. Access the message map
2. Return the "role" field value

**Test Assertions**:
- returns "user" for user message entries
- returns "assistant" for assistant message entries
- returns nil when message has no role field

### tool_use_blocks/1

Extract tool use content blocks from an assistant entry.

```elixir
@spec tool_use_blocks(t()) :: [map()]
```

**Process**:
1. Return empty list if not an assistant entry
2. Get content list from message
3. Filter content blocks where type is "tool_use"

**Test Assertions**:
- returns empty list for user entries
- returns empty list for assistant entries with no tool use
- returns list of tool_use blocks when present
- preserves tool name and input from tool_use blocks

### tool_result_blocks/1

Extract tool result content blocks from a user entry containing tool results.

```elixir
@spec tool_result_blocks(t()) :: [map()]
```

**Process**:
1. Get content from message (may be a list for tool results)
2. Return empty list if content is not a list
3. Filter content blocks where type is "tool_result"

**Test Assertions**:
- returns empty list for entries with string content
- returns list of tool_result blocks when present
- preserves tool_use_id and content from tool_result blocks

## Dependencies

- Jason
