# QA System Redesign

## Problem

The QA system failed in practice when run against a real project (Fuellytics):

1. **165KB prompt** — QaApp embedded all stories, the full router, BDD coverage, and spec summaries into one massive prompt that overwhelmed the agent
2. **Broken dispatch** — `@"CodeMySpec:qa-story (agent)"` is not a valid agent type, so the orchestrator could never dispatch subagents
3. **No testing strategy** — the agent received vague "smoke-test routes" instructions with no guidance on which tool to use for LiveView vs controller routes, how to authenticate, or how to create test data
4. **Agent rubber-stamped results** — without clear instructions, the agent used `curl` against random URLs, wrote passing results for everything, and never actually tested the application

The root cause: the system tried to be procedurally clever (embedding everything in the prompt) when it should have written resources to files and given the LLM clear, structured instructions.

## Design

### Architecture: Five Modules

Separate infrastructure setup from story planning from testing. QaSetup runs first to establish the tooling foundation. Two planner tasks figure out HOW to test; one tester task EXECUTES against a brief. An orchestrator coordinates everything.

```
Agent Tasks (Elixir):          Agent Types (CLI):        Skills (CLI):
+-----------------------+      +----------------+       +------------------------+
| QaSetup         [DONE]|----->| qa-planner.md  |<------| qa-setup/SKILL.md      |
| QaPlanStory     [NEXT]|----->| qa-planner.md  |<------| qa-plan-story/SKILL.md |
| QaTest                |----->| qa-tester.md   |<------| qa-test/SKILL.md       |
| QaApp (orchestrator)  |----->| (skill tools)  |<------| qa-app/SKILL.md        |
+-----------------------+      +----------------+       +------------------------+
```

**QaSetup** [DONE] — infrastructure planner. Analyzes the running app (routes, auth, config) and produces plan.md + executable scripts (auth curl helpers in `.code_my_spec/qa/scripts/`, seed `.exs` files in `priv/repo/`). Designed to re-run as the app evolves. References `qa-tooling.md` knowledge article for script-writing patterns.

**QaPlanStory** [NEXT] — plans per-story QA. Writes prompt.md files (pure data: story + BDD specs), returns planner prompt. The planner agent reads the QA plan + prompt files, then writes per-story briefs.

**QaTest** — tests a single story or journey. Takes a story ID or journey name from `session.state["topic"]`. Reads the brief, follows it exactly. Intentionally narrow — does not reason about strategy, tooling, or auth.

**QaApp** — orchestrator. Dispatches QaSetup, then story planner, then testers per story, then writes summary.

> **QaPlanJourney deferred** — journey planning (multi-story flows) is out of scope for now. Can be added after the core story loop works.

### File Structure

```
.code_my_spec/qa/
+-- plan.md                    <-- QaSetup writes (doc type: qa_plan)
+-- scripts/
|   +-- authenticated_curl.sh  <-- QaSetup writes (auth helper)
|   +-- smoke_test.sh          <-- QaSetup writes (route checker)
+-- {story_id}/
|   +-- prompt.md              <-- Code writes (story + BDD spec projections)
|   +-- brief.md               <-- QA planner writes (doc type: qa_story_brief)
|   +-- result.md              <-- QA tester writes (doc type: qa_result)
+-- summary.md                 <-- QA App orchestrator writes

priv/repo/
+-- qa_seeds.exs               <-- QaSetup writes (seed data, single BEAM boot)
```

- `plan.md` — **QaSetup writes**. App overview, tools registry, seed strategy. References scripts and seed files.
- `prompt.md` — **code writes** via `QaPlanStory.write_prompt_files/1`. Pure data: story text, acceptance criteria, BDD spec projections. No instructions.
- `brief.md` — **QA planner agent writes** after reading the plan + prompt. Structured document with: tool to use, auth instructions, seed commands, what to test, result path.
- `result.md` — **QA tester agent writes**. Structured document with: status, scenarios tested, issues found, evidence.

### Document Types (Documents.Registry)

#### `qa_plan` [DONE]

Overall testing strategy document. Written by QaSetup.

| Section | Required | Content |
|---------|----------|---------|
| App Overview | Yes | Tech stack, how auth works, port, key routes. Brief paragraph. |
| Tools Registry | Yes | For each testing approach: tool name, when to use, example invocation. Include shell scripts for controller/API testing with auth baked in. |
| Seed Strategy | Yes | Reference `.exs` seed scripts in `priv/repo/` with `mix run` invocations. |
| Notes | No | Additional context or caveats. |

#### `qa_story_brief`

Per-story testing context. Written by QA planner after reading the story's prompt.md and the QA plan.

| Section | Required | Content |
|---------|----------|---------|
| Tool | Yes | Which tool to use (web, curl, shell script). Single line. |
| Auth | Yes | Exact auth instructions (login URL, credentials, headers). Tester copies verbatim. |
| Seeds | Yes | Exact seed commands or script references for test data setup. |
| What to Test | Yes | Specific URLs, interactions, expected outcomes. Bullet list. |
| Result Path | Yes | File path where the tester writes the result. |
| Setup Notes | No | Additional context. |

#### `qa_result`

Test result document. Written by QA tester.

| Section | Required | Content |
|---------|----------|---------|
| Status | Yes | Single line: PASS, FAIL, or PARTIAL. |
| Scenarios Tested | Yes | Bullet list: `[scenario]: PASS/FAIL -- [details]`. |
| Issues Found | Yes | Bullet list with issue file references, or "None". |
| Evidence | Yes | Actual tool output, curl responses, web tool excerpts. Must have >20 chars. |

### Agent Types (CLI)

#### `qa-planner.md` [DONE]

```yaml
---
name: qa-planner
description: Plans QA testing strategy by analyzing the running app's routes, auth, and configuration
tools: Read, Write, Glob, Grep, Bash(web *), Bash(curl *), Bash(lsof *), Bash(mix run *), Bash(mix phx.*)
model: sonnet
color: blue
---
```

References `qa-tooling.md` knowledge article. Used by both QaSetup and QaPlanStory.

#### `qa-tester.md`

```yaml
---
name: qa-tester
description: Tests a single user story by following a QA brief
tools: Read, Write, Glob, Grep, Bash(web *), Bash(curl *), Bash(lsof *), Bash(mix run *)
model: sonnet
color: cyan
---
```

Body instructions: Read the brief. Follow it exactly — it tells you which tool, how to auth, what seeds to run, and what to test. Do not reason about strategy or tooling; the brief has all the answers. Write your result to the path specified in the brief. Evidence section must include actual tool output.

### Knowledge Articles

#### `qa-tooling.md` [DONE]

Reference patterns for writing QA scripts:
- Authenticated curl (CSRF + cookie jar flow for session-based auth)
- Seed data scripts (`.exs` in `priv/repo/`, single BEAM boot, context modules, idempotency)
- Smoke test scripts (route-by-route HTTP code checking)

## Completed Work

### Phase 0: QaSetup [DONE]

| What | Status |
|------|--------|
| `qa_plan` document type in Registry | Done |
| `qa_plan/0` in Paths | Done |
| `QaSetup` module (`command/3`, `evaluate/3`) | Done |
| `QaSetup` wired into StartAgentTask + SessionType | Done |
| `qa_setup_test.exs` (12 tests) | Done |
| `qa-planner.md` agent type | Done |
| `qa-setup/SKILL.md` skill | Done |
| `qa-tooling.md` knowledge article | Done |

Validated against Fuellytics — produced a comprehensive plan.md, authenticated_curl.sh, seed_data.sh, and smoke_test.sh.

Key learnings applied:
- Seed data must be `.exs` files in `priv/repo/` (not bash wrappers calling `mix run -e` per entity)
- Auth scripts stay as `.sh` in `.code_my_spec/qa/scripts/`
- Prompt references `qa-tooling.md` so the agent doesn't rediscover patterns from scratch

## Next: Phase 1 — QaPlanStory

### What it does

Writes per-story prompt.md files (pure data), then returns a planner prompt that instructs the agent to read those files + the QA plan and write per-story briefs.

### Files to Create

| File | Purpose |
|------|---------|
| `lib/code_my_spec/agent_tasks/qa_plan_story.ex` | Story planner: writes prompt files, generates planner prompt, validates briefs |
| `test/code_my_spec/agent_tasks/qa_plan_story_test.exs` | Tests |
| `code_my_spec_cli/CodeMySpec/skills/qa-plan-story/SKILL.md` | Standalone skill |

### Files to Modify

| File | Changes |
|------|---------|
| `lib/code_my_spec/documents/registry.ex` | Add `qa_story_brief` document type |
| `lib/code_my_spec/agent_tasks/start_agent_task.ex` | Add `qa_plan_story` to maps |
| `lib/code_my_spec/sessions/session_type.ex` | Add `QaPlanStory` |

### Public API

```elixir
@doc "Write per-story prompt.md files. Returns list of {story, path} tuples."
def write_prompt_files(scope)

@doc "Generate the story planning prompt."
def command(scope, session, opts \\ [])

@doc "Validate all story briefs are complete."
def evaluate(scope, session, opts \\ [])
```

`write_prompt_files/1`: Loads stories, for each writes `prompt.md` to `.code_my_spec/qa/{story_id}/prompt.md` containing story details + BDD spec projections.

`command/3`: Calls `write_prompt_files/1`, builds planner prompt including:
- `DocumentSpecProjector.project_spec("qa_story_brief")` for brief format
- Reference to existing plan.md (agent must read it for tools/auth/seeds context)
- List of stories with their prompt.md paths
- Instructions: read plan.md, read each prompt.md, write brief.md per story

`evaluate/3`: For each story, check brief.md exists at `.code_my_spec/qa/{story_id}/brief.md` and has required sections.

### Reusable code

- `QaStory.load_specs/2` — loads and projects BDD specs for a story
- `QaSetup.derive_app_name/1` — extracts app name from mix.exs (same pattern)
- `DocumentSpecProjector.project_spec/1` — projects registered document types
- `BddSpecs.list_specs_for_story/2` — BDD spec loading per story
- `Stories.list_stories/1` — story loading

## Future Phases

### Phase 2: QaTest

Tester module. Takes story ID from topic, reads prompt + brief, returns testing prompt. Validates result.md exists with required sections.

### Phase 3: QaApp Rewrite

Orchestrator rewrite. Dispatches QaSetup, then QaPlanStory, then QaTest per story, then writes summary. Slim prompt (~2-4KB).

### Phase 4: Cleanup

- Delete old `qa_story.ex` and related files
- Update `qa-app/SKILL.md`
- Remove old `qa-story/SKILL.md`

## Key Design Decisions

**Separate infrastructure from story planning from testing**
QaSetup runs once to establish tooling (plan.md, scripts, seeds). QaPlanStory reads that foundation to write per-story briefs. QaTest follows briefs blindly. Each layer has a clear, narrow job.

**Document types in Registry**
Briefs and results use the existing `Documents.Registry` system. `DocumentSpecProjector.project_spec("qa_story_brief")` tells agents exactly what format to write, and evaluation checks for required sections.

**Prompt files as resources, not instructions**
`prompt.md` contains only data (story text, BDD spec projections). Instructions come from the agent task prompt. This keeps auto-generated content clean and reusable.

**Seed data in `priv/repo/` as `.exs` files**
Each `.exs` script boots the BEAM once. Bash wrappers calling `mix run -e` per entity boot the app N times. The `qa-tooling.md` knowledge article documents the pattern.

**Auth scripts in `.code_my_spec/qa/scripts/`**
Shell scripts that bake in CSRF + cookie handling. Testers run pre-authorized scripts instead of dealing with per-command auth.

**Knowledge article as the teaching layer**
`qa-tooling.md` contains the patterns for writing scripts. The prompt references it so the agent doesn't rediscover auth flows, seed patterns, etc. from scratch each time.
