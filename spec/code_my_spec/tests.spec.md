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

## Dependencies

- Logger
- Briefly
- Jason
