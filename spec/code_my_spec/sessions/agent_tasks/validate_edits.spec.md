# CodeMySpec.Sessions.AgentTasks.ValidateEdits

A Claude Code stop hook handler that validates files edited during an agent session. When Claude stops, this hook retrieves edited files from session state (populated by the TrackEdits post-tool-use hook), categorizes them by type (spec, test, code), runs the appropriate validators for each category, and returns actionable feedback so Claude can fix issues before the session terminates.

**File Type Validation Strategy**:
- **Spec files** (`.spec.md`): Schema validation via `Documents.create_dynamic_document/2`
- **Test files** (`_test.exs`): Static analysis (Credo) + test-specific checks
- **BDD spec files** (`_spex.exs`): Not validated yet (future: syntax validation)
- **Code files** (`.ex`, `.exs`): Static analysis (Credo, Sobelow) + SpecAlignment

## Functions

### run/1

Execute validation on files edited during a Claude Code session.

```elixir
@spec run(session_id :: integer()) :: {:ok, :valid} | {:error, [Problem.t()]}
```

**Process**:
1. Get edited files from session state via `Sessions.get_edited_files/1`
2. If no session found, return `{:ok, :valid}` (nothing to validate)
3. If no files were edited, return `{:ok, :valid}` immediately
4. Categorize files by type using `categorize_files/1`
5. For each category, run the appropriate validators:
   - Spec files: `validate_spec_files/1`
   - Test files: `validate_test_files/2`
   - BDD spec files: skipped (no validation yet)
   - Code files: `validate_code_files/2`
6. Aggregate all problems from all validators
7. If no problems found, return `{:ok, :valid}`
8. If problems found, return `{:error, problems}`

**Test Assertions**:
- returns {:ok, :valid} when session has no edited files
- returns {:ok, :valid} when all edited files pass validation
- returns {:ok, :valid} when session not found (nothing to validate)
- returns {:error, problems} when spec file fails schema validation
- returns {:error, problems} when test file has Credo issues
- returns {:error, problems} when code file has Credo issues
- returns {:error, problems} when code file has Sobelow issues
- returns {:error, problems} when code file fails SpecAlignment
- aggregates problems from multiple file types
- handles individual validator failures gracefully (continues with others)

### run_and_output/0

Run validation and output JSON result to stdout for hook protocol.

```elixir
@spec run_and_output() :: :ok
```

**Process**:
1. Get current session ID from `CurrentSession.get_session_id/0`
2. If no session, output `%{}` and return `:ok`
3. Call `run/1` with the session ID
4. Format the result using `format_output/1`
5. Encode as JSON and output to stdout
6. Return `:ok`

**Test Assertions**:
- outputs empty JSON object {} when no active session
- outputs empty JSON object {} when validation passes
- outputs {"decision": "block", "reason": "..."} when validation fails
- includes actionable problem descriptions in reason

### categorize_files/1

Categorize a list of file paths by type for validation dispatch.

```elixir
@spec categorize_files([Path.t()]) :: %{spec: [Path.t()], test: [Path.t()], spex: [Path.t()], code: [Path.t()]}
```

**Process**:
1. Iterate through file paths
2. Categorize each file:
   - Files ending in `.spec.md` → `:spec`
   - Files ending in `_test.exs` → `:test`
   - Files ending in `_spex.exs` → `:spex`
   - Files ending in `.ex` or `.exs` (non-test, non-spex) → `:code`
   - Other files → ignored (not validated)
3. Return map with categorized file lists

**Test Assertions**:
- categorizes .spec.md files as :spec
- categorizes _test.exs files as :test
- categorizes _spex.exs files as :spex
- categorizes .ex files as :code
- categorizes .exs files (non-test, non-spex) as :code
- ignores non-Elixir files (.js, .json, .md)
- handles empty list
- handles mixed file types

### validate_spec_files/1

Validate spec files against their document schemas.

```elixir
@spec validate_spec_files([Path.t()]) :: [Problem.t()]
```

**Process**:
1. For each spec file path:
   - Read file contents from disk
   - Determine document type from path using `document_type_from_path/1`
   - Validate using `Documents.create_dynamic_document/2`
   - Convert validation errors to Problem structs
2. Return list of all problems found

**Test Assertions**:
- returns empty list when all specs are valid
- returns problems for specs missing required sections
- returns problems for specs with disallowed sections
- includes file path in problem
- handles file read failures gracefully
- determines correct document type (context_spec vs spec)

### validate_test_files/2

Validate test files with test-specific checks.

```elixir
@spec validate_test_files([Path.t()], Scope.t()) :: [Problem.t()]
```

**Process**:
1. Run Credo analysis scoped to test files
2. Filter results to only edited test files
3. Return list of problems found

**Test Assertions**:
- returns empty list when tests have no issues
- returns Credo problems for test files
- filters to only edited test files
- handles analyzer failures gracefully

### validate_code_files/2

Validate code files with full static analysis suite.

```elixir
@spec validate_code_files([Path.t()], Scope.t()) :: [Problem.t()]
```

**Process**:
1. Run static analyzers: Credo, Sobelow, SpecAlignment
2. Filter results to only edited code files
3. Return aggregated list of problems

**Test Assertions**:
- returns empty list when code has no issues
- returns Credo problems for code files
- returns Sobelow problems for code files
- returns SpecAlignment problems for code files
- filters to only edited code files
- aggregates problems from all analyzers
- handles individual analyzer failures gracefully

### filter_problems_by_files/2

Filter a list of problems to only include those affecting specific files.

```elixir
@spec filter_problems_by_files([Problem.t()], [Path.t()]) :: [Problem.t()]
```

**Process**:
1. Take the list of problems and list of edited file paths
2. Return only problems where the problem's file path matches one of the edited files
3. Handle both absolute and relative path matching

**Test Assertions**:
- returns only problems matching edited file paths
- returns empty list when no problems match
- handles absolute path matching
- handles relative path matching
- handles path normalization differences

### document_type_from_path/1

Determine the document type for spec validation based on file path conventions.

```elixir
@spec document_type_from_path(file_path :: Path.t()) :: String.t()
```

**Process**:
1. Extract segments after `docs/spec/` in the path
2. If exactly 2 segments (project dir + file), return "context_spec"
3. Otherwise return "spec" for component-level specs

**Test Assertions**:
- returns "context_spec" for docs/spec/project/context.spec.md
- returns "spec" for docs/spec/project/context/component.spec.md
- returns "spec" for deeply nested component specs
- handles paths without docs/spec prefix

### format_output/1

Format validation results for Claude Code stop hook output.

```elixir
@spec format_output({:ok, :valid} | {:error, [Problem.t()]}) :: map()
```

**Process**:
1. For `{:ok, :valid}`, return `%{}` (empty map allows stop)
2. For `{:error, [:file_not_found]}`, return `%{}` (nothing to validate)
3. For `{:error, problems}`, return map with:
   - `"decision"` => `"block"`
   - `"reason"` => formatted actionable feedback listing all problems

**Test Assertions**:
- returns %{} for valid result
- returns %{} for file not found (nothing to validate)
- returns %{"decision" => "block", "reason" => message} for problems
- formats problems with file path, line number, and description
- groups problems by analyzer for readability
- includes fix suggestions when available from analyzer

### format_problems_as_feedback/1

Format a list of problems as actionable feedback for the agent.

```elixir
@spec format_problems_as_feedback([Problem.t()]) :: String.t()
```

**Process**:
1. Group problems by their source analyzer
2. For each group, format as a section with analyzer name
3. For each problem, include:
   - File path and line number
   - Problem description/message
   - Suggested fix if available
4. Return concatenated string suitable for agent feedback

**Test Assertions**:
- groups problems by analyzer
- includes file:line format for each problem
- includes problem message
- includes suggested fix when present
- produces readable multi-line output

## Dependencies

- CodeMySpec.Sessions
- CodeMySpec.Sessions.CurrentSession
- CodeMySpec.Documents
- CodeMySpec.StaticAnalysis.Runner
- CodeMySpec.Problems.Problem
- CodeMySpec.Users.Scope
