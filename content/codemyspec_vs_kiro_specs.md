---
# Metadata for codemyspec_vs_kiro_specs.md

# Required fields
slug: codemyspec-vs-kiro-specs
type: blog
title: "CodeMySpec Specs vs Kiro EARS: Two Approaches to Spec-Driven AI Development"

# Publishing control
protected: false
publish_at: 2026-03-22T00:00:00Z
expires_at: null

# SEO Metadata
meta_title: "Kiro Specs vs CodeMySpec: EARS Notation vs BDD"
meta_description: "Kiro specs use EARS notation; CodeMySpec uses BDD. How Amazon's spec-driven approach compares to BDD specs for AI-generated code, tested side by side."
og_title: "CodeMySpec Specs vs Kiro EARS"
og_description: "Both tools bet that better specifications produce better AI-generated code. They disagree about where specs should live and who should own them."
og_image: null

metadata:
  template: article
  author: John Davenport
  category: AI Development
  featured: true

tags:
  - ai
  - specifications
  - kiro
  - ears
  - bdd
  - spec-driven-development
  - ai-coding
  - comparison
---

# CodeMySpec Specs vs Kiro EARS: Two Approaches to Spec-Driven AI Development

## Introduction

Kiro and CodeMySpec agree on one thing: better instructions beat better models. Where they disagree is where the instructions live.

**Kiro** (Amazon) is an IDE with spec mode: specs get generated, reviewed, and executed inside the Kiro editor. Specs are a feature of the agent.

**CodeMySpec** is a harness: specs are executable BDD files in your repo that any supported agent works from and that run in CI. Specs are the layer underneath the agent.

That's the whole argument. Everything else is detail.

## How Kiro Works

Kiro is a VS Code fork from Amazon, powered by Claude (Sonnet 4.6 and Opus 4.6 GA, Opus 4.7 experimental as of April 20, 2026 at a 2.2x credit multiplier with 1M context). Its defining feature is **spec mode**: before writing code, Kiro generates three documents:

1. **requirements.md**: Requirements in EARS notation. Structured, testable acceptance criteria covering edge cases.
2. **design.md**: System design describing components, data flow, integration points.
3. **tasks.md**: Dependency-ordered implementation plan with discrete, executable steps.

You review and approve each. Only then does Kiro start generating code, working tasks.md step by step.

### EARS Notation

EARS structures requirements into five patterns:

- **Ubiquitous:** "The system shall [action]"
- **Event-Driven:** "When [event], the system shall [action]"
- **State-Driven:** "While [state], the system shall [action]"
- **Unwanted Behavior:** "If [condition], then the system shall [action]"
- **Optional:** "Where [condition], the system shall [action]"

This forces clarity. Instead of "handle errors gracefully," you get "When the API returns a 429 status code, the system shall retry with exponential backoff starting at 1 second, with a maximum of 3 retries."

### Kiro Is Investing, Not Stagnating

Anyone writing off Kiro should look at April 2026:

- **Kiro CLI 2.0**: Headless mode and Windows support. The CLI is now viable outside the IDE.
- **AWS Transform**: Automated migrations for Java, Python, Node.js, and the AWS SDK, in both Kiro IDE and VS Code. Kiro is leaning hard into AWS enterprise workflows.
- **Claude Opus 4.7 experimental** (April 20, 2026) with 1M context at a 2.2x credit multiplier. Sonnet 4.6 and Opus 4.6 are GA.

Kiro's not slowing down. The question isn't whether Kiro survives, it's what problem each tool is actually solving.

### What Users Say

The spec-first approach has real fans:

> "I was genuinely impressed by Kiro. Its Spec mode is exactly how I think large, single-purpose tasks should be orchestrated, with clean, well-scoped specs driving the whole flow... This actually feels like engineering, not fighting the tool." (u/Pitiful_Guess7262, r/ChatGPTCoding)

The overhead is also real:

> "Is it still slow as fuck" (u/AtariBigby, r/ChatGPTCoding)

And skepticism about Amazon's commitment:

> "A good idea that's going to be someone's promo and then when they get burned out and leave it will be taken on as a group project that no one will really work on." (u/donkeyking899, r/ChatGPTCoding)

## How CodeMySpec Works

CodeMySpec treats specs as a platform layer instead of an IDE feature. The premise: specs should be portable across tools, not locked to one editor.

1. **Executable BDD specs are the core.** Acceptance criteria become BDD scenarios (written in Spex) that run with `mix spex`, not `mix test`. They are a mandatory gate, so the spec continuously verifies intent instead of sitting in a document.
2. **Specs as first-class artifacts.** Requirements, design decisions, and implementation plans live as standalone files in your repo, not IDE state.
3. **Bring your own agent.** CodeMySpec ships plugins for Claude Code, Codex, and Google Antigravity, and serves its tools over MCP so other MCP-capable agents can connect.
4. **Live verification.** A QA pass boots the real app and drives a real browser against the BDD specs, so the running software is checked against the spec.

### The Core Difference

Kiro does spec-then-code at the **agent level**. You open Kiro, write a spec, Kiro writes code. The whole thing happens inside one tool, and leaving the tool means leaving the workflow.

CodeMySpec does spec-then-code at the **full-lifecycle / platform level**. Specs live in your repo. They feed every supported agent your team uses. They survive tool changes. They integrate with code review, stakeholder sign-off, and CI/CD, because they're files in your repo that run with `mix spex`.

If you see specs as a feature of an agent, Kiro is the better-integrated answer. If you see specs as infrastructure that outlasts any particular agent, that's CodeMySpec.

## Side-by-Side Comparison

| Dimension | Kiro | CodeMySpec |
|---|---|---|
| **Spec format** | EARS notation (requirements.md, design.md, tasks.md) | Executable BDD scenarios (Spex, run with `mix spex`) + acceptance criteria |
| **Where specs live** | Inside Kiro IDE | Standalone files (any repo, any tool) |
| **Agent lock-in** | Claude only, Kiro IDE/CLI only | None (BYO model and keys; plugins for Claude Code, Codex, Antigravity; MCP for the rest) |
| **Editor lock-in** | Yes (VS Code fork), though Kiro CLI 2.0 loosens this | No (specs are files, not IDE state) |
| **MCP integration** | Consumer (uses MCP servers) | Producer (serves specs via MCP) |
| **Verification** | Agent Hooks (auto-run tests on save/commit) | Executable BDD gate plus live browser QA |
| **Enterprise** | AWS GovCloud, IAM, pursuing FedRAMP High, AWS Transform for migrations | Not a focus |
| **Pricing** | $20/mo; Opus 4.7 experimental at 2.2x credit multiplier | Build is free (includes the content engine). Operate & Grow is $100/mo per user. |
| **Maturity** | Preview (buggy, slow, but shipping) | Younger and smaller, still evolving |

## Where Each Approach Wins

### Kiro Wins When...

- **You're on AWS and committed.** GovCloud support, IAM integration, AWS Transform migrations, and Amazon backing make it the path of least resistance for AWS shops.
- **You want specs generated for you.** Kiro writes the spec from a natural-language description. CodeMySpec has you interview and refine the stories and acceptance criteria with the agent, then turns them into executable specs.
- **You want a single integrated experience.** IDE + spec + agent + execution in one tool. No MCP configuration, no context file generation.
- **Compliance matters.** FedRAMP High pursuit, structured audit trail of requirements -> design -> tasks -> code.

### CodeMySpec Wins When...

- **Your team uses more than one tool.** If people on the same team use Claude Code and Codex, both work from the same specs in the repo. Kiro specs feed Kiro.
- **You want agent flexibility by task.** Claude Code for architecture, Codex for implementation, all reading the same specs.
- **Specs are a team artifact.** Code review, stakeholder sign-off, compliance audits, specs that live as files in your repo integrate with existing team workflows.
- **You already have a spec practice.** If you write BDD scenarios, acceptance criteria, or design docs, CodeMySpec extends that. Kiro replaces it with EARS.

{{portable_spec_cta headline="Kiro's specs live in Kiro." campaign="codemyspec-vs-kiro-specs"}}

## The "Spec Overhead" Problem

Both approaches hit the same wall: specs add friction. For a typo fix or a one-line change, generating requirements, design docs, and task plans is overkill.

Kiro's Reddit feedback confirms this, users love spec mode for complex features and find it frustrating for simple tasks. Spec overhead is the #1 reason casual users bounce.

Any spec-driven tool has to handle the spectrum:

- **One-liner:** "Fix the typo in the error message" -> no spec needed
- **Small feature:** "Add rate limiting to the API" -> brief acceptance criteria
- **Complex feature:** "Implement OAuth2 with PKCE flow" -> full spec with requirements, design, edge cases

The tool that scales cleanly from zero spec to full spec wins the long game.

## What Kiro Validates

Kiro's existence is validation. Amazon investing in spec-driven AI development, and doubling down in April 2026 with CLI 2.0 and AWS Transform, proves the thesis:

1. **"Spec before code" works.** Users who actually use spec mode consistently report better outcomes than free-form prompting.
2. **EARS is one valid format.** Not the only one. BDD, user stories, acceptance criteria, plain markdown all work.
3. **The spec-to-code gap is real.** "It didn't do what I meant" is the #1 complaint about every AI coding tool. Better specs address it.
4. **Enterprise wants structure.** GovCloud, FedRAMP, audit trails, enterprises want provable requirements-to-code traceability.

The question isn't "specs or no specs", it's "where do specs live and who owns them?"

## The Emerging Pattern: Spec as a Protocol Layer

The most interesting development isn't any single tool, it's the industry converging on specs as a shared layer:

- **CLAUDE.md, AGENTS.md, .cursorrules, GEMINI.md, .github/copilot-instructions.md**: Every major tool supports context files now. These are proto-specs.
- **MCP servers**: Now Linux Foundation-stewarded (April 2026). Any supporting agent can consume structured context, including specs.
- **Kiro's EARS files**: Structured requirements as markdown. Portable in theory, locked in practice.
- **Agent Skills Specification**: Claude Code's open standard, now cross-tool via GitHub's `gh skill` command (April 16, 2026), covering Copilot, Claude Code, Cursor, Codex, Gemini CLI, Antigravity.

The tool that becomes the canonical spec format, the way OpenAPI became the standard for API specs, captures enormous value. That's the opportunity.

Cross-reference: ["Design-Driven Code Generation"](/blog/design-driven-code-generation), how structured design docs improve AI coding output.

## Related Articles

- [Spec-Driven Development in 2026: The Complete Guide and Tool Comparison](/blog/spec-driven-development)
- [Kiro Specs Explained: EARS, Spec Mode, and the Trade-offs](/blog/kiro-specs-explained)
- [EARS Notation Explained](/blog/ears-notation)
- [What Is a Spec?](/blog/what-is-a-spec)
- [BDD Specs for AI-Generated Code](/blog/bdd-specs-for-ai-generated-code)

## Sources

- [Kiro Feature Specs](https://kiro.dev/docs/specs/feature-specs/)
- [Kiro Introducing Blog](https://kiro.dev/blog/introducing-kiro/)
- [Kiro CLI 2.0 release, April 2026](https://kiro.dev/blog/)
- [AWS Transform in Kiro IDE, April 2026](https://aws.amazon.com/transform/)
- [Kiro vs Cursor, Morph](https://www.morphllm.com/comparisons/kiro-vs-cursor)
- [Kiro Agentic IDE Review, PeteScript](https://petermcaree.com/posts/kiro-agentic-ide-hype-hope-and-hard-truths/)
- [EARS Requirements Notation, Alistair Mavin](https://ieeexplore.ieee.org/document/5328509)
- [Claude Code Agent Skills Spec](https://code.claude.com/docs/en/skills)
- Reddit threads: [Has anyone used Kiro Code by Amazon](https://reddit.com/r/ChatGPTCoding/comments/1m0f4hm/), [Really cool feature in Kiro](https://reddit.com/r/ChatGPTCoding/comments/1m3cjt2/)
