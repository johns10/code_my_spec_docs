# Install Page Email Capture

**Priority:** On hold — premise changed
**Area:** `/install` — non-technical-visitor safety net
**Status:** On hold. `/install` is going to become a gated, post-signup page
(the harness can't be used standalone yet, so install happens after signup,
not instead of it). That removes the reason this task existed — a visitor
who can't self-serve install won't reach `/install` at all anymore; they'll
bounce at signup, which is a different problem than this task was solving.
**Source:** CRO diagnostic (Amplified Growth, 2026-08-01), FIX001

## 2026-09-12 update

Before this surfaced, a generic capture backend was built (migration, a
`CodeMySpec.Leads` schema + context, a `POST /install/email-capture`
controller action), unwired to any form — nothing user-facing shipped. Per
John, everything should drive signups for now, and gating a freebie behind
lead capture is explicitly undecided ("I'm not sure"). **Removed rather than
left dormant** (John: "remove the leads backend") — no half-built,
disconnected infrastructure sitting in the tree. If a real gated-freebie
need shows up later, this is small enough to rebuild from scratch against
whatever the actual requirement turns out to be, rather than guessing now.

**Also flagged:** the four "Start free" CTAs instrumented in Rule 10
(analytics issue) all point at `/install`. Once `/install` is actually
gated, those need a new destination — John's read is "either
`/users/register` or whatever the agent/chat entry point ends up being
(probably the homepage hero)," tied to the same onboarding integration as
FIX009 (stories 990/992, `agent-conversation-ui`). Left as-is for now per
John: don't touch until that flow is decided. Re-visit this task once it
is.

## Why This Exists

`/install` has no signup form and no email capture. Every visitor who lands
there but can't or won't run `brew install` — can't use a terminal, on a
locked-down work machine, just wants to be notified later — bounces with zero
trace. At current traffic (~1,400 sessions/month sitewide per the diagnostic),
even a 5% capture rate on `/install` visits recovers leads that currently
disappear entirely. This is the single lowest-effort fix on the list.

Related: `/install` already has a "Talk to John instead" recovery link
(`install.html.heex:265`, now instrumented — see the analytics issue). Email
capture is the *other* recovery path, for visitors who aren't ready for a
call either.

## Locked Decisions

1. A single email field, not a full form. Copy direction: "Get notified when
   the no-install version is ready" (matches the diagnostic's suggested
   framing and is honest about what's actually being offered).
2. Placement is a design call — the natural spot is near the existing
   "Build it with me instead" section (`install.html.heex:260-267`), since
   that's already the page's acknowledgment that not everyone wants the CLI
   path.
3. This is a safety net, not a redesign of `/install`. Don't touch the
   OS/agent tab selector or install commands.

## User Stories

### Story 1: A visitor who won't run the install captures their email instead

**As a** visitor on `/install` who isn't going to run a terminal command,
**I want** a simple way to say "email me when this is easier,"
**So that** the visit isn't a total loss for either of us.

**Acceptance criteria:**
- Given a visitor on `/install`
- When they submit a valid email in the capture field
- Then the email is stored (reuse whatever lead-capture mechanism already
  exists elsewhere in the app; don't build a new one if one exists)
- And a `data-event-label="cta-email-capture-install"`-style event fires so
  this is visible in GA4 alongside the other `/install` CTAs
- And the visitor sees a clear confirmation, not a silent no-op

### Story 2: The capture rate is measurable

**As** the person running this CRO effort,
**I want** to know the capture rate on `/install`,
**So that** I can tell whether this recovered anything.

**Acceptance criteria:**
- Given the email capture has been live for at least a week
- When someone checks GA4 for the new event
- Then submissions are queryable and can be compared against `/install`
  sessions to compute a capture rate

## Definition of Done

- Email field live on `/install`, submissions persisted, event tracked.
- No regression to the existing install-command or recovery-CTA flows.
