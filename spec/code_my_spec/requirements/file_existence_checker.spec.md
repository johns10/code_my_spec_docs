# CodeMySpec.Requirements.FileExistenceChecker

Implements the CheckerBehaviour to verify that required files exist for a component. Checks for spec files, code files, test files, and review files based on the requirement definition's name field. Uses the Environments abstraction for file existence checks to support different execution contexts (CLI, VS Code, local).

## Dependencies

- CodeMySpec.Requirements.CheckerBehaviour
- CodeMySpec.Requirements.RequirementDefinition
- CodeMySpec.Components.Component
- CodeMySpec.Users.Scope
- CodeMySpec.Utils
- CodeMySpec.Environments

## Functions

### check/4

Checks if a required file exists for a component based on the requirement definition.

```elixir
@spec check(Scope.t(), RequirementDefinition.t(), Component.t(), keyword()) ::
        Requirement.requirement_attrs()
```

**Process**:
1. Extract component file paths using Utils.component_files/2 with the component and project from scope
2. Map requirement name to file key using file_key/1 (e.g., "spec_file" -> :spec_file)
3. Get the file path from the files map using the file key
4. Get environment type from options (defaults to :cli)
5. Create environment using Environments.create/2
6. Check file existence using Environments.file_exists?/2
7. Build and return requirement attrs map with satisfaction status, score, and details

**Test Assertions**:

- returns satisfied true with score 1.0 when file exists
- returns satisfied false with score 0.0 when file is missing
- returns satisfied false with error details when file check fails with error
- correctly maps "spec_file" requirement name to spec file path
- correctly maps "code_file" requirement name to code file path
- correctly maps "implementation_file" requirement name to code file path
- correctly maps "test_file" requirement name to test file path
- correctly maps "review_file" requirement name to review file path
- uses :cli environment type by default
- respects custom environment_type option
- includes file path in details for both satisfied and unsatisfied results
- returns current timestamp in checked_at field

### file_key/1

Maps requirement names to file key atoms for looking up paths in the component files map.

```elixir
@spec file_key(String.t()) :: atom()
```

**Process**:
1. Pattern match on the name string
2. Return corresponding atom key for the component files map

**Test Assertions**:

- maps "spec_file" to :spec_file atom
- maps "code_file" to :code_file atom
- maps "implementation_file" to :code_file atom (alias for code_file)
- maps "test_file" to :test_file atom
- maps "review_file" to :review_file atom
- raises FunctionClauseError for unknown file names