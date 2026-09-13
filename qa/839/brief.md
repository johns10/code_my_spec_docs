# Qa Story Brief

## Tool

`curl` against the harness's own HTTP surface (`CmsHarness.Web.Endpoint`, port 4004), plus direct inspection of `~/.codemyspec/harness.log` and `~/.codemyspec/web.log`.

This story has no LiveView/browser surface. The deliverable is
`CmsHarness.Project.AnalysisServer` (per-working-copy analyzer queue) and
`CmsHarness.AnalysisSlots` (machine-wide semaphore). Their only externally
observable surface is (a) the HTTP endpoint that dispatches an analyzer run,
and (b) the log lines both modules emit at each decision point. Vibium does
not apply — there is nothing to render.

## Auth

None. `POST /api/harnesses/<working_copy_id>/analysis/run` sits behind the
harness's `:hook` pipeline (`LocalOnly` — loopback IP only, no credential).
Working copy id is the maintenance worktree itself:
`7bd818cc-e623-4220-aa47-a95a443824a5` (confirmed live via
`list_working_copies` and `curl localhost:4004/health`).

## Seeds

None needed. The "seed data" for this story is real, ongoing analyzer
traffic on a shared multi-agent dev box — already present in volume in
`~/.codemyspec/harness.log` and `~/.codemyspec/web.log` (11-14 concurrently
served working copies, each running its own stop-hook-triggered
compiler/credo/exunit/spex sweeps).

## What To Test

- **Tie, not supersede** (criteria 3439/3444/3445): grep
  `~/.codemyspec/harness.log` for `AnalysisServer.tie_to_queued/3` and grep
  `~/.codemyspec/web.log` for `"superseded"` / `"already queued"` rejection
  warnings. Compare timestamps against when the fix commit (`ed3f949c9`,
  2026-09-12 20:49:25 -0400 = `2026-09-13T00:49:25Z`) landed, and when the
  currently-running build (>= `c852941b7`) booted.
- **Slot-wait, not instant refuse** (criteria 3438/3440/3443/3446/3447): grep
  `harness.log` for `CmsHarness.AnalysisSlots` — the new
  `"waiting for a machine-wide slot"` message vs. the old
  `"refusing an analyzer run: N already running ... re-enqueued by the next
  stop"` message. Same before/after comparison against the fix landing time.
- **Direct drive**: fire two concurrent `POST .../analysis/run` requests for
  the same source (`compiler`) against the maintenance working copy and
  confirm both return real, non-fabricated bodies (not a synthetic
  `:superseded` answer), while watching `harness.log` for the tie event on
  that same working copy.
- **Automated regression backstop** (not a substitute for the above, but
  corroborating): `test/cms_harness/analysis_slots_test.exs`,
  `test/cms_harness/analysis_path_test.exs`, and the 8 spex files under
  `test/spex/1002_model_and_system_share_one_analysis_run_record/` map
  1:1 onto criteria 3438-3447. Not executed directly in this session —
  the harness already runs this exact suite against this exact working copy
  continuously during the session (visible in the logs), and a second
  concurrent `mix test`/`mix spex` invocation against the same `_build`
  would be the exact hazard `AnalysisSlots`' own moduledoc describes.

## Result Path

No `result.md` for this workflow variant — findings go through
`create_issue` as discovered, and the session ends with one
`submit_qa_result` call carrying the structured `scenarios` list and every
issue id filed.

## Setup Notes

The dev box hosting `:4000`/`:4004` is shared by many concurrent agent
worktrees and experienced two `econnrefused` restart windows during this
session (visible as `ChannelClient.handle_disconnect` bursts in
`harness.log`, `build` field changing in `/health` across polls). This is
known, unrelated infra churn (see CLAUDE.md "Ports" reference notes on
`:4000` restarts) — not a story 839 regression — and is not filed as an
issue against this story. It did make the live two-request drive slow
(queued behind the machine-wide slot on a saturated box, which is itself
consistent with the fix's own wait-not-refuse behavior).
