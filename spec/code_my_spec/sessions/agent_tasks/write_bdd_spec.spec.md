# CodeMySpec.Sessions.AgentTasks.WriteBddSpec

**Type**: agent_task

Agent task module for generating BDD specification files from acceptance criteria via Claude Code slash commands. Takes a story and criterion as input, generates a prompt with the Spex DSL guide and acceptance criteria context, and validates the generated spec file parses correctly and covers the criterion requirements.

## Delegates

None

## Functions

### command/3

Generate the prompt for Claude to create a BDD specification file using the Spex DSL.

```elixir
@spec command(CodeMySpec.Users.Scope.t(), map(), keyword()) :: {:ok, String.t()} | {:error, term()}
```

**Process**:
1. Extract story and criterion from session map
2. Determine expected file path using BddSpecs.spec_file_path/2
3. Load the Spex DSL documentation/guide for the prompt
4. Build prompt including:
   - Story title and description for context
   - Criterion description and requirements
   - Spex DSL syntax guide with examples
   - Expected file path for the spec
5. Return the prompt text

**Test Assertions**:
- returns ok tuple with prompt text for valid session
- includes story title and description in prompt
- includes criterion description in prompt
- includes Spex DSL syntax guide in prompt
- includes expected file path from BddSpecs.spec_file_path/2
- includes Given/When/Then structure guidance
- returns error if story is missing from session
- returns error if criterion is missing from session

### evaluate/3

Validate the generated BDD spec file parses correctly and covers the criterion.

```elixir
@spec evaluate(CodeMySpec.Users.Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Extract story and criterion from session map
2. Determine spec file path using BddSpecs.spec_file_path/2
3. Validate file exists at expected path
4. Parse the spec file using BddSpecs.Parser
5. Verify spec contains at least one scenario
6. Verify scenarios contain Given/When/Then steps
7. Return :valid if all validations pass
8. Build revision feedback with specific issues if validation fails

**Test Assertions**:
- returns {:ok, :valid} when spec file is valid Spex DSL
- returns {:ok, :invalid, feedback} when spec file has syntax errors
- returns {:ok, :invalid, feedback} when spec has no scenarios
- returns {:ok, :invalid, feedback} when scenarios have no steps
- includes parse error details in feedback
- returns error when spec file does not exist
- returns error when story or criterion missing from session

## Dependencies

- CodeMySpec.BddSpecs
- CodeMySpec.BddSpecs.Parser
- CodeMySpec.Stories.Story
- CodeMySpec.AcceptanceCriteria.Criterion
- CodeMySpec.Environments
