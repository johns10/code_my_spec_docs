# Architecture for AI Agents: Which Patterns Actually Work?

Most developers skip architecture when working with AI agents. They describe what they want, the agent writes code, and they move on. Then three months later the codebase is a tangled mess and every new feature breaks something else.

The data backs this up. BSWEN measured a [26-point gap between AI-only code and human-guided architecture](https://docs.bswen.com/blog/2026-03-25-why-vibe-coding-fails-production/) (59/105 vs 85/105). The entire gap comes from architectural dimensions: async design, abstraction quality, maintainability, code organization. AI handles implementation details well when given clear architectural direction. The problem is nobody provides the direction.

And the cost of skipping architecture is getting worse, not better. [Ox Security found 10 recurring anti-patterns in 80-100% of AI-generated code](https://www.infoq.com/news/2025/11/ai-code-technical-debt/). Unmanaged AI code drives [maintenance costs to 4x traditional levels by year two](https://www.buildmvpfast.com/blog/ai-generated-code-technical-debt-management-2026). When code generation is nearly free, you can generate technical debt at scale.

## What Is the Most Important Constraint for AI Agent Architecture?

Every architecture should be evaluated by one question: does it fit in the agent's context window? The architecture you choose determines how much of your codebase the agent must load to make a single change. If it has to load too much, the quality of its output degrades — and the degradation is measurable. Sebastian Sigl [puts it well](https://www.thecodecoach.dev/blog/bounded-contexts-are-the-key-to-effective-ai-driven-development): "The problem is that we give it too much irrelevant context, which creates ambiguity. And ambiguity is where correctness usually dies." The architecture must create bounded scope, clear contracts, and predictable conventions so the agent can work within a focused context window without loading irrelevant code that degrades its reasoning.

The [40% rule](https://dev.to/somedood/vertical-slice-architecture-is-the-new-meta-for-agentic-coding-hma) says LLMs degrade past 40% context usage. If your architecture forces the agent to load half the codebase to make a change, you're already in the degradation zone.

## Which Architecture Patterns Work Best for AI Agents?

After digging through 40+ sources, here's how architecture patterns stack up for AI agents. The key differentiator is how well each pattern limits what the agent needs to load into context while still giving it enough information to produce correct, well-structured code.

| Pattern | AI Suitability | Best For | Key Risk |
|---------|---------------|----------|----------|
| Modular monolith with bounded contexts | Excellent | Teams wanting clean boundaries without microservice overhead | Requires discipline to maintain boundaries |
| Vertical slices | Very good | Feature-focused development, solo developers | Can lead to duplication across slices |
| Hexagonal / Ports & Adapters | Very good | Systems with multiple integrations | Higher initial setup complexity |
| Layered (OpenAI-style) | Good | Large teams with strict enforcement | Rigid, requires linter enforcement |
| Microservices | Mixed | Individual services great, cross-service changes terrible | System-level coordination failures |
| Plain monolith | Limited | Small projects under 10K lines | Context pollution above 100K lines |
| MVC frameworks | Limited | Familiar to agents from training data | Horizontal slicing forces many file touches |

**Modular monolith with bounded contexts: the winner.** One codebase, clear internal boundaries. Shopify transitioned their [2.8M-line Rails monolith](https://www.linkedin.com/pulse/ai-agents-will-force-your-code-become-more-modular-enrico-piovesan-x7vxf/) into a modular monolith with bounded contexts, which enabled their internal AI to generate meaningful features without compromising design integrity. [42% of organizations that adopted microservices have consolidated back](https://www.cncf.io/reports/cncf-annual-survey-2025/). [Phoenix contexts](/pages/why-phoenix-contexts-are-great-for-llms) are a natural fit here: each context encapsulates a domain with a clear public API.

**Vertical slices: the dark horse.** Organize by feature, not by layer. Instead of models/controllers/views, you get features/authentication, features/billing, features/notifications. Each slice contains everything the agent needs for one feature. The agent loads one slice, makes the change, moves on. No scattered files across directories.

**Hexagonal / Ports & Adapters: great for quality.** Clear separation gives agents unambiguous rules: business logic here, infrastructure there. [Agents can modify core logic without touching database or API code](https://dev.to/bardia/hexagonal-architecture-for-ai-agents-2jmm). Port interfaces act as contracts. Adapter swapping becomes trivial.

**OpenAI's layered architecture: the case study.** Types -> Config -> Repo -> Service -> Runtime -> UI. Code can only depend forward. [3 engineers, ~1M lines, 5 months](https://openai.com/index/harness-engineering/), 3.5 PRs per engineer per day. Constraints enforced by linters, not documentation. I covered this in depth in [the harness layer article](/pages/the-harness-layer). This is the strongest evidence that strict architectural enforcement produces reliable agent output.

**Microservices: mixed.** Individual services are great, each one fits in context. Cross-service changes are terrible. An [arXiv benchmark of 144 generated microservices](https://arxiv.org/abs/2603.09004) showed 81-98% integration test pass rates for clean-state generation but only 50-76% for incremental work. The "one agent per service" pattern works. System-level changes don't.

**Plain monoliths: they scale down, not up.** Under 10K lines, agents handle them fine. Over 100K, context pollution kills effectiveness. Everything is visible but everything is also noise.

**MVC frameworks: familiar but horizontal.** Agents know MVC well from training data. But horizontal slicing (code by layer, not by feature) forces agents to touch many files per feature. A [token efficiency study](https://alderson.dev/blog/2026/03/24/ai-coding-agents-picking-the-right-web-framework) showed Phoenix at 74K tokens vs ASP.NET Minimal at 26K for equivalent tasks.

## How Does Architecture Become Context for AI Agents?

The most interesting development isn't a specific pattern. It's the idea that architecture itself becomes machine-readable context that the agent can consume. Instead of relying on the agent to infer your architectural decisions from code alone, you encode those decisions as structured documents that the agent reads before making changes. This transforms architecture from a passive constraint into an active input that shapes every generation.

[Archgate](https://www.infoq.com/news/2025/12/archgate-architecture-decision-records/) turns Architecture Decision Records into executable TypeScript rules that enforce decisions in CI and feed context to agents automatically. When an ADR says "all API endpoints must use the shared response format," Archgate returns file-and-line violations.

The [Steward Agents concept](https://blog.thinktastic.com/why-domain-driven-design-is-having-a-renaissance-in-the-age-of-ai-agents) assigns one agent per bounded context. Each agent maintains its own documentation, ADRs, and internal conventions. The agent becomes the domain expert for its context.

An [arXiv paper on "Codified Context"](https://arxiv.org/abs/2603.05344) documents a three-tier system: hot-memory constitution, 19 domain-expert agents, and 34 on-demand spec documents, tested across 283 sessions on a 108K-line system. Single-file manifests like CLAUDE.md don't scale past modest codebases. You need structured, layered architecture context.

## What Should You Do First?

If you're starting a new project with AI agents, pick a modular monolith with bounded contexts or vertical slices. These patterns give the agent the smallest possible scope for each change while maintaining a single codebase. Enforce boundaries with linters, not documentation — documented conventions get ignored, but linter failures block merges. Give the agent architecture context it can read (ADRs, component specs, design documents), not just code. The architecture is the most neglected phase in the agentic development process, and it's also the highest leverage: a 26-point quality gap from architecture alone tells you everything about where to invest your time.

If you have an existing codebase, the first investment isn't better prompts. It's better boundaries. Even adding one enforced boundary between two domains improves agent output measurably.

## Frequently Asked Questions

**Does architecture matter if I'm just building a small project?**
Under 10K lines, most architectures work fine with AI agents. The agent can hold the entire codebase in context. But if you expect the project to grow, establishing bounded contexts early prevents the "context pollution" problem that hits hard above 100K lines. The modular monolith pattern scales both up and down.

**Should I use microservices to give each agent its own service?**
The "one agent per service" pattern works well for isolated changes within a single service. But cross-service changes — the kind that span API contracts, shared data, or coordinated deployments — fail 24-50% of the time in benchmarks. Unless you need independent deployment, a modular monolith gives you the same isolation with none of the coordination overhead.

**How do I enforce architecture boundaries with AI agents?**
Don't rely on documentation or comments — agents ignore soft constraints. Use linters, boundary libraries (like Elixir's `Boundary` library), and CI checks that fail on violations. OpenAI's approach of enforcing forward-only dependencies with linters produced 3.5 PRs per engineer per day across 1M lines of code. The enforcement mechanism matters more than the pattern.

**What's the difference between bounded contexts and vertical slices?**
Bounded contexts group code by domain ownership (Users, Billing, Notifications) with clear public APIs between them. Vertical slices group code by feature (authentication flow, checkout flow) with everything needed for one user story in one place. Both limit what the agent loads. Bounded contexts work better for larger teams; vertical slices work better for solo developers building feature-by-feature.

**Can I retrofit architecture onto an existing AI-generated codebase?**
Yes, but incrementally. Start by identifying the two domains with the most cross-cutting changes and add an enforced boundary between them. Measure the agent's output quality before and after. The 26-point quality gap from the BSWEN study suggests even partial architectural guidance produces measurable improvements.
