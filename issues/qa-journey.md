# QA Journey Feature

## Context

Replace `project_qa` (QaApp) with 3 separate requirements for end-to-end QA journeys through the entire app — from empty instance to functioning software, culminating in permanent Wallaby regression tests.

QaStory (per-story QA) is kept as-is. Only `project_qa` in the project requirement graph is replaced.

Key design: each phase is a separate requirement with its own simple agent task. The requirement graph handles sequencing — no internal state machine needed. Each task follows the QaSetup pattern (just `command/3` + `evaluate/3`).

## Requirement Graph Change

```
# Before:
... → all_stories_complete → project_qa (QaApp)

# After:
... → all_stories_complete → qa_journey_plan → qa_journey_execute → qa_journey_wallaby
```

## Artifacts

| Phase | Artifact Path | Document Type |
|-------|--------------|---------------|
| Plan | `.code_my_spec/qa/journey_plan.md` | `qa_journey_plan` |
| Execute | `.code_my_spec/qa/journey_result.md` | `qa_journey_result` |
| Wallaby | `test/journeys/*_test.exs` (target project) | N/A (test files) |

---

## Implementation Steps

### 1. Paths — add 3 helpers

**File:** `lib/code_my_spec/paths.ex`

- `qa_journey_plan/0` → `".code_my_spec/qa/journey_plan.md"`
- `qa_journey_result/0` → `".code_my_spec/qa/journey_result.md"`
- `qa_journey_wallaby_dir/0` → `"test/journeys"` (relative, target project)

### 2. Document Registry — add 2 document types

**File:** `lib/code_my_spec/documents/registry.ex`

**`qa_journey_plan`:**
- Required: `"journeys"`, `"prerequisites"`
- Optional: `"notes"`
- Journeys section: H3 per journey with Role, Steps, Expected outcome
- Prerequisites: server startup, seeds, credentials, config

**`qa_journey_result`:**
- Required: `"status"`, `"journey results"`
- Optional: `"issues"`, `"evidence"`
- Status: pass/fail/partial
- Journey Results: H3 per journey matching plan names

### 3. Pipeline — extend QA file detection

**File:** `lib/code_my_spec/validation/pipeline.ex`

- Extend `qa_file?/1` to match `journey_plan.md` and `journey_result.md`
- Replace `qa_document_type/1` `if` with `cond` handling all 4 file types

### 4. Requirement Checkers — 3 new files

All implement `CheckerBehaviour`, receive `%Project{}` as entity.

| File | Checks |
|------|--------|
| `requirements/qa_journey_plan_checker.ex` | `journey_plan.md` exists + valid via `Documents.create_dynamic_document` |
| `requirements/qa_journey_execute_checker.ex` | `journey_result.md` exists + valid |
| `requirements/qa_journey_wallaby_checker.ex` | At least one `*_test.exs` under `test/journeys/` via `Environments.glob` |

### 5. Agent Tasks — 3 new files

All follow the **QaSetup pattern**: just `command/3` + `evaluate/3`, no `orchestrate/3` override (uses `ProjectCoordinator.default_orchestrate`). No TaskMarker.

**`agent_tasks/qa_journey_plan.ex`**
- `command/3`: reads QA plan, architecture overview, stories → builds prompt to write `journey_plan.md`
- `evaluate/3`: checks required sections exist (journeys, prerequisites)

**`agent_tasks/qa_journey_execute.ex`**
- `command/3`: reads journey plan → builds prompt to execute each journey with browser tools, write `journey_result.md`
- `evaluate/3`: checks required sections exist (status, journey results)

**`agent_tasks/qa_journey_wallaby.ex`**
- `command/3`: reads journey plan + result → builds prompt to write Wallaby tests for passing journeys to `test/journeys/`
- `evaluate/3`: checks at least one `*_test.exs` exists under `test/journeys/`
- Assumes Wallaby is already installed in the target project

### 6. Requirement Definitions — wire into project graph

**File:** `lib/code_my_spec/requirements/requirement_definition_data.ex`

- Add aliases for 3 new checkers
- Add 3 new definition functions: `qa_journey_plan/0`, `qa_journey_execute/0`, `qa_journey_wallaby/0`
- All use `scope: :orchestrate`
- Prerequisites chain: `all_stories_complete` → plan → execute → wallaby
- Update `project_requirements/0`: replace `project_qa()` with the 3 new definitions
- Keep `project_qa/0` function for backward compat (just remove from the list)

### 7. Session Registration

**`lib/code_my_spec/sessions/session_type.ex`** — add 3 types to `@valid_types`

**`lib/code_my_spec/agent_tasks/start_agent_task.ex`** — add to `@session_type_map` + `@componentless_tasks`

### 8. Tests

**3 checker tests:** `test/code_my_spec/requirements/qa_journey_{plan,execute,wallaby}_checker_test.exs`
- Satisfied when artifact exists and valid, not satisfied when missing/invalid

**3 agent task tests:** `test/code_my_spec/agent_tasks/qa_journey_{plan,execute,wallaby}_test.exs`
- command/3 returns prompt with expected content
- evaluate/3 returns valid/invalid based on artifact state

**Pipeline test additions:** extend existing `test/code_my_spec/validation/pipeline_test.exs` for journey file categorization

---

## Files Summary

### New files (9):
- `lib/code_my_spec/agent_tasks/qa_journey_plan.ex`
- `lib/code_my_spec/agent_tasks/qa_journey_execute.ex`
- `lib/code_my_spec/agent_tasks/qa_journey_wallaby.ex`
- `lib/code_my_spec/requirements/qa_journey_plan_checker.ex`
- `lib/code_my_spec/requirements/qa_journey_execute_checker.ex`
- `lib/code_my_spec/requirements/qa_journey_wallaby_checker.ex`
- `test/code_my_spec/agent_tasks/qa_journey_plan_test.exs`
- `test/code_my_spec/agent_tasks/qa_journey_execute_test.exs`
- `test/code_my_spec/agent_tasks/qa_journey_wallaby_test.exs`

### Modified files (6):
- `lib/code_my_spec/paths.ex`
- `lib/code_my_spec/documents/registry.ex`
- `lib/code_my_spec/validation/pipeline.ex`
- `lib/code_my_spec/requirements/requirement_definition_data.ex`
- `lib/code_my_spec/sessions/session_type.ex`
- `lib/code_my_spec/agent_tasks/start_agent_task.ex`

### Untouched:
- `qa_story.ex`, `qa_app.ex` — QaApp orphaned from graph but not deleted
- `task_evaluator.ex` — no changes (journey tasks don't use TaskMarker)

## Verification

1. `mix compile` — all new modules compile cleanly
2. `mix test test/code_my_spec/requirements/qa_journey_*` — checker tests pass
3. `mix test test/code_my_spec/agent_tasks/qa_journey_*` — agent task tests pass
4. `mix test test/code_my_spec/validation/pipeline_test.exs` — pipeline tests pass
5. Verify `RequirementDefinitionData.project_requirements/0` returns the updated list
6. Verify `StartAgentTask` routes `"qa_journey_plan"` etc. to the correct modules
