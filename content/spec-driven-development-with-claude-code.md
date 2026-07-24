---
# Metadata for spec-driven-development-with-claude-code.md

# Required fields
slug: spec-driven-development-with-claude-code
type: blog
title: "Spec-Driven Development with Claude Code"

# Publishing control
protected: false
publish_at: 2026-06-03T00:00:00Z
expires_at: null

# SEO Metadata
meta_title: "Spec-Driven Development with Claude Code"
meta_description: "How to do spec-driven development with Claude Code: CLAUDE.md limits, layering Spec Kit or OpenSpec, and CodeMySpec's enforced BDD gate plus live QA."
og_title: "Spec-Driven Development with Claude Code"
og_description: "CLAUDE.md, Spec Kit, OpenSpec, and CodeMySpec: how to add a real spec gate and verification on top of Claude Code."
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
  - claude-code
  - codemyspec
---

# Spec-Driven Development with Claude Code

Claude Code is a coding agent, not a spec-driven development tool. It reads your codebase, runs commands, edits files, and follows instructions. What it does not do on its own is hold you to a structured spec, derive code from it, and prove the result. If you want [spec-driven development](/blog/spec-driven-development) (SDD), where the spec is the source of truth and code is the derived artifact, you have to add that discipline on top of Claude Code yourself.

I build Phoenix apps with AI agents, and Claude Code is the agent I reach for most. This is a practical guide to doing SDD with it: what `CLAUDE.md` actually buys you, how to layer Spec Kit or OpenSpec on top when you want a real workflow, and where CodeMySpec fits, since it runs inside Claude Code as a plugin and adds the one thing none of the others enforce.

## Start with CLAUDE.md, and know its limits

The first thing every Claude Code user reaches for is `CLAUDE.md`. It is a markdown file Claude Code loads automatically into context at the start of a session. You drop one at the repo root (and optionally one per directory, plus a personal `~/.claude/CLAUDE.md`), and it becomes standing instructions: your stack, your conventions, your architecture, the commands to run tests and lint, the things you never want the agent to do.

A solid `CLAUDE.md` for a Phoenix project might pin down the framework version, the rule that business logic lives in contexts and never in LiveViews, the requirement that every write goes through an Ecto changeset, and the exact `mix` commands for test and format. That is genuinely useful. It cuts the rate at which the agent hallucinates APIs or scatters logic where it does not belong, and it survives across sessions instead of living in chat history you lose when the window resets.

Here is the honest limit: `CLAUDE.md` is guidance, not verification. It is a prompt the agent reads, not a contract the system enforces. Nothing checks that the generated code actually obeyed it. The file gets long, the agent's attention to any single line gets thin, and on a big task the instructions you cared about most are the ones that quietly slip. No gate says "this work does not satisfy the spec, so it does not pass." `CLAUDE.md` is a proto-spec: better than vibe-coding through chat, weaker than a real spec layer.

A common upgrade is to treat a `specs/` folder as input and point Claude Code at it ("read `specs/billing.md`, then implement it"). That helps, because now the intent lives in a durable file the agent reads on demand. It is still convention, though. The spec drives the first generation and then has no authority over what the code becomes. You have written down intent; you have not enforced it.

## Layer Spec Kit on Claude Code for a real workflow

When you want structure instead of a single instructions file, the most popular option is [GitHub Spec Kit](/blog/github-spec-kit-guide), and Claude Code was one of its first supported agents. Spec Kit is agent-agnostic by design: it supplies the workflow and the templates, and Claude Code does the generation.

Setup is a Python CLI. With `uv` installed, you run the initializer and pick Claude Code as your agent:

```
uvx --from git+https://github.com/github/spec-kit.git specify init my-project --ai claude
```

That writes a `.specify/` directory (templates, scripts, a `constitution.md`) and installs Claude Code slash commands. From inside Claude Code you then walk the phases:

- `/speckit.constitution` to set project principles.
- `/speckit.specify` to define the what and why (no tech details).
- `/speckit.plan` to choose the architecture and stack.
- `/speckit.tasks` to break the plan into ordered, testable units.
- `/speckit.implement` to have Claude Code execute the tasks.

Optional gates (`/speckit.clarify`, `/speckit.analyze`, `/speckit.checklist`) sit between those steps so you can reject or refine before code multiplies. Every artifact is plain markdown committed to your repo under `specs/[feature]/`, so it diffs and reviews like code.

This is a real step up from a bare `CLAUDE.md`. You get explicit checkpoints, a spec that drove the build, and a paper trail. The recurring criticism, well documented in field reviews, is volume and rigidity: a Scott Logic review described it as "a sea of markdown documents, long agent run-times and unexpected friction," and called the process document-heavy with overhead that did not always pay off. Spec Kit also has no verification loop. It produces dense prose specs the agent interprets, with nothing that proves the code conforms to them. Adoption, on the other hand, is enormous: [![GitHub stars](https://img.shields.io/github/stars/github/spec-kit?style=flat&label=stars&color=e25515)](https://github.com/github/spec-kit).

## Layer OpenSpec on Claude Code for something lighter

If Spec Kit feels heavy, [OpenSpec](/blog/openspec-explained) from Fission AI is the lighter repo-resident option, and it also supports Claude Code. It is an npm package that asks for no API key and no MCP server. You install it and initialize:

```
npm install -g @fission-ai/openspec
openspec init
```

Pick Claude Code during init and OpenSpec writes its slash commands. The default flow runs in the `opsx:` namespace: `propose` generates a full change proposal (intent, design, delta specs, task checklist), `apply` implements it, `sync` merges the change into your main specs, and `archive` files it. Specs live under `openspec/specs/[domain]/spec.md` as Requirements plus Given/When/Then scenarios, and OpenSpec's signature feature is delta tracking: each change records only the ADDED, MODIFIED, and REMOVED requirements, which makes it strong for evolving an existing codebase. It is consistently cited as the easiest SDD framework to start with: [![GitHub stars](https://img.shields.io/github/stars/Fission-AI/OpenSpec?style=flat&label=stars&color=e25515)](https://github.com/Fission-AI/OpenSpec).

The catch is the same one `CLAUDE.md` has, just better organized. OpenSpec's behavior scenarios are optional, `openspec validate` checks structure rather than behavior, and `/opsx:verify` is explicitly non-blocking ("won't block archive"). The dominant community complaint is spec drift: the specs do not self-update during implementation, so when Claude Code diverges from the spec, you resync by hand. You get a strong place to write down intent. Keeping that intent true to the code is still on you.

## Where the gap is, on every one of these

Stack back and the pattern is clear. `CLAUDE.md`, Spec Kit, and OpenSpec all make Claude Code spec-aware. None of them make Claude Code spec-accountable. The spec guides generation and then loses authority. No mandatory behavioral gate stops bad work, and no step boots the app to check that the feature works. You are trusting that the agent followed the document, which is a polite way of saying you are back to praying it got it right.

For small or exploratory work, that trust is fine. For a feature you are going to ship and maintain, the missing piece is enforcement: a spec the work has to satisfy, and verification that the running software does what the spec said.

## CodeMySpec: SDD inside Claude Code with an enforced gate

[CodeMySpec](/developers) is the full-lifecycle, spec-driven AI development harness I built for Phoenix and Elixir, and it is distributed as a Claude Code plugin (with a local MCP server and a web app). The point of difference is not that it generates specs. Spec Kit and OpenSpec do that too. The point is that it enforces a behavioral spec as a gate and then verifies the running app, neither of which the others do.

Working inside Claude Code, the pieces are:

- **A requirement graph.** Every artifact (spec, BDD scenario, generated test, implementation, QA result) is a node with prerequisites on one graph. The harness computes what to work on next (`get_next_requirement` then `start_task`) instead of leaving you to thread the workflow by hand.
- **Mandatory BDD specs.** Acceptance criteria become behavior scenarios in the Spex DSL. These BDD specs are a non-negotiable gate; work has to pass them. Module specs, reviews, and generated tests are configurable knobs on top, but the behavioral contract is not optional. That is the line `CLAUDE.md` and OpenSpec do not draw.
- **Generated ExUnit tests.** Specs produce acceptance criteria and real ExUnit tests in your existing toolchain, so verification lives where your suite already lives.
- **Live browser QA.** The `qa` subagent writes a brief from the BDD specs, boots the real Phoenix app, drives a real browser through Vibium MCP, screenshots the result, and files issues with severity. Unit tests pass, BDD specs pass, then the QA agent clicks the button and finds the bug anyway. No other tool in this space does live-app verification.

And it stays portable. Specs are markdown, tests are ExUnit, and the artifacts are served to any agent via MCP or generated context files (`CLAUDE.md`, `AGENTS.md`, `.cursorrules`, `GEMINI.md`). Bring your own agent, your own model, your own keys; the harness adds no token markup. Running it inside Claude Code is the path I use most, but you are not locked to it.

The honest framing: portability and repo-resident specs are table stakes here, and Spec Kit and OpenSpec meet them too. The combination CodeMySpec rests on is the wedge: a mandatory BDD gate, built-in live verification, the full lifecycle on one graph, and Phoenix-native depth a stack-neutral tool cannot match. CodeMySpec is in early access and free during that period, so the practical move is to run it on a real feature and tell me where it falls short.

## What to use when

If you are exploring or doing small changes, a disciplined `CLAUDE.md` plus a `specs/` folder you point Claude Code at is enough, and it costs you nothing. When you want a repeatable workflow with checkpoints and a paper trail, add Spec Kit for the full toolkit or OpenSpec for the lighter, brownfield-friendly version; both treat Claude Code as a first-class agent. When the work has to be enforced and verified, and especially when the work is Phoenix, that is where a harness with a mandatory gate and live QA earns its place. Prompting is praying. Verification is a guarantee.

What does your `CLAUDE.md` look like, and how far does it actually get you before the agent drifts?

## Related Articles

- [What Is a Spec? The Most Overloaded Word in Software](/blog/what-is-a-spec)
- [Spec-Driven Development in 2026: The Complete Guide and Tool Comparison](/blog/spec-driven-development)
- [GitHub Spec Kit: How It Works and When to Use It (2026)](/blog/github-spec-kit-guide)
- [OpenSpec Explained: Repo-Native Spec-Driven Development](/blog/openspec-explained)
- [Spec-Driven Development for Elixir and Phoenix](/blog/spec-driven-development-elixir)
- [CodeMySpec](/developers)

## Sources

- Claude Code memory and CLAUDE.md docs: https://docs.anthropic.com/en/docs/claude-code/memory
- GitHub Spec Kit launch post (2025-09-02): https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/
- GitHub Spec Kit repo (CLI, `.specify/` structure, agent list incl. Claude Code): https://github.com/github/spec-kit
- Scott Logic, "Putting Spec Kit Through Its Paces" (2025-11-26): https://blog.scottlogic.com/2025/11/26/putting-spec-kit-through-its-paces-radical-idea-or-reinvented-waterfall.html
- OpenSpec repo (npm install, opsx workflow, delta tracking, Claude Code support): https://github.com/Fission-AI/OpenSpec
- OpenSpec workflows (`/opsx:verify` "won't block archive," scenarios optional): https://github.com/Fission-AI/OpenSpec/blob/main/docs/workflows.md
- OpenSpec homepage (lightweight, brownfield-first, "No API Keys," "No MCP"): https://openspec.dev/
- Hacker News practitioner sentiment on OpenSpec drift: https://news.ycombinator.com/item?id=47994433
- Martin Fowler / Birgitta Böckeler, three-level SDD taxonomy: https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html
