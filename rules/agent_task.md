---
component_type: "agent_task"
session_type: "code"
---

# Agent Task Rules

Agent tasks live in `lib/code_my_spec/agent_tasks/` and drive the Claude Code slash-command workflow. Each task module generates prompts for Claude and validates the output.

## Core Interface

Every agent task implements up to four public functions:

```elixir
def command(scope, session, opts \\ [])     # Build the initial prompt
def evaluate(scope, session, opts \\ [])    # Validate output, return feedback or :valid
def orchestrate(scope, session, opts \\ []) # Write prompt files for multi-step orchestration
def orchestrate_evaluate(scope, session, opts \\ []) # Evaluate within orchestration context
```

- `command/3` returns `{:ok, prompt_text}`.
- `evaluate/3` returns `{:ok, :valid}`, `{:ok, :invalid, feedback}`, or `{:error, reason}`.
- `orchestrate/3` and `orchestrate_evaluate/3` delegate to `ProjectCoordinator.default_orchestrate/4` unless custom orchestration is needed.

## Task Categories

### 1. Artifact Tasks (component-scoped)

Tasks that produce a single artifact for a component: spec, test, or code file.

**Examples:** `ComponentSpec`, `ComponentCode`, `ComponentTest`, `ContextSpec`, `LiveViewSpec`

**Pattern:**
- `command/3` builds a prompt with rules, document specs, similar components, and context.
- `evaluate/3` delegates to requirement checkers via `Requirements.check_artifact_requirements/3`, then adds problem feedback via `ProblemFeedback`.
- Embed a `TaskMarker` in the prompt so subagent transcripts are self-identifying.

```elixir
def evaluate(scope, session, _opts \\ []) do
  component = ComponentRepository.get_component(scope, session.component.id)
  reqs = Requirements.check_artifact_requirements(scope, component, :specification)
  unsatisfied = Enum.filter(reqs, &(not &1.satisfied))

  req_feedback =
    if Enum.empty?(unsatisfied), do: nil,
    else: RequirementsFormatter.format_unsatisfied(unsatisfied, context: "...")

  problem_feedback = ProblemFeedback.for_spec_task(scope, component, session.project)
  ProblemFeedback.combine(req_feedback, problem_feedback)
end
```

**Key rule:** Never re-implement checker logic in evaluate. Call `check_artifact_requirements` or the checker module directly and format the result as feedback.

### 2. Orchestrator Tasks (multi-step workflows)

Tasks that coordinate multiple phases or subagents. They manage state, write prompt files, and advance through phases.

**Examples:** `DevelopContext`, `DevelopLiveView`, `WriteBddSpecs`, `QaStory`, `ManageImplementation`

**Pattern:**
- `command/3` detects the current phase and returns a phase-appropriate prompt.
- `evaluate/3` is a state machine that checks each phase artifact in order.
- `orchestrate/3` writes prompt and problem files for the main agent to delegate.
- Use `Environments` for all file operations (not raw `File` calls).

```elixir
def evaluate(scope, session, _opts \\ []) do
  with :ok <- check_phase_1(env),
       :ok <- check_phase_2(env),
       {:ok, result} <- check_phase_3(env) do
    {:ok, :valid}
  else
    {:ok, :invalid, feedback} -> {:ok, :invalid, feedback}
  end
end
```

Orchestrator evaluate functions are intentionally richer than their corresponding requirement checkers. The checker answers "is the final artifact present?" while evaluate manages the full phase progression. This divergence is expected.

### 3. Topic Tasks (project-scoped, no component)

Tasks that operate on a project-level topic passed via `session.state["topic"]`.

**Examples:** `QaStory` (topic = story ID), `ResearchTopic` (topic = research subject), `TriageIssues`, `FixIssues`

**Pattern:**
- Read the topic from `session.state["topic"]`.
- No component lookup needed; registered in `StartAgentTask.@topic_tasks` or `@componentless_tasks`.

### 4. Bootstrap Tasks (no project required)

Tasks that run before a project is fully configured.

**Examples:** `ProjectSetup`

**Pattern:**
- Minimal scope -- only environment/cwd, no active project.
- Registered in `StartAgentTask.@bootstrap_tasks`.

## Relationship to Requirements

Each requirement definition in `RequirementDefinitionData` has a `satisfied_by` field pointing to an agent task module. This is how the system knows which task to run when a requirement is unsatisfied.

### Evaluate must delegate to checkers

For artifact tasks, `evaluate/3` should call `Requirements.check_artifact_requirements/3` rather than re-implementing the checker logic. This keeps the checker as the single source of truth for "is this requirement satisfied?"

The component artifact tasks already follow this pattern well. If your task validates something that a checker also validates, call the checker.

### When custom evaluate logic is appropriate

- **Phase management:** Orchestrators need to track multi-step progress (e.g., QaStory's plan/brief/result phases). The checker only gates on the final artifact.
- **Side effects:** Some evaluate functions trigger actions on completion (e.g., QaStory files issues when result is valid). Checkers are pure validation.
- **Richer feedback:** Evaluate returns actionable prose for Claude. Checkers return structured data for the requirement graph. Evaluate should format checker results into useful feedback, not duplicate the validation.

## Conventions

### TaskMarker

Every task prompt must include a `TaskMarker` so subagent transcripts can be identified by the validation hook:

```elixir
TaskMarker.build("ComponentSpec", component.module_name)
# => <!-- cms:task type="ComponentSpec" component="MyApp.Accounts.User" -->
```

### ProblemFeedback

Use `ProblemFeedback` to query persisted problems (compilation errors, credo, spec alignment) and format them as feedback:

```elixir
problem_feedback = ProblemFeedback.for_code_task(scope, component, project)
ProblemFeedback.combine(req_feedback, problem_feedback)
```

`ProblemFeedback.combine/2` merges requirement feedback and problem feedback into the correct return tuple.

### Orchestrate delegation

Most tasks delegate orchestration to `ProjectCoordinator`:

```elixir
def orchestrate(scope, session, opts \\ []) do
  ProjectCoordinator.default_orchestrate(__MODULE__, scope, session, opts)
end

def orchestrate_evaluate(scope, session, opts \\ []) do
  ProjectCoordinator.default_orchestrate_evaluate(__MODULE__, scope, session, opts)
end
```

Only override when the task needs custom orchestration (e.g., QaStory writes phase-specific prompt files).

### File operations

Use `Environments` for all filesystem access. Never use raw `File` module calls. This enables testing with virtual filesystems.

```elixir
Environments.read_file(env, path)
Environments.write_file(env, path, content)
Environments.file_exists?(env, path)
Environments.glob(env, pattern)
```

### Registration

New tasks must be registered in `StartAgentTask`:
1. Add to `@session_type_map` with a string key.
2. Add to the appropriate category list (`@componentless_tasks`, `@topic_tasks`, `@bootstrap_tasks`, or none for component tasks).
3. If the task satisfies a requirement, add `satisfied_by: YourTask` to the requirement definition in `RequirementDefinitionData`.

### Return values

- `command/3`: Always `{:ok, prompt}` or `{:error, reason}`.
- `evaluate/3`: Always `{:ok, :valid}`, `{:ok, :invalid, feedback_string}`, or `{:error, reason}`.
- Keep feedback strings actionable -- tell Claude exactly what to fix and where.
