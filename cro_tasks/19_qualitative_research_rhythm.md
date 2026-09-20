# Qualitative Research Rhythm

**Priority:** Medium (P4 — ongoing, low effort, high leverage at current traffic)
**Area:** Process
**Status:** Todo
**Source:** CRO diagnostic (Amplified Growth, 2026-08-01), FIX014

## Why This Exists

At current sign-up volume, A/B testing on the signup event isn't
statistically viable — the sample size is too small to trust a result.
Qualitative research (user interviews) becomes the primary optimization
input instead. One interview typically surfaces 3-5 testable hypotheses;
over a quarter that replaces guesswork with evidence. This also directly
unblocks `16_operator_intent_content.md`, which needs real operator
vocabulary rather than assumed language.

## Locked Decisions

1. Cadence: ~5 interviews/month, non-technical operators matching the ICP
   (money-making operators who want AI leverage but can't/won't touch a
   CLI — see the diagnostic's n=3 customer profile).
2. Owner: founder + product. No tooling investment needed — this is calendar
   discipline, not a build.
3. Source candidates first: the two Reddit threads that already converted
   customers are a starting point for who to talk to, alongside new
   `/install` email-capture leads once `14_install_page_email_capture.md`
   ships.

## User Stories

### Story 1: A monthly interview rhythm exists

**As** the founder,
**I want** a standing practice of talking to 5 operators/month,
**So that** product and content decisions are grounded in what real
non-technical users actually say, not assumption.

**Acceptance criteria:**
- Given a month has passed
- When the rhythm is checked
- Then at least some interviews were conducted (this is a process
  commitment, not a feature — "done" is a habit, not a shipped artifact)
- And each interview produces at least one written, testable hypothesis
  (stored wherever `.code_my_spec/knowledge/` or `campaigns/` research notes
  already live)

## Definition of Done

- First interview conducted and its hypotheses written down.
- A recurring calendar commitment exists (not tracked as code — this task
  closes once the habit is established, not once a tool is built).
