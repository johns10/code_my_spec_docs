# QA Result — Story 1015

**Status:** partial (final submission)

This QA ran across several sessions/compactions on this same story; this file
is the reconciled final state as of 2026-09-13, after two full 3321
reproductions and a round of engineer fixes in between. Findings are filed
via `create_issue` (ids below) and the canonical record is the
`submit_qa_result` DB attempt; this file is the evidence trail. Full raw
transcripts are under `.code_my_spec/qa/1015/responses/`.

## Scenarios (final)

| Criterion | Status | Evidence |
|---|---|---|
| 3309 — machinery healthy and says so | pass | Live `check_machinery({})` on the real, connected project (re-confirmed 2026-09-13, ~11:0x): `tools: working — every agent's machine is answering with a usable tool list.`; harness/preview/analyzers/machine sections all state positively. |
| 3310 — every agent failing points at machinery | pass | Live, re-confirmed cleanly on 2026-09-13 via `/dev/copies/:id/machine_tools`: with the QA Fixture Project's shared copy (`1fc425f5-...`, 5 real running agents) and its pre-existing toolless copy (`d1540d93-...`) both made toolless (tool list saved and restored within seconds), `check_machinery` read `tools: FAULTY on the machinery — every agent on this project is on a machine reporting no tools ... one fault underneath them and not 6 separate agent faults.` No individual agent id named in the `tools:` section. The 5 real agents were never stopped/restarted — only a metadata field was toggled and restored (confirmed via `agents.status`/`updated_at`, all unaffected). |
| 3311 — one agent failing points at the agent | pass | Live, same session: with only `d1540d93-...`'s agent (`22227f46-...`) toolless and the shared copy restored, `check_machinery` read `tools: the machinery is working — other agents on this project are calling tools normally. These are not: 22227f46-.... The fault is theirs rather than the machine's.` |
| 3312 — fault the main agent can't act on is raised | pass | Both halves live, cleanly, on 2026-09-13: with the machine-wide fault staged as above, `restart_agent` against the toolless copy's own agent returned `isError`/refused on the first attempt ("Not restarted: the fault is underneath this agent, not in it. ... It has been raised as an issue."), and `list_issues` on that project showed the raised fault. Sibling refusal path (foreign agent id → `{:error, :not_mine}` → issue raised, explaining the shared-harness tradeoff) also re-verified live. All QA-artifact issues this staging produced were dismissed immediately after. |
| 3321 — what the main agent can fix, it fixes | **fail** | Two independent live reproductions on disposable agents (created via `create_working_copy`, offboarded after each). First (`5bdd5845-...`) found two defects: an in-flight Bash subprocess (`sleep 180`) survives a restart untouched, and the relaunch itself collided on `Anubis.Client already_started`, permanently stranding the agent at `status: starting` while `restart_agent` reported `{:ok, agent}`. Filed `4078e7bf` (Bash survival) — **still open/accepted**. The `Anubis.Client` collision was filed separately as `dfa1ee9e` and is **now fixed** (`42235f788`, confirmed present in this checkout's `lib/cms_harness/mcp/transport/anubis.ex`): a second disposable-agent reproduction (`37dca1b7-...`) confirmed the `:starting`-guard and `turn_started_at` fixes hold, and the collision is gone. But `4078e7bf`'s core finding — a genuinely in-flight Bash tool call is not killed by a restart, because the OS-level Task is supervised by Alloy (not our `Engine`) and closing a port doesn't signal the child — remains architecturally traced and explicitly not yet fixed; a custom `:bash_executor` seam exists but hasn't been built. QA judgment (asked for explicitly by the engineer in `4078e7bf`'s own resolution notes): this is a real, if intermittent and load-correlated, violation of "what the main agent can fix, it fixes" — a restart can report success while a bad long-running command it was meant to interrupt keeps running unattended. **3321 fails** on this open defect. |
| 3322 — analyzer health visible alongside everything | pass | Same live reports: `analyzers:` names compiler/credo/exunit/spex individually, on both the real project and the fixture project. |
| 3323 — an analyzer not really running isn't "passing" | pass | Same: observed all three non-passing states live across the two projects — `STALE` ("Nothing it reports should be read as passing"), `FAILED` ("this gate cannot be answered"), and `has not run here` — never silently reported as clean. |
| 3324 — saturated machine explains agent behavior | pass | Live, real unstaged saturation throughout (load_average 9–39 on 10 CPUs over the session, memory_free_mb as low as 90): `SATURATED: ... Agents here will be slow or appear stalled for that reason; restarting them adds to what it is carrying.`, with the agents on that machine listed. Confirms the gap originally filed as `4bca4e6c` (no harness ever sent `machine_load`) is genuinely fixed — `CmsHarness.Sync.measure_machine_load/1` runs every 60s and the server renders real numbers now. |
| 3325 — shared machinery visible across project lines | pass | Live: `shared: N other project(s) have checkouts here` plus `agents on it:` limited to the asking project's own ids; cross-checked against `list_agents({})` filtered to the project — exact match, no foreign id ever appeared. |
| 3326 — seeing shared machinery ≠ acting on it | pass | Cross-project restart refused live, issue raised explaining the tradeoff. The wording gap found earlier this story (issue didn't say "shared harness" literally, `999d5f17`) is now fixed (`b2a797013`) — both the refusal text and the filed issue say "a shared harness" explicitly. Full pass, no remaining caveat. |

## Issues

Filed this story, current status:

- `4078e7bf-8b34-484e-9b6f-a736e4fc4329` [high/app, **accepted — still open**] — `restart_agent` does not reliably discard in-flight work: an already-dispatched Bash tool call survives the restart untouched (traced to Alloy's `Task.Supervisor.async_nolink`, not linked to our `Engine`; closing a port doesn't signal the OS child either). This is the issue behind 3321's fail; linked to this submission.
- `dfa1ee9e-ab2c-4a07-a59a-25f0d940acc9` [high/app, resolved] — the separate `Anubis.Client` relaunch-collision defect that also stranded restarted agents; fixed in `42235f788`, re-verified live.
- `d99706c6-161a-4ea8-95d2-f6f3854f6dbf` [low/docs, resolved] — `restart_agent/2` moduledoc drift; fixed alongside `dfa1ee9e`.
- `b27c54f1-0365-4246-9414-58351bfc1850` [medium/app, resolved] — `check_machinery` crashed (nil comparison) with a project-only scope; fixed (`f12652145`).
- `57ba014e-074e-4ef8-822a-f79249037946` [medium/app, resolved] — machine-wide/restart-changed-nothing faults re-filed duplicate issues, no dedup; fixed (`ed279e866`), keyed on open (incoming/accepted) issues with the same title. Note: this session's own 3312 staging still produced two identically-titled "The machinery is serving no tools" issues a few seconds apart — possibly a TOCTOU race under the box's current heavy load, possibly the running server not yet on this fix's commit (this box's server runs from the main checkout, not this worktree). Not re-filed as a new issue given the ambiguity and that the fix's mechanism is sound by design; worth a glance if it recurs cleanly.
- `999d5f17-c45f-4f96-b792-3ae9cdc1eb85` [low/app, resolved] — cross-project refusal didn't say "shared harness" literally; fixed (`b2a797013`).

Only `4078e7bf` is submitted as this attempt's linked issue — it's the sole
remaining open defect and the reason overall status is `partial` rather than
`pass`.

## Setup used (and torn down)

- Real, live fleet reads for 3309/3322–3325 (this worktree's own connected harness, and the QA Fixture Project's real shared copy) — read-only.
- QA Fixture Project's shared copy (`1fc425f5-...`) briefly made toolless twice (exact 85-tool list captured via `psql` beforehand both times, restored via the same JSON payload within seconds each time) to demonstrate 3310 and 3312. The 5 real agents on that copy were never stopped, restarted, or otherwise disrupted — confirmed via `agents.status`/`updated_at` before and after both windows.
- Two disposable working copies + agents created via `create_working_copy` on the real CodeMySpec project across the two 3321 reproductions, each offboarded after.
- All QA-artifact issues raised by this staging (3 from the 3310/3312 window today, plus earlier ones from the 3321 reproductions) were dismissed with a note identifying them as QA artifacts.
- `/dev/faults` confirmed empty at the end of the session; nothing left injected.
