# Choosing a Test Seam

The other documents here describe the mechanisms. This one answers the question that
actually costs time: **which seam does my test want, and which ones will hurt me?**

Written after a session that reached for the most invasive option available three times
in a row and broke nine unrelated tests doing it. Every trap below was paid for.

## Start here: what is the test asserting?

| The test asserts on… | Reach for | Cost |
|---|---|---|
| A pure function's output — parsers, converters, renderers | Nothing. Call it with data. | None |
| Files being read, written, globbed | `Environments.create(:memory, …)` | Writes must go through `Environments.write_file/3` |
| What the *pipeline decided* — blocking, demotion, staleness, freshness | Seed the decision's inputs; keep the analyzer from running at all | None, and it is usually free |
| What a command actually *returned* | `use_cmd_cassette` | High — see below. Almost never right in a unit test |
| The shell-out itself — that we invoke the analyzer correctly and parse real output | A real subprocess, in a tagged integration test | Slow, so keep the count small |

The row that gets skipped is the third, and it is the one most tests are in.

## The analyzer does not have to run

`Validation.validate_stop/3` calls `Analysis.ensure_stale_runs/3`, which splits every
source into **stale** (dispatched — this is what shells out) and **memoized** (skipped
entirely, logged as `[Analysis] skipped (current): …`). A source is memoized when it has
a completed run whose `input_fingerprint` matches the current tree.

So a test that seeds its own findings and asserts only on the verdict wants *all* sources
memoized:

```elixir
# Dispatches compiler, exunit and spex — three real `mix` processes, in a
# directory with no project, purely so they can fail.
fresh_analysis_runs_fixture(scope, ["credo"])

# Memoizes all four. Nothing spawns.
fresh_analysis_runs_fixture(scope)
```

`fresh_analysis_runs_fixture/2` already defaults to `Run.sources()`. Passing a subset is
what buys the subprocesses, and the test passes either way — which is the proof it never
wanted them. Measured on `validation/demotion_wiring_test.exs`: ~8 seconds, all of it
spawning processes whose output is discarded.

**Before mocking a command, check whether the code can simply not call it.**

## The memory environment fakes the filesystem, not the shell

`InMemoryEnvironment` deliberately delegates execution to Local:

```elixir
@impl true
defdelegate cmd(env, command, args, opts), to: CodeMySpec.Environments.Local
```

That is not an oversight — its docstring says so, and the reason is that
`use_cmd_cassette` meck-patches `System.cmd/3` *underneath* the delegation, so replay
works for cassette-driven specs. Overriding it to return a canned result breaks every one
of them.

Consequences worth knowing before you reach for it:

- A memory environment **will not stop a spawn**. If the code under test shells out, it
  still shells out.
- The scope you hand in is not always the scope that runs. The analyzer rebuilds one via
  `Scope.for_local_project/2`, which constructs a fresh `:local` environment when the
  registry has nothing — so the env must also be `Environments.register/2`'d to take
  effect down that path.
- `File.write!` is invisible to it. Writes go through `Environments.write_file/3`.

## Cassettes are a suite-wide mechanism, not a local one

`use_cmd_cassette` meck-patches `System.cmd/3` **process-globally**. Its blast radius is
the whole suite, not the block it appears in. Two failures paid for this:

- From an `async: true` test, the patch and its teardown land under whatever runs
  concurrently. One file plus its neighbour went from 12 passing to 4 killed, and the
  kills were reported against the *other* file.
- Even at `async: false`, the patch leaked past its block: nine provisioning tests failed
  with `CassetteNotFoundError` on `age-keygen` and `sops encrypt/decrypt`. "No recording
  found" means a cassette is active when it should not be — if you see that in a test you
  did not touch, suspect a leaked patch elsewhere.

So: a cassette belongs where the test genuinely needs command *output*, and where the file
is `async: false`. `static_analysis_test.exs` and `static_analysis/runner_test.exs` are
both `async: false` for this reason. If the output is discarded, you are paying a
suite-wide cost for nothing.

## Recorded analyzer output already exists

`test/fixtures/validation/<scenario>/` holds real captured analyzer results — `exunit.json`
in the ExUnit JSON-formatter shape, `compile.jsonl` in the compiler-diagnostics shape —
produced from real projects. The stop hook accepts them directly:

```elixir
post(~p"/api/hooks/stop", %{
  "session_id" => session_id,
  "test_output_files" => %{
    "exunit"  => fixture_path("exunit.json"),
    "compile" => fixture_path("compile.jsonl"),
    "spex"    => Path.expand("test/fixtures/validation/spex_green.jsonl")
  }
})
```

This is the right layer for anything about how the pipeline *reacts* to findings.

**Known gap, as of 2026-08-14:** injecting an output file substitutes the results but does
not prevent the command. `Tests.execute/2` calls `run_with_database(…)` unconditionally
and reads the caller's file afterwards. That is why the 555 and 670 spex stack a cassette
on top of the fixture — the fixture supplies the output, the cassette absorbs the process.
If injection came to mean "results are given, do not run", those cassettes could go. The
open design question is `exit_code`, which today comes from the process.

## Real subprocesses: legitimate, but contained

`cms_harness/analysis_test.exs` builds fixture projects and runs the analyzer against them
for real, and should stay that way — stubbing it would assert that the harness formats a
payload, which was never in doubt. The rules that keep it affordable:

- Keep it out of the parallel phase. ExUnit runs sync cases after the async phase, which
  gives the heavy builds the box to themselves (`1710fd57`).
- Keep the count small. These are also what *produce* the fixtures the pipeline layer
  consumes.

## `killed` findings have three causes, and load is only one

`** (EXIT from #PID<…>) killed` is a process being terminated — never an assertion. What
terminated it is the question, and there are three answers. Reaching for the first one and
stopping cost two agents an afternoon.

### 1. A global mock, patched or unpatched under a concurrent test

**This is the one that reads exactly like load and is not.** `use_cmd_cassette`
meck-patches `System.cmd/3` **process-globally**. When that patch loads or unloads while
another async test is inside `System.cmd`, that test's process dies — and `Task.async`
links, so a patched-out task takes its caller with it, reported as `killed`, naming
nothing.

Deterministic. Two files, 3.6 seconds, on an idle box:

    mix test test/code_my_spec/analysis/runners_test.exs \
             test/code_my_spec/validation/blocking_on_recorded_findings_test.exs
    ** (EXIT from #PID<0.6323.0>) killed

`async: false` on the cassette user, and the same pair is 22/22.

The most consistent victim was whichever test spent longest inside a shell-out —
`OnboardRelayGateTest` probes a `sleep 120` through a 10-second `Task.yield`, by far the
widest window in the suite. The victim set changing run to run is not evidence of load; it
is whoever happened to be shelling out when the patch moved.

**So: a cassette user must be `async: false`. There is no safe async cassette.**

### 2. A shared directory two suites both build in

`../code_my_spec_test_repos` is one directory every worktree reaches by symlink. Tests that
rsync a copy and run `mix` inside it collide across worktrees, and `ensure_fixture_fresh`
used to `git pull` there on every `mix test`. Both are gone from the default suite — the
recordings are committed, and the four tests that need a real project are
`@moduletag :analyzer`.

### 3. Actual load

Real, and it does kill processes: three full runs at `--max-cases 20` gave 5, 5 and 4
failures with almost no overlap; dropping to 4 took it to one. Two agents running suites
against one box doubles it.

But **do not stop here.** After the mock and directory causes were fixed, three consecutive
full runs came back 4312/0 *at load 8–12 with a second suite running* — the load that had
been blamed for everything.

### What to do when you see them

Ask, in order: is any cassette user `async: true`? is anything building in a shared
directory? is another suite running? Then run the named files directly — seconds — and
`clear_problems` with their paths. Do **not** re-run the full suite; that is what produces
the load variety. Issues `0bc611c9`, `c8264c1f`.

## Never leave a live shell-out in a test

No `System.cmd("git", …)`, no building a real repo in `tmp` to assert against. This is the
same class as the above: it fails for reasons unrelated to the code.

When tempted, ask what property actually has a consequence. For
`BootVersion.config_changed?/2` it was not "git diff works" — it was that an unreadable
range answers `:unknown` rather than `false`, because a confident `false` tells someone
whose dev server is wedged that it is fine. That needed no subprocess at all: an
unreadable root short-circuits before `System.cmd` is reached. The rewrite went from 0.3s
and a real repository to 0.00s and nothing that can be killed.

"A stubbed version would only prove the stub" is not a justification. It is a sign the test
is aimed at the wrong property.

## Global state in tests

Anything node-global must be *defined* by the test, not read and restored:

```elixir
setup do
  on_exit(fn -> :persistent_term.erase({BootVersion, :boot}) end)
  ...
end
```

No conditional logic — not in the test body, not in function heads. A test that branches on
what it found is reacting to state it should control. `boot_version_contract_test.exs`
captured into `:persistent_term` and never cleaned up, so whichever file the seed happened
to order after it started shelling out `git rev-parse` and failed with a cassette error
naming a file that had done nothing wrong.

Node-global also means **some tests genuinely cannot be async**, and the reason is usually
a registry rather than the filesystem. `sync_path_test` registers through
`CmsHarness.Registry` — one registry for the node — and then does
`assert_receive {:joined, project_id, _}`; run in parallel it receives a neighbour's join.
Before making a file async, ask what it registers, not just what it writes.

## Counting things across this suite

If you are about to justify a change with a count — "N files do X" — check how the number
was produced. Two measurement errors in one afternoon, both from grep:

- Spex declare `async` in `CodeMySpecSpex.Case`, not in the file. Grepping for `async` in
  spex files counts every one of them as async when they are all sync by design. That
  produced "22 async files racing on a shared registry" when the true number was zero.
- Matching `async: false` anywhere in a file also matches moduledocs that mention it in
  prose.

Match `^\s*use .*async:` and then read what the case module does with it.
