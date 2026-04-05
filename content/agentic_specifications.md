# Your AI Agent Is Only as Good as Your Spec

I've been watching developers skip specifications for two years now. They fire up Cursor or Claude Code, describe what they want in a few sentences, and get working code in minutes. It feels like magic. Then three months later they can't figure out why their codebase is a tangled mess of duplicated logic and inconsistent patterns.

The reality is: code is no longer the asset. The specification is the asset. When AI agents can generate code at near-zero cost, the thing that constrains, directs, and validates that code becomes the primary deliverable.

## What Is Spec-Driven Development and Why Does It Matter for AI Agents?

Spec-driven development inverts the traditional workflow. Instead of writing code and hoping it matches what you intended, you write a structured specification first and let the agent implement against it. Thoughtworks called it ["one of the most important practices to emerge in 2025."](https://www.thoughtworks.com/en-us/insights/blog/agile-engineering-practices/spec-driven-development-unpacking-2025-new-engineering-practices)

Martin Fowler [defines a spec](https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html) as "a structured, behavior-oriented artifact written in natural language that expresses software functionality and serves as guidance to AI coding agents." He breaks SDD into three levels: spec-first (write spec, generate code, move on), spec-anchored (spec evolves with the codebase), and spec-as-source (spec IS the source of truth, code regenerated from it). Most tools today operate at spec-first. The industry is working toward spec-anchored. Spec-as-source is still aspirational.

The workflow across all these tools converges on the same pattern: define [requirements](/blog/agentic-requirements), design the [architecture](/blog/agentic-architecture), decompose into tasks, generate code, validate against the spec. Augment Code adds a crucial insight: [debug specifications, not code](https://www.augmentcode.com/guides/what-is-spec-driven-development). When AI output is wrong, fix the spec and regenerate rather than patching the generated code.

## Which Tools Support Spec-Driven Development With AI Agents?

**[Kiro](https://kiro.dev/)** (AWS) is the simplest and most widely known. Three-phase workflow: Requirements using EARS notation, Design, Tasks. EARS forces you to be specific. Instead of "handle errors gracefully," you get "When the API returns a 429 status code, the system shall retry with exponential backoff starting at 1 second, with a maximum of 3 retries." That precision is what agents need.

**[GitHub spec-kit](https://github.com/github/spec-kit)** is open source (MIT). Four phases: Specify, Plan, Tasks, Implement. It introduces a constitution.md for non-negotiable project principles and works with Copilot, Claude Code, and Gemini CLI. The key framing: "Instead of reviewing thousand-line code dumps, you review focused changes that solve specific problems."

**[Tessl](https://tessl.io/blog/tessl-launches-spec-driven-framework-and-registry/)** takes the most radical approach. Specs ARE the maintained artifact. Code is regenerated from them, marked "GENERATED FROM SPEC - DO NOT EDIT." They have a Spec Registry with 10,000+ pre-built specs for open source libraries to help agents avoid API hallucinations. Still in private beta.

**[cc-sdd](https://github.com/gotalab/cc-sdd)** democratizes Kiro's workflow across 8 agents and 13 languages. Install in 30 seconds, get spec-first development with any tool you already use.

**[BMAD-METHOD](https://github.com/bmad-code-org/BMAD-METHOD)** is the most comprehensive. Twelve-plus domain-expert agents (Analyst, PM, Architect, Scrum Master, Developer, QA) each defined as markdown files. It splits development into Upstream (Thinking) and Downstream (Building). Documentation is the source of truth. 100% free and open source.

## How Do Design Documents Become Executable Contracts for AI Agents?

Design documents are evolving from passive reference material into operational instructions for AI agents. The same document that communicates intent to humans now constrains machine behavior.

David Haberlah [puts it well](https://medium.com/@haberlah/how-to-write-prds-for-ai-coding-agents-d60d72efb797): AI coding agents require specs that function as programming interfaces. Precise enough to execute. Structured enough to sequence. Constrained enough to prevent scope drift.

Addy Osmani's spec framework, based on [GitHub's analysis of 2,500+ agent files](https://www.oreilly.com/radar/how-to-write-a-good-spec-for-ai-agents/), identifies six critical areas: commands, testing procedures, project structure, code style, git workflow, and boundaries. His three-tier boundary system is the most useful thing in the whole piece: "Always do" (agent proceeds), "Ask first" (needs approval), "Never do" (hard stop). The most common helpful constraint? "Never commit secrets."

## What Is the Specification Gap and Why Does It Cause AI Code Quality Failures?

The specification gap is the failure to write specs before generating code. It is the single largest source of quality failures in AI-assisted development.

The numbers tell the story. A [GitClear study of 211 million lines of code](https://www.augmentcode.com/guides/vibe-coding-vs-spec-driven-development) found that after AI adoption, refactoring dropped 60% and code duplication rose 48%. Teams copy-paste rather than abstract. AI writes [roughly 30% of Microsoft's code and over 25% of Google's](https://www.technologyreview.com/2026/01/12/1130027/generative-coding-ai-software-2026-breakthrough-technology/) now. That's a lot of code being generated without specifications.

The [VibeContract paper](https://arxiv.org/abs/2603.15691) calls it the "illusion of correctness" - LLM-generated code is syntactically valid but semantically flawed. It compiles. It passes superficial tests. But it doesn't do the right thing. Their example: a loan origination endpoint that created loan records correctly but skipped mandatory approval steps and document requirements. Tests passed because they only validated what the AI built, not what the spec required.

Augment Code documents a [predictable three-month decay pattern](https://www.augmentcode.com/guides/vibe-coding-vs-spec-driven-development): months 1-3 everything ships fast; months 4-9 integration challenges emerge; month 9 onward you're drowning in debugging because the team has lost understanding of their own system.

## How Do OpenAPI Specifications Act as Guardrails for AI-Generated Code?

OpenAPI specifications are the most mature example of structured schemas as AI guardrails. The relationship is natural: OpenAPI already provides machine-readable descriptions of exactly what an API does, what parameters it accepts, and what responses to expect.

The mechanism works through function calling. OpenAPI specs get converted to function definitions for the LLM. The model generates properly-structured arguments matching the schema. The structured schema constrains AI-generated parameters to valid values. According to [Xoriant's data](https://www.xoriant.com/blog/how-swagger-driven-api-frameworks-help-data-ai-modernization), real-time validation using OpenAPI schemas at the gateway level prevents 89% of malformed requests from reaching backend services.

The broader pattern applies everywhere: JSON Schema for data validation, Protocol Buffers for service contracts, GraphQL schemas for queries, TypeScript types for code-level contracts. Formal, machine-readable specifications constrain AI output to valid values. That's the whole game.

## How Do You Write Specifications That AI Agents Can Execute Correctly?

After working with spec-driven development across multiple projects, here's what I've learned makes the difference:

**State boundaries explicitly.** AI cannot infer scope from omission. "Do not implement user authentication in this phase" must be stated. If you leave it out, the agent will build it, and it will be wrong.

**Make acceptance criteria testable.** Not "works well" but "returns 200 OK with JSON body matching schema X within 500ms." Agents need precision. Vague specs produce vague code.

**Use dependency-ordered phases.** Spell out foundations before building on them. Agents are bad at figuring out what needs to exist first.

**Break specs into modules.** Osmani documents the ["curse of instructions"](https://addyosmani.com/blog/good-spec/) - performance drops as requirements pile up in a single prompt. Divide specs into phases with summaries and references.

**Include what NOT to do.** The three-tier boundary system (always do, ask first, never do) is one of the simplest improvements you can make to any spec.

**Use structured formats where they exist.** OpenAPI for APIs. JSON Schema for data. Type definitions for code. The more machine-readable your spec, the less room for hallucination.

The specification is not overhead. It is the product. Every hour you spend writing a clear spec saves you three hours of debugging generated code that almost does the right thing but doesn't.

What's your experience been? Are you writing specs before you prompt, or are you still fixing the output after the fact?

## Frequently Asked Questions

**What is spec-driven development and how is it different from traditional development?** Spec-driven development inverts the traditional workflow by writing a structured specification first and letting the AI agent implement against it. Instead of writing code and hoping it matches intent, you define behavior-oriented artifacts in natural language that serve as guidance to AI coding agents. Thoughtworks called it one of the most important practices to emerge in 2025.

**Why does AI-generated code quality degrade after three months without specifications?** Augment Code documents a predictable decay pattern: months 1-3 everything ships fast, months 4-9 integration challenges emerge, and beyond month 9 teams drown in debugging because they have lost understanding of their own system. Without specifications as a stable reference point, there is no way to verify that generated code matches original intent as the codebase grows.

**What is the best format for writing specifications that AI agents can follow?** Use structured, machine-readable formats wherever possible -- OpenAPI for APIs, JSON Schema for data validation, TypeScript types for code-level contracts. Make acceptance criteria testable with precise thresholds rather than vague descriptions. Break specs into modules to avoid the "curse of instructions" where agent performance drops as requirements pile up in a single prompt.

**How do tools like Kiro, spec-kit, and Tessl compare for spec-driven development?** Kiro (AWS) uses EARS notation to force requirement precision across three phases. GitHub spec-kit is open source and works across multiple AI tools with a constitution.md for project principles. Tessl takes the most radical approach where specs are the maintained artifact and code is regenerated from them. All converge on the same core workflow: define requirements, design architecture, decompose into tasks, generate, and validate.

**Should you fix AI-generated code or fix the specification and regenerate?** Fix the specification and regenerate. Augment Code's key insight is to debug specifications, not code. When AI output is wrong, patching the generated code creates a divergence between your spec and your implementation that compounds over time. Fixing the spec and regenerating keeps the specification as the single source of truth.
