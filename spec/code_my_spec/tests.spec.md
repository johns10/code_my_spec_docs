# CodeMySpec.Tests

The Tests context provides a functional interface for executing ExUnit tests with real-time streaming and structured result parsing. It executes mix test commands asynchronously via Erlang ports, streams JSON-formatted test events, and returns parsed test run data including statistics, failures, and passes.

## Type

context

## Components

### CodeMySpec.Tests.TestRun

Embedded schema representing a complete test execution run with metadata, statistics, and test results.

### CodeMySpec.Tests.TestStats

Embedded schema capturing test run statistics including duration, pass/fail counts, and timing information.

### CodeMySpec.Tests.TestResult

Embedded schema representing individual test results with status and error details.

### CodeMySpec.Tests.TestError

Embedded schema capturing test failure information including file, line number, and error message.

## Functions

### execute/2

Execute mix test synchronously with real-time streaming and JSON result parsing.

```elixir
@spec execute(args :: [String.t()], interaction_id :: String.t()) :: map()
```

**Process**:
1. Create temporary file for clean JSON test results output
2. Open Erlang port with mix test command, configuring environment variables for JSON streaming
3. Stream stdout from port, parsing JSON events and updating InteractionRegistry status
4. Read clean JSON test results from temporary file
5. Clean up temporary file
6. Return result map with status and test results data

**Test Assertions**:
- executes mix test with provided arguments
- creates temporary file for JSON output
- sets MIX_ENV to test
- sets EXUNIT_JSON_OUTPUT_FILE environment variable
- sets EXUNIT_JSON_STREAMING to true
- streams output and updates interaction status with JSON events
- reads JSON results from temporary file
- cleans up temporary file after reading
- returns map with :ok status and test_results data
- handles file read errors gracefully with empty JSON fallback
- accumulates stdout lines during streaming
- handles both full lines (eol) and partial lines (noeol)
- waits for port exit status before returning
- parses JSON events and updates InteractionRegistry with test events

## Dependencies

- Logger
- Briefly
- Jason
