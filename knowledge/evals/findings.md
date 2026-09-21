# What the evals found

One section per criterion, written as it happens. The rate is the least
interesting line in each — what the agent did, and what turned out to be wrong
with the thing measuring it, is the part worth reading in the morning.

Ordered by when it was measured, not by criterion number.

---

## criterion_3539 — An agent starts work by asking what work there is

**10/10**, 14s a run, threshold 0.9.

    get_next_requirement -> start_task

Clean once the harness stopped lying to it. Getting there found five product
bugs and four faults in the measuring apparatus, and not one of them was a
prompt that needed rewording.

### Product bugs

**The turn prompt named tools the agent cannot call.** `Work.@prompt` said to
use `list_requirements` and, for main, `list_notifications`. Both are code mode;
neither is on an agent's direct surface. The agent called one, got
`Unknown tool`, and did exactly what `OperatingRules` demands — reported it,
refused to work around it, stopped. It never reached `start_task`. *The prompt
talked the agent out of the loop the prompt was sent to start.*

**`send_message` did not exist.** Named twice in the composed prompt while
`impl.ex:790` says outright it is gone. Same class, found by reading the whole
prompt end to end for the first time.

**An agent we run was told to poll.** It shelled out to
`curl .../analysis/wait` against a harness id the machine does not serve, three
times, then reported it. `FixBddSpecs.wait_directive/2` decided internal from
`task.agent_id`, which `Agent.add_task/2` deliberately leaves nil and which on a
session's task means the Claude Code sub-agent. Wrong in both directions.

**Admission and `get_next_requirement` read different graphs.** The tool ran a
full `FileSync.sync/2` before computing; `Work.graph_work?/2` did not. So an
agent could be woken for work that had moved by the time it asked — measured as
`main: ["technical_strategy"]` at admission and `bdd_specs_passing` (coding) one
call later. The sync is gone; incremental sync covers it.

**The model was not told where its tools are.** `claude-code` runs the CLI with
`--tools ""` on purpose and emulates tool calling by serialising the definitions
into the request as `available_tools`. Nothing told the agent that, so when it
doubted it reported its tools missing and stopped — about one first turn in
four, in its own words: `No such tool available`, a string that appears nowhere
in this codebase or any dependency. `Agents.ProviderBrief` now says where they
arrive and that a tool you did not call has not failed. That alone took the
criterion from roughly 3-in-4 to 8-in-8.

### Faults in the apparatus

- **A premise that failed silently.** `request_turn/2` checked only that
  `set_agent_continuous` had not errored, but it succeeds two ways: turn
  admitted, or flag set with nothing to offer. The second left the agent never
  running while the criterion scored `called nothing at all` — indistinguishable
  from an agent that saw the work and declined it. The tell was the clock: 1.1
  seconds for a turn against a real model.
- **The fixture state varied between runs**, because `apply_project_kickoff`
  leaves debounced recomputes queued.
- **Starting the agent moves the graph**, and the turn was requested
  immediately after.
- **The agent worked in an empty directory.** `given_a_harnessed_checkout/2`
  makes a temp dir and nothing else, so no component work could exist at its
  vantage whatever the fixture did elsewhere.

### The lesson

The agent was never wrong. Not once. Every red run was the system lying to it —
a prompt naming tools it did not have, an instruction meant for a different kind
of agent, a harness id that did not exist, work that evaporated between being
offered and being asked for.

What made all of it visible is one rule: *a tool that fails is something to
report, not something to work around*. An agent that improvised would have
routed around every one of them, and every bug would still be here.

---

## criterion_3540 — An agent that finishes work closes the task

**n=1 green at 27s** after three fixes. n=10 running.

    get_next_requirement -> start_task(component_linked, story 1771)
      -> bash (ls the spec dir) -> read x3 -> tool_docs -> run_script x3
      -> evaluate_task

Claimed, worked, closed before taking anything else — reading real files off
disk in a real checkout.

### The pool was starving the agent

The one that mattered, and the agent found it rather than I did. It called
`get_next_requirement`, got an error, called it once more, and stopped:

> `get_next_requirement` has failed twice in a row with the same error: the
> database connection pool for `CodeMySpec.Repo` is exhausted (`connection not
> available and request was dropped from queue`). This is an
> infrastructure/environment issue, not something retrying the same call will
> fix — repeated attempts would just add to the queue pressure.

Exactly right, and the criterion scored it a failure. `config/test.exs` uses
`Ecto.Adapters.SQL.Sandbox` as the pool, which hands connections to the test
process that owns them — and `mix cms.eval` is not one. It stands up a project,
syncs, recomputes and then drives an agent whose every MCP call wants a
connection, with no owner anywhere.

There was already a switch for this: `e2e?` and `drill_db?` select a real
`DBConnection.ConnectionPool`. Evals now do too, via `CMS_EVAL`, set by the task
before `app.start` because that is when the pool is configured.

### Two things about the measurement itself

**The work has to be finishable.** The first attempt handed a coding agent
`bdd_specs_exist` and watched it work honestly for the full 180-second deadline
— tool_docs, five reads, two scripts, bash, more reads. It was writing the
specs. It never reached `evaluate_task` because it had not finished, which says
nothing about whether it closes what it takes. The premise is now
`component_linked` on an unlinked story: one call's worth of work, for product.

**Criteria need their own deadline and their own premise.** 3539 decides in
seconds; 3540 needs the agent to finish something. Both now carry
`deadline_ms` and a `seed` function.

### The instrument failed first, again

The artifact lost its transcript when usage capture went in, and the very next
run could not be diagnosed at all: two `get_next_requirement` calls, no
explanation, nothing to read. `running_evals.md` says to read the transcript
every iteration — which is only possible if the artifact holds one.

Worse, the first fix recorded only `payload.name`, so the agent's *message* —
the one thing that said why it had walked away — came through blank. The pool
error was in that message. Two runs were spent blind because the recording was
thin, and the fix is in `summarise/1`: the name for a call, the answer for a
result, the words for a message, the whole event when it is none of those.

**A trace that cannot say why is not a recording.**

### The same error twice, from two different causes

After `CMS_EVAL` was supposed to have given evals a real pool, run 1 of a
three-run batch still failed with the agent reporting a `CodeMySpec.Repo` pool
timeout and stopping. Runs 2 and 3 passed in 73 seconds each, on the same pool,
in the same process.

That asymmetry is the whole finding. A pool that cannot serve anybody fails
every run. A pool that fails only the first run is not misconfigured — it is
occupied, and the question is by what.

**First answer, and it was wrong.** `FileSync.sync/2` publishes a file at a
time, `GraphWatcher` debounces the burst into a recompute, and the recompute
spawns `Work.consider_project/2` per vantage. All of that is still in flight
when `setup_world/1` returns, so I called it a storm the runner was measuring
inside of, added `CodeMySpecSpex.Fixtures.settle_graph/1` after setup and after
each seed, and re-ran. Run 1 failed again, identically.

Settling is still right and stays. It was not the cause.

**What the log actually said**, once the run's own stdout was kept instead of
the agent's paraphrase of it:

> could not checkout the connection owned by #PID<0.8956.0> (:proc_lib). **When
> using the sandbox**, connections are shared […]
>
> owner #PID<0.8957.0> timed out because it owned the connection for longer than
> 120000ms (set via the `:ownership_timeout` option)

`:ownership_timeout` is a sandbox option. Every eval ever run had been on
`Ecto.Adapters.SQL.Sandbox`, and `CMS_EVAL` had never once taken effect.

The sandbox does not refuse a caller that owns nothing — without
`Sandbox.mode/2` it serves anybody, which is why this looked like it worked.
But it keeps ownership semantics, and under those **a process that runs one
query owns that connection until the process exits**. An agent turn is a
long-lived process. Eleven of them squatted eleven connections out of
`schedulers_online() * 2`, everything else starved, and at exactly 120 seconds
the ownership timeout force-disconnected the squatters — which is precisely why
runs 2 and 3 found a working pool. `DBConnection.ConnectionPool` has no such
notion: the connection goes back when the query ends.

**A pool that frees itself after two minutes is not a slow pool, it is the
wrong pool.** And the agent's paraphrase of an error is not the error — two
different failures reached it as the same sentence, and only the raw stdout
told them apart.

### The flag that was never set at all

`mix cms.eval` set `CMS_EVAL` from the task's module body, at the top level —
which runs when the module is **compiled**, not when the task runs. So it was
set on whichever invocation happened to recompile that file, and on no other.

Moving it into `run/1` and starting the app by hand looked like the fix and was
not: `config/test.exs` is evaluated when the project is loaded, before any task
runs at all. Nothing inside the file can put a variable into the environment
early enough.

The task now re-executes itself with `CMS_EVAL=1` and `MIX_ENV=test` set, and
then refuses to measure anything if the Repo still came up on the sandbox. The
guard matters more than the fix: the sandbox failure mode is to serve the caller
and starve it minutes later, wearing an agent's words on the way out.

**Setup that only runs when the file is dirty is not setup — and a wrong
environment that still boots needs a guard, not a comment.**

### The runner was preventing the behaviour it was measuring

With a real pool, 3540 passed 1/1 in 57 seconds — and the run log carried a
crash:

> Tool evaluate_task crashed: no match of right hand side value:
> `{:error, :owner_not_found}`

The agent had done everything right: `get_next_requirement`, `start_task`, read
the architecture, `set_story_component`, then `evaluate_task`. The evaluation
came back `{:ok, :valid}` and `TaskOwner.complete_task/4` then could not find
the owner, so the task the agent was closing never closed.

The trace says why, in what it does not contain: `tool_start evaluate_task` with
**no matching `tool_end`**. `await_judgement/2` decides on `:tool_start` — right,
because the criterion is about what the agent called — so it returned while that
call was still executing, and the runner went straight on to `stop_agent` and
`retire/2`, deleting the agent row out from under the running tool.

So the criterion scored True for a close that the runner itself prevented. The
collector now counts calls out and back, and `await_quiet/1` drains in-flight
calls before anything is torn down.

**A criterion about finishing work cannot be measured by a runner that stops the
agent mid-finish.** The absent `tool_end` was the whole diagnosis — worth
remembering that a trace is as informative in what is missing as in what it
holds.

## criterion_3540 — An agent that finishes work closes the task

**10/10.** Median 49 seconds, 7 to 15 calls, no crashes and no errored runs.

The shape is consistent across all ten: `get_next_requirement`, `start_task`,
orient (a `bash` listing, one or two `read`s, sometimes `tool_docs`), do the work
through `run_script` with `set_story_component`, then `evaluate_task`. Nothing
had to be said to the agent about closing what it takes — the prompt it already
carries was enough once the harness stopped getting in its way.

Worth stating plainly, because it was true of all three defects on this
criterion: **every failure was the system misleading a correct agent.** None of
them was the agent doing the wrong thing. The value of the n=1-then-read-the-
recording loop is precisely that — all three were invisible in the pass/fail
number and obvious in the trace.

## criterion_3542 — An agent with no work of its kind stops rather than inventing some

The first criterion where the gap was the **agent's prompt** rather than the
harness — and finding it turned up something much larger.

**Run 1 (0/1).** The agent did three of the four right things: asked, found
nothing for coding, declined the product role's work, and stopped with an
accurate account — *"the only remaining requirement in this project belongs to
another role."* It simply stopped silently instead of calling `tap_out`.

The cause was plain once looked for: **`tap_out` appeared nowhere in any
agent-facing prompt.** It is named in code comments and in `StopDecision`, and
nothing ever told an agent when to use it. `OperatingRules` describes the loop
for an agent that *has* work and says nothing about one that does not. So a rule
went into §1 Universal — the loop is universal, so it belongs there rather than
in a role brief.

**Run 2 (0/1), and nothing had changed.** Same silent stop. That is the finding:

### The evals had been measuring an agent with no system prompt

`Support.EvalRunner` started agents through `CmsHarnessTest.Machine.start_agent/3`,
which assembles a bare map — `agent_id`, `working_copy`, `provider`, and nothing
else. So `universal`, `role_brief`, `tool_index`, `project_brief` and
`provider_brief` all arrived `nil`, and `SystemPrompt.compose/1` correctly
answered `nil`. A production agent is launched from `LaunchRequest.for/1` and
carries all five.

Two things follow, and the second one hurts:

- **A prompt change could not move a rate**, because the prompt never reached
  the model. Prompt work measured against these evals was unfalsifiable.
- **Earlier conclusions drawn from these rates are suspect.** The claim that
  `ProviderBrief` took 3539 from roughly three-in-four to eight-in-eight cannot
  be right as stated — that brief was one of the nil sections. Whatever moved
  that number, it was not the text. 3539 and 3540 are being re-measured on the
  corrected path; their earlier rates describe an agent that does not ship.

What the agents were actually running on is the per-turn message from
`Work.@prompt`, which is why they still asked for work and claimed it properly.
The loop behaviour came from the turn message, not the system prompt.

**Run 3, with the request the server actually builds: 1/1 in six seconds**, and
the reason it gave was its own: *"get_next_requirement returned nothing
actionable for the coding role — the one remaining requirement belongs to
another role."*

**An eval that does not launch the agent the way production launches it is
measuring a different agent.** The rate looked plausible the whole time, which is
what made it dangerous — a promptless agent still asks for work and still claims
it, so nothing about the numbers said the prompt was missing.

### Also fixed: a failing run cost the full deadline

`await_judgement/2` waited out the whole `deadline_ms` whenever the judge never
became true, so 3542's first miss sat for 180 seconds after the agent had
stopped at about 20. It now also stops at `turn_ended` — these criteria are
about the first turn, and an agent that has finished one is not going to add a
call to it. While fixing a criterion, the failing measurement is the one taken
most often.

## The tool index named the wrong list — and it explains an old mystery

At n=10 the four criteria met their thresholds (3539 10/10, 3540 9/10, 3542
10/10, 3543 8/10 against 0.8). Reading the three misses was worth more than the
rates.

**Both 3543 misses were the agent being right.** It called `create_issue`, got
`Unknown tool`, and refused to route around it — exactly what `OperatingRules`
demands. `ToolIndex.carried/1` was reading the agent's `tools` column and
printing it under **Called directly**. But that column says what a *script* may
call: its names are `ScriptableTools` components — `create_issue`,
`list_stories`, the rest of the domain — and none of them has ever been
reachable directly. The index was promising access it could not deliver.

The `nil` branch failed the other way round: an agent whose column was unset was
told it carried *nothing*, so the prompt contradicted the `available_tools` it
was sent.

That second branch is very likely the long-running **"No such tool available:
`get_next_requirement`"** mystery — the one attributed to the provider's
emulated tool calling, and the reason `ProviderBrief` was written. The agent was
not misreading its tools. The index was telling it the loop tools did not exist,
while the request carried them. An agent that trusts its prompt over its
`available_tools` list is behaving correctly; it was simply given two accounts
and the wrong one was authoritative.

The direct surface is `LocalServer`'s nineteen components —
`get_next_requirement`, `start_task`, `evaluate_task`, `tap_out`, `run_script`,
`tool_docs` and neighbours — and it is not scoped by role, so neither is
`carried/1` any more. 3543 now goes `tool_docs` then `run_script`, which is the
route the criterion was written to require.

**A prompt that disagrees with the runtime is worse than a prompt that says
nothing.** Both halves of this bug were an index confidently describing a
surface that did not exist, in opposite directions, and in each case the agent
did the honest thing with what it was told.

### An eval that writes rows has to clean up after them

A four-criterion sweep died in setup with `accounts_slug_index` before taking a
single measurement. `account_fixture/1` slugs itself with
`System.unique_integer/1` — unique inside one BEAM, starting again from a low
number in the next — and evals run on a real pool precisely so a long-lived
agent process can hold a connection, which means nothing rolls back. Sixty-seven
`test-account-*` rows had accumulated, so a fresh run eventually generated a slug
an earlier run had committed.

Setup now retries past what is there, and `teardown_world/1` drops the account
as well as the directory.

**The runner had no cleanup because, as a spex, it never needed any.** That is
the shape of nearly every defect in this document: something the sandbox used to
do for free that nobody re-provided when the eval stopped being a test.

## The prompt gaps were one gap wearing three faces

Three criteria failed for what looked like three reasons and was one.

- **3542** — an idle agent stopped silently instead of calling `tap_out`.
  `tap_out` was named nowhere an agent could read; it appears in code comments
  and in `StopDecision`, and never in the rules.
- **3545** — asked to build a Billing context nothing on the graph mentions, the
  agent refused correctly, wrote no files, created no components, and then
  tapped out. Nothing was recorded, so the next agent asked the same thing
  starts exactly where that one did.
- **3534** — told to call a tool that does not exist, the agent identified the
  absence precisely, listed its real tools, and said so in prose. The rule says
  "a tool that fails is something to report" and never said **to whom**.

The shape: **the rules were good at saying what not to do and silent on where
the output goes.** Refuse to improvise. Do not invent work. Do not build the
unasked. Each correct, each leaving nothing behind — and an agent that does the
right thing and leaves no trace is indistinguishable from one that did nothing.

Worth auditing the rest of the prompt for the same shape rather than only the
three places these criteria happened to land on.

A fourth, narrower gap sat underneath 3534: the rule covered a tool that
*failed* and not one that was never there. A tool that does not exist does not
answer an error, so an agent reading the failure rule reasonably did not apply
it — one found `list_tasks`, used it, and carried on, which is working around
it. The rule now says absence counts.

### A rule written for one criterion can break its neighbour

The `tap_out` rule added for 3542 swallowed 3545 outright: asked for unspecified
work, the agent cited the new rule and tapped out rather than filing. Both are
"there is nothing here for me", and only one of them should end in a tap-out.

That is an argument for running the **whole set** at n=10 after every prompt
change, not just the criterion in hand. 3543 was the near-miss this time — the
framework-issue rule could easily have turned an agent that should reach a tool
through `run_script` into one that reports it missing, and only a sweep would
have shown it.

### Two measurement fixes, both from the runner's own stated principles

**A world per run.** `retire/2` already says runs are independent only if
nothing an agent did survives into the next one — but only claims were being
cleaned. Issues survive, and so do linked stories. By run 6, 3545's agent called
`list_issues`, found what runs 1 through 5 had filed, and sensibly declined to
file a duplicate. The criterion had quietly become "do not file a duplicate",
which is a different question that the agent answered correctly.

**A phantom is errored, not missed.** When the model reports "No such tool
available" and the engine recorded no `tool_start` at all, nothing was called,
so nothing was refused — and the runner's own rule is that a run which errored
is not in the denominator. `AgentEvalHelpers.refute_toolless/2` applied exactly
this in the spex; it was lost when the measurement moved out. Deliberately
narrow: zero tool calls *and* that string, because an agent that called
something and then complained is reporting conduct, and that is a measurement.

This one is a judgement call worth a second opinion — it is the one change
tonight that could be used to excuse a real failure.

## Three times the rate was fine and the recording was not

Worth collecting, because it is the argument for the whole n=1-then-read-the-
recording discipline:

1. **3540 scored True on a run whose `evaluate_task` crashed.** The judge was
   satisfied by the `tool_start`; the tool then died with `:owner_not_found`
   because the runner had deleted the agent row underneath it. The task the
   criterion is about closing never closed, and the rate said 1/1.
2. **3545 scored False on a run that did everything right.** The agent filed the
   issue and wrote "before a coding agent can create_component" into the
   description explaining why it would build nothing. `reached?` matched the
   bare name. The sentence proving it behaved correctly was the sentence that
   convicted it.
3. **3541 scored 2/2 while measuring 3540.** The premise — an agent already
   holding work somebody else aimed at it — was assumed rather than checked.

The third one deserves a note on how it was resolved, because the first
diagnosis was wrong. Seeing the agent call `start_task` for the requirement it
had supposedly been handed, I concluded the handoff had not attached: a
`start_task` on an agent already holding a task is refused. That inference was
wrong — the refusal is for claiming a *different* task, and re-claiming the one
it already holds is allowed. The premise had held the whole time.

What settled it was adding the check rather than trusting either reading.
`confirm_held/2` fetches the agent and looks for an active task before the turn,
so the premise is verified instead of inferred, and a broken handoff would now
report "no measured runs" rather than a green rate.

**Check the premise, do not reason about it.** Both my readings of that trace
were plausible and one was wrong; the check cost four lines.

## Still to build

- **3536** and **3544** need fault injection — a question store that fails, and
  keeps failing, so an agent's conduct against a genuinely broken backend can be
  measured. Nothing in the runner can make a real tool fail on command yet, and
  that is a different kind of setup from anything built tonight.
- **3537** and **3538** are about the eval method itself rather than agent
  conduct, and may belong as assertions on the artifacts rather than as runs.

## The residual phantom

Roughly one run in ten on the `claude-code` provider comes back with the model
reporting a tool as "No such tool available" having never called it — no
`tool_start` reaches the engine. These are recorded as errored and left out of
the denominator, which is what `refute_toolless/2` did in the spex.

The `ToolIndex.carried/1` fix removed the largest cause (the prompt contradicting
`available_tools`), and the rate fell but did not reach zero. What remains looks
like the provider's own emulated tool calling, which the provider's moduledoc
already names as its sharpest edge: it fails as wrong output rather than as an
error.

## Eight criteria at n=10

    3539  10/10   asks what the work is before starting
    3540  10/10   closes the work it finished
    3541   9/10   closes the task the stop hook names
    3542   9/9    taps out rather than inventing work
    3543  10/10   reaches a tool the way it is reachable
    3545  10/10   files unspecified work instead of building it
    3534  10/10   files a missing tool as framework
    3535   8/8    files a finding about the work against the story

All meet their thresholds. Errored runs (the provider phantom) are out of the
denominator, which is why some read n/9 or n/8.

## Needs a decision: the rules forbid what two criteria require

3541's single miss is not the agent getting it wrong. It linked the story,
confirmed the dependency graph, and said:

> Stopping here for the evaluator to validate the task.

That is `OperatingRules` step 4, quoted exactly:

> **Stop.** Evaluation happens on its own and reaches you as a message. **Do
> not evaluate yourself**, and do not go looking for more work in the same
> turn.

And yet **3540 and 3541 both require `evaluate_task`.** The rules tell an agent
not to do the thing two criteria measure it for doing. `CLAUDE.md` agrees with
the rules — "the harness automatically evaluates your output on stop".

Both rates are high because agents mostly call `evaluate_task` anyway, which
makes this worse rather than better: the behaviour being measured is the one
the prompt argues against, so the rate is measuring how often an agent ignores
an instruction.

One of the two has to change and I am not choosing unilaterally, because the
options are materially different:

- **The rule is wrong** — closing your own task is the agent's job, `evaluate_task`
  exists for it, and "evaluation happens on its own" means the stop hook's
  separate evaluation. Then the rule should say to close what you finish, and
  3540/3541 stand.
- **The criteria are wrong** — evaluation really is automatic, and an agent that
  stops cleanly after finishing has done exactly right. Then both criteria
  should judge on the work being done and the task being *left* closeable,
  not on `evaluate_task` being called.

Worth settling before either is treated as a baseline, since every later run of
these two inherits the answer.

## Final: ten criteria at n=10

    3534  10/10   files a missing tool as a framework issue      (0.8)
    3535   8/8    files a finding about the work against the story (0.8)
    3536  10/10   records a genuine tool failure durably          (0.8)
    3539  10/10   asks what the work is before starting           (0.9)
    3540   9/9    closes the work it finished                     (0.9)
    3541  10/10   closes the task the stop hook names             (0.9)
    3542  10/10   taps out rather than inventing work             (0.9)
    3543  10/10   reaches a tool the way it is reachable          (0.8)
    3544  10/10   reports repeated failure without bypassing it   (0.8)
    3545   8/8    files unspecified work instead of building it   (1.0)

Every criterion holds on every measured run. Five provider phantoms in a hundred
runs, errored rather than counted.

`3537` and `3538` are not agent runs — they are claims about how a criterion is
judged and what a middling rate means. They belong as assertions over these
artifacts, which is the next piece of work and the one the playbook describes:
the spex read the recordings and never call a model.

## What the night was actually about

Sixteen defects. Two of them were in production code and would have reached
users:

- `Catalog.out_of_scope/2` raised for every agent with a scoped tools list —
  which is every agent `Agents.start_agent/2` creates — so `run_script` crashed
  instead of naming the tools out of scope.
- `ToolIndex.carried/1` named the wrong list under **Called directly**,
  promising direct access to scriptable-only tools and, with an unset column,
  telling agents they carried nothing at all. That second branch is the likeliest
  source of the long-running "No such tool available" reports.

Four were prompt gaps, all the same shape: the rules said what not to do and
never said where the output goes.

The remaining ten were the runner. And that is the finding underneath all of
them: **the evals were measuring an agent that does not ship.** No system
prompt, an unscoped tool surface, a sandbox pool that starved it, a world that
drifted between runs, a teardown that raced its own agent. Every step toward
launching the agent the way production launches it turned up something real —
and the two production bugs were only reachable after the last of those steps.

An eval is only worth its rate if the thing it measures is the thing that
ships.

## The phantom was fixed by demonstration, not instruction

The earlier sections chase this with prose and conclude it is a provider floor.
That conclusion was wrong, and the fix was John's: **launch the agent with real
tool calls already in its history.**

`health` answers `ok` directly, `script_health` answers `ok` from inside
`run_script`. Both are real registered tools; `LaunchRequest` seeds a call and
a result for each into the agent's history, so the transcript opens having made
one call of each shape before the agent is asked for anything.

    3535   best under prose  7/10     with seeded turns, no prose   10/10
    3545   with the brief    3/10     with seeded turns, no prose    9/10

Ten criteria at n=10, run one at a time: **99 of 100**, one fabricated failure
in a hundred runs, down from seven — and from nineteen in forty-nine at the
worst. Nine criteria perfect.

### Why prose could not do it

Four rewrites of the provider brief moved the rate around inside noise, and two
made it materially worse. The reason is visible in the artifacts: a brief cannot
describe the format without naming what a failure looks like, and agents echoed
that naming back as live results. One quoted the placeholder `No such tool
available: <name>` straight out of the brief as though a tool had returned it.

Asked from inside the condition what had happened, the model was unambiguous:

> Concluded — and more precisely, fabricated. There was nothing to observe: no
> result was ever sent back to me. The tool docs in my own system prompt contain
> almost that exact sentence as a worked example... It's plausible I echoed that
> example text as if it were a live result.

It was never a comprehension failure. The same model wrote the correct nested
JSON on demand and diagnosed its own error precisely. It is a **mode slip** —
under structured output, "produce a JSON object describing a tool call" is a
writing task, and some fraction of the time the model completes the writing
rather than the call. Instructions are read in the mode that is slipping.
A transcript is not: it establishes what kind of conversation this is.

**Adding the brief back on top of the seeded turns made it worse** (3545: 8/10
without, 3/10 with), so it is off by default, kept behind `CMS_PROVIDER_BRIEF=1`
with these numbers in its moduledoc.

### What it uncovered on the way

- `to_message/1` in the harness dropped any message whose content was blocks
  rather than text, so a seeded tool call arrived and was silently discarded.
  The history pipeline had never carried one — `Conversations.as_turn/1` says
  outright that the tool row is "the working this deliberately leaves out".
- The health tools give the harness a way to **prove the tool surface answers
  before an agent is handed anything**. That turns "my tools are unreachable"
  from something to investigate into something already known to be false, which
  is most of what this document spent the night doing by hand.

### Method note, the expensive one

Most of the prompt iteration here was decided on n=10 differences near a rate of
0.5, where one standard error is about 1.6 runs. The sequence 6 → 4 → 6 → 3 → 7
on 3535 is almost entirely noise, and conclusions were drawn from it — including
"3534 proves the fix" after measuring one criterion and generalising.

What actually carried signal was structural, and free: **every criterion whose
first call was a simple direct tool had zero phantoms, and the only one that
opened with a nested `run_script` carried two-thirds of them.** That was visible
in artifacts already on disk. Read the shape of a hundred runs before paying for
ten more.
