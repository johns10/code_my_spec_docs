# CodeMySpec.AgentTasks.ComponentCode

## Type

module

Agent task module for component implementation sessions with Claude Code. Provides two entry points: `command/3` generates the implementation prompt with spec location, test file, similar components for patterns, and coding rules; `evaluate/3` checks code artifact requirements and queries persisted problems for the component's code and test files, returning combined feedback.

## Functions

### command/3

Generate the implementation prompt for Claude to code a component.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:
1. Extract component and project from session map
2. Get implementation rules matching component type and "code" session type via Rules.find_matching_rules/2
3. Fetch similar components via Components.list_similar_components/2 for pattern reference
4. Build implementation prompt with:
   - Project name and description
   - Component name, description, and type
   - Spec file path (from Utils.component_files/2)
   - Test file path for behavior expectations
   - Similar components formatted with their spec/code/test paths
   - Coding rules content
   - Target code file path for implementation
5. Return {:ok, prompt_text}

**Test Assertions**:
- returns ok tuple with prompt string
- includes spec file path in prompt
- includes test file path in prompt
- includes component name and type in prompt
- includes project name and description in prompt
- includes coding rules from matching rules
- includes similar components with file paths when available
- handles empty similar components list with fallback text
- handles component with no description

### evaluate/3

Evaluate Claude's implementation by checking code requirements and querying persisted problems.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Extract component and project from session map
2. Reload component from database via ComponentRepository.get_component/2
3. Check code artifact requirements via Requirements.check_requirements/4 with artifact_types: [:code]
4. Build requirement feedback from unsatisfied requirements (nil if all pass)
5. Check problems via ProblemFeedback.for_code_task/3 (queries code file + test file problems)
6. Combine requirement feedback and problem feedback via ProblemFeedback.combine/2

**Test Assertions**:
- returns {:ok, :valid} when all code requirements are satisfied and no problems exist
- returns {:ok, :invalid, feedback} when code requirements are unsatisfied
- returns {:ok, :invalid, feedback} when problems exist on code file even if requirements pass
- returns {:ok, :invalid, feedback} when problems exist on test file even if requirements pass
- returns {:ok, :invalid, feedback} combining requirement and problem feedback when both fail
- reloads component from database before checking requirements

## Dependencies

- CodeMySpec.AgentTasks.ProblemFeedback
- CodeMySpec.Components
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Requirements
- CodeMySpec.Requirements.RequirementsFormatter
- CodeMySpec.Rules
- CodeMySpec.Utils
