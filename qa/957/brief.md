# Qa Story Brief — 957: I can see my working copies and what is running on each

## Tool

web

## Auth

Hosted app, port 4000, magic-link only (no password field).

1. `http://127.0.0.1:4000/users/log-in` → fill `user[email]` with `johns10@gmail.com` → click "Log in with email".
2. Read `http://127.0.0.1:4000/dev/mailbox`. **This mailbox is shared across QA sessions** — match the message to `johns10@gmail.com` specifically rather than taking the newest entry, or you log in as someone else's QA user.
3. Follow the login-link token to `/users/log-in/:token` on `127.0.0.1:4000` (rewrite the origin if the link was minted against a different host).

Target project: `708492f9-454e-482f-a2eb-be64f0356b87` (sidebar: Build → "Working copies").

## Seeds

No seed script. Working copies come into existence when a harness joins for the project; nothing fabricates them. This project already has 100+ real harness rows across several git worktrees of this repo, so two distinct checkouts exist without any setup.

**Simulating agents.** `Agents.list_running/1` is a plain DB query over `Agent.status in [:starting, :running]`, and `Agents.start_agent/2` writes a row, mints a Pi config dir and opens the conversation — it does **not** spawn an OS process. So the MCP `start_agent` tool is the lever for putting an agent on a copy. Drive it against the local MCP endpoint on **4004** (not the published-binary 4003), single-line curl:

```
curl -s -X POST "http://127.0.0.1:4004/mcp?harness=<HARNESS_ID>" -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"start_agent","arguments":{"provider":"openai-codex","engine":"pi"}}}'
```

- Only `openai-codex` has a connected credential on this account; `anthropic` and `zai` refuse with `:not_connected`.
- `engine` is `"pi"` (default) or `"claude_code"`. `working_copy` defaults to the caller's own checkout; set it explicitly to another already-joined harness root to put an agent on a different copy.
- `stop_agent` (`arguments: {"agent_id": "<id>"}`) tears one down. **Always stop what you start.**
- Harness ids: `psql -qtA code_my_spec_dev -c "select id, root from harnesses where project_id='708492f9-454e-482f-a2eb-be64f0356b87';"`, or read `.cms_harness.json` at a checkout's root.

## Setup Notes

**The surface is three pages, not one.** An earlier version of this brief described a single index page carrying an inline rename input and an inline transcript with a reply box (`[data-test=rename]`, `[data-test=open-transcript]`, `[data-test=agent-reply]`). That UI no longer exists and those selectors match nothing. As of commit `234f8471` the surface is:

| Page | Route | Module |
|---|---|---|
| Index | `/app/projects/:pid/working-copies` | `WorkingCopyLive.Index` |
| Show | `/app/projects/:pid/working-copies/:harness_id` | `WorkingCopyLive.Show` |
| Rename | `/app/projects/:pid/working-copies/:harness_id/edit` | `WorkingCopyLive.Form` |

The index is **read-only** — every row offers exactly `View` and `Rename`, both `navigate` links. Renaming is its own route. Talking to an agent is `AgentConversationLive.Show`, reached from the Show page's "Open agent chat" button; there is no second transcript inlined anywhere.

Current selectors: `[data-test=working-copy][data-root=...]`, `[data-test=working-copy-id]` (first 8 chars of the harness id), `[data-test=liveness]`, `[data-test=liveness-since]`, `[data-test=liveness-basis]`, `[data-test=agent-chip][data-engine=...]`, `[data-test=open-working-copy]`, `[data-test=view-working-copy]`, `[data-test=edit-working-copy]`. On Show: `[data-test=working-copy-show]`, `[data-test=agent][data-engine=...]`, `[data-test=agent-liveness]`, `[data-test=open-agent-chat]`, `[data-test=no-agent-chat]`, `[data-test=no-agents]`. On the form: `#working_copy_label`, `[data-test=save]`.

**Liveness wording** is `Running` / `Last heard from` / `Idle`, each with a `basis` clause underneath. The word "Present" is not used anywhere — a brief or result asserting it is testing an older build.

**The `:4000` server runs from the main checkout** (`/Users/johndavenport/Documents/github/code_my_spec`), not from a worktree. Read the source you are testing from there, and re-check it mid-run — this surface has been under active edit.

**Reconciliation is edge-triggered.** `LaneReporter` reports only on a Presence diff; there is no timer and no reconcile on mount. An agent row created by `start_agent` with no lane behind it is never reaped, so it will sit on the page as "Running" until you stop it. Budget for cleanup; do not assume it ages out.

## What To Test

- **2830 — live Pi vs quiet Claude don't look alike:** put a `pi` agent on one checkout and a `claude_code` agent on another, then read `[data-test=liveness]` on each row. Pi must read `Running` with basis "present on the harness channel"; Claude Code must read `Last heard from` with basis "HTTP hooks only — recency, not presence". Neither row's text may contain the other's verdict. Check the `[data-test=agent-chip]` engine names differ too (`main · Pi` vs `main · Claude Code`).
- **2831 — a dead Pi agent stops being present immediately:** with the index already mounted (not a fresh load), `stop_agent` the Pi agent from a separate call. Without reloading, the row's liveness must leave `Running`/`present`, the agent chip must go, and the working-copy row itself must still be listed — only the agent went, not the checkout.
- **2832 — both checkouts are there, one idle:** confirm both agent-bearing rows are listed at once, and that copies with no agent render `Idle · no agent reported on this copy` rather than blank space.
- **2833 — talking to the Pi agent reaches it:** from the Pi copy's Show page click `[data-test=open-agent-chat]`, then fill and submit the message form on `AgentConversationLive.Show`. The message must appear in the transcript. Verify it was stored in the form the channel relays: `psql -qtA code_my_spec_dev -c "select role, content::text from conversation_messages where content::text like '%<your text>%';"` must return role `operator` — `HarnessChannel` matches `%Message{role: :operator}` to push down as `user_message`, so an `assistant`-roled write would look sent and reach nobody.
- **2834 — a Claude Code copy offers no box:** on the Claude Code copy's Show page, `[data-test=open-agent-chat]` must be absent and `[data-test=no-agent-chat]` present. Count inputs/forms inside `[data-test=working-copy-show]` — must be zero.
- **2835 — two checkouts told apart at a glance:** this project has three harness rows sharing the root `/Users/johndavenport/Documents/github/code_my_spec` with identical labels. Confirm `[data-test=working-copy-id]` renders a distinct 8-char id on each, then rename one via `/edit` and confirm the index shows the new name. Also exercise the documented clear path: a whitespace-only name must store `NULL` (`normalize_label` trims), and the copy falls back to its root. **Restore the original label afterwards.**
- **2836 — an agent nobody is running is not listed as running:** two directions, and they behave differently.
  - *Reaped after a report* — `stop_agent` an agent with the index mounted; the row must leave `Running` and say `Idle`, not go blank. This passes.
  - *Never started* — call `start_agent` and leave it. The row claims `Running · present on the harness channel` indefinitely for a lane with no `os_pid`, `status = :starting`, that never joined a channel. This fails; see issue `fcd8f7ba`. The spex's own rule states the broader requirement: the page's claim "has to come from the harness's claim, not from what the server remembers asking for".
- **2837 — nothing here ends anything:** with agents actively shown running, confirm zero `[data-test=stop-agent]` and zero `[data-test=stop-harness]` anywhere on index and Show, and that no row control reads stop/kill/terminate/shut down/delete. The only per-row actions are View and Rename.
- Screenshot each key state into `.code_my_spec/qa/957/screenshots/`.

## Result Path

No result.md — findings go through `create_issue`; the session ends with one `submit_qa_result` call.
