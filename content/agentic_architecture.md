# Architecture for AI Agents: Which Patterns Actually Work?

Most developers skip architecture when working with AI agents. They describe what they want, the agent writes code, and they move on. Then three months later the codebase is a tangled mess and every new feature breaks something else.

The data backs this up. BSWEN measured a [26-point gap between AI-only code and human-guided architecture](https://docs.bswen.com/blog/2026-03-25-why-vibe-coding-fails-production/) (59/105 vs 85/105). The entire gap comes from architectural dimensions: async design, abstraction quality, maintainability, code organization. AI handles implementation details well when given clear architectural direction. The problem is nobody provides the direction.

And the cost of skipping architecture is getting worse, not better. [Ox Security found 10 recurring anti-patterns in 80-100% of AI-generated code](https://www.infoq.com/news/2025/11/ai-code-technical-debt/). Unmanaged AI code drives [maintenance costs to 4x traditional levels by year two](https://www.buildmvpfast.com/blog/ai-generated-code-technical-debt-management-2026). When code generation is nearly free, you can generate technical debt at scale.

## The constraint that matters

Every architecture should be evaluated by one question: does it fit in the agent's context window?

Sebastian Sigl [nails it](https://www.thecodecoach.dev/blog/bounded-contexts-are-the-key-to-effective-ai-driven-development): "The problem is that we give it too much irrelevant context, which creates ambiguity. And ambiguity is where correctness usually dies." Bounded scope, clear contracts, predictable conventions. That's what agents need.

The [40% rule](https://dev.to/somedood/vertical-slice-architecture-is-the-new-meta-for-agentic-coding-hma) says LLMs degrade past 40% context usage. If your architecture forces the agent to load half the codebase to make a change, you're already in the degradation zone.

## What works, ranked

After digging through 40+ sources, here's how architecture patterns stack up for AI agents:

**Modular monolith with bounded contexts: the winner.** One codebase, clear internal boundaries. Shopify transitioned their [2.8M-line Rails monolith](https://www.linkedin.com/pulse/ai-agents-will-force-your-code-become-more-modular-enrico-piovesan-x7vxf/) into a modular monolith with bounded contexts, which enabled their internal AI to generate meaningful features without compromising design integrity. [42% of organizations that adopted microservices have consolidated back](https://www.cncf.io/reports/cncf-annual-survey-2025/). [Phoenix contexts](/pages/why-phoenix-contexts-are-great-for-llms) are a natural fit here: each context encapsulates a domain with a clear public API.

**Vertical slices: the dark horse.** Organize by feature, not by layer. Instead of models/controllers/views, you get features/authentication, features/billing, features/notifications. Each slice contains everything the agent needs for one feature. The agent loads one slice, makes the change, moves on. No scattered files across directories.

**Hexagonal / Ports & Adapters: great for quality.** Clear separation gives agents unambiguous rules: business logic here, infrastructure there. [Agents can modify core logic without touching database or API code](https://dev.to/bardia/hexagonal-architecture-for-ai-agents-2jmm). Port interfaces act as contracts. Adapter swapping becomes trivial.

**OpenAI's layered architecture: the case study.** Types -> Config -> Repo -> Service -> Runtime -> UI. Code can only depend forward. [3 engineers, ~1M lines, 5 months](https://openai.com/index/harness-engineering/), 3.5 PRs per engineer per day. Constraints enforced by linters, not documentation. I covered this in depth in [the harness layer article](/pages/the-harness-layer). This is the strongest evidence that strict architectural enforcement produces reliable agent output.

**Microservices: mixed.** Individual services are great, each one fits in context. Cross-service changes are terrible. An [arXiv benchmark of 144 generated microservices](https://arxiv.org/abs/2603.09004) showed 81-98% integration test pass rates for clean-state generation but only 50-76% for incremental work. The "one agent per service" pattern works. System-level changes don't.

**Plain monoliths: they scale down, not up.** Under 10K lines, agents handle them fine. Over 100K, context pollution kills effectiveness. Everything is visible but everything is also noise.

**MVC frameworks: familiar but horizontal.** Agents know MVC well from training data. But horizontal slicing (code by layer, not by feature) forces agents to touch many files per feature. A [token efficiency study](https://alderson.dev/blog/2026/03/24/ai-coding-agents-picking-the-right-web-framework) showed Phoenix at 74K tokens vs ASP.NET Minimal at 26K for equivalent tasks.

## Architecture as context

The most interesting development isn't a specific pattern. It's the idea that architecture itself becomes context for the agent.

[Archgate](https://www.infoq.com/news/2025/12/archgate-architecture-decision-records/) turns Architecture Decision Records into executable TypeScript rules that enforce decisions in CI and feed context to agents automatically. When an ADR says "all API endpoints must use the shared response format," Archgate returns file-and-line violations.

The [Steward Agents concept](https://blog.thinktastic.com/why-domain-driven-design-is-having-a-renaissance-in-the-age-of-ai-agents) assigns one agent per bounded context. Each agent maintains its own documentation, ADRs, and internal conventions. The agent becomes the domain expert for its context.

An [arXiv paper on "Codified Context"](https://arxiv.org/abs/2603.05344) documents a three-tier system: hot-memory constitution, 19 domain-expert agents, and 34 on-demand spec documents, tested across 283 sessions on a 108K-line system. Single-file manifests like CLAUDE.md don't scale past modest codebases. You need structured, layered architecture context.

## The practical takeaway

If you're starting a new project with AI agents, pick a modular monolith with bounded contexts or vertical slices. Enforce boundaries with linters, not documentation. Give the agent architecture context it can read, not just code.

If you have an existing codebase, the first investment isn't better prompts. It's better boundaries. Even adding one enforced boundary between two domains improves agent output measurably.

The architecture is the most neglected phase in the agentic development process. It's also the highest leverage. A 26-point quality gap from architecture alone tells you everything you need to know about where to invest your time.

What architecture patterns are you using with AI agents? I'm particularly curious about anyone running Phoenix contexts or vertical slices at scale.
