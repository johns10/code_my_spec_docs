## Tool

mcp (this session's own local /mcp endpoint, curled directly to confirm the tool manifest independent of the run_script sandbox)

## Auth

No login needed. This session's own harness id is read from CMS_HARNESS_ID / .cms_harness.json and sent as X-Harness-Id on POST http://localhost:4004/mcp with Accept: application/json, text/event-stream.

## Seeds

None. This story is about agent-process lifecycle, not app data. No seed script applies.

## What To Test

All 12 criteria depend on tools that are not present on this QA session's own /mcp tool manifest (confirmed by curling it directly, not just inferring from run_script refusals): no list_agents, no list_working_copies, no list_agent_work, no restart_agent. And there is no tool anywhere reachable from this role to trigger a harness-level restart (as opposed to an agent-level start/stop).

- 3204, 3209, 3210 need an actual harness-process restart. No such tool exists on this manifest, and this session's own harness may be the one serving this worktree, so even a hypothetical lever would be too risky to pull deliberately. Not testable live.
- 3205, 3296, 3449 need start_agent + stop_agent plus a way to confirm the outcome (a working tool call, or a fleet listing). start_agent/stop_agent are present, but nothing to read back the result with is on the manifest.
- 3206, 3467, 3468, 3469 need restart_agent, which is not on the manifest at all -- not a role filter inside a script, confirmed by curling the endpoint directly.
- 3211, 3462 need a working copy staged with an unreachable or empty-tool machine. Staging or finding one needs list_working_copies, not on the manifest.

This matches the prior attempt (dd7a3d38-d105-4066-8cab-535e3fd5e1d8, 2026-09-13, partial) exactly, and issue 50eac6ab-14e8-4901-bef3-6e12355653f6 (accepted, still open) already tracks the root cause. Nothing has changed since that attempt. Confirm it is still open, then submit partial referencing that issue rather than refiling a duplicate.

## Result Path

DB-backed QaAttempt via submit_qa_result. No result.md file.
