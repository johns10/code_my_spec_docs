# Qa Story Brief — 956: A Pi agent starts in a minted working copy on my own subscription

## Tool

MCP (`mcp__plugin_codemyspec_local__{start_agent,list_agents,stop_agent}`) + `curl` for the
harness channel's HTTP neighbours + `web` (Vibium) for the agent-conversation page.

Three surfaces, because the story has three and the plan says to pick by pipeline
rather than by guess:

- **MCP tools** — `start_agent`, `list_agents`, `stop_agent` are the engineer's
  entry point. Registered on `LocalServer`, reachable at `4004/mcp`.
- **Harness channel** — `CodeMySpecWeb.HarnessChannel` carries `agents_running`
  and `agent_message`. A websocket is not curl-able, so what QA can check from
  outside is its *effect*: a reported agent appears, and a stopped one does not.
- **Agent conversation LiveView** — `4000/app/projects/:id/agent-conversation`,
  where a started agent has to become visible. This is criterion 2824's whole
  subject and the only genuinely browser-shaped surface here.

## Auth

**Local MCP (4004):** none. `LocalOnly` accepts the loopback address and scope
comes from the harness id, which this session's MCP client already carries. Call
the tools directly.

**Hosted UI (4000):** magic link, per the plan.

1. Navigate to `http://127.0.0.1:4000/users/log-in`
2. Fill `user[email]` with the seeded QA user, click "Log in with email"
3. Read `http://127.0.0.1:4000/dev/mailbox`, take the newest link, visit it

Note from the plan, worth heeding: `/dev/mailbox` is shared, so the newest login
link may belong to another QA session and log you in as the wrong user. Match the
message to the address you just submitted rather than taking the top one.

## Seeds

    mix run priv/repo/qa_seeds.exs

No story-specific seeds. The story's own entities are made through the surface
under test — starting an agent is the thing being tested, so seeding one would
skip the subject.

A provider must be connected for a start to succeed. The account this session's
harness resolves to may have no OpenAI integration, in which case
`start_agent` refusing is the *correct* behaviour and is criterion 2821 rather
than a blocker. Test 2821 first for that reason.

## What To Test

Ordered so the refusals come before the successes — a refusal needs no
credential, and reaching it first proves the tool is wired before anything
depends on a connected provider.

- **Asked for a provider that was never connected (2821).** Call `start_agent`
  with `provider: "openai-codex"` on an account with no OpenAI integration.
  Expect: an error, naming `openai-codex`, telling the reader to connect it.
  Expect NOT: a started agent, a stack trace, or an unnamed "no credential".

- **An unknown provider is refused by name.** Call `start_agent` with
  `provider: "not-a-provider"`. Expect the known-provider list in the message.
  This is not a story criterion; it is the adjacent input a real caller gets
  wrong first.

- **The tool is reachable at all.** Confirm `start_agent`, `list_agents` and
  `stop_agent` appear in the MCP tool list. They were unregistered until this
  session — the spex call `execute/2` directly and never proved reachability.

- **Started, seen, stopped (2827).** With a provider connected: `start_agent`,
  then `list_agents` and expect the agent against its working copy, then
  `stop_agent` and expect it gone from the listing. If two can be started on
  different copies, stop one and confirm the *other survives* — that is the
  assertion a tree-reaping stop would fail.

- **One agent, whichever engine is behind it (2824).** After a start, open
  `http://127.0.0.1:4000/app/projects/<project_id>/agent-conversation` in the
  browser and expect a session row. Screenshot it. This is the acceptance signal
  the whole story is worth doing for: an agent the server cannot observe is
  indistinguishable from one that never started.

- **The credential lands beside the copy, never inside it (2823).** After a
  start, read the `Config dir` line from the tool's reply and confirm on disk
  that it sits outside the working copy and that no `auth.json` or `.pi`
  directory appeared inside the copy. The copy gets committed; a credential in
  it is a scheduled leak.

- **Two tenants on one box (2829).** Confirm the minted config directory path is
  scoped to the account. Reading another account's path should not be possible
  from the tool's output.

- **Free exploration.** Empty listing before anything starts; `stop_agent` with
  an id that does not exist; `start_agent` twice on one working copy.

## Result Path

`.code_my_spec/qa/956/` for screenshots. Findings go to `create_issue` as they
are found; the run ends with one `submit_qa_result`. There is no result.md.

## Setup Notes

**The device-login flow is not in scope for this story.**
`Providers.OpenAI.DeviceAuth` reproduces Pi's ChatGPT login and is tested at the
unit level, but nothing surfaces it yet — no LiveView, no CLI prompt. Connecting
a provider through the UI is therefore not testable here, and its absence is a
gap in a *later* story rather than a defect in this one.

**Two spex assertions cannot be reproduced by hand and are not worth trying.**
Criterion 2828's orphan is arranged by a harness reporting a set that omits an
agent, over a websocket; 2822's expired-but-refreshable credential needs a
stubbed token endpoint. Both are asserted at the contract level. QA's job here is
the surfaces a person or an agent can actually reach.

**Ports.** The local MCP server is on 4004 in this dev checkout, not 4003. The
hosted UI is 4000.
