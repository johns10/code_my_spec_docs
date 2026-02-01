# CodeMySpec.BddSpecs

**Type**: context

Context for working with BDD specifications. Provides file-based discovery and coverage analysis of Spex DSL specs without database persistence. Maps specs to stories and acceptance criteria through file naming conventions, enabling traceability between requirements and executable specifications.

## Delegates

### Spex

Delegates to `CodeMySpec.BddSpecs.Spex` for executing BDD specifications.

## Functions

### list_specs/1

Returns all BDD specs for the project as parsed summaries.

```elixir
@spec list_specs(Scope.t()) :: [Spec.t()]
```

**Process**:
1. Get project root from scope's active_project
2. Glob for `test/spex/**/*_spex.exs` files relative to project root
3. Parse each file using Parser.parse_file/1 internally
4. Return list of Spec structs (summaries, no implementation code)

**Test Assertions**:
- returns all spec files in test/spex directory
- returns empty list when no specs exist
- returns Spec structs with scenarios and step descriptions
- handles nested directory structures
- respects project scope

### list_specs_for_story/2

Returns specs linked to a specific story.

```elixir
@spec list_specs_for_story(Scope.t(), integer()) :: [Spec.t()]
```

**Process**:
1. Call list_specs/1 to get all specs
2. Filter specs where story_id matches (derived from directory name pattern `{story_id}_*`)
3. Return matching specs

**Test Assertions**:
- returns specs in story directory
- returns empty list when story has no specs
- extracts story_id from directory naming convention
- handles multiple specs for same story

### list_specs_for_criterion/2

Returns specs linked to a specific acceptance criterion.

```elixir
@spec list_specs_for_criterion(Scope.t(), integer()) :: [Spec.t()]
```

**Process**:
1. Call list_specs/1 to get all specs
2. Filter specs where criterion_id matches (derived from filename pattern `criterion_{id}_spex.exs`)
3. Return matching specs

**Test Assertions**:
- returns specs matching criterion filename pattern
- returns empty list when criterion has no specs
- extracts criterion_id from filename convention
- handles criterion spec with multiple scenarios

### get_coverage_report/1

Returns a formatted coverage report showing spec coverage across stories.

```elixir
@spec get_coverage_report(Scope.t()) :: String.t()
```

**Process**:
1. Call list_specs/1 to get all specs
2. Load stories with criteria from CodeMySpec.Stories
3. Use SpecProjector.format_coverage/2 internally to format coverage report
4. Return markdown formatted report

**Test Assertions**:
- returns markdown formatted report
- groups specs by story
- shows criteria coverage within each story
- indicates missing coverage with clear markers
- includes summary statistics

### check_story_coverage/2

Checks which acceptance criteria for a story have BDD specs.

```elixir
@spec check_story_coverage(Scope.t(), Story.t()) :: %{covered: [integer()], missing: [integer()]}
```

**Process**:
1. Get story's acceptance criteria IDs via CodeMySpec.AcceptanceCriteria
2. Get specs for story via list_specs_for_story/2
3. Extract criterion_ids from spec file paths
4. Return map of covered and missing criterion IDs

**Test Assertions**:
- returns covered criteria IDs that have specs
- returns missing criteria IDs without specs
- handles story with full coverage (empty missing list)
- handles story with no specs (empty covered list)
- handles story with no criteria

### validate_spec_syntax/2

Validates that a spec file has correct Spex DSL syntax.

```elixir
@spec validate_spec_syntax(Scope.t(), String.t()) :: :ok | {:error, [String.t()]}
```

**Process**:
1. Read file contents from provided file path
2. Use Parser.validate/1 internally to validate AST structure
3. Verify required macros (spex, scenario, given_/when_/then_)
4. Return :ok or {:error, validation_errors}

**Test Assertions**:
- returns :ok for valid Spex syntax
- returns {:error, reasons} for missing spex macro
- returns {:error, reasons} for malformed scenarios
- validates given_/when_/then_ step structure
- handles file not found errors

### spec_file_path/2

Returns the conventional file path for a story/criterion spec.

```elixir
@spec spec_file_path(Story.t(), Criterion.t()) :: String.t()
```

**Process**:
1. Build path from story: `test/spex/stories/{story_id}_{slug}/`
2. Append criterion filename: `criterion_{criterion_id}_spex.exs`
3. Return full path

**Test Assertions**:
- returns path following naming convention
- slugifies story title for directory name
- uses criterion_id in filename
- produces valid filesystem path

## Components

### BddSpecs.Spec

Struct representing a parsed BDD specification. Contains spec name, file path, scenarios with step descriptions, and derived story_id/criterion_id from file path. No implementation code retained - just the structural summary.

### BddSpecs.Scenario

Struct representing a scenario within a spec. Contains scenario name and lists of given/when/then step descriptions as strings.

### BddSpecs.Step

Struct representing a Given/When/Then step. Contains step type (:given, :when, :then), description text, and source line number.

### BddSpecs.Parser

Parses Spex DSL files into Spec structs using Elixir AST analysis. Extracts spex, scenario, given_, when_, and then_ macro calls. Returns structured data without implementation code. Not exposed publicly - used internally by the context.

### BddSpecs.SpecProjector

Renders Spec structs into formatted output. Provides coverage reports and summary views. Not exposed publicly - used internally by the context for report generation.

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.Stories.Story
- CodeMySpec.AcceptanceCriteria
- CodeMySpec.AcceptanceCriteria.Criterion
- CodeMySpec.Users.Scope
