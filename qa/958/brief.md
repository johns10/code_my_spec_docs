# Qa Story Brief

QA brief for story 958 — Mark Stories Ready for Development to Control Pace.

The story ships the epic board (`CodeMySpecLocalWeb.EpicsLive`) plus the
`ready_for_dev` pace gate. The board is a LiveView on the local endpoint, so
this is browser QA.

## Tool

web

## Auth

None. The local endpoint (`CodeMySpecLocalWeb`) has no user auth — `Plugs.LocalOnly`
admits any loopback request and project scope comes from the URL's
`:project_name` segment.

Base URL for the in-repo dev server:

```
http://localhost:4004
```

Board under test:

```
http://localhost:4004/projects/code-my-spec/epics
```

## Seeds

**Do not run `priv/repo/cli_qa_seeds.exs` for this story.** Two reasons:

- `MIX_ENV=dev_cli mix run ...` takes the dev_cli compile lock and 500s the
  running :4004 server mid-session.
- The board already has real data in `~/.codemyspec/cli_dev.db` (50+ stories,
  existing epics), which is a better test of the real thing.

Instead, create disposable fixtures **through the UI under test** and delete
them at the end:

- One epic named `QA 958 Epic`
- Three stories titled `QA 958 story A|B|C`, created at
  `http://localhost:4004/projects/code-my-spec/stories/new`

**Critical constraint:** never release or park any pre-existing story. The
`ready_for_dev` flag drives `Requirements.Preloader`, so parking a real story
silently removes it from the requirement graph and changes what the harness
serves next. Bulk release/park must only ever be aimed at `QA 958 Epic`.

## What To Test

- **Board renders** — visit `/projects/code-my-spec/epics`. Two columns:
  epics left, unfiled stories right. Both scroll independently.
- **New story defaults to parked** (criterion 7940) — create `QA 958 story A`
  at `/stories/new` with only title + story filled. Expect it to save (no
  "can't be blank" error from the untouched criterion row) and show `parked`.
- **Epic creation** (7938) — "New epic" → create `QA 958 Epic`. Expect it in
  the left column with `0 stories · 0 ready`.
- **Drag to file** (7938) — drag `QA 958 story A` from unfiled into
  `QA 958 Epic`. Expect it to leave the unfiled column and the epic header to
  update to `1 stories`.
- **Drag out** (7939) — drag it back to the unfiled column. Expect the epic to
  return to `0 stories` and the story to reappear on the right.
- **Bulk release** (7941) — file all three stories, then click `Release`.
  Expect all three to show `ready` and the header to read `3 ready`.
- **One-shot, not a cascade** (7941) — file a fourth story *after* the release.
  Expect it to stay `parked` while the other three stay `ready`.
- **Bulk park** (7957) — click `Park`. Expect all of the epic's stories to show
  `parked`, and spot-check that a story outside the epic is unchanged.
- **Rename** (7956) — `Edit` → rename to `QA 958 Renamed`. Expect the new name
  on the board, the URL slug to follow, and the filed stories to survive.
- **Delete returns stories to unfiled** (7958) — `Delete` → confirm. Expect the
  epic gone, every story that was in it back in the unfiled column, and each
  story's readiness unchanged.
- **Per-story toggle** (7945) — toggle one QA story `parked` → `ready` → back.
- **Nav** — `Epics` appears in the sidebar under `// data` and is marked active
  on the board.

Screenshots at each key state to `.code_my_spec/qa/958/screenshots/`.

## Result Path

Recorded in the DB via `submit_qa_result`; screenshots at
`.code_my_spec/qa/958/screenshots/`.

## Setup Notes

Drag-and-drop is SortableJS via a colocated LiveView hook. Driving it needs a
real browser drag (`vibium drag`) — LiveViewTest cannot dispatch drag events,
which is why the BDD specs push the `move_story` event directly instead.

Cleanup at the end of the session: delete `QA 958 Epic` (or its renamed form)
and the four `QA 958 story *` records so the project's backlog is left as
found.
