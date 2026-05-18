# Qa Story Brief

## Tool

MCP (`mcp__plugin_codemyspec_local__start_task` and `mcp__plugin_codemyspec_local__evaluate_task`)

## Auth

No auth required — the local MCP server (`4004/mcp`) trusts the loopback caller. The sandbox project is resolved via `X-Working-Dir: /Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox` (embedded in the MCP tool calls by the `WorkingDirScope` plug). The `start_task` and `evaluate_task` MCP tools are called directly from the agent session without any login flow.

## Seeds

The QA Fixture Project (id `11111111-1111-4111-8111-111111111111`) is already registered in the DB with `local_path` pointing at the sandbox. Run once to verify the server is up:

```
curl -sSf http://127.0.0.1:4004/health
```

No additional seed scripts are required. Each test scenario creates its own stories, components, and proposal.md in the sandbox directory via the `evaluate_task` flow (the spex write the proposal file to the environment before calling evaluate_task). The sandbox itself is clean between major runs.

## What To Test

All scenarios exercise the `start_task` → write `proposal.md` → `evaluate_task` flow for `architecture_designed`. The sandbox project (`qa_sandbox`) is the target for all MCP mutations. After each scenario, inspect the evaluate_task response text for the expected pass/fail signal.

### Scenario 1 — All stories linked (criterion 5289)
- Call `start_task` with `requirement_name: "architecture_designed"`, `entity_type: "project"`, sandbox project id
- Write a `proposal.md` to the sandbox that maps every unsatisfied story to a surface component (liveview type)
- Call `evaluate_task` with the returned task_id
- Expected: response contains "Passed", no "needs work" text

### Scenario 2 — Story left unlinked (criterion 5290)
- Same setup: call `start_task` for `architecture_designed`
- Write `proposal.md` that omits one story from all surface component Story lists
- Call `evaluate_task`
- Expected: response contains "needs work", response names the unlinked story's ID

### Scenario 3 — Link story to surface component / liveview (criterion 5291)
- Start task, write proposal with story linked to a `liveview` type component
- Call `evaluate_task`
- Expected: "Passed", no "non-surface" warning mentioning that story's ID

### Scenario 4 — Link story to non-surface component / context (criterion 5292)
- Start task, write proposal with story linked to a `context` type component (not a surface liveview)
- The proposal still has a surface liveview component with no story (so the context carries the story link)
- Call `evaluate_task`
- Expected: "Passed" (non-surface link warns, does not block); response contains "warning" and the story ID

### Scenario 5 — Component removed from proposal (criterion 5307)
- Pre-create a component in the DB (`Stories.RemoteClient`)
- Start task, write proposal that omits `Stories.RemoteClient` but includes a different story-linked surface
- Call `evaluate_task`
- Expected: response passes, contains "warning" or "preserved" or "removed from proposal", names "RemoteClient"

### Scenario 6 — Schema-only cycle allowed (criterion 5308)
- Start task, write proposal with `User -> Account` and `Account -> User` both typed `schema` (declared as children under a context)
- Call `evaluate_task`
- Expected: "Passed", no "circular" error mentioning those schemas

### Scenario 7 — Non-schema cycle rejected (criterion 5309)
- Start task, write proposal with `Stories -> AcceptanceCriteria -> Rules -> Stories` where all are `context` type
- Call `evaluate_task`
- Expected: "needs work", response mentions "circular" or "cycle", mentions "Stories"

### Scenario 8 — New component with no spec file (criterion 5310)
- Start task, write proposal with a new child module `Stories.RemoteSync`
- Verify no spec file exists for it before evaluate
- Call `evaluate_task`
- Expected: "Passed"; spec stub file now exists at `.code_my_spec/spec/stories/remote_sync.spec.md` (or equivalent path)

### Scenario 9 — Component with existing spec file (criterion 5311)
- Write an existing spec file for `Stories.RemoteClient` before starting task
- Start task, write proposal that includes `Stories.RemoteClient` as a new component
- Call `evaluate_task`
- Expected: "Passed"; existing spec content is preserved (not overwritten)

### Scenario 10 — All dependencies resolve (criterion 5312)
- Pre-create `Stories` component in DB
- Start task, write proposal where `StoryLive.Index -> Stories` (Stories exists in DB)
- Call `evaluate_task`
- Expected: "Passed", no "dangling" or "unresolved" text

### Scenario 11 — Dangling dependency rejected (criterion 5313)
- Start task, write proposal with `StoryLive.Index -> Stroies` (typo — does not exist in DB or proposal)
- Call `evaluate_task`
- Expected: "needs work", response names "Stroies" and "StoryLive.Index"

### Scenario 12 — Orphan classified as infrastructure (criterion 5657)
- Start task, write proposal with `Web.Application` typed `infrastructure` and no story/dep link
- Write `.code_my_spec/config.yml` with `infrastructure_paths: [lib/my_app_web/application.ex]`
- Call `evaluate_task`
- Expected: "Passed", no spec stub for `Web.Application`

### Scenario 13 — Orphan resolved by dependency edge (criterion 5658)
- Start task, write proposal with `SharedKit` context that has no story link but is depended on by a story-linked surface component transitively (`FeatureLive -> Features -> SharedKit`)
- Call `evaluate_task`
- Expected: "Passed"; spec stub for `SharedKit` is created

### Scenario 14 — Orphan blocks execution (criterion 5659)
- Start task, write proposal with `LeftoverKit` context that has no story link and no dep edges pointing to it
- Call `evaluate_task`
- Expected: "needs work", response names `LeftoverKit`, no spec stubs created

### Scenario 15 — Post-execution orphan unsatisfies gate (criterion 5871)
- Requires a fully-satisfied project state — skipped in dogfood mode (depends on LiveView sync surface and graph rendering, not MCP tools). Note the surface is the requirements graph LiveView at `4004/projects/:name/requirements/graph`, which is tested separately via Vibium.

### Scenario 16 — Task prompt surfaces orphan details (criterion 5873)
- When `architecture_designed` is unsatisfied because an orphan context exists, calling `start_task` should return a prompt that names the orphan and lists the resolution menu (link story, add dep edge, add to `infrastructure_paths`, delete component)
- This scenario is validated by calling `start_task` while an orphan is in the DB and checking the response text

## Result Path

`.code_my_spec/qa/70/result.md`

## Setup Notes

All MCP surface tests target the sandbox project. Write `proposal.md` to `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox/.code_my_spec/proposal.md` before calling `evaluate_task`. The `entity_type` must be `"project"` and `entity_id` must be the sandbox project UUID from the DB.

Scenarios 15 is browser-based (LiveView requirements graph). The core MCP surface (scenarios 1–14 and 16) can be dogfooded entirely with `mcp__plugin_codemyspec_local__*` tool calls.

Save responses to `.code_my_spec/qa/70/responses/` as plain text files named `scenario_<N>_response.txt`.
