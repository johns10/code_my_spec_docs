# CodeMySpec.Transcripts.ClaudeCode.Transcript

Struct representing a parsed Claude Code transcript. Contains the file path and list of entries parsed from a JSONL transcript file. This struct is the primary data structure returned by the Parser module and consumed by the FileExtractor and other analysis modules.

## Fields

| Field   | Type                 | Required | Description                                      | Constraints                |
| ------- | -------------------- | -------- | ------------------------------------------------ | -------------------------- |
| path    | string               | Yes      | Absolute file path to the source JSONL file      | Must be a valid file path  |
| entries | list(Entry.t())      | Yes      | List of parsed Entry structs from the transcript | Defaults to empty list     |

## Functions

### new/1

Create a new Transcript struct from keyword options.

```elixir
@spec new(keyword()) :: t()
```

**Process**:
1. Accept keyword list with :path and optional :entries
2. Build struct with provided values, defaulting entries to empty list

**Test Assertions**:
- creates struct with path and empty entries by default
- creates struct with provided entries list
- raises when path is not provided

### new/2

Create a new Transcript struct from path and entries.

```elixir
@spec new(Path.t(), [Entry.t()]) :: t()
```

**Process**:
1. Accept path as first argument and entries list as second
2. Build struct with the provided values

**Test Assertions**:
- creates struct with given path and entries
- accepts empty entries list

## Dependencies

- CodeMySpec.Transcripts.ClaudeCode.Entry