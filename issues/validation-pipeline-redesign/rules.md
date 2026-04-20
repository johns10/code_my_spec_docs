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

## Rule: Advisory problems in a blocking response are summarized, not enumerated

When the stop is blocked AND there are advisory problems (e.g. test
failures on untouched components under `block_changed`), the blocking
response must summarize the advisory set by source + count only — it
must not enumerate each advisory problem. The agent cannot act on
advisory problems this turn (they're not in scope), so enumerating
them wastes the agent's context window.

When there are no blocking problems, advisory problems are not
included in the response at all — they're logged server-side and
surface through the UI.

## Rule: Blocking problem messages are compacted

Each blocking problem renders as one line: `file_path:line — first
line of message, truncated to ~200 chars`. Stacktraces, assertion
left/right dumps, and multi-line messages get truncated. The agent
has `get_issue` / UI tools to inspect any single problem in full —
the stop response exists to tell them *what* to fix, not to reproduce
the full failure.

## Rule: Stop response body has a hard size ceiling

The total formatted `reason` string is capped (target: 4 KB). If
blocking problems would exceed the cap, the per-source listing is
truncated and a footer like `... 12 more problems (use get_issue to
inspect)` is appended. This prevents runaway output from pathological
cases (e.g. 500 sobelow findings) from blowing past the agent's
context budget.
