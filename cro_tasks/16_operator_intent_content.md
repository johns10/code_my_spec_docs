# Operator-Intent Landing Content

**Priority:** Medium (P3 — revenue capped, long-term channel)
**Area:** Content / SEO
**Status:** Todo — blocked on ICP language validation
**Source:** CRO diagnostic (Amplified Growth, 2026-08-01), FIX010

## Why This Exists

Every non-brand query the site ranks for is engineer-intent (tool
comparisons: OpenSpec vs Spec Kit, Kiro, BMAD, Aider, Cursor, Claude Code).
Not one query in the diagnostic's top-50 sample comes from a business owner
describing a business problem. Meanwhile, all three paying customers to date
are non-technical, money-making operators who found the founder through
Reddit, not search. The ranking asset is real (7% of traffic, technical SEO
audit is clean per `technical-seo-remaining.md`) but pointed at the wrong
audience. This is a content-strategy gap, not a technical one.

## Blocked By

**ICP language validation.** Don't write operator-facing content from
assumption — the diagnostic's own customer-reality findings (n=3) say the
actual converting language is "I'm losing visibility / I'm lost with this
tool," not "I want an AI coding harness." FIX014 (qualitative research
rhythm) should produce real operator vocabulary before this content ships,
or at minimum draw directly from the existing Reddit-thread transcripts that
already converted someone.

## Locked Decisions

1. Target language: "I have a business problem, not a coding problem" — per
   the diagnostic and the one existing customer quote on file ("If you're
   good enough to hook up an MCP server, you don't need my MCP server").
2. 2-3 posts to start, not a full content pivot. Don't touch or retire the
   existing engineer-comparison cluster — that's a separate decision
   (tracked as the "SEO migration plan" in the diagnostic, not decided here).

## User Stories

### Story 1: A non-technical operator finds content that speaks to their problem

**As a** money-making operator who wants AI leverage but isn't a developer,
**I want** to find content describing my actual problem (not a tool
comparison),
**So that** I recognize CodeMySpec as relevant before I ever hit the
homepage.

**Acceptance criteria:**
- Given 2-3 posts targeting operator-intent, business-problem language
- When they're published
- Then they're indexed (verify via GSC, matching the sitemap-submission
  pattern already used for other content)
- And they link to the appropriate conversion path (`/install` or the
  "Built with you" tier, per what the post is about)

## Definition of Done

- 2-3 operator-intent posts live and indexed.
- Each links to a tracked CTA (see the analytics issue's Rules 10-11 for the
  label conventions already in place).
