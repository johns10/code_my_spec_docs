# QA Brief — Story 988: The stop decision reaches the agent running inside our own BEAM

## Tool

`mcp__plugin_codemyspec_local__*` (agent tools: `start_agent`, `message_agent`,
`stop_agent`, `list_agents`), with `psql -d code_my_spec_dev` for reading back
the agent's conversation and `~/.codemyspec/harness.log` for the analysis seam.

The story's surface is the agent lifecycle, which is reached only through the
local MCP server. There is no LiveView for it — the orchestrator's message
lands in an agent's conversation thread, not on a page — so the browser is the
wrong instrument here and `qa/plan.md`'s table routes this to the MCP column.

## Auth

Local MCP on `4004` takes no user auth. Scope comes from the harness id, which
the plugin's MCP mount already carries as `X-Harness-Id`; calling the
`mcp__plugin_codemyspec_local__*` tools from this session needs nothing else.

For the direct HTTP probes below, the harness id is
`6c4a7be3-4e6c-4822-9baa-6db8a702ee6e` (the main checkout — the copy this
session's scope names):

    curl -sS -X POST localhost:4004/api/harnesses/6c4a7be3-4e6c-4822-9baa-6db8a702ee6e/analysis/wait

Postgres needs no credentials on this box: `psql -d code_my_spec_dev`.

## Seeds

No seed script. The bench is a working copy plus a live agent, both created
during the run:

    # the disposable project, which exists so QA can run mix credo without
    # touching the framework's own checkout (see its mix.exs)
    /Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox

Values the tester needs:

- Working copy id: `c75f9ad9-e4e0-47cc-a0ca-3ffc55c99067` (qa_sandbox, project
  *Code My Spec* `708492f9-454e-482f-a2eb-be64f0356b87`)
- Provider: `openai-codex` — John's ChatGPT plan. Flat-rate, so a real turn
  costs nothing per token, and `CmsHarness.Agents.Provider` documents it as
  handling its own credential, so no key is passed.
- Analyzer modes on the project: credo `block_changed`, compile_warnings
  `block`, exunit and spex `block_all`.

Read the delivered message back with:

    psql -d code_my_spec_dev -c "select m.role, m.origin, m.inserted_at, m.content \
      from conversation_messages m join conversations c on c.id = m.conversation_id \
      where c.agent_id = '<agent id>' order by m.inserted_at;"

## What To Test

- **A finished turn puts the analyzers to work.** Start an agent on the
  qa_sandbox copy, send it a message, and let the turn end. Expect
  `harness.log` to show analysis requested for
  `code_my_spec_test_repos/qa_sandbox` with no hook having fired — nothing
  external POSTed `/api/hooks/stop`, so the enqueue can only have come from the
  turn ending.

- **One landing, one set of words.** Have the agent write a module with no
  `@moduledoc` (credo is `block_changed`, so the agent must touch the file
  itself or the finding will not block and the scenario proves nothing).
  Expect an orchestrator message in its conversation carrying the problem
  summary and the directive — the same sentences `Hooks.Stop` renders for an
  external agent, not a paraphrase.

- **The answer arrives when it exists.** Expect the message to land *after*
  the analysis run completes, and expect no text anywhere in it telling the
  agent to `curl .../analysis/wait` and stop again. That directive is the
  external path's and must have no counterpart here.

- **A clean stop is left alone.** Remove the offending file, let a turn end on
  a clean tree with no task open, and expect **no** new orchestrator message.
  Silence is the correct answer; a message here would charge the agent a turn
  to be told nothing.

- **A clean tree does not excuse an abandoned task.** With a task open against
  the agent and the tree clean, expect a message naming the requirement and
  carrying the whole `evaluate_task task_id: "..."` call — not a pointer to go
  read about one.

- **Stopping on purpose is not a delivery failure.** Stop the agent, then let
  a decision be produced for it. Expect the harness to log that it was not
  told, at info, and expect nothing to crash — a halted agent has nobody to
  tell, which is a state rather than a failed delivery.

## Result Path

`.code_my_spec/qa/988/result.md`

## Setup Notes

- The code under test must be **live**, not merely committed: `:4000` and
  `:4004` both run the main checkout, whatever worktree pushed. Confirm with
  `grep -hoE '\[Boot\][^"]{0,40}' ~/.codemyspec/web.log | tail -1` before
  trusting any negative result. This run verified `[Boot] serving 01a7e0de`.
- A harness restart leaves agent rows reading `running` with no process behind
  them. `list_agents` after a restart is residue; stop it before starting a
  fresh agent or the bench is a ghost.
- Teardown: delete the offending module from qa_sandbox, stop every agent this
  session started, and leave no credo problem standing against the project.
