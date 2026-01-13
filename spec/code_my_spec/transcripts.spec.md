# CodeMySpec.Transcripts

Parses Claude Code transcript JSONL files to extract tool usage information. Transcripts are append-only logs of agent interactions, stored as newline-delimited JSON. This context provides utilities for reading transcripts and extracting specific data such as file paths modified by Write or Edit tool calls, enabling hooks to validate files written during agent sessions.

## Delegates

- parse/1: Transcripts.ClaudeCode.Parser.parse/1
- extract_edited_files/1: Transcripts.ClaudeCode.FileExtractor.extract_edited_files/1
- get_tool_calls/1: Transcripts.ClaudeCode.FileExtractor.get_tool_calls/1
- get_tool_calls/2: Transcripts.ClaudeCode.FileExtractor.get_tool_calls/2

## Functions

## Dependencies

- Jason

## Components

### CodeMySpec.Transcripts.ClaudeCode.Transcript

Struct representing a parsed Claude Code transcript. Contains the file path and list of entries.

### CodeMySpec.Transcripts.ClaudeCode.Entry

Struct representing a single line entry in the Claude Code transcript JSONL. Maps to the raw JSON structure with type, role, and content fields.

### CodeMySpec.Transcripts.ClaudeCode.ToolCall

Struct representing a Claude Code tool invocation extracted from the transcript. Contains the tool name, input parameters map, and optional result.

### CodeMySpec.Transcripts.ClaudeCode.Parser

Handles Claude Code JSONL file reading and line-by-line JSON parsing into Entry structs. Assembles the final Transcript struct.

### CodeMySpec.Transcripts.ClaudeCode.FileExtractor

Analyzes Claude Code transcript entries to extract file modification information. Identifies Edit and Write tool calls and extracts their file_path parameters.
