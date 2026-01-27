# CodeMySpec.BddSpecs

**Type**: context

Context for working with BDD specifications. Provides file-based discovery, parsing, and rendering of Spex DSL specs without database persistence. Maps specs to stories and acceptance criteria through file naming conventions, enabling traceability between requirements and executable specifications.

## Delegates

None

## Functions

### list_specs/1

Discovers all BDD spec files in the project's test/spex directory.

```elixir
@spec list_specs(Scope.t()) :: [Spec.t()]
```

**Process**:
1. Get project root from scope's active_project
2. Glob for `test/spex/**/*_spex.exs` files
3. Parse each file using Parser.parse/1
4. Return list of Spec structs

**Test Assertions**:
- returns all spec files in test/spex directory
- returns empty list when no specs exist
- parses files into Spec structs
- handles nested directory structures

### list_specs_for_story/2

Returns specs linked to a specific story via file naming convention.

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

### list_specs_for_criterion/2

Returns specs linked to a specific acceptance criterion via file naming convention.

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

### parse_spec/1

Parses a single Spex DSL file into a Spec struct.

```elixir
@spec parse_spec(String.t()) :: {:ok, Spec.t()} | {:error, term()}
```

**Process**:
1. Read file contents from path
2. Delegate to Parser.parse/1
3. Augment Spec with file_path and derived story_id/criterion_id from path
4. Return result tuple

**Test Assertions**:
- returns {:ok, spec} for valid Spex file
- returns {:error, reason} for invalid syntax
- extracts story_id and criterion_id from file path
- handles missing files gracefully

### render_summary/1

Renders a spec to a compact summary format for context windows.

```elixir
@spec render_summary(Spec.t()) :: String.t()
```

**Process**:
1. Delegate to SpecProjector.summary/1
2. Return formatted string with spec name and step descriptions only

**Test Assertions**:
- returns compact markdown summary
- includes spec name and scenario names
- includes given/when/then descriptions without code
- omits implementation details

### render_coverage_report/1

Generates a coverage report showing which stories and criteria have BDD specs.

```elixir
@spec render_coverage_report(Scope.t()) :: String.t()
```

**Process**:
1. Call list_specs/1 to get all specs
2. Delegate to SpecProjector.coverage_map/1 to group by story
3. Format as markdown report
4. Return formatted string

**Test Assertions**:
- returns markdown formatted report
- groups specs by story
- shows criteria coverage within each story
- indicates missing coverage

### validate_spec_syntax/1

Validates that a spec file has correct Spex DSL syntax.

```elixir
@spec validate_spec_syntax(String.t()) :: :ok | {:error, [String.t()]}
```

**Process**:
1. Read file contents
2. Attempt to parse with Code.string_to_quoted/1
3. Walk AST to verify required macros (spex, scenario, given_/when_/then_)
4. Return :ok or {:error, validation_errors}

**Test Assertions**:
- returns :ok for valid Spex syntax
- returns {:error, reasons} for missing spex macro
- returns {:error, reasons} for malformed scenarios
- validates given_/when_/then_ step structure

### check_story_coverage/2

Checks which acceptance criteria for a story have BDD specs.

```elixir
@spec check_story_coverage(Scope.t(), Story.t()) :: %{covered: [integer()], missing: [integer()]}
```

**Process**:
1. Get story's acceptance criteria IDs
2. Get specs for story via list_specs_for_story/2
3. Extract criterion_ids from spec file paths
4. Return map of covered and missing criterion IDs

**Test Assertions**:
- returns covered criteria IDs that have specs
- returns missing criteria IDs without specs
- handles story with full coverage
- handles story with no specs

## Dependencies

- CodeMySpec.BddSpecs.Spec
- CodeMySpec.BddSpecs.Scenario
- CodeMySpec.BddSpecs.Step
- CodeMySpec.BddSpecs.Parser
- CodeMySpec.BddSpecs.SpecProjector
- CodeMySpec.Users.Scope
- CodeMySpec.Stories.Story

## Components

### BddSpecs.Spec

Struct representing a parsed BDD specification file. Contains the spec name, file path, scenarios, and optional links to story and criterion IDs. No database persistence - purely in-memory representation for parsing and rendering.

### BddSpecs.Scenario

Struct representing a single scenario within a spec. Contains the scenario name and collections of given, when, and then step descriptions.

### BddSpecs.Step

Struct representing a single Given/When/Then step. Contains the step type, description text, and source line number for reference.

### BddSpecs.Parser

Parses Spex DSL files into Spec structs using Elixir AST analysis. Extracts spex, scenario, given_, when_, and then_ macro calls from source files. Returns structured data without executing the specs.

### BddSpecs.SpecProjector

Renders parsed specs into various output formats optimized for different use cases. Provides summary views for context windows, full views for detailed inspection, and coverage maps linking specs back to stories.
