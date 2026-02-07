# CodeMySpec.AgentTasks.WriteBddSpecs

**Type**: agent_task

Agent task module for generating BDD specification files for a single story at a time. Writes specs for all acceptance criteria of one story. Auto-selects the top-priority incomplete story if none specified in the session. Generates a comprehensive prompt with story context, testing guides based on component type, and shared givens instructions.

## Delegates

None

## Functions

### command/3

Generate the prompt for Claude to create BDD specification files for a story.

```elixir
@spec command(term(), map(), keyword()) :: {:ok, String.t()} | {:error, term()}
```

**Process**:
1. Extract environment from session (session.environment)
2. Resolve story: use session.story_id if provided, otherwise auto-select via BddSpecs.get_next_incomplete_story/2
3. Return {:error, :all_stories_complete} if no incomplete stories exist
4. Get the linked component for the story
5. Return {:error, :component_not_linked} if story has no component
6. Ensure shared givens file exists at `test/spex/support/shared_givens.ex`, scaffolding if missing
7. Check story coverage via BddSpecs.check_story_coverage/2
8. Build comprehensive prompt including:
   - Story context (id, title, description, priority)
   - Component under test (module, type)
   - All acceptance criteria with status (covered/missing) and expected file paths
   - Component-specific testing guide (LiveView, Controller, or generic)
   - Current shared givens content
   - Shared givens usage instructions
   - Spex DSL syntax guide
9. Return the prompt text

**Test Assertions**:
- returns ok tuple with prompt text when story has missing criteria
- returns {:error, :all_stories_complete} when all stories have complete coverage
- returns {:error, :component_not_linked} when story has no component_id
- returns {:error, :component_not_found} when component doesn't exist
- auto-selects top-priority incomplete story when no story_id in session
- uses story_id from session when provided
- skips fully covered story and selects next incomplete story
- includes story title and description in prompt
- includes all acceptance criteria with coverage status
- includes expected file paths for each criterion
- includes LiveView testing guide for liveview components
- includes Controller testing guide for controller components
- includes generic testing guide for other component types
- includes current shared givens content
- scaffolds shared_givens.ex if it does not exist
- uses existing shared_givens.ex if present
- derives app module name from mix.exs for scaffold
- includes Spex DSL syntax guide in prompt

### evaluate/3

Validate all BDD specs for the current story.

```elixir
@spec evaluate(term(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Extract environment from session (session.environment)
2. Resolve story (same logic as command/3)
3. For each acceptance criterion in the story:
   - Check spec file exists at expected path
   - Parse using BddSpecs.Parser.parse_file/1
   - Verify spec contains at least one scenario
   - Verify scenarios contain Given/When/Then steps
4. If any specs are missing or invalid:
   - Build feedback with specific errors per criterion
   - Return {:ok, :invalid, feedback}
5. If all specs valid, run `mix compile --warnings-as-errors` in working directory
6. If compilation fails:
   - Return {:ok, :invalid, feedback} with compile output
7. If all valid and compiles:
   - Return {:ok, :valid}

**Test Assertions**:
- returns {:ok, :valid} when all specs exist, parse correctly, and compile
- returns {:ok, :invalid, feedback} when spec file is missing
- returns {:ok, :invalid, feedback} when spec has syntax errors
- returns {:ok, :invalid, feedback} when spec has no scenarios
- returns {:ok, :invalid, feedback} when scenarios have no steps
- returns {:ok, :invalid, feedback} when mix compile fails
- includes criterion id and description in error feedback
- includes parse error details in feedback
- returns error when story cannot be resolved

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.BddSpecs
- CodeMySpec.BddSpecs.Parser
- CodeMySpec.Components
- CodeMySpec.Environments
