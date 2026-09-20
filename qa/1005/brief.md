# QA Brief: Story 1005 — Work appearing on the graph reaches the agent who can do it

## Tool
api

## Auth
None required for the primary evidence surface. The three read-only fleet
diagnostics on the hosted app are unauthenticated (per `plan.md`'s "Fleet
observation for internal agent-behavior stories" section):

    GET http://localhost:4000/dev/agents
    GET http://localhost:4000/dev/fleet?project_id=708492f9-454e-482f-a2eb-be64f0356b87
    GET http://localhost:4000/dev/state

The mutating half of the test (filing/accepting the issue that becomes the
trigger) uses this QA role's own `create_issue` / `accept_issue` /
`resolve_issue` tools directly — no auth needed, same as any other MCP call
this role carries.

Reading the *target agent's own conversation* requires relaying through its
harness, since `read_agent_conversation` is not a tool the `qa` role carries
directly:

    call_mcp_server({
      url = "http://localhost:4004",
      headers = { ["X-Harness-Id"] = "<target working copy's harness id>" },
      tool = "run_script",
      arguments = { script = 'return read_agent_conversation({ agent_id = "<id>", limit = 40 })' },
      timeout = 30000
    })

Postgres is directly reachable for read-only corroboration:
`psql -qtA code_my_spec_dev -c "..."` (see "Setup Notes" — this is how the
real routing key was found).

## Seeds
None. Tested against the real, already-running fleet on project
`708492f9-454e-482f-a2eb-be64f0356b87` ("Code My Spec") — an
internal-agent-behavior story, not a UI/data story. Do not seed this
project. Any trigger is a real, disclosed mutation (a QA-probe issue,
clearly titled and resolved afterward), not a fixture.

## What To Test

**Pick the target first, verify all four wake gates before touching
anything.** A wake reaches a continuous agent only if all hold at once:

1. `continuous == true` and `status` is `running` (or `starting`) —
   `/dev/agents` or `/dev/fleet`.
2. Not awaiting an answer — no pending question *and* no pending
   permission request. **Not visible from `/dev/fleet` or any qa-role
   tool.** The only way to check it is to read the tail of the agent's own
   conversation (via the relay above) and look for an unanswered `Q:` with
   no matching `A:` after it, or a `tap_out` nobody decided. Issue
   `8cb3f626` explains why this is invisible and why it matters — an agent
   with any open question is unwakeable, silently, with no error and no log
   line, and it accumulates (one real agent on this project carried 8 open
   questions at once during this session).
3. Not mid-turn — `turn_started_at` is null. Not directly exposed either;
   infer it by reading `tool_calls`/`spoke`/`last_message` twice a few
   seconds apart and confirming they are stable (unchanged = idle).
4. Its role's menu is non-empty *after* the trigger — `/dev/fleet`'s
   `actionable` for that agent going from N to N+1, or
   `get_next_requirement` (relayed to that harness) returning something new
   — is the confirmation that real work reached that specific working copy,
   not just the project's graph in the abstract.

**The trigger:** `create_issue` (scope `app`, severity `medium` or higher,
`story_id` set) followed by `accept_issue`. A `low`-severity issue is below
`fix_issues_min_severity` and creates no coding work — confirmed by reading
`Validation`'s gate, don't re-derive it live. Confirm registration via
`gating_issues.app` incrementing on the very next `/dev/fleet` read.

**Picking which story to file against is the part every prior attempt got
wrong, including this one on its first try.** The obvious read — "the
working copy's directory name matches a story number, target that story" —
is false. The real routing key is the `working_copy_id` column on the
`stories` table itself:

    psql -qtA code_my_spec_dev -c "
      select s.id, s.title, s.working_copy_id, wc.root
      from stories s left join working_copies wc on wc.id = s.working_copy_id
      where s.id = <candidate>;"

or, to list every story actually routed to a given checkout:

    psql -qtA code_my_spec_dev -c "
      select id, title from stories where working_copy_id = '<working_copy uuid>';"

A worktree folder named `963-main-agent-nontechnical` does **not** mean
story 963 routes there — in this session story 963's `working_copy_id`
pointed at a completely different checkout (`phx-new-generator`), and the
issue-acceptance trigger against 963 registered and satisfied correctly,
but on the *wrong* (non-continuous) agent, which by design should not
receive an autonomous wake at all. Confirm the target working copy owns the
story *before* filing, not after a null result.

- **A ready story wakes the idle coding agent / Work inside my role and my
  copy wakes me** (3188, 3295): with target + story confirmed matched by
  `working_copy_id`, trigger and watch that agent's conversation (relay
  above) for a new `"Work of your kind is available"` occurrence, and
  `/dev/fleet`'s `active_task`/`last_message`/`actionable` for a change.
  Count literal occurrences before and after — `spoke`/`tool_calls` moving
  is not sufficient evidence (see Setup Notes: an unrelated operator
  message or a harness restart moves both without any wake occurring).
- **A story ready to test wakes the QA agent** (3192): same shape, target a
  continuous QA-role agent instead. Issue `b789ed99` (resolved) documents a
  ~1-in-3 live flake in the underlying settle/announce race for this exact
  criterion in spex; a single live pass or single live miss is weak
  evidence either way without several repeats.
- **A change that adds no work for me does not wake me** (3190): every
  *other* agent in the fleet should show no `spoke`/`last_message` change
  across the same window as the positive trigger — check this
  automatically alongside whichever positive case runs, across the whole
  fleet, not just the one target.
- **Problems appearing wake the coding agent** (3193): trigger via
  `start_analysis` (credo/exunit/spex) on the target's own working copy
  instead of the issue path, then poll `list_problems` (relayed to that
  harness — it is not a directly-callable tool, call it via
  `run_script({script="return list_problems({})"})`) for a nonzero result.
  A clean working copy (all analyzers pass) produces zero problems and
  therefore cannot exercise this path — check `list_problems` is nonzero
  *before* relying on this as your trigger.
- **One graph change, one announcement, routed per agent** (3189): confirm
  exactly the intended agent transitions from the single accept action, no
  second unrelated agent elsewhere in the fleet.
- **Work still waiting does not wake the agent a second time** (3474):
  after an observed wake, accept a second, unrelated issue in the same
  agent's scope while its first item is still outstanding; confirm no
  second wake fires while mid-turn or while the same item is still the only
  actionable thing. `StopDecision.wake/2` returns `:ok` for an agent with
  `turn_started_at` set — issue `088615be` (withdrawn) has the full
  mechanism and a corrected spex measurement (8/8 green) if source
  inspection is needed as a backstop to a live attempt.
- **Work arriving mid-turn is found at the stop hook** (3191): trigger
  while `tool_calls` is actively incrementing on the target; confirm no
  interruption and that the new work surfaces only after the turn ends.
- **A coding agent gets its red spex while product's triage queue is still
  full** (3491): confirm any successful positive-case wake happens
  regardless of nonzero `gating_issues` elsewhere in the project — they are
  never zero on this project (14 app / 16 framework at last check), so this
  is satisfied incidentally by any successful positive run.
- **An unreachable agent does not make the graph retry** (3194): check
  `/dev/state`'s `disagreements` for a target project stuck with
  `recompute_pending: true`, or for `harness_not_connected` loops.
  Several unrelated `harness_not_connected` disagreements already exist on
  other projects on this box — that is expected background noise, not a
  finding, unless one is stuck rather than transient.
- **A published wake reaches a healthy agent** (3294): the positive case
  itself, same evidence as 3188.
- **The work is gone by the time the agent wakes / A recompute that fails
  wakes nobody / A watcher starting up does not wake anyone for work that
  predates it** (3197, 3198, 3475): not producible from this trigger
  mechanism without deliberately breaking something shared (forcing a
  recompute failure, or restarting the one live GraphWatcher for a project
  with real agents depending on it). Record as **not exercisable from this
  role/surface without mutation beyond what's authorized** — consistent
  with `50eac6ab`. The GraphWatcher-startup behavior in 3475 *was*
  observed incidentally and safely: this project's watcher was seen absent
  (`/dev/state` → `graph_watcher.watching: false`, with an explicit
  disagreement message) and self-seeded a few minutes later with no
  spurious wake for pre-existing work in between — see Setup Notes.

## Result Path
No result.md. File findings via `create_issue` as they're found; submit the
final result via `submit_qa_result` on the current task id. Save any
corroborating JSON/text snapshots under `.code_my_spec/qa/1005/evidence/`.

## Setup Notes

- **A project's GraphWatcher is not always running, and reading the graph
  does not start one.** `/dev/state` surfaces this directly as a
  disagreement: *"project X has agents in the loop and no GraphWatcher —
  work appearing will not wake anybody... toggle an agent's loop off and
  on, or restart the server, which seeds a watcher."* Observed live this
  session: `graph_watcher.watching: false` at one poll, `true` with a fresh
  `last_recompute` about three minutes later with no action from this QA
  session — some other agent's ordinary lifecycle activity reseeded it.
  **Check `/dev/state` for `graph_watcher.watching` before trusting a
  negative wake result** — a watcher that is down makes every wake
  criterion fail for a reason that has nothing to do with the wake
  mechanism itself, and this project's watcher is not always up when you
  start looking.
- **A live wake test on this project is subject to real operator/harness
  churn that looks like, but is not, a wake.** During this session: (1) a
  human operator sent the pre-verified target agent an unrelated message
  about the QA test itself mid-window, which incremented `spoke` and
  `last_message` with zero relation to any graph change; (2) the harness
  serving that same agent restarted mid-turn minutes later, resetting
  `tool_calls`/`spoke` counters downward and producing another
  `last_message` change. Both were confirmed by reading the actual
  conversation text (`"The harness restarted while you were part-way
  through a turn"` / an operator chat message), not inferred. **Counter
  deltas alone (`spoke`, `tool_calls`, `last_message`) are not sufficient
  evidence of a wake** on a shared, live box — always confirm by reading
  the conversation text for the literal `"Work of your kind is available"`
  string, and read enough of the tail to rule out an operator message or a
  restart notice as the real cause of any counter movement.
- **`list_requirements` silently ignores `entity_id` — do not read absence
  from it.** The previous attempt filed `1766c610` claiming
  `story_issues_resolved` never generates for the 26 stories on working copy
  `8a03db06`. That was wrong and the issue is dismissed: 24 of those 26 have
  it, story 965 among them, on that copy's own vantage — verified by psql.

  What actually happened is that `list_requirements({entity_type: "story",
  entity_id: 965})` drops the `entity_id` filter and returns "showing 100 of
  483" — the first hundred rows across every story on the project. The story
  under test simply was not in that window, and the truncation notice reads as
  pagination of your own result rather than of everything. Reproduced with the
  id as integer and as string. Note `requirement_name` *does* filter
  correctly, which is what makes the dropped one invisible.

  Filed as `69b418e0` (high). **Check requirements with psql, not
  `list_requirements`**, until that is fixed:

      select name, satisfied from requirements
       where story_id = <id> and working_copy_id is null;

- Every probe issue filed this session was clearly titled
  `[QA PROBE 1005 disposable]`, disclosed in its body, and resolved by QA
  before the session ended — none should reach a real coding agent as
  live, ambiguous work.
