# Qa Story Brief — 873: Harness-to-Server Projection

## Tool

MCP + web + `harness.log` inspection — this story is deep infrastructure
(a harness scanning disk and delivering manifests to a server that holds
no disk of its own). Its own spex predominantly drive an in-process
`Fixtures` bridge rather than an HTTP route, so the QA equivalent is:
write a real file, let the real, currently-running harness for this
worktree pick it up on its own schedule (~2s debounce), then confirm the
effect through a read surface — `list_requirements` /
`show_requirement` / `show_story_requirements` (MCP), the Files LiveView
(`web`), or `~/.codemyspec/harness.log` (log inspection). This matches
the QA plan's "File projection" row in the Tools Registry: touch a file,
then query through one of the other surfaces.

## Auth

None needed for the surfaces this story touches. My own MCP tools
(`mcp__plugin_codemyspec_local__*`) are already scoped to this
worktree's harness. For the one curl probe (criterion 8194's proxy
test), no `X-Harness-Id` header is sent on purpose — that is the point
of the test.

For the hosted Files LiveView check (criterion 8193), if a session is
needed: `http://127.0.0.1:4000/users/log-in`, magic link to
`qa@codemyspec.local`, mailbox at `http://127.0.0.1:4000/dev/mailbox`
per `.code_my_spec/qa/plan.md`.

## Seeds

None required. All probes use disposable entities created and deleted
within this session (`create_story` / `delete_story`), or write/delete
plain files directly in this real, live worktree — the same worktree
the running harness already watches. No `delete_component` tool exists,
so no throwaway components are created anywhere.

## What To Test

- **bdd_specs_exist** (a written spex file satisfies it) — story 873's
  own `bdd_specs_exist` is already satisfied by the very spex files this
  session is reading, delivered by this exact pipeline. Confirmed via
  `show_story_requirements(873)`. Reinforced by the causal probe below
  (8192).
- **implementation_file** (a written implementation file satisfies it) —
  `CodeMySpec.Files`, the component that implements this story, already
  has `implementation_file` satisfied via the same live pipeline.
  Confirmed via `show_component_requirements("CodeMySpec.Files")`.
- **personas_complete** (persona research satisfies it) — already
  satisfied at the project level from real, pre-existing persona
  records. Confirmed via `list_requirements(requirement_name:
  "personas_complete", status: "satisfied")`.
- **qa_setup** (a written QA plan satisfies it) — `.code_my_spec/qa/plan.md`
  exists and the project-level `qa_setup` requirement is satisfied.
  Confirmed via `show_requirement(name: "qa_setup", entity_type:
  "project")`.
- **qa_journey_execute** (a written journey result satisfies it) — write
  real `.code_my_spec/qa/journey_plan.md` and
  `.code_my_spec/qa/journey_result.md` (conventional paths from
  `CodeMySpec.Paths.qa_journey_plan/0` and `qa_journey_result/0`)
  documenting an actual journey performed in this QA session, let the
  live harness sync, confirm the project-level requirement flips to
  satisfied.
- **An unclassifiable file is named rather than dropped** (8191) — DONE.
  Wrote a deliberately unclassifiable `.ex` file under `test/support/`,
  watched `~/.codemyspec/harness.log`'s unclassified-file count go
  1722→1723 on the very next scan, then deleted the probe file.
- **A spec written for a story created after the harness joined is still
  linked** (8192) — create a throwaway story via `create_story` (the
  harness has been continuously joined for this entire session, so any
  story created now was necessarily created after join), write its spex
  file at the conventional `test/spex/<id>_.../..._spex.exs` path, let
  the live harness sync, confirm `bdd_specs_exist` flips to satisfied
  for that story specifically (not cached/stale from join time), then
  `delete_story` and delete the file.
- **A spex file naming a story that does not exist is linked to nothing**
  (8193) — write a spex file under a directory named for a nonexistent
  story id, let the live harness sync it, confirm via the Files
  LiveView / an MCP read that the file is stored (manifest accepted)
  but confirm no story requirement anywhere references it, then delete
  the file.
- **A tool that needs a working copy refuses instead of using the
  server's** (8194) — proxy test: curl `127.0.0.1:4004/mcp` calling a
  Files-writing tool (`create_component`) with no `X-Harness-Id` header,
  confirming a clean refusal rather than a silent fallback to this
  worktree's own harness (or any other). The spex-level scenario
  (`scope.environment: nil, scope.cwd: nil` inside the hosted server
  with no connected harness) is not reachable from my available
  surfaces — no hosted MCP tools are in my toolset and minting a hosted
  OAuth bearer locally requires the Cloudflare tunnel per the QA plan,
  which is out of scope for a local-harness QA session. Reported as not
  directly exercisable; the plug-level proxy above is the closest live
  substitute and is exercised.

## Result Path

`.code_my_spec/qa/873/` (screenshots, if any, under `screenshots/`) —
findings recorded via `create_issue`, outcome via `submit_qa_result`.
There is no `result.md`; the DB attempt is canonical.

## Setup Notes

This story has no meaningful browser surface of its own to click through
— it is the mechanism that makes every other story's requirements
observable at all. Every probe here writes a real file into this real,
live worktree and watches this worktree's own already-running harness
project it through the real channel to the real server, which is a
closer-to-production test than the in-process `Fixtures` bridge the
spex suite uses. All throwaway entities (stories, files) are deleted at
the end of their respective probes.

## Retry Note (qa-873b, session 2)

This is a second QA pass on story 873, run under an explicit instruction
**not** to mutate this working copy (no write-then-delete probe files, no
throwaway `create_story`/`delete_story`). That rules out live-executing the
mutation-based probes this brief originally described for criteria 8192 and
8193, and the create/delete-story probe for 8191 — even though the earlier
pass reported them done.

What this session actually verified, all read-only / non-mutating:

- **8186 bdd_specs_exist, 8187 personas_complete, 8188 qa_setup, 8190
  implementation_file** — confirmed via `show_story_requirements(873)` /
  `show_component_requirements("CodeMySpec.Files")` /
  `show_requirement(entity_type: "project")`: all satisfied right now, by
  this exact project's own real, pre-existing spex files, persona records,
  QA plan, and `lib/code_my_spec/files.ex` — genuine production evidence,
  not manufactured.
- **8191 unclassifiable file named, not dropped** — no probe file needed.
  `~/.codemyspec/harness.log` already shows `report_unclassified/2` firing
  on every scan of this real worktree, naming ~1720 real pre-existing files
  by path (e.g. `lib/code_my_spec_web/components/layouts/root.html.heex`).
  The count moves scan-to-scan (1707–1724 across worktrees over the last
  day) as real dev activity changes what's on disk, and the log line always
  carries file paths, not just a bare count — live confirmation that
  unclassifiable files are named, not silently dropped.
- **8194 tool refusing without a working copy** — `curl` to `127.0.0.1:4004/mcp`
  calling `create_component` with no `X-Harness-Id` header returned a clean
  JSON-RPC error (`-32000`, "This request does not say which working copy it
  is about...") rather than silently falling back to this worktree's own
  harness. Note: this exercises the *local proxy's* harness-id requirement,
  not the exact hosted-server `scope.environment: nil` path the spex covers
  — same as the original brief's own caveat on this probe.
- **8189 qa_journey_execute** — NOT independently positive-verified this
  session. The project-level requirement is currently unsatisfied (no
  `journey_result.md`), which is consistent with the mechanism working
  correctly on absence, but demonstrating the positive case would mean
  writing `journey_plan.md`/`journey_result.md`, which this session's
  constraints rule out doing as a QA probe.
- **8192 (story created after join still linked) and 8193 (ghost-story spex
  linked to nothing)** — NOT live-exercised this session; both need a
  working-copy file write (and 8192 a throwaway story) to observe causally.
  Not re-verified independently here. Supporting evidence instead: read the
  spex source for both
  (`test/spex/987_harness_to_server_projection/criterion_8192_*_spex.exs`,
  `criterion_8193_*_spex.exs`) and confirmed the implementation logic is
  correct, and `bdd_specs_passing` is satisfied for story 873 (full spex
  suite green), but that is spex evidence, not a live browser/MCP probe —
  per QA doctrine a green spex is not itself a QA pass.

Also hit: the shared Vibium MCP browser tool was completely wedged for this
session's entire browser-verification window (~90 min, three consecutive
1800s timeouts on `browser_new_page`/`browser_list_pages`/`browser_navigate`,
plus two fast BiDi `unknown error`s before that) — most likely concurrent
contention from the many QA subagents running in parallel today, not a
story-873 defect. Filed as issue 0963f90f. This is why the Files LiveView
check for 8193 could not be attempted at all, on top of the no-mutation
constraint.

Net: submitting `partial` — 6 of 9 criteria have real, live, non-mutating
confirmation; 3 (8189's positive case, 8192, 8193) are not independently
verified in this session and are reported as such rather than assumed from
the prior brief or from spex passing alone.
