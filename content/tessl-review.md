# Tessl Review (2026): The Spec-as-Source Bet

Tessl is the most aggressive spec-driven development vision in the market, and it is also the least proven. The thesis is radical: the spec, not the code, becomes the artifact you maintain, and the code becomes a regenerable output stamped `// GENERATED FROM SPEC - DO NOT EDIT`. If that works, you stop editing code at all. You edit intent, and a machine recompiles your application from it. That is the boldest claim anyone in this category is making, and as of mid-2026 it is still mostly a thesis.

The vision deserves serious treatment. This review does that, then separates it from what you can actually run today.

## Who builds Tessl

Tessl was founded by Guy Podjarny ("Guypo"), founder and former president of Snyk, the multi-billion-dollar developer-security company, and before that CTO at Akamai. He also co-hosts the AI Native Dev podcast and runs the AI Native DevCon conference in New York. Tessl is his second major venture, and the pedigree explains both the capital and the thought-leadership share Tessl commands in the spec-driven conversation.

The funding is its own headline. On November 14, 2024, Tessl announced **$125M total**: a $25M seed (April 2024) led by boldstart and GV, and a $100M Series A led by Index Ventures with Accel participating. Fortune reported a valuation around **$750M**. The unusual part is the timing. At the announcement, Fortune reported Tessl "is not yet ready... to begin selling the software to paying customers," was testing two preliminary versions internally and with select users, and hoped to offer the product to customers in 2025. This was vision financing in its purest form: three quarters of a billion dollars in valuation against a thesis and a founder's track record, before a commercial product existed.

That is not a criticism. Betting big on a hard problem is how categories get created. But it sets the bar for the rest of this review, because a company funded on a vision invites one question: is the vision shipping?

## The vision: spec as source of truth

Podjarny's framing is "code-centric to spec-centric." In his words, "Being spec-centric means you define what you want, and that includes definitions of what correctness looks like, the core definitions of how the system should behave." The Series A vision post put the bet more plainly: "AI offers a breakthrough: finally separating what the software does from how it does it."

The payoff, if it lands, is large. If the spec is canonical and the code is disposable, applications become language-agnostic. The vision post described apps "easily adapted from JavaScript to Python, iPhone to Android or browser to native app," because you would regenerate the code in a new target from the same spec. And the system would "continuously maintain the app, relying on tests from the spec to ensure the app doesn't break." This is spec-as-source in the fullest sense: you never touch the code again.

This is genuinely different from everyone else. Kiro and GitHub Spec Kit are spec-first: you write specs, generate code once, then maintain the code by hand from then on. Tessl is the only major tool chasing spec-as-source, where the code stays disposable forever. On ambition, nobody is reaching higher.

## What's actually shipped

Here is where vision and product diverge. Tessl ships in two pieces, and only one of them is the engine the thesis depends on.

**Tessl Spec Registry** launched in open beta on September 16, 2025. Think "npm for knowledge": a dependency system for versioned specification packages, holding (per Tessl) 10,000+ specs that describe how to use external libraries so agents stop hallucinating APIs and mixing up versions. By the January 29, 2026 repositioning, this became the **skills registry**: versioned, evaluated bundles of instructions, docs, and rules, installable via `tessl install`, publishable by teams, and run through both review evaluations (structure and best-practice checks) and task evaluations (real-world performance testing). This is the live, growing product, and it is genuinely useful. Versioned, evaluated skill packages beat a folder of ad-hoc markdown files.

**Tessl Framework** launched the same day in closed beta, and it is the actual spec-drives-code engine, the part the entire thesis rests on. Birgitta Böckeler, writing on Martin Fowler's site on October 15, 2025, got hands-on with it. Her findings:

- It ships as a CLI that also acts as an MCP server.
- Specs live in the codebase as markdown under a `specs/` folder, capturing functional requirements, API contracts, and edge cases as "long-term memory" for agents.
- Tags like `@generate` and `@test` direct generation; `tessl build` generates the code.
- Generated files carry the `// GENERATED FROM SPEC - DO NOT EDIT` stamp.
- A 1:1 mapping ties each spec file to a code file, operating at a deliberately low abstraction level per file.
- The observed output language was **JavaScript**. Not Python, not Swift, not the "language-agnostic" vision. JS.

As of mid-2026, the Framework still does not appear to have reached general availability. It has been in closed or private beta for roughly nine months, and Böckeler described it as "more future-oriented" than the public registry. What you can install and use today is a spec-first workflow tile (`tessl install tessl-labs/spec-driven-development`): the agent asks clarifying questions, writes specs first, pauses for a human review checkpoint, implements against the specs, and back-updates the specs with what it learned. Plugins exist for Express and LangChain. That is the spec-first shape (write specs, generate code once), not the spec-as-source shape (regenerate forever) that the Framework is reaching for.

## The reality check: a non-deterministic compiler

The core technical critique of spec-as-source is sharp, and it comes straight out of the hands-on testing. If you generate code from a spec, you are "fully dependent on a non-deterministic compiler." Run the same spec twice and you get different implementations.

Böckeler observed exactly this. She "generated code multiple times from the same spec" and described it as "an interesting exercise to iterate on the spec and make it more and more specific to increase the repeatability of the code generation." Non-determinism forced iterative spec refinement. That is the crux. The premise "the spec is the source of truth" only holds if the spec deterministically produces the same software. If it does not, the spec is not a source of truth; it is a prompt with extra steps, and you are back to refining inputs until the slot machine pays out.

Two more recurring criticisms deserve fair airing:

- **Waterfall risk.** A real difference separates TDD (write a failing test for the next 20 minutes of work) from writing a 2,000-line spec document for the next two months. Large up-front specs can quietly reintroduce waterfall, and skeptics question whether "lots of up-front spec design is a good idea, especially when it's overly verbose."
- **The sledgehammer problem.** For a one-line null check, you should not have to amend a constitutional spec document. A fair worry holds that spec-driven development gets "over-applied with the same confidence that microservices were over-applied," scaling poorly down to small changes.

## The January 2026 pivot

The other thing a fair review has to name is the repositioning. On January 29, 2026, Tessl reframed itself around "Skills on Tessl: the package manager for agent skills," and the company now describes itself as an **Agent Enablement Platform**. The current homepage tagline is "Skills are the new code. Treat them that way." The three pillars are now security and governance, standardization and reuse, and continuous optimization.

Read against the original "spec-centric development" centerpiece, this looks like a pivot toward the more tractable, enterprise-sellable adjacent problem: governing the AI-agent sprawl companies already have. The target buyer drifted with it, from "developers and software designers working more like architects" toward security leaders and CISOs, platform and enablement teams, and engineering leadership wanting eval-based ROI. Notably, Tessl's own skills announcement does not explain how skills relate to the earlier spec registry and Framework, which reads like a messaging migration still in progress. The "accessible to many more creators" promise has quietly receded behind governance.

## Strengths, stated fairly

Tessl earns real credit:

- **The boldest thesis in the category.** Tessl named and evangelized "AI Native Development." It owns outsized mindshare in the spec-driven conversation, conference and podcast included.
- **Founder credibility and capital.** Podjarny's Snyk track record plus $125M of runway buys hiring, patience, and enterprise trust that smaller projects cannot match.
- **The registry is a genuinely good product.** Versioned, evaluated skill and spec packages, with review and task evals, are a real improvement over scattered markdown.
- **The governance angle is enterprise-saleable.** Security scanning, audit logs, and policy gating on agent skills target a CISO pain that pure dev tools ignore.
- **MCP-native and agent-agnostic.** It sits above Claude Code, Cursor, Copilot, and Gemini rather than forcing you off them.

## Where it lands on the rigor spectrum

Tessl aspires to the highest-rigor position available: spec-as-source, where correctness lives in the spec and the code is a build artifact. On ambition, it is the truest spec-driven tool there is.

As a shipped product, the honest assessment is "truest vision, least-proven execution." What is GA is a spec and skill registry, governance, and a spec-first workflow tile. The regeneration engine the whole thesis depends on is closed beta, JavaScript-only, 1:1 spec-to-file, and demonstrably non-deterministic. Tessl is true spec-driven development in aspiration and spec-first-with-a-registry in practice today.

## How it compares to CodeMySpec

[CodeMySpec](/products/code-my-spec) takes the opposite bet. Where Tessl wants the spec to *replace* code as the source of truth, CodeMySpec holds that spec quality *determines* code quality, and that the code stays real, human-owned source. Specs are a portable protocol layer that feeds whatever coding agent you already use, not a compiler that regenerates your app from scratch. Nothing depends on a non-deterministic regeneration engine, because nothing gets regenerated from zero.

| Dimension | Tessl | CodeMySpec |
|---|---|---|
| **Core thesis** | Spec replaces code as source of truth; code is a regenerable artifact | Spec quality determines code quality; code stays real, human-maintainable source |
| **Spec to code** | Aspirationally regenerate-everything; today closed-beta `tessl build`, ~1:1 spec-to-JS file, non-deterministic | Specs feed any agent via MCP and context files to guide generation; no regenerate-from-scratch dependency |
| **Spec types** | Markdown specs plus tests | Mandatory BDD scenarios plus configurable module specs on a requirement graph |
| **Verification** | Tests from spec (vision); engine in beta | Generated tests plus live browser QA on the real running app |
| **Distribution** | Registry-centric, centralized hub plus governance | Repo-native; specs live with the code, no central registry |
| **Agent and model** | Agent-agnostic layer above Claude Code/Cursor/Copilot/Gemini | BYO agent, BYO model, BYO keys, no token markup |
| **Language focus** | Vision: language-agnostic. Reality: JavaScript/TS | Phoenix and Elixir-native |
| **Maturity** | $125M-funded; flagship engine closed beta ~9 months; mid-pivot to agent enablement | Focused niche product, shipping in its niche (early access) |

The verification difference is the one I care about most. Tessl's thesis leans on "tests from the spec" to keep regenerated code correct, but that machinery is still beta. CodeMySpec already runs a QA agent that boots the real app, drives a real browser, takes screenshots, and files issues by severity. Unit tests pass, BDD specs pass, and then the agent clicks the button and finds the bug anyway. Prompting is praying. Verification is a guarantee.

The honest summary: Tessl is the maximalist pole of spec-driven development, with huge funding, the boldest spec-as-source vision, and a flagship engine still in beta while the company retreats toward registry and governance. CodeMySpec is the pragmatic inverse. Rather than make code disposable or build a centralized registry, it makes high-quality, mandatory specs a portable protocol that improves whatever agent the engineer already uses: repo-native, BYO-everything, Phoenix-deep. Where Tessl bets the company on a non-deterministic compiler, CodeMySpec keeps deterministic human-owned code and uses specs to raise its quality.

If the spec-as-source bet pays off, Tessl will have built something genuinely new. Today it is a serious vision with a useful registry attached, and an engine you cannot yet run in production.

## Related Articles

- [What Is a Spec? The Most Overloaded Word in Software](/blog/what-is-a-spec)
- [Spec-Driven Development in 2026: The Complete Guide and Tool Comparison](/blog/spec-driven-development)
- [Kiro Specs Explained: EARS, Spec Mode, and the Trade-offs](/blog/kiro-specs-explained)
- [GitHub Spec Kit: How It Works and When to Use It (2026)](/blog/github-spec-kit-guide)
- [CodeMySpec](/products/code-my-spec)

## Sources

- Tessl, "Announcing Our Series A for AI-Native Software Development" (2024-11-14): https://tessl.io/blog/announcing-our-series-a-for-ai-native-software-development/
- Fortune, "Snyk founder's new startup Tessl raises funding for AI software development" (2024-11-14): https://fortune.com/2024/11/14/tessl-funding-ai-software-development-platform/
- Tech.eu, "Snyk founder's new venture Tessl raises $125M" (2024-11-14): https://tech.eu/2024/11/14/snyk-founders-new-venture-tessl-raises-125m-for-ai-software-development/
- Tessl, "Announcing Tessl's products to unlock the power of agents" (2025-09-16): https://tessl.io/blog/announcing-tessls-products-to-unlock-the-power-of-agents/
- Birgitta Böckeler, Martin Fowler's site, "Exploring Generative AI: three spec-driven tools" (2025-10-15): https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html
- Tessl docs, "Spec-Driven Development with Tessl": https://docs.tessl.io/use/spec-driven-development-with-tessl
- Tessl, "Skills are software and they need a lifecycle: introducing Skills on Tessl" (2026-01-29): https://tessl.io/blog/skills-are-software-and-they-need-a-lifecycle-introducing-skills-on-tessl/
- Tessl homepage (June 2026): https://tessl.io/
- GV, "Guy Podjarny interview: Tessl and AI software development": https://www.gv.com/news/guy-podjarny-interview-tessl-ai-software-development
- Tessl, "From code-centric to spec-centric": https://tessl.io/blog/from-code-centric-to-spec-centric/
- Zuplo, "Spec-driven AI development": https://zuplo.com/blog/spec-driven-ai-development
