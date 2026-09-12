# QA Brief — Story 1017: The main agent looks in on its agents on a cadence

## Tool

`mcp__plugin_codemyspec_local__*` (MCP tools on the local server), plus `curl` for `:4004` probes

## Auth

No auth. The local endpoint on `:4004` is `LocalOnly` and takes project scope from
the harness id, which this session already carries. MCP tools are called directly:

```
mcp__plugin_codemyspec_local__run_script   # for ScriptableTools (list_open_questions, check_machinery, …)
mcp__plugin_codemyspec_local__tap_out      # spine tool, called directly
```

Health probe, to confirm which build is answering before trusting anything:

```
curl -s http://localhost:4004/health
```

## Seeds

None. This story is about the *running* fleet, so the live state is the fixture —
eight checkouts on this machine, seven connected, four analyzers reporting. Seeding
synthetic agents would test the seed rather than the cadence.

Where a criterion needs a state the live fleet does not happen to be in (an agent
gone silent, a digest that cannot be assembled), say so and mark the scenario
unobserved rather than manufacturing it. Manufacturing state here would test the
fixture, and the criterion is about production behaviour.

## What To Test

Surface note, established before testing: of this story's nine criteria, only three
have an agent-facing surface. `check_in`, `cadence_interval`, `set_cadence_interval`
and `stand_down` are context functions with no MCP tool bound — confirmed by
enumerating the bound tool names in the code-mode sandbox. The spex reach them
through the Fixtures bridge, which is in-process and not a QA surface.

- **The main agent comes back round on its own** — re-test of issue 96626683
  (fixed in b7ea25060): a project that gains its first continuous agent while
  the server is already up must end up with a running cadence, not just one
  that had it at boot. Do **not** flip a real agent's continuous flag to force
  this — it rings the agent's bell. Instead use the throwaway QA Fixture
  Project's own sandbox working copy (harness id
  `1fc425f5-7b88-4e32-86a3-c16c3317408c`, 0 live agents on it) via the same
  `POST http://localhost:4004/mcp` handshake `qa_code_mode.sh` uses, sending
  `X-Harness-Id: 1fc425f5-7b88-4e32-86a3-c16c3317408c`: call `cadence({})`
  (expect `running: no`), then `set_working_copy_loop({working_copy_id =
  "1fc425f5-7b88-4e32-86a3-c16c3317408c", working = true})` (0 agents match,
  so nothing is put to work — safe no-op on the work side), then `cadence({})`
  again (expect `running: yes`).
- **The interval is set rather than assumed** — determine where a set interval is
  stored and whether it survives a restart. Expected: durable, per-project.
- **A pushed question does not wait for the next check-in** — call
  `list_open_questions`. Expected: a question raised now is visible now.
- **An agent that went silent is caught by the check-in** — call `list_agent_work`
  and compare against the live fleet from `check_machinery`.
- **A quiet check-in does not become a notification** — with nothing wrong, confirm
  no notification is raised.
- **The wake-up says what is going on** — inspect the digest content.
- **A digest that cannot be assembled is not delivered as an empty one** — needs a
  broken digest source; no external way to induce it. Expect unobserved.
- **Everybody is through their work and the main agent stands down** — `tap_out`.
- **Tapping out does not make the main agent unreachable** — after `tap_out`,
  confirm a question still reaches the main agent via `list_open_questions`.

## Result Path

DB-backed attempt via `mcp__plugin_codemyspec_local__submit_qa_result`; findings via
`create_issue`. No `result.md` — the harness does not read one.

## Setup Notes

Verify the harness build matches the checkout before testing. This session began
with the harness on `1555655bf` while the checkout was on `a391b2af0`, which made
every MCP task tool fail in a way that reads as a session problem rather than a
version skew. `curl -s http://localhost:4004/health` reports the build; it must
match `git rev-parse --short main`.
