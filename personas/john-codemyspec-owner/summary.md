# John Davenport — CodeMySpec Owner

> "I need to read the funnel end-to-end without a prod cross-check. The instrumentation has to survive the agent loop, and I'm not building an observability platform — I'm shipping a developer tool."

Profile of the operator running CodeMySpec. Distinct from Solo Shipper Sam (the abstract target customer) — John is the concrete person who triages issues, signs off on scope, reads daily analytics snapshots, and dogfoods the harness on his own products. The persona exists so stories scoped to operator concerns (analytics tracking, issue triage, requirements graph) have a real voice attached. [E1, E2, E3]

## Role

Founder of CodeMySpec, a development harness for Elixir/Phoenix/LiveView applications shipping as a Claude Code extension. Concurrently Data Engineer at Openforce — a fintech platform processing ~$6B/year for 60,000+ companies and 350,000+ contractors. Full stack software engineer with 20+ years across enterprise systems, manufacturing IT, and Elixir/Phoenix development. Speaker at ARC Conference 2018. [E1, E5]

Bootstrapped. Team of one. Wears every hat — builder, marketer, operator, support — and is the buyer of every tool the business uses. [E1, E4]

## Goals

**Read the funnel end-to-end without prod cross-checks.** Operates from daily analytics snapshots (`code_my_spec_marketing/.code_my_spec/knowledge/analytics-snapshots/`). When GA4 reports diverge from prod truth, the snapshot becomes untrustworthy and the marketing loop stalls. Wants a single source of truth that doesn't require manual reconciliation. [E3, E4]

**Ship the product, not the observability platform.** Funnel instrumentation is necessary but not the product. Resists building reconciliation jobs, alert pipelines, and metric-collection infra unless they pay back in operator-hours saved per week. Strong preference for thin observability (structured logs, fixed dashboards) over rich observability (custom collectors, alerting). [E3, E4]

**Dogfood CodeMySpec on every product he builds.** Fuellytics (5 days, zero human-written code, 5-validator fraud pipeline) and MetricFlow (13 days, 12 contexts, 6 platform integrations) were both shipped using the harness. The harness has to survive its own operator's workflows. [E2, E3]

**Authentic voice through dictation, not LLM drafting.** Was called out for AI-generated content early; switched to dictating raw ideas and having the LLM clean them up. Marketing copy and posts now read as his voice, not a template. [E4]

## Pain Points

**Silent dropped events.** A signup that doesn't reach GA4 looks like a marketing failure when it's actually an instrumentation gap. The 2026-05-21 missed `sign_up` event for faturrachman6773 is the load-bearing example: no logs, no alert, only caught by manual prod cross-check on the next-day snapshot. Cost ~2 hours to diagnose. [E2, E3]

**Bot/(not set) traffic distorting funnel ratios.** When `(not set)` source share jumped from 8% to 27% in one week, every engagement-rate read in the snapshot became unreadable without manual bot correction. Manual correction doesn't scale across daily snapshots. [E3]

**gtag page-speed cost.** Browser-side `gtag.js` measurably hurts page-speed metrics on the marketing site. Pays the perf cost on every visitor for client-side telemetry that could happen server-side. [E2]

**Agent context loss inside the harness.** When the agent loop drifts off-spec or papers over real bugs, the operator catches it in QA — but only because John is the one reading every QA result. The harness has to be self-policing because there's no team to catch the agent's misses. [E3]

**Time leakage to non-product work.** As a one-person team also working at Openforce, every hour spent on infrastructure friction (broken cassettes, stale binaries, harness friction) is an hour not shipping product. [E1, E5]

## Context

**~20 years of full-stack engineering, 15+ in manufacturing IT.** Brings a brownfield/legacy-modernization mental model to greenfield startup work — comfortable with messy production data, comfortable with multi-system integration. Not a Greenfield-only operator. [E1]

**Polyglot stack chops.** Elixir, Phoenix LiveView, Python, TypeScript, C#, PostgreSQL, GraphQL, CQRS, Event Sourcing. CodeMySpec is opinionated on Elixir/Phoenix not because John can't use other stacks but because Elixir gives him the most leverage per line. [E1]

**Already deep in the LLM agent stack.** Daily Claude Code user; built MCP integrations (Reddit Buddy, GA4, Search Console, Vibium browser automation) as standard tooling. Pre-converted on the LLM thesis. [E2, E4]

**Marketing-aware engineer.** Built MarketMySpec because past projects failed from skipped marketing. Treats analytics, SEO, Reddit engagement, and content cadence as engineering problems with daily measurement loops. $3,500 in pre-launch commitments before paying users. [E4]

**Public footprint exists but is engineering-focused.** GitHub (`johns10`), LinkedIn, conference talk at ARC 2018. Not a high-volume public-content creator — most output is product code and shipped artifacts, not blog posts. [E1, E6, E7]

## Decision Drivers

**"Does it eliminate a manual cross-check?"** Instrumentation work pays back when it removes a recurring manual reconciliation from the daily snapshot. Work that only flags problems doesn't qualify; work that removes the need to ask qualifies. [E3, E4]

**"Is this our domain?"** Strong filter against scope-creep into adjacent infrastructure (alerting platforms, observability stacks, custom analytics collectors). If it's not core to the dev harness or core to operating the dev harness, it's somebody else's product. [E3]

**"Can the agent loop ship this without me?"** Preference for work the harness can execute end-to-end via BDD specs, code generation, and QA — not for work that requires John to manually drive every step. The harness has to ship its own roadmap. [E2, E3]

**"Will this survive the next missed event?"** Forward-looking observability test: can I trace the next dropped signup from server logs alone, or do I have to manually correlate against prod? If the answer is logs alone, the instrumentation is sufficient. [E2, E3]

## Anti-Patterns

Explicit non-targets — these signal the work is mis-scoped for this operator:

- **Defensive infrastructure for problems that shouldn't recur.** Daily reconciliation jobs after a logging fix is suspenders-on-suspenders.
- **Per-incident alert pipelines.** Operator reads daily snapshots and triages from there; doesn't want pages.
- **Vanity metrics without conversion signal.** Page views matter only as upstream of activation events.
- **Observability platforms.** GA4 + structured server logs + daily snapshot is the stack; not building a parallel one.

## Evidence

- **E1** — `resume/resume-site/src/content/overview.md` — primary identity, 20+ years experience, key expertise breakdown, contact details.
- **E2** — `resume/resume-site/src/content/projects/codemyspec.md` — CodeMySpec project detail: 368 modules, 46 contexts, what it proved on Fuellytics and MetricFlow.
- **E3** — `code_my_spec/.code_my_spec/issues/ga4-missing-signup-event-trace.md` and `analytics-tracking-and-traffic-filtering.md` — operator-authored issue files articulating analytics pain points in his own words.
- **E4** — `resume/resume-site/src/content/projects/marketmyspec.md` — marketing approach, dictation workflow, $3,500 pre-launch commitments, MCP stack inventory.
- **E5** — `resume/resume-site/src/content/organizations/oforce.md` — Openforce concurrent role, scale of fintech platform.
- **E6** — `https://github.com/johns10` — GitHub profile referenced in resume overview; engineering-focused public footprint.
- **E7** — `https://www.linkedin.com/in/johndavenport` — LinkedIn profile referenced in resume overview.
