# CommandBuilder

## Purpose
Constructs mix test command strings with ExUnit JSON formatter and configurable options.

## Responsibilities
- Build base mix test command with JSON formatter
- Apply include/exclude tag filtering
- Configure test execution options (seed, max failures)
- Ensure proper shell escaping and argument formatting

## Public API

```elixir
@type build_opts :: [
  include: [atom()],
  exclude: [atom()],
  seed: non_neg_integer(),
  max_failures: pos_integer(),
  only: [String.t()],
  stale: boolean(),
  failed: boolean()
]

@spec build_command(build_opts()) :: String.t()
@spec validate_opts(build_opts()) :: :ok | {:error, String.t()}
```

## Command Structure

### Base Command
```bash
mix test --formatter ExUnitJsonFormatter
```

### Option Mapping
- `include: [:integration, :slow]` � `--include integration,slow`
- `exclude: [:pending]` � `--exclude pending` 
- `seed: 12345` � `--seed 12345`
- `max_failures: 5` � `--max-failures 5`
- `only: ["test/user_test.exs:42"]` � `--only test/user_test.exs:42`
- `stale: true` � `--stale`
- `failed: true` � `--failed`

## Implementation Strategy

### Validation Rules
- Include/exclude tags must be atoms or convertible to strings
- Seed must be positive integer
- Max failures must be positive integer
- Only paths must be valid file references
- Conflicting options (include/exclude same tag) should error

## Error Handling
- Invalid option types return `{:error, "Invalid option: #{inspect(opt)}"}`
- Conflicting options return `{:error, "Conflicting options: #{conflict}"}`
- Empty option lists are valid and ignored
- Unknown options are ignored with warning

## Usage Examples

```elixir
# Basic test run
CommandBuilder.build_command_string([])
# => "mix test --formatter ExUnitJsonFormatter"

# Integration tests only
CommandBuilder.build_command_string(include: [:integration])
# => "mix test --formatter ExUnitJsonFormatter --include integration"

# Complex filtering
CommandBuilder.build_command_string([
  include: [:integration, :api],
  exclude: [:slow, :external],
  seed: 42,
  max_failures: 3
])
# => "mix test --formatter ExUnitJsonFormatter --include integration,api --exclude slow,external --seed 42 --max-failures 3"

# Specific test files
CommandBuilder.build_command_string([
  only: ["test/user_test.exs:15", "test/account_test.exs"]
])
# => "mix test --formatter ExUnitJsonFormatter --only test/user_test.exs:15 --only test/account_test.exs"
```