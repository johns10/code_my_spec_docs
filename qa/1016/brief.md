# QA Brief: Story 895 — Stories are assigned to a working copy

## Tool
curl

## Auth
Local endpoint (port 4004), no user auth — `Plugs.LocalOnly` + `Plugs.HarnessScope`. Every request needs an `X-Harness-Id` header naming a working copy:

```
ID=$(grep -o '"harness_id"[[:space:]]*:[[:space:]]*"[^"]*"' .cms_harness.json | head -1 | cut -d'"' -f4)
curl -sSf -X POST http://127.0.0.1:4004/api/hooks/stop -H "Content-Type: application/json" -H "X-Harness-Id: $ID" -d '{"conversationId":"qa-895-probe"}'
```

This project's own `.cms_harness.json` (repo root) names the `phx-new-generator` working copy's harness id. A second, distinct working copy is needed for "another working copy's story is not offered here" (3193/2399) — check `.code_my_spec/architecture` or `psql code_my_spec_dev -c "select id, label, root from working_copies where project_id = (select id from projects where name = 'Code My Spec');"` for a second real id already on this box, or mint a disposable one via `mix cms.harness.onboard <throwaway-dir> --project <code-my-spec-project-id>` per the QA plan's sandbox pattern (do NOT reuse the QA Fixture sandbox for this -- it is a different project).

## Seeds
None beyond what already exists. This story tests real story/problem/working-copy state on the live "Code My Spec" project (708492f9-454e-482f-a2eb-be64f0356b87) -- it is about which stories and findings a *specific* working copy's stop hook sees, so it needs real rows, not a fixture project.

To assign a story to a working copy: `CodeMySpec.Stories.Story` has a castable `working_copy_id` field (`lib/code_my_spec/stories/story.ex:175,199`). Check whether `/app/projects/:project_id/stories/:number/edit` exposes a working-copy picker before assuming DB-only access is needed; if not, note that as a possible gap (the story implies an agent-facing assignment mechanism, not necessarily a human UI one -- check for an MCP tool too, e.g. `assign_story` or similar in `CodeMySpec.McpServers`).

## What To Test
The mechanism: `POST /api/hooks/stop` (`CodeMySpecLocalWeb.Hooks.StopController` -> `CodeMySpec.Hooks.Stop.decide/2`) returns a `decision` derived from `CodeMySpec.Problems.render_stop_response/3`, which splits problems into **blocking** and **advisory** lists. `Problems.advisory_assignment_note/2` explains *why* something advisory (not blocking) names whose story it's on -- that note is the surface criteria 2394/2395 are about.

- **A finding on someone else's story is still reported here** (2394): with a problem attached to a story assigned to a *different* working copy, confirm the stop response still lists it (in the advisory section, with an assignment note identifying whose story it is) rather than omitting it entirely.
- **Unassigned findings are visible without being blocking** (2395): a problem on a story with `working_copy_id: nil` should appear in the response but not force `decision: block`.
- **A story assigned to nobody blocks everybody** (2396): a problem on an unassigned story should appear as *blocking* (not advisory) regardless of which working copy's harness id calls `/api/hooks/stop` -- the negative-half check here is that this is NOT reachable-copy-scoped like the negative case in 2399.
- **Having assignments does not hide the unassigned backlog** (2398): with some stories assigned and others not, confirm the response still surfaces the unassigned ones rather than only ever showing assigned work.
- **Another working copy's story is not offered here** (2399): a problem on a story assigned to *working copy A*, queried via *working copy B*'s harness id, should not appear as blocking for B (the negative half of 2394 -- reported vs. blocking are different claims).
- **A regression on proven behaviour blocks whoever is stopping** (2406): a problem representing a regression (previously-passing, now failing) should block regardless of story assignment -- check whether this overrides the per-copy scoping above.
- **Work in progress elsewhere does not block here** (2407): a problem tied to work assigned to and actively in progress on a *different* working copy should not block this one's stop.

For each: `curl` the target working copy's `/api/hooks/stop`, inspect the JSON `decision` field and whatever field names the blocking/advisory problem lists (read the actual response shape on the first call -- `Problems.render_stop_response/3`'s exact keys weren't confirmed by static reading and should be taken from a live response, not assumed).

## Result Path
No result.md. File findings via `create_issue` as they're found; submit the final result via `submit_qa_result` on task `6735cdc7-81ca-47b0-a562-6ebd6c2a6b74`.

## Setup Notes
This story's mechanism (`Problems`, `Stories.working_copy_id`, `Hooks.Stop`) lives entirely in the local endpoint (4004) and the Postgres-backed `code_my_spec_dev` database shared with the live project -- there is no fixture/sandbox isolation documented for it the way there is for MCP-surface mutations. Prefer read-only setup (finding existing problems/stories in the right states) over creating new rows on the real project; if creating a probe problem/story is unavoidable, label it clearly as a QA probe and record its id so it can be cleaned up, per the QA plan's sandbox-isolation principle even though no dedicated sandbox exists for this specific mechanism.

The exact JSON response shape from `/api/hooks/stop` was not confirmed via source reading in the time available (only the controller and the top-level `Problems.render_stop_response/3` delegate were read, not its implementation) -- the first live call in this brief's execution should record the actual shape before writing further test steps against it.

**Schema correction:** `problems` has no `story_id` column at all -- it links via `component_id` and `working_copy_id`. The real chain for "a finding on someone else's story" is `problem.component_id -> component <- story.component_id -> story.working_copy_id`. A direct query joining `problems` to `stories` on `component_id` for this project returned zero rows: no currently-live problem's component matches any story's component. Producing a real test case needs an actual analyzer run that finds an issue on a component a story references (not a raw DB insert, which would bypass the real surface and QA nothing). This is the next concrete step, and it's a real chunk of setup work on its own -- likely worth a dedicated pass.

**Further confirmed:** every currently-live problem on this project has `component_id: null` -- checked directly, zero rows with a non-null `component_id` exist at all. The ~10 most recent problems are all `category: test_failure`, `severity: error`, tied to `working_copy_id` 7bd818cc (the `maintenance` worktree), none carrying a component. If `component_id` really is the only way a problem gets linked to a story's assignment, this story's whole mechanism currently has nothing in the live project to exercise it against -- either `test_failure` problems are never supposed to carry story assignment (plausible: a failing test is about correctness, not authorship) and some other category (credo/compiler, tied to a specific file+component) is what actually reaches `advisory_assignment_note/2`, or the assignment path is effectively dead code against current data. Worth confirming which category of problem actually gets a `component_id` set (check `CodeMySpec.Analysis`'s problem-recording code per source) before assuming this is a real gap rather than the expected shape for test failures specifically.

**Baseline captured:** `POST /api/hooks/stop` against this working copy's own harness id (9f77b922, `phx-new-generator`) with no problem set up returns bare `{}` -- no `decision` key, nothing. That confirms the endpoint answers and this copy currently has no outstanding blocking/advisory problems, but it means the full response shape (what `decision`, and whatever names the blocking/advisory lists, actually look like) is still unconfirmed. The next step is finding or creating a real problem attached to a story with a known `working_copy_id` state, then re-calling this same endpoint to see a non-empty response before writing scenario-by-scenario assertions.