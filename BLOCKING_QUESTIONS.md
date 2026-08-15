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

_(nothing else blocking as of 2026-08-14 ~21:25)_
