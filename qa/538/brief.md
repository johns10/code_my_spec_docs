# Qa Story Brief

## Tool

curl — all scenarios exercise `POST /api/hooks/stop` and related hook endpoints on the local app (port 4004 in dev_cli). Vibium is not needed; this story has no LiveView surface.

## Auth

No auth required. The local endpoint (`http://127.0.0.1:4004`) uses `LocalOnly` — loopback IP is accepted without credentials.

Required header on every request:
```
-H "X-Working-Dir: /Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox"
```

## Seeds

Verify the QA sandbox project exists and the local app is responding:

```bash
curl -s http://127.0.0.1:4004/health
# Expected: {"status":"ok"}
```

No seed scripts needed — the sandbox project (id `11111111-1111-4111-8111-111111111111`) is already configured in the local CLI DB. All scenarios create their own sessions inline.

Note: The local app runs on port **4004** in `dev_cli` mode (not 4003). Port 4004 may already be in use by the published `cms` binary; check with `lsof -i :4004`.

## What To Test

All tests use the sandbox working directory:
```
SANDBOX_DIR=/Users/johndavenport/Documents/github/code_my_spec_test_repos/qa_sandbox
```

### Scenario 1: Continuous mode OFF — stop allowed (criterion 5110)

- Create a session via `POST /api/hooks/session-start` with a unique `session_id`
- Do NOT call the skill start endpoint (continuous mode stays off)
- Fire `POST /api/hooks/stop` with the same `session_id`
- Expected: response is `{}` (empty object, no `decision` key, no `reason` key)

### Scenario 2: Continuous mode ON — stop blocked with next requirement (criterion 5111)

- Create a session via session-start
- Enable continuous mode: `POST /api/skills/start` with `{"skill":"implement","external_id":"<session_id>"}`
- Fire `POST /api/hooks/stop`
- Expected: response contains `"decision": "block"` and `"reason"` that includes `"start_task"`

### Scenario 3: Block reason embeds full start_task directive (criterion 5112)

- Same setup as Scenario 2
- Inspect the `reason` field more carefully
- Expected: reason contains `requirement_name=`, `entity_type=`, `entity_id=`, and `entity_id=` value is a real backticked identifier (UUID or slug)

### Scenario 4: Sub-agent directive does not include direct start_task footer (criterion 5113)

- This criterion requires a sub-agent-typed task in the actionable frontier, set up via the spex graph fixture (`ProjectStateFixtures.apply_story_chain_complete`). Not exercisable via plain curl without the full graph state from spex fixtures.
- Defer to `mix spex` test result for this criterion.

### Scenario 5: Manual task failing evaluation keeps loop iterating (criterion 5116)

- Create a session, enable continuous mode
- Start a task via the skill endpoint (this creates a manual-validation task when the next requirement is `personas_complete`)
- Fire `POST /api/hooks/stop`
- Expected: with an active manual task, stop is allowed (loop waits for human signal), response is `{}`

### Scenario 6: Idle sub-agent + open main task → assign directive (criterion 5119)

- Create a session, enable continuous mode
- Register a sub-agent via `POST /api/hooks/subagent-start` with `session_id`, `agent_id`, `agent_name`
- Confirm registration echoes `agent_id` back
- Fire `POST /api/hooks/stop`
- Note: R5b requires an *active task* on the session. Without a task started via `start_task`, this falls through to the continuation path. Full criterion requires the spex `:context_spec_task_started` shared given.
- Defer full R5b verification to `mix spex` for criterion 5119.

### Scenario 7: Last requirement satisfied — stop allowed, retrospective emitted (criteria 5120, 6219)

- This criterion requires a fully-satisfied project graph (`FullSatisfactionFixtures.apply`), which is only available via spex fixtures.
- Defer to `mix spex` test results for criteria 5120 and 6219.

### Scenario 8: Five consecutive failures → stuck-detection terminates loop (criterion 5122)

- This criterion requires the `EvaluateTask` MCP tool to be called 5 times with the same failure hash.
- Defer to `mix spex` test result for criterion 5122.

### Scenario 9: Voluntary tap-out routes to permission socket (criterion 5124)

- This criterion requires the `TapOut` MCP tool.
- Defer to `mix spex` test result for criterion 5124.

### Scenario 10: Block-with-feedback includes harness hint (criterion 6220)

- This criterion requires a compile-error block, which requires the cassette fixture (`use_cmd_cassette`) to inject the pre-recorded compile output.
- Defer to `mix spex` test result for criterion 6220.

### Scenario 11: Spex test suite — all 12 criteria (all criteria)

Run: `mix spex --pattern "test/spex/538_llm_agent_autonomous_task_execution/**"`

- Expected: 12 tests, 0 failures

### Scenario 12: Sub-agent registration surface smoke test

- `POST /api/hooks/subagent-start` with `session_id`, `agent_id`, `agent_name`
- Expected: response echoes `{"agent_id": "<id>", "agent_name": "<name>"}`

## Result Path

`.code_my_spec/qa/538/result.md`
