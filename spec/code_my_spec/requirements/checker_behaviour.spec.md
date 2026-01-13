# CodeMySpec.Requirements.CheckerBehaviour

Defines the interface contract for requirement checker modules. Checker modules implement the `check/4` callback to evaluate whether a component satisfies a specific requirement. The behaviour enables pluggable checker implementations for different requirement types (file existence, test status, dependencies, etc.) while maintaining a consistent interface for the requirements system. Checkers should be idempotent (same inputs produce same outputs), graceful (handle missing data without crashing), and fast (avoid expensive operations).

## Delegates

None.

## Functions

### check/4 (callback)

Checks if a requirement is satisfied for a given component within a scoped context.

```elixir
@callback check(Scope.t(), RequirementDefinition.t(), Component.t(), keyword()) ::
            Requirement.requirement_attrs()
```

**Process**:
1. Receive scope, requirement definition, component, and options
2. Extract relevant configuration from the requirement definition
3. Perform the specific check logic (varies by implementation)
4. Build and return a requirement_attrs map with satisfaction status, score, and details

**Test Assertions**:
- returns satisfied: true with score 1.0 when requirement is met
- returns satisfied: false with score 0.0 when requirement is not met
- includes checked_at timestamp in result
- includes details map with check-specific information
- handles missing or invalid data gracefully without crashing
- respects options passed in keyword list

## Dependencies

- CodeMySpec.Requirements.Requirement
- CodeMySpec.Requirements.RequirementDefinition
- CodeMySpec.Components.Component
- CodeMySpec.Users.Scope