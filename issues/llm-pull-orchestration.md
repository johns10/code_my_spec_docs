# LLM-Pull Orchestration: Replace Heavy Stop Hooks with MCP-Driven Task Flow

## Problem

The current orchestration is **push-based**: every stop hook (main agent AND every sub-agent) triggers a full validation pipeline — static analysis, tests, spex, requirement evaluation, and task matching. This is:

1. **Heavy** — N sub-agents means N+1 full validation runs per development cycle
2. **Non-deterministic** — sub-agent identification relies on probabilistic transcript matching against 351+ dispatched tasks (prompt_path string matching with touched-file fallback)
3. **Always-on** — hooks fire even when you're just exploring code or asking questions, burning resources on validation that isn't needed
4. **Blunt** — no distinction between "sub-agent finished a task" and "main agent paused to think"

The fundamental mismatch: **hooks are driving orchestration, but the LLM should be.**

## Relationship to Existing Work

Builds on [requirements-driven-orchestration.md](requirements-driven-orchestration.md) (now complete), which replaced hard-coded phase logic with a prerequisite graph and provides `next_actionable/2`. This issue focuses on *how the LLM controls the flow* — pulling tasks, linking sub-agents, and triggering validation only when meaningful.

## Design

### Core Idea: Pull Model via MCP

The LLM pulls tasks through an Orchestrator MCP server. Stop hooks still validate — but they're **targeted** (validate only the assigned task's component) instead of running the full pipeline. The heavy project-wide sync only happens when the LLM asks for the next task.

### Flow

```
┌──────────────────────────────────────────────────────────────┐
│ Main Agent                                                    │
│                                                               │
│  1. Calls MCP: list_next_tasks(count: 5)                      │
│     ├─ Server syncs project state (analysis, requirements)    │
│     ├─ Walks requirement graph (next_actionable)              │
│     └─ Returns: [{task_id, component, requirements, ...}]     │
│                                                               │
│  2. Picks a task, calls MCP: prepare_task(task_id)            │
│     ├─ Generates prompt for sub-agent                         │
│     ├─ Records task as prepared (not yet active)              │
│     └─ Returns: prompt content to feed sub-agent              │
│                                                               │
│  3. Spawns sub-agent with vended prompt                       │
│                                                               │
│  4. Calls MCP: assign_task(task_id, agent_id)                 │
│     ├─ Links the sub-agent to the task                        │
│     ├─ Marks task active, requirements :in_progress           │
│     └─ Now we know exactly which agent is on which task       │
│                                                               │
│  5. Sub-agent works... sub-agent stops                        │
│     ├─ Stop hook fires:                                       │
│     │   ├─ Look up agent_id → find assigned task              │
│     │   ├─ Run TARGETED validation (just that component)      │
│     │   ├─ If problems → block, make sub-agent fix them       │
│     │   └─ If clean → mark task complete, update requirements │
│     │                                                         │
│  6. Main agent stop hook:                                     │
│     ├─ Check: all sub-agents done?                            │
│     │   ├─ Not yet → tell agent to wait / do something else   │
│     │   └─ All done → suggest calling list_next_tasks()       │
│     └─ Validate main agent's own changes (if any)             │
│                                                               │
│  7. Main agent calls list_next_tasks() → loop                 │
└──────────────────────────────────────────────────────────────┘
```

### Key Design Decisions

#### 1. Three-step task lifecycle: prepare → assign → complete

**Why not combine prepare and assign?** Because the LLM starts the sub-agent and THEN gets the agent_id back. The sequence is:

1. `prepare_task(task_id)` → returns prompt content
2. LLM starts sub-agent with that prompt (or includes it in the prompt instruction telling the agent to start and assign)
3. `assign_task(task_id, agent_id)` → links the sub-agent

This means we always know which agent is on which task — no guessing. If the LLM runs a sub-agent as a blocking call (not background), it can still assign after the fact — the stop hook sees an unassigned task and tells the main agent to assign it.

**Alternative for blocking sub-agents:** The prompt itself can instruct the LLM: "Start a sub-agent with this prompt, then call assign_task with the agent_id." This works whether the sub-agent runs in foreground or background.

#### 2. Project sync only on `list_next_tasks`

Today: sync runs on every stop hook (static analysis, tests, spex, requirement recalculation).

New: full project-wide sync runs only when the LLM asks what to do next. This is the natural boundary between units of work — the moment "what changed across the project?" matters.

**Why this works:** Between tasks, the project is being actively modified. Syncing mid-work is wasteful. The sub-agent's stop hook does targeted validation (just its component), which is cheap.

#### 3. Stop hooks still validate — but targeted

**We do NOT remove validation from stop hooks.** If an agent goes in and breaks things, we need to make it fix them before it quits. The change is:

**Sub-agent stop hook:**
```
1. Look up agent_id in session → find assigned task
   - Found → run targeted validation on that task's component only
     - Compile check (just that component's files)
     - Tests for changed files (mix test --stale is already scoped)
     - Re-evaluate the specific requirements the task targeted
     - If problems → block, sub-agent fixes them
     - If clean → mark task complete
   - Not found (unassigned) → tell main agent to assign it
2. No project-wide sync. No full spex run. No full static analysis.
```

**Main agent stop hook:**
```
1. Check active tasks status
   - Unassigned tasks? → tell agent to assign them
   - Active tasks with sub-agents still running? → tell agent to wait
   - All tasks complete? → suggest list_next_tasks()
2. If main agent touched files directly → targeted validation on those files
3. No project-wide sync.
```

**Spex:** Stays in the validation pipeline as-is for now (runs in `list_next_tasks` sync and targeted validation). Longer-term, spex likely becomes its own dedicated task in the requirement graph (e.g., a `specs_passing` requirement dispatched like any other task) rather than being bolted onto every validation run. Not blocking for this issue.

#### 4. Requirements `:in_progress` coupled to active tasks

Don't add `:in_progress` as a stored status flag — derive it from the session's active task state. A requirement is in_progress if and only if there's an assigned task targeting it. When the task completes (or fails, or the session dies), status reverts to `:pending` automatically.

```elixir
# Requirement status derived from session state, not stored:
def requirement_status(requirement, session_state) do
  cond do
    requirement.satisfied -> :satisfied
    session_state.task_targeting?(requirement) -> :in_progress
    true -> :pending
  end
end
```

**Why:** No stale `:in_progress` states. Session GenServer dies → tasks clear → requirements fall back to `:pending`.

#### 5. Session GenServer holds everything

The active task registry isn't a separate thing — it's part of the Session GenServer state. The session already tracks what's happening; active tasks are just another piece of that state.

```elixir
defmodule CodeMySpec.Sessions.SessionServer do
  use GenServer

  defstruct [
    :session,           # existing Session struct
    :active_tasks,      # %{task_id => ActiveTask}
    :prepared_tasks,    # %{task_id => PreparedTask} (prompt generated, not yet assigned)
    :completed_tasks    # %{task_id => CompletedTask} (for history/reporting)
  ]

  # Can still persist to JSON file for durability across restarts
  # But in-memory state is the source of truth during a session
end
```

#### 6. Don't rely on sub-agents to self-report

Sub-agents are unreliable messengers. They may not call MCP tools. They may not follow prompt instructions. They may block instead of running in background.

**The linking strategy is main-agent-driven:**
- Main agent calls `assign_task(task_id, agent_id)` — this is the primary path
- Sub-agent stop hook uses `agent_id` from the hook payload to look up the task — this is automatic, no sub-agent cooperation needed
- Only if agent_id lookup fails do we fall back to asking the main agent

We do NOT rely on the sub-agent calling `complete_task`. The stop hook handles completion automatically via the agent_id → task mapping.

### Orchestrator MCP Server

```elixir
defmodule CodeMySpec.McpServers.OrchestratorServer do
  use Hermes.Server, capabilities: [:tools]

  # Task lifecycle
  tool "list_next_tasks"   # Syncs project, walks requirement graph, returns available tasks
  tool "prepare_task"      # Generates prompt for a task, records as prepared
  tool "assign_task"       # Links agent_id to task, marks active + requirements in_progress

  # Status
  tool "get_project_status"  # Requirement satisfaction summary (no sync, reads current state)
  tool "get_active_tasks"    # What's currently running, which agents, which components

  # Manual control
  tool "cancel_task"         # Clear a stuck/wrong task
  tool "force_sync"          # Full project sync on demand (escape hatch)
end
```

Note: no `complete_task` tool. Task completion is handled by the stop hook automatically when the assigned sub-agent stops and validation passes.

### What `list_next_tasks` Does Internally

This is where the heavy work moves — from every stop hook to an on-demand call:

```
list_next_tasks(scope, count: 5)
  1. Sync component mtimes (file watcher catch-up)
  2. Run static analysis on dirty components (Credo, compile)
  3. Run tests (mix test --stale)
  4. Run spex (mix spex --stale)
  5. Recalculate requirements for changed components
  6. Walk requirement graph (Requirements.next_actionable)
  7. Filter out tasks already active/prepared
  8. Return top N actionable tasks with metadata
```

Steps 1-5 are exactly what the stop hook does today. The difference: they run once per task cycle, not once per stop event.

### What the Sub-agent Stop Hook Does Internally

Targeted, not full-project:

```
on_subagent_stop(agent_id, transcript_path)
  1. Look up agent_id in session → find assigned task
  2. If found:
     a. Identify changed files from transcript
     b. Compile check (targeted)
     c. Run tests on changed files (mix test --stale already scoped)
     d. Re-evaluate the task's targeted requirements
     e. If problems → block, return feedback for sub-agent to fix
     f. If clean → mark task complete in session state
  3. If not found:
     a. Check prepared (unassigned) tasks — maybe agent was never assigned
     b. Tell main agent: "Sub-agent {agent_id} finished, please assign it to a task"
```

## Implementation Sequence

### Phase 1: Session GenServer

1. Create `CodeMySpec.Sessions.SessionServer` GenServer wrapping existing Session
2. Move session state into GenServer: session struct + active_tasks + prepared_tasks
3. Add task lifecycle functions: prepare/assign/complete/cancel
4. Persist to JSON file for durability (write-through, read on startup)
5. Requirement status derivation from session state

### Phase 2: Orchestrator MCP Server

6. Create `OrchestratorServer` with `list_next_tasks`, `prepare_task`, `assign_task`
7. `list_next_tasks` wraps existing validation pipeline + `next_actionable/2`
8. `prepare_task` generates prompt via existing agent task modules, records in session
9. `assign_task` links agent_id to prepared task, marks requirements in_progress

### Phase 3: Targeted stop hooks

10. Sub-agent stop hook: look up agent_id → targeted validation on assigned component
11. On validation pass → mark task complete in session
12. On validation fail → block with targeted feedback
13. Unassigned agent fallback → tell main agent to assign
14. Main agent stop hook: report active task status, suggest next action

### Phase 4: Reduce full-pipeline scope

15. Move full project sync exclusively into `list_next_tasks`
16. Stop hooks run only targeted validation (component-scoped)
17. Add `get_project_status` and `get_active_tasks` for visibility
18. Add `cancel_task` and `force_sync` escape hatches

### Phase 5: Cleanup

19. Remove old implementation_status.json dispatch tracking (replaced by session state)
20. Remove transcript-based task identification (replaced by agent_id lookup)
21. Simplify hook_controller.ex dispatch logic

## Risks

**Agent_id availability** — The sub-agent stop hook payload includes `agent_id`. If Claude Code doesn't reliably provide this, the automatic linking breaks. Need to verify this field is always present in SubagentStop events. If not, we fall back to the "ask main agent" path more often.

**Blocking sub-agents** — When the main agent runs a sub-agent in foreground (blocking), it can't call `assign_task` until after the sub-agent finishes. The stop hook fires before assign. Mitigation: the stop hook sees an unassigned agent, queues the completion, and when the main agent calls `assign_task` after unblocking, we retroactively process the completion. Or: the vended prompt instructs the LLM to start sub-agent in background and then assign.

**Targeted validation gaps** — Only validating the assigned component could miss cross-component breakage. Mitigation: `list_next_tasks` runs full sync before dispatching the next task, catching anything the targeted validation missed. This is a bounded window of ignorance.

**Session GenServer lifecycle** — GenServer ties to the local_server process tree. If the server restarts, in-memory state is lost. Mitigation: write-through to JSON file, reconstruct state on startup. Active tasks from a dead session get cleared (requirements fall back to `:pending`).

**Spex as a task (future)** — Spex stays in the pipeline for now, but it's an entire test suite with potential to get slow. Eventually it probably belongs as a dedicated requirement/task (`specs_passing`) in the graph rather than running on every validation. Not blocking for this issue.

## Dependencies

- [requirements-driven-orchestration.md](requirements-driven-orchestration.md) (complete) — provides `next_actionable/2` and the prerequisite graph
- Existing MCP server infrastructure (Hermes.Server) — already in place
- Hook controller — needs modification but not replacement
- Claude Code hook payload — need to verify `agent_id` is reliably present in SubagentStop events

## Files to Create

| File | Purpose |
|------|---------|
| `lib/code_my_spec/sessions/session_server.ex` | GenServer wrapping Session + active task state |
| `lib/code_my_spec/orchestration/active_task.ex` | ActiveTask / PreparedTask structs |
| `lib/code_my_spec/mcp_servers/orchestrator_server.ex` | MCP server for LLM task pull |
| `test/code_my_spec/sessions/session_server_test.exs` | GenServer + task lifecycle tests |
| `test/code_my_spec/mcp_servers/orchestrator_server_test.exs` | MCP server tests |

## Files to Modify

| File | Changes |
|------|---------|
| `lib/code_my_spec/sessions.ex` | Delegate to SessionServer for task operations |
| `lib/code_my_spec/local_server/controllers/hook_controller.ex` | Targeted validation via session task lookup |
| `lib/code_my_spec/validation.ex` | Extract targeted (single-component) validation path |
| `lib/code_my_spec/validation/pipeline.ex` | Add component-scoped validation mode |
| `lib/code_my_spec/project_coordinator/implementation_status.ex` | Migrate to use session state (or deprecate) |
