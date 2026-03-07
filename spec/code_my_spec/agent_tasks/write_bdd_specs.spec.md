# CodeMySpec.AgentTasks.WriteBddSpecs

## Type

agent_task

Agent task module for generating BDD specification files for a single story at a time. Writes specs for all acceptance criteria of one story. Auto-selects the top-priority incomplete story if none specified in the session. Generates a comprehensive prompt, writes it to a subagent prompt file, and returns a short orchestration prompt instructing the agent to invoke the bdd-spec-writer subagent.

## Delegates

None

## Functions

### command/3

Generate the prompt for Claude to create BDD specification files for a story.

```elixir
@spec command(term(), map(), keyword()) :: {:ok, String.t()} | {:error, term()}
```

**Process**:
1. Extract environment from scope and external_conversation_id from session
2. Resolve story: use session.story_id if provided, otherwise auto-select via BddSpecs.get_next_incomplete_story/2
3. Return {:error, :all_stories_complete} if no incomplete stories exist
4. Get the linked component for the story
5. Return {:error, :component_not_linked} if story has no component
6. Ensure app_spex.ex and shared givens file exist, scaffolding if missing
7. Check story coverage via BddSpecs.check_story_coverage/2
8. Build comprehensive prompt including:
   - Story context (id, title, description, priority)
   - Component under test (module, type)
   - All acceptance criteria with status (covered/missing) and expected file paths
   - Component-specific testing guide (LiveView, Controller, or generic)
   - Current shared givens content
   - Shared givens usage instructions
   - Spex DSL syntax guide
9. Write prompt to subagent prompt file at `.code_my_spec/internal/sessions/{external_id}/subagent_prompts/bdd_specs_story_{story_id}.md`
10. Return short orchestration prompt referencing the file path and bdd-spec-writer subagent

**Test Assertions**:
- writes prompt file to disk and returns orchestration prompt
- orchestration prompt references the prompt file path
- orchestration prompt references bdd-spec-writer subagent
- prompt file includes all acceptance criteria
- prompt file includes expected file paths for each criterion
- prompt file includes Spex DSL syntax guide
- prompt file includes LiveView testing guide for liveview components
- prompt file includes Controller testing guide for controller components
- prompt file marks covered criteria
- prompt file includes current shared givens content
- scaffolds app_spex.ex and shared_givens.ex if they do not exist
- returns {:error, :all_stories_complete} when all stories have complete coverage
- returns {:error, :component_not_linked} when story has no component_id
- auto-selects top-priority incomplete story when no story_id in session
- skips fully covered story and selects next incomplete story

### evaluate/3

Validate all BDD specs for the current story.

```elixir
@spec evaluate(term(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Extract environment from scope and external_conversation_id from session
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
   - Clean up the prompt file for this story
   - Attempt to remove the prompt directory if empty
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
- cleans up prompt file on valid result

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.BddSpecs
- CodeMySpec.BddSpecs.Parser
- CodeMySpec.Components
- CodeMySpec.Environments
