# CodeMySpecCli.Hooks.ValidateEdits

A Claude Code stop hook handler that validates spec files written or edited during an agent session. When Claude stops, this hook parses the session transcript to identify edited `.spec.md` files, validates each against its document schema using `Documents.create_dynamic_document/2`, and returns validation errors so Claude can revise non-conforming specs before the session fully terminates.

## Functions

### run/1

Execute validation of spec files edited during a Claude Code session.

```elixir
@spec run(transcript_path :: Path.t()) :: {:ok, :valid} | {:error, validation_errors :: [String.t()]}
```

**Process**:
1. Parse the Claude Code transcript at the given path using `Transcripts.parse/1`
2. Extract all edited file paths using `Transcripts.extract_edited_files/1`
3. Filter for spec files (paths ending with `.spec.md`)
4. If no spec files were edited, return `{:ok, :valid}` immediately
5. For each spec file path:
   - Read the file contents from disk
   - Determine the document type from the file path using `document_type_from_path/1`
   - Validate using `Documents.create_dynamic_document/2`
   - Collect validation errors with file path context
6. If all validations pass, return `{:ok, :valid}`
7. If any validations fail, return `{:error, [error_messages]}`

**Test Assertions**:
- returns {:ok, :valid} when transcript has no file edits
- returns {:ok, :valid} when transcript has only non-spec file edits
- returns {:ok, :valid} when single valid spec file was edited
- returns {:ok, :valid} when multiple valid spec files were edited
- returns {:error, [errors]} when spec file is missing required sections
- returns {:error, [errors]} when spec file has disallowed sections
- includes file path in error message for identification
- validates all spec files before returning collected errors
- handles transcript parse failure gracefully
- handles file read failure gracefully (file deleted after edit)
- returns {:error, [:file_not_found]} when transcript path does not exist

### validate_spec_file/1

Validate a single spec file against its document schema.

```elixir
@spec validate_spec_file(file_path :: Path.t()) :: :ok | {:error, reason :: String.t()}
```

**Process**:
1. Read file contents from disk
2. Determine document type from file path using `document_type_from_path/1`
3. Call `Documents.create_dynamic_document/2` with contents and document type
4. Return `:ok` if validation succeeds
5. Return `{:error, reason}` with the validation error message if validation fails

**Test Assertions**:
- returns :ok for valid spec document
- returns {:error, reason} for spec missing required sections
- returns {:error, reason} for spec with invalid sections
- returns {:error, reason} when file does not exist
- returns {:error, reason} when file is empty
- determines document type correctly from path

### document_type_from_path/1

Determine the document type for validation based on file path conventions.

```elixir
@spec document_type_from_path(file_path :: Path.t()) :: String.t()
```

**Process**:
1. Extract the parent directory name from the file path
2. Check if the directory indicates a context-level spec (file name matches directory name pattern)
3. Return "context_spec" for context-level specs
4. Return "spec" for component-level specs (default)

**Test Assertions**:
- returns "context_spec" for top-level context spec files
- returns "spec" for component-level spec files
- returns "spec" for nested component spec files
- handles various path depths correctly

### spec_file?/1

Check if a file path represents a spec file.

```elixir
@spec spec_file?(file_path :: Path.t()) :: boolean()
```

**Process**:
1. Check if the file path ends with `.spec.md`
2. Return `true` if it does, `false` otherwise

**Test Assertions**:
- returns true for paths ending in .spec.md
- returns false for paths ending in .md (non-spec markdown)
- returns false for paths ending in .ex
- returns false for paths without extension

### format_output/1

Format validation results for Claude Code stop hook output.

```elixir
@spec format_output({:ok, :valid} | {:error, [String.t()]}) :: map()
```

**Process**:
1. For `{:ok, :valid}`, return `%{"continue" => true}`
2. For `{:error, errors}`, return map with:
   - `"continue"` => `false`
   - `"stopReason"` => formatted error message listing all validation failures

**Test Assertions**:
- returns %{"continue" => true} for valid result
- returns %{"continue" => false, "stopReason" => message} for errors
- formats multiple errors as readable list in stopReason
- single error returns concise message

## Dependencies

- CodeMySpec.Transcripts
- CodeMySpec.Transcripts.ClaudeCode.Transcript
- CodeMySpec.Documents