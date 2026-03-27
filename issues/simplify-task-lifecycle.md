# Simplify Task Lifecycle: Drop DraftTask, Enrich MCP with Session Context

## Problem

The current task lifecycle has unnecessary ceremony:

1. `draft_task` (MCP) → finds next requirement, creates a `:prepared` task on the session
2. `start_task` (MCP) → transitions `:prepared` → `:active`, returns prompt
3. `evaluate_task` (MCP) → validates work, completes task

Step 1 is over-engineered. The agent doesn't need to "draft" before starting. It should pick a requirement and go. The two-step draft→start exists because the old architecture needed to separate "what to work on" from "claim the work" — but in practice agents always call them back-to-back.

Additionally, MCP tools don't have access to `session_id` or `agent_id` — this context lives in the hook layer. Currently DraftTask requires the agent to pass `session_id` explicitly, which is fragile and requires the skill/hook layer to thread it through.

## Proposed Design

### New flow

1. **Requirements MCP tools** — agent discovers what needs doing
2. **`start_task`** with requirement ID — creates + activates task in one step, returns prompt
3. **`evaluate_task`** — same as now

### Requirements tools (new, in LocalServer)

```
list_requirements     — returns all project requirements with satisfaction status
next_actionable       — returns next actionable requirements (shortcut for filtered list)
```

These replace `draft_task` as the "what should I work on" discovery mechanism. They're read-only — no session side effects.

### Revised `start_task`

Current: takes `session_id` + `task_id` (from draft_task output)
New: takes `requirement_id` (or `requirement_name`)

The tool:
1. Resolves the requirement
2. Finds or creates the session (using enriched `session_id` from hook)
3. Creates a task with `:active` status directly (no `:prepared` intermediate)
4. Generates the prompt via `requirement.satisfied_by.command(scope, task)`
5. Returns the prompt

### PreToolUse hook enrichment

The hook at `controllers/hooks/pre_tool_use_controller.ex` already intercepts tool calls. Extend it to inject session context into MCP tool inputs:

```
When tool_name matches an MCP tool call:
  - Inject session_id from the hook payload's session_id
  - Inject agent_id from the hook payload (if available)
```

This means `start_task` and `evaluate_task` don't need the agent to manually pass session_id — it arrives automatically via the hook layer.

### What to delete

- `DraftTask` MCP tool — replaced by requirements tools + simplified start_task
- `Sessions.prepare_task/3` — no more `:prepared` status needed (or keep for backward compat but don't require it)
- The `draft_task` references in TasksMapper

### What to keep

- `evaluate_task` — unchanged
- `Sessions.activate_task/4` — still used by start_task
- `Sessions.complete_task/4` — still used by evaluate_task
- The skill → agent-task → controller flow for slash commands (orthogonal)

## Decisions

1. **PreToolUse enrichment**: ✅ CONFIRMED. MCP tools appear as regular tools in hook events with naming pattern `mcp__<server>__<tool>` (e.g. `mcp__plugin_codemyspec_codemyspec__start_task`). `updatedInput` works on MCP tool parameters. The PreToolUse hook can match `mcp__plugin_codemyspec_codemyspec__.*` and inject `session_id`.

2. **Session creation timing**: SessionStart hook fires at conversation start, before any tool calls. `start_task` can assume session exists — the enriched `session_id` from PreToolUse will always resolve.

3. **Requirement selection**: `start_task` takes a `requirement_id`. Agents use `list_requirements` to browse or `get_next_requirement` to get the first actionable one. Agent picks, tool executes.

4. **Subagent sessions**: No separate sessions for subagents. The parent session's `session_id` is always injected via hook enrichment. Subagents are assigned to tasks on the parent session. A session accumulates 1 or more tasks — subagent work is just another task on the same session.

5. **Skills**: The `agent-task` controller is transitional. Skills will eventually tell the agent to call `start_task` MCP tool with a requirement. But the controller works now and doesn't block anything.

## MCP Tools

### Requirements tools (read-only, new)

- `list_requirements` — all project requirements with satisfaction status, grouped by entity
- `get_next_requirement` — returns the single next actionable requirement (first from `next_actionable_project`)

### Task tools (revised)

- `start_task(requirement_id)` — session_id injected by hook. Creates + activates task, returns prompt.
- `evaluate_task(task_id)` — unchanged. session_id injected by hook.

### Deleted

- `draft_task` — replaced by requirements tools + simplified start_task

## Implementation Order

1. Add requirements MCP tools (`ListRequirements`, `GetNextRequirement`)
2. Extend PreToolUse hook to enrich `mcp__plugin_codemyspec_codemyspec__*` tool inputs with `session_id`
3. Revise `start_task` to accept `requirement_id`, auto-resolve session from enriched `session_id`
4. Delete `draft_task`, update skills/prompts that reference it
5. Clean up NextTaskLive to use requirements tools pattern
