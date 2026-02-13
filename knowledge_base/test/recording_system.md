# Recording System

We record external command executions and HTTP calls so tests replay deterministic output without hitting real systems.

Two VCR libraries handle this:

- **ExCliVcr** - Records/replays `System.cmd/3` calls (the primary mechanism)
- **ExVCR** - Records/replays HTTP requests (GitHub API, etc.)

## ExCliVcr (CLI Recording)

Records and replays `System.cmd/3` calls. This is the primary recording mechanism since CodeMySpec orchestrates external tools (`mix compile`, `mix credo`, `mix sobelow`, `mix test`, `mix spex`).

### Setup

Add to your test module:

```elixir
use ExCliVcr
```

This imports the `use_cmd_cassette` macro.

### Usage

```elixir
@tag timeout: 120_000
test "runs credo analysis", %{scope: scope} do
  use_cmd_cassette "static_analysis_credo_run", ignore: [[:opts, :cd]] do
    {:ok, problems} = Credo.run(scope)
    assert is_list(problems)
  end
end
```

### How It Works

1. **First run** (no cassette file exists): Intercepts `System.cmd/3` via `:meck`, executes the real command, records output to JSON
2. **Subsequent runs** (cassette exists): Matches incoming commands against recorded ones, returns stored output without executing

The macro wraps your test block:
```elixir
ExCliVcr.start_cassette(name, opts)
try do
  # your test code
after
  ExCliVcr.stop_cassette()
end
```

### The `ignore` Option

```elixir
ignore: [[:opts, :cd]]
```

Masks environment-specific values in cassettes. The `:cd` option (working directory) varies between test runs because pooled repos have different paths (`pool_code_repo_1`, `pool_code_repo_7`, etc.).

In the cassette file, masked values are stored as `"*"`:
```json
{
  "opts": {
    "cd": "*",
    "stderr_to_stdout": true
  }
}
```

During replay, `"*"` matches any value for that field.

### Cassette File Format

Stored in `test/fixtures/cassettes/` as JSON:

```json
{
  "commands": [
    {
      "command": "mix",
      "args": ["credo", "suggest", "--format", "json", "--all"],
      "opts": { "cd": "*", "stderr_to_stdout": true },
      "output": "...full command output...",
      "exit_code": 0,
      "recorded_at": "2026-02-07T14:53:41.952273Z"
    }
  ],
  "ports": []
}
```

A single cassette can contain multiple commands (e.g., a validation test records `mix compile`, `mix test`, `mix credo`, and `mix sobelow` in sequence).

### Re-recording

Delete the cassette file and run the test. It will execute real commands and create a new recording. Make sure you have a working test fixture repo.

## ExVCR (HTTP Recording)

Standard Elixir HTTP recording library. Used for GitHub API interactions (creating repos, etc.).

Cassettes stored in `test/fixtures/vcr_cassettes/`.

## Test Environment (RecordingEnvironment)

Location: `test/support/recording_environment.ex`

The default `EnvironmentsBehaviour` implementation for tests (configured in `config/test.exs`). Despite the name, it's primarily a local filesystem environment - it handles `read_file`, `write_file`, `glob`, `file_exists?`, etc. by resolving paths relative to the environment's `cwd`.
