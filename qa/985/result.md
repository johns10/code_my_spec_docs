# Qa Result

## Status

fail

Tested against harness/server build `5f6dc226`, through
`http://localhost:4004/mcp` with this worktree's harness id, plus the
transcript page at
`/app/projects/708492f9-…/agent-conversation/6148be6a-…` in a browser. One
agent (`b649a3dd`, `warm-badger`) was started for this run and stopped at the
end.

Two defects, both in what an action *says* rather than in whether it appears.
The story's premise holds: the orchestrator's acts reach the agent's transcript
through the running app, they are not drawn as the agent's own, and nothing
closes a task on the agent's behalf.

## Scenarios

### the_action_is_there_at_all

PASS, and this was the one worth checking. The brief flagged it because every
spex builds its own scope while the app resolves one from `X-Harness-Id`, and
the recorder is deliberately silent for an agent with no conversation — so
"nothing recorded" and "nothing to record against" look identical from the page.

Started `b649a3dd` on this worktree, fired a real stop hook against
`:4004/api/hooks/stop` with the checkout's harness id, opened the transcript.
Eight `[data-test="orchestrator-action"]` entries, all of them produced by this
session's own stops and task calls. The header path works.

### one_decision_is_one_entry (3034)

PASS. After the stops, `[data-action-kind="decision"]` counts six — one per
stop hook fired, never one per analyzer. The two remaining entries are a
`handover` and a `nudge`, which are different acts and not repeats.

The kind attribute is what makes this checkable by a reader rather than only by
a regex, and it is the reason the count is honest: without it, "one decision is
one action" reads as "one action per stop", which was never the rule.

### the_count_and_the_tool (3035, 3036)

**FAIL** on the count. Every decision carries one, and it is the project's
standing problem backlog rather than what that decision found:

    Ran the analyzers and let you stop.  476 problems  — run list_problems…

The stop **allowed**. It found nothing blocking. `476` is what
`Problems.list_project_problems/1` returns for the working copy — ambient, and
nothing to do with this decision. It read `500` an hour later, for the same
reason. A person reading that line concludes the stop found 476 problems and
was waved through anyway.

Filed `bae56fe8`.

The tool half is right: six counts, seven tools, no link to a problems page
inside any action's own markup. (The sidebar's Problems link is the page's, not
the action's — checked the action subtree, which is where an earlier version of
the spex went wrong.)

### not_the_agent's_doing (3037)

PASS. Zero entries match `[data-test="orchestrator-action"][data-role="assistant"]`,
and none render through the `tool_call` component — the orchestrator clause is
its own `turn/1` head with `data-role="orchestrator"`. Reading the transcript,
the stop does not present as the agent's own judgement.

### a_requirement_handed_over (3038)

PASS, including the negative half. `start_task` for `stories_exist` with
`agent_id` set to this agent produced one entry — "Gave you the next
requirement: stories_exist." Calling `start_task` again for the *same*
requirement produced **no** second entry, because re-reading the prompt for an
active task is not a hand-over.

### the_nudge_and_what_must_not_happen (3039)

PASS on the behaviour, **FAIL** on the wording.

The nudge fires and the task stays open. `list_tasks` after the stop:

    ● stories_exist — [active] agent=b649a3dd…

Nothing completed it. That is the whole of John's call — "it should always be
at the agent's discretion" — and it is an absence, which is the easiest thing
for a spec to assert wrongly, so it was checked against the task record rather
than against the transcript's silence.

The wording is wrong. The nudge renders:

    You stopped with stories_exist still open. Close it yourself when it is
    done — nothing will do it for you.  — run evaluate_task for the detail

`evaluate_task` is not "for the detail" there; it is the thing to do. One
sentence template — "run X for the detail" — is serving two different
relationships between an action and a tool. On a decision it is correct; on a
nudge it tells an agent its own next move is somewhere to go reading.

Filed `d7cbbf60`. John's direction on the fix: send the precise call, with the
task id, and the precedent is already in the code — `TasksMapper` footers a
started task with ``Task ID: `#{task.id}` ``.

### the_empty_case

PASS on the half that has teeth. A missing part draws nothing, not an empty
one — the handover's markup:

    <div class="min-w-0">
      <span>Gave you the next requirement: stories_exist.</span>
    </div>

No count span, no tool span, no stray "— run  for the detail". Across the whole
transcript, `[data-test="orchestrator-action-count"]:empty` and
`…-tool:empty` are both zero.

The other half — a conversation with orchestrator activity absent entirely —
could only be checked vacuously. The project chat at
`/app/projects/…/chat` renders zero turns of any kind, so "no orchestrator
entries" there is true of a page with nothing on it. Recording that rather than
claiming a test I did not run.

## Issues

- `bae56fe8` — new, medium. A stop decision reports the whole project's problem
  count instead of its own.
- `d7cbbf60` — new, low. The nudge tells an agent its own next action is "for
  the detail"; it should carry the precise `evaluate_task` call including the
  task id.

## Note On The Evidence

I wrote both the implementation and the spex for this story in the same
session, and said so in the brief. Both defects are in the class that pairing
produces: the spex assert that a count is *present*, so
`data-test="orchestrator-action-count"` rendering is enough to pass, and the
number inside it was never anybody's claim. Neither defect is reachable from a
green suite — the suite is green and both are real.

Also on the record, because it cost somebody else time: `57054285` put a
knowingly-red 985 spex on main. The devops worktree pulled it and its agent was
blocked five times over fifteen minutes by criterion 3039 before the stop
hook's own escape hatch released it. Fixed one commit later at `5f6dc226`,
which devops-q has not pulled. Not a defect in 985 — a defect in how I landed
it.
