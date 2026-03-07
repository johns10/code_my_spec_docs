# CodeMySpec.Requirements.ContextReviewFileChecker

## Type

module

Checker for context-level design review file existence. This checker verifies that a context has an associated design review file, which documents the architectural analysis and validation of the context and its child components. Implements the CheckerBehaviour callback interface.

## Delegates

None

## Functions

### check/4

Verifies that a context component has an associated design review file at the expected path.

```elixir
@spec check(Scope.t(), RequirementDefinition.t(), Component.t(), keyword()) :: Requirement.requirement_attrs()
```

**Process**:
1. Extract component files map using Utils.component_files/2 with component and project
2. Convert requirement name to atom and look up corresponding file path from files map
3. Get environment type from options (defaults to :cli) and create environment
4. Check if file exists at the resolved path using Environments.file_exists?/2
5. Build result map with satisfaction status, score, and details:
   - If file exists: satisfied=true, score=1.0, details include status and path
   - If file missing: satisfied=false, score=0.0, details include reason and path
   - If error occurs: satisfied=false, score=0.0, details include error reason and path
6. Return requirement attributes map with name, artifact_type, description, checker_module, satisfied_by, satisfied, score, checked_at, and details

**Test Assertions**:
- returns satisfied=true with score 1.0 when review file exists
- returns satisfied=false with score 0.0 when review file is missing
- returns satisfied=false with score 0.0 when file check returns error
- includes file path in details on success
- includes file path and reason in details on failure
- uses environment_type option when provided
- defaults to :cli environment type when option not provided
- correctly resolves review_file key from component files map

## Dependencies

- CodeMySpec.Components.Component
- CodeMySpec.Environments
- CodeMySpec.Requirements.CheckerBehaviour
- CodeMySpec.Requirements.RequirementDefinition
- CodeMySpec.Users.Scope
- CodeMySpec.Utils