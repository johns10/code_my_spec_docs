# CodeMySpec.AgentTasks.ComponentCode

## Type

module

Agent task module for component implementation sessions with the coding agent. Provides four entry points: `command/2` generates the implementation prompt with spec/test/code paths, project context, and component-type-scoped coding rules; `evaluate/2` checks code artifact requirements and queries persisted problems on the code and test files, returning combined feedback; `analyzers/0` declares the analyzers that keep persisted problems fresh; `orchestrate/1` builds the parent-context prompt that spawns a `@code-writer` sub-agent against this requirement and component.

## Functions

### command/2

Generate the implementation prompt for the coding agent.

```elixir
@spec command(Scope.t(), map()) :: {:ok, String.t()}
```

**Process**:
1. Load the component via `Components.get_component!/2` using `task.component_id`
2. Take the project from `scope.active_project`
3. Resolve the matching coding rules via `Rules.find_matching_rules/3` filtered by component type and the `"code"` session, scoped to `scope.environment.cwd`
4. Build the implementation prompt with:
   - Project name and description
   - Component name, description (with `"No description provided"` fallback when nil), and type
   - Spec file path, test file path, and target code file path from `Utils.component_files/2`
   - Coding rules content joined into the Coding Rules section
5. Return `{:ok, prompt_text}`

**Test Assertions**:
- returns `{:ok, prompt}` with a string prompt
- prompt includes the spec file path, test file path, and target code file path
- prompt includes the project name and project description
- prompt includes the component name, description, and type
- prompt includes the Coding Rules section content from matching rules
- only rules matching the component type and `"code"` session appear in the Coding Rules section
- rules for other component types or other session kinds are filtered out
- when no rules match, the Coding Rules section renders without rule content
- when the component description is nil, the prompt renders the literal `"No description provided"` in the description slot

### evaluate/2

Evaluate the coding agent's output by checking code artifact requirements and persisted problems.

```elixir
@spec evaluate(Scope.t(), map()) :: {:ok, :valid} | {:ok, :invalid, String.t()}
```

**Process**:
1. Load the component via `Components.get_component!/2` using `task.component_id`
2. Take the project from `scope.active_project`
3. Reload the component via `ComponentRepository.get_component/2` so the freshest persisted state (including problems written by analyzers since `command/2` fired) drives the gate
4. Check code artifact requirements via `Requirements.check_artifact_requirements/3` with `:code`
5. Build requirement feedback from unsatisfied requirements via `RequirementsFormatter.format_unsatisfied/2` with context `"Code requirements not met:"`; nil when all requirements pass
6. Build problem feedback via `ProblemFeedback.for_code_task/3` (queries problems on the component's code file and test file)
7. Combine via `ProblemFeedback.combine/2` — returns `{:ok, :valid}` when both are nil, otherwise `{:ok, :invalid, combined_feedback}`

**Test Assertions**:
- returns `{:ok, :valid}` when all code requirements are satisfied and no problems exist on the code or test file
- returns `{:ok, :invalid, feedback}` framed as `"Code requirements not met:"` when at least one code requirement is unsatisfied
- returns `{:ok, :invalid, feedback}` when a persisted problem exists on the component's code file even if requirements pass
- returns `{:ok, :invalid, feedback}` when a persisted problem exists on the component's test file even if requirements pass
- returns `{:ok, :invalid, feedback}` combining requirement and problem feedback when both fail
- reloads the component from the database before checking so analyzer output written between `command/2` and `evaluate/2` is honored

### analyzers/0

Declare analyzers the harness should run before evaluation so persisted problems stay fresh.

```elixir
@spec analyzers() :: [atom()]
```

**Process**:
1. Return `[:exunit_stale]`

**Test Assertions**:
- returns `[:exunit_stale]` so the harness re-runs the test suite on code changes
- returned list is the contract the harness reads via `analyzers/0` — adding/removing analyzers is a deliberate change

### orchestrate/1

Build the parent-context prompt that instructs the parent to spawn a `@code-writer` sub-agent against this specific requirement and component entity.

```elixir
@spec orchestrate(map()) :: {:ok, String.t()} | {:error, :invalid_node}
```

**Process**:
1. Validate the node has `name`, `entity_type`, `entity_id`, and `entity_name`
2. On invalid node, return `{:error, :invalid_node}` so the caller never emits a prompt with nil interpolations
3. Build the spawn instruction string naming the requirement, entity type, entity id, and entity name
4. Return `{:ok, prompt_text}`

**Test Assertions**:
- returns `{:ok, prompt}` for a node with name, entity_type, entity_id, and entity_name
- prompt names the `@code-writer` sub-agent
- prompt names `start_task` with the requirement (`node.name`)
- prompt names the entity type, entity id, and entity name
- returns `{:error, :invalid_node}` when name is missing
- returns `{:error, :invalid_node}` when entity_type is missing
- returns `{:error, :invalid_node}` when entity_id is missing
- returns `{:error, :invalid_node}` when entity_name is missing

## Dependencies

- CodeMySpec.AgentTasks.ProblemFeedback
- CodeMySpec.Components
- CodeMySpec.Components.ComponentRepository
- CodeMySpec.Requirements
- CodeMySpec.Requirements.RequirementsFormatter
- CodeMySpec.Rules
- CodeMySpec.Utils
