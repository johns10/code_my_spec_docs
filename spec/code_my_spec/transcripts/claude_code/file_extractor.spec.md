# CodeMySpec.Transcripts.ClaudeCode.FileExtractor

Analyzes Claude Code transcript entries to extract file modification information. Identifies Edit and Write tool calls and extracts their file_path parameters. Also provides utilities for extracting all tool calls or filtering by tool name.

## Functions

### extract_edited_files/1

Extract the list of files that were edited during a Claude Code session.

```elixir
@spec extract_edited_files(Transcript.t()) :: [Path.t()]
```

**Process**:
1. Get all tool calls from the transcript using get_tool_calls/1
2. Filter for Edit and Write tool calls by name
3. Extract the "file_path" parameter from each tool call's input map
4. Remove nil values (in case file_path is missing from malformed entries)
5. Return unique file paths using Enum.uniq/1 to deduplicate repeated edits to same file

**Test Assertions**:
- returns empty list for transcript with no tool calls
- returns empty list for transcript with only non-file-modifying tool calls (e.g., Bash, Read)
- extracts file_path from Edit tool calls
- extracts file_path from Write tool calls
- extracts file paths from both Edit and Write tool calls in same transcript
- returns unique paths when same file is edited multiple times
- returns unique paths when same file is written multiple times
- handles tool calls with missing file_path parameter gracefully
- preserves chronological order of first occurrence for each unique file

### get_tool_calls/1

Extract all tool calls from a transcript.

```elixir
@spec get_tool_calls(Transcript.t()) :: [ToolCall.t()]
```

**Process**:
1. Get entries from the transcript struct
2. Filter entries where type is "assistant" (tool calls come from assistant responses)
3. Flat map over content blocks in each entry
4. Filter for content blocks with type "tool_use"
5. Map each tool_use block to a ToolCall struct extracting:
   - name: the tool name string
   - input: the input parameters map
   - id: the tool use ID for correlation with results

**Test Assertions**:
- returns empty list for empty transcript
- returns empty list for transcript with only user/system messages
- extracts single tool call from transcript
- extracts multiple tool calls from single entry
- extracts tool calls across multiple entries
- preserves chronological order of tool calls
- extracts tool name correctly
- extracts input parameters map correctly
- extracts tool use id for result correlation
- handles entries with mixed content types (text and tool_use)

### get_tool_calls/2

Extract tool calls filtered by tool name.

```elixir
@spec get_tool_calls(Transcript.t(), tool_name :: String.t()) :: [ToolCall.t()]
```

**Process**:
1. Get all tool calls from transcript using get_tool_calls/1
2. Filter tool calls where name matches the provided tool_name exactly

**Test Assertions**:
- returns empty list when transcript has no tool calls
- returns empty list when no tool calls match the specified name
- returns matching tool calls for valid tool name
- filters to only Edit tool calls when specified
- filters to only Write tool calls when specified
- filters to only Read tool calls when specified
- filters to only Bash tool calls when specified
- matches tool name exactly (case-sensitive)
- preserves chronological order of filtered tool calls

## Dependencies

- CodeMySpec.Transcripts.ClaudeCode.Transcript
- CodeMySpec.Transcripts.ClaudeCode.ToolCall
- CodeMySpec.Transcripts.ClaudeCode.Entry