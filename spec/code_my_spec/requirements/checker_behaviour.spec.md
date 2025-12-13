# Requirements.CheckerBehaviour

Defines the interface for requirement checker modules. Each checker module implements a `check/2` callback that takes a requirement spec and an entity (component or context), then returns a check result map.

## Principles

Checkers should be:
- **Idempotent**: Same inputs always produce same outputs
- **Graceful**: Handle missing data without crashing
- **Fast**: Avoid expensive operations when possible

## Types

### check_result

```elixir
@type check_result :: %{
  satisfied: boolean(),
  checked_at: DateTime.t(),
  details: map()
}
```

The result returned by checker modules containing:
- `satisfied`: Whether the requirement is satisfied
- `checked_at`: Timestamp when the check was performed
- `details`: Additional context about the check result

## Callbacks

### check/2

```elixir
@callback check(Requirement.requirement_spec(), struct()) :: check_result()
```

Checks if a requirement is satisfied for a given entity (component or context).

**Parameters**:
- `requirement_spec`: The requirement specification containing name, checker module, and satisfied_by
- `entity`: The component or context struct being checked

**Returns**: A `check_result` map

## Example Implementations

- **FileExistenceChecker**: Verifies files exist at expected paths
- **HierarchicalChecker**: Checks if child components have satisfied requirements
- **DependencyChecker**: Validates all dependencies are satisfied
- **TestStatusChecker**: Confirms tests are passing
- **ContextReviewFileChecker**: Checks if review documentation exists