# Reddit Playbook + UTM Convention

**Priority:** Medium (P2/P4 — channel clarity + scalability)
**Area:** Marketing process, not application code
**Status:** Todo
**Source:** CRO diagnostic (Amplified Growth, 2026-08-01), FIX008 + FIX013

## Why This Exists

100% of paying customers to date came from manual Reddit comments (founder
replies in r/SaaS-style threads about a business problem, buyer reads the
founder's entire post history, buyer engages). Reddit is also 48% of site
traffic. Right now that's a founder-dependent hobby, not a channel: nothing
documents which subreddits, which problem domains, or which comment formats
actually convert, and the UTM tags used when posting are inconsistent
(`reddit/comment`, `reddit.com/referral`, `reddit/social`,
`Reddit/Comment`, `reddit/post` all show up as separate values in GA4,
splitting the #1 channel's data five ways).

Verified 2026-09-12: there is no UTM-building code anywhere in
`code_my_spec_web` — this is entirely a posting-time convention problem, not
an engineering fix. (Compare: `CodeMySpecWeb.Plugs.GaClientId` already
solves the *unrelated* problem of untagged/stripped-referrer traffic
attributing to `(not set)` — that's server-side and already shipped.)

## Locked Decisions

1. One normalized UTM pair going forward: `utm_source=reddit&utm_medium=comment`
   for founder comments, `utm_source=reddit&utm_medium=social` for
   Reddit-native posts. Pick a single casing and stick to it (GA4 treats
   `Reddit/Comment` and `reddit/comment` as different values).
2. The playbook itself: which subreddits, which problem-domain framing,
   which comment formats converted historically (the two known-converting
   comments are the source material — pull from them directly rather than
   theorizing).
3. Historical data isn't worth normalizing retroactively — this fixes
   going forward only.

## User Stories

### Story 1: Reddit is measured as one channel

**As** the person running this CRO effort,
**I want** every Reddit link tagged with one consistent UTM pair,
**So that** Reddit's true contribution and ROI is visible as a single number
in GA4, not split five ways.

**Acceptance criteria:**
- Given the UTM convention is documented
- When any future Reddit comment or post links to the site
- Then it uses one of the two locked UTM pairs above, no variants

### Story 2: The playbook is repeatable beyond founder time

**As** the founder,
**I want** the "what converts on Reddit" knowledge written down,
**So that** this channel doesn't depend entirely on me personally commenting.

**Acceptance criteria:**
- Given the two historical converting threads (n=3 customers, 2 from one
  thread)
- When the playbook is written
- Then it names the subreddit(s), the problem framing that worked, and the
  comment structure/tone, in enough detail that someone else could
  replicate the approach

## Definition of Done

- UTM convention documented and in use for all new Reddit links.
- Reddit playbook written and stored in `.code_my_spec/knowledge/` or
  alongside the existing campaign docs in `campaigns/`.
