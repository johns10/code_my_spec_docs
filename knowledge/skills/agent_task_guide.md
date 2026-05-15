# Agent Task Design Guide (CodeMySpec)

An **agent task** in CodeMySpec is a skill with three things bolted on:

1. **Dynamic prompt generation** — the prompt is built from current project state (decisions, components, files, requirements) rather than living in a static markdown file.
2. **A validation gate** — `evaluate/2` is the "skill-scoped stop hook" the platform won't give us. It runs after each turn and decides whether the work is done.
3. **A central dispatcher** — `StartAgentTask` routes incoming requests by type instead of relying on each platform's native skill discovery.

Everything skill design teaches still applies. This guide tells you which skill principle maps to which part of the agent_task contract, and where the codebase already does it well or badly.

## The skill ↔ agent_task mapping

| Skill concept | Agent task equivalent |
|---|---|
| `name` | Module name + entry in `@session_type_map` in `start_agent_task.ex:33` |
| `description` (routing signal) | `orchestrate/1` return string |
| `SKILL.md` body | `command/2` return prompt |
| `references/foo.md` | `priv/knowledge/**.md`, referenced by direct path in the prompt (preferred) or via the knowledge MCP `semantic_search` (discovery only) |
| `scripts/foo.py` | Helper modules + `Environments.*` functions (no first-class script convention) |
| `allowed-tools` | MCP tools documented in prose inside the prompt |
| Per-skill stop hook *(doesn't exist on Claude Code)* | `evaluate/2` + the unified `Evaluator` |
| Progressive disclosure tiers | The way `command/2` writes its prompt (see below) |
| Skill vs subagent vs slash command | Component / componentless / topic / bootstrap dispatch + `execution_type` |

## The agent_task contract

Required:

```elixir
def command(scope, task), do: {:ok, prompt}
```

Optional, in order of how often you'll need them:

```elixir
def evaluate(scope, task), do: {:ok, :valid} | {:ok, :invalid, feedback}
def orchestrate(node), do: "<description-style string>"
def before_evaluate(scope, task), do: :ok          # side effects before validation
def init_session(scope, session), do: {:ok, session}  # mutate session before command/2 runs
def analyzers, do: []                              # legacy
```

If you don't export `evaluate/2`, the unified `Evaluator` (in `agent_tasks/evaluator.ex`) drives validation via the `RequirementCalculator` against the task's requirement definition. Prefer that over hand-rolled evaluation logic — see "When to write custom `evaluate/2`" below.

## Dispatch routing — pick the right shape

`StartAgentTask` (`start_agent_task.ex`) routes by type. Pick deliberately:

| Shape | When to use | Listed in `start_agent_task.ex` |
|---|---|---|
| `bootstrap_task` | Runs before a project exists (no project_id, no requirement graph) | `@bootstrap_tasks` (line 73) |
| `project_task` | Project-wide validation before the session even opens | `@project_tasks` (line 76) |
| `componentless_task` | Project-scoped but not tied to a specific component | `@componentless_tasks` (line 79) |
| `topic_task` | Takes a free-form topic/story_id, bypasses the requirement graph | `@topic_tasks` (line 106) |
| (default) `component_task` | Operates on one component, dispatched by the requirement graph | not listed; this is the fallthrough |

Decision tree:

```
Does this task need an active project?
├── No  → bootstrap_task
└── Yes
    ├── Does it operate on a free-form topic the graph doesn't know about (story_id, research topic)?
    │   └── topic_task
    ├── Does it need project-wide validation before opening the session (e.g. spex batch run)?
    │   └── project_task
    ├── Does it operate on the project as a whole (architecture, code generation, qa)?
    │   └── componentless_task
    └── Default: scoped to one component
        └── component_task
```

When you add a new task, you also need to:
1. Add the module to `@session_type_map`.
2. Add the type string to the appropriate dispatch list (`@bootstrap_tasks`, etc.).
3. If the task has custom evaluation logic, add the module to `Evaluator.custom_evaluate_modules/0` (`evaluator.ex:66`).

## `command/2` — apply progressive disclosure

The prompt your `command/2` returns is the equivalent of `SKILL.md`'s body — it sits in the agent's context for the rest of the session. The skill rules apply:

- **Keep it under ~500 lines / 1,500–2,000 words.** Once loaded, every token competes with conversation history.
- **Quick start, then decision tree, then references.** Not protocol dump.
- **Reference, don't inline.** Point the agent at `priv/knowledge/` or `.code_my_spec/` docs instead of pasting 70 lines of static protocol.
- **Dynamic context is fine.** Inspecting decisions, components, generators-already-run, file state — that's the *point* of agent tasks over static skills. Do it.

The good pattern (from `three_amigos.ex`):

```
## Read the playbook first

Before writing anything, query the knowledge MCP server for protocol
guidance:

- `semantic_search` with a query about the Three Amigos protocol,
  readiness rules, and scenario quality bar.
```

This is the references-loaded-on-demand pattern. The protocol body still lives in the prompt today (~70 lines) — but the door is open to move it out.

The bad pattern (from `code_generation.ex`): 350+ lines, with section after section of static instructions inlined alongside the dynamic project state. Most of that is reference material, not procedure.

### Suggested `command/2` shape

```elixir
def command(scope, task) do
  state = inspect_project_state(scope)        # dynamic context
  
  prompt = """
  # <Task name>
  
  ## What you're doing
  
  <one paragraph — the orchestrate/1 description, expanded>
  
  ## Current state
  
  <dynamic: what's already done, what's pending>
  
  ## Read the playbook first
  
  Use the knowledge MCP `semantic_search` for "<topic>" — the corpus has
  the protocol, decision rules, and quality bar.
  
  ## What you need to produce
  
  <concrete deliverable list, dynamic if possible>
  
  ## Required tools
  
  <MCP tools you'll call, with brief why-each>
  
  ## Done signal
  
  <how evaluate/2 will know you're done>
  """
  
  {:ok, prompt}
end
```

If the prompt grows past ~200 lines, look for blocks of static reference material to move into `priv/knowledge/`.

## `orchestrate/1` — apply the description rubric

`orchestrate/1` is what the requirements graph shows when this task surfaces as the next thing to do. It's the routing signal — equivalent to a skill's `description`. Apply the [description rubric](description_rubric.md):

❌ Current (from `code_generation.ex:23`):
```
"Call `start_task` with requirement `#{node.name}` for #{node.entity_type} `#{node.entity_id}` (#{node.entity_name})"
```
This is mechanics, not intent. It tells the agent *how* to dispatch, not *what* the task does or *when* to reach for it.

✅ Better:
```
"Run code generators (phx.gen.auth, cms_gen.accounts, integrations, feedback widget) based on the project's technical decisions. Produces an idempotent generation script. Call `start_task` with requirement `#{node.name}`."
```

This says what + when + concrete output, then includes the dispatch instruction at the end.

For tasks where `orchestrate/1` is rendered into requirement graph output for the agent, treat it the way you'd treat a `description` in a `SKILL.md`. The agent uses it to decide whether to start the task.

## `evaluate/2` — when to write custom logic

Default: don't. Let the unified `Evaluator` drive validation via the `RequirementCalculator` against the requirement definition. The calculator already:
- Syncs files (filesystem → DB).
- Runs `before_evaluate/2` for side effects.
- Loads `Files` for the entity (component / story / project).
- Computes satisfaction against the requirement definition.
- Formats feedback.

Write custom `evaluate/2` only when:
1. The done signal can't be expressed as a `RequirementCalculator` check (e.g., `StartImplementation` checks `next_actionable`; `Init` runs sub-step evaluations).
2. You need to delegate to a checker module that isn't part of the requirements graph (e.g., `ThreeAmigos` calls `BddRulesChecker.complete?`).
3. The task is bootstrap-shaped (no requirement definition exists yet, like `ProjectSetup`).

If you add a custom `evaluate/2`, register the module in `Evaluator.custom_evaluate_modules/0` — otherwise the unified evaluator will run first and produce confusing feedback before your custom logic even sees the request.

## `before_evaluate/2` — side effects, not validation

This is for *mutations the evaluator needs to see*. Examples:
- Executing a proposal that was generated during the session.
- Re-running a sync step after the agent did something off-graph.

Don't put validation in `before_evaluate/2` — that belongs in `evaluate/2` or the requirement check. Keep the boundary clean.

## Sub-step orchestration pattern

Several tasks (Init, ProjectSetup, Setup.*) break their work into ordered sub-steps. Each sub-step is its own module with `command/2` + `evaluate/2` (often `check/1` or `evaluate/1`), and the parent task composes them.

Reference implementation: `agent_tasks/init.ex`. The pattern:

```elixir
@steps [Init.Auth, Init.Elixir, Init.PhoenixInstaller, ...]

def command(scope, _task) do
  evaluated = evaluate_all(scope)
  incomplete = incomplete_steps(evaluated)
  
  # Render checklist + inline prompts for incomplete steps
end

def evaluate(scope, _task) do
  if all_done?(scope), do: {:ok, :valid}, else: {:ok, :invalid, progress_report}
end
```

Use this when:
- The work is genuinely ordered and each step has its own validation.
- You want the agent to see progress (checklist with `[x]` / `[ ]`) and the "next" pointer.
- Steps share a common context object (cf. `Setup.Context` loading files once for all steps).

Don't use this when:
- The work is one continuous reasoning pass.
- Steps are independent and can run in any order (use separate top-level tasks).

## `priv/knowledge/` as the `references/` layer

This codebase doesn't have a `references/` directory next to each task — it has `priv/knowledge/` with subdirectories organized by topic.

Use it as the references layer:

1. Long-form protocol (BDD authoring, three amigos workshop, spex conventions) → `priv/knowledge/bdd/**.md`.
2. Decision rules, architecture conventions → `priv/knowledge/<topic>/**.md`.
3. `command/2` prompt points the agent at the specific file path.

The "for X, see [references/X.md]" link from skill design becomes:
```
Read `priv/knowledge/<topic>/<file>.md` for <what's there>.
```

**Prefer direct path over `semantic_search`.** If the task author knows which doc applies — and they usually do, since they wrote it — point at the path. Direct read is deterministic, one tool call, and easier for the agent to act on.

Use `semantic_search` only for **discovery**: cases where the agent has to figure out which doc applies (e.g., "find guidance on this error pattern", "look up conventions for this domain"). If you can answer "which doc do I need" at design time, hard-code the path.

This works as long as:
- The path actually exists and contains the content described.
- You keep the path stable, or update the prompt when you move the doc.

## Tools — document them, route the agent

Like skills, agent tasks can't install MCP servers. Be explicit about what the task expects.

The good pattern (from `three_amigos.ex`):
```
Use these MCP tools to persist work:
- `add_persona` / `list_personas` / `link_persona_to_story` — persona management
- `add_rule` — store rules on the story
- `add_scenario` — store scenarios on the story
- `add_question` — park open questions
```

The bad pattern: prompts that say "use the right tools" without naming them. The agent will guess or wander.

## Anti-patterns

| Anti-pattern | Where I saw it | What to do instead |
|---|---|---|
| Multi-hundred-line static protocol inlined in `command/2` | `code_generation.ex` (350 lines), `three_amigos.ex` `protocol_body/0` (~70 lines) | Move to `priv/knowledge/<task>/workflow.md`, point at the file by direct path |
| Spex assertions pin exact prompt phrases that the refactor moved to workflow.md | story 80 / 559 / 598 / 668 spex after the refactor batch | Loosen the spex to check the workflow.md path is referenced. Specs assert intent; prompts deliver the artifact. |
| `orchestrate/1` returns mechanics, not intent | Most tasks today | Apply description rubric — name what + when + output |
| Custom `evaluate/2` that re-implements requirement checking | Several `custom_evaluate_modules` entries that probably don't need to be | Audit each; move to `RequirementCalculator` definitions where possible |
| `before_evaluate/2` doing validation work | watch for this | Side effects only; validation belongs in `evaluate/2` |
| Inventing a new dispatch shape | hypothetical | Use one of the five existing shapes; if you genuinely need a sixth, add it to `StartAgentTask` deliberately |
| Skipping `init_session/2` registration | implicit in the dispatcher | If your task needs session state mutation, export `init_session/2`; the dispatcher (`start_agent_task.ex:180`) will pick it up |
| Module name doesn't match `@session_type_map` key | risk | Keep both in sync; the type string is the public contract |

## Authoring checklist for new agent tasks

Run through this in order:

1. **Pick the dispatch shape.** Bootstrap / project / componentless / topic / component — see decision tree above.
2. **Write `orchestrate/1` first.** Apply the description rubric. This is the routing signal.
3. **Decide the done signal.** Is it expressible as a `RequirementCalculator` check? Default to yes. If genuinely no, plan custom `evaluate/2` and register in `Evaluator`.
4. **Draft `command/2` outline.** Quick start → current state → references → required tools → done signal. Aim for under 200 lines rendered.
5. **Identify static content.** Anything that's protocol or reference material → move to `priv/knowledge/<task>/workflow.md`. The prompt points at the file by direct path. (`semantic_search` is for discovery — use when the agent has to figure out which doc applies, not when you know.)
6. **List required MCP tools.** Name them with one-line "what for" rationale. Cross-check against the surface registered in `LocalServer` (`lib/code_my_spec/mcp_servers/local_server.ex`) so you don't reference a tool that doesn't exist.
7. **Wire dispatch.** Add to `@session_type_map`, the right dispatch list in `StartAgentTask`, and (if custom evaluate) `Evaluator.custom_evaluate_modules/0`.
8. **Update related spex.** If procedural detail moved from the prompt into a workflow doc, the spex assertions that pin that exact phrasing need to be loosened. Right framing: **specs assert intent, prompts deliver the artifact.** A spec that checks for the workflow doc reference (path appears in prompt) is healthier than one that pins inline phrasing — it survives prompt refactors.
9. **Self-review.** Same checklist as the skill authoring guide, plus: does `orchestrate/1` pass the description rubric? Does `command/2` apply progressive disclosure?

## When in doubt

If the task is mostly static instructions with light dynamic context, ask whether it should be a Claude Code skill instead of an agent task. The agent_task machinery (Sessions, Evaluator, RequirementCalculator) is overhead — pay it for the validation gate and the dynamic prompt generation, not for skill-grade reusability.

If you find yourself writing a 300-line `command/2` prompt, you're using agent_tasks as if they were `SKILL.md` files. Either:
- Move static content to `priv/knowledge/` and point at `semantic_search`, or
- Demote the task to a Claude Code skill in `.claude/skills/` and use the skill loader.

The agent_task layer is best at: "dispatch a prompt that depends on live project state, with a validation gate that the platform doesn't give us." Stay in that lane.
