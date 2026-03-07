# CodeMySpec.AgentTasks.QaStory

## Type

module

Per-story agent task for QA-testing a single user story. Takes a story ID, loads the story (title, description, acceptance criteria) and its BDD specs, projects specs via SpecProjector, and builds a prompt pointing the agent at the story context, specs, and router. The agent decides how to authenticate, navigate, and verify. Defines a structured output format so the evaluate function can validate results.

## Functions

### load_specs/2

Load and project BDD specs for a story.

```elixir
@spec load_specs(Environment.t(), integer()) :: {[String.t()], [String.t()]}
```

**Process**:
1. Call `BddSpecs.list_specs_for_story(env, story_id)`
2. If empty, return `{[], []}`
3. Project each spec via `SpecProjector.project_full/1`
4. Collect file paths from each spec struct
5. Return `{projections, file_paths}`

**Test Assertions**:
- returns empty tuples when no specs exist
- returns projections and file paths when specs exist

### command/3

Generate the QA prompt for a single story.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:
1. Get story ID from `session.state["topic"]` (integer or string)
2. Load the story via `Stories.get_story!/2` to get title, description, and acceptance criteria
3. Derive app name from mix.exs and build router path
4. Load and project BDD specs via `load_specs/2`
5. Read existing QA result and list existing issues
6. Assemble prompt sections:
    - Header with story ID and reference to `web-cli` knowledge article
    - Story section with full title, description, and acceptance criteria
    - BDD specs section with projected specs and file paths (or "no specs" fallback)
    - Router section with path to router file
    - Existing result section (if re-running)
    - Existing issues section (if any)
    - Instructions: read specs, read router, test the app, file issues
    - Required output format defining the structured QA result document

**Test Assertions**:
- returns ok tuple with prompt containing story ID
- includes story title and description in prompt
- includes acceptance criteria in prompt
- references web-cli knowledge article
- includes router path reference
- includes BDD specs when they exist
- handles missing specs gracefully
- includes existing result when present
- references existing issues when present
- includes structured output format with Status, Scenarios Tested, Issues Found sections
- instructs agent to write QA result to docs/qa/{story_id}.md
- includes issue filing instructions
- accepts string story ID

### evaluate/3

Validate the story's QA result is complete.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()}
```

**Process**:
1. Get story ID from `session.state["topic"]`
2. Check QA result exists at `docs/qa/{story_id}.md`
3. Check result is non-empty
4. Check result contains `## Status:` line
5. Return `{:ok, :valid}` or `{:ok, :invalid, feedback}`

**Test Assertions**:
- returns {:ok, :valid} when QA result exists with status line
- returns {:ok, :invalid, feedback} when QA result is missing
- returns {:ok, :invalid, feedback} when QA result is empty
- returns {:ok, :invalid, feedback} when QA result missing status line

## Dependencies

- CodeMySpec.BddSpecs
- CodeMySpec.BddSpecs.SpecProjector
- CodeMySpec.Environments
- CodeMySpec.Stories
