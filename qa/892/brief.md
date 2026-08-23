# QA Brief — Story 892: A working copy that vanished warns until I offboard it

## Tool

web (Vibium) for `CodeMySpecWeb.WorkingCopyLive.Index` (`/app/projects/:project_id/working-copies`) —
the only surface that removes a working copy. curl for the two HTTP endpoints
a harness itself uses to establish and report on a working copy:
`POST /api/harnesses` (mint/recognise, `CodeMySpecWeb.HarnessLookupController`)
and `POST /api/devices` (machine announce + path observation,
`CodeMySpecWeb.DeviceController`).

Attaching a `device_id` to a working copy (what makes `observe_paths/2` able to
flip it missing/present) only happens inside the `harness_project:<project_id>`
Phoenix channel join — there is no HTTP-only way to do it. See Setup Notes.

## Auth

Hosted app (`:4000`): magic-link login as `qa@codemyspec.local` per
`.code_my_spec/qa/plan.md` — rewrite the mailed link's origin to
`http://127.0.0.1:4000` before following it.

`/api/harnesses` and `/api/devices` take a project deploy key or a token
exchanged for one at `POST /api/sprite/token`. The QA Fixture Project's key is
`dk_qa_codemyspec_local` — use only this key for anything under this brief.
**Never** pass the real `code-my-spec` project's own `DEPLOY_KEY` (from
`envs/dev.env`) to these scripts; it mutates the live project every other
agent in this session is working against.

## Seeds

No seed script needed — the QA Fixture Project (`11111111-1111-4111-8111-111111111111`)
already exists. Mint a scratch working copy row with:

    TOKEN=$(curl -sS -X POST http://localhost:4000/api/sprite/token \
      -H 'authorization: Bearer dk_qa_codemyspec_local' -H 'content-type: application/json' \
      | sed -n 's/.*"access_token":"\([^"]*\)".*/\1/p')

    curl -sS -X POST http://localhost:4000/api/harnesses \
      -H "authorization: Bearer $TOKEN" -H 'content-type: application/json' \
      -d '{"project_id":"11111111-1111-4111-8111-111111111111","root":"/tmp/<scratch-root>","label":"<label>"}'

The reply's `working_copy_id` is the row's id. Point `root` at a real directory
if you want an on-disk check (criterion 2865); a nonexistent path is fine for
everything else.

## What To Test

At `http://127.0.0.1:4000/app/projects/11111111-1111-4111-8111-111111111111/working-copies`:

- **2863 / 2865** — mint a working copy at a real scratch directory. Click
  **Offboard**, confirm the `<.confirm_dialog>` names the copy and states files
  + problems + orphaned components are removed and the checkout is not
  touched. Confirm. The row disappears, the flash states real counts, and the
  directory (and its `.cms_harness.json`) are untouched on disk.
- **2864** — `grep -rn "WorkingCopies.offboard" lib/` has exactly one call
  site: this button's `handle_event`. No scheduled job, hook, or sync path
  calls it — confirms nothing offboards a copy without a click.
- **2868** — re-POST `/api/harnesses` presenting the id of a working copy you
  just offboarded (same root, same id in the body). The reply carries a
  **different** `working_copy_id` — a returning checkout is issued a new
  identity, never repaired into the old row.
- **2859 / 2862 (UI)** — `UPDATE working_copies SET path_missing_since = now()
  WHERE id = '<id>'` on a copy you own, reload the page: "Checkout gone" badge
  and warning text render. Set it back to `NULL`: badge disappears. This
  proves the render path; the detection path (`observe_paths/2` stamping the
  column from a real report) is channel-only — see Setup Notes and the spex
  list below.
- **2866 (partial live)** — offboarding a working copy with orphaned
  components in the project removes them; the flash names the count. Verified
  live during this pass (8 orphaned components removed alongside qa-739-beta).

Always clean up rows you mint: `DELETE FROM working_copies WHERE id = '<id>'`
(only after confirming it has no files/problems, or offboard it through the UI
instead — that's the real deletion path and leaves no residue to clean by
hand).

## Not reachable outside the app — verified via `mix spex` instead

Every one of the 11 criteria has a dedicated, substantive spex file at
`test/spex/1014_a_working_copy_that_vanished_warns_until_i_offboard_it/`, and
the story's `bdd_specs_passing` requirement is satisfied (green as of this QA
pass). These use `join_working_copy`/`harness`/`report` helpers that call the
real channel-join and `observe_paths` code in-process — not a fixture standing
in for the mechanism.

- **2860** (offline device isolation), **2861** (device-scoped path
  authority — two working copies at one path, two devices), **2867**
  (authored links survive an offboard), **2872** (a restarted harness asks the
  server what it's carrying) — genuinely need either two independent device
  identities or a harness-process restart. Neither is reachable from outside
  the BEAM without running a second, independently-credentialed `cms harness`
  process, which hit an unresolved local blocker — see Setup Notes.
- **2859 / 2862** (detection/clearing on the server side, as opposed to the UI
  render checked live above) fall in the same bucket, since they also need a
  device-attached working copy plus a real path observation.

Code-read alongside the spex for each: `WorkingCopies.observe_paths/2` scopes
every write to `w.device_id == ^device_id` (the security boundary 2861 is
about), and `reclaim_orphan_components/1` in `working_copies.ex` excludes
anything a file or a story still points to project-wide (2867).

## Result Path

Findings filed with `create_issue` as found, submitted via `submit_qa_result`.
Screenshots: `.code_my_spec/qa/892/screenshots/`.

## Setup Notes

**A second harness process could not join the QA Fixture project's channel on
this machine.** Started via `CMS_HARNESS=1 CMS_DEPLOY_KEY=dk_qa_codemyspec_local
cms start` (the published binary, on a free port via `CMS_HARNESS_PORT` +
`CMS_NODE_NAME` to dodge the sname collision with the already-running dev
harness) — the socket still connected using the **real `code-my-spec`
project's** deploy key (verbatim, confirmed byte-for-byte against
`envs/dev.env`'s `DEPLOY_KEY`) regardless of the process's own `CMS_DEPLOY_KEY`
env var, and every join to `harness_project:11111111-...` was refused. Same
result from the already-running dev harness via `qa_agents.sh touch`. Filed as
a framework issue — this blocks any future QA needing a second, independently
credentialed harness identity on this box, which is exactly the case
`CmsHarness.Credentials`'s moduledoc says the per-working-copy credential
resolution exists to support.

`/codemyspec:qa story <id>` (the documented skill shortcut) is also broken
right now: `SkillRouter`'s topic-task path builds `%{requirement_name: topic}`
but `QaStory.get_story_id/1` pattern-matches on `%{story_id: story_id}`, so
every invocation fails with "QaStory requires a story ID argument" regardless
of the id passed. Worked around by calling the `start_task` MCP tool directly
with `requirement_name: "qa_complete", entity_type: "story", entity_id: "892"`.
Filed as a framework issue.

The story 739 fixture rows (`qa-739-alpha`, `qa-739-beta`) pre-existed in the
QA Fixture project with `device_id` already `NULL` — the same channel-join
limitation likely blocked that QA pass too, for the same underlying reason.
