---
# Metadata for bmad-method-explained.md

# Required fields
slug: bmad-method-explained
type: blog
title: "The BMAD Method Explained: Multi-Agent Agile for AI Coding"

# Publishing control
protected: false
publish_at: 2026-06-03T00:00:00Z
expires_at: null

# SEO Metadata
meta_title: "The BMAD Method Explained: Multi-Agent AI Agile"
meta_description: "What is the BMAD method? How BMAD-METHOD's two-phase, multi-agent agile framework works for AI coding, its strengths and weaknesses, and where it fits in SDD."
og_title: "The BMAD Method Explained"
og_description: "BMAD is the biggest name in spec-driven AI coding, and the one that least resembles the others. A look at its multi-agent agile approach, its costs, and where it fits."
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
  - bmad
  - bmad-method
  - multi-agent
  - agile
---

# The BMAD Method Explained: Multi-Agent Agile for AI Coding

If you have spent any time reading about spec-driven development, you have run into BMAD. It is the biggest name in the category by raw popularity, and it is also the one that least resembles the others. Where Spec Kit, OpenSpec, and Kiro are spec formats with tooling around them, BMAD is a whole simulated agile team. The spec is something it produces along the way, not the thing it is built around.

This is the explainer I wish I had read before I tried to figure out where BMAD fits in the [spec-driven development landscape](/blog/spec-driven-development). Here is what it is, how it actually works, the honest knocks against it, and how it lines up against a spec-first harness like CodeMySpec.

## What BMAD Is

BMAD-METHOD ("Breakthrough Method for Agile AI-Driven Development") is an open-source framework from BMad Code, LLC. It is MIT-licensed, free, and bring-your-own-model. It is one of the most popular and widely adopted projects in the agentic-coding space. [![GitHub stars](https://img.shields.io/github/stars/bmad-code-org/BMAD-METHOD?style=flat&label=stars&color=e25515)](https://github.com/bmad-code-org/BMAD-METHOD)

It is worth being precise about what BMAD *is*, because it surprises people. It is not a product, an IDE, or a hosted service. It is a method distributed as files: agent persona definitions written in Markdown and YAML, plus workflows, templates, and a CLI installer that drops it into your own AI coding environment. The agents are prompts and personas, not a service you log into.

The current line is **V6** (latest tagged release v6.8.0, around May 2026), which reorganized the project into a "module ecosystem" with scale-adaptive planning and a "BMad Builder" for custom extensions. **V4** is the prior stable line, and it is what the bulk of existing tutorials and explainers document, so if you read three BMAD walkthroughs you are mostly reading about V4. The conceptual model is the same across both, so I will describe it the way the V4 README states it most cleanly.

## The Two Phases

BMAD formalizes the software lifecycle into two phases, each targeting a specific failure mode in AI coding.

**Phase 1, Agentic Planning.** A set of dedicated agents (Analyst, PM, and Architect) collaborate with you to produce detailed, consistent PRDs and architecture documents. This phase is typically run in a web UI (Gemini Gems or ChatGPT Custom GPTs) using "web bundles," because the planning artifacts are large and benefit from big context windows. What comes out: a project brief, a PRD (functional requirements, non-functional requirements, epics, draft stories), a UX spec, and an architecture document. Everything is a versioned Markdown file committed to Git. The failure mode this attacks is **planning inconsistency**.

**Phase 2, Context-Engineered Development.** The Scrum Master agent transforms those plans into hyper-detailed development stories that contain everything the Dev agent needs: full context, implementation details, and architectural guidance embedded directly in each story file. This runs in the IDE (Claude Code, Cursor, and so on). The mechanism is **sharding**: the big PRD and architecture docs get broken into individual, self-contained story files. Each story carries its rationale, explicit constraints, embedded tests, and links back to the source docs, so the Dev agent has full context without re-reading everything. The Dev agent implements one story at a time, often on a branch, and a QA review follows. The failure mode this attacks is **context loss** between agents.

## The Agent-Persona Model

The cast is what defines the method. It ships a roster of scoped personas (Analyst, PM, Architect, PO or Product Owner, Scrum Master, Dev, QA, UX Expert) plus an Orchestrator and a Master agent that coordinate the others. Each persona is a bounded role that produces one versioned artifact and hands off to the next. You are not prompting "an assistant." You are running a relay where each leg has a job, a context window scoped to that job, and a deliverable.

BMAD also reaches beyond software. Expansion packs and modules extend the method into creative writing, business strategy, education, and game development. The software method is just the flagship module.

## Is BMAD Really Spec-Driven Development?

This is the question worth slowing down on, because the honest answer is "yes, but with an asterisk."

The case for calling it SDD is straightforward. It meets the working definition every comparison article uses: a written, versioned artifact (not the chat history) is the source of truth that drives implementation. BMAD's PRD, architecture doc, and story files are exactly that. And the market already files it under SDD: essentially every 2025-2026 roundup of spec-driven tools lists BMAD alongside Spec Kit, Kiro, and OpenSpec as a peer.

The asterisk is about identity. BMAD's primary identity is a **simulated agile team**, not a specification format. Tim Wang, in his comparison of the major tools, describes BMAD as mimicking a full agile development team of specialized agents: agile-simulation-first, with spec-driven elements bolted on, rather than spec-first with agile features layered over it. The unit that actually drives the Dev agent is the **hyper-detailed story**, not a clean, minimal, portable spec. The story is a context-packing device. Its job is to stuff everything one agent needs into one file. Compare that to Spec Kit's executable spec or Kiro's requirements-to-design-to-tasks flow, which are spec-centric by construction. BMAD is role-and-handoff-centric and produces specs along the way.

The fair framing is this: BMAD is **SDD-by-outcome** rather than SDD-by-philosophy. It produces and drives from versioned PRDs, architecture, and stories, which earns its place in the category, but the spec is not the central object. The multi-agent method is. Think of BMAD as the **agentic-agile wing** of the landscape: the answer for people who want to orchestrate a whole AI team, not write a better spec.

## Strengths

- **Covers the full lifecycle.** It simulates an entire product team rather than a single assistant. If you want planning, architecture, and implementation handled as distinct disciplines, nothing else goes this far.
- **A strong artifact trail.** Brief, PRD, architecture, sharded stories, code, and tests all live in Git. That paper trail doubles as audit and compliance evidence, which is why BMAD gets recommended for regulated industries where "PRDs, architecture diagrams, and story-level test plans double as compliance evidence."
- **Deliberate context engineering.** Self-contained stories are a real answer to cross-agent context loss, which is one of the genuine hard problems in multi-step AI coding.
- **Free, MIT, model-agnostic.** It runs on whatever LLM you point it at (validated against Claude, Gemini, GPT, and Grok) with a large, active community behind it.

## Weaknesses

The criticisms are real and well-documented, and most of them come from people who like the tool.

- **Steep learning curve.** Using BMAD means understanding "CLI commands, YAML configuration files, and the roles and handoffs among approximately six to seven agent personas." Anderson Santos, in his "You should BMAD, part 2" writeup, estimates roughly two months to master, against a day or two for Spec Kit.
- **Heavy token cost.** The numbers here move with the version and the project, so treat them as order-of-magnitude, not gospel: one analysis pegged earlier versions at roughly 31,667 tokens per workflow run and about $847/month in API spend on example projects, and real-world users have reported around 230M tokens per week on large builds. PRDs and architecture files alone can run to tens of thousands of tokens, so BMAD struggles on small models and small context windows.
- **Slow on small tasks.** Reenbit benchmarked the same CRM dashboard build at "5.5 hours with BMAD" versus 12 minutes with OpenSpec (and 90 minutes with Spec Kit). After three client projects and five frameworks, their verdict was blunt: "the answer we give most often is not BMAD."
- **Error propagation across agents.** "If one agent produces flawed output, downstream agents may not detect the error." One cited user "spent over nine hours only to encounter a nonfunctional authentication system erroneously marked complete." This is the dark side of the relay model: a bad handoff compounds.
- **Weak on legacy code.** Its documentation-first assumptions "don't always map cleanly onto a 10-year-old monolith." BMAD shines on greenfield with clear scope, not on rescuing a messy codebase.

## A Note for the Phoenix Crowd

BMAD is stack-generic by design. A community port, `mkreyman/bmad-elixir`, adapts the method for Elixir, Phoenix, and the BEAM with quality gates layered on. I read that port as a signal rather than a solution: the Phoenix audience wants stack-native spec tooling, and they want it badly enough to fork a generic framework to get it. The port exists because BMAD itself does not speak Phoenix.

## How It Compares to CodeMySpec

BMAD and CodeMySpec are solving different problems, and the cleanest way to see the difference is to state each tool's central question.

BMAD answers: **how do I run a whole AI agile team?** CodeMySpec answers: **how do I make the spec good enough that any agent produces verified good code?**

That difference cascades into everything else.

| Dimension | BMAD-METHOD | CodeMySpec |
|---|---|---|
| Core identity | Multi-persona agile team simulation | Spec-generation harness that produces specs an agent consumes |
| Unit that drives code | Hyper-detailed story files (sharded from PRD/arch) | BDD specs + module specs on a requirement graph |
| Spec philosophy | Specs are one artifact among many | Spec quality *is* the thesis |
| Spec role | Context-packing for the next agent | Portable protocol layer (consumed via MCP / context files) |
| Phases | Agentic Planning -> Context-Engineered Development | Spec generation -> BYO-agent implementation |
| Stack | Generic / language-agnostic | Phoenix-native |
| Verification | Multi-agent QA review of stories | Mandatory BDD gate + live browser QA on the running app |
| Weight | Heavyweight: 6-7 personas, high token spend, weeks to learn | Lighter: the harness produces the spec, you run any agent |
| Pricing | Free, MIT, BYO model | Free in early access, BYO agent/model/keys |

BMAD bundles roles, handoffs, and stories into a method. [CodeMySpec](/developers) does the opposite: it isolates the spec as a portable, BDD-grounded protocol and stays out of the agent's way. Specs are markdown, tests are ExUnit, and any agent (Claude Code, Codex, Gemini CLI) can consume them via MCP or generated context files. Bring your own agent, your own model, your own keys. We don't arbitrage tokens.

The other gap is verification. BMAD's quality gate is a multi-agent QA review of the story output, agents checking agents, which is exactly where the error-propagation criticism bites. CodeMySpec's gate is different in kind: every spec produces BDD acceptance criteria and generated tests, and then a QA subagent boots the real app, drives a real browser, screenshots the result, and files issues with severity. Unit tests pass. BDD specs pass. Then the QA agent clicks the button and finds the bug anyway. Prompting is praying; verification is a guarantee.

Most spec-driven tools are spec-only. They generate a spec and hand off to a separate agent. CodeMySpec runs spec, code, test, and live verification in one system, tracked on a requirement graph, built Elixir-first by an Elixir engineer.

If you want to orchestrate a full AI product team and you have a greenfield project with real compliance needs, BMAD is a serious, comprehensive choice. If you want the spec itself to be good enough, and verified, so that any agent produces working Phoenix code without the weeks-long ramp and the 230M-tokens-a-week bill, that is the problem CodeMySpec solves.

## Related Articles

- [What Is a Spec? The Most Overloaded Word in Software](/blog/what-is-a-spec)
- [Spec-Driven Development in 2026: The Complete Guide and Tool Comparison](/blog/spec-driven-development)
- [OpenSpec Explained: Repo-Native Spec-Driven Development](/blog/openspec-explained)
- [Kiro Specs Explained: EARS, Spec Mode, and the Trade-offs](/blog/kiro-specs-explained)
- [Spec-Driven Development for Elixir and Phoenix](/blog/spec-driven-development-elixir)
- [Kiro vs Zed vs Cursor vs Windsurf: 2026 AI IDE Comparison](/blog/ai-ides-compared-2026)
- [Claude Code vs Codex vs Aider: 2026 CLI Agent Benchmarks](/blog/cli-agents-compared-2026)

## Sources

- [github.com/bmad-code-org/BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD)
- [github.com/bmad-code-org/BMAD-METHOD/tree/V4](https://github.com/bmad-code-org/BMAD-METHOD/tree/V4)
- [github.com/bmad-code-org/BMAD-METHOD/blob/main/docs/index.md](https://github.com/bmad-code-org/BMAD-METHOD/blob/main/docs/index.md)
- [Tim Wang, "Spec-kit, BMAD, Agent OS and Kiro," Medium](https://medium.com/@tim_wang/spec-kit-bmad-and-agent-os-e8536f6bf8a4)
- [Reenbit, "BMAD vs Spec Kit vs OpenSpec"](https://reenbit.com/bmad-vs-spec-kit-vs-openspec-choosing-your-spec-driven-ai-framework/)
- [Reenbit, "What Is BMAD?"](https://reenbit.com/the-bmad-method-how-structured-ai-agents-turn-vibe-coding-into-production-ready-software/)
- [Anderson Santos, "You should BMAD -- part 2," Medium](https://adsantos.medium.com/you-should-bmad-part-2-a007d28a084b)
- [MarkTechPost, "9 Best AI Tools for Spec-Driven Development in 2026"](https://www.marktechpost.com/2026/05/08/9-best-ai-tools-for-spec-driven-development-in-2026-kiro-bmad-gsd-and-more-compare/)
- [Vishal Mysore, "Comprehensive Guide to Spec-Driven Development: Kiro, GitHub Spec Kit, and BMAD-METHOD," Medium](https://medium.com/@visrow/comprehensive-guide-to-spec-driven-development-kiro-github-spec-kit-and-bmad-method-5d28ff61b9b1)
- [AngelHack DevLabs, "What is the BMad Method?"](https://devlabs.angelhack.com/blog/bmad-method/)
- [DEV Community, "BMAD: The Agile Framework That Makes AI Actually Predictable"](https://dev.to/extinctsion/bmad-the-agile-framework-that-makes-ai-actually-predictable-5fe7)
- [github.com/mkreyman/bmad-elixir](https://github.com/mkreyman/bmad-elixir)
