---
component_type: "*"
session_type: "*"
---

# Analysis Is Explicit

**Nothing starts an analyzer run implicitly.** The subprocess sources —
compiler, credo, exunit, spex — run only when something asks for them by
name: an agent calling `start_analysis`, an operator's manual request, or
promote, which requires fresh results before it lands.

Never enqueue a run as a side effect of a hook, a turn ending, a subagent
stopping, a file scan, or a sync. The stop hook reads the problems already
recorded and decides from those; it does not start the runs that would
produce new ones.

**Why.** Machine-wide analyzer concurrency is one. A run started as a side
effect competes for that slot with runs somebody actually asked for, and a
leg that keeps failing stays stale — so if staleness triggers a run, the run
re-triggers itself. On 2026-09-27 that was one project's 25-minute spex
sweep, failing on a missing test database, re-requested after every scan and
holding the only slot for everyone.

A criterion that needs a run in flight starts one explicitly. A criterion
asserting that some event *causes* a run is asserting the thing this rule
forbids.
