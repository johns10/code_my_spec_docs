# Qa Result

## Status

pass

## Scenarios

### Scenario 1: Continuous mode OFF — stop allowed (criterion 5110)

pass

Steps:
1. Created a session via `POST /api/hooks/session-start` with a unique session_id.
2. Did NOT enable continuous mode.
3. Fired `POST /api/hooks/stop` with the same session_id.

Observation: Response was `{}` (empty object). No `decision` key, no `reason` key. The stop hook correctly allows the stop without consulting the requirement graph.

Covered by spex: `criterion_5110_continuous_off_passing_task_stop_allowed_spex.exs` — PASS.

### Scenario 2: Continuous mode ON — stop blocked with embedded directive (criteria 5111, 5112)

pass

Steps:
1. Created a session via `POST /api/hooks/session-start`.
2. Enabled continuous mode via `POST /api/skills/start` with `{"skill":"implement","external_id":"<session_id>"}`.
3. Fired `POST /api/hooks/stop`.

Observation: Response contained `"decision": "block"` and a `reason` field including all three required fields:
- `start_task` — present in reason
- `requirement_name=` — present as `` requirement_name=`project_setup` ``
- `entity_type=` — present as `` entity_type=`project` ``
- `entity_id=` — present as `` entity_id=`11111111-1111-4111-8111-111111111111` `` (real UUID in backticks)

Example response:
```
{"decision":"block","reason":"Task completed successfully. Continuing the autonomous loop with the next assignment:\n\n### ProjectSetup\n\n- Call `start_task` with requirement `project_setup` for project `11111111-1111-4111-8111-111111111111` (QA Fixture Project) — call `start_task` with requirement_name=`project_setup`, entity_type=`project`, entity_id=`11111111-1111-4111-8111-111111111111`.\n"}
```

Covered by spex: `criterion_5111_...` and `criterion_5112_...` — both PASS.

### Scenario 3: Sub-agent registration smoke test

pass

Steps:
1. Created a session via session-start.
2. Registered a sub-agent via `POST /api/hooks/subagent-start` with `session_id`, `agent_id`, `agent_name`.

Observation: Response echoed back `{"agent_id":"<id>","agent_name":"codemyspec:code-writer"}`.

### Scenario 4: R5b — no assign directive without active task

pass

Steps:
1. Created a session, enabled continuous mode, registered an idle sub-agent.
2. Fired stop hook without any active main-agent task.

Observation: Response was the regular continuation block (no `assign_subagent` directive). R5b correctly requires an active main-agent task before issuing the assign directive.

The full R5b path (with an active task from `start_task`) is exercised by the spex: `criterion_5119_idle_subagent_open_task_assign_directive_spex.exs` — PASS.

### Scenario 5: Sub-agent directive omits direct start_task footer (criterion 5113)

pass

Deferred to spex. `criterion_5113_sub_agent_directive_does_not_invite_direct_start_task_spex.exs` — PASS.

Requires the full project graph state from `ProjectStateFixtures.apply_story_chain_complete` to place a sub-agent-typed requirement at the actionable frontier. Not exercisable via plain curl.

### Scenario 6: Manual task passing evaluation continues loop (criterion 5115)

pass

Deferred to spex. `criterion_5115_manual_task_passing_evaluation_continues_loop_spex.exs` — PASS.

Requires the `EvaluateTask` MCP tool surface and persona artifact fixtures.

### Scenario 7: Manual task failing evaluation iterates (criterion 5116)

pass

Deferred to spex. `criterion_5116_manual_task_failing_evaluation_iterates_spex.exs` — PASS.

Confirmed: after a failing `evaluate_task` call, the active manual task stays in-flight and the stop hook returns `{}` (allow), not a block — the agent is expected to iterate.

### Scenario 8: Last requirement satisfied — stop allowed, retrospective emitted (criteria 5120, 6219)

pass

Deferred to spex. Both `criterion_5120_last_requirement_satisfied_stop_allowed_spex.exs` and `criterion_6219_loop_terminus_emits_retrospective_spex.exs` — PASS.

Both criteria confirmed:
- With all requirements satisfied and continuous mode on, stop is allowed (no block decision).
- Response carries a `retrospective` map with a non-empty `prompt` and `scope: "framework"`, instructing the agent to call `create_issue` for any harness friction.

### Scenario 9: Five consecutive failures terminate loop (criterion 5122)

pass

Deferred to spex. `criterion_5122_five_consecutive_failures_terminate_loop_spex.exs` — PASS.

After 5 consecutive `evaluate_task` failures with the same feedback hash, the stop hook:
1. Does NOT block (returns allow).
2. Includes a `systemMessage` field containing "stuck-detection" language.
3. Also includes the `retrospective` marker (R7 terminus payload).

### Scenario 10: Voluntary tap-out routes to permission socket (criterion 5124)

pass

Deferred to spex. `criterion_5124_voluntary_tap_out_routed_to_permission_socket_spex.exs` — PASS.

After the agent taps out and the human approves, continuous mode clears and the next stop hook returns `{}` (loop terminated).

### Scenario 11: Block-with-feedback includes harness hint (criterion 6220)

pass

Deferred to spex. `criterion_6220_block_with_feedback_includes_harness_hint_spex.exs` — PASS.

A compile-error block (exercised via `use_cmd_cassette`) carries the R9 harness hint in the reason:
- Contains `create_issue`
- Contains `scope: framework`
- Contains "harness" language

### Scenario 12: Full spex suite

pass

Command: `mix spex --pattern "test/spex/538_llm_agent_autonomous_task_execution/**"`

Result: **12 tests, 0 failures** in 1.2 seconds.

All 12 criteria covered:
- criterion_5110 — continuous off + passing task → stop allowed
- criterion_5111 — continuous on + passing task → block with next req embedded
- criterion_5112 — block reason has all three start_task fields
- criterion_5113 — sub-agent directive omits direct-start_task footer
- criterion_5115 — manual task + passing eval → loop continues
- criterion_5116 — manual task + failing eval → iterates
- criterion_5119 — idle sub-agent + open task → assign directive
- criterion_5120 — last req satisfied → stop allowed
- criterion_5122 — 5 consecutive failures → terminate loop
- criterion_5124 — voluntary tap-out → permission socket → loop terminates on approve
- criterion_6219 — loop terminus emits R7 retrospective
- criterion_6220 — block-with-feedback includes R9 harness hint

## Evidence

- `.code_my_spec/qa/538/screenshots/538_health_check.png` — local app port 4004 health check showing `{"status":"ok"}`
- `.code_my_spec/qa/538/screenshots/538_sessions_view.png` — sessions LiveView for QA Fixture Project at start of testing
- `.code_my_spec/qa/538/screenshots/538_sessions_with_qa_data.png` — sessions view after QA session creation tests

## Issues

None
