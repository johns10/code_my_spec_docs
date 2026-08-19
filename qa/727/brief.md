# QA Brief — Story 727: Agents working the same project do not collide

Second pass. Builds on attempt `43cc9af8-7645-4ac8-b32d-cbb261909bec` (2026-08-13,
`partial`, one issue filed: `3c6b6b63`, now resolved — components stay
project-scoped by identity, per-harness by presence via `ComponentSync` +
`ArchitectureChecker.orphans/1`; the story's own notes were updated 2026-08-15
to reflect that, so the stale-doc caveat that made criterion 732 partial last
time no longer applies).

## Tool

No `web` — this story's 13 criteria are agent identity / per-agent projection /
lease refusal, with no meaningful page surface (team-lead instruction, learned
from burning QA agents on the neighbouring story 873). Tools instead: writing
files into this working copy and reading the reaction in
`~/.codemyspec/harness.log`; MCP read tools bound to this worktree's own
harness; `curl` against `localhost:4004/mcp` with an explicit `X-Harness-Id`
header for a *different* worktree; source-reading for mechanisms too
destructive to trigger deliberately (killing another live agent's identity
file, or spawning a rival process against a working copy another session
depends on right now).

## Auth

None needed. The local harness endpoints (`:4004`, loopback-only) are scoped
entirely by the `X-Harness-Id` header / `?harness=` param, not by login —
`Harnesses.fetch(id)` preloads `.project`, so no project id or session is ever
supplied on the wire. This session's own MCP tools already carry an
authenticated context; the cross-harness `curl` calls reuse the same MCP
session-id handshake (`initialize` → `notifications/initialized` →
`tools/call`) with a different `X-Harness-Id`.

## Seeds

None needed. Fixtures are the repo's own worktrees — 9 of them, each with its
own `.cms_harness.json` (distinct `harness_id`, some sharing project
`708492f9-454e-482f-a2eb-be64f0356b87`) — and this project's own real backlog
(stories, issues) as authored-data fixtures for the project-scoped-vs-harness-
scoped distinction the story is built around.

## What To Test

- 732/738/741 — write/delete a file inside this working copy, confirm the file
  count in `harness.log` moves and comes back (`.code_my_spec/qa/scripts/` is
  a real, role-classified probe location — not fabricated)
- 733 — two harnesses at different worktree paths hold distinct `harness_id`s
  despite some sharing one project (source + `.cms_harness.json` comparison)
- 734 — create a throwaway story via this worktree's own MCP tools, read it
  back over `curl` using a different worktree's `X-Harness-Id`, delete it
- 735 — a restarted harness process resumes the same harness_id's state with
  no data loss (opportunistic: watch for a natural process handoff during the
  session)
- 736 — source only: identity is always server-minted, never derived from
  path/host, so a lost identity cannot coincide with another's by
  construction. Not safely triggerable live (would require destroying a live
  peer's `.cms_harness.json`)
- 737 — source: `HarnessScope` resolves purely from `X-Harness-Id`, no code
  path accepts a client-supplied project id; corroborated by every MCP call
  this session
- 739 — no browser this pass: grep `files_live.ex` / `problems_live.ex` for
  `<.harness_picker>` + `Harnesses.viewing/1` wiring
- 740 — source only: sync is push-based from an active harness process; there
  is no passive path for an unwatched edit to produce file state
- 742 — compare `get_next_requirement()` (project-level) against the story's
  own "Open" note that next-work must stay per-project for authored work
- 743 — source only: sprite-volume recreation is out of scope to trigger live
  this pass
- 744 — source-verified mechanism (`take_working_copy/2`,
  `ChannelClient.log_refusal/3`); live-trigger only if a second process
  naturally joins this working copy during the session — do not engineer it

## Result Path

`.code_my_spec/qa/727/result_complete.md`

## Setup Notes

Disk at 96% — keep artifacts small, no screenshots, delete every probe file
and throwaway story before submitting. The QA sandbox project is not isolated
from the real backlog (issue `ee058c95`), so anything created here (stories,
issues, files) lands in the real project — clean up accordingly.
