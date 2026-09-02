# QA Brief — Story 987: Analysis results reach the agent running inside our own BEAM

## Tool

curl

## Auth

The story's user is an agent, not a person, so there is no page to log into.
Every call goes at the MCP endpoint carrying a working copy's own id.

**Use a disposable working copy, not a live one.** A QA agent's typed
`mcp__plugin_codemyspec_local__*` tools are bound to whichever harness its own
session serves — in a worktree of this repo that is the real dev harness, and no
parameter redirects a call. Issue `08d4d7bd`. Only curl with an explicit
`X-Harness-Id` isolates, and this story needs a *writable* working copy because
a finding has to land in it.

Mint one:

    /Users/johndavenport/Documents/github/code_my_spec/.code_my_spec/qa/scripts/qa_agents.sh up 1
    /Users/johndavenport/Documents/github/code_my_spec/.code_my_spec/qa/scripts/qa_agents.sh touch 1

`up` prints the root and the server-issued harness id. Hold that id — it is the
`X-Harness-Id` for every call below, and using any other one tests the wrong
checkout.

    curl -sS -X POST "$SERVER/mcp/harness" \
      -H "content-type: application/json" \
      -H "X-Harness-Id: $QA_HARNESS_ID" \
      -H "Authorization: Bearer $CMS_TOKEN" \
      -d '{...}'

`CMS_TOKEN` as `qa_agents.sh` resolves it: `CMS_TOKEN`, then `CMS_DEPLOY_KEY`,
then whichever is in `envs/.env`.

### The model credential

The agent runs on a real provider, from the database rather than a fixture.
`Agents.Credential.fetch/2` reads `Integrations` for the scope's user, so an
agent started with `provider: "openai"` picks up the stored token with no extra
plumbing. Two are live:

    user 14  qa@codemyspec.local   expires 2026-09-05
    user 1   johns10@gmail.com     expires 2026-09-12

Prefer the QA account. John's is the fallback if the QA one has lapsed — his
words, that these are free to use on the harness.

## Seeds

Base seeds, only with the dev server stopped:

    mix run priv/repo/qa_seeds.exs

Story-specific, and the part that matters: a finding has to exist in the
disposable copy before the agent is asked to do anything, because the alert is
about a landing. There is no page for that — post analyzer output the way the
harness does, against the disposable copy's id:

    curl -sS -X POST "localhost:4004/api/harnesses/$QA_HARNESS_ID/analysis/run" \
      -H 'content-type: application/json' -d '{"source":"credo"}'

If the disposable copy has nothing to find, write one broken file into its root
first — `qa_agents.sh up` prints it — and re-run. Confirm the finding landed
before testing delivery, or a silent result reads as the feature failing when
the premise never held:

    psql -qtA code_my_spec_dev -c \
      "select source, count(*) from problems where working_copy_id='$QA_HARNESS_ID' group by 1;"

## What To Test

Each maps to one acceptance criterion. The surface is the agent's own tool
result — start it, make it call something, read what comes back.

- **An Alloy agent is told its own turn broke something.** With a finding
  outstanding in the disposable copy, start an agent on it (`start_agent`,
  `provider: "openai"`), then message it so it makes a tool call. The reply
  should carry a line naming the analyzer, a count and an age. Expect
  `credo: N failing in this working copy, as of Xs ago. list_problems for detail`.
- **The same landing produces the same words for either agent.** Against the
  same landing, POST `/api/hooks/post-tool-use` with a `session_id` and compare
  its `systemMessage` to what the agent got. The two should agree — assert they
  match each other, not a phrase, so a reworded alert does not read as a defect.
- **A clean run says nothing to either agent.** Mint a second disposable copy
  with nothing broken, start an agent, message it. The reply should carry no
  alert at all. This is the criterion most likely to regress quietly.
- **An agent that fires no hooks is still told.** Same as the first, and the
  thing to check is that no hook was involved: the disposable agent has no
  Claude Code session, so nothing could have fired `PostToolUse` for it.
- **Being told does not silence the other agent.** Fire the hook first for an
  external session, then message the Alloy agent. It must still be told. Then
  the reverse order. Dedup is per agent — issue `927c2b78` is this exact bug on
  the external side and it shipped, so test both directions.
- **A stopped agent is a stopped agent, not a lost message.** Stop the agent
  (`stop_agent`), then land another finding. Nothing should be delivered and
  nothing should be logged as an error — check `~/.codemyspec/web.log` for the
  window. "Nobody to tell" is a state, not a fault.
- **Being alerted mid-work does not cost the agent its stop decision.** After
  the agent has been alerted, confirm the findings are still outstanding — ask
  again from another surface and see them. The alert must not consume them. The
  full interaction with an internal stop decision belongs to story 988, which
  has no turn-end seam yet; do not fail 987 for it.

## Result Path

`.code_my_spec/qa/987/result.md`

## Setup Notes

**Tear down by root, deliberately.** `qa_agents.sh down` removes the scratch
directories and leaves the server rows, and a retired copy's file rows keep
components alive for every other agent — issue `3c6b6b63`, which cost four days
of a phantom orphan context. After the session:

    psql -d code_my_spec_dev -c \
      "delete from files where working_copy_id in (select id from working_copies where root like '/tmp/cms-qa-agents%');
       delete from working_copies where root like '/tmp/cms-qa-agents%';"

The label does not survive — the server rewrites it once the copy goes live, so
a cleanup keyed on the label matches nothing and reports success. The root is
the stable handle.

**Never point a live agent at a real checkout.** This story needs a broken file
to exist, and the agent has a real model credential and real edit tools. A
disposable root is not tidiness here, it is the only safe place to do it.

**The alert is deduped per agent per landing.** An agent is told once and stays
quiet until the problems move, so a second tool call in the same state answering
nothing is correct, not a miss. To see it again, land a different finding.
