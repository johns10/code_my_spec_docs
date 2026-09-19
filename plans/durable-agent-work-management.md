# Durable agent work management — retire `wake`

## Decision summary

`continuous` means only: **the user or main agent has asked this already-staffed role agent to
continue taking turns while eligible work exists.** It is neither a process
status nor a task assignment policy.

The code, QA, and product agents are durable, role-based agents on a working
copy. We do not start or staff an agent when graph work appears. We may request
one more **turn** from the existing agent only when all of the following are
true:

1. the agent's `continuous` flag is true;
2. it has no turn in flight (`turn_started_at` is nil);
3. it has no `:active` task; and
4. role- and working-copy-scoped eligible work exists.

The turn says that work is available and directs the agent to inspect it and
choose it with `start_task`. It never assigns, claims, or embeds a particular
requirement. The agent retains the agency that has proved useful in practice.

`wake` is removed as an untyped project-wide fanout. Its replacement is a
guarded, idempotent request for another turn from one existing role agent.

## Why the Engine should not directly subscribe to the graph

The Engine owns one local harness process and its turn queue; the requirement
graph, durable agent/task state, and the graph watcher live in the server
application. Having `CmsHarness.Agents.Engine` subscribe directly would make a
local process reconstruct server graph semantics, lose work events while the
harness is disconnected, and couple the Engine back to the scheduler concerns
we just extracted from it.

Do not add a second global dispatcher GenServer or a separate bounded context.
Add `CodeMySpec.Agents.Work` as a focused component of the existing `Agents`
context. `GraphWatcher`, task transitions, question answers, and permission
decisions call that component's pure/transactional admission functions. The
Engine remains the final local admission point: it accepts a typed
`:work_available` turn request only when idle, queues it when appropriate, and
runs exactly one turn. The server remains authoritative about whether a request
is warranted; the Engine remains authoritative about local execution and
serialisation.

This division is important:

| Concern                                                             | Owner                                  |
| ------------------------------------------------------------------- | -------------------------------------- |
| durable roster, continuous policy, tasks, blockers, eligibility     | server DB/context                      |
| graph recomputation and the event that eligibility may have changed | `GraphWatcher`                         |
| deciding whether to request a new turn                              | `Agents.Work.request_turn_if_runnable/2` |
| receiving/running one requested turn; never concurrent turns        | Engine                                 |
| selecting and claiming a requirement                                | the agent, through `start_task`        |

## Task lifecycle and stable identity

Use the persisted task UUID (`CodeMySpec.Sessions.Task.id`) to identify the work
that is blocked. Do **not** add `requirement_id` to questions or tap-outs:
requirement nodes are a recomputed graph projection and are not a durable
foreign-key identity. The task already preserves the stable snapshot needed to
re-resolve a requirement: `requirement_name` plus entity identity.

Extend `CodeMySpec.Sessions.Task` for both `Session` and durable `Agent` owners:

```text
active -> completed | failed | cancelled
       -> blocked(question | tap_out | manual)
blocked -> cancelled | active        (only after its blocker is resolved and
                                      the agent deliberately resumes it)
```

Add these fields to the embedded task schema and its type/changeset:

- `:blocked` to `@statuses`;
- `blocked_at`;
- `blocker_type` (`question` | `tap_out` | `manual`);
- `blocker_id` (the request UUID); and
- `blocker_resolved_at`; and
- optional `blocked_reason` for a short user-visible summary.

Add matching `TaskOwner.block_task/5`, `release_block/3`, and query helpers.
They must update the owning agent/session atomically and must not close a task
as a side effect of asking a person. `active_task/1` remains exactly active
only, so a blocked task does not prevent the agent from doing unrelated work.

`prepared` is legacy draft-state vocabulary. It has no role in the durable-agent
work model: the requirement graph is the source of available work, and an agent
task begins only when the agent claims it as `:active`.

`start_task` remains the agent-controlled claim point. It must:

1. reject an attempt to start work owned by another agent;
2. refuse a start when this agent has an `:active` task, with a clear instruction
   to disposition it as `completed`, `blocked`, or `cancelled` first;
3. expose no bare `force` or implicit switch: cancelling ends only this recorded
   attempt, not the graph requirement, which remains available to start later;
4. allow a different task when every existing task is blocked, while showing a
   compact "also blocked on …" reminder; and
5. treat a matching blocked task whose `blocker_resolved_at` is set as a
   deliberate resume request, re-resolve its requirement against the current
   graph, and only then reactivate it; otherwise start a new attempt.

Do not automate `complete_task`. The agent's judgement remains authoritative;
the stop decision is where we make an unfinished active task explicit.

## Remove `send_message`; extend the existing task-scoped question tool

Delete `lib/cms_harness/agents/tools/send_message.ex` and remove its catalog
registration and tests. It is misleading: the agent is not sending ordinary
prose; it is creating a durable blocker and asking a human a question.

`ask_user_question` already exists and is carried by the internal Engine. I
reviewed `lib/cms_harness/agents/tools/ask_user_question.ex`: it is the right
structured-question surface, but its current schema has no task linkage and
still tells the agent to stop for an answer. Extend that existing tool rather
than introducing another question tool. It should:

- accept the structured question/options already supported by
  `QuestionRequest` (free text remains one-question/no-options);
- infer the caller agent from authenticated tool context, never a caller-supplied
  agent ID;
- accept an optional `task_id`, defaulting to the caller's active task;
- reject an unknown, non-owned, non-active task; and
- create `QuestionRequest` with `agent_id` **and `task_id`**, then atomically
  move that task to `:blocked` with `blocker_type: :question`.

Add nullable `task_id :string` to `QuestionRequest` rather than a relational
foreign key: tasks are embeds, so a database FK cannot exist. Legacy
Claude-Code/session questions may keep it null and continue to use polling.
The user-facing question UI can show the task's saved requirement label, but
does not use graph `requirement_id` as identity.

On answer, `Notifications.answer_question_request/3` should persist the answer
first, retain the matching task as `:blocked` but mark its blocker resolved, and
then invoke the runnable-turn check. The next turn presents the resolved blocker
and the agent explicitly resumes or cancels the task; it is not silently made
active. Do not use `Agents.send_to_agent/3` as a control
channel for the answer. A later agent turn reads the durable answer/task state;
a conversation record can still be written for audit/UI, but it is not the
mechanism that resumes work.

Delete the server-side `CodeMySpec.McpServers.Tasks.Tools.SendMessage` too; its
free-text use case is intentionally gone. Preserve `ask_user_question` and
`check_answer` for their existing callers, including external Claude Code
sessions. Before deletion, `rg -n -i 'send_message' lib test .code_my_spec`
must produce an ownership list and every tool/catalog/prompt/test reference
must be removed or changed to `ask_user_question`. Do not remove unrelated
Phoenix/UI `send_message` event names that mean a user chat message rather than
this MCP tool.

## Make tap-out task-scoped too

The current internal-agent tap-out writes `PermissionRequest(agent_id, tap_out)`
and treats a decision as a message to the entire agent. Add nullable `task_id`
to `PermissionRequest` and require/derive it for an internal-agent tap-out from
the caller's active task. Continue to allow null for ordinary tool permissions
and Claude Code's session/SSE path.

On creation, atomically block the task only when `task_id` is present. On a
decision:

- **`task_id` present, allow / approved**: release that task into a terminal
  outcome chosen by the tap-out contract (normally `:cancelled` or `:failed`
  with a reason); do not change `continuous` merely because one task was
  declined;
- **`task_id` present, deny**: retain the blocked task with its blocker resolved;
  leave `continuous` intact; the next agent turn explicitly resumes or cancels
  it;
- **`task_id` null**: this explicitly means "stop work period." On approval,
  turn off `continuous`; no task is blocked or released;
- **ordinary tool permission**: preserve its existing permission-specific
  behaviour and do not alter task state unless it carries a task link.

The nullable `task_id` is the explicit intent discriminator: present means
"stop this task"; null means "stop continuous work." No separate request-intent
field is required.

## Stop decision and continuous turns

Refactor `CodeMySpec.Agents.StopDecision` into two responsibilities:

1. **End-of-turn task decision.** If an active task remains, render the compact
   open-task menu: complete, ask/block, tap out/block, cancel, or keep
   working. If there is no active task, render the compact main menu. Neither
   menu silently selects a new requirement.
2. **Runnable-turn request.** When the turn is fully ended and the stop decision
   has recorded its outcome, call `Agents.Work.request_turn_if_runnable(scope,
   agent, reason)`. The request is
   deduplicated by `turn_started_at` plus a durable/atomic pending-request
   marker (or compare-and-set update) so simultaneous graph and answer events
   cannot create two turns.

The continuous loop no longer embeds `get_next_requirement` in a stop response.
After an agent completes, blocks, or pauses its active task, the runnable check
may request another turn. That turn says only that eligible work exists and
the agent uses `list_requirements` / `get_next_requirement` / `start_task` to
choose it. With no eligible work it does nothing: no empty turn, no message,
and no retry loop.

`Notifications.awaiting_answer?/1` becomes an informational query, not a
global wake gate. A pending question/tap-out blocks only its linked task.
Consequently, replace the current test named
`a_wake_breaks_through_an_open_question_test` with tests that prove a blocked
task leaves unrelated work selectable and that an answer re-enables only its
own task.

## Graph integration and retirement of wake

`GraphWatcher` remains the graph subscriber. On a successful recompute with a
meaningful observation/eligibility change, it calls `Agents.Work.consider_project/2`.
That context evaluates each durable role agent from its own working-copy
vantage, not from a blended project scope, and invokes
`request_turn_if_runnable/2` only for qualifying agents.

Replace:

- `Requirements.GraphWatcher.maybe_wake/2`;
- `Agents.wake_project_roles/2` and `wake_roles/3`; and
- `StopDecision.wake/2` / its rendered "Work of your kind is available"
  message path.

with a typed turn request, for example `Agents.request_work_turn/3`, delivered
to the already-running Engine through the existing authenticated transport.
The Engine may enqueue that typed request but must not inspect the graph,
choose a requirement, or manufacture a durable task state.

All other eligibility-changing paths must call the same context: task terminal
transition, question answer, tap-out resolution, dependency completion, graph
sync, and stale-turn/task recovery. The main-agent cadence becomes recovery
and observability only; it must not periodically fan out broad work messages.

## Revise existing stories and specifications before implementation

This is not a mechanical refactor of the current acceptance criteria. The
existing continuous-mode material (Story 538 / `.code_my_spec/issues/continuous-mode`)
requires the stop hook to choose and embed the next requirement. That conflicts
with the desired agent-choice model. Story 1005 / its QA brief similarly
defines success as a literal wake message and assumes pending questions are a
global wake concern.

Revise the existing Story 538 and Story 1005 criteria, their Spex, and QA plans
before changing production code. Do not create new stories: the product is still
in development and these are corrections to the intended lifecycle. The revised
examples are:

1. A continuous, idle coding/QA/product agent with eligible work receives one
   new turn; it is not re-staffed and no task is preselected.
2. The same agent with no eligible work receives no turn.
3. An agent chooses a task with `start_task`; starting another while one is
   active is refused until the agent explicitly completes, blocks, or cancels
   the active task. A cancellation leaves the graph requirement available.
4. Asking a task-scoped user question blocks only that task; the agent can take
   other role-eligible work.
5. Answering releases only the linked task and results in at most one runnable
   turn request; it never sends a generic user-message wake.
6. A task-scoped tap-out blocks/releases only that task; a tap-out with null
   `task_id` turns off continuous work on approval.
7. Graph changes while an agent is mid-turn do not interrupt it; after it
   becomes idle, eligibility is considered once.
8. A disconnected Engine never loses durable task/blocker state; reconnect and
   recovery safely reconsider eligibility without duplicate turns.

Update Spex and QA evidence to assert turn requests and task state rather than
literal `"Work of your kind is available"` conversation text.

## Delivery sequence

1. Revise and approve the existing Story 538 and Story 1005 criteria, Spex, and
   QA plans using the examples above.
2. Add `:blocked` task state and blocker metadata with unit tests for both
   `Agent` and `Session` owners.
3. Add `task_id` to question and permission requests; implement atomic
   ask/block and resolve/release operations, including legacy-null compatibility.
4. Remove both `send_message` tool surfaces; extend the existing
   `ask_user_question` flow with `task_id`; grep and remove every tool-related
   reference in catalog, tools, skills, prompts, and tests.
5. Introduce `Agents.Work` eligibility/admission functions and Engine typed turn
   request handling, with a concurrency/deduplication test.
6. Move `GraphWatcher` and all lifecycle transitions to that API; retain a
   temporary metric-only compatibility shim for `wake` if rollout needs it.
7. Remove `wake`, the fanout methods, task-control `send_to_agent` deliveries,
   stale UI wording, and their tests; run ExUnit, Spex, and live fleet QA.

## Acceptance gates

- Exactly one durable role agent/working-copy process is reused; no graph event
  invokes staffing/start-agent APIs.
- No agent with no eligible work receives a turn.
- No graph event assigns a requirement; only `start_task` claims one.
- A question/tap-out links to `task_id`, never graph `requirement_id`.
- Blocked tasks are visible and durable, and do not prevent other eligible work.
- Duplicate graph/answer events cannot create concurrent Engine turns.
- Internal agents expose no `send_message` tool, and no internal control path
  relies on a user-message to resume a blocked task.
