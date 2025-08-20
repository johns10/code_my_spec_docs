# Tests

## Purpose
Executes and parses ExUnit test results for project validation and analysis.

## Entity Ownership
- TestRun embedded schema with execution metadata
- TestResult embedded schema for individual test outcomes  
- TestStats embedded schema for aggregate statistics
- TestError embedded schema for failure details

## Public API

```elixir
@type run_opts :: [
  timeout: pos_integer(),
  include: [atom()],
  exclude: [atom()], 
  seed: non_neg_integer(),
  max_failures: pos_integer()
]

@type execution_status :: :success | :failure | :timeout | :error

# Test Execution
@spec run_tests(String.t(), run_opts()) :: {:ok, TestRun.t()} | {:error, term()}
@spec run_tests_async(String.t(), run_opts()) :: Task.t()

# JSON Output Processing  
@spec parse_json_output(String.t()) :: {:ok, TestRun.t()} | {:error, term()}
@spec from_project_path(String.t()) :: {:ok, TestRun.t()} | {:error, :no_results | term()}

# Result Access (simple filters - stats already contain counts)
@spec failed_tests(TestRun.t()) :: [TestResult.t()]
@spec passed_tests(TestRun.t()) :: [TestResult.t()]
@spec success?(TestRun.t()) :: boolean()
```

## State Management Strategy

### In-Memory Processing
- All test data stored in embedded schemas for transient analysis
- No persistence - TestRun structs exist only during processing
- Pattern matching on JSON events to build complete TestRun structure

### Command Execution
- Spawns `mix test` process with ExUnit JSON formatter
- Captures complete output as string for parsing
- Timeout handling with graceful process termination

## Component Diagram

```
Tests
├── TestRun (embedded schema)
├── TestStats (embedded - aggregated counts)
├── TestResult list (embedded - individual outcomes)
├── TestError (embedded - failure details)
├── CommandBuilder
│   └── mix test option construction
├── ProcessExecutor
│   └── System.cmd with timeout handling
└── JsonParser
    ├── event line parsing
    └── TestRun construction from events
```

## Dependencies

- **Ecto**: Embedded schema validation and structure
- **Jason**: JSON parsing for ExUnit formatter output
- **System**: Process execution for mix test commands

## Execution Flow

1. **Command Construction**: Build mix test command with formatter and options
2. **Process Execution**: Execute command in project directory with timeout
3. **Output Capture**: Collect complete stdout/stderr as raw string
4. **JSON Parsing**: Parse each line as JSON event array
5. **Event Processing**: Pattern match events to build TestRun structure
6. **Result Assembly**: Combine metadata, stats, and individual results

### Error Handling
- Process timeouts return `:timeout` execution status
- JSON parsing errors return `{:error, reason}` tuples
- Command failures captured with exit codes and error status