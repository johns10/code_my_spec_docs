# Validation Pipeline — Rules

## Rule: Changed files determine what analysis runs

The sync is the truth boundary. Whatever `sync_changed` finds dirty is the scope.
Task Agent uses `started_at` as the time window. Freestyle Agent uses whatever
sync_changed found on disk. The system is designed on the assumption that the
last sync surfaced everything relevant.

But the tools that run have their own scoping:
- Compile — whole project
- Credo — whole project (for now)
- Tests — `mix test --stale` (Elixir manifest handles dependency tracking)
- Spec validation — targeted to changed files
- Spex — `mix spex --stale`, only when task declares it

## Rule: The blocking check always runs, regardless of whether analysis ran

Even if zero files changed and we skip compile/credo/tests, we still query
the problems table. If there are unresolved problems from a previous run,
the agent is blocked until they're fixed.

## Rule: Compilation blocks before anything else runs

Compiler errors AND warnings both block. If `mix compile` produces any
diagnostics, the stop is blocked. No analyzers, no tests. Fix the compiler
output first.

## Rule: Credo blocks only on violations in changed files

Credo runs project-wide, but only violations on files the agent touched
are blocking. Credo problems on untouched files are ignored for the
blocking decision.

## Rule: Default blocking mode is block-all for tests

All test failures block the stop. All credo violations on changed files block.
All compiler diagnostics block. This is the hardcoded default until the
analyzer configuration UI exists.

## Rule: mix test --stale and mix spex --stale handle their own scoping

We don't figure out which test files to run. Elixir's manifest tracks
dependencies transitively. We pass --stale and trust it.
