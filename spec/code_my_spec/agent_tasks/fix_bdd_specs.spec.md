# CodeMySpec.AgentTasks.FixBddSpecs

## Type

agent_task

Agent task module for fixing failing BDD specifications. Reads spex failures from the Problems table, derives which stories and components they belong to, filters to only failures whose component has a satisfied `implementation_file` requirement, and builds a prompt instructing the agent to fix the implementation code so the specs pass.

## Delegates

None

## Functions

### command/3

Read failing spex problems and build a fix prompt.

```elixir
@spec command(term(), map(), keyword()) :: {:ok, String.t()}
```

**Process**:
1. Query all spex problems via `Problems.list_project_problems(scope, source: "spex")`
2. If none exist, return early with "all BDD specs passing" message
3. Filter to relevant problems:
   a. Derive story_id from each problem's file_path via `Parser.derive_story_id/1`
   b. Discard problems with no derivable story_id
   c. Group by story_id and load each story via `Stories.get_story/2`
   d. Discard stories with no component_id
   e. Load component via `Components.get_component/2` (preloads requirements)
   f. Keep only problems where the component's `implementation_file` requirement is satisfied
4. If no relevant problems remain, return "unimplemented components" message
5. Group remaining problems by story and build prompt including:
   - Story title and ID
   - Component module name and file paths via `Utils.component_files/2`
   - Each failing spec's file path, line, message, severity, and file content
   - Current implementation code and test file content via `Environments.read_file/2`
   - Instructions to fix implementation code (not specs)
6. Return `{:ok, marker <> prompt}`

**Test Assertions**:
- returns all-passing message when no spex problems exist
- returns unimplemented message when all failures are for unimplemented components
- builds fix prompt with failure details for implemented components
- includes component module name in prompt
- filters out problems with no derivable story_id

### evaluate/3

Check that no relevant spex failures remain.

```elixir
@spec evaluate(term(), map(), keyword()) :: {:ok, :valid} | {:ok, :invalid, String.t()}
```

**Process**:
1. Query all spex problems via `Problems.list_project_problems(scope, source: "spex")`
2. If none exist, return `{:ok, :valid}`
3. Apply same filter pipeline as command/3 to get relevant problems
4. If no relevant problems remain, return `{:ok, :valid}`
5. Build feedback listing each remaining failure with file path, story title, and message
6. Return `{:ok, :invalid, feedback}` with count and details

**Test Assertions**:
- returns {:ok, :valid} when no spex problems exist
- returns {:ok, :valid} when all failures are for unimplemented components
- returns {:ok, :invalid, feedback} when relevant failures remain
- feedback includes count of remaining failures

## Dependencies

- CodeMySpec.Problems
- CodeMySpec.BddSpecs.Parser
- CodeMySpec.Stories
- CodeMySpec.Components
- CodeMySpec.Environments
- CodeMySpec.Utils
- CodeMySpec.AgentTasks.TaskMarker
