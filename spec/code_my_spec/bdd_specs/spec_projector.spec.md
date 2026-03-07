# CodeMySpec.BddSpecs.SpecProjector

## Type

module

Renders parsed Spec structs into various output formats. Provides summary views optimized for AI context windows (names and step descriptions only), full views with complete detail, and coverage maps that aggregate specs by story or criterion. Used to give agents visibility into BDD coverage without consuming context on implementation code.

## Delegates

None

## Functions

### project_summary/1

Returns a compact summary view of a single spec showing only names and step descriptions.

```elixir
@spec project_summary(Spec.t()) :: String.t()
```

**Process**:
1. Extract spec name and file path from Spec struct
2. Format header with spec name
3. For each scenario, list scenario name and step descriptions (without implementation code)
4. Return markdown formatted string optimized for AI context consumption

**Test Assertions**:
- returns spec name as header
- includes all scenario names
- includes step descriptions for given/when/then steps
- excludes implementation code
- returns compact markdown format

### project_summary_list/1

Returns a summary view of multiple specs as a formatted list.

```elixir
@spec project_summary_list(list(Spec.t())) :: String.t()
```

**Process**:
1. Map over specs list calling project_summary/1 for each
2. Join summaries with newline separators
3. Return combined markdown string

**Test Assertions**:
- returns empty string for empty list
- formats single spec correctly
- formats multiple specs with proper separation
- preserves spec order in output

### project_full/1

Returns a detailed view of a spec with complete information including metadata.

```elixir
@spec project_full(Spec.t()) :: String.t()
```

**Process**:
1. Extract all spec metadata (name, file path, story_id, criterion_id)
2. Format header with spec name and metadata section
3. For each scenario, format complete details including step types and line numbers
4. Include tags and descriptions if present
5. Return comprehensive markdown document

**Test Assertions**:
- includes spec name and file path
- includes story_id when present
- includes criterion_id when present
- shows all scenario details with step types
- includes step line numbers for traceability
- includes tags when present

### project_coverage_by_story/2

Returns a coverage report showing specs grouped by story.

```elixir
@spec project_coverage_by_story(list(Spec.t()), list(Story.t())) :: String.t()
```

**Process**:
1. Group specs by story_id (extracted from file path convention)
2. For each story, list associated specs and criteria coverage
3. Identify stories with no specs (missing coverage)
4. Format as markdown with story headers and indented spec listings
5. Include coverage percentage or indicator for each story

**Test Assertions**:
- groups specs by story correctly
- shows stories with full coverage
- highlights stories with partial coverage
- lists stories with no specs
- includes coverage indicators or percentages
- returns empty string for empty inputs

### project_coverage_by_criterion/2

Returns a coverage report showing which criteria have specs.

```elixir
@spec project_coverage_by_criterion(list(Spec.t()), list(Criterion.t())) :: String.t()
```

**Process**:
1. Extract criterion_ids from spec file names (pattern: criterion_{id}_spex.exs)
2. Match specs to criteria by ID
3. Identify criteria without specs
4. Format as markdown listing criteria with their spec status
5. Use visual indicators for covered vs uncovered criteria

**Test Assertions**:
- matches specs to criteria by ID
- shows covered criteria with spec links
- highlights uncovered criteria
- handles criteria with multiple specs
- returns organized markdown format
- handles empty inputs gracefully

### format_scenario/1

Formats a single scenario into markdown representation.

```elixir
@spec format_scenario(Scenario.t()) :: String.t()
```

**Process**:
1. Format scenario name as header
2. Group steps by type (given, when, then)
3. Format each step with appropriate indentation
4. Return formatted markdown string

**Test Assertions**:
- formats scenario name as header
- groups steps by type
- preserves step descriptions
- returns valid markdown structure

### format_step/1

Formats a single step into markdown representation.

```elixir
@spec format_step(Step.t()) :: String.t()
```

**Process**:
1. Extract step type and description from Step struct
2. Format with type prefix (Given/When/Then)
3. Include line number if present
4. Return formatted string

**Test Assertions**:
- includes step type prefix
- includes step description
- includes line number when present
- handles all step types (given, when, then)

## Dependencies

- CodeMySpec.BddSpecs.Spec
- CodeMySpec.BddSpecs.Scenario
- CodeMySpec.BddSpecs.Step
- CodeMySpec.Stories.Story
- CodeMySpec.AcceptanceCriteria.Criterion
