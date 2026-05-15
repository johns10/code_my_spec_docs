# Cassettes — project-specific recording playbook

The framework doc at `priv/knowledge/bdd/spex/recording_cassettes.md` covers
the full recipe in detail. This file documents the project-specific
constants, the fixture inventory, and the two distinct cassette systems.

---

## Two cassette systems — use the right one

| System | Dep | Intercepts | Cassette location |
|---|---|---|---|
| `ExCliVcr` | `ex_cli_vcr` | `System.cmd` (mix compile, mix test, mix credo, mix spex) | `test/fixtures/cassettes/<name>.json` |
| `ReqCassette` | `req_cassette ~> 0.6.0` | Outbound HTTP via `Req` (OAuth providers, external APIs) | `test/cassettes/oauth/<name>.json` |

**Default choice:** if the scenario shells out to a mix command, use
ExCliVcr. If the scenario makes outbound HTTP calls through Assent or
a `Req`-backed client, use ReqCassette (or go through `OAuthHelpers`).

---

## ExCliVcr — stop-hook pipeline cassettes

### Test repo pool

Recording cassettes requires a real Elixir project. The pool lives at:

```
../code_my_spec_test_repos/pool_code_repo_1   # through pool_code_repo_9
```

Each pool directory is a full Elixir project with `deps` and `_build`
ready. Any `pool_code_repo_*` can be used as the recording target. The
`mix.exs` stub in the spec's `scope.cwd` is only a marker for the
WorkingDir plug; actual compile/test commands run from the pool repo.

There are also `pool_content_repo_*` directories for content-specific
fixtures. Use `pool_code_repo_*` for compilation and test recording.

### Required env vars when recording

| Var | Tool | Purpose |
|---|---|---|
| `EXUNIT_JSON_OUTPUT_FILE` | `mix test` | Path where ExUnit JSON results are written |
| `DIAGNOSTICS_OUTPUT` | `mix compile --return-errors` | Path where compiler JSONL diagnostics are written |
| `--jsonl=<path>` flag | `mix spex --stale` | Path where spex JSONL results are written |

These are read by `Tests.execute`, `Compile.execute`, and `Spex.execute`
respectively. On replay, the values in the cassette are irrelevant (env
is excluded from match_on) — only the `test_output_files` POST body
field matters.

The `ClientUtils.TestFormatter` formatter must be wired into the test
repo for ExUnit JSON output:

```bash
cd ../code_my_spec_test_repos/pool_code_repo_1
MIX_ENV=test EXUNIT_JSON_OUTPUT_FILE=/tmp/exunit.json \
  mix test --formatter ClientUtils.TestFormatter --stale
```

### The `test_output_files` trick

The stop hook's JSON body accepts an optional `test_output_files` map.
`StopController.extract_test_output_files/1` reads it and threads the
paths into `Validation.validate_stop/3` as `compile_output_file`,
`exunit_output_file`, and `spex_output_file` opts. The pipeline reads
pre-recorded JSON from those paths instead of whatever `mix` would write
at runtime. Real clients never send this field; production is unaffected.

```elixir
post(~p"/api/hooks/stop", %{
  "test_output_files" => %{
    "compile" => fixture_path("compile.jsonl"),
    "exunit"  => fixture_path("exunit.json")
  }
})
```

Fixture files live at `test/fixtures/validation/<scenario_name>/`.

### Existing cassette inventory

103 cassettes are checked in at `test/fixtures/cassettes/`. Key ones:

| Cassette | What it captures | Used by |
|---|---|---|
| `pipeline_compile_error.json` | compile only, exit 1 (no credo/test entries) | 5099 — proves pipeline short-circuits on compile error |
| `clean.json` | compile (ok) + test (ok, `--stale`) + credo (exit 14, no blocking issues) | 5098, 5101, 5594, 5587, 5586, 5564 — clean-run scenarios |
| `pipeline_exunit_failure.json` | compile + test (failure) | 5088, 5089 |
| `pipeline_credo_blocks.json` | compile + credo (violations) | credo-blocking scenarios |
| `credo_violation.json` | credo only | legacy single-tool scenarios |

> `pipeline_clean_run` exists only as a **validation fixture directory** at
> `test/fixtures/validation/pipeline_clean_run/` (the `compile.jsonl` /
> `exunit.json` files fed via `test_output_files`). There is no cassette
> named `pipeline_clean_run.json`. Specs that drive a clean pipeline use
> the `clean` cassette and the `pipeline_clean_run/` fixture dir together.

Shared cassettes (two specs using the same cassette name): 5088 and 5089
both use `pipeline_exunit_failure`. Record one at a time — see the
"Concurrent specs racing a shared cassette" gotcha in the framework doc.

### Fixture validation directory inventory

```
test/fixtures/validation/
  pipeline_clean_run/
    compile.jsonl   ← empty (0 bytes) = no diagnostics
  pipeline_compile_error/
    compile.jsonl   ← one error diagnostic on lib/example_context.ex:1
  pipeline_exunit_failure/
    compile.jsonl   ← empty
    exunit.json     ← one failing test
  pipeline_spex_failure/
    compile.jsonl   ← empty
    spex.jsonl      ← hand-crafted failure record (sexy_spex not in test repo)
  ...
```

**Empty `compile.jsonl` is load-bearing.** `Compile.execute` returns
`{:ok, []}` for a 0-byte file. Do not write `[]` or `{}` into it.

### Recording a new cassette — condensed recipe

```bash
# 1. Prep the pool repo as needed (add failing test, etc.)
# 2. Capture JSON output files
cd ../code_my_spec_test_repos/pool_code_repo_1
DIAGNOSTICS_OUTPUT=/tmp/compile.jsonl mix compile --return-errors
cp /tmp/compile.jsonl ../code_my_spec/test/fixtures/validation/<name>/compile.jsonl

# 3. Flip spec to record: :once, delete stale cassette
rm -f test/fixtures/cassettes/<name>.json
# (edit spec: record: :none → record: :once)

# 4. Run the spec
mix spex test/spex/<story>/<crit>_spex.exs

# 5. Flip back, verify replay
# (edit spec: record: :once → record: :none)
mix spex

# 6. Clean up pool repo side effects
# (remove any test files added during recording)
git -C ../code_my_spec_test_repos/pool_code_repo_1 status
```

Full recipe with error/spex failure variants: `priv/knowledge/bdd/spex/recording_cassettes.md`.

---

## ReqCassette — outbound HTTP (OAuth)

ReqCassette intercepts `Req`-based HTTP calls. In this repo it is used
exclusively for OAuth provider flows (Google, GitHub). Direct use in
spex files is intentionally avoided — all OAuth specs go through
`CodeMySpecSpex.OAuthHelpers`.

**How OAuthHelpers works:**

1. `build_google_cassette!/2` — loads a real-shape recording from
   `test/cassettes/oauth/google_login_shape.json`, injects a
   freshly-generated RSA keypair + signed id_token per test run, writes
   a temp cassette file to `test/cassettes/oauth/`. Deleted on_exit.
2. `do_google_callback/3` — calls `ReqCassette.with_cassette/3`, which
   injects a Req plug that replays the cassette instead of hitting
   Google's servers. `OAuthHelpers.with_assent_plug/2` swaps Assent's
   HTTP adapter for the duration.
3. Cassette options: `mode: :replay`, `match_requests_on: [:method, :uri]`.

**Re-recording shape cassettes:**

```bash
# Google
rm test/cassettes/oauth/google_login_shape.json
TEST_GOOGLE_REFRESH_TOKEN=<token_from_dev_db> \
  mix test --only record_google_login_shape

# GitHub
rm test/cassettes/oauth/github_login_shape.json
TEST_GITHUB_ACCESS_TOKEN=<token_from_dev_db> \
  mix test --only record_github_login_shape
```

Tokens live in the dev DB integrations table. See
`test/code_my_spec/integrations_test.exs` for the recording tests.

**For a new outbound HTTP integration** (not OAuth): add a Req-based
client, call `ReqCassette.with_cassette/3` directly, and store cassettes
in `test/cassettes/<integration_name>/`. Match on `[:method, :uri]` unless
request bodies also need matching.
