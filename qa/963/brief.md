# QA Brief — Story 963: A main agent runs my project and explains it to me

## Tool

`web` for every page, `curl` against `http://localhost:4004/mcp` for
`start_agent` / `stop_agent`, which have no web control.

## Auth

Magic link, port 4000. There is no password field.

- Open `http://127.0.0.1:4000/users/log-in`
- Fill `user[email]` with `qa@codemyspec.local`, submit `#login_form_magic`
- Read `http://127.0.0.1:4000/dev/mailbox`, take the newest message **whose
  recipient matches** — the mailbox is shared and the top one is often
  somebody else's — and visit its `/users/log-in/:token` link

Clear cookies before switching users. A logged-in session turns the login page
into a re-authentication form whose email field is readonly, and a fill against
it fails in a way that looks like a broken selector.

For MCP, no login: `X-Harness-Id` from `.cms_harness.json`, `initialize`, then
the `notifications/initialized` notification, then `tools/call`.

## Seeds

```
mix run priv/repo/qa_seeds.exs
```

**The base seeds are not enough for this story and that is the main thing to
get right before testing.** Everything here is about a *running* main agent,
which needs three things at once:

1. **A provider on the testing user.** `qa@codemyspec.local` holds an `openai`
   integration (ChatGPT). Without one, `ensure_main_agent/1` refuses with
   `:not_connected` before any agent exists.
2. **A main working copy that a harness is actually serving.** An agent in a
   root no harness holds records `:starting` and is never confirmed — an
   honest state, and useless for asking the agent anything.
3. **That copy must not be the checkout you are working in.** A main agent
   edits files in its root.

The checkout prepared for this run is
`/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox` — a
real Phoenix app with `lib/` code, disposable, registered to project
`708492f9-454e-482f-a2eb-be64f0356b87` as working copy `c75f9ad9`. Its stale
config is at `.cms_harness.json.stale`; the live one was minted by
`mix cms.harness.onboard <path>`, which **crashes after minting** (issue
`ec56e75c`) — the id and the row land before it dies, so check for them rather
than trusting the exit code.

A harness picks a root up on first contact. To make it serve one:

```
curl -s -X POST http://localhost:4004/api/hooks/session_start \
  -H 'content-type: application/json' \
  -d '{"cwd":"<root>","session_id":"qa963","hook_event_name":"SessionStart"}'
```

The reply is an error about the hook name; ignore it. Confirm with
`curl -s localhost:4004/health` — the root should appear with
`"connected": true`.

## What To Test

**Finding the agent** — `/app/projects/708492f9-454e-482f-a2eb-be64f0356b87/agent-conversation`

- Opening the page finds or starts the project's main agent, without anyone
  supplying a provider, a checkout or a role.
- The page names which checkout it is in, so "it runs in the copy you
  designated" can be checked without going elsewhere.
- The status reads as a sentence a non-technical person could follow, not as a
  build log.
- A project with **no** main working copy says so, and says what to do about
  it, rather than failing quietly.

**One main agent, in one place**

- Starting other agents (`start_agent` with any role) does not produce a second
  agent claiming to be the main one.
- A second agent cannot be started in the main checkout — the refusal should
  name the root.

**Designation** — `/app/projects/:id/working-copies`

- A checkout becomes the main one because somebody said so, on that page.
- Naming a *different* copy as main **moves** the agent rather than starting a
  second one. Count agents before and after; this is the criterion most likely
  to look right and be wrong.

**The conversation**

- It survives leaving and coming back — the same transcript, not a new one.
- It survives the agent being stopped and started again.

**What the agent knows** (needs a confirmed, running agent)

- It answers about the code actually in its checkout.
- It answers about the project rather than about a directory.
- Stories it creates appear in the project, not only in the chat.
- A subagent's work reports back through it.
- It hands over rather than designing.
- It can check work rather than take somebody's word for it.

## Result Path

`.code_my_spec/qa/963/result.md`

## Setup Notes

Requires a server restarted since `68579640`.

Tear down what the run starts: every agent stopped, and the main working copy
put back to
`/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator`
at the end. Re-designating is itself one of the criteria, so the restore and
the test are the same action — do it deliberately and record what it showed.

The distinction this story turns on, and the one to hold on to while testing:
`agents.role` defaults to `"main"`, so every agent ever started carries that
word. What makes *the* main agent unique is **where it is** — the checkout the
project designated. A test that checks the role rather than the copy will pass
on an agent that is not the one being talked about.
