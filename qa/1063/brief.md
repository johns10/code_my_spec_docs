# Qa Story Brief

## Tool

MCP (curl JSON-RPC against the local harness's `/mcp` proxy) + direct disk writes, against the `qa_sandbox` fixture project.

## Auth

No login needed — everything here is local-app/MCP surface, not the hosted `:browser` pipeline.

- Sandbox harness id (from `qa_sandbox/.cms_harness.json`): `1fc425f5-7b88-4e32-86a3-c16c3317408c`
- MCP endpoint: `POST http://localhost:4004/api/harnesses/<harness_id>/mcp` with `Accept: application/json, text/event-stream`
- Register a probe session first (task tools need one): `register_session({ session_id = "qa-1063-sandbox-probe" })` via `run_script`
- `create_story`, `update_story`, `create_persona`, `link_persona_to_story`, `add_rule`, `add_scenario`, `create_issue`, `show_story_requirements`, `list_requirements`, `get_story`, `sync_project` are all reachable this way; `start_task`/`submit_qa_result` need the registered `session_id` passed explicitly since there's no PreToolUse hook injecting it over raw curl.
- Isolation check before mutating anything: `list_story_titles({})` should return ~25 rows (the qa_sandbox fixture set), never ~120 (the real project).

## Seeds

No seeding needed beyond the existing `qa_sandbox` fixture project (already onboarded, id `11111111-1111-4111-8111-111111111111`). All test fixtures (stories, personas, issues, files) were created live through the real MCP surface during this session rather than from a script.

## What To Test

- **A story being released moves the graph (3340):** create an unreleased story, read `show_story_requirements`, `update_story(ready_for_dev: true)`, read again — requirement rows should go from 0 to a full set.
- **A QA attempt lands and the graph hears about it (3235) / one story's attempt moves that story and leaves the others (3237):** two released stories, `start_task` a `qa_complete` task on each, `submit_qa_result(pass)` on one — its `qa_complete` should flip `[x]`, the other story's markdown must be byte-identical to before.
- **A second identical failure is taken at face value (3236):** `submit_qa_result(fail)` twice against the same task, same issue id, same observation — both must be accepted (not refused/deduped); the second attempt should carry `parent_attempt_id` pointing at the first.
- **File-based criteria (3238, 3346, 3347, 3349):** write a spec file (`.code_my_spec/spec/<Name>.spec.md` with a bare `# ModuleName` H1 — a trailing word like "Context" fails the parser, see Setup Notes), `sync_project`, confirm `spec_file` flips; add `lib/<name>.ex`, resync, confirm `implementation_file` flips; add an unclassified file (e.g. `notes/x.txt`) in the same pass and confirm no third component/row appears.
- **A spex file appearing moves the graph (3348):** write `test/spex/<story-number>_<slug>/criterion_N_..._spex.exs` under the target story's own number (from `get_story`), resync, check that story's `bdd_specs_exist`. **Known trap:** in this fixture project the directory-number-to-story-id resolution can disagree with the story's own recorded number — see Setup Notes and issue `3cec218f`.
- **An issue being filed moves the graph (3343):** verified via code (`Issues.create_issue` calls `GraphInputs.changed/1` directly) — the project-level `issues_triaged` requirement in this fixture project was already unsatisfied before and after (pre-existing backlog), so a boolean-flip could not be observed live; not a defect, just an unlucky starting state for this specific fixture.
- **A criterion being added / a persona being linked moves the graph (3341, 3345):** `create_persona` + `link_persona_to_story` + `add_rule` + `add_scenario` on a released story all succeeded without error, but `three_amigos_complete` requires an explicit *seal* (`ThreeAmigos.evaluate/2`, driven through `evaluate_task` on a real three-amigos task) beyond just having a rule and scenario present — that seal step wasn't exercised, so this pair has no clean live boolean-flip confirmation. Fingerprint coverage for both tables is confirmed by code inspection (`Preloader.delegated_inputs/2`).
- **Heartbeat / commit-count / cross-copy isolation (3231, 3232, 3339, 3240) and the wake criterion (3241):** the only real write path is a harness's git-state channel report (`CmsHarness` → `HarnessProjectChannel` → `WorkingCopies.record_git_state/2`), which has no HTTP/curl equivalent — it's a live Phoenix Channel join. Synthesizing one safely (a second real onboarded working copy, or driving the existing channel) was disproportionate for this session. Verified by full code review of `GraphFingerprint`, `Preloader.working_copy_gate_inputs/2`, `GraphWatcher`, and the corresponding spex (`criterion_3231/3232/3339/3240/3241_*_spex.exs`), all of which are well-targeted at exactly the claimed behavior.
- **A deploy being recorded moves the graph (3344):** `Deploys.record/4` is only reachable through the real provisioning pipeline (`CodeMySpec.Provisioning.Steps`) — no lightweight QA surface exists. Not exercised; disproportionate to stand up real devops infra for this check.
- **The diagnostic endpoint itself** (`GET /api/projects/:project_name/requirements/graph`, `computed_at`/`served_from`/`watcher`): unreachable in this dev topology — see issue `5dab2365`. All of the above was verified through end-state correctness on `show_story_requirements`/`list_requirements`/`get_next_requirement` instead, which is weaker evidence for the "served from the same computation" half of these criteria specifically.

## Result Path

No result.md — findings filed as issues (`create_issue`), final verdict via `submit_qa_result` on story 1021's `qa_complete` task.

## Setup Notes

- Spec-file H1 parsing (`Files.ComponentSync.parse_spec_file_from_disk/2`) requires the line to be exactly `^# ([A-Z][a-zA-Z0-9_.]+)$` — `# Widget Context` style headings (extra words after the module name) fail silently with a log warning ("no extractable H1 module heading") and the component is never synced. Use a bare module name.
- `sync_project` against a harness-served project is async — it just requests a rescan; wait several seconds and re-read before concluding a write didn't land. `~/.codemyspec/harness.log` shows the scan, `~/.codemyspec/web.log` shows the reconcile (`[FileSync] writing N row(s) ...`).
- The most significant finding this session: a spex file's story attribution landed on the *wrong* story (`test/spex/29_.../..._spex.exs` credited story db-id 7 — whose own number is 5 — instead of the story that actually reports itself as number 29). Filed as issue `3cec218f-db89-4b3e-9310-10e09815be96`. Re-verify this before reusing story numbers as directory prefixes in this fixture project.
- Cleaned up all disk fixtures this session added to `qa_sandbox` (spec/impl/spex/junk files) and re-triggered a sync afterward; left the created stories/personas/issues in place, consistent with the ~25 pre-existing fixture rows already in that project.
