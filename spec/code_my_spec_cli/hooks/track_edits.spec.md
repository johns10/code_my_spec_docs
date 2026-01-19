# CodeMySpecCli.Hooks.TrackEdits

A Claude Code post-tool-use hook that tracks files edited during an agent session. When Claude uses Write or Edit tools, this hook captures the file path and stores it in session state, building a record of all files modified during the session for later validation.

## Functions

### run/1

Process a tool use event and track file edits.

```elixir
@spec run(hook_input :: map()) :: map()
```

**Process**:
1. Check if tool name is "Write" or "Edit"
2. If not a file edit tool, return `%{}` immediately (no-op)
3. Extract file path from tool input
4. Get current session ID from `CurrentSession`
5. If no active session, return `%{}` (nothing to track)
6. Store the edited file path in session state via `Sessions.add_edited_file/2`
7. Return `%{}` to allow tool execution to proceed

**Test Assertions**:
- returns empty map for Write tool (allows proceed)
- returns empty map for Edit tool (allows proceed)
- returns empty map for non-edit tools (Read, Bash, etc.)
- extracts file_path from Write tool input
- extracts file_path from Edit tool input
- stores file path in session state
- handles missing session gracefully (no error)
- handles missing file_path in input gracefully
- does not store duplicate paths for same file edited multiple times

### run_and_output/1

Run hook and output JSON result to stdout for hook protocol.

```elixir
@spec run_and_output(hook_input :: map()) :: :ok
```

**Process**:
1. Call `run/1` with hook input
2. Encode result as JSON and output to stdout
3. Return `:ok`

**Test Assertions**:
- outputs {} for all cases (never blocks tool use)

## Hook Input Format

The hook receives a map with tool use information:

```elixir
%{
  "tool" => "Write" | "Edit" | "Read" | ...,
  "input" => %{
    "file_path" => "/path/to/file.ex",
    # other tool-specific params
  }
}
```

## Session State

Requires `Sessions` context to support:

```elixir
Sessions.add_edited_file(session_id, file_path) :: :ok | {:error, term()}
Sessions.get_edited_files(session_id) :: [Path.t()]
```

## Dependencies

- CodeMySpec.Sessions
- CodeMySpec.Sessions.CurrentSession
