# QA Brief — Story 727: Agents working the same project do not collide

Second pass. Builds on attempt `43cc9af8-7645-4ac8-b32d-cbb261909bec` (2026-08-13,
`partial`, one issue filed: `3c6b6b63`). That issue is now **resolved** — components
stay project-scoped by identity (deliberate design: 112 stories / 4048 requirements
reference stable component ids); per-harness *presence*/orphan-detection is handled
separately by `ComponentSync` + `ArchitectureChecker.orphans/1` once
`Harnesses.reclaim_quiet/1` (story 892) prunes an idle harness's Files. The
resolution names story 727 directly: its notes still read "Components follow
files... same grain," which is now superseded by the shipped design — that
sentence is stale documentation, not an open bug.

## Constraints this pass

Team-lead instruction: no browser. This story's 13 criteria are agent identity /
per-agent projection / lease refusal — no meaningful page surface, and Vibium is a
single shared instance across concurrent QA agents (measured, issue `0963f90f`:
three 1800s hangs, ~90 min lost). Surfaces used instead: writing files into this
working copy and reading the live harness's reaction from `harness.log`; MCP read
tools; `curl` against `:4004/mcp` with an explicit `X-Harness-Id` for a different
worktree; source-reading for mechanisms too destructive to trigger live (killing
another live agent's identity, or spawning a rival process against a working copy
another session is relying on right now).

This harness: root `.../phx-new-generator`, `harness_id
6bc4851f-f735-4590-bb1c-c660619b4019`, project `708492f9-454e-482f-a2eb-be64f0356b87`
(inst 15609). Baseline scan before writing this file: 4141 files, manifest accepted
at 04:31:10.327803Z.

## Plan

- 732/738/741: this brief.md itself is the probe (`Scanner.classify_qa/1` maps
  `.code_my_spec/qa/<id>/brief.md` → role `:qa_brief`, so it is a legitimate
  observation, not a fabricated artifact). Baseline/after file count in
  `harness.log` ties the write to this session's harness.
- 734: create a throwaway story via my own `create_story`, read it back over
  `curl` using a *different* worktree's `X-Harness-Id` (web-ui:
  `f9bcf3d8-677f-4ac1-9f0c-002a51c47e2a`), delete it after.
- 739: source-verify only. `harness_picker` import + `<.harness_picker>` call
  confirmed present in both `files_live.ex` and `problems_live.ex` this session
  (mirrors prior attempt's finding, re-confirmed 6 days later, no browser needed).
- 736/744: source-verified only, matching the prior attempt's own restraint —
  triggering either requires destroying another live agent's `.cms_harness.json`
  or starting a rival process against a working copy this session is relying on.
  Not a safe trade on a shared machine.
- 732 scoring: the criterion text is about *files*, not components. Files/Problems
  do carry `harness_id` (confirmed via migration). Score the literal criterion on
  that basis; note the stale story-notes sentence as a documentation finding
  distinct from — and not a re-file of — `3c6b6b63`.
- 742: `get_next_requirement()` (no story scope) returns a project-level item
  (`TriageIssues`), consistent with the story's own "Open" note that
  authored-work sequencing stays project-level rather than per-agent — this
  reads as an intentional scope boundary, not a defect.
