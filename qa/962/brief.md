# QA Brief — Story 962: I can watch a background agent work and talk to it

## Tool

web

The story's surface is `CodeMySpecWeb.AgentConversationLive` and
`CodeMySpecWeb.WorkingCopyLive.Show`, both on the `:browser` pipeline of the
hosted endpoint at `http://127.0.0.1:4000`. Vibium drives them.

Two supporting surfaces are reached with `curl` against the local MCP forward
at `http://localhost:4004/mcp`, because the app has no UI for either and the
story's preconditions need both:

- `start_agent` / `stop_agent` — there is deliberately nothing on the working
  copy page that ends an agent (story 1019 keeps a criterion about that), so
  the lifecycle is driven through the agent's own MCP surface.
- `list_agents` — to read back the ids the page is showing.

Both calls carry `X-Harness-Id`, which is what scopes them to this checkout.

## Auth

The harness id every `curl` below needs:

```
ID=$(grep -o '"harness_id"[[:space:]]*:[[:space:]]*"[^"]*"' .cms_harness.json | head -1 | cut -d'"' -f4)
```

Browser login is the magic link, as the account that owns project
`708492f9-454e-482f-a2eb-be64f0356b87` — the project this harness serves. The
QA fixture user is not a member of it, and this story's whole subject is an
agent running on a working copy the harness is actually serving, so a fixture
project with no harness behind it cannot exercise a single criterion.

1. `http://127.0.0.1:4000/users/log-in` → fill `input[name="user[email]"]`
   with `johns10@gmail.com` → click "Email me a login link".
2. `http://127.0.0.1:4000/dev/mailbox` → open the **newest** message. The
   mailbox is shared with every other QA run on this box, so an older link
   logs in as somebody else.
3. Rewrite the link's origin from `https://dev.codemyspec.com` to
   `http://127.0.0.1:4000` before navigating. Following it as-is leaves the
   local app.
4. Persist with `browser_storage_state`.

## Seeds

No seed script. The preconditions are made through the app's own surfaces,
which is the point — every one of them is a thing the story claims a user can
do.

Both servers must be on the commit under test. `just refresh` moves the
:4000 server and restarts the harness; `curl -s localhost:4004/health` prints
the build both are on, and `degraded: false` with this checkout's root in
`projects` is the precondition.

Two agents, on the checkout the harness is serving:

```
curl -s -X POST http://localhost:4004/mcp -H "Content-Type: application/json" -H "Accept: application/json, text/event-stream" -H "X-Harness-Id: $ID" -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"start_agent","arguments":{"provider":"openai-codex"}}}'
```

`openai-codex` because it is the credential this box actually has —
`codex login` was completed here and `Provider.options/3` falls back to
`~/.codex/auth.json`. A `zai` agent needs an API key that is not on this
machine, and an agent that cannot reach a provider proves nothing about
watching one work.

Teardown: `stop_agent` every id started, and confirm through `list_agents`
that none is left running. An agent left up spends a subscription for as long
as nobody notices.

## Scenarios

### 1. Two agents on one copy are two conversations (2892)

Start a second agent with the same call. Then visit
`http://127.0.0.1:4000/app/projects/708492f9-454e-482f-a2eb-be64f0356b87/working-copies`
and open this checkout's copy.

Expect: the Transcript section lists **two** "Open … chat" links, one per
agent, each naming its role. Follow both and confirm the two URLs differ and
each page shows only its own agent's turns.

Fails if: one link, or two links to the same conversation, or a page showing
both agents' turns interleaved.

### 2. I watch the work arrive (2893)

On one agent's conversation page, type
`list the files in this directory and tell me how many there are` into the
send box and submit. Do not reload.

Expect: the agent's steps appear on the page while it is still working — tool
calls first, the answer after — with no reload.

Fails if: the page stays empty until the turn ends, or stays empty entirely.

### 3. I redirect an agent without a terminal (2895)

Same page, immediately after scenario 2 settles. Send
`say READY and nothing else`.

Expect: the message appears in the transcript as sent, and the agent's answer
appears below it in the same conversation. Reload the page and confirm both
are still there.

Fails if: the message is recorded and nothing comes back — the exact failure
this story exists to fix, where the box looks like it worked and the agent was
never told.

### 4. Something I said mid-turn is not dropped, and can be taken back (2897, 2900, 2901)

Send a long instruction — `count slowly from 1 to 40, one line each` — and,
while it is still running, send a second: `also say BANANA when you are done`.

Expect: the second is accepted and shown as **waiting**, with a control to
take it back.

Then, in two separate runs:

- **2900** — click "Take it back" while the first turn is still going. Expect
  the pending row to clear, and expect the agent's later output to never
  mention the withdrawn message.
- **2901** — let the first turn finish first, then click "Take it back".
  Expect to be told it has already been delivered, and expect nothing on the
  page to describe it as withdrawn.

Fails if: the second message is silently refused while the agent is busy, or
disappears without being delivered, or a withdrawal after delivery reports
success.

### 5. The send box does not accept what it cannot deliver (2898)

`stop_agent` one of the agents, then reload its conversation page.

Expect: no send box, and a line saying the agent is not running.

Fails if: the box is still offered, or typing into it records a message.

### 6. What it did outlives it (2899)

Same page as scenario 5, after the stop.

Expect: everything the agent did is still readable, and the page makes clear
the agent is no longer running.

Fails if: the conversation is gone, empty, or indistinguishable from a running
agent's.

### 7. A message that could not be delivered says so (2896)

Stop the harness's process for this checkout while an agent row still says
running — `just refresh-harness` restarts it, and there is a window
immediately after where the server has an agent row and no machine behind it.
Send a message in that window.

Expect: a message saying it could not be delivered, naming the machine as
unreachable, and **no** new message in the transcript.

If the window cannot be caught reliably, say so in the observation rather than
claiming the scenario passed — an untested criterion reported as tested is
worse than an admitted gap.

### 8. A turn that fails still shows what it did first (2894)

Best effort. Send an instruction whose first step succeeds and whose second
cannot — `read mix.exs, then read /nope/does/not/exist.ex` — and watch what
the transcript holds after the failure.

Expect: the successful step is still on the page after the turn goes wrong.

Fails if: the transcript loses everything the agent did once the turn fails.

## Result Path

`.code_my_spec/qa/962/result.md`

## Setup Notes

- **Both servers must be on the commit under test.** The :4000 server and the
  harness both run from the *main* checkout, not from this worktree, so code
  committed and pushed here is absent from every response until `just refresh`
  has moved them. `curl -s localhost:4004/health` prints the build.
- **The channel contract moved to v2** in this change. A harness on the old
  build is refused at join with `contract_version_mismatch` — which is the
  designed signal, not a fault. `just refresh` restarts both halves together.
- **Screenshots** land in `~/Pictures/Vibium/<basename>`; copy them into
  `.code_my_spec/qa/962/` at the end.
- **Do not leave agents running.** Every agent started here spends a real
  ChatGPT-plan quota until it is stopped.
