# DependencyChecker

Checks whether a component's dependencies have all their requirements satisfied. Implements the `CheckerBehaviour` to validate the `:dependencies_satisfied` requirement, ensuring a component can only proceed when its dependencies are ready.

## Delegates

None.

## Functions

### check/4

Evaluates whether all dependencies of a component have satisfied requirements.

```elixir
@spec check(Scope.t(), RequirementDefinition.t(), Component.t(), keyword()) :: Requirement.requirement_attrs()
```

**Process**:
1. Pattern match on requirement name and dependencies from the component
2. For `:dependencies_satisfied` with empty dependencies list, return satisfied with "No dependencies to satisfy" status
3. For `:dependencies_satisfied` with non-empty dependencies list:
   - Check each dependency using `dependency_satisfied?/1`
   - If all satisfied, return satisfied with count of dependencies
   - If any unsatisfied, return not satisfied with list of unsatisfied dependency names, total count, and unsatisfied count
4. For `:dependencies_satisfied` with `Ecto.Association.NotLoaded`, return not satisfied with "Dependencies not loaded" reason
5. For any other case, return not satisfied with "Invalid dependency structure" reason
6. Build and return requirement attributes map with name, artifact_type, description, checker_module, satisfied_by, satisfied status, score (1.0 if satisfied, 0.0 otherwise), checked_at timestamp, and details

**Test Assertions**:
- returns satisfied when component has no dependencies
- returns satisfied when all dependencies have satisfied requirements
- returns not satisfied when any dependency has unsatisfied requirements
- returns not satisfied when dependencies association is not loaded
- includes unsatisfied dependency names in details when not satisfied
- includes counts in details (total_dependencies, unsatisfied_count)
- returns score of 1.0 when satisfied
- returns score of 0.0 when not satisfied
- sets checked_at to current UTC datetime
- handles invalid dependency structure gracefully

## Dependencies

- CodeMySpec.Components.Component
- CodeMySpec.Requirements.CheckerBehaviour
- CodeMySpec.Requirements.RequirementDefinition
- CodeMySpec.Requirements.Requirement
- CodeMySpec.Users.Scope