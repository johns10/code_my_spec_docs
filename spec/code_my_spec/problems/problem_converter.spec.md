# CodeMySpec.Problems.ProblemConverter

Utility module for transforming heterogeneous tool outputs (Credo, Dialyzer, compiler warnings, test failures) into normalized Problem structs. Provides consistent data transformation regardless of source tool format.

## Dependencies

- CodeMySpec.Problems.Problem

## Functions

### from_credo/1

Transforms Credo analysis results into normalized Problem structs.

```elixir
@spec from_credo(map()) :: Problem.t()
```

**Process**:
1. Extract severity from Credo priority/category
2. Map Credo check name to category
3. Set source to "credo" and source_type to :static_analysis
4. Build Problem struct with normalized fields

**Test Assertions**:
- correctly maps Credo priorities to severity levels
- extracts file path and line number
- preserves original Credo check name in rule field
- stores Credo-specific metadata

### from_dialyzer/1

Transforms Dialyzer warnings into normalized Problem structs.

```elixir
@spec from_dialyzer(map()) :: Problem.t()
```

**Process**:
1. Set severity based on warning type (always :warning for Dialyzer)
2. Extract file path and line from warning location
3. Set source to "dialyzer" and source_type to :static_analysis
4. Parse warning message and categorize as "type"

**Test Assertions**:
- sets severity to :warning
- extracts location information correctly
- categorizes all Dialyzer output as type Problems
- preserves full warning message

### from_compiler/1

Transforms compiler warnings/errors into normalized Problem structs.

```elixir
@spec from_compiler(map()) :: Problem.t()
```

**Process**:
1. Map compiler severity (warning/error) to Problem severity
2. Extract file, line, and message from compiler output
3. Set source to "compiler" and source_type to :static_analysis
4. Categorize based on warning type

**Test Assertions**:
- distinguishes between compiler warnings and errors
- handles compilation errors with appropriate severity
- extracts multiline error messages
- categorizes unused variable warnings separately from other Problems

### from_test_failure/1

Transforms ExUnit test failure into normalized Problem struct.

```elixir
@spec from_test_failure(CodeMySpec.Tests.TestError.t()) :: Problem.t()
```

**Process**:
1. Set severity to :error for test failures
2. Extract file path and line from test location
3. Set source to "exunit" and source_type to :test
4. Capture assertion failure details in message and metadata

**Test Assertions**:
- sets severity to :error for all test failures
- extracts test file location
- includes test name in message
- preserves assertion details in metadata
- categorizes as "test_failure"
