# Spex Boundary Tightening — route all spex into the app through Fixtures

Follow-up cleanup pass to enforce the "Fixtures is the only door from
spex into the app" rule end-to-end. The boundary tooling has been wired
up so violations are visible; the spex suite carries pre-existing debt
that bypassed the bridge while enforcement was a no-op.

## Background — what was broken, what's fixed, what's left

The `:spex` compiler (from the SexySpex library) wraps each
`test/spex/**/*_spex.exs` file into a configured boundary so cross-
boundary references can be checked. Without `spex: [pattern: ..., boundary: ...]`
in `mix.exs`, the compiler returns `:noop` and silently skips the
analysis. That was the state of this repo: the boundary was declared
in `test/support/code_my_spec_spex.ex`, but the compiler never ran
against the spex files, so direct calls into `CodeMySpec.*` modules
went unchallenged.

What's changed in the lead-in to this issue:

1. **`CodeMySpecSpex.Fixtures` is now its own top-level boundary**
   (`test/support/fixtures/spex_fixtures.ex`), with
   `deps: [CodeMySpec, CodeMySpec.Environments, CodeMySpecTest]`. The
   bridge is no longer nested inside `CodeMySpecSpex`, so the spex
   boundary itself does **not** depend on `CodeMySpec`.
2. **`CodeMySpec` and `CodeMySpec.Repo` are removed from
   `CodeMySpecSpex`'s `deps:`** in `test/support/code_my_spec_spex.ex`.
   The current door list is `[CodeMySpec.Environments,
   CodeMySpec.McpServers, CodeMySpecSpex.Fixtures, CodeMySpecWeb,
   CodeMySpecLocalWeb]`.
3. **The `Sync.sync_path/2` "file changed" event has been routed
   through `Fixtures.notify_file_changed/2`** — this is the model
   pattern for everything else this issue cleans up. See spex 5922,
   5923, 5934, 6085 for the rewired examples.
4. **`mix.exs` `spex: [pattern: ..., boundary: ...]` config is currently
   reverted** so the violations don't block the build. **Re-enable it
   as the last step of this cleanup** once zero violations remain.

## What the next agent needs to read before starting

These are non-negotiable. Read them all, in this order.

### Framework rules (project-agnostic)

- `priv/knowledge/bdd/spex/boundaries.md` — what spex can call, what
  `then_` is allowed to read, the "approved doors" rule, the anti-pattern
  of seeding server-side state directly.
- `priv/knowledge/bdd/spex/writing_a_spex.md` — DSL, file layout,
  anchor-assertion rule, single-action `when_` rule.
- `priv/knowledge/bdd/spex/environment.md` — memfs, stub dir, cassettes.

### Project-specific rules

- `.code_my_spec/knowledge/bdd/spex/surfaces.md` — the four real
  surfaces in this codebase (MCP / HTTP-hook / LiveView / filesystem),
  plus the file-change event surface added during the lead-in (Sync
  via Fixtures).
- `.code_my_spec/knowledge/bdd/spex/cassettes.md` — cassette playbook.
- `.code_my_spec/knowledge/bdd/spex/four_surfaces_quick_reference.md`.

### Stored feedback (project memory)

- `feedback_no_db_in_thens.md` — `then_` may only observe via HTTP
  response / LiveView render / MCP tool. Never `Repo`.
- `feedback_no_internal_calls_in_when.md` — `when_` calls MCP tool
  modules, HTTP hooks, LiveView. Not contexts, not `Repo`, not
  internal services.
- `feedback_no_fixtures_in_spex.md` — `given_` setup goes through the
  app's surface (LiveView / Conn / MCP) when possible; Fixtures is
  the bridge for **state that originates server-side and syncs into
  the local app** (users, accounts, projects), not for local-only
  state that the user would create through the UI.
- `feedback_sync_path_is_a_surface.md` — explicit classification of
  the new file-change surface and how the `Sync.sync_path/2` →
  `Fixtures.notify_file_changed/2` rewrite works.
- `feedback_three_amigos_titles.md`, `feedback_no_manufactured_examples.md`
  — title and example discipline.

### Actual boundary declarations to keep in mind

- `test/support/code_my_spec_spex.ex` — the spex boundary's allowed
  doors. Do NOT add to this list to silence a violation. Either route
  through Fixtures, or drive the surface (LiveView / HTTP / MCP) the
  user would actually touch.
- `test/support/fixtures/spex_fixtures.ex` — the bridge. Adding a
  function here is the right move when the underlying call is genuinely
  "state that originates server-side." It is the **wrong** move when
  the spex is testing a local user action that should be driven through
  the LiveView or hook surface.

## The punch list — ~100 forbidden references

Counts produced by running `MIX_ENV=test mix compile --force` after
adding the `spex:` config block back to `mix.exs`. Numbers shift
slightly run-to-run if files are touched; re-grep before starting each
batch.

| Module | Count | Likely remediation |
|---|---:|---|
| `CodeMySpec.Paths` | 30 | Likely just path constants (e.g. `Paths.base_dir/0`). Add narrow delegates to Fixtures: `defdelegate base_dir(), to: Paths` etc. |
| `CodeMySpec.IssuesFixtures` | 29 | Already a `*Fixtures` module — `defdelegate` lines through `CodeMySpecSpex.Fixtures`. Check the existing aliased fixture pattern in `spex_fixtures.ex` lines 19-37. |
| `CodeMySpec.AgentTasks.ProjectSetup` | 19 | **Suspect.** ProjectSetup is a setup-evaluator module. Most callers are in story 124 specs. Decide per-spec: is the scenario testing the *engineer's setup flow* (drive `/projects/<name>/configuration` or `/sync` LiveView)? Or is it asserting on an internal computation? The latter is a unit-test concern, not a spex. |
| `CodeMySpec.Personas` | 7 | If the spex is creating a persona, it should drive the `CreatePersona` MCP tool (see `shared_givens.ex :persona_exists`). If reading persona state, that's a `then_` violation. |
| `CodeMySpec.AgentTasks.ComponentCode` | 5 | Same shape as ProjectSetup — likely should be driven through the agent surface (MCP / hook) or moved out of spex. |
| `CodeMySpec.ProjectSync.Sync` | 0 ← already done | Pattern: `Fixtures.notify_file_changed/2`. Done in 5922, 5923, 5934, 6085 — copy the pattern if any new violations appear. |
| `CodeMySpec.Users.Scope` | 2 | Scope is constructed by setup helpers. Direct references probably indicate a spec building a scope manually — should use `setup_active_project` / `setup_active_account` instead. |
| `CodeMySpec.AcceptanceCriteria` | 2 | Decide per call: surface this through an MCP tool (acceptance criteria are agent-creatable) or through Fixtures if the test is about server-originated state. |
| `CodeMySpec.Sessions`, `CodeMySpec.Sessions.Session` | 2 | Session creation is done through `/api/hooks/session-start` (see `shared_givens.ex :bdd_task_started`). Direct calls should be replaced with the hook. |
| `CodeMySpec.Problems` | 1 | Single reference, likely a `Fixtures.problem_fixture/2`-style seed. Already a delegated pattern — check Fixtures and add if missing. |

## Process

1. Re-enable the spex compiler config:
   ```elixir
   # mix.exs in project/0:
   spex: [pattern: "test/spex/**/*_spex.exs", boundary: CodeMySpecSpex],
   ```
2. Run `MIX_ENV=test mix compile --force 2>&1 | grep "forbidden reference"`
   to get the fresh punch list.
3. Pick one violated module at a time (start with the biggest count for
   throughput, or the messiest semantically for judgment first — your call).
4. For each spex file referencing that module:
   - Read the spec. Decide: surface drive or Fixtures wrapper?
   - If surface: rewrite the `given_`/`when_` to drive LiveView / MCP /
     hook. Existing shared givens in `test/support/shared_givens.ex`
     show the patterns.
   - If Fixtures: add a narrow `defdelegate` (or wrapper function with
     intent-revealing name) to `CodeMySpecSpex.Fixtures`. Group with
     existing sections.
5. After each batch, run the affected spex files (`mix spex test/spex/<story>/`)
   to confirm green.
6. When the punch list hits zero, the boundary tightening is complete.
   The `:spex` config in mix.exs stays on permanently — this is the
   gate that prevents regression.

## What NOT to do

- Do **not** add `CodeMySpec` back to `CodeMySpecSpex`'s `deps:`. That
  defeats the entire point.
- Do **not** add modules to Fixtures just to silence a violation. If
  the right answer is "drive the LiveView," do that.
- Do **not** weaken the spex by changing what it asserts. The spex
  describes user-observable behavior; tightening the door doesn't change
  the contract.
- Do **not** turn off the `:spex` compiler config to make the warnings
  go away. The whole point is keeping it on.

## Verification

When done:

```bash
MIX_ENV=test mix compile --force 2>&1 | grep -c "forbidden reference"
# expected: 0

mix spex
# expected: green
```

Update `priv/knowledge/bdd/spex/boundaries.md` to reflect the four
real doors (`Environments | McpServers | Fixtures | <App>Web`) — the
doc was the original gold standard; the suite has now caught up.

## Origin

Issue surfaced in the spex coverage tightening session (May 2026). The
file-change surface refactor (Sync module + Fixtures bridge) proved
the pattern works; this issue is the cleanup to apply it across the
rest of the suite.
