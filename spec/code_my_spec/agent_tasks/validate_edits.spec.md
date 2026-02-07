# CodeMySpec.AgentTasks.ValidateEdits

A Claude Code stop hook handler that validates files edited during an agent session. When Claude stops, this hook retrieves edited files from session state (populated by the TrackEdits post-tool-use hook), categorizes them by analyzer type, runs validators in sequence, and returns actionable feedback so Claude can fix issues before the session terminates.

**Validation Pipeline** (execution order):
1. **Compile** - Compile the project once upfront via `CodeMySpec.Compile`
2. **Tests** - Run tests for modified code files and modified test files
3. **Credo** - Run on all modified Elixir files (code + test + spex)
4. **Sobelow** - Run on all modified Elixir files
5. **Spex** - Run BDD specs for modified spex files
6. **Document validation** - Validate `.spec.md` files against schemas

**File Accumulation Strategy**:
- **Spec files** (`.spec.md`): Schema validation via `Documents.create_dynamic_document/2`
- **Test files**: Modified `_test.exs` files + test files corresponding to modified code files
- **Spex files** (`_spex.exs`): BDD spec execution via `mix spex`
- **All Elixir files** (`.ex`, `.exs`): Credo, Sobelow, SpecAlignment

**Cleanup**: Files that pass all their validators are removed from `FileEdits` tracking so they won't be re-validated on subsequent stops.

## Functions

### run/2

Execute validation on files edited during a Claude Code session.

```elixir
@spec run(session_id :: String.t(), opts :: keyword()) :: {:ok, :valid} | {:error, [Problem.t()]}
```

**Process** (with block):
```elixir
with {:ok, all_files} <- get_edited_files(session_id),
     {:ok, categorized} <- categorize_files(all_files),
     {:ok, project_root} <- find_project_root(all_files, opts),
     :ok <- compile_project(project_root),
     {:ok, test_problems} <- run_tests(categorized.test_files, project_root),
     {:ok, credo_problems} <- run_credo(categorized.elixir_files, project_root),
     {:ok, sobelow_problems} <- run_sobelow(categorized.elixir_files, project_root),
     {:ok, spex_problems} <- run_spex(categorized.spex_files, project_root),
     {:ok, spec_problems} <- validate_spec_files(categorized.spec_files) do
  all_problems = test_problems ++ credo_problems ++ sobelow_problems ++ spex_problems ++ spec_problems

  if all_problems == [] do
    # All files passed - remove from tracking
    FileEdits.remove_edited_files(session_id, all_files)
    {:ok, :valid}
  else
    # Some files failed - remove only the ones that passed
    failed_files = extract_failed_files(all_problems)
    passed_files = all_files -- failed_files
    FileEdits.remove_edited_files(session_id, passed_files)
    {:error, all_problems}
  end
end
```

**Test Assertions**:
- returns {:ok, :valid} when session has no edited files
- returns {:ok, :valid} when all edited files pass validation
- returns {:error, problems} when any validator finds issues
- runs validators in order: compile, test, credo, sobelow, spex, spec
- removes validated files from FileEdits tracking when they pass
- keeps failed files in FileEdits tracking for re-validation
- aggregates problems from all validators
- handles individual validator failures gracefully (continues with others)

### categorize_files/1

Categorize a list of file paths by validator type.

```elixir
@spec categorize_files([Path.t()]) :: {:ok, %{
  spec_files: [Path.t()],
  test_files: [Path.t()],
  spex_files: [Path.t()],
  code_files: [Path.t()],
  elixir_files: [Path.t()]
}}
```

**Process**:
1. Iterate through file paths and categorize:
   - `.spec.md` → `spec_files`
   - `_test.exs` → `test_files`
   - `_spex.exs` → `spex_files`
   - `.ex` (non-test, non-spex) → `code_files`
   - `.exs` (non-test, non-spex) → `code_files`
2. Build `elixir_files` = `code_files` ++ `test_files` ++ `spex_files`
3. For each code file, find corresponding test file and add to `test_files`
4. Return categorized map

**Test Assertions**:
- categorizes .spec.md files as spec_files
- categorizes _test.exs files as test_files
- categorizes _spex.exs files as spex_files
- categorizes .ex files as code_files
- categorizes .exs files (non-test, non-spex) as code_files
- builds elixir_files from code + test + spex
- maps lib/foo.ex to test/foo_test.exs and includes in test_files
- ignores non-Elixir files (.js, .json, .md without .spec)
- handles empty list

### compile_project/1

Compile the project once before running any validators.

```elixir
@spec compile_project(project_root :: Path.t()) :: :ok | {:error, String.t()}
```

**Process**:
1. Call `CodeMySpec.Compile.execute(cwd: project_root)`
2. Return `:ok` on success, `{:error, reason}` on failure

**Test Assertions**:
- compiles project using CodeMySpec.Compile
- returns :ok on successful compilation
- returns {:error, reason} when compilation fails

### run_tests/2

Run tests for modified test files.

```elixir
@spec run_tests([Path.t()], project_root :: Path.t()) :: {:ok, [Problem.t()]}
```

**Process**:
1. Filter to only existing test files
2. Run tests via `CodeMySpec.Tests.execute/2`
3. Convert failures to Problem structs
4. Return `{:ok, problems}`

**Test Assertions**:
- returns {:ok, []} when no test files
- returns {:ok, []} when all tests pass
- returns {:ok, problems} with test failure problems
- filters non-existent test files
- handles test execution errors gracefully

### run_credo/2

Run Credo static analysis on Elixir files.

```elixir
@spec run_credo([Path.t()], project_root :: Path.t()) :: {:ok, [Problem.t()]}
```

**Process**:
1. Check if Credo is available (deps/credo exists)
2. Run `mix credo suggest --format json --all-priorities --no-color` on files
3. Parse JSON output, extract issues
4. Convert to Problem structs
5. Return `{:ok, problems}`

**Test Assertions**:
- returns {:ok, []} when no files
- returns {:ok, []} when Credo not installed
- returns {:ok, []} when no issues found
- returns {:ok, problems} with Credo issues
- handles JSON parsing errors gracefully

### run_sobelow/2

Run Sobelow security analysis on Elixir files.

```elixir
@spec run_sobelow([Path.t()], project_root :: Path.t()) :: {:ok, [Problem.t()]}
```

**Process**:
1. Check if Sobelow is available (deps/sobelow exists)
2. Run `mix sobelow --format json --private`
3. Parse JSON output, extract findings
4. Convert to Problem structs
5. Return `{:ok, problems}`

**Test Assertions**:
- returns {:ok, []} when no files
- returns {:ok, []} when Sobelow not installed
- returns {:ok, []} when no findings
- returns {:ok, problems} with security findings
- handles JSON parsing errors gracefully

### run_spex/2

Run BDD specs for modified spex files.

```elixir
@spec run_spex([Path.t()], project_root :: Path.t()) :: {:ok, [Problem.t()]}
```

**Process**:
1. Run `BddSpecs.run_specs/2` on spex files
2. Convert failures to Problem structs
3. Return `{:ok, problems}`

**Test Assertions**:
- returns {:ok, []} when no spex files
- returns {:ok, []} when all specs pass
- returns {:ok, problems} with spex failures
- handles spex execution errors gracefully

### validate_spec_files/1

Validate spec files against their document schemas.

```elixir
@spec validate_spec_files([Path.t()]) :: {:ok, [Problem.t()]}
```

**Process**:
1. For each spec file path:
   - Read file contents from disk
   - Determine document type from path using `document_type_from_path/1`
   - Validate using `Documents.create_dynamic_document/2`
   - Convert validation errors to Problem structs
2. Return `{:ok, problems}`

**Test Assertions**:
- returns {:ok, []} when all specs are valid
- returns {:ok, problems} for specs missing required sections
- returns {:ok, problems} for specs with disallowed sections
- includes file path in problem
- handles file read failures gracefully
- determines correct document type (context_spec vs spec)

### map_code_to_test_files/2

Map code files to their corresponding test files.

```elixir
@spec map_code_to_test_files([Path.t()], project_root :: Path.t()) :: [Path.t()]
```

**Process**:
1. For each code file in lib/:
   - Convert `lib/foo/bar.ex` → `test/foo/bar_test.exs`
2. Filter to only existing test files
3. Return list of test file paths

**Test Assertions**:
- maps lib/foo.ex to test/foo_test.exs
- maps lib/foo/bar.ex to test/foo/bar_test.exs
- filters non-existent test files
- returns empty list for non-lib files

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

### extract_failed_files/1

Extract unique file paths from a list of problems.

```elixir
@spec extract_failed_files([Problem.t()]) :: [Path.t()]
```

**Process**:
1. Map problems to their file_path field
2. Remove nils and duplicates
3. Return unique list of failed file paths

**Test Assertions**:
- extracts unique file paths from problems
- handles problems without file_path
- returns empty list for empty problems

### format_output/1

Format validation results for Claude Code stop hook output.

```elixir
@spec format_output({:ok, :valid} | {:error, [Problem.t()]}) :: map()
```

**Process**:
1. For `{:ok, :valid}`, return `%{}` (empty map allows stop)
2. For `{:error, problems}`, return map with:
   - `"decision"` => `"block"`
   - `"reason"` => formatted actionable feedback listing all problems

**Test Assertions**:
- returns %{} for valid result
- returns %{"decision" => "block", "reason" => message} for problems
- formats problems with file path, line number, and description
- groups problems by analyzer for readability

## Dependencies

- CodeMySpec.FileEdits
- CodeMySpec.Compile
- CodeMySpec.Tests
- CodeMySpec.BddSpecs
- CodeMySpec.Documents
- CodeMySpec.Problems.Problem
- CodeMySpec.Problems.ProblemRenderer
