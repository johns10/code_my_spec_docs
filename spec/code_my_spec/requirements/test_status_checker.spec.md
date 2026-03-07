# CodeMySpec.Requirements.TestStatusChecker

## Type

module

Checks whether a component's tests are passing by examining its component_status. Implements the CheckerBehaviour callback to evaluate the :tests_passing requirement. Returns satisfied true only when tests exist and are passing; returns appropriate failure reasons for missing tests, failing tests, or tests not yet run.

## Delegates

None

## Functions

### check/4

Evaluates whether the :tests_passing requirement is satisfied for a component.

```elixir
@spec check(Scope.t(), RequirementDefinition.t(), Component.t(), keyword()) :: Requirement.requirement_attrs()
```

**Process**:
1. Pattern match on the requirement name (converted to atom) and component_status
2. For :tests_passing with test_exists: false, return unsatisfied with "No test file exists"
3. For :tests_passing with test_status: :passing, return satisfied with score 1.0
4. For :tests_passing with test_status: :failing, return unsatisfied with "Tests are failing"
5. For :tests_passing with test_status: :not_run, return unsatisfied with "Tests have not been run"
6. For nil component_status, return unsatisfied with "Component status not available"
7. For unrecognized component_status structure, return unsatisfied with "Invalid component status structure"
8. Build and return requirement_attrs map with name, artifact_type, description, checker_module, satisfied_by, satisfied, score, checked_at, and details

**Test Assertions**:
- returns satisfied true with score 1.0 when tests exist and are passing
- returns satisfied false with score 0.0 when test file does not exist
- returns satisfied false when tests are failing
- returns satisfied false when tests have not been run
- returns satisfied false when component_status is nil
- returns satisfied false when component_status has unexpected structure
- includes appropriate reason in details for each failure case
- sets checked_at to current UTC timestamp
- preserves requirement definition fields in result (name, artifact_type, description, checker_module, satisfied_by)

## Dependencies

- CodeMySpec.Components.Component
- CodeMySpec.Requirements.RequirementDefinition
- CodeMySpec.Requirements.Requirement
- CodeMySpec.Users.Scope