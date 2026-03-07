# CodeMySpec.AgentTasks.LiveViewCode

## Type

module

Implements a LiveView module to pass its tests, with visual feedback from rendered screenshots. Like ComponentCode but the evaluate step also reads screenshots produced by headless-rendering the HTML artifacts captured during tests. Tests save rendered HTML at key visual states; a post-processing step renders those artifacts in a headless browser to produce screenshots. When tests pass, the agent still sees the screenshots to confirm the UI looks correct before declaring done. References a resources directory for progressive-disclosure LiveView guidance rather than embedding it in the prompt.

## Dependencies

- CodeMySpec.AgentTasks.ProblemFeedback
- CodeMySpec.Components
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Requirements
- CodeMySpec.Requirements.RequirementsFormatter
- CodeMySpec.Rules
- CodeMySpec.Utils

## Functions

### command/3

Generate the implementation prompt for a LiveView, referencing spec, tests, coding rules, and a resources directory for LiveView-specific guidance.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:
1. Extract component and project from session map
2. Get implementation rules matching component type and "code" session type via Rules.find_matching_rules/2
3. Fetch similar components via Components.list_similar_components/2 for pattern reference
4. Build implementation prompt with:
   - Task marker via TaskMarker.build("LiveViewCode", component.module_name)
   - Project name and description
   - Component name, description, and type
   - Spec file path (from Utils.component_files/2)
   - Test file path for behavior expectations
   - Resources directory path for progressive-disclosure LiveView guidance
   - Similar components formatted with their spec/code/test paths
   - Coding rules content
   - Target code file path for implementation
5. Return {:ok, prompt_text}

**Test Assertions**:
- returns ok tuple with prompt string containing task marker
- includes spec file path and test file path in prompt
- includes component name and type in prompt
- includes project name and description in prompt
- includes coding rules from matching rules
- includes resources directory path for progressive disclosure
- includes similar components with file paths when available
- handles empty similar components list with fallback text
- handles component with no description

### evaluate/3

Evaluate Claude's implementation by checking code artifact requirements and querying persisted problems.

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
- returns {:ok, :invalid, feedback} when implementation_file requirement is unsatisfied
- returns {:ok, :invalid, feedback} when tests_passing requirement is unsatisfied
- returns {:ok, :invalid, feedback} when problems exist on code or test files even if requirements pass
- returns {:ok, :invalid, feedback} combining requirement and problem feedback when both fail
- ignores non-code artifact type requirements
- reloads component from database before checking requirements
