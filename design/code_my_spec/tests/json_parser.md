# JsonParser

## Purpose
Parses ExUnit JSON formatter output into structured TestRun data, designed as a pure functional core that transforms raw JSON strings into validated embedded schemas.

## Responsibilities
- Parse JSON event lines from ExUnit formatter output
- Transform JSON events into TestRun embedded schemas
- Validate and structure test results, errors, and statistics
- Handle malformed JSON with clear error reporting

## Design Philosophy

### Functional Core Pattern
Following the functional core/imperative shell pattern:
- **Pure Functions**: All parsing logic is side-effect free with deterministic outputs
- **Immutable Transformations**: JSON events flow through transformation pipeline
- **No Side Effects**: Only data transformation, no I/O or process spawning
- **Composable**: Small functions that compose into larger parsing workflows

### Fail Fast with Structured Errors
- Invalid JSON returns `{:error, :invalid_json, details}` immediately
- Unknown event types return `{:error, :unknown_event, event}` for debugging
- Malformed event data returns `{:error, :malformed_event, context}`
- All errors preserve original input for troubleshooting

### Single Responsibility
- Only handles JSON parsing and TestRun construction
- No command execution or file I/O
- Clear separation from ProcessExecutor and CommandBuilder
- Focused on data transformation pipeline

## Public API

```elixir
@type json_event :: 
  {:start, %{including: [String.t()], excluding: [String.t()]}} |
  {:pass, %{title: String.t(), fullTitle: String.t()}} |
  {:fail, %{title: String.t(), fullTitle: String.t(), err: map()}} |
  {:end, %{duration: float(), passes: integer(), failures: integer()}}

@type parse_error :: 
  {:invalid_json, %{line: String.t(), reason: term()}} |
  {:unknown_event, %{event: term()}} |
  {:malformed_event, %{event: term(), field: atom()}}

@spec parse_json_output(String.t()) :: {:ok, TestRun.t()} | {:error, parse_error()}
@spec parse_json_line(String.t()) :: {:ok, json_event()} | {:error, parse_error()}
@spec build_test_run_from_events([json_event()], map()) :: TestRun.t()
@spec validate_event_sequence([json_event()]) :: :ok | {:error, :invalid_sequence}
```

## Implementation Strategy

### Event Parsing Pipeline
```elixir
def parse_json_output(raw_output) do
  raw_output
  |> String.split("\n", trim: true)
  |> Enum.reduce_while({:ok, []}, &parse_and_accumulate/2)
  |> case do
    {:ok, events} -> build_test_run_from_events(events)
    {:error, reason} -> {:error, reason}
  end
end

defp parse_and_accumulate(line, {:ok, acc}) do
  case parse_json_line(line) do
    {:ok, event} -> {:cont, {:ok, [event | acc]}}
    {:error, reason} -> {:halt, {:error, reason}}
  end
end
```

### JSON Event Processing
```elixir
def parse_json_line(json_line) do
  with {:ok, [event_type, data]} <- Jason.decode(json_line),
       {:ok, parsed_event} <- parse_event_type(event_type, data) do
    {:ok, parsed_event}
  else
    {:error, %Jason.DecodeError{} = error} -> 
      {:error, {:invalid_json, %{line: json_line, reason: error}}}
    {:error, reason} -> 
      {:error, reason}
  end
end

defp parse_event_type("start", %{"including" => inc, "excluding" => exc}) do
  {:ok, {:start, %{including: inc || [], excluding: exc || []}}}
end

defp parse_event_type("pass", %{"title" => title, "fullTitle" => full_title}) do
  {:ok, {:pass, %{title: title, full_title: full_title}}}
end

defp parse_event_type("fail", %{"title" => title, "fullTitle" => full_title, "err" => err}) do
  {:ok, {:fail, %{title: title, full_title: full_title, err: err}}}
end

defp parse_event_type("end", stats_data) do
  {:ok, {:end, stats_data}}
end

defp parse_event_type(unknown_type, data) do
  {:error, {:unknown_event, %{type: unknown_type, data: data}}}
end
```

### TestRun Construction
```elixir
def build_test_run_from_events(events, metadata \\ %{}) do
  events
  |> Enum.reverse()
  |> process_events(%{
    results: [],
    stats: nil,
    metadata: metadata,
    start_data: nil
  })
  |> construct_test_run()
end

defp process_events([], acc), do: acc

defp process_events([{:start, data} | rest], acc) do
  process_events(rest, %{acc | start_data: data})
end

defp process_events([{:pass, data} | rest], acc) do
  result = %TestResult{
    title: data.title,
    full_title: data.full_title,
    status: :passed,
    error: nil
  }
  process_events(rest, %{acc | results: [result | acc.results]})
end

defp process_events([{:fail, data} | rest], acc) do
  error = parse_test_error(data.err)
  result = %TestResult{
    title: data.title,
    full_title: data.full_title,
    status: :failed,
    error: error
  }
  process_events(rest, %{acc | results: [result | acc.results]})
end

defp process_events([{:end, data} | rest], acc) do
  stats = parse_test_stats(data)
  process_events(rest, %{acc | stats: stats})
end
```

### Error and Stats Parsing
```elixir
defp parse_test_error(%{"file" => file, "line" => line, "message" => message}) do
  %TestError{
    file: file,
    line: line,
    message: message
  }
end

defp parse_test_error(%{"message" => message}) do
  %TestError{
    file: nil,
    line: nil,
    message: message
  }
end

defp parse_test_stats(%{
  "duration" => duration,
  "passes" => passes,
  "failures" => failures,
  "pending" => pending,
  "invalid" => invalid,
  "tests" => tests,
  "suites" => suites,
  "start" => start_time,
  "end" => end_time
} = data) do
  %TestStats{
    duration_ms: round(duration),
    load_time_ms: data["loadTime"] && round(data["loadTime"]),
    passes: passes,
    failures: failures,
    pending: pending,
    invalid: invalid,
    tests: tests,
    suites: suites,
    started_at: parse_datetime(start_time),
    finished_at: parse_datetime(end_time)
  }
end
```

## Validation Strategy

### Event Sequence Validation
```elixir
def validate_event_sequence(events) do
  with :ok <- validate_start_event(events),
       :ok <- validate_end_event(events),
       :ok <- validate_test_events(events) do
    :ok
  end
end

defp validate_start_event([{:start, _} | _]), do: :ok
defp validate_start_event(_), do: {:error, :missing_start_event}

defp validate_end_event(events) do
  if Enum.any?(events, &match?({:end, _}, &1)) do
    :ok
  else
    {:error, :missing_end_event}
  end
end
```

### Error Recovery
- Skip malformed individual test events but continue parsing
- Preserve partial results when stats are missing
- Provide default values for missing optional fields
- Log warnings for recoverable parsing issues

## Usage Examples

```elixir
# Parse complete test run output
json_output = """
["start", {"including": [], "excluding": []}]
["pass", {"title": "creates user", "fullTitle": "UserTest: creates user"}]
["fail", {"title": "invalid email", "fullTitle": "UserTest: invalid email", "err": {"file": "test/user_test.exs", "line": 15, "message": "Expected true, got false"}}]
["end", {"duration": 1200.0, "passes": 1, "failures": 1, "tests": 2, "suites": 1}]
"""

{:ok, test_run} = JsonParser.parse_json_output(json_output)

# Parse individual event line
{:ok, {:pass, data}} = JsonParser.parse_json_line(~s(["pass", {"title": "test", "fullTitle": "Module: test"}]))

# Build TestRun from event list
events = [{:start, %{}}, {:pass, %{title: "test", full_title: "Module: test"}}, {:end, %{duration: 100}}]
test_run = JsonParser.build_test_run_from_events(events)
```

This design provides a clean, testable JSON parsing pipeline with comprehensive error handling and validation, following functional programming principles while maintaining clear separation of concerns.