# QA Story Brief — Story 983

## Tool

web

## Auth

This copy's own app (`CodeMySpecWeb.Endpoint`, worktree `agent-conversation-ui`, pid 89836, HTTP on `127.0.0.1:60642`) is down with a Phoenix `CompileError` (stale `_build/dev/lib/code_my_spec/.mix/compile.lock`, requires a process restart — see Setup Notes). Login via the browser was not reachable this run. When it is up, auth follows the hosted-app pattern in `.code_my_spec/qa/plan.md` (session cookie + CSRF, `UserAuth.fetch_current_scope_for_user`).

## Seeds

None run — testing was done by static spex review plus the live `ready_for_qa` certification record already on story 983 (commit `e65d0726edb75b75012f54a211edbdebb0e45531`, certified 21:14 today). No new seed data was needed because the spex fixtures build their own throwaway promotable projects/stories per scenario.

## What To Test

- Criterion 1895 — a newly created criterion starts unlatched: `criterion_1895_a_newly_created_criterion_starts_unlatched_spex.exs` — adds a second criterion after certification, red on its own spex, and asserts re-certification is refused and the story carries no stamp.
- Criterion 1896 — promoting latches only the criteria green on that run: `criterion_1896_...spex.exs` — promotes a story with one green, one red (unlatched) criterion; asserts the green one latches and the red one does not.
- Criterion 1897 — rewriting a criterion's spex unlatches only that criterion: `criterion_1897_...spex.exs` — two latched criteria, rewrite one's spec, assert only that one unlatches.
- Criterion 1898 — a failing spex blocks the stop when its criterion is latched: `criterion_1898_...spex.exs` — drives the real configuration LiveView to turn on `spex: block_all`, latches a criterion via promotion, regresses its spec, and asserts the real stop-hook endpoint blocks and names the file.
- Criterion 1899 — a failing spex on an unlatched criterion is advisory: `criterion_1899_...spex.exs` — same LiveView/stop-hook path, criterion never latched, asserts the stop is allowed.
- Criterion 1900 — only the latched criterion's failure blocks when both are red: `criterion_1900_...spex.exs` — one latched (regressed) + one never-latched (red) criterion on the same story; asserts the block names only the latched one's file.
- Criterion 1901 — a latched criterion's failure blocks in any working copy: `criterion_1901_...spex.exs` — sets the latch directly (standing in for a different copy's certifying run) and shows this copy still blocks on the regression even though it never earned the latch itself.
- Criterion 1902 — the ready-for-QA stamp clears on retirement: `criterion_1902_...spex.exs` — retires a criterion on a certified story; asserts the stamp is gone and `ready_for_qa` is no longer satisfied.
- Criterion 1903 — readiness/parking never change a criterion's latch: `criterion_1903_...spex.exs` — parks a certified story and clears `ready_for_dev`; asserts the latch is untouched.
- Criterion 1904 — a retired criterion's latch goes with it: `criterion_1904_...spex.exs` — retires a latched criterion; asserts its latch is gone.
- Criterion 1905 — a story is specs-ready only when every live criterion is latched: `criterion_1905_...spex.exs` — one green, one red criterion; certifies, asserts not specs-ready; catches the second up; certifies again, asserts specs-ready.
- Criterion 1906 — ready-for-QA scopes cross-story problems as promotion does: `criterion_1906_...spex.exs` (two scenarios) — an unlatched sibling story's red spex is advisory; a latched sibling's regressed criterion blocks, naming it.

Expected outcome for all twelve: each spex's own `then_` assertions pass. Cross-checked against `.code_my_spec/qa/plan.md`'s App Overview and the acceptance criteria text in the task prompt — the assertions map 1:1 onto the criteria's wording.

## Result Path

N/A — findings and the outcome are recorded via `create_issue` and `submit_qa_result`, not a result.md file (per `qa_story/workflow.md`).

## Setup Notes

This copy's own dev server (worktree `agent-conversation-ui`, pid 89836, `127.0.0.1:60642`) returned a reproducible 500 `CompileError` on every request this session: "could not compile application: code_my_spec ... the following files changed and must be recomputed on a server restart: `_build/dev/lib/code_my_spec/.mix/compile.lock`". This is Phoenix's code reloader refusing a hot recompile across a dependency/config-cache change — it needs an actual process restart, which is the harness's job, not something to do by hand against a shared `_build` directory. Filed as issue (see below); did not attempt to restart it myself.

In its place, verification leaned on two things: (1) static review of all twelve spex files for criteria 1895–1906, four of which (1898–1901) drive the real configuration LiveView and the real stop-hook HTTP endpoint rather than pure unit fixtures; (2) the fact that `ready_for_qa` on story 983 is itself certified at this exact commit, which per criterion 1774's own definition requires a clean run of all four analyzers — including these exact spex files — at HEAD. The app-level blocker is an environment/build-cache issue on this one worktree's dev server, not a defect in the story's code.
