# Blocking questions

Questions that changed what I'd do next and could not be answered from the code,
the issue, or a sensible default. Written down rather than asked, because the
loop that produced them runs while you are away.

Everything not listed here was decided and carried on — this is the short list,
not a log.

Format: what I need, why it blocks, what I did in the meantime.

---

## 1. Test implementations for the analyzers — how far?

**Your steer, twice:** "we actually have fixtures for the analyzers now, so in
tests we should lean on the fixtures", and "it may be that we want a test
implementation that handles this for analyzers".

**Why it needs you:** there are three seams already and they do different
things, so "a test implementation" could mean any of them and the choice
changes a lot of files.

- `test_output_files` in the hook payload — the pipeline reads recorded
  analyzer output instead of producing its own. Works for compile, credo, spex.
  **Does not stop exunit shelling out**: `exunit_output_file` moves where
  results are *read from*, not whether `mix test` runs.
- `use_cmd_cassette` — meck-patches `System.cmd/3`. Actually prevents the
  subprocess, but it is process-global, so it cannot be used from an
  `async: true` file without killing whatever else is running concurrently.
  That is the mechanism behind the `** (EXIT …) killed` phantoms.
- `InMemoryEnvironment` — fakes the filesystem, deliberately **not** the shell
  (`defdelegate cmd(...) to: Local`), so cassettes intercept underneath.

A genuine test implementation of the analyzer behaviour — one module, swapped
by config, returning recorded results without any of the above — would replace
all three for test purposes. That is the version I'd build, but it touches
`Analysis.Runners`, `Compile`, `Tests`, `StaticRunner` and every test that
currently threads a fixture path, so I want your call before doing it.

**Meanwhile:** using `test_output_files` where it works (done for
`stop_controller_test` — eeb7eb74) and tagging the ones that genuinely need a
real toolchain into `:analyzer` so they run on demand (7eede844, e19fbea0).
Both are compatible with any of the three answers.

---

## 2. The agent's `mix test` and the analyzer's share one database

**The finding, measured today.** `mix cms.harness.onboard` writes
`MIX_TEST_PARTITION` into `.claude/settings.local.json`'s `env` block. Claude
Code exports that block into the session, and `config/test.exs` lets an explicit
`MIX_TEST_PARTITION` win over the worktree-derived name. So:

    agent's `mix test`      -> code_my_spec_testh789652af
    analyzer's exunit run   -> code_my_spec_testh789652af   (same)
    analyzer's spex run     -> code_my_spec_testh789652afs  (its own)

Verified by printing `Repo.config()[:database]` and
`TestDatabase.partition_for/1,2` side by side. `code_my_spec_test_phx-new-generator`
exists — the name config would derive without the env var — and nothing uses it.

**Why I think it is accidental rather than designed.**
`Onboarding.resolve_partition!/2` *reads* the partition back out of that same
`env` block — it is the record, and `env` is simply where onboarding had to put
it so something could read it later. Exporting it into every session's shell is
a side effect of the storage location, not a decision. Nothing I can find
argues for the agent and the analyzer sharing a database.

**Why it matters.** Two full suites in one database is `bcad622d`'s exact shape
— "a sweep truncates before exunit and rows appear *during* it", 13 committed
`requirements` rows against an empty `projects` table. That was fixed *between
exunit and spex* by giving spex the `s` suffix. The agent-vs-analyzer collision
was never addressed, and it is live every time you run `mix test` while a sweep
is going.

**Why I did not just fix it.** `CmsHarness.TestDatabase` documents the decision
explicitly and against the obvious repair:

> Only spex moves. Giving exunit a new name would orphan the database it has and
> force a fresh `ecto.create` + `ecto.migrate`, measured at 37.6s; spex pays that
> once and nothing else pays it at all.

So the cost is known and was judged not worth paying. I don't know whether that
judgement was made knowing the agent's own suite is in there too — the comment
says "the shared one", which reads like sharing between the analyzer's own
sources rather than with the interactive session.

**Three options, in the order I'd pick them:**

1. **Stop exporting it.** Record the partition somewhere Claude Code does not
   turn into an environment variable, and have `resolve_partition!` read that.
   The agent falls back to `code_my_spec_test_<worktree>`, which already exists.
   Costs a change in `client_utils` (separate repo).
2. **Give the analyzer's exunit its own suffix** (`h<sha8>a`), exactly as spex
   got `s`. One `ecto.create` + `ecto.migrate` per working copy, ~37.6s, paid
   once — and it contradicts the comment above, which is why I'm asking.
3. **Leave it**, and treat "don't run `mix test` during a sweep" as the rule.
   That is the status quo, and it is what the existing guidance already says,
   but nothing enforces it and the failure is silent.

**Meanwhile:** nothing. It is not blocking anything I'm doing, and every fix
changes which database an agent's tests run against — not a thing to change
under you while you're away.

## 3. Story 983 needs a criterion for the spex-attribution rule (Three Amigos)

**Issue `638f6df4`.** Two changes altered what the spex gate does without
touching a criterion, so 983's specs pass while describing behaviour the system
no longer has:

- `ae0a8537` exempted spex from attribution demotion, so a spex failure on a
  latched story blocks any agent, not just the one who wrote it.
- The `specs_ready` latch was flipped across 88 stories, closing the second of
  two independent reasons the gate had never fired.

983's criteria cover *which stories* a failure blocks (the latch, freshness,
partial-green). Nothing covers whether a finding on a latched story blocks an
agent who did not touch it — which now has an answer, is load-bearing, and is
pinned only by `test/code_my_spec/validation/demotion_wiring_test.exs`.

**Why I did not do it.** The issue says so itself — "983 has passing specs, so
changing what it asserts is a Three Amigos decision, not an edit" — and that
matches your standing rule about not running Three Amigos unilaterally. The
right move is `start_three_amigos_session` on 983 with you in it.

**The shape the issue suggests**, so the session starts from something: one rule
with two scenarios, because the pair is what makes it honest — a spex failure on
a latched story blocks an agent who did not write it, *and* a credo/exunit
finding on an untouched file still does not, because those sources have no
per-story mandate test. Without the second, the first reads as "we reverted the
fix".

**One thing in that issue I did not act on and would not without you.** It notes
a database restore reverted the latch flips from 88 stories to 10, and that they
"need redoing". Flipping 78 stories to `specs_ready: true` makes their spex
failures start blocking every agent in the working copy — the exact mechanism
that hammered four unrelated sessions in `b9a9f9bc`. Not something to do
unattended.

**Meanwhile:** shipped `3e1c14d2`, which makes the stop response *explain* the
rule when it fires — that an agent is blocked by a foreign spex, why attribution
does not demote it, and that parking the story clears the latch. That is the
user-facing half of what the missing criterion would assert, and it does not
change what 983 claims.

---

## 4. Should a finding be acknowledgeable — and if so, with what expiry?

**Issue `fb41eff7`.** The stop hook blocked five consecutive turns on 15 spex
findings, none clearable in that session. Five were cassette mismatches caused
by a behaviour change you approved; ten were pre-existing devops criteria. The
correct fix — re-record the cassettes — was deferred *by your explicit
decision*, because recording requires tearing down a drill sitting at 13/14
waiting on Resend's asynchronous SPF verification.

So the hook had no affordance for "known, attributed, deliberately sequenced",
and the only ways to quieten it were to revert an approved change or destroy a
working environment against your stated wish.

**Why I did not build it.** An acknowledge-with-reason mechanism is a gate
escape hatch, and this codebase has paid repeatedly for gates that quietly stop
blocking — the spex attribution demotion that made `spex: :block_all` a no-op
for months, `reclaim_quiet`'s nil-`last_seen_at` clause that reclaimed every
default harness, `plan_runs`/`fresh_sources` disagreeing into a livelock. The
principle is written in `split_unattributed/2`: "a gate that quietly stops
blocking is worse than one that blocks too much, and it is invisible." It is
also close to the `@tag :pending` stubs your own guidance rules out.

**The shape I would build, if you want it:**

- An `acknowledgement` on a Problem — reason (required), issue or story link
  (required), and who.
- **Expires on change, not on time.** It holds until the file or its
  dependencies change, which is the report's own wording and the right trigger:
  an acknowledgement is a claim about a specific finding on a specific tree, and
  an edit invalidates it.
- **Loudly present in the response.** The stop message names every acknowledged
  finding and its reason, so "the gate is quiet because someone silenced it" can
  never look like "the gate is quiet because the code is clean". That is the one
  property that makes this survivable.
- The MCP tool takes the problem id and refuses without a link, the way
  `submit_qa_result` refuses a non-pass with no `issue_ids`.

**The questions I actually need answered:**

1. Is a per-finding acknowledgement the right grain, or should it be per source
   per story — closer to how `specs_ready` already gates spex?
2. Should acknowledging require an issue that is *open*, so the deferral has a
   place to be resolved from? That is stricter and I think better, but it makes
   the tool refuse more often.
3. Does an acknowledgement survive a rebase that does not touch the file? By
   "expires on change" it would, and that is the case where it is most likely to
   go stale unnoticed.

**Meanwhile:** two mechanisms that were contributing turns to loops of this
shape are fixed — a sweep no longer drops a rerun for a busy source
(`c97c52c4`), and a finding whose source is stale *and* re-running is now
advisory (`0967844a`). Neither addresses deliberate deferral. And since the
report, a blocking spex group in files this session did not touch at least
explains why it blocks and names parking the story as the one legitimate escape
(`3e1c14d2`).

---

## 5. Where should a growing circular-dependency count surface? (`73ff202b`)

**Not blocking any work** — the reporting half is done (`a2478e5c`:
`get_architecture_summary` now returns `circular_dependency_count`, and
`validate_dependency_graph` / `architecture_health_summary` already carried the
full list). What is left is the question the issue actually reserves, and it is
yours because every answer has a cost I would be guessing at.

Confirmed live tonight: **21 cycles**, up from 4 when `d10f65e8` was filed.
Performance is not the problem — 1.85s cold, 0.31s warm with all 21 present.
The problem is that it grew five-fold and nothing said so.

Three shapes, in increasing intrusiveness:

1. **Nothing further.** The count is now in the summary; anyone reading
   architecture health sees it. Cheapest, and honest — but it is what we have
   had all along one level down, and 4→21 is what that produced.
2. **A ratchet.** Store the count, report only when it *increases*. Fires zero
   times today, once on the next regression, and names the new cycle. Needs a
   home for the baseline (a checked-in file, most likely) and a surface to
   report on — session start is the natural one, alongside the co-occupancy
   warning.
3. **A gate.** A requirement that blocks. At 21 this wedges every agent
   immediately, so it would need the baseline anyway, which makes it option 2
   with a refusal instead of a sentence.

I lean to **2**, because an always-on warning about 21 pre-existing cycles is
the "warning that is always on is one nobody reads" failure — the same argument
that made the co-occupancy check a warning rather than a refusal. But a ratchet
also quietly blesses the 21, and if the intent is to drive them down, that is
the wrong default.

Separately, three of them look like mistakes rather than design tensions and
could be fixed without a policy at all: `Member ↔ Account` is two schemas inside
`Accounts`; `Utils → Sessions → AgentTasks` puts a `logic` component in a cycle
with two contexts; and four of the long chains converge on
`Stories → Components → Requirements`, so breaking one edge there likely takes
several with it. Say the word and I will take those three rather than the policy.

**Update — I traced `Member ↔ Account` and it is not a cycle at all
(`f198b227`).** `validate_dependency_graph/1` already excludes schemas on both
ends, because a `belongs_to`/`has_many` pair is an Ecto association rather than
an architectural cycle. Both files are `use Ecto.Schema` on disk and both are
typed **`module`** in the components table, so the exclusion never applies.

The cause is not local: **59 components on this project are typed `module` while
their implementation is an Ecto schema** — `Analysis.Run`, `Components.Component`,
`Content.Content`, `Billing.StripeEvent` among them. `ComponentSync` reads the
type from the spec's `## Type` section, and a spec without one falls back to the
changeset default `"module"`. `member.spec.md` opens "Ecto schema managing the
many-to-many relationship…" and has no such section.

Two things follow, and they change this question. The count is softer than 21 —
at least one is not a cycle, so nobody should read that figure as 21
architectural problems. And the bigger consequence is not the count: those 59 are
getting the module requirement graph where `graph_for_type("schema")` returns a
genuinely different one, so 59 components are being asked for the wrong artifacts.

I did not fix it. Correcting the type reshapes the requirement graph for 59
components, and `ComponentSync`'s own comment records that exact reshaping going
wrong once before in the other direction. `f198b227` carries three options; I
lean on inferring from `use Ecto.Schema` while an explicit `## Type` still wins,
so nothing already correct changes.

**Measured the consequence, and it changes that lean.** Module-typed components
carry one requirement (`implementation_file`, satisfied by 722 of 724); the
schema graph carries three (`spec_file`, `spec_valid`, `implementation_file`).
So correcting the type adds two requirements each — and:

    Ecto schemas typed `module`:      59
      ...that have a spec file:       10
      ...whose spec has a ## Type:     0
      ...with NO spec file at all:    49

Adding `## Type: schema` to the specs reaches **10 of 59** — the rest have no
spec to put it in. Inference reaches all 59 and immediately opens **49
unsatisfied `spec_file` requirements**, with `spec_valid` behind them.

So the real question is not "fix a mistyping" but **do you want 49 schema
specs?** If yes, inference is the mechanism and the backlog is the point. If no,
the type stays wrong and the cycle detector keeps counting Ecto associations as
architectural cycles — the cheaper problem, and the one this question is already
living with.

Third path, if neither appeals: infer the type *and* exempt schemas from
`spec_file`/`spec_valid` until someone opts in. Cycle detector correct, graph
honest about what a schema is, no new tasks. It needs your view on whether an
Ecto schema warrants its own specification at all.

---

## 6. Do components move to the agent grain, or stay project-scoped? (`3c6b6b63`)

**Story 892 already decided this on paper** — "Components follow files. They are
file projections, so they sit at the same grain. This is the authored/derived
line." The schema does not:

    files.harness_id       present
    problems.harness_id    present
    components             project_id only

Two passes have now declined to make this call from the queue, and I am the
second, so it should be a decision rather than a thing that keeps getting
deferred. A components migration touches the architecture pipeline,
`ComponentSync`, and every checker that reads components by project.

**The incident is closed and stays closed.** Verified again just now — the only
two harnesses holding file rows on this project are both live (`phx-new-generator`
4,061 files, `devops-qa` 4,002, both seen within two minutes). The Aug-9 harnesses
from the original report hold none. `Harnesses.reclaim_quiet/1` deletes a quiet
harness's files, `ComponentSync` then prunes components with no remaining source,
and that is suggestion 2 — "prune on the source side" — arrived at without a
migration.

**The residual is a window, not a hole.** A harness that has gone quiet but not
crossed `harness_idle_hours` (default 2, and in practice shorter because reclaim
runs on every local stop) still holds its files, and so still holds components
alive for every other agent. The original failure — an orphan no edit in any
checkout could clear — needed the *unbounded* version of that.

So the question is whether a bounded window is acceptable:

- **Accept it.** Close the issue, keep components project-scoped, and treat 892's
  sentence as satisfied in effect rather than in schema.
- **Do the migration.** Removes the window entirely and matches what the story
  says. This is the expensive one.

I did **not** implement suggestion 3 ("the orphan rule should ignore file rows
from retired agents"), and it is worth saying why, because it sounds cheap and is
not. The orphan rule (`list_orphaned_contexts/1`) reads stories and dependencies
and never looks at file rows at all — what holds a component alive is
`ComponentSync`'s prune. Teaching that prune about idle thresholds would put the
same cutoff logic in a second place, and pruning too eagerly is exactly the
regression that took ten spex across stories 555, 669 and 983 red on this same
story. Not a change to make on a hunch while you are away.

---

## 7. Is `NoControlFlowInTests` meant to cover helpers and stubs? (`358799d7`)

**Not blocking anything** — nothing is failing and I changed no behaviour. It is
here because it is one line from you and it is 80% of this working copy's
blocking-severity credo backlog, so the answer is worth more than the question.

**104 of 130 error-severity credo findings** on this checkout are this one rule.
It walks the whole file (`Credo.Code.prewalk`) and flags every `case`, `if`,
`unless`, `cond` and `try` anywhere in a `_test.exs` or `_spex.exs` — including
inside `defp` helpers and stub plugs. Its message argues something narrower:
"A branch means the test is reacting to state it should control."

I read 7 of 12 randomly sampled findings. None was a test reacting to state it
should control:

- **Stub routing** — `case conn.request_path` inside a `Req.Test.stub`. That is
  the fake server's job.
- **Extraction that raises otherwise** — `case Regex.run(…) do [_, id] -> id;
  _ -> raise …`, which makes the test fail loudly rather than branch around a
  problem.
- **Teardown helpers** — a `defp delete_ssh_key/1` handling present and absent.

The moduledoc says "inside test files … and BDD spec files", so file-level scope
looks intended rather than accidental, and a blanket rule is consistent with how
strict the spex rules are elsewhere. Which is exactly why I did not touch it.

Two answers, and they are opposites:

1. **The rule is right, the message is wrong.** Say plainly that no control flow
   is permitted anywhere in these files, helpers and stubs included. The 104
   become a backlog instead of a puzzle. Cheapest.
2. **The message is right, the rule is too broad.** Scope the walk to `test` /
   `given_` / `when_` / `then_` bodies and leave `defp` and `setup` alone. Clears
   most of the 104.

A third, narrower option is to exempt stub functions specifically, which targets
the shape that is least arguably a test smell.

Separately and already done (`44b68a5d`): `priv/credo_checks/` — what
`install_credo_checks` copies into every project — had been stale since
2026-05-19, so its copy of this check carried a thinner explanation than the one
this project has. Installing would have regressed the text. Behaviour was
identical in both copies; I diffed `run/2`, `test_or_spex?/1` and all five
`walk/2` clauses before touching it, so no findings changed.

---

## 8. ~~Ten async tests mutate globals…~~ — **answered by tracing, no decision needed** (`f6badea0`)

Left in place because it was a question for three hours and the answer is worth
more than the question. **Resolved, nothing needed from you.**

I traced all eight reachable candidates. **Three were real and all are fixed:**

    deploy_key            07c2c511   the one actually observed failing
    harness_fs_transport  30e22f47
    embeddings_backend    17c4b260

Five were false: `resend_webhook_secret` (only its own test hits the endpoint),
`code_my_spec_project_id` (outcome cannot flip without a UUID coincidence),
`git_impl_module`, `project_id` and `provisioning_step_opts` (all flagged by
tests that merely *mention* the module and never call the reading function).
Three more — the `chat_*` keys, `harness_transport*`, `task_help_dir` — have no
other async test referencing their readers at all.

**`embeddings_backend` is worth thirty seconds of your time.** The file already
had this at the top, above a `use` line saying `async: true`:

    # async: false because `sync_framework_knowledge` reads
    # `Application.get_env(:code_my_spec, :framework_knowledge_dir)` —
    # tests put a per-test value via `Application.put_env` and
    # concurrent tests would race on the global.

Someone worked it out and it never got applied. The race also reached further
than that comment: the file `delete_env`s `:embeddings_backend`, and
`file_sync_test.exs:643` writes `{:ok, results} = Embeddings.search(…)`, so an
overlap raises **MatchError inside a test about file syncing**.

**I am no longer proposing the credo check**, and the audit is why: eight traced,
three real. A static check sees condition 1, approximates condition 2 by module
name — which produced three of the five false positives — and cannot see
condition 3 at all. At `error` severity that is ~2 spurious blocks per real bug,
which is question 7's problem rebuilt.

**The three-condition test** is the durable output, and is what made eight traces
cheap:

1. the key is read at **runtime** by `lib/` (not `compile_env`),
2. another **async** test actually *calls* the reading path,
3. the swapped value **changes that test's outcome**.

---

## 9. The spex analyzer works again, and now blocks on mail/devops spex (`c7c86260` in practice)

**This one may actually block me**, unlike 5–8. Recording it before stopping,
because the stop hook is about to tell me and the answer is yours either way.

**What I fixed.** The spex analyzer has been failing on every sweep — `spex:
failed` in every `analysis/wait` all night — and nothing said why. Three layers
hid it:

1. `Spex.execute` matched `{_raw_output, exit_code}` and discarded everything
   `mix spex` printed (`3d6e5a68`).
2. `error_excerpt/1` took the last three lines, which for a mix crash is always
   the same boilerplate while the line naming the fault sits above (`6468832a`).
3. With those fixed, the reason arrived:

       ** (RuntimeError) The test database `code_my_spec_testh789652afs`
          is 3 migration(s) behind.

The **spex** partition — the one with the `s` suffix — was stale. I had migrated
dev and the agent's own test partition when I added `add_qa_script_to_file_role`
and never that one. Migrated it; the suite now runs (160s) and the server
**accepts** the result for the first time.

**The consequence.** 6 frozen stale problems became **37 real ones**. Most are
mail and devops: stories 841, 964, 969, 972, plus 14 that failed in `setup` so
ExUnit could not attribute a file. And `816` — "Sam sends and receives email on
his own domain" — is **`specs_ready: true`**, so its 2 failures block, and spex
is deliberately exempt from attribution demotion (`ae0a8537`), which means they
block *me* rather than whoever wrote them.

I cannot clear them: mail and devops are not my area, and parking a story to
clear the latch is not my call.

**So, one of:**

1. **Park the latched stories whose spex are red for reasons the harness agent
   cannot fix.** One `update_story` each; clears the latch and the block.
2. **Hand them to whoever owns mail/devops.** They are real failures that were
   invisible until tonight, so somebody wanting them is plausible.
3. **Tell me to work them anyway**, overriding "stick with harness bugs, don't
   drift into devops".

I lean 1 so the harness backlog stays workable, and 2 for the substance.

**Update — I fixed the four that were mine, and the rest are not.** Confirmed
breakdown from the read model rather than by eye:

    (none)  14   domain / certificate / mail — die in `setup` on a missing
                 Resend stub, so ExUnit cannot attribute a file
    992      6   image builders
    841      5   devops setup
    995      2   devops
    963      1   setup routine
    964      1   provider credentials
    ----
    812      1   mine — fixed (90761f35)
    726      1   mine — fixed (90761f35)
    677/711  —   mine — fixed (5e9c4ef9), already cleared from the read model

None of the four was a code regression. Each was a spec that had drifted from
what the system does, invisible for as long as the analyzer could not run:

- 677/711 asserted `{:ok, []}` — "exists and is empty" — under step titles
  saying the directory does not exist.
- 726 refuted the bare word `brief`, so `Qa.Evidence`'s unrelated "…where the
  brief was written" sentence tripped it.
- 812 captured logs at `:info` while the trace it follows spans `:info` and
  `:debug`, the delivery line having been moved down deliberately because at
  warning it emitted 2,190 lines per suite run.

So after my four, **everything left is devops or mail.** That makes this a clean
handover rather than a mixed pile, and it is the whole of what question 9 needs
answering for.

**Later: two more were mine, and now filed as `a735ad1d`.** Story 995's pair
turned out to be app code rather than spec drift — a tool result that carried no
`data-tool-call-id` though the call did and the data had it, and a call with
`data-answered` where the criterion asks for `data-state` running/done, which is
the convention the rest of the app uses. Fixed in `46129624`. Six of mine fixed
in total (677, 711, 726, 812, 995 ×2).

Everything still blocking is 816, 964, 972, 974, 992 ×6 and the 14
setup-failures — all devops or mail.

`a735ad1d` records the structural half so it outlives this file — **but read its
correction before acting on it.** After filing I found `d3fa4dc1`, dismissed,
which asked for exactly this. Attribution *was* extended to spex to answer it and
was **reversed** in `ae0a8537`, because it left `spex: :block_all` with no effect
whatsoever — every finding demoted to advisory across an evening, while the mode
had read `:block_all` for months and nothing had ever blocked.

So the blocking behaviour is **intended**, and the option I proposed (demote
foreign spex) is a cure already tried and rolled back. I have struck it.

What survives is narrower and, I think, still real: `d3fa4dc1`'s dismissal gives
the escapes as "fix the regression, or unlatch the story" and treats that as
sufficient. It assumes the stopping agent owns the story. On a project worked by
several agents with standing areas, an agent outside the owning area can take
neither — unlatching changes shared state for everybody, and fixing is the drift
it was told to avoid. That constraint is not in `d3fa4dc1`.

Its dismissal also names where to reopen the argument: **story 983's criteria**,
which under-describe the shipped gate — already question 3 above, and a Three
Amigos session rather than an edit.

So question 9 reduces to: park the affected stories now (1), give stories an
owner/area (3), or accept it (4). Not "change the gate".

**One dead end, checked so nobody else spends the time.** 14 of the 21 remaining
blockers share a single message — `cannot find mock/stub
CodeMySpec.Provisioning.Resend in process #PID<…>` — which looks like one
test-plumbing fix would clear the lot. It would not. `23d3c71c` already measured
it: adding `Req.Test.set_req_test_to_shared(%{})` (the pattern 22 other spex use,
"so the LiveView process sees the stub") changes the error from `cannot find
mock/stub … in process` to `no mock or stub for …` — from a per-process lookup
failure to "there is no stub anywhere". Same failure count. The honest blocker
is the missing recordings, not process scoping.

Worth knowing anyway, and `23d3c71c` says so: without it the failure **names the
wrong cause**, so a spex author reading it goes looking for process scoping when
the stub does not exist at all. That is a message problem worth fixing whenever
someone owns those spex — just not a way past this gate.

---

_(nothing else blocking as of 2026-08-15 ~06:30)_
