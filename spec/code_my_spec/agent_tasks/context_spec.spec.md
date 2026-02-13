# CodeMySpec.AgentTasks.ContextSpec

**Type**: module

Consolidated context spec session for Claude Code slash commands. Generates comprehensive prompts for creating Phoenix bounded context specifications with design rules, user stories, and similar component examples. Validates generated specs against artifact requirements, checks for persisted problems on the spec file, and creates child component spec files from parsed sections.

## Functions

### command/3

Generate the command/prompt for Claude to create a context specification.

```elixir
@spec command(Scope.t(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:
1. Extract component from session
2. Retrieve design rules using Rules.find_matching_rules/2 for "context" and "design" types
3. Fetch similar components using Components.list_similar_components/2
4. Load user stories for the context using Stories.list_component_stories/2
5. Build comprehensive prompt with build_spec_prompt/4 including:
   - Project name and description
   - Context name, description, and type
   - Formatted user stories with acceptance criteria
   - Similar component references with design/implementation/test file paths
   - Document specification from DocumentSpecProjector
   - Design rules text
   - Target spec file path
6. Return {:ok, prompt_text}

**Test Assertions**:
- generates prompt with all required sections (project, context, stories, similar components, document spec, design rules)
- includes design rules matching "context" and "design" types
- formats user stories with acceptance criteria
- formats similar components with file paths
- includes target spec file path from Utils.component_files/2
- returns {:ok, prompt} on success

### evaluate/3

Evaluate Claude's output by checking requirements, querying persisted problems, and creating child spec files.

```elixir
@spec evaluate(Scope.t(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()} | {:error, term()}
```

**Process**:
1. Reload the component via `ComponentRepository.get_component/2` to get current requirements
2. Check specification artifact requirements using `check_artifact_requirements/3`
   - If persisted requirements exist for `:specification`, filter and return them
   - If none exist, fall back to Registry definitions for the component type
3. Build requirement feedback from unsatisfied requirements (nil if all pass)
4. Check problems via `ProblemFeedback.for_spec_task/3` (queries spec file problems)
5. Combine requirement feedback and problem feedback via `ProblemFeedback.combine/2`
6. If invalid, return feedback immediately (problems block child stub creation)
7. If valid, read spec file and validate document structure
8. Create child spec stub files from parsed components section (won't overwrite existing)
9. Return `{:ok, :valid}` if child files created successfully

**Test Assertions**:
- returns {:ok, :valid} when specification requirements are satisfied, no problems, and child files created
- returns {:ok, :invalid, feedback} when specification requirements are unsatisfied
- returns {:ok, :invalid, feedback} when spec file has problems even if requirements pass
- returns {:ok, :invalid, feedback} combining requirement and problem feedback when both fail
- creates child spec files for components listed in Components section
- does not overwrite existing child spec files
- falls back to Registry definitions when no persisted requirements exist
- reloads component from database to get current requirements

## Dependencies

- CodeMySpec.AgentTasks.ProblemFeedback
- CodeMySpec.Components
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Components.Registry
- CodeMySpec.Documents
- CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.Environments
- CodeMySpec.Requirements
- CodeMySpec.Requirements.RequirementsFormatter
- CodeMySpec.Rules
- CodeMySpec.Stories
- CodeMySpec.Utils
