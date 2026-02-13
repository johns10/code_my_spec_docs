# CodeMySpec.AgentTasks.ComponentSpec

Agent task module for generating component specification documents via Claude Code slash commands.

This module orchestrates the workflow of creating component spec documents through AI agents. It provides two main entry points: `command/3` builds the initial prompt for Claude with design rules and document specifications, while `evaluate/3` validates the generated spec against artifact requirements and checks for persisted problems on the spec file.

## Delegates

None

## Functions

### command/3

Generate the prompt for Claude to create a component specification document.

```elixir
@spec command(CodeMySpec.Users.Scope.t(), map(), keyword()) :: {:ok, String.t()} | {:error, term()}
```

**Process**:
1. Extract component from session map
2. Retrieve design rules matching the component type using `Rules.find_matching_rules/2`
3. Build the complete spec prompt via `build_spec_prompt/2` with rules
4. Return the prompt text

**Test Assertions**:
- returns ok tuple with prompt text for valid session
- includes project name and description in prompt
- includes component name, description, and type in prompt
- includes design rules content in prompt
- includes document specification in prompt
- includes spec file path in prompt
- includes existing implementation file path when code exists
- includes existing test file path when tests exist
- includes parent component spec file path when parent exists
- returns error if rules cannot be loaded

### evaluate/3

Validate the generated spec file by checking requirements and querying persisted problems.

```elixir
@spec evaluate(CodeMySpec.Users.Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Reload the component via `ComponentRepository.get_component/2` to get current requirements
2. Check specification artifact requirements using `check_artifact_requirements/3`
   - If persisted requirements exist for `:specification`, filter and return them
   - If none exist, fall back to Registry definitions for the component type
3. Build requirement feedback from unsatisfied requirements (nil if all pass)
4. Check problems via `ProblemFeedback.for_spec_task/3` (queries spec file problems)
5. Combine requirement feedback and problem feedback via `ProblemFeedback.combine/2`

**Test Assertions**:
- returns {:ok, :valid} when specification requirements are satisfied and no problems exist
- returns {:ok, :invalid, feedback} when specification requirements are unsatisfied
- returns {:ok, :invalid, feedback} when spec file has problems even if requirements pass
- returns {:ok, :invalid, feedback} combining requirement and problem feedback when both fail
- includes requirement descriptions in feedback
- falls back to Registry definitions when no persisted requirements exist
- reloads component from database to get current requirements

## Dependencies

- CodeMySpec.AgentTasks.ProblemFeedback
- CodeMySpec.Components.Component
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Components.Registry
- CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.Environments
- CodeMySpec.Requirements
- CodeMySpec.Requirements.RequirementsFormatter
- CodeMySpec.Rules
- CodeMySpec.Utils
