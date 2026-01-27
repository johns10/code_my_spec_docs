# CodeMySpec.Requirements.HierarchicalChecker

Implements `CheckerBehaviour` to verify hierarchical component requirements by recursively checking that all child components in a component tree satisfy specific artifact requirements (spec files, implementation files, test files) or are fully complete.

## Delegates

None.

## Dependencies

- CodeMySpec.Components.Component
- CodeMySpec.Requirements.CheckerBehaviour
- CodeMySpec.Requirements.RequirementDefinition
- CodeMySpec.Users.Scope

## Functions

### check/4

Checks hierarchical requirements for a component by verifying that all child components in the tree satisfy the specified requirement type.

```elixir
@spec check(Scope.t(), RequirementDefinition.t(), Component.t(), keyword()) :: Requirement.requirement_attrs()
```

**Process**:
1. Pattern match on the requirement definition's name to determine which type of hierarchical check to perform
2. For "children_designs", delegate to check_children_requirements with "spec_file"
3. For "children_implementations", delegate to check_children_requirements with "implementation_file"
4. For "children_tests", delegate to check_children_requirements with "test_file"
5. For "children_complete", delegate to check_all_children_requirements
6. For unknown requirement names, log an error and return unsatisfied result
7. Build and return a requirement attributes map with name, artifact_type, description, checker_module, satisfied_by, satisfied status, score (1.0 if satisfied, 0.0 otherwise), checked_at timestamp, and details

**Test Assertions**:
- returns satisfied result when component has no child components for children_designs
- returns satisfied result when component has no child components for children_implementations
- returns satisfied result when component has no child components for children_tests
- returns satisfied result when component has no child components for children_complete
- returns unsatisfied result when child components association is not loaded
- returns satisfied result when all child components have spec_file requirement satisfied for children_designs
- returns unsatisfied result when some child components are missing spec_file requirement for children_designs
- returns satisfied result when all child components have implementation_file requirement satisfied for children_implementations
- returns unsatisfied result when some child components are missing implementation_file for children_implementations
- returns satisfied result when all child components have test_file requirement satisfied for children_tests
- returns unsatisfied result when some child components are missing test_file for children_tests
- returns satisfied result when all child components have all requirements satisfied for children_complete
- returns unsatisfied result when some child components have unsatisfied requirements for children_complete
- recursively checks nested child components at all levels of hierarchy
- returns unsatisfied result with error details for invalid requirement name
- includes score of 1.0 when satisfied
- includes score of 0.0 when not satisfied
- includes checked_at timestamp in result
- includes details map with status message when satisfied
- includes details map with reason when not satisfied