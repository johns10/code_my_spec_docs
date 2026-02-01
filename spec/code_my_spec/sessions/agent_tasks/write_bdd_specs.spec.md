# CodeMySpec.Sessions.AgentTasks.WriteBddSpecs

**Type**: module

Agent task orchestrator for generating BDD specifications across all stories and acceptance criteria in a project. Coordinates serial processing of story/criterion pairs using WriteBddSpec for individual prompt generation, allowing shared givens to evolve between specs.

## Delegates

None

## Functions

### command/3

Generate the orchestration prompt for writing BDD specs across all project stories.

```elixir
@spec command(term(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:
1. Extract working directory and external_id from session
2. Create environment using Environments.create/2
3. Ensure shared givens file exists at `test/spex/support/shared_givens.ex`, scaffolding if missing
4. Fetch all stories with their acceptance criteria via Stories.list_project_stories/1
5. Find missing specs by checking coverage via BddSpecs.check_story_coverage/2 for each story
6. For each missing criterion, generate a prompt file using WriteBddSpec.command/3
7. Write prompt files to `.code_my_spec/internal/sessions/{external_id}/bdd_prompts/`
8. Build coverage report via BddSpecs.get_coverage_report/2
9. Return orchestration prompt with serial processing instructions

**Test Assertions**:
- returns complete prompt when no specs exist for any criteria
- returns "all complete" message when all criteria have valid specs
- generates one prompt file per missing criterion
- prompt files contain WriteBddSpec-generated content
- includes coverage report in orchestration prompt
- lists specs to write in numbered order with paths
- scaffolds shared_givens.ex if it does not exist
- uses existing shared_givens.ex if present
- derives app module name from project name for scaffold
- instructs serial processing (not parallel) for shared step evolution
- instructs mix compile verification after each spec
- skips generating prompt files for criteria that already have prompt files

### evaluate/3

Validate all BDD specs have been written correctly.

```elixir
@spec evaluate(term(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Fetch all stories with their acceptance criteria
2. For each story/criterion pair, check spec file at expected path
3. Parse each spec file using BddSpecs.Parser.parse_file/1
4. Verify each spec contains at least one scenario
5. Run `mix compile --warnings-as-errors` in working directory
6. If all validations pass and compile succeeds, cleanup prompt directory and return {:ok, :valid}
7. If validations fail, return {:ok, :invalid, feedback} with specific errors
8. If compile fails, return {:ok, :invalid, feedback} with compile output

**Test Assertions**:
- returns :valid when all specs exist, parse correctly, and compile
- returns :invalid with file path when spec file is missing
- returns :invalid with parse error when spec has syntax errors
- returns :invalid when spec has no scenarios
- returns :invalid with compile output when mix compile fails
- cleans up prompt directory on successful validation
- preserves prompt directory on validation failure
- lists all failing specs in feedback message
- includes story title and criterion id in feedback
- provides instructions for re-invoking sub-agents

## Dependencies

- CodeMySpec.Stories
- CodeMySpec.BddSpecs
- CodeMySpec.BddSpecs.Parser
- CodeMySpec.Environments
- CodeMySpec.AcceptanceCriteria
- CodeMySpec.Sessions.AgentTasks.WriteBddSpec
