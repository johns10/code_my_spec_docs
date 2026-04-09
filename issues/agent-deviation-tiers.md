# Agent Deviation Tiers: Autonomy Boundaries During Task Execution

## Problem

When the agent encounters unexpected issues during a task (test failures, missing dependencies, broken imports), there's no guidance on how autonomous it should be. The stop hook evaluates pass/fail, but the agent doesn't know whether to silently fix a bug it caused, ask before making architectural changes, or give up after repeated failures.

This leads to two failure modes:
1. Agent spends 20 minutes chasing a tangent fixing something unrelated to the task
2. Agent stops and asks for help on something trivial it could have fixed itself

## Design

Encode deviation tiers in the MCP tool responses (e.g. `start_task` response text) so the agent has clear autonomy boundaries:

| Tier | Action | Example |
|---|---|---|
| Auto-fix | Fix silently, no confirmation | Bug introduced by current task, missing import, type error |
| Auto-add | Add and note in summary | Missing critical functionality implied by the requirement |
| Auto-block | Fix up to 3 attempts, then stop | Test failure in unrelated module, dependency conflict |
| Escalate | Stop and report | Architectural change needed, scope creep beyond requirement |

### Scope constraint

Deviation fixes must be scoped to "issues caused by the current task." If a test was already failing before the task started, that's not the agent's problem.

### Attempt limit

Cap fix attempts at 3 per task. After 3 failed fixes for the same issue, escalate rather than looping.

### Implementation location

The tier guidance goes into the text response from `start_task` and/or the requirement description. No schema changes needed — this is prompt-level guidance that shapes agent behavior.

## Inspiration

GSD framework's executor agent deviation rules — a 4-tier system that encodes real-world wisdom about when an agent should be autonomous vs when it should ask.
