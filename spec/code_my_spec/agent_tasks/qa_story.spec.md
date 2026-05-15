# CodeMySpec.AgentTasks.QaStory

## Type

skill

## Intent

QA-test a single user story end-to-end. The agent works through two phases —
write a testing brief, then execute it — producing inspectable markdown
artifacts at each stage. The project-wide QA plan (`.code_my_spec/qa/plan.md`)
is a prerequisite, produced upstream by the `qa_setup` task. The agent
authenticates against the running app, walks the story's acceptance criteria,
captures screenshots as evidence, files issues for any defects found, and
writes a structured result document. The task is re-runnable — a failed
result is archived so the next run starts Phase 2 fresh.

## Done signal

`.code_my_spec/qa/<story_id>/result_complete.md` exists. The evaluator
promotes `result.md` → `result_complete.md` when the result document
validates against the `qa_result` spec AND has `status: pass`. On
`fail`/`partial`, the result is archived as
`result_failed_<timestamp>.md`, issues are filed regardless, and the
requirement stays unsatisfied for the next QA cycle.

The role-tag pattern in `FileSync.match_qa_result?/1` only assigns the
`:qa_result` role to `result_complete.md`, so the requirement graph's
`:file_exists` check on `:qa_result` resolves correctly.

## Dispatch shape

`topic_task` — takes a story_id as the topic, bypassing the component-graph
dispatch. Also surfaces from the story graph as `qa_complete` (id 4) once
`bdd_specs_passing` is satisfied.

## Out of scope

- The task does not write or modify the project-wide QA plan
  (`plan.md`). That artifact is owned by `qa_setup` — if it's missing or
  incomplete, the evaluator returns invalid pointing at that task.
- The task does not write or modify BDD specs. Fix specs upstream
  (`write_bdd_specs`, `fix_bdd_specs`).
- The task does not fix application bugs. It identifies defects via
  testing and files issues; `triage_issues` and `fix_issues` handle
  resolution.

## Failure modes the agent should avoid

- Skipping reading `plan.md` and inventing auth/seed strategy ad-hoc.
- Using curl with session cookies for browser-authenticated routes —
  UI routes must be tested with MCP browser tools.
- Writing results without capturing screenshots (evidence is required).
- Skipping issue filing when the result lists issues. Issues filed to
  the DB are what `triage_issues` works against.
- Treating Phase 2 as scripted-only — exploratory testing of unexpected
  inputs and edge cases is required.

## Resources

Required input:
- `task.story_id` — passed via topic-task dispatch or story-graph entity_id.
- The story record (loaded from `Stories.get_story!/2`).
- `.code_my_spec/qa/plan.md` — produced by `qa_setup`. Read first.

Optional input:
- BDD spec files for the story — `BddSpecs.list_specs_for_story/2`.
- Linked component (`story.component_id`) — source/spec/test paths for
  feature context.
- Existing scripts in `.code_my_spec/qa/scripts/`.

Produced:
- `.code_my_spec/qa/<id>/brief.md` — Phase 1, per-story testing plan.
- `.code_my_spec/qa/<id>/result.md` — Phase 2 transient artifact.
- `.code_my_spec/qa/<id>/result_complete.md` — pass terminal state
  (renamed from `result.md` by the evaluator).
- `.code_my_spec/qa/<id>/result_failed_<ts>.md` — fail terminal state
  (archived from `result.md` by the evaluator).
- `.code_my_spec/qa/<id>/screenshots/*` — evidence.
- Issues filed to the DB via `Issues.create_from_qa_result/3`.

## Tools

- **MCP browser tools** (Vibium) — required for UI testing. Any route
  behind the `:browser` Phoenix pipeline.
- `curl` via Bash — for `:api`-pipeline routes only. Use
  `.code_my_spec/qa/scripts/authenticated_curl.sh` for API-key auth.
  NEVER for browser-authenticated routes.

Built-ins (Read, Write, Bash, Glob) handle the rest. The playbook lives at
`priv/knowledge/qa_story/workflow.md`; supporting cheat sheets at
`priv/knowledge/qa-tooling.md` and `priv/knowledge/qa-tooling/`.

## Dependencies

- CodeMySpec.BddSpecs
- CodeMySpec.Components
- CodeMySpec.Documents
- CodeMySpec.Documents.DocumentSpecProjector
- CodeMySpec.Environments
- CodeMySpec.Issues
- CodeMySpec.Paths
- CodeMySpec.Stories
- CodeMySpec.Utils
