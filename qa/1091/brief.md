## Tool

web

## Auth

Seed first (idempotent):

```
DATABASE_NAME=code_my_spec_dev_wc_ad7d67d6 MIX_ENV=dev mix run priv/repo/qa_seeds.exs
```

Log in as the seeded QA fixture user via the dev sign-in shortcut (no mailbox needed):

```
curl -s -X POST http://127.0.0.1:<instance-port>/dev/sign-in -d 'email=qa@codemyspec.local&password=qa-dev-sign-in'
```

Take the returned `sign_in_url`, rewrite its origin to `http://127.0.0.1:<instance-port>`, and navigate the browser there. Lands on `/app` inside the **QA Fixture Project** (`11111111-1111-4111-8111-111111111111`) — this project doubles as the sandbox for agent-surface mutation tests per `.code_my_spec/qa/plan.md`, so issue-assignment scenarios are safe to run here without touching the real CodeMySpec backlog.

## Seeds

Same seed command as above. The fixture project already carries a mix of `incoming`/`accepted` issues left over from prior QA cycles (shared sandbox) — reuse one of the `accepted` ones, or `Accept` an `incoming` one from its issue page, rather than minting new fixture rows.

## What To Test

- Navigate to `/app/projects/11111111-1111-4111-8111-111111111111/issues`, open any issue card (they're `phx-click` navigate cards, not plain `<a>` links — `browser_map`/`browser_find` won't surface them as links; read the `phx-click` attribute off the card div to get the `/issues/:id` href if clicking by ref doesn't navigate).
- On an `incoming` issue, click **Accept**. Confirm the badge changes to `accepted` and an **"Assign to working copy"** form appears (`form[data-test="issue-assignment-form"]`, `phx-submit="assign_to_working_copy"`).
- Select a working copy from the dropdown and click **Assign**. This is criterion "Main assigns an accepted issue" / "The user assigns from the issue page".
- With that issue still assigned, select a **different** working copy in the same form and click **Assign** again. This is criterion "Main moves an issue to another team".
- After each Assign, the UI gives no visible confirmation (form just resets to the blank "Choose a working copy" option) — verify the actual effect server-side, not from the page:
  ```
  psql -qtA code_my_spec_dev_wc_ad7d67d6 -c "select assigned_working_copy_id, awaiting_role, updated_at from issues where id = '<issue-id>';"
  ```

## Result Path

(no result.md — findings go through `create_issue`, the pass/fail through `submit_qa_result`)

## Setup Notes

This copy's app instance (`ensure_app_running`) was found `erroring` at session start with `Phoenix.Ecto.PendingMigrationError`. The instance's own isolated database is **not** the one `mix ecto.migrate` touches by default — it's named `code_my_spec_dev_wc_<working-copy-id-prefix>` (see `~/.codemyspec/app-instances/<id>/state.json`'s `database` field). Fix is:
```
DATABASE_NAME=<that database> MIX_ENV=dev mix ecto.migrate
```
then `restart_app`. `.code_my_spec/qa/plan.md`'s existing "run pending migrations" section doesn't mention this per-worktree DB naming — flagged separately as a docs gap.
