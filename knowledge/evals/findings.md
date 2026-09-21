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
