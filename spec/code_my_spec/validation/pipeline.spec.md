# CodeMySpec.Validation.Pipeline

Runs the generic validation pipeline on a set of files. Categorizes files by type, compiles the project, then runs tests, static analysis (Credo, Sobelow), BDD specs, and spec document validation. Clears stale problems per-source before each validator step, then returns a flat list of all new problems found.

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
- **All Elixir files** (`.ex`, `.exs`): Credo, Sobelow

**Stale Problem Clearing**:

Problems are persisted to the database so downstream consumers (e.g. `TestStatusChecker`, `TaskEvaluator`) can query them. When a validator re-checks files and finds no issues, the previously persisted problems for those files must be cleared — otherwise resolved issues persist as false failures.

Clearing is **source-scoped**: each validator only clears problems matching its own source identifier for the files it checks. This prevents one validator from accidentally wiping another validator's results.

Clearing strategy per validator:
- **Tests**: Clear `source_type: :test` (excluding `source: "spex"`) for `test_files`
- **Credo**: Clear `source: "credo"` for `elixir_files`
- **Sobelow**: Clear `source: "sobelow"` for `elixir_files`
- **Spex**: Clear `source: "spex"` for `spex_files`
- **Spec validation**: Clear `source: "spec_validation"` for `spec_files`
- **Compiler errors** (on compilation failure): Clear `source: "compiler"` project-wide before inserting compilation error

This requires `Problems.clear_problems_for_source/3` — a new function in `ProblemRepository` that deletes problems matching a source filter + file paths list.

## Functions

### run/3

Run the full validation pipeline on a set of files.

```elixir
@spec run(Scope.t(), [Path.t()], keyword()) :: [Problem.t()]
```

**Process**:
1. If files empty, return `[]`
2. Categorize files by type
3. Clear stale problems for all categorized file groups (one clear per source)
4. Compile project (via `scope.cwd`)
5. On compilation failure: clear stale compiler problems, return compilation error
6. Run tests on `test_files`
7. Run Credo on `elixir_files`
8. Run Sobelow on `elixir_files`
9. Run spex on `spex_files`
10. Validate `spec_files`
11. Aggregate and return all problems

**Test Assertions**:
- returns [] when no files provided
- returns [] when all files pass validation
- returns problems when any validator finds issues
- runs validators in order: compile, tests, credo, sobelow, spex, spec
- aggregates problems from all validators
- handles individual validator failures gracefully (continues with others)
- short-circuits on compilation failure
- clears stale test problems for test_files before running tests
- clears stale credo problems for elixir_files before running credo
- clears stale sobelow problems for elixir_files before running sobelow
- clears stale spex problems for spex_files before running spex
- clears stale spec_validation problems for spec_files before validating specs
- clears stale compiler problems on compilation failure

### categorize_files/1

Categorize a list of file paths by validator type.

```elixir
@spec categorize_files([Path.t()]) :: %{
  spec_files: [Path.t()],
  test_files: [Path.t()],
  spex_files: [Path.t()],
  code_files: [Path.t()],
  elixir_files: [Path.t()]
}
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
@spec compile_project(Scope.t() | nil) :: :ok | {:error, String.t()}
```

**Process**:
1. Extract project root from `scope.cwd`
2. Call `CodeMySpec.Compile.execute(cwd: project_root)`
3. Return `:ok` on success, `{:error, reason}` on failure
4. Skip compilation when scope is nil or has no cwd

**Test Assertions**:
- compiles project using CodeMySpec.Compile
- returns :ok on successful compilation
- returns {:error, reason} when compilation fails
- skips compilation when scope is nil

### run_tests/2

Run tests for modified test files.

```elixir
@spec run_tests([Path.t()], Scope.t() | nil) :: {:ok, [Problem.t()]}
```

**Process**:
1. Filter to only existing test files
2. Run tests via `CodeMySpec.Tests.execute/2`
3. Convert failures to Problem structs
4. When `execution_status: :error`, parse raw output for compiler warnings/errors and tag as `source: "compiler", source_type: :static_analysis`
5. Return `{:ok, problems}`

**Test Assertions**:
- returns {:ok, []} when no test files
- returns {:ok, []} when all tests pass
- returns {:ok, problems} with test failure problems
- filters non-existent test files
- handles test execution errors gracefully
- tags compiler errors from test execution as source_type: :static_analysis

### run_credo/2

Run Credo static analysis on Elixir files via StaticAnalysis.Runner.

```elixir
@spec run_credo([Path.t()], Scope.t() | nil) :: {:ok, [Problem.t()]}
```

**Process**:
1. Run `StaticAnalysis.run(scope, :credo, files: files)`
2. Filter problems to only those in provided files
3. Return `{:ok, problems}`
4. Skip when scope is nil

**Test Assertions**:
- returns {:ok, []} when no files
- returns {:ok, []} when no scope
- returns {:ok, []} when no issues found
- returns {:ok, problems} with Credo issues
- filters problems to only provided files

### run_sobelow/2

Run Sobelow security analysis via StaticAnalysis.Runner.

```elixir
@spec run_sobelow([Path.t()], Scope.t() | nil) :: {:ok, [Problem.t()]}
```

**Process**:
1. Run `StaticAnalysis.run(scope, :sobelow)`
2. Filter problems to only those in provided files
3. Return `{:ok, problems}`
4. Skip when scope is nil

**Test Assertions**:
- returns {:ok, []} when no files
- returns {:ok, []} when no scope
- returns {:ok, []} when no findings
- returns {:ok, problems} with security findings
- filters problems to only provided files

### run_spex/2

Run BDD specs for modified spex files.

```elixir
@spec run_spex([Path.t()], Scope.t() | nil) :: {:ok, [Problem.t()]}
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

## Dependencies

- CodeMySpec.BddSpecs
- CodeMySpec.Compile
- CodeMySpec.Documents
- CodeMySpec.Problems
- CodeMySpec.Problems.Problem
- CodeMySpec.StaticAnalysis
- CodeMySpec.Tests
