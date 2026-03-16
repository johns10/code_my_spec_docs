# Research: mix test --stale and mix spex --stale

## Summary

This document captures research findings on `mix test --stale` behavior, whether
`mix spex` supports a `--stale` flag, how the current Pipeline uses test execution,
and the implications for optimizing incremental test runs in CodeMySpec.

---

## 1. How --stale Determines Which Tests to Run

The `--stale` flag is implemented in `Mix.Compilers.Test`. The algorithm works as
follows:

**First run:** All test files are run and a manifest is written to
`_build/<env>/.mix/compile.test_stale` (an Erlang binary term file, version-tagged,
compressed). The manifest stores a map of test source paths to their recorded
compile-time and runtime module references plus external file dependencies.

**Subsequent runs:** A test file is considered stale if any of the following are
true:
- The test file itself was modified after the manifest was last written.
- Any module it references (compile-time or runtime) has a `.beam` file newer than
  the manifest, resolved recursively through the full dependency graph.
- An external resource declared with `@external_resource` in a referenced module
  has been modified.
- `mix.exs` or `config/config.exs` has changed (forces all tests to run).
- The first run ever with `--stale` (no manifest exists).

The dependency graph traversal (`find_all_dependent_on/4`) walks the full
compile-time and runtime reference chain, not just direct references. This means
a change to a deeply nested utility module will cause all test files that transitively
depend on it to be marked stale.

**Manifest is only written when all tests pass.** If any failures exist, the manifest
is not updated. This means a failing run will re-run the same tests next time even
if nothing changed — by design, to prevent silently skipping known-failing tests.

**Source:** `Mix.Compilers.Test` in the Elixir standard library, confirmed by reading
`/Users/johndavenport/.asdf/installs/elixir/1.19.4-otp-28/lib/mix/lib/mix/compilers/test.ex`.

---

## 2. Output When Some Tests Are Stale vs None

**When stale tests exist:** Normal ExUnit output. The formatter does not annotate
which files were selected as stale — it just runs them and prints the standard
"dot per test" progress with failure details and the final summary line:

```
Finished in 0.12s (0.00s async, 0.12s sync)
3 tests, 0 failures
```

**When NO stale tests exist:** The task prints exactly this message and exits:

```
No stale tests
```

This is a `Mix.shell().info/1` call at line 731 of `mix/tasks/test.ex`. The task
then returns without calling `System.at_exit` with a non-zero status.

There is no verbose listing of which files were selected for a stale run. The only
way to know which files ran is to parse the formatter output (test module names
appear in failure reports) or to read the manifest file directly.

---

## 3. Can We Determine Which Test Files Actually Ran?

**From CLI output alone: No.** There is no built-in flag that causes `mix test
--stale` to print a list of the selected test files before or after running them.

**Options for determining this programmatically:**

### Option A: Read the stale manifest before and after
The manifest at `_build/test/.mix/compile.test_stale` is a map keyed by relative
test file path. It is updated only on clean runs. You can decode it with:
```elixir
[@manifest_vsn | sources] = File.read!(manifest_path) |> :erlang.binary_to_term()
```
Where `manifest_path = Path.join(Mix.Project.manifest_path(), "compile.test_stale")`.
However, reading the manifest before the run gives you the previous state, not
the files about to run — the stale calculation is internal to `Mix.Compilers.Test`.

### Option B: Compare manifest timestamps
Before the run: record the mtime of `compile.test_stale`. After the run: compare
the mtime of each test file against the manifest mtime to infer which ones were
stale. This is a heuristic, not authoritative.

### Option C: The --trace flag
Running `mix test --stale --trace` causes ExUnit to print each test name as it runs
(with its module). Test module names map to test files, but this requires parsing.

### Option D: Capture formatter events (most reliable)
The `ClientUtils.TestFormatter` (already used by this project) receives `suite_started`,
`test_started`, and `test_finished` events for every test that actually runs. The
test module atom (`:case` field on `%ExUnit.Test{}`) maps directly to a source file.
You could extend the JSON formatter to emit a `"files"` list by collecting unique
`tags[:file]` values from all test events. This gives an exact file list without
any manifest parsing.

**Note:** `ExUnit` does not expose a public API like `ExUnit.get_loaded_files/0`.
The list of files to run is an internal detail of `Mix.Compilers.Test` and is not
published to the formatter or any callback.

---

## 4. ExUnit Programmatic API for Stale File List

There is no `ExUnit` API to retrieve which files were selected in a stale run.
The stale file set is computed inside `Mix.Compilers.Test.set_up_stale/3`, passed
to `Kernel.ParallelCompiler.require/2` directly, and never stored on a public
process or ETS table.

The formatter receives individual test events but does not receive a "files to run"
notification. The `tags[:file]` field on each `%ExUnit.Test{}` gives the source
file of that specific test, so you can reconstruct the file list from test events
after the fact.

---

## 5. Umbrella App Support

`mix test` is declared `@recursive true`, which means running `mix test --stale`
from an umbrella root will recursively invoke the task for each child app. Each
child app manages its own `compile.test_stale` manifest in its own `_build/test/.mix/`
directory. Stale detection is fully independent per app — a change in `apps/foo`
does not mark tests in `apps/bar` stale.

You can target a single umbrella child from the root:
```
mix test apps/my_app/test
mix test apps/my_app/test --stale
```

In that case, recursive tests for other child apps are skipped entirely.

**CodeMySpec is a single-app project**, so umbrella concerns do not apply directly,
but this is relevant for client projects that may use umbrella structure.

---

## 6. Exit Code Behavior

| Scenario | Exit Code |
|---|---|
| Tests run, all pass | 0 |
| Tests run, failures exist | 2 (default, configurable via `--exit-status`) |
| No stale tests (prints "No stale tests") | 0 |
| No tests to run (prints "There are no tests to run") | 0 |
| `--only` matches nothing | 1 (exits with error) |
| Compilation error | 1 |

**Key implication:** When `--stale` produces "No stale tests" the exit code is 0.
The current `Tests.execute/2` function in this project checks `exit_code == 0` to
determine `:success`. This means a `--stale` run with no stale tests would be
classified as `:success` with zero tests in the JSON output — indistinguishable
from a real test run that happened to have no output yet.

**The JSON output file will be empty or `{}` when no stale tests run**, because the
formatter never receives any test events and the `ClientUtils.TestFormatter` writes
the output file only after suite completion. If the suite is a `:noop` (no files
loaded), ExUnit still calls `ExUnit.run()` but silently (formatters are temporarily
removed per the source code). The JSON output file will likely contain an empty
result or not be written at all.

---

## 7. Does mix spex Support --stale?

**No.** Looking at the `Mix.Tasks.Spex` source at
`/Users/johndavenport/Documents/github/code_my_spec/deps/sexy_spex/lib/mix/tasks/spex.ex`:

- The `OptionParser.parse/2` switches do not include `:stale`.
- The task finds files via `Path.wildcard/1` with a glob pattern, not through
  `Mix.Compilers.Test`.
- It calls `ExUnit.start/1` and `ExUnit.run/0` directly, bypassing the Mix compiler
  infrastructure entirely.
- There is no manifest read or write.

`mix spex --stale` would silently ignore the `--stale` flag (it would appear in
the unparsed remainder and be discarded).

There is also **no `mix spex --stale` equivalent** via the sexy_spex library. Stale
detection for spex files would have to be implemented at the pipeline level (e.g.,
tracking file mtimes manually).

---

## 8. Current Pipeline Behavior

### How `Pipeline.run_tests` works today

In `lib/code_my_spec/validation/pipeline.ex`, the `run_tests/3` function:
1. Filters `test_files` to those that exist on disk.
2. Calls `Tests.execute(test_opts)` with the file list passed directly as args.

In `lib/code_my_spec/tests.ex`, `execute/2`:
1. Builds args: `["test", "--formatter", "ClientUtils.TestFormatter" | args]` where
   `args` is the list of test file paths.
2. Runs `System.cmd("mix", test_args, ...)` with `EXUNIT_JSON_OUTPUT_FILE` set.
3. Parses the JSON output file via `TestRun.parse_changeset/2`.

**There is no `--stale` flag anywhere** in the current test execution path. Tests
are always run by passing specific file paths explicitly. This means stale detection
is done at the pipeline level by filtering which files to pass in, not by `mix test
--stale`.

### How test output is parsed

The `ClientUtils.TestFormatter.JsonFormatter` captures test events and writes a JSON
file structured as:
```json
{
  "stats": { "passes": N, "failures": N, ... },
  "tests": [...],
  "failures": [...],
  "pending": [...]
}
```

Failures include `"error": { "file": "...", "line": N, "message": "..." }`.

There is **no `"files"` list** in the current JSON schema — only which tests ran
and which failed. The pipeline infers which files were involved from the input
`test_files` list, not from the output.

### Existing "stale" in the codebase

The word "stale" appears in pipeline.ex in `clear_stale_problems/2` — this is about
clearing old `Problem` records from the database, not about `mix test --stale`. The
two concepts are unrelated despite sharing the term.

---

## Implications for Potential --stale Integration

If we wanted to add `--stale` support to the pipeline, the key constraints are:

1. **We cannot pass both file paths and `--stale`** effectively. When you pass
   explicit paths to `mix test`, Mix restricts the candidate files to those paths
   and then applies stale filtering within that set. If you pass only changed files
   (as the pipeline currently does), adding `--stale` would further filter them —
   which could be useful but changes semantics.

2. **A "no stale tests" result looks like success** with no test data. The pipeline
   would need to distinguish between "all tests passed" and "no tests ran because
   nothing was stale". The exit code is the same (0) and the JSON output file will
   be empty or absent.

3. **The manifest only updates on clean runs.** If we use `--stale` in a flow where
   tests can fail, we would need to decide whether we want "run stale again after
   fixing" semantics (don't update manifest on failure) or "always update manifest"
   semantics (requires patching or a custom manifest).

4. **`mix spex` cannot use --stale.** Spex stale detection would require a separate
   implementation — either tracking spex file mtimes in the Problems cache or
   implementing a custom manifest alongside the sexy_spex flow.

5. **The most actionable optimization** if we want incremental test runs is what
   the pipeline already does: pass explicit file paths. `mix test --stale` is most
   useful for interactive development (terminal), not for programmatic pipeline
   use where we already know which files changed.

---

## Sources

- Mix.Tasks.Test source: `/Users/johndavenport/.asdf/installs/elixir/1.19.4-otp-28/lib/mix/lib/mix/tasks/test.ex`
- Mix.Compilers.Test source: `/Users/johndavenport/.asdf/installs/elixir/1.19.4-otp-28/lib/mix/lib/mix/compilers/test.ex`
- sexy_spex Mix.Tasks.Spex: `/Users/johndavenport/Documents/github/code_my_spec/deps/sexy_spex/lib/mix/tasks/spex.ex`
- [mix test HexDocs](https://hexdocs.pm/mix/Mix.Tasks.Test.html)
- [mix test --stale PR #4696](https://github.com/elixir-lang/elixir/pull/4696)
- [Elixir Forum: predetermining stale tests](https://elixirforum.com/t/is-there-a-way-to-predetermine-which-tests-and-why-would-be-run-on-mix-test-stale/48325)
