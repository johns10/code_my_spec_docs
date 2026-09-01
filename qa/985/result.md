# Qa Result

## Status

pass

Second attempt. Tested against harness/server build `74f1e2ed`, through
`http://localhost:4004/mcp` and `POST :4004/api/hooks/stop` with this
worktree's harness id, reading the transcript at
`/app/projects/708492f9-…/agent-conversation/be4fc02d-…` in a browser. One
agent (`a3cf32cb`) was started for this pass and stopped at the end; the
`stories_exist` task raised to produce a hand-over was cancelled after.

The first attempt (`cd29414f`, `fail`) found two defects, both in what an
action *says* rather than in whether it appears. Both are fixed in `74f1e2ed`
and both were re-tested live here rather than trusted from a green suite.

## Scenarios

### the_action_is_there_at_all

PASS. Six actions on a fresh conversation, every one produced by a real stop
hook or `start_task` through the running app. The header-resolved scope reaches
the recorder — the brief's highest risk, because a spex builds its own scope and
the recorder is deliberately silent for an agent with no conversation.

### one_decision_is_one_entry (3034)

PASS. Four `[data-action-kind="decision"]` entries for four stop hooks, never
one per analyzer. The other two are a `handover` and a `nudge` — different acts,
not repeats, and now distinguishable by a reader rather than only by a regex.

### the_count_and_the_tool (3035, 3036)

PASS, re-tested. This is where the first attempt failed.

Paired the hook's own answer against what the transcript drew. One stop
returned:

    "decision": "block"
    per-source: [('compiler', '7')]  → total 7

and the entry it produced reads **`7 problems`**. Another, taken when the tree
held one more, reads `8 problems`. The two stops that *allowed* carry **no
count at all**:

    Ran the analyzers and let you stop.  — run list_problems for the detail

Before the fix every one of those four would have read the same number: 476,
then 500, the project's standing backlog. The number is now the decision's own
claim, and an allow's claim is that nothing stopped the agent.

`list_problems` is still named on every decision, so a reader with no number
still has somewhere to go.

### not_the_agent's_doing (3037)

PASS. Every action carries `data-role="orchestrator"`; none carries
`assistant`, and none renders through the `tool_call` component.

### a_requirement_handed_over (3038)

PASS. `start_task` for `stories_exist` against agent `a3cf32cb` produced one
entry — "Gave you the next requirement: stories_exist." — and re-reading an
active task's prompt produces no second one.

### the_nudge_and_what_must_not_happen (3039)

PASS, re-tested. This is the other first-attempt failure.

    You stopped with qa_complete still open. Close it yourself when it is
    done — nothing will do it for you.
      — call evaluate_task task_id: "fe196562-9038-4cce-ac2b-c7c9f10a0940"

Three things changed and all three matter. It says **call**, not "run". It has
no "for the detail" tail, because the tool there is the act and not the
reference. And it carries the task id, per John: "you should be able to send it
the precise evaluate task call with the task id."

`fe196562` is a real task, and `list_tasks` after the stop still shows it
`[active]`. Nothing completed it. That absence is the whole of the criterion and
was checked against the task record rather than against the transcript's
silence.

### the_empty_case

PASS. The handover carries neither a count nor a tool, and draws neither:

    <div class="min-w-0">
      <span>Gave you the next requirement: stories_exist.</span>
    </div>

An allowed decision carries a tool and no count, and draws exactly that. Across
the transcript, `[data-test="orchestrator-action-count"]:empty` and
`…-tool:empty` are both zero. A missing part is absent, not blank.

The zero-activity half remains checkable only vacuously — the project chat
renders no turns at all — and is recorded as such rather than claimed.

## Issues

Both first-attempt defects are resolved:

- `bae56fe8` — resolved. `decision_count/1` sums the per-source counts off the
  block's own reason, sharing `blocking_counts/1` with the log line; an allow
  returns nil.
- `d7cbbf60` — resolved. The nudge carries the whole call; `tool_lead/1` and
  `tool_tail/1` key the label off the action's kind.

Filed and left open, on John's call to ship 985 anyway:

- `f0cc65ab` — medium. Only the hand-over is shared between external and
  internal agents. The decision and the nudge are both produced inside
  `Hooks.Stop.decide/2`, reached only by an external agent POSTing
  `/api/hooks/stop`; `CmsHarness.Agents.Engine` never calls
  `Validation.validate_stop/3`, so an Alloy agent ending a turn with an open
  task is never told to close it. John's direction is on the issue: abstract the
  transport rather than duplicating the hook — "for external agents we deliver
  via queueing to the stop hook, for the internal one we use messaging."

## Note On The Evidence

The brief said to treat a green spex as weak evidence here, because I wrote the
implementation and the spex in the same session. That was the right warning:
both defects were invisible to a passing suite, and one of them was invisible
*because* of it — criterion 3035 asserted a count was present, and it also never
blocked, feeding the compile fixture without writing the file so the diagnostic
was out of scope and the stop allowed. The assertion passed on the backlog.

3035 now writes the broken file the way 5099 does, asserts the block, asserts
the count is 1, and carries a second scenario for the allow case that fails
against the old code. Both new assertions were run against the reverted
implementation before being kept.
