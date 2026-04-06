# CodeMySpec.Requirements.RequirementCalculator

Computes requirement satisfaction from File records, Problems, and entity fields.

Dispatches on the `check_type` field of each RequirementDefinition rather than
pattern-matching on requirement names. Covers component, story, and project
requirements with a unified set of check types.

Check types:

- **`:file_exists`** — a File record with the configured role exists for the entity
- **`:file_valid`** — a File record with the configured role exists AND has `valid: true`
- **`:path_exists`** — a file at the configured path exists in the project file list
- **`:field_present`** — a field on the entity is not nil
- **`:no_problems`** — zero Problem records from the configured source
- **`:tests_passing`** — zero exunit Problem records for the entity
- **`:spex_passing`** — zero spex Problem records for the entity

Each check type reads its parameters from `definition.config`:
- `:file_exists` → `%{role: :spec}`, `%{role: :bdd_spec}`, etc.
- `:file_valid` → `%{role: :spec}`, `%{role: :test}`, etc.
- `:path_exists` → `%{path: ".code_my_spec/qa/journey_plan.md"}` or `%{path_prefix: ".code_my_spec/integrations/"}`
- `:field_present` → `%{field: :component_id}`
- `:no_problems` → `%{source: "credo"}`, `%{source: "sobelow"}`, etc.
- `:tests_passing` → no config needed (source is always "exunit")
- `:spex_passing` → no config needed (source is always "spex")

The old children aggregate checks (`context_specs`, `context_implementation`)
are removed — child dependencies are handled by the requirement graph edges,
not by the calculator.

Story and project checks are also handled here instead of in RequirementGraph.
The graph is responsible for topology (edges), the calculator for satisfaction
(nodes). `project_setup` remains a special case that delegates to
`ProjectSetup.evaluate`.

## Type

module

## Dependencies

- CodeMySpec.Components.Component
- CodeMySpec.Files.File
- CodeMySpec.Issues
- CodeMySpec.Problems.Problem
- CodeMySpec.Requirements.RequirementDefinition
- CodeMySpec.Requirements.Preloader
- CodeMySpec.Stories.Story
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

Compute satisfaction for a single requirement definition against an entity.

```elixir
@spec compute_one(Scope.t(), struct(), RequirementDefinition.t(), [File.t()], Preloader.context() | nil) :: computed_requirement()
```

**Process**:
1. Read `definition.check_type` to determine which check to run
2. Read `definition.config` for check parameters (role, source, path, field, etc.)
3. Dispatch to the appropriate check function
4. Return `%{name: definition.name, satisfied: boolean, details: map}`

**Test Assertions**:
- dispatches to file_exists check when check_type is :file_exists
- dispatches to file_valid check when check_type is :file_valid
- dispatches to path_exists check when check_type is :path_exists
- dispatches to field_present check when check_type is :field_present
- dispatches to no_problems check when check_type is :no_problems
- dispatches to tests_passing check when check_type is :tests_passing
- dispatches to spex_passing check when check_type is :spex_passing
- returns unsatisfied with "Unknown check_type" for unrecognized check types

### check :file_exists

Checks whether a File record with the configured role exists for the entity.
Works for components (by component_id), stories (by story_id), and any entity
with file records.

**Config**: `%{role: atom()}` — the file role to look for (e.g. `:spec`, `:implementation`, `:test`, `:review`, `:bdd_spec`, `:qa_result`)

Optionally includes the expected file path in details when the file is missing.

**Test Assertions**:
- returns satisfied when a file with the configured role exists
- returns unsatisfied with "role file missing" when no file with that role exists
- includes expected_path in details when file is missing
- works for all roles: spec, implementation, test, review, json, bdd_spec, qa_result

### check :file_valid

Checks whether a File record with the configured role exists AND has `valid: true`.

**Config**: `%{role: atom()}` — the file role to check validity for

**Test Assertions**:
- returns satisfied when file exists and valid is true
- returns unsatisfied with "file invalid" when valid is false, includes validation_errors
- returns unsatisfied with "file not yet validated" when valid is nil
- returns unsatisfied with "file missing" when no file with that role exists

### check :path_exists

Checks whether a file at the configured path (or path prefix) exists in the
project's file list. Used for project-level requirements that check specific
known paths rather than role-based file records.

**Config**: `%{path: String.t()}` for exact match, or `%{path_prefix: String.t()}` for prefix match (at least one file)

**Test Assertions**:
- returns satisfied when a file at the exact path exists
- returns unsatisfied when no file at the path exists
- returns satisfied when at least one file matches the path prefix
- returns unsatisfied when no files match the path prefix

### check :field_present

Checks whether a field on the entity struct is not nil. Used for story-level
checks like `component_linked` where the story must have a `component_id`.

**Config**: `%{field: atom()}` — the field name to check

**Test Assertions**:
- returns satisfied when the field value is not nil
- returns unsatisfied when the field value is nil

### check :no_problems

Checks whether zero Problem records exist for the entity from the configured source.
Used for static analysis checks (credo, sobelow, compiler, spec_alignment).

**Config**: `%{source: String.t()}` — the problem source to count

**Test Assertions**:
- returns satisfied when problem count is zero for the configured source
- returns unsatisfied with failure count when problems exist
- works for credo, sobelow, compiler, and spec_alignment sources

### check :tests_passing

Checks whether zero exunit Problem records exist for the entity.
Source is always "exunit" — no config needed.

**Test Assertions**:
- returns satisfied with "No test failures" when exunit problem count is zero
- returns unsatisfied with failure count when test failures exist

### check :spex_passing

Checks whether zero spex Problem records exist for the entity.
Source is always "spex" — no config needed.

**Test Assertions**:
- returns satisfied when spex problem count is zero
- returns unsatisfied with failure count when spex failures exist
