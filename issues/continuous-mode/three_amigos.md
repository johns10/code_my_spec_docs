# Three Amigos — Story 538: LLM Agent Autonomous Task Execution

**Status:** signed off — AC ready to write to story 538 (MCP session dropped, retry pending reconnect)
**Started:** 2026-04-22

## Story (yellow)

As the LLM agent, I receive tasks from the orchestrator, complete them, and am
automatically directed to the next task so that I can work through the project
requirements without user intervention.

## Persona

LLM agent in a Claude Code-style harness with a stop hook in the loop.
**Continuous mode is a session flag.** Human presence is immaterial — the rule
reads the flag, not the room.

## Boundary with 553/554/555 (validation-pipeline-redesign)

Checked `.code_my_spec/issues/validation-pipeline-redesign/{rules,examples,acceptance_criteria,questions}.md`.
**No collision.** The validation pipeline owns: what triggers analysis, what
blocks, advisory vs blocking, response compactness, the 4 KB cap. Continuous
mode is a thin layer that runs **after** the pipeline says "allow stop" — if
the session flag is on, it re-blocks with the next directive.

- **Criterion 5104 still moves from 555 → 538** under its new shape.
- **Open seam:** the next-requirement payload embedded in the block reason
  (R3) shares the response budget with 554's 4 KB cap. Tracked as F1; not
  story-blocking.

## Rules (blue) — confirmed

- **R1** Next-task selection follows the requirements graph
  (`get_next_requirement` returns highest-priority unsatisfied with met prereqs).
- **R2** Continuous mode is a flag on the session. When off, stop is allowed
  (no continuation logic runs). When on, R3–R6 + R8 apply.
- **R3** *(simplified, includes former R7)* When the stop hook fires in
  continuous mode **AND** the current task passed validation **AND** there is
  actionable work, the hook calls `get_next_requirement` server-side and
  **embeds the result in the block reason**. The agent then calls `start_task`
  itself (or delegates to a sub-agent) based on the result. The agent never
  invokes `get_next_requirement` to discover the next action.
  - When the current task is invalid, the stop is blocked with failure
    feedback only (555/554 territory) — no continuation directive. Agent
    fixes, doesn't move on.
- **R4** `validation_type: :manual` → the human signals completion to the
  agent in conversation; the agent calls `evaluate_task`. Continuous mode
  resumes from the result of that evaluation. Manual is a checkpoint, not a
  loop terminator.
- **R5** Sub-agent rules:
  - **R5a** A sub-agent is alive + assigned + working → main agent's stop
    hook does not run (main agent is idle by design while sub-agent works).
  - **R5b** *(reshaped per feedback)* The session has an **open task** AND a
    sub-agent is alive + unassigned → block, instruct main agent to assign
    sub-agent to the open task. Once assigned, main agent stops; further
    stops happen via the sub-agent's own lifecycle.
  - **R5c** No sub-agent + work in graph → R3 applies normally; main agent
    receives the next-requirement directive and may spawn a sub-agent itself
    based on task type.
  - **R5d** No work in graph → R6.
- **R6** Empty graph terminates the loop. Stop allowed, user notified.
  Includes the "blocked-but-non-empty" case (graph has work but every
  actionable item has unmet prereqs — should never happen in a well-formed
  graph; treat as empty if it does).
- **R8** *(stuck-detection)* If `evaluate_task` returns the same failed
  result 5 times in a row on the same task, the loop terminates. Optionally
  the agent can tap out earlier and route to the permissions system
  (`PermissionSocket`) for human approval — either path is acceptable.

## Open follow-ups (not blocking the story)

- **F1** *(resolved)* Interaction between R3's embedded next-requirement
  payload and 554's 4 KB cap — confirmed non-issue. The next requirement
  payload is small by construction; it will not approach the cap.
- **F2** When `get_next_requirement` (server-side, called by hook) errors
  mid-loop → stop the loop, surface the error. Treat as terminal in v1.
- **F3** Define "no progress" precisely for R8 — confirmed: same evaluate
  result on the same task. Counter resets on a different result or a
  different task.
- **F4** Optional voluntary tap-out tool (R8) — if added, route through
  `PermissionSocket`. Out of scope unless examples surface a need.

## Examples (green) — pending sign-off

### R2 — Continuous mode is a session flag
- Continuous mode off, task passes, stop is allowed
- Continuous mode on, task passes, agent receives next directive in the block reason without invoking get_next_requirement

### R3 — Stop hook embeds next-requirement result
- Task passes, hook calls get_next_requirement server-side and embeds the result, agent calls start_task on the returned requirement
- Embedded directive points to a sub-agent task type, agent spawns a sub-agent instead of calling start_task
- Task fails validation, stop is blocked with failure feedback only, no continuation directive embedded
- Task passes but graph has nothing actionable, R6 applies (allow with notification, no directive)

### R4 — Manual validation as checkpoint
- Manual-validation task completes, human says "done" in conversation, agent calls evaluate_task, evaluation passes, loop continues
- Manual-validation task completes, human says "done", evaluate_task fails, agent gets feedback and iterates on the same task
- Manual-validation task in flight, agent stops before the human signals — stop is allowed, no continuation

### R5a — Sub-agent assigned and working
- Sub-agent mid-task, main agent's stop hook is suppressed entirely

### R5b — Open task on session + idle sub-agent
- Session has an open task and an idle sub-agent, directive tells main agent to assign sub-agent to the open task

### R5c — No sub-agent + work in graph
- *(Covered by R3 examples — R5c is "R3 applies normally")*

### R6 — Empty graph terminates the loop
- Last actionable requirement satisfied, next stop is allowed with a "you're done" signal
- Graph has work but every item is blocked by prereqs, treated as empty, loop terminates with notification

### R8 — Stuck-detection terminates the loop
- evaluate_task returns the same failed result 5 times on the same task, loop escalates
- Agent makes progress (different evaluate result), counter resets
- Agent voluntarily taps out, request routed to PermissionSocket for human approval *(optional, F4)*

## Acceptance Criteria — final form (to write to story 538)

1. When continuous mode is off and the current task passes, the stop is allowed.
2. When continuous mode is on and the current task passes, the stop is blocked with the next requirement embedded in the block reason.
3. When the stop hook fires in continuous mode and the current task passed, it calls get_next_requirement server-side and embeds the result in the block reason; the agent then calls start_task on the returned requirement.
4. When the embedded directive points to a sub-agent task type, the agent spawns a sub-agent instead of calling start_task directly.
5. When the current task fails validation, the stop is blocked with failure feedback only and no continuation directive is embedded.
6. When a manual-validation task completes and the human signals done in conversation, the agent calls evaluate_task and on a passing evaluation the loop continues.
7. When a manual-validation task completes and the human signals done but evaluate_task fails, the agent receives feedback and iterates on the same task.
8. When a manual-validation task is in flight and the agent stops before the human signals, the stop is allowed and no continuation directive is embedded.
9. When a sub-agent is mid-task on the session, the main agent's stop hook does not run.
10. When the session has an open task and an idle alive sub-agent, the stop is blocked with a directive instructing the main agent to assign the sub-agent to the open task.
11. When the last actionable requirement is satisfied, the next stop is allowed and the user is notified.
12. When the graph has work but every actionable item is blocked by unmet prerequisites, the loop is treated as having no actionable work and terminates with notification.
13. When evaluate_task returns the same failed result five times in a row on the same task, the loop terminates and escalates.
14. When the agent makes progress on a task (evaluate_task returns a different result), the stuck-detection counter resets.
15. When the agent voluntarily taps out of continuous mode, the request is routed to PermissionSocket for human approval.
