# QA Brief — Story 985: I can see what the orchestrator did to my agent

## Tool

`web` for the transcript, plus `curl` against the harness hook on :4004 to make
the orchestrator actually do something. The page is the claim; the hook is what
produces the thing being claimed about.

## Auth

Magic link, port 4000, no password field.

- `http://127.0.0.1:4000/users/log-in`, fill `#login_form_magic_email` with
  `qa@codemyspec.local`, submit `#login_form_magic > button`
- `http://127.0.0.1:4000/dev/mailbox` holds one message at a time; pull the
  `/users/log-in/:token` link out of
  `/dev/mailbox/<id>/html` and follow it against `127.0.0.1:4000`

Target project: `708492f9-454e-482f-a2eb-be64f0356b87`.

For the hook, no login: `X-Harness-Id` from the checkout's `.cms_harness.json`.

## Seeds

None. What this story needs is an agent with a conversation and an orchestrator
that acts on it, and both are made by using the product:

1. `start_agent` over `:4004/mcp` puts a Pi agent on a checkout and opens its
   conversation.
2. `POST :4004/api/hooks/stop` with that checkout's harness id makes a real stop
   decision.

**Stop every agent you start.** Check `agents where status in
('running','starting')` at the end rather than trusting that you did.

## What To Test

- **The action is there at all** — start an agent, fire a stop hook against its
  checkout, open its transcript. There must be a
  `[data-test="orchestrator-action"]` entry. This is the story's whole premise
  and the thing most likely to work in a spex and not in the app: the spex build
  their own scope, and the running system resolves one from a header.

- **One decision is one entry (3034)** — a stop runs several analyzers. Count
  `[data-action-kind="decision"]` entries after one stop. Exactly one. Then count
  *all* `[data-test="orchestrator-action"]` entries and satisfy yourself that any
  extras are different acts rather than repeats of the decision — a nudge about
  an open task is a second act and not a second decision.

- **The count and the tool (3035, 3036)** — the action must carry a number and
  the name of a tool, and must not carry a link to a problems page. Check the
  action's own markup, not the page's: the sidebar has a Problems link and
  always will. An earlier version of the spex failed on exactly that and it was
  the assertion that was wrong.

- **Not the agent's doing (3037)** — the entry must not render as a tool call and
  must not carry `data-role="assistant"`. Read the surrounding markup: does a
  person scrolling this transcript come away thinking the agent chose to stop?

- **A requirement handed over (3038)** — call `start_task` for a requirement the
  agent has not already been given, with `agent_id` set to that agent. An entry
  should appear naming the requirement. Then call it *again* for the same
  requirement: there must **not** be a second entry, because re-reading the
  prompt for an active task is not a hand-over.

- **The nudge, and what must not happen (3039)** — give the agent a task, then
  fire the stop hook without completing it. The transcript must tell the agent to
  close it and name `evaluate_task`. Then check the task's status in the
  database: it must still be open. Nothing may complete work on the agent's
  behalf — that is the decision John made, and the failure mode is that the
  system quietly does it anyway.

- **The empty case** — an agent with no orchestrator activity must render a
  transcript with no orchestrator entries and no blank ones. A renderer that
  draws an empty card for a missing count is worse than one that draws nothing.

## Result Path

`.code_my_spec/qa/985/result.md`

## Setup Notes

**I wrote the implementation and the spex for this story in the same session, so
treat a green spex as weak evidence here.** The specific risk is a spex that
passes because it and the code agree with each other rather than because the
product works: three of these spex failed for reasons that were faults in the
spec rather than the feature, and each time the fix made them agree with the code
I had already written. What QA adds is a reader who did not write either.

Look hardest at two things:

1. **Whether the action reaches the transcript in the running app.** Every spex
   builds its own scope; the app resolves one from `X-Harness-Id`. That gap has
   already produced one silent no-op in this story — the recorder is deliberately
   quiet for an agent with no conversation, which means "nothing recorded" and
   "nothing to record against" look identical from the page.

2. **Whether anything completes a task for the agent.** The whole of 3039 turns
   on the orchestrator *not* doing something, and an absence is the easiest thing
   for a spec to assert wrongly.

Requires a server and harness on `5f6dc226` or later.
