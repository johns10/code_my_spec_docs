# Acceptance Criteria — Stop Response Compactness

Story 554 — Validation Pipeline Redesign: Stop Response Compactness.
Criteria continue the auto-increment from Story 553 (5081–5090).

The stop-hook response goes directly into the agent's context window.
Blocking responses today include multi-line raw problem messages
(stacktraces, assertion left/right dumps) and the full enumeration of
advisory problems the agent cannot act on this turn. That bloat burns
context budget the agent needs for the fix. These criteria tighten the
formatter.

## 5091 — Advisory problems are summarized, not enumerated, when the stop is blocked

When the stop is blocked AND advisory problems exist (e.g. exunit
failures demoted by `dont_block`, compile warnings under
`compile_warnings: :dont_block`, or failures on untouched components
under `block_changed`), the blocking response enumerates only the
blocking set and represents the advisory set as one summary line per
source: `<source>: <count> <severity>s (advisory)`. No individual
advisory file paths, line numbers, or messages appear in the response.

Spec: `test/spex/554/5091_spex.exs`

## 5092 — Advisory problems do not appear in an allow response

When the stop is allowed AND only advisory problems exist (nothing
blocking), the response is the allow signal (empty map, `%{}`). The
advisory problems are logged server-side; none of them reach the
agent's context via the response body.

Spec: `test/spex/554/5092_spex.exs`

## 5093 — Blocking problem messages are compacted to one line

Each blocking problem renders as a single line:
`file_path:line — first line of message, truncated to ~200 chars`.
Multi-line raw message bodies — stacktraces, assertion `code:` /
`left:` / `right:` dumps, trailing newline noise — are stripped.

Spec: `test/spex/554/5093_spex.exs` *(implemented, awaiting formatter)*

## 5094 — Per-source enumeration is capped

Each source (credo, exunit, spex, compiler, …) lists at most N
blocking problems inline (current cap: 10). Overflow is indicated with
a footer: `... <remaining> more <source> problems (use get_issue to
inspect)`.

Spec: `test/spex/554/5094_spex.exs`

## 5095 — Total response size is hard-capped

The full `reason` string is capped (target: 4 KB). When blocking
problems would otherwise exceed the cap, later problems are omitted
with a tail footer: `... <N> more problems omitted (response size
limit)`. The response body fits under the cap.

Spec: `test/spex/554/5095_spex.exs`

## 5096 — A single blocking problem is never overflow-truncated

A single blocking problem with a long message is compacted per 5093
(message truncated to ~200 chars) but never triggers the 5095
overflow footer. One problem always fits.

Spec: `test/spex/554/5096_spex.exs`

## Implementation notes

- 5091, 5092: change `Validation.decide/2` — when blocking list is
  non-empty, swap full advisory enumeration for a one-line-per-source
  summary. When blocking is empty, keep the current `:ok` (logged-only)
  behavior — no format change needed there, just assertion coverage.
- 5093, 5094, 5096: change `format_problem_group/1` and the per-item
  renderer — compact the message, keep the existing `Enum.take(10)` cap,
  surface the overflow footer.
- 5095: new top-level size check after assembly; applies to both the
  blocking enumeration and the advisory summary line(s).
- Per-problem and total caps are constants; propose `@per_problem_cap
  200` and `@total_response_cap 4096` at the top of the formatter
  module.
