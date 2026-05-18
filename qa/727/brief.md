# Qa Story Brief

## Tool

web

## Auth

No auth required. The local web app on port 4004 uses `Plugs.LocalOnly`
(loopback-only) + `X-Working-Dir`-based scope resolution. The browser
sends `X-Working-Dir: /Users/johndavenport/Documents/github/code_my_spec`
automatically when launched against `http://localhost:4004`.

## Seeds

No seeding required. The cli_dev.db at `~/.codemyspec/cli_dev.db` already
contains the qa_attempts + qa_invalidations data accumulated during this
session — that data is exactly what the index needs to render.

## What To Test

Target URL: `http://localhost:4004/projects/code-my-spec/qa`

- **Default view (criterion 6474):** open the QA index from the sidebar.
  Sidebar should have a "QA" entry on every project page. Click it.
  Expect: page renders with the latest-pass-per-story default (no older
  attempts, no invalidated). Story titles + status + submitted-at columns.
- **Filter toggle: include older (criterion 6475):** flip the
  "Include older" toggle. Page should re-render showing prior attempts
  per story (parent_attempt_id lineage visible).
- **Filter toggle: include invalidated (criterion 6475):** flip the
  "Include invalidated" toggle. Page should re-render with the 29
  invalidated attempts from this session visible, each with the
  invalidation reason.
- **Sidebar entry presence (criterion 6474):** confirm "QA" appears in
  the local web sidebar on at least one other project page (e.g.
  `/projects/code-my-spec/architecture`) so it isn't a per-route accident.

## Result Path

.code_my_spec/qa/727/result.md
