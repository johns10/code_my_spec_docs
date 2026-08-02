---
# Metadata for spec-driven-development.md

# Required fields
slug: spec-driven-development
type: blog
title: "Spec-Driven Development in 2026: The Complete Guide and Tool Comparison"

# Publishing control
protected: false
publish_at: 2026-06-03T00:00:00Z
expires_at: null

# SEO Metadata
meta_title: "What Is Spec-Driven Development? 2026 Guide and Tools"
meta_description: "What is spec-driven development? A 2026 guide to SDD, the spec-first to spec-as-source rigor spectrum, and the top spec-driven development tools compared."
og_title: "Spec-Driven Development in 2026: Guide + Tool Comparison"
og_description: "The complete guide to spec-driven development: definition, rigor spectrum, canonical workflow, and the SDD tools compared (Spec Kit, Kiro, Tessl, OpenSpec, BMAD, Agent OS, CodeMySpec)."
og_image: null

metadata:
  template: article
  author: John Davenport
  category: AI Development
  featured: false

tags:
  - ai
  - ai-coding
  - spec-driven-development
  - spec-kit
  - kiro
  - openspec
  - tessl
  - bmad
  - agent-os
  - codemyspec
---

# Spec-Driven Development in 2026: The Complete Guide and Tool Comparison

AI coding agents are great at producing plausible code fast, and terrible at remembering what you actually asked for across a long session. Spec-driven development (SDD) is the bet that the fix is to stop treating the chat window as the source of truth. You make a written specification the authoritative artifact, and code becomes something derived and verified against it, not the other way around. Instead of vibe coding through a chat, where your intent lives in throwaway conversation history and the agent drifts, hallucinates APIs, and decays as the project grows, you author a structured, behavior-oriented spec first, derive a plan, break it into atomic tasks, and only then generate code that gets checked back against the spec.

That spec is the durable memory that survives context windows, model swaps, and the months between when a feature was built and when someone has to change it. By mid-2026 SDD is a real category with a Martin Fowler article, a DeepLearning.AI course, an arXiv paper, and at least seven serious tools fighting over the term. It is also one of the few durable ideas in a churning market: the spring 2026 consolidation wave (acquisitions, rebrands, and sunsets across the [broader AI coding tool landscape](/blog/best-ai-coding-tools-2026)) strengthened the case for keeping your intent in specs you own rather than in any one vendor's chat history. This guide defines the category, lays out the rigor spectrum, walks the canonical workflow, classifies the tools, compares them in one table, and gives you a way to choose. I build with one of these tools daily (CodeMySpec, which I make), so I will flag my bias where it shows up and try to be fair to the rest.

## What is spec-driven development?

**Spec-driven development is a software methodology where a written specification, not the code, is the source of truth: humans author and maintain the spec, and AI agents generate, verify, and update code against it.**

The core idea is an inversion. In traditional development, code is the source of truth and any spec is a stale document describing what the code used to do. SDD flips that: the spec is what you maintain, and code is generated or reconciled against it. GitHub's own toolkit puts it bluntly: "Specifications don't serve code; code serves specifications."

The term and the modern wave are most often credited to **GitHub Spec Kit**, open-sourced in September 2025 and built on John Lam's research into making LLM-driven development more deterministic. The underlying idea, capturing intent in a formal spec, long predates it, and AWS's Kiro and Tessl pushed the phrase into mainstream developer vocabulary through late 2025 and 2026. But Spec Kit is what gave the category its name.

### The three-level rigor spectrum

Not all SDD is the same, and the most authoritative framing of the differences comes from Birgitta Bockeler on Martin Fowler's site, echoed almost exactly by the 2026 arXiv paper "From Code to Contract." Both use the same three-level spectrum, and it is the right mental model for the whole category:

1. **Spec-first.** The spec gives initial clarity, then is discarded or allowed to drift once code is generated. The spec launches the work; the code becomes the source of truth again. This is the default behavior of Spec Kit and Kiro.
2. **Spec-anchored.** The spec is maintained alongside code for the life of the system, and tests enforce alignment between the two. Bockeler describes this as the sweet spot for most production systems.
3. **Spec-as-source.** Humans edit only the spec; machines generate all the code; the human never touches the implementation. The most radical form. Tessl aspires here, stamping generated files with `// GENERATED FROM SPEC - DO NOT EDIT`.

Bockeler's own caveat is worth repeating: the term is imprecisely defined, and many tools that claim SDD are really spec-first, meaning the discipline evaporates the moment the agent starts writing code. Where a tool lands on this spectrum tells you more than any feature list.

## The canonical workflow

Almost every SDD tool converges on the same four-phase loop, even when the command names differ:

1. **Specify.** Write the "what" and "why" as functional requirements and user stories, with no implementation detail. This is `requirements.md` in Kiro, `spec.md` in Spec Kit, the proposal-and-spec step in OpenSpec.
2. **Plan.** Translate the spec into technical design: architecture, data model, interfaces, constraints. This is the "how." Kiro's `design.md`, Spec Kit's `plan.md`.
3. **Implement.** Decompose the plan into ordered, testable tasks and have the agent execute them. Kiro and Spec Kit both produce a `tasks.md` sequenced by dependency, often with traceability back to specific requirements.
4. **Validate.** Confirm the code matches the spec. This is the phase most tools treat as optional, and it is where the category quietly falls apart (more on that below).

### EARS notation, briefly

Requirements in the Specify phase are frequently written in **EARS** (Easy Approach to Requirements Syntax), a constrained-English template that Kiro and the now-sunsetted Amazon Q Developer popularized for AI specs. EARS was developed by Alistair Mavin and his team at Rolls-Royce around 2009, originally for aircraft engine control requirements, and presented at IEEE RE09. It is vendor-neutral; Kiro adopted it, did not invent it.

EARS has five requirement types (ubiquitous or always-on, event-driven, state-driven, optional, and unwanted-behavior), and its signature form is the event-driven template: "WHEN a user submits a form with invalid data THE SYSTEM SHALL display validation errors next to the relevant fields." The point is to remove ambiguity and produce testable, traceable acceptance criteria. The limitation is that EARS standardizes how a requirement is phrased; it does not make the requirement an executable test. That distinction, requirements syntax versus executable behavioral specs, separates the tools more than most comparisons admit.

## The landscape: a classification

The cleanest way to map the field is to ask two questions of each tool: what role does the spec play, and how durable is it? That yields four buckets.

**Bucket A, pure, durable SDD.** The spec persists across the life of the system and is the artifact you edit to change behavior; code is derived or continuously reconciled. This maps to spec-anchored and spec-as-source. Members: Tessl (aspirational spec-as-source), OpenSpec (repo-resident living specs with delta tracking), Augment's Intent (living specs that reconcile to what was built), and CodeMySpec.

**Bucket B, spec-first scaffolding.** Structured Specify-Plan-Tasks scaffolding bolted onto a coding session. The spec is real and disciplined, but it is treated as a launch document, not a living contract, so it drifts once code generation starts. This is the most crowded bucket. Members: GitHub Spec Kit, Kiro, the legacy Amazon Q, GSD, Traycer, and the various Spec Kit clones.

**Bucket C, agentic-agile orchestration.** Spec-producing, but the differentiator is a multi-role agent team (analyst, PM, architect, dev, QA) running an agile-style lifecycle. The unit that drives code is a context-packed story, not a minimal portable spec. Members: BMAD-METHOD is the archetype; Agent OS overlaps Buckets B and C.

**Bucket D, adjacent but not SDD.** Tools that share the word "spec," support context files, or do planning, but where the spec is not the governing source of truth. General agents like Cursor, Claude Code, and Devin Desktop (formerly Windsurf) live here: they support context files, but a plan made in Plan Mode is discarded after use. Orchestration libraries (CrewAI, LangGraph, AutoGen) are infrastructure, not SDD. And API-contract tools that collide on the word "spec" (OpenAPI, Swagger, AsyncAPI) are unrelated to AI SDD entirely.

## The tools compared

Here are the seven tools most worth knowing, on the dimensions that actually distinguish them.

| Tool | Maker | Category | Spec format | Enforcement / gate | Verification | Agent/IDE lock-in | Pricing | Community |
|---|---|---|---|---|---|---|---|---|
| **CodeMySpec** | J. Davenport | Full-lifecycle harness (Layer 1) | BDD scenarios (Spex) + module specs on a requirement graph | **Mandatory BDD gate** | **Live browser QA + generated tests** | None (any agent, BYO model/keys) | Free (early access) | Emerging |
| **GitHub Spec Kit** | GitHub/MS | Spec-first scaffolding | Prose markdown (spec/plan/tasks.md) | None (convention) | None | None (~30 agents) | Free, MIT | [![GitHub stars](https://img.shields.io/github/stars/github/spec-kit?style=flat&label=stars&color=e25515)](https://github.com/github/spec-kit) |
| **Kiro** | AWS | Spec-first IDE | EARS (requirements/design/tasks.md) | Review-gated, not enforced | Agent Hooks (tests) | Kiro IDE/CLI, Claude via Bedrock | Metered credits w/ markup | Closed |
| **Tessl** | Tessl (Podjarny) | Spec-as-source (aspirational) | Spec regenerates code (beta, JS-only, non-deterministic) | n/a (pre-product) | n/a | Platform/registry | Closed beta | Closed beta |
| **OpenSpec** | Fission AI | Pure SDD (repo-resident) | Structured md + optional Given/When/Then + delta tracking | Optional (validate = structure only) | None | None (20+ agents, no API key) | Free, MIT | [![GitHub stars](https://img.shields.io/github/stars/Fission-AI/OpenSpec?style=flat&label=stars&color=e25515)](https://github.com/Fission-AI/OpenSpec) |
| **BMAD-METHOD** | BMAD Code | Agentic-agile orchestration | PRD + architecture + sharded stories | Process-gated (agent handoffs) | None built-in | None (BYO model) | Free, MIT | [![GitHub stars](https://img.shields.io/github/stars/bmad-code-org/BMAD-METHOD?style=flat&label=stars&color=e25515)](https://github.com/bmad-code-org/BMAD-METHOD) |
| **Agent OS** | Builder Methods | Standards-first | Reverse-engineered standards + ephemeral plan-mode specs (v3 dropped durable specs) | Advisory only | None | None (Claude Code-optimized) | Free, MIT | [![GitHub stars](https://img.shields.io/github/stars/buildermethods/agent-os?style=flat&label=stars&color=e25515)](https://github.com/buildermethods/agent-os) |

**GitHub Spec Kit** is the category-definer: a constitution, specify, plan, tasks, implement workflow layered on top of any of about 30 agents, all as plain markdown committed to your repo. It is free, MIT, and genuinely portable. GitHub calls it an experiment, and the honest critique (a "sea of markdown," "reinvented waterfall," weak on iteration and legacy code) comes from real reviews. Read the full breakdown in the [GitHub Spec Kit guide](/blog/github-spec-kit-guide).

**Kiro** is AWS's agentic IDE (and CLI) that makes the spec the unit of work, generating a requirements doc in EARS, a design doc, and a sequenced task list with requirement-to-task traceability. It is one of the most legitimately spec-first tools in the field, and AWS has made it the successor to the sunsetted Amazon Q Developer. Its weaknesses are lock-in (specs live in `.kiro/`, models route through Bedrock) and a documented pricing backlash over metered credits. See the [Kiro specs explainer](/blog/kiro-specs-explained).

**Tessl** is the most aggressive vision in the category, spec-as-source, where code is a regenerable artifact you never hand-edit, backed by Guy Podjarny (Snyk founder) and 125M dollars in funding. The catch is that the regeneration engine has been in closed beta for roughly nine months, is JavaScript-only, and was observed by Bockeler to generate non-deterministic output from identical specs. The shipped product today is a registry of agent skills, not the spec compiler. Details in the [Tessl review](/blog/tessl-review).

**OpenSpec** is the strongest pure-SDD, no-lock-in option: free, MIT, repo-resident, no API key, no MCP required, with a signature delta-tracking feature for evolving existing codebases. It uses Given/When/Then scenarios, but they are optional, its `verify` step explicitly will not block, and its `validate` checks structure rather than behavior. The dominant community complaint is manual spec drift. Full write-up in [OpenSpec explained](/blog/openspec-explained).

**BMAD-METHOD** orchestrates a simulated agile team (analyst, PM, architect, scrum master, dev, QA) through a two-phase planning-then-development lifecycle, sharding a PRD and architecture doc into hyper-detailed story files. It is the highest-starred name adjacent to the category and the best fit for high-complexity, high-stakes, paper-trail-heavy work. It is also heavyweight: weeks to learn, high token cost, and slow on small tasks. See [the BMAD method explained](/blog/bmad-method-explained).

**Agent OS** from Brian Casel is standards-first rather than spec-first: it reverse-engineers your codebase's conventions into documented standards and injects the relevant ones into your agent's context. Its v3 (January 2026) deliberately dropped durable spec-writing in favor of shaping Claude Code's ephemeral Plan Mode, on the rationale that frontier models now handle scaffolding. Strong at the standards problem, but no longer holds a spec as a source of truth. Read the [Agent OS review](/blog/agent-os-review).

**CodeMySpec** is the tool I build. It is a full-lifecycle, specification-driven AI development harness for Phoenix and Elixir, distributed as a Claude Code plugin with a local MCP server and a web app. The mental model is a requirement graph: every artifact (spec, test, implementation, BDD scenario, QA result) is a node with prerequisites, and the system computes what to work on next. BDD scenarios (written in a Spex DSL from acceptance criteria) are a mandatory gate; module specs, reviews, and tests are configurable knobs. The piece that sets it apart is verification, covered below.

## What most tools get wrong

Look back at the comparison table and one column tells the whole story: verification. Almost every tool in the category is spec-first scaffolding that drifts, or spec-as-living-documentation you have to sync by hand. The category splits into two failure modes.

The first is **spec-first-then-drift.** Spec Kit, Kiro, Agent OS, and most of Bucket B generate a disciplined spec to launch a session, then let the code become the source of truth again the moment generation starts. The spec was real; it just stopped governing anything. The Scott Logic review of Spec Kit captured the experience: engineers "running through the commands just to generate code and read the code rather than the docs," buried in "a sea of markdown documents." When the spec does not gate the code, it is documentation, and documentation drifts.

The second is **spec-follows-code.** OpenSpec and Augment's Intent keep a living spec, which is better, but the synchronization is aspirational and manual. OpenSpec's `verify` explicitly will not block an archive; its Given/When/Then scenarios are optional. A Hacker News practitioner described abandoning sync entirely because the specs "keep drifting and drifting until you have duplication and contradictions." A spec that follows the code is a changelog, not a contract.

Both failure modes share the same root: nothing enforces the spec as a gate, and nothing verifies the running code against it. EARS standardizes requirement phrasing but does not run a test. A `validate` command that checks for a missing markdown section does not check behavior. This is the gap CodeMySpec is built around. BDD specs are a mandatory gate, not an optional doc: spec quality is the explicit lever on code quality. And verification is built in: the QA subagent writes a brief from the BDD specs, boots the real app, drives a real browser through Vibium, screenshots the result, and files issues with severity. Unit tests pass, BDD specs pass, and then the QA agent clicks the button and finds the bug anyway. No other tool in this space does live-app verification. On top of that, CodeMySpec is Phoenix and Elixir-native (contexts, LiveView, Ecto, and OTP are first-class), which is a vertical no other tool occupies.

To be fair about what is shared: repo-resident specs, bring-your-own-agent, no token markup, and specs-before-code are not unique to CodeMySpec. OpenSpec, Spec Kit, Agent OS, and BMAD all meet some of those bars, and portability in particular is table stakes, not a moat. The defensible combination is the mandatory BDD gate, built-in live verification, full lifecycle on one requirement graph, and framework-native depth in Phoenix. No competitor combines all four. You can see how that combination plays out against the closest no-lock-in peer in [CodeMySpec vs OpenSpec](/blog/codemyspec-vs-openspec), and against the closest spec-first IDE in [CodeMySpec vs Kiro Specs](/blog/codemyspec-vs-kiro-specs).

{{enforced_spec_cta shape="aside" headline="Most SDD tools generate a spec, then hand off and stop watching." sub="The harder problem is making the spec govern the code." body="CodeMySpec blocks the build when they disagree." label="See it enforce on your own repo" campaign="spec-driven-development"}}

## How to choose

No single tool wins outright; the right one depends on your situation.

- **You want the default, well-supported starting point and you live across many stacks.** Use GitHub Spec Kit. It has the biggest community, the broadest agent support, and it is free. Accept the document overhead.
- **You are deep in AWS and want spec rigor with enterprise features.** Kiro fits, especially if you are migrating off Amazon Q Developer. Budget for the credit metering and the IDE adoption.
- **You are evolving a brownfield codebase and want the lightest possible repo-resident layer with no API key.** OpenSpec is the pragmatic choice, with the caveat that you will manage spec drift by hand.
- **You are running a complex, high-stakes greenfield build and want a full simulated team plus a compliance paper trail.** BMAD-METHOD, if you can absorb the learning curve and token cost.
- **You want your agent to stop reinventing your house conventions on an existing codebase.** Agent OS, for standards injection, not for durable specs.
- **You are betting on a radical spec-as-source future and want to track it.** Watch Tessl, but do not build production on a closed beta.
- **You build in Phoenix and Elixir and you want specs that actually gate the code and a QA agent that verifies the running app.** That is the CodeMySpec wedge: [see the product](/developers).

The honest one-line summary of the whole category: most SDD tools generate a spec and hand off to a separate agent. The harder, more useful problem is making the spec govern the code and verifying the result, end to end. That is the bet worth understanding before you pick a tool.

## Related Articles

- [What Is a Spec? The Most Overloaded Word in Software](/blog/what-is-a-spec)
- [GitHub Spec Kit: How It Works and When to Use It (2026)](/blog/github-spec-kit-guide)
- [OpenSpec Explained: Repo-Native Spec-Driven Development](/blog/openspec-explained)
- [Kiro Specs Explained: EARS, Spec Mode, and the Trade-offs](/blog/kiro-specs-explained)
- [Tessl Review (2026): The Spec-as-Source Bet](/blog/tessl-review)
- [The BMAD Method Explained: Multi-Agent Agile for AI Coding](/blog/bmad-method-explained)
- [Agent OS Review: Standards-First AI Coding](/blog/agent-os-review)
- [Spec Kit vs Kiro: Which Spec-Driven Tool in 2026?](/blog/spec-kit-vs-kiro)
- [OpenSpec vs Spec Kit: Lightweight vs Full Toolkit](/blog/openspec-vs-spec-kit)
- [Kiro vs OpenSpec: Integrated AWS IDE vs Lightweight Spec Tool](/blog/kiro-vs-openspec)
- [CodeMySpec vs OpenSpec: Enforced Specs vs Living Docs](/blog/codemyspec-vs-openspec)
- [CodeMySpec vs Kiro Specs](/blog/codemyspec-vs-kiro-specs)
- [Spec-Driven Development for Elixir and Phoenix](/blog/spec-driven-development-elixir)
- [Spec-Driven Development vs Vibe Coding](/blog/spec-driven-development-vs-vibe-coding)
- [Spec-Driven Development with Claude Code](/blog/spec-driven-development-with-claude-code)
- [Best Spec-Driven Development Tools (2026)](/blog/best-spec-driven-development-tools)
- [EARS Notation Explained](/blog/ears-notation)
- [The Best AI Coding Tools in 2026: CLI Agents, IDEs, and the Great Consolidation](/blog/best-ai-coding-tools-2026)
- [CodeMySpec](/developers)
- [Our methodology](/methodology)

## Sources

- GitHub Spec Kit launch and SDD definition: https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/
- Spec Kit canonical workflow and philosophy: https://github.com/github/spec-kit and https://github.com/github/spec-kit/blob/main/spec-driven.md
- Spec Kit origin (Sept 2025, John Lam's research): https://den.dev/blog/github-spec-kit/
- Microsoft framing of the code-spec inversion: https://developer.microsoft.com/blog/spec-driven-development-spec-kit
- Three-level rigor spectrum (Bockeler): https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html
- Academic SDD definition and taxonomy: https://arxiv.org/html/2602.00180v1
- Scott Logic Spec Kit critique: https://blog.scottlogic.com/2025/11/26/putting-spec-kit-through-its-paces-radical-idea-or-reinvented-waterfall.html
- Kiro launch and spec workflow: https://kiro.dev/blog/introducing-kiro/ and https://kiro.dev/docs/specs/
- Kiro pricing: https://kiro.dev/pricing/
- Amazon Q Developer end-of-support, Kiro as successor: https://aws.amazon.com/blogs/devops/amazon-q-developer-end-of-support-announcement/
- EARS origin (Mavin / Rolls-Royce, IEEE RE09): https://reqassist.com/blog/ears-requirements-syntax
- Tessl Series A vision and spec-centric thesis: https://tessl.io/blog/announcing-our-series-a-for-ai-native-software-development/
- Tessl funding and valuation (Fortune): https://fortune.com/2024/11/14/tessl-funding-ai-software-development-platform/
- Tessl skills repositioning: https://tessl.io/blog/skills-are-software-and-they-need-a-lifecycle-introducing-skills-on-tessl/
- OpenSpec repo and docs: https://github.com/Fission-AI/OpenSpec and https://openspec.dev/
- OpenSpec verify is non-blocking, scenarios optional: https://github.com/Fission-AI/OpenSpec/blob/main/docs/workflows.md
- OpenSpec drift sentiment (HN): https://news.ycombinator.com/item?id=47994433
- BMAD-METHOD repo and two-phase method: https://github.com/bmad-code-org/BMAD-METHOD
- BMAD cost and learning-curve critique: https://adsantos.medium.com/you-should-bmad-part-2-a007d28a084b
- Agent OS repo and v3 scope change: https://github.com/buildermethods/agent-os and https://buildermethods.com/agent-os/v2
- 2026 SDD tool roundup: https://www.marktechpost.com/2026/05/08/9-best-ai-tools-for-spec-driven-development-in-2026-kiro-bmad-gsd-and-more-compare/
- SDD as a taught discipline: https://www.deeplearning.ai/courses/spec-driven-development-with-coding-agents
