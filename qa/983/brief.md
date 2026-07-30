# Qa Story Brief

Story 983 — Spec failures block only stories whose specs have gone green.

The story has two halves with different surfaces. The **latch UI** is a
LiveView on the local app (StoryLive.Index) and is tested in the browser.
The **enforcement and gate** halves are agent-facing — they run through the
stop hook and the MCP requirement tools — and are tested against the live
local endpoint, not through a page.

## Tool

web (MCP browser tools) for StoryLive.Index; curl for the local `/api/hooks/*`
and MCP surfaces.

## Auth

The local endpoint has no user auth — `Plugs.LocalOnly` accepts loopback only.
Project scope comes from the working directory.

- Browser: navigate directly, no login.
  `http://127.0.0.1:4004/projects/code-my-spec/stories`
- Hook/API: send the working dir header on every request.
  `-H "x-working-dir: /Users/johndavenport/Documents/github/code_my_spec"`

Port 4004 is the in-repo dev server (`MIX_ENV=dev_cli mix phx.server`), which is
the one running this story's code. Port 4003 is the published binary on older
code — do not test against it.

## Seeds

No seed script. This story is verified against the real `code_my_spec` project
in `~/.codemyspec/cli_dev.db`, because the interesting states (stories with a
passing QA attempt, stories mid-build) already exist there in volume and are
more representative than anything a fixture would build.

Schema for the story was applied to the running DBs directly rather than via
`mix ecto.migrate`, which would take the compile lock and 500 the live servers:

```
sqlite3 ~/.codemyspec/cli_dev.db "ALTER TABLE stories ADD COLUMN specs_ready BOOLEAN"
sqlite3 ~/.codemyspec/cli_dev.db "UPDATE stories SET specs_ready = 1 WHERE id IN (SELECT story_id FROM qa_attempts WHERE status = 'pass')"
sqlite3 ~/.codemyspec/cli_dev.db "UPDATE project_configurations SET spex = 'block_all' WHERE spex IS NULL OR spex = 'off'"
```

Backups taken first: `~/.codemyspec/db_backups/cli_dev_pre_983_*.db` and
`~/.codemyspec/db_backups/code_my_spec_dev_pre_983_*.sql`.

Reference values after seeding:
- 59 of 232 stories latched (`specs_ready = 1`) — the grandfathered set
- 7 project configurations at `spex = block_all`
- Story 983 itself is unlatched and is the story under test

## What To Test

- **Grandfathering is not a blanket flip.** Query the latched set and confirm
  it equals the set with a passing QA attempt — not all stories, not none.
  Guards the migration against reopening the whole back catalogue.
- **Story list renders both latch states.** Visit
  `/projects/code-my-spec/stories`. Expect `data-test="story-specs-ready"` on
  latched stories and `data-test="story-specs-not-ready"` on unlatched ones,
  each with its own toggle button. Screenshot.
- **Manual toggle clears the latch.** Click
  `[data-test='toggle-story-specs-ready']` on a latched story. Expect the
  badge to flip to "Specs not green" and persist across a reload. Screenshot
  before and after.
- **Manual toggle sets the latch.** Click it again. Expect "Specs green" back.
  Covers criteria 8169 and 8170 — the two-way override.
- **The gate is in the graph and ordered before QA.** Call
  `show_story_requirements` for story 983. Expect `bdd_specs_passing` present,
  unsatisfied, and listed before `qa_complete`. Covers 8157 and 8167.
- **The gate reads the latch.** Set 983's latch by hand, re-read requirements,
  expect `bdd_specs_passing` satisfied; clear it, expect unsatisfied. Covers
  the `:field_true` check end to end.
- **A latched story shows the gate satisfied.** Pick a grandfathered story and
  confirm its `bdd_specs_passing` reads `[x]` — the migration's whole purpose.
- **Config default is blocking for existing projects.** Confirm
  `spex = block_all` on the existing project configurations, and that the
  Configuration page renders the spex mode.
- **The spex analyzer runs regardless of mode.** Confirm the requirement graph
  does not report the gate as permanently unsatisfiable when spex is off —
  the wedge scenario. Set one project's spex to `off` and confirm the gate
  still evaluates.

## Result Path

Findings go to `create_issue` and the attempt to `submit_qa_result`; no result
file. Screenshots: `.code_my_spec/qa/983/screenshots/`.

## Setup Notes

The local app runs on SQLite (`cli_dev.db`), not the Postgres
`code_my_spec_dev` that the hosted app on :4000 uses. Both needed the column;
only the SQLite one is exercised by this story's UI.

The published binary on :4003 runs older code without `specs_ready` and will
keep working — the column is additive and the old code never selects it.
