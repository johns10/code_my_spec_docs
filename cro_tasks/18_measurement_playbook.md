# Measurement Playbook

**Priority:** Low (P4 — sustainability, do last)
**Area:** Documentation
**Status:** First draft shipped 2026-09-12 —
`.code_my_spec/knowledge/measurement_playbook.md`. Rules 4/7/8/9 (analytics
issue) are still open; revisit the playbook once they land rather than
waiting for them to write it.
**Source:** CRO diagnostic (Amplified Growth, 2026-08-01), FIX012

## Why This Exists

The analytics setup now spans multiple stories and issue files
(`analytics-tracking-and-traffic-filtering.md` and its Rules 1-11,
`ga4-missing-signup-event-trace.md`, `GaClientId`, the `cta_click` label
convention). That's institutional knowledge scattered across issue files
written for engineers debugging a specific defect, not a reference for
"how do I read the funnel" or "how do I add a new tracked event without
re-breaking something." Without this written down in one place, measurement
drifts back to broken within 3-6 months — which is exactly the failure mode
that produced most of the issues this backlog is fixing.

## Blocked By

The rest of this CRO backlog (Rules 4/7/8/9 in the analytics issue,
FIX001/006/007). Document what's actually true once it stops changing weekly,
not before.

## What It Should Cover

1. How events fire: server-side dispatch (the authoritative pattern — see
   Rule 1) vs. browser-side `gtag` (the `cta_click` delegated handler
   pattern — see Rules 10-11).
2. The `cta_click` label convention (`cta-<purpose>-<location>`) so new CTAs
   get labeled consistently instead of silently going untracked again.
3. UTM taxonomy (ties to `17_reddit_playbook_and_utm_convention.md`).
4. How to read the funnel end-to-end in GA4 (which reports, which key
   events, which custom dimensions exist and why).
5. The seven defects this engagement fixed (D1-D7 in the diagnostic) as a
   "don't let these recur" checklist.

## Definition of Done

- One document, likely in `.code_my_spec/knowledge/`, that a new engineer
  or the founder could use to add a tracked event or debug a measurement
  gap without re-deriving any of the history in the issue files above.
