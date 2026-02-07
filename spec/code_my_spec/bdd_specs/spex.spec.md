# CodeMySpec.BddSpecs.Spex

**Type**: component

Executes Spex BDD specifications via `mix spex` and returns structured results. Wraps command execution with JSONL output parsing, capturing scenario pass/fail status and step-level failure details.

## Functions

### execute/2

Execute mix spex synchronously and parse results.

```elixir
@spec execute(args :: [String.t()], opts :: keyword()) ::
        {:ok, [Failure.t()], integer()} | {:error, {:parse_error, String.t()}}
```

**Options**:
- `:project_root` - Project root directory to run tests from (defaults to cwd)
- `:quiet` - Suppress console output (default: false)

**Process**:
1. Get project_root from opts or File.cwd!()
2. Generate temp file path: `Path.join(System.tmp_dir!(), "spex_output_#{System.unique_integer([:positive])}.jsonl")`
3. Build args: `["spex" | args] ++ ["--jsonl=#{temp_file}"]`
4. Add `--quiet` flag if option set
5. Execute `System.cmd("mix", args, cd: project_root, stderr_to_stdout: true)`
6. Read and parse JSONL file for failures
7. Clean up temp file
8. Return `{:ok, failures, exit_code}` or `{:error, {:parse_error, reason}}`

**Test Assertions**:
- Not directly tested (would require mocking or real project setup)
- Integration testing handled via cached JSONL fixtures in TestAdapter

### parse_jsonl/1

Parses JSONL failure file into Failure structs.

```elixir
@spec parse_jsonl(String.t()) :: {:ok, [Failure.t()]} | {:error, term()}
```

**Process**:
1. Read file contents
2. Return `{:ok, []}` if file doesn't exist or is empty
3. Split by newline, trim empty lines
4. Decode each line as JSON
5. Map to Failure structs
6. Return `{:ok, failures}`

**Test Assertions**:
- parses multiple failure lines
- returns {:ok, []} for empty file
- returns {:ok, []} when file doesn't exist
- decodes all failure fields correctly
- returns {:error, _} for malformed JSON
- parses real passing spex output from cached run (via TestAdapter)
- parses real failing spex output from cached run (via TestAdapter)

## Components

### Spex.Failure

Struct representing a single test failure with BDD context.

**Fields**:
- `spex` - string, name of the spex (test group)
- `scenario` - string | nil, scenario name or nil if outside scenario
- `steps` - list of Step structs
- `error` - Error struct with failure details

### Spex.Step

Struct representing a BDD step executed during the test.

**Fields**:
- `type` - string, "Given", "When", "Then", or "And"
- `description` - string, step description text
- `status` - string, "passed" or "failed"

### Spex.Error

Struct representing the error details of a failure.

**Fields**:
- `message` - string, error/assertion message
- `file` - string | nil, source file path
- `line` - integer | nil, line number
- `stacktrace` - list of stacktrace entry maps
- `left` - string | nil, left side of assertion (assertion errors only)
- `right` - string | nil, right side of assertion (assertion errors only)

## Dependencies

None (uses only stdlib and Jason)
