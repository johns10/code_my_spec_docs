# CodeMySpec.Transcripts.ClaudeCode.Parser

**Type**: module

Handles Claude Code JSONL file reading and line-by-line JSON parsing into Entry structs. Assembles the final Transcript struct.

Claude Code stores conversation transcripts as JSONL (newline-delimited JSON) files where each line represents a single interaction entry. This parser reads these files, validates the JSON structure, converts each line into an Entry struct, and constructs a Transcript struct containing all parsed entries in order.

## Delegates

None

## Functions

### parse/1

Parses a Claude Code transcript JSONL file from the given file path into a Transcript struct.

```elixir
@spec parse(Path.t()) :: {:ok, Transcript.t()} | {:error, term()}
```

**Process**:
1. Check if file exists at the provided path
2. If file does not exist, return error tuple with :file_not_found
3. Read file contents as a binary string
4. If file read fails, return error tuple with :read_error and reason
5. Split content by newlines, filtering out empty lines
6. Parse each line as JSON using Jason.decode/1
7. If any line fails JSON parsing, return error tuple with :json_parse_error, line number, and reason
8. Convert each decoded JSON map into an Entry struct
9. Build a Transcript struct with the file path and list of Entry structs
10. Return success tuple with the Transcript struct

**Test Assertions**:
- returns error tuple with :file_not_found for non-existent file path
- returns error tuple with :json_parse_error for malformed JSON line
- includes line number in error for malformed JSON
- parses valid JSONL transcript into Transcript struct
- handles empty transcript file returning Transcript with empty entries list
- preserves entry order matching line order in file
- handles transcript with single entry
- handles transcript with multiple entries
- ignores empty lines between entries
- handles trailing newline in file
- handles entries with nested JSON structures
- parses entry with type field
- parses entry with role field
- parses entry with content field
- handles entries with tool_use content blocks
- handles entries with text content blocks
- handles entries with tool_result content blocks
- works with absolute file paths
- works with relative file paths
- handles unicode characters in transcript content
- handles very long lines without truncation
- handles special characters in JSON strings
- returns consistent error structure for all error types

### parse_line/2

Parses a single JSONL line into an Entry struct.

```elixir
@spec parse_line(String.t(), pos_integer()) :: {:ok, Entry.t()} | {:error, term()}
```

**Process**:
1. Attempt to decode JSON string using Jason.decode/1
2. If decoding fails, return error tuple with :json_parse_error and line number
3. Extract type, role, and content fields from decoded map
4. Construct Entry struct with extracted fields
5. Return success tuple with Entry struct

**Test Assertions**:
- parses valid JSON line into Entry struct
- returns error for invalid JSON syntax
- includes line number in error response
- extracts type field from JSON
- extracts role field from JSON
- extracts content field from JSON
- handles missing optional fields
- handles null values in JSON
- handles nested content structures

### read_lines/1

Reads a JSONL file and returns non-empty lines.

```elixir
@spec read_lines(Path.t()) :: {:ok, [String.t()]} | {:error, term()}
```

**Process**:
1. Read file contents using File.read/1
2. If file read fails, return error tuple with reason
3. Split contents by newline character
4. Filter out empty and whitespace-only lines
5. Return success tuple with list of line strings

**Test Assertions**:
- reads file and returns list of non-empty lines
- filters out empty lines
- filters out whitespace-only lines
- returns error for non-existent file
- returns empty list for empty file
- handles files with only whitespace
- preserves line content without modification
- handles various newline formats (LF, CRLF)

## Dependencies

- Jason
- CodeMySpec.Transcripts.ClaudeCode.Transcript
- CodeMySpec.Transcripts.ClaudeCode.Entry
