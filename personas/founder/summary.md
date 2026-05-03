# Solo Shipper Sam

> "I want to run a software business by myself. The LLM does the labor. I do the thinking."

Proto-persona for CodeMySpec's primary user — the bootstrapped, technical solo founder who already lives inside LLM coding tools and is tired of the fiddle tax. Built from (a) the founder of CodeMySpec being one and (b) triangulation against public bootstrapper / indie-hacker sources. Mark as proto: validate against 5+ live customer interviews before treating any claim here as load-bearing.

## Role

Solo founder of a software business. Team of one. Bootstrapped — not VC-funded, has not raised, will not raise. Technical or semi-technical: can read code, ship a Phoenix or Next.js app, but doesn't want to write every line. Already a daily user of Claude Code, Cursor, or equivalent. Usually beyond first-time shipping, but a determined first-timer fits.

Plays every role in the business: builder, marketer, operator, support, accountant — and is the buyer of every tool the business uses. No procurement department, no internal champion, no committee. [E2, E3, E4]

## Goals

**Run a software business with one person's effort.** End goal — a real product, real customers, real revenue, run by one human. Existence proof: Pieter Levels at $3M ARR with zero employees, Marc Lou at $1M+ across three products with zero employees. The ceiling for a one-person software business with modern tooling is well past $1M ARR. [E1, E5]

**Get out of the engineering loop.** Spec → product writes itself → modify spec → product updates. Same round-trip for marketing copy via Market My Spec. The product is a cockpit; the human is the pilot, not the engine. [E3, E6]

**Move fast without the fiddle tax.** Every hour spent re-grounding an LLM that lost context is an hour stolen from the business. The point of the agent stack is leverage, not babysitting. [E2, E6, E7]

## Pain Points

**Agent drift and context loss.** AI coding agents start strong and degrade as the codebase grows. Qodo's 2025 report: 65% of developers say AI assistants "miss relevant context" during refactoring. Context drift compounds when team conventions evolve and the agent keeps generating to outdated practices. Developers describe Claude Code as "the tool they reach for when other tools fail" — but still hit context-window amnesia across sessions. [E6, E7]

**Wearing every hat as a team of one.** Solo founders context-switch all day — "six hats, each requiring a complete mental reset" — and the cognitive switching depletes mental energy faster than deep work. ~70% of a solo founder's time goes to admin/operational tasks that don't drive growth. [E2]

**Burnout risk.** 70%+ of solo founders report significant burnout within their first 18 months. The product has to give time back, not eat it. [E2]

**Self-service or it dies on the vine.** Sam is the buyer, user, and payer in one person. If onboarding asks for a sales call or a 30-day implementation, Sam is gone before the email lands. [E3]

## Context

**Population is real and growing.** Solo-founded startups rose from 23.7% of new starts in 2019 to 36.3% by mid-2025. TinySeed reports 60–70% of bootstrapped SaaS founders are solo; 90% are solo or two-person. [E3, E4]

**Already inside the AI agent stack.** The 2026 solo founder runs a $300–500/month tool stack (Cursor, Claude Code, Zapier, content tools, ops automation) that replaces what would have been $80k–$120k/month in payroll. They are pre-converted on the LLM thesis; the open question is which orchestration layer wins. [E3, E6]

**Context engineering is the new bottleneck.** "The critical skill in 2026 is context engineering — building the information architecture that surrounds agents so they are reliable across complex, multi-step tasks." That infrastructure is specs, rules, knowledge bases, requirements graphs — exactly what CodeMySpec produces. [E6]

**Ship-fast culture.** Levels' 12-startups-in-12-months and Marc Lou's feature-scoped launches define the cultural baseline: validate in public, ship in days, kill what doesn't sell. Tools that add ceremony lose to tools that ship. [E1, E5]

## Decision Drivers

**"Does it pay for itself in hours saved?"** The math is fiddle-hours-saved × Sam's value-of-time minus subscription cost. Pricing has to respect a one-person budget and the marketing has to do the time-saved math out loud. [E2, E3]

**"Can I onboard myself in one sitting, on a Saturday, sober?"** No sales call. No implementation engagement. The product has to demo-itself from a landing page to a running spec → generated component in under an hour. [E3]

**"Does the spec round-trip actually work?"** Sam will test by editing one spec and watching whether the product re-generates without re-fiddling. If yes, they convert. If they have to re-prompt the agent every time, they fall back to raw Claude Code.

**"Is this built for me, or for an enterprise team?"** Marketing, defaults, and roadmap all need to read as "one person, one cockpit." Enterprise features (RBAC, SSO, audit logs) signal Sam is not the customer; agency / consultancy framing signals the same.

## Anti-Patterns

Explicit non-targets — we are **not** designing for these and should resist requests that pull us toward them:

- **Non-technical solo founders.** Can't read the specs the system generates, can't fix the small percentage of agent output that needs human judgment, can't operate the cockpit. Different product, different category.
- **Founders not already using LLMs daily.** Skeptics need to be converted to LLM-assisted development first. Conversion is somebody else's funnel; Sam is already on the other side.
- **VC-funded scaling teams.** Their constraint isn't one-person time; it's hiring velocity and process scale. Different decision drivers, different tooling.
- **Agency / contractor shops.** Multiple clients, multiple codebases, different billing model. Not Sam.

## Evidence

Every claim above traces to one of the entries below. Sources are listed in full with URLs and access dates in `sources.md`.

- **E1** — Pieter Levels solo bootstrapper case studies. Multiple independent reports of $3M ARR, zero employees, ship-in-24-hours culture, boring stack, 12-startups-in-12-months challenge.
- **E2** — Solo founder time scarcity, decision fatigue, and burnout sources. Multiple independent confirmations: 70% burnout in 18 months, 70% time on admin/ops, six-hats cognitive switching cost.
- **E3** — Indie Hackers / 2026 solo founder AI stack sources. Multiple independent confirmations: $300–500/mo stack replacing $80k–$120k/mo payroll, self-service buyer, solo % rising 23.7% → 36.3% (2019 → mid-2025).
- **E4** — MicroConf / TinySeed Stair Step bootstrapping sources. Multiple independent confirmations: 60–70% TinySeed founders solo, 90% solo+two-person, replace-job-income-then-build-recurring playbook.
- **E5** — Marc Lou / ShipFast solo studio sources. Multiple independent reports: solo studio, $1M+ across three products in 2025, feature-scoped launches, ship-fast playbook.
- **E6** — AI coding agent drift / context engineering sources. Multiple independent confirmations: 65% miss-context rate (Qodo), context drift as conventions evolve, "context engineering" as the 2026 critical skill.
- **E7** — Claude Code adoption / "tool you reach for when others fail" sources. Multiple independent reports: 46% most-loved rating, used as escalation when Cursor/Copilot fail, context-window amnesia complaints.
