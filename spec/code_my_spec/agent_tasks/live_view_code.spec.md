# CodeMySpec.AgentTasks.LiveViewCode

**Type**: module

Implements a LiveView module to pass its tests, with visual feedback from rendered screenshots. Like ComponentCode but the evaluate step also reads screenshots produced by headless-rendering the HTML artifacts captured during tests. Tests save rendered HTML at key visual states; a post-processing step renders those artifacts in a headless browser to produce screenshots. When tests pass, the agent still sees the screenshots to confirm the UI looks correct before declaring done. References a resources directory for progressive-disclosure LiveView guidance rather than embedding it in the prompt.

## Dependencies

- CodeMySpec.Rules
- CodeMySpec.Components
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Requirements
- CodeMySpec.Requirements.RequirementsFormatter

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

Evaluate Claude's implementation by checking code artifact requirements. Run tests, render HTML artifacts in headless browser to produce screenshots, and provide visual + functional feedback.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Extract component from session map
2. Reload component from database via ComponentRepository.get_component/2 to get latest requirements
3. Check code artifact requirements via Requirements.check_requirements/4 with artifact_types: [:code]
4. If any requirements unsatisfied, return {:ok, :invalid, feedback} with formatted unsatisfied requirements
5. If all code requirements satisfied, return {:ok, :valid}

**Test Assertions**:
- returns {:ok, :valid} when all code requirements are satisfied
- returns {:ok, :invalid, feedback} when implementation_file requirement is unsatisfied
- returns {:ok, :invalid, feedback} when tests_passing requirement is unsatisfied
- ignores non-code artifact type requirements
- feedback includes "requirements not met" context message
- reloads component from database before checking requirements
