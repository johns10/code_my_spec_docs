# ClientUtils.TestFormatter.JsonFormatter

Handles formatting of ExUnit test results into JSON-compatible maps.

## format_stats(map, run_us, load_us)

Receives test stats and formats them to JSON

## format_suite_end_event(stats)

Formats the suite end streaming event.

## format_suite_result(stats, tests, failures, pending)

Formats the final suite result with all test data.

## format_suite_start_event(start_time)

Formats the suite start streaming event.

## format_test_case_failure(test_case, failures)

Receives a test case and formats its failure.

## format_test_event(type, test_result)

Formats a streaming event for a test.

## format_test_failure(test, failures)

Receives a test and formats its failure.

## format_test_pass(test)

Receives a test and formats its information

## format_test_pending(test)

Formats a skipped or excluded test as pending.