# CodeMySpec Specs vs Kiro EARS: Two Approaches to Spec-Driven AI Development

## Introduction

The idea that AI coding tools need better instructions — not just better models — is gaining traction. Two tools are betting on this thesis from different angles:

**Kiro** (Amazon) generates specifications inside its IDE before writing any code, using EARS notation for structured requirements.

**CodeMySpec** takes a platform approach: specs as a layer that feeds into any coding agent, any editor, any workflow.

Both validate the same insight: the quality of the specification determines the quality of the AI-generated code. But they make fundamentally different architectural choices about where specs live, who owns them, and how they connect to the tools developers already use.

This isn't a "which is better" comparison — it's an analysis of two different bets on how spec-driven development will evolve.

## How Kiro Works

Kiro is a VS Code fork from Amazon, powered by Claude (Sonnet 4.6 and Opus 4.6). Its defining feature is **spec mode**: before writing a single line of code, Kiro generates three documents:

1. **requirements.md** — Requirements in EARS (Easy Approach to Requirements Syntax) notation. Structured, testable acceptance criteria covering edge cases.
2. **design.md** — System design describing components, data flow, and integration points.
3. **tasks.md** — Dependency-ordered implementation plan with discrete, executable steps.

You review and approve each document. Only then does Kiro start generating code, working through tasks.md step by step.

### EARS Notation

EARS structures requirements into five patterns:

- **Ubiquitous:** "The system shall [action]"
- **Event-Driven:** "When [event], the system shall [action]"
- **State-Driven:** "While [state], the system shall [action]"
- **Unwanted Behavior:** "If [condition], then the system shall [action]"
- **Optional:** "Where [condition], the system shall [action]"

This forces clarity. Instead of "handle errors gracefully," you get "When the API returns a 429 status code, the system shall retry with exponential backoff starting at 1 second, with a maximum of 3 retries."

### What Users Say

The spec-first approach has genuine fans:

> "I was genuinely impressed by Kiro. Its Spec mode is exactly how I think large, single-purpose tasks should be orchestrated, with clean, well-scoped specs driving the whole flow... This actually feels like engineering, not fighting the tool." — u/Pitiful_Guess7262, r/ChatGPTCoding

But the overhead is real:

> "Is it still slow as fuck" — u/AtariBigby, r/ChatGPTCoding (top comment on a positive Kiro thread)

And there's skepticism about Amazon's commitment:

> "A good idea that's going to be someone's promo and then when they get burned out and leave it will be taken on as a group project that no one will really work on." — u/donkeyking899, r/ChatGPTCoding

## How CodeMySpec Works

CodeMySpec takes the specification concept and makes it a platform rather than an IDE feature. The core premise: specs should be portable across tools, not locked into one editor.

### The Approach

1. **Specs as first-class artifacts** — Requirements, design decisions, and implementation plans live as standalone documents, not IDE state.
2. **Agent-agnostic delivery** — Specs flow to coding agents via:
   - **MCP servers** — Serve specs directly to Claude Code, Codex CLI, Gemini CLI, Goose, Cline
   - **Context files** — Generate CLAUDE.md, .cursorrules, GEMINI.md, .github/copilot-instructions.md from specs
   - **Direct consumption** — Any agent that reads markdown can consume CodeMySpec specs
3. **BDD-style specifications** — Behavior-driven development format with scenarios, acceptance criteria, and verification steps.
4. **Spec-to-verification pipeline** — Specs generate not just code but also the tests that verify the code meets the spec.

### The Key Difference

Kiro's specs exist inside Kiro. If you switch editors, leave Kiro, or want a different agent to execute the spec, you're on your own.

CodeMySpec's specs exist outside any tool. They're markdown files that any agent can read, any team can review, and any CI/CD pipeline can enforce.

## Side-by-Side Comparison

| Dimension | Kiro | CodeMySpec |
|---|---|---|
| **Spec format** | EARS notation (requirements.md, design.md, tasks.md) | BDD scenarios + acceptance criteria |
| **Where specs live** | Inside Kiro IDE | Standalone files (any repo, any tool) |
| **Agent lock-in** | Claude only, Kiro IDE only | Any agent (Claude Code, Codex, Gemini CLI, Aider, etc.) |
| **Editor lock-in** | Yes (VS Code fork) | No (specs are files, not IDE state) |
| **MCP integration** | Consumer (uses MCP servers) | Producer (serves specs via MCP) |
| **Verification** | Agent Hooks (auto-run tests on save/commit) | Spec-to-test generation pipeline |
| **Enterprise** | AWS GovCloud, IAM, pursuing FedRAMP High | — |
| **Pricing** | $20/mo (same models, less flexibility) | — |
| **Maturity** | Preview (buggy, slow) | Early (marketing-first, tooling emerging) |

## Where Each Approach Wins

### Kiro Wins When...

- **You're starting fresh on AWS.** GovCloud support, IAM integration, and Amazon backing make it the path of least resistance for AWS shops.
- **You want specs generated for you.** Kiro creates the spec from a natural language description. CodeMySpec (currently) requires you to write or collaborate on the spec.
- **You want a single integrated experience.** IDE + spec + agent + execution in one tool. No configuration, no MCP setup, no context file generation.
- **Compliance matters.** FedRAMP High pursuit, structured audit trail of requirements → design → tasks → code.

### CodeMySpec Wins When...

- **You use multiple tools.** If your team uses Claude Code, Cursor, and Copilot, CodeMySpec specs feed into all of them. Kiro specs feed into Kiro only.
- **You want agent flexibility.** Use Claude for architecture, Codex for implementation, Aider for cost-sensitive iteration — all consuming the same spec.
- **Specs are a team artifact.** Code reviews, stakeholder sign-off, compliance audits — specs that live as files in your repo integrate with existing team workflows.
- **You already have a spec practice.** If your team writes BDD scenarios, acceptance criteria, or design docs, CodeMySpec enhances that practice. Kiro replaces it with EARS.

## The "Spec Overhead" Problem

Both approaches face the same challenge: spec-driven development adds friction. For a quick bug fix or a one-line change, generating requirements, design docs, and task plans is overkill.

Kiro's Reddit feedback confirms this — users love spec mode for complex features but find it frustrating for simple tasks. The spec overhead is the #1 reason casual users bounce.

Any spec-driven tool needs to handle the spectrum:
- **One-liner:** "Fix the typo in the error message" → no spec needed
- **Small feature:** "Add rate limiting to the API" → brief acceptance criteria
- **Complex feature:** "Implement OAuth2 with PKCE flow" → full spec with requirements, design, edge cases

The tool that handles this gracefully — scaling from zero spec to full spec based on task complexity — wins the long game.

## What Kiro Validates for CodeMySpec

Kiro's existence is validation, not competition. Amazon investing in spec-driven AI development proves the market thesis:

1. **"Spec before code" works.** Users who use spec mode consistently report better outcomes than free-form prompting.
2. **EARS notation is one valid format.** But not the only one. BDD, user stories, acceptance criteria, and even plain markdown all work.
3. **The spec-to-code gap is real.** The biggest complaint about every AI coding tool is "it doesn't do what I meant." Better specs address this directly.
4. **Enterprise wants structure.** AWS GovCloud, FedRAMP, audit trails — enterprises want provable requirements-to-code traceability.

The question isn't "specs or no specs" — it's "where do specs live and who owns them?"

## The Emerging Pattern: Spec as a Protocol Layer

The most interesting development in this space isn't any single tool — it's the convergence toward specs as a shared layer:

- **CLAUDE.md, .cursorrules, GEMINI.md, .github/copilot-instructions.md** — Every major tool now supports context files. These are proto-specs.
- **MCP servers** — The Model Context Protocol enables serving structured context (including specs) to any supporting agent.
- **Kiro's EARS files** — Structured requirements as markdown. Portable in theory, locked in practice.
- **Agent Skills Specification** — Claude Code's open standard, adopted by OpenAI. Skills are executable specs.

The tool that becomes the canonical spec format — the way OpenAPI became the standard for API specs — captures enormous value. That's the opportunity.

Cross-reference: ["Design-Driven Code Generation"](/blog/design-driven-code-generation) — how structured design docs improve AI coding output.

## Sources

- [Kiro Feature Specs](https://kiro.dev/docs/specs/feature-specs/)
- [Kiro Introducing Blog](https://kiro.dev/blog/introducing-kiro/)
- [Kiro vs Cursor — Morph](https://www.morphllm.com/comparisons/kiro-vs-cursor)
- [Kiro Agentic IDE Review — PeteScript](https://petermcaree.com/posts/kiro-agentic-ide-hype-hope-and-hard-truths/)
- [EARS Requirements Notation — Alistair Mavin](https://ieeexplore.ieee.org/document/5328509)
- [Claude Code Agent Skills Spec](https://code.claude.com/docs/en/skills)
- Reddit threads: [Has anyone used Kiro Code by Amazon](https://reddit.com/r/ChatGPTCoding/comments/1m0f4hm/), [Really cool feature in Kiro](https://reddit.com/r/ChatGPTCoding/comments/1m3cjt2/)
