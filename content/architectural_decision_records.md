# ADRs Are the Guardrails Your AI Agent Actually Reads

Most teams treat Architecture Decision Records as documentation. Write them once, file them away, forget they exist. I've done it too. But here's the thing: when an AI coding agent is generating your code, ADRs stop being documentation and start being the only thing standing between a coherent codebase and architectural chaos.

## What ADRs Are (30-Second Version)

An ADR captures one technical decision: what you chose, why you chose it, and what you gave up. Michael Nygard [proposed the format](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions) back in 2011. Status, Context, Decision, Consequences. That's it. Most teams skip them because writing docs feels like busywork. That calculus changes completely when agents enter the picture.

## Why ADRs Matter More With AI Agents

An AI agent doesn't have institutional memory. It doesn't remember that your team tried Redux and hated it, or that you picked LiveView specifically to avoid a JavaScript build pipeline. Every time it starts a task, it's working from whatever context you give it.

Without ADRs, you get drift. The agent picks Express when you standardized on Phoenix. It reaches for React when you committed to LiveView. It adds a new ORM when you already have Ecto. Research from [ArXiv shows coding agents will increasingly violate constraints](https://arxiv.org/html/2603.03456v1) over time, especially under ambiguity. ADRs eliminate that ambiguity.

An agent that reads "Use Phoenix LiveView for interactive UI" with context explaining why - no separate frontend build pipeline, server-rendered reactivity over WebSockets - makes fundamentally different choices than one flying blind.

## The Pre-Made Decisions Pattern

Here's my favorite approach: write your standard stack decisions before any coding starts.

In CodeMySpec, the TechnicalStrategy module ships with [pre-made ADRs](https://codemyspec.com) for every standard stack choice. When a project kicks off, decisions like "Use Elixir as the primary language" and "Use Tailwind CSS for styling" get written automatically with full context. The agent reads them and follows them. No discussion needed.

Then for anything outside the standard stack - maybe you need a payment processor or a specific caching strategy - the agent does cursory research, evaluates options against project needs, and writes a new ADR for human review. Two phases: auto-write the obvious stuff, deliberate on the rest.

This is not a path for the lazy. You still need to think through your stack. But you only think through it once, and every agent on every project inherits those decisions.

## Structuring ADRs for Agent Consumption

Agents parse markdown. They're good at it. But structure matters. Here's what works:

```markdown
# Use Phoenix LiveView for interactive UI

## Status
Accepted

## Context
We need rich, interactive user interfaces without the complexity
of a JavaScript SPA framework.

## Decision
Use Phoenix LiveView for all interactive UI. It enables
server-rendered reactive interfaces over WebSockets, eliminating
the need for a separate frontend build pipeline.

## Consequences
- No React/Vue/Svelte expertise needed
- Real-time features come nearly free
- Heavy client-side computation stays on the server
- SEO works out of the box (server-rendered HTML)
```

Keep each ADR in its own file. Name it by topic (`liveview.md`, `deployment.md`). Maintain an index file that lists every decision with its status. The agent can scan the index, then read individual records when it needs the full context.

## Making ADRs Executable: The Archgate Concept

ADRs that agents read are good. ADRs that CI enforces are better.

[Archgate](https://archgate.dev/) turns ADRs into executable rules. Each decision record gets a companion `.rules.ts` file that runs checks against your codebase. Import React in a LiveView project? CI catches it. Add a dependency that conflicts with an accepted decision? Blocked before merge.

This is where ADRs graduate from "guidelines the agent should follow" to "constraints the pipeline enforces." The agent reads the ADR and tries to comply. The CI pipeline verifies it actually did. Belt and suspenders.

## Where This Fits in Agentic Development

Architecture decisions sit between requirements and implementation. You know what you're building. Now you decide how. ADRs are that decision layer, and they feed directly into everything downstream. The agent writing your specs reads them. The agent writing your code reads them. The agent writing your tests reads them. One set of decisions, consumed everywhere, enforced automatically.

After building multiple projects this way, I've learned that the teams who skip architecture decisions don't save time. They spend it later, refactoring the mess their agents made. ADRs are cheap. Rearchitecting isn't.

What's your approach to constraining agent behavior? I'd be curious whether anyone else is using ADRs this way or if you've found something better.

---

**Sources:**

- [Michael Nygard, "Documenting Architecture Decisions" (2011)](https://cognitect.com/blog/2011/11/15/documenting-architecture-decisions)
- [Archgate - Executable ADRs for AI Governance](https://archgate.dev/)
- [Agent Decision Records (AgDR) - GitHub](https://github.com/me2resh/agent-decision-record)
- [Owen Zanzal, "Vibe ADR: Building with Intention in the Age of AI" (2025)](https://medium.com/devops-ai/vibe-adr-building-with-intention-in-the-age-of-ai-d01e93f36696)
- [InfoQ, "Architectural Governance at AI Speed" (2026)](https://www.infoq.com/articles/architectural-governance-ai-speed/)
- [ArXiv, "Asymmetric Goal Drift in Coding Agents Under Value Conflict"](https://arxiv.org/html/2603.03456v1)
- [AWS Prescriptive Guidance - ADR Process](https://docs.aws.amazon.com/prescriptive-guidance/latest/architectural-decision-records/adr-process.html)
