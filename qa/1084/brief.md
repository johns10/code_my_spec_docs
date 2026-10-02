# Qa Story Brief

## Tool

web

## Auth

Browser session via magic link — `qa@codemyspec.local` is passwordless (GitHub/Google/magic-link only, no password form):

1. Navigate to `http://127.0.0.1:63811/users/log-in`
2. Fill `input[name="user[email]"]` with `qa@codemyspec.local`, click "Email me a login link"
3. Navigate to `http://127.0.0.1:63811/dev/mailbox`, open the newest message to `qa@codemyspec.local`, copy the login link
4. The link is minted against `https://dev.codemyspec.com/users/log-in/<token>` — rewrite the origin to `http://127.0.0.1:63811` before navigating, or you leave this worktree's app entirely
5. Lands on `/app`. Single-use token — repeat from step 1 for a second login.
6. Immediately after login, fix the active account/project (this seed user belongs to several stale QA accounts and session login lands on an arbitrary one):
   - `http://127.0.0.1:63811/app/accounts/picker` → choose "QA Account"
   - `http://127.0.0.1:63811/app/projects/picker` → choose "QA Fixture Project"

Component/dependency/sync setup (done via `run_script` + `call_mcp_server`, not the browser — there is no hosted LiveView UI for authoring components, only the MCP surface) uses this reusable bearer token for `johns10@gmail.com` (a member of QA Account, minted 2026-10-02T21:49:20Z, expires in 43200s / 12h):

```
Authorization: Bearer 6ec378ef5adfac747a83bbdb077a235f27c50c2feb979cb9d8365c613cf67b00
X-Project-ID: 11111111-1111-4111-8111-111111111111
```

against base URL `http://127.0.0.1:63811`, paths `/mcp/components` (`create_component`, `add_dependency`) and `/mcp/harness` (`sync_project`). Example:

```lua
return call_mcp_server({
  url = "http://127.0.0.1:63811",
  path = "/mcp/components",
  tool = "create_component",
  arguments = { name = "Billing", module_name = "Billing", type = "context" },
  headers = {
    Authorization = "Bearer 6ec378ef5adfac747a83bbdb077a235f27c50c2feb979cb9d8365c613cf67b00",
    ["X-Project-ID"] = "11111111-1111-4111-8111-111111111111"
  }
})
```

If the token has expired, mint a fresh one — **against this worktree's own database**, not the shared one:

```
psql -qtA code_my_spec_dev_wc_7e342ada -c "select token from oauth_access_tokens where resource_owner_id=1 and revoked_at is null order by inserted_at desc limit 1;"
```

This worktree's own Postgres DB is `code_my_spec_dev_wc_7e342ada`, confirmed via the running server's env (`lsof -nP -i :63811` → PID → `ps -E -p <pid> -ww | tr ' ' '\n' | grep DATABASE_NAME`). Querying the default `code_my_spec_dev` instead silently returns a different working copy's state (it has the same fixture rows, from a stale clone, but a different `local_path` and different components).

## Seeds

From this worktree's root (NOT `mix run` — that boots a second endpoint and 500s the one already serving :63811):

```
mix cms.seed priv/repo/qa_seeds.exs
```

Idempotent, touches only the database. Creates/confirms `qa@codemyspec.local`, the `QA Account` / `QA Fixture Project` (id `11111111-1111-4111-8111-111111111111`), and — the part that matters for this story — repoints the project's `local_path` to `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox` (the sandbox directory you have write access to; it currently points at a stale path under a different checkout's `.claude/worktrees/`, left by a prior session on a different working copy). Confirm the repoint landed:

```
psql -qtA code_my_spec_dev_wc_7e342ada -c "select local_path from projects where id='11111111-1111-4111-8111-111111111111';"
```

should print the `code_my_spec_test_repos/qa_sandbox` path, not a `.claude/worktrees/...` one.

No `Billing` / `Accounts` / `Notifications` / `Billing.Invoice` components exist yet in this project (checked 2026-10-02) — the scenarios below create them fresh.

## What To Test

Setup is layered — each criterion builds on the previous one's state, same component set throughout. For every `create_component` / `add_dependency` / `sync_project` call use `run_script` + `call_mcp_server` per the Auth section above. For every file write use the `write` tool against `/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox/`.

**Criterion 1725 — Sam sees a call between components that was just added**
- `create_component`: `Billing` (type `context`), `Accounts` (type `context`).
- Write `qa_sandbox/lib/billing.ex`:
  ```elixir
  defmodule Billing do
    @moduledoc false
    alias Accounts
  end
  ```
- `sync_project`.
- Navigate to `http://127.0.0.1:63811/app/projects/11111111-1111-4111-8111-111111111111/architecture/overview`.
- Expect: Billing's section lists Accounts with a marker containing "in code".

**Criterion 1726 — a call removed from the code is gone from the view**
- Overwrite `qa_sandbox/lib/billing.ex`, dropping the alias:
  ```elixir
  defmodule Billing do
    @moduledoc false
  end
  ```
- `sync_project` again.
- Reload the overview page.
- Expect: Billing's section still renders (still mentions it is a context) but no longer mentions Accounts anywhere.

**Criterion 1727 — Sam tells planned from actual at a glance**
- `create_component`: `Notifications` (type `context`).
- `add_dependency` Billing → Accounts (planned only — the code call was removed in 1726).
- Write `qa_sandbox/lib/billing.ex`:
  ```elixir
  defmodule Billing do
    @moduledoc false
    alias Accounts
    alias Notifications
  end
  ```
- `sync_project`.
- Reload the overview page.
- Expect: Billing → Accounts marked both "planned" and "in code"; Billing → Notifications marked "in code" only, not "planned".

**Criterion 1728 — calls inside a context don't show as dependencies**
- `create_component`: `Billing.Invoice` (type `schema`, `parent_component_id` = Billing's id).
- Write `qa_sandbox/lib/billing.ex`:
  ```elixir
  defmodule Billing do
    @moduledoc false
    alias Billing.Invoice
    alias Accounts
    alias Notifications
  end
  ```
- `sync_project`.
- Reload the overview page.
- Expect: Billing's section never mentions "Invoice", but still shows Accounts and Notifications as dependencies.

After the four scripted scenarios, explore freely: a component with zero code dependencies, `sync_project` called before any components exist, and the Dependency Graph / Namespace Hierarchy tabs on the same page (not this story's criteria, but worth a glance for regressions).

## Result Path

.code_my_spec/qa/1084/result.md

## Setup Notes

- Per `qa_story/workflow.md`, findings go through `create_issue` the moment they're found, and the run closes with one `submit_qa_result` call (task id `68419648-9058-4fc6-a348-15e7708b4ccc`). This result path is for screenshots/evidence only, not a substitute for that.
- `browser_screenshot` always writes to `~/Pictures/Vibium/<basename>` regardless of the `filename` path given — copy anything worth keeping into `.code_my_spec/qa/1084/screenshots/` with a `63811_` prefix.
- Dependency markers render as parenthetical text next to the target module's name inside each component's prose section (e.g. "Accounts (planned, in code)") — read with `browser_get_text` rather than relying on exact HTML structure.
- Story 1084 is CodeMySpec testing its own Architecture feature; the "project under test" is the QA Fixture Project, never this worktree's own CodeMySpec codebase. Don't write scenario files into this worktree's own `lib/`.
