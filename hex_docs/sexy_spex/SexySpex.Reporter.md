# SexySpex.Reporter

Handles reporting and output formatting for spex execution.

Provides a clean interface for tracking spex execution progress and
generating human-readable output.

## Quiet Mode (Default)

Reporter output is suppressed by default. Use `--verbose` flag to enable
detailed Reporter output alongside ExUnit results.

## JSONL Output

Use `--jsonl` flag to output test failures as JSONL for machine parsing.
Each failure includes BDD step context (Given/When/Then) alongside error info.

## scenario_failed(name, error, stacktrace \\ [])

Reports failure of a scenario.

## scenario_passed(name)

Reports successful completion of a scenario.

## spex_failed(name, error, stacktrace \\ [])

Reports failure of a specification.

## spex_passed(name)

Reports successful completion of a specification.

## start_scenario(name)

Starts reporting for a new scenario.

## start_spex(name, opts \\ [])

Starts reporting for a new specification.

## step(type, description)

Reports execution of a Given-When-Then step.