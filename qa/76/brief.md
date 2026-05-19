# Qa Story Brief

Story 76 — Component Specification Generation. Tests the agent task surface
for generating component specs: canonical paths, template dispatch by component
type, parent-spec injection, diagnostics on re-fire, sticky-node release, crash
recovery, and the skill entry point.

## Tool

MCP tools (`mcp__plugin_codemyspec_local__start_task`, `mcp__plugin_codemyspec_local__evaluate_task`)
for criteria 5540–5547 (MCP surface). `curl` for criterion 5548 (skill entry point
at `POST /api/skills/start`).

## Auth

Local endpoint (port 4004) — no auth needed. `LocalOnly` plug accepts loopback.
Seed scripts create the QA Fixture Project with `local_path` pointing at the sandbox.

For curl calls pass `X-Working-Dir` header:
```
-H "X-Working-Dir: /Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox"
```

The MCP tools resolve scope automatically from the project the session is wired to.

## Seeds

Run the server seed to ensure the QA user and project exist:

```
mix run priv/repo/qa_seeds.exs
```

The QA Fixture Project (`11111111-1111-4111-8111-111111111111`) must have
`local_path` set to the sandbox directory. The seed script handles this.

For MCP-surface tests that mutate component state, target the sandbox project so
test cruft does not pollute the working CodeMySpec checkout.

## What To Test

### Scenario 1 — Context spec lands at the canonical path (criterion 5540)

- Call `mcp__plugin_codemyspec_local__start_task` with:
  - `requirement_name: "spec_file"`
  - `entity_type: "component"`
  - Supply a context-type component with module name `Story76.SpecPath`
    (create via the app's Components context if it doesn't exist, or observe
    an existing component of type `context` whose spec file is absent)
- Assert the returned prompt contains `"Please write the specification to:"`
- Assert the prompt contains `".code_my_spec/spec/story76/spec_path.spec.md"`
  (canonical path derived from the module name)

### Scenario 2 — Valid spec satisfies the node without a separate review (criterion 5541)

- Ensure an `ExampleContext` component is synced with a valid context spec on disk
  (use QA seed data or the sandbox project)
- Call `mcp__plugin_codemyspec_local__*` equivalent of `list_requirements`
  (use the running MCP client) or curl `GET /api/projects/:project_name/requirements`
- Assert the response shows `[x] **spec_file**` and `[x] **spec_valid**` for
  ExampleContext — both satisfy without a separate review gate

### Scenario 3 — live_context Components use the LiveContextSpec template (criterion 5542)

- Call `start_task` for a `live_context` component (module name `Story76Web.SpecLive`)
  with `spec_file` requirement
- Assert the prompt contains:
  `"Your task is to generate a specification for a Phoenix live context"`
- Assert the prompt references `".code_my_spec/spec/story76_web/spec_live.spec.md"`

### Scenario 4 — Controller Components use the ControllerSpec template (criterion 5543)

- Call `start_task` for a `controller` component (module name `Story76Web.UsersController`)
  with `spec_file` requirement
- Assert the prompt contains:
  `"Your task is to generate a specification for a Phoenix controller"`
- Assert the prompt references `".code_my_spec/spec/story76_web/users_controller.spec.md"`

### Scenario 5 — Child spec generation receives the parent spec and design rules (criterion 5544)

- Ensure a parent `ExampleContext` context component has a valid spec on disk
- Create a child `schema` component `ExampleContext.User` linked to the parent
- Call `start_task` for the child's `spec_file` requirement
- Assert the prompt contains:
  `"Parent Context Design File: .code_my_spec/spec/example_context.spec.md"`
- Assert the prompt contains a `"Design Rules:"` section

### Scenario 6 — Invalid spec re-fires the same node with diagnostics (criterion 5545)

- Write an intentionally invalid context spec (missing required sections) to disk
- Sync the project so the system picks it up
- Call `start_task` for the `spec_valid` requirement on that component
- Assert the prompt contains the spec file path
- Assert the prompt contains a diagnostics heading matching
  `Previous validation|Validator diagnostics|Diagnostics from prior run`

### Scenario 7 — Sticky node releases once revision passes file_valid (criterion 5546)

- Start with ExampleContext synced with an invalid spec (missing required sections)
- Rewrite the spec to a valid form and re-sync
- Call `list_requirements` (via MCP tool)
- Assert the response shows `[x] **spec_valid**` for ExampleContext

### Scenario 8 — Agent crash leaves spec_file unsatisfied (criterion 5547)

- Create a context component `Story76.NoFile` with no spec file on disk
- Call `start_task` for `spec_file` on that component (simulate "agent picked up task")
- Without writing anything, call `list_requirements`
- Assert the response shows `[ ] **spec_file**` for `Story76.NoFile` — graph stays honest

### Scenario 9 — Skill-driven spec generation runs the same task (criterion 5548)

- POST to `http://127.0.0.1:4004/api/skills/start` with:
  ```
  curl -sSf -X POST http://127.0.0.1:4004/api/skills/start \
    -H "Content-Type: application/json" \
    -H "X-Working-Dir: /Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox" \
    -d '{"skill":"develop","subcommand":"context","module_name":"Story76.SkillTriggered","external_id":"qa-76-skill-test"}'
  ```
- Assert HTTP 200 and response JSON contains `"prompt"` key
- Assert the prompt contains `"Develop Context"`
- Assert the prompt contains the component name
- Assert the prompt contains `"Context Spec"`

## Result Path

`.code_my_spec/qa/76/result.md`
