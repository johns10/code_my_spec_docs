# CodeMySpec.Requirements.RequirementCalculator

Computes requirement satisfaction from File records and Problems.

Dispatches on the `check_type` field of each RequirementDefinition rather than
pattern-matching on requirement names. Three check types cover all component
requirements:

- **`:file_exists`** — a File with the configured role exists for the component
- **`:file_valid`** — a File with the configured role exists AND has `valid: true`
- **`:no_problems`** — zero Problem records from the configured source

Each check type reads its parameters from `definition.config`:
- `:file_exists` → `%{role: :spec}`, `%{role: :implementation}`, etc.
- `:file_valid` → `%{role: :spec}`, `%{role: :test}`, etc.
- `:no_problems` → `%{source: "exunit"}`

The old children aggregate checks (`context_specs`, `context_implementation`)
are removed — child dependencies are handled by the requirement graph edges,
not by the calculator.

## Type

module

## Dependencies

- CodeMySpec.Components.Component
- CodeMySpec.Files.File
- CodeMySpec.Problems.Problem
- CodeMySpec.Requirements.RequirementDefinition
- CodeMySpec.Requirements.Preloader
- CodeMySpec.Users.Scope

## Functions

### compute_component/3

Compute satisfaction for all requirements of a component.

```elixir
@spec compute_component(Scope.t(), Component.t(), Preloader.context() | nil) :: [computed_requirement()]
```

**Process**:
1. Get requirement definitions for the component's type from the registry
2. Get the component's files (from preloaded context or query)
3. For each definition, call `compute_one/5`

**Test Assertions**:
- returns a list of computed requirements matching the component type's definitions
- uses preloaded context when provided to avoid queries
- falls back to database queries when no context provided

### compute_one/5

Compute satisfaction for a single requirement definition.

```elixir
@spec compute_one(Scope.t(), Component.t(), RequirementDefinition.t(), [File.t()], Preloader.context() | nil) :: computed_requirement()
```

**Process**:
1. Read `definition.check_type` to determine which check to run
2. Read `definition.config` for check parameters (role, source, etc.)
3. Dispatch to the appropriate check function
4. Return `%{name: definition.name, satisfied: boolean, details: map}`

**Test Assertions**:
- dispatches to file_exists check when check_type is :file_exists
- dispatches to file_valid check when check_type is :file_valid
- dispatches to no_problems check when check_type is :no_problems
- returns unsatisfied with "Unknown check_type" for unrecognized check types

### check :file_exists

Checks whether a File record with the configured role exists for the component.

**Config**: `%{role: atom()}` — the file role to look for (e.g. `:spec`, `:implementation`, `:test`, `:review`)

Optionally includes the expected file path in the details when the file is missing,
derived from `Utils.component_files/2`.

**Test Assertions**:
- returns satisfied when a file with the configured role exists
- returns unsatisfied with "role file missing" when no file with that role exists
- includes expected_path in details when file is missing
- works for all roles: spec, implementation, test, review, json

### check :file_valid

Checks whether a File record with the configured role exists AND has `valid: true`.

**Config**: `%{role: atom()}` — the file role to check validity for

**Test Assertions**:
- returns satisfied when file exists and valid is true
- returns unsatisfied with "file invalid" when valid is false, includes validation_errors
- returns unsatisfied with "file not yet validated" when valid is nil
- returns unsatisfied with "file missing" when no file with that role exists

### check :no_problems

Checks whether zero Problem records exist for the component from the configured source.

**Config**: `%{source: String.t()}` — the problem source to count (e.g. "exunit")

**Test Assertions**:
- returns satisfied with "No test failures" when problem count is zero
- returns unsatisfied with failure count when problems exist
