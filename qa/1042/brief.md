# QA Brief — Story 987: Analysis results reach the agent running inside our own BEAM

## Tool

`mcp__plugin_codemyspec_local__*` (`start_agent`, `message_agent`, `stop_agent`,
`list_agents`) driven through `run_script`, with
`curl localhost:4004/api/harnesses/<id>/analysis/run` to land a run on demand,
`psql -d code_my_spec_dev` to read the agent's conversation back, and
`~/.codemyspec/harness.log` for the analyzer side.

The surface is an agent's conversation, and there is no page for it, so
`qa/plan.md`'s table routes this to the MCP column rather than the browser.

## Auth

Local MCP on `4004` takes no user auth; scope comes from the harness id the
plugin's mount already sends. Postgres needs no credentials on this box.

For the direct probes, the QA copy's harness id is
`16bce3db-8212-469b-a6dd-c6a4a4b3a499`.

## Seeds

No seed script. The bench is built during the run:

    /tmp/cms-qa-agents/agent-1

A credo-capable copy of the QA sandbox project, minted by
`.code_my_spec/qa/scripts/qa_agents.sh` and populated from
`code_my_spec_test_repos/qa_sandbox` — which exists precisely so QA can run
`mix credo` without touching the framework's own checkout.

**Use this root and not `qa_sandbox` itself.** `start_agent` resolves a named
root through `WorkingCopies.by_root`, which matches project *and device* and
root; qa_sandbox's Code-My-Spec row sits on a stale device, so naming it
records the agent against the main checkout instead (issue `af85efc7`). This
root resolves correctly. Confirm before trusting anything:

    psql -d code_my_spec_dev -t -c "select working_copy_id from agents where id='<agent id>';"

must print `16bce3db-8212-469b-a6dd-c6a4a4b3a499`.

Wake the copy on the harness first — a copy is picked up on its first contact,
and a just-restarted harness holds a lease on the others for up to a minute:

    curl -sS -X POST localhost:4004/api/hooks/session-start \
      -H "X-Harness-Id: 16bce3db-8212-469b-a6dd-c6a4a4b3a499" \
      -H 'content-type: application/json' -d '{"session_id":"qa-987"}'

Read what the agent was told with:

    psql -d code_my_spec_dev -t -A -c "select m.role, m.inserted_at, m.content::text \
      from conversation_messages m join conversations c on c.id = m.conversation_id \
      where c.agent_id = '<agent id>' order by m.inserted_at;"

## What To Test

- **An Alloy agent is told its own turn broke something.** Ask the agent to
  write a module with no `@moduledoc`, then let a credo run land. Expect an
  alert in its conversation naming the finding, arriving *because the run
  completed* — not because a turn ended and not because the agent asked.

- **An agent that fires no hooks is still told.** Confirm no
  `/api/hooks/stop` was POSTed for this agent, so the only route the alert
  could have taken is the internal one. `web.log` distinguishes them: the hook
  path carries `cms_hook=stop cms_session=...`, the internal path carries
  neither.

- **A clean run says nothing to either agent.** Remove the offending module,
  land another credo run, and expect no new message. An agent woken to be told
  its tree is clean has been charged a turn for no information.

- **The same landing produces the same words for either agent.** Compare the
  alert text against what the same finding renders for an external agent.
  Different accounts of one tree is the failure.

- **Being told does not silence the other agent.** With more than one agent on
  the project, an alert delivered to one must not consume the finding: the
  other is still owed it. Check both conversations after a single landing.

- **A stopped agent is a stopped agent, not a lost message.** Stop the agent,
  land a run, and expect the delivery to be recorded as undeliverable at info
  rather than raising — a halted agent has nobody to tell, which is a state and
  not a fault.

- **Being alerted mid-work does not cost the agent its stop decision.** Land a
  run while the agent is mid-turn, then end the turn. The stop decision must
  still arrive; the alert must not have consumed or replaced it. Story 988's
  path is the one to watch here, and the two must both land.

## Result Path

`.code_my_spec/qa/987/result.md`

## Setup Notes

- The code under test must be **live**, not merely committed: `:4000` and
  `:4004` both run the main checkout whatever worktree pushed. Confirm with
  `grep -hoE '\[Boot\][^"]{0,40}' ~/.codemyspec/web.log | tail -1` before
  trusting a negative result, and check the harness's own build at
  `curl -sS localhost:4004/health`.
- A harness restart leaves agent rows reading `running` with no process behind
  them. `list_agents` straight after a restart is residue; stop it before
  starting a fresh agent.
- Silence is the expected answer in two of these scenarios and the failure in
  another, so never read "no message" as a result without first proving the
  finding was real and enforceable — `analysis/wait` reporting
  `credo: fresh, N problem(s)` is that proof. Three of story 988's criteria
  passed for months by counting zero against zero.
- Teardown: delete the seeded modules, stop every agent started, and land a
  final clean credo run so no finding is left standing against the project.
