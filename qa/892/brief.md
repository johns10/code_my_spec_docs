# QA Brief — Story 892: An agent that has gone quiet stops holding state for everyone else

## Tool

curl for `POST /api/hooks/stop`; web (Vibium) for the components LiveView — both on the same endpoint.

Both surfaces belong to `CodeMySpecLocalWeb`, which is why this story can be
tested from one running app: the hook is what triggers a reclaim and the
components page is where its effect is visible. Testing either alone proves
nothing — a reclaim with no observer, or an observer with nothing to observe.

## Auth

None. `CodeMySpecLocalWeb` runs `Plugs.LocalOnly`, which rejects anything
off-loopback with `403 {"error": "Localhost only"}` and trusts whoever is on
the box. Requests must originate from `127.0.0.1`.

The hook identifies its working copy rather than its user:

    curl -sS -X POST localhost:4014/api/hooks/stop \
      -H 'content-type: application/json' \
      -H "x-harness-id: <HARNESS_ID>" \
      -d '{"session_id":"qa-892"}'

`x-harness-id` is the whole of the request's identity — `Plugs.HarnessScope`
resolves the project, the working copy's root, and the environment from it, and
ignores anything the request says about where it is.

## Seeds

The QA instance is a second copy of the app on its own port and its own
database, so nothing here can touch `~/.codemyspec/cli.db`, the dev Postgres, or
another agent's working copy:

    CMS_PORT=4014 \
    CMS_DB_PATH=<scratch>/qa892/qa.db \
    MIX_ENV=dev_cli elixir -S mix phx.server

Seed with:

    NO_SERVER=true CMS_DB_PATH=<scratch>/qa892/qa.db MIX_ENV=dev_cli \
      elixir -S mix run <scratch>/qa892/seed.exs

The seed builds the two-agent situation the story is about:

- a project, with `harness_idle_hours` left at its default of 2
- **harness A** — "the agent that left": `last_seen_at` 96 hours ago, holding
  file rows for a spec and an implementation, which project a component
  `QaOrphanContext`
- **harness B** — "the agent still working": `last_seen_at` now, its own root,
  no files
- **`QaAuthoredContext`** — a component with a story pointing at it, whose only
  files also belong to A. It is the control: authored links are not derived
  state and must survive the same sweep that takes the orphan.

It prints `PROJECT_ID`, `HARNESS_A`, `HARNESS_B` for the steps below.

## What To Test

Before the hook, at `http://localhost:4014/app/projects/<PROJECT_ID>/components`:

- Both `QaOrphanContext` and `QaAuthoredContext` are listed. This is the
  premise, and it is worth checking rather than assuming — a page that lists
  neither would make every later step pass for the wrong reason.

Fire the live agent's stop hook (criterion 2384 — the sync is the trigger, so
an ordinary stop is the whole interaction; there is no sweep endpoint to call):

    curl -sS -X POST localhost:4014/api/hooks/stop \
      -H 'content-type: application/json' -H "x-harness-id: <HARNESS_B>" \
      -d '{"session_id":"qa-892"}'

Then reload the components page and check:

- `QaOrphanContext` is **gone** — criterion 2379. Its files belonged only to a
  checkout nobody is running, and no story points at it, so nothing an agent
  does in any working copy could have cleared what the graph demanded of it.
- `QaAuthoredContext` is **still listed** — criterion 2380. Someone decided that
  link; it is not regenerable, and spending it to reclaim a derived row is the
  bad trade.
- A's file rows are gone and B's remain — criterion 2385. The sweep is not
  scoped to the agent doing the syncing; if it were, B would sweep itself, find
  nothing, and reclaim nothing forever while looking correct.

Then, without re-seeding:

- Fire the hook again as B. Nothing further is reclaimed, and the page is
  unchanged — a second sweep has nothing to find.
- Fire the hook as **A**, the agent that was reclaimed, and check the response
  carries no error — criterion 2378. A returning agent presents the id from its
  own checkout and is served as the same harness; only its derived state was
  taken. Then confirm B's component is untouched — criterion 2377, a working
  agent is never reclaimed out from under itself.

Configuration, on `http://localhost:4014/app/projects/<PROJECT_ID>/configuration`:

- Set **harness idle hours** to `0` and save. Re-seed, then fire B's hook
  immediately, with A only seconds old rather than days. `QaOrphanContext`
  disappears without any waiting — `0` means a harness that is not the caller is
  quiet at once.
- Set it to a large value (`720`). Re-seed and fire B's hook. `QaOrphanContext`
  survives: A is 96 hours idle, well inside a 720-hour window — criterion 2381,
  an unswept checkout is not a quiet agent.

Not testable from outside the app, and left to the spex that already cover them:

- criterion 2382 (idle time is measured in UTC) — reproducing it needs the
  machine's timezone changed under a running server.
- criterion 2383 (coming back is onboarding, not recovery) — needs a real
  harness process re-onboarding a root.

## Result Path

Findings are filed with `create_issue` as they are found and submitted via
`submit_qa_result`; the harness does not read a result file. Screenshots:
`.code_my_spec/qa/892/`.

## Setup Notes

The QA rig needed two fixes before it would start at all, both filed as
critical framework issues:

- `61351c19` — CLI migration `20260810220000` carried Postgres `split_part` and
  `::integer` into SQLite.
- `ca46f606` — CLI migration `20260813210000` altered `question_requests`, a
  table the CLI set never creates.

Neither had ever run: both local databases sit behind them, so the next release
carrying either would have failed to boot for every existing user, not only for
fresh installs. `CodeMySpecLocalWeb.Migrator` is a supervision-tree child, so a
failing migration stops the application rather than being skipped.
