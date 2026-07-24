---
# Metadata for codemyspec-vs-openspec.md

# Required fields
slug: codemyspec-vs-openspec
type: blog
title: "CodeMySpec vs OpenSpec: Enforced Specs vs Living Docs"

# Publishing control
protected: false
publish_at: 2026-06-03T00:00:00Z
expires_at: null

# SEO Metadata
meta_title: "CodeMySpec vs OpenSpec: Enforced Specs vs Docs"
meta_description: "CodeMySpec vs OpenSpec: both are repo-resident and BYO-agent. The split is enforcement and live verification. An honest, specific comparison."
og_title: "CodeMySpec vs OpenSpec: Enforced Specs vs Living Docs"
og_description: "Both keep specs in your repo with no lock-in. The difference: OpenSpec's behavior spec is optional, CodeMySpec enforces it and verifies against the running app."
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
  - openspec
  - codemyspec
---

# CodeMySpec vs OpenSpec: Enforced Specs vs Living Docs

OpenSpec and CodeMySpec agree on more than they disagree on: repo-resident specs, bring-your-own-agent, no lock-in, no token markup, specs before code. The split is enforcement and verification. OpenSpec gives you an optional behavior contract and a manual living changelog across any stack, while CodeMySpec makes the behavior spec a mandatory gate, boots the real app to verify it, and goes framework-native in Phoenix.

If you are evaluating both, that one sentence is the decision. The rest of this page is the detail behind it.

## Where We Agree

Most comparison pages open by inventing differences. I'll start with the overlap, because it's real and pretending otherwise would cost me credibility:

- **Specs live in your repo.** Both tools keep specs as version-controlled files alongside code, not in a proprietary cloud silo. Both treat the spec as a portable protocol the agent reads.
- **Bring your own agent.** Both are agent-neutral. OpenSpec feeds 20+ assistants (Claude Code, Cursor, Copilot, Gemini CLI, Codex, Amazon Q, Cline, and more) via installed Skills and slash commands. CodeMySpec serves specs through MCP servers (Claude Code, Codex, Gemini CLI, Goose, Cline) or generated context files (CLAUDE.md, AGENTS.md, .cursorrules, GEMINI.md, copilot-instructions.md).
- **No token tax.** OpenSpec requires no API key at all, since it never calls an LLM itself. CodeMySpec is explicitly bring-your-own-key with no token markup. Neither tool monetizes inference.
- **Specs before code.** Both believe spec quality precedes good AI-generated code. Both put a human-aligned spec in front of generation.
- **Behavioral vocabulary in both.** OpenSpec *does* use Given/When/Then scenarios. CodeMySpec uses BDD scenarios. The honest contrast is not whether behavior shows up in the spec. It is whether the tool *enforces* it and *verifies* it.

If you want a portable, repo-resident, no-lock-in SDD layer, both tools deliver. The decision is about what happens when the spec and the code disagree.

## How OpenSpec Works

OpenSpec (from Fission AI, MIT-licensed, with a large and growing GitHub community, latest release v1.4.1 on 2026-06-03) is a lightweight, brownfield-first spec layer you install as an npm package and run with `openspec init`. It never calls a model; it rides on whatever agent you already pay for.

The workflow is a slash-command cycle: `propose -> explore -> apply -> sync -> archive`.

- **Propose** generates a full change proposal in one shot: intent, a design doc, delta specs, and a task checklist.
- **Apply** runs the implementation tasks through your agent.
- **Sync** merges the change's delta specs into the main specs.
- **Archive** moves the completed change to a dated folder, prompting a sync if the specs were not merged.

Specs are organized by domain. Under `openspec/specs/[domain]/spec.md` you get **Requirements** (using RFC 2119 MUST/SHALL/SHOULD) plus **Scenarios** in Given/When/Then. The docs explicitly call a spec a "behavior contract, not an implementation plan."

The signature feature is **delta tracking**. A change does not restate the whole spec. Its `changes/[name]/specs/` folder holds delta specs marked ADDED, MODIFIED, or REMOVED. On archive, those deltas merge into the main spec, so documentation compounds over time. Because deltas are scoped to individual requirements, two in-flight changes can edit the same `spec.md` without conflicting as long as they touch different requirements. This is genuinely good for iterating on existing systems, and it enables intent-based code review: a reviewer reads the delta to grasp what changed and why, instead of reverse-engineering a diff.

On verification, the nuance matters. `openspec validate` (optionally `--strict`) checks **structure only**: required sections present, valid format, cross-artifact dependencies. It does not check behavioral correctness and does not run tests. The extended profile adds `/opsx:verify`, which assesses completeness, correctness, and coherence, but the docs are explicit: **"Verify won't block archive."** And `archive --no-validate` skips checks entirely. Given/When/Then scenarios factor into the verify assessment but their creation is never a blocking requirement.

Net: OpenSpec has advisory verification and structural validation, but no mandatory blocking gate and no behavioral-spec or test enforcement.

## How CodeMySpec Works

CodeMySpec is a full-lifecycle, specification-driven AI development harness for Phoenix and Elixir, distributed as a Claude Code plugin plus a local MCP server and the web app at codemyspec.com.

The core mental model is a **requirement graph**. Every artifact (spec, test, implementation, BDD scenario, QA result) is a node with prerequisites. The system computes what to work on next through a `get_next_requirement -> start_task` loop, so you never stare at a blank repo wondering what is unblocked.

Specs come in two forms. **BDD scenarios** in the Spex DSL come from acceptance criteria and are **mandatory**. They are the gate. **Module specs**, along with reviews and test requirements, are configurable knobs you can turn on or off. You can relax the module-level rigor; you cannot skip the behavior spec.

Verification is the part no other tool in this space does. A `qa` subagent plans, writes a brief from the BDD specs, boots the real application, drives a real browser through the Vibium MCP, takes screenshots, and files issues with severity. The line that captures it: unit tests pass, BDD specs pass, then the QA agent clicks the button and finds the bug anyway. Prompting is praying; verification is a guarantee.

And it is Elixir-native. Phoenix contexts, LiveView, Ecto, and OTP are first-class. The specs understand the framework's architectural idioms rather than treating your stack as a generic file tree.

## The Core Difference

OpenSpec asks for a behavior contract. CodeMySpec requires one and won't let work pass without it.

That is the whole argument. OpenSpec's Given/When/Then scenarios are optional, its `verify` explicitly won't block archive, its `validate` checks structure not behavior, and `archive --no-validate` bypasses checks. The spec is a strong convention, not a hard contract the system enforces. In practice OpenSpec is closer to a spec-as-living-changelog than a spec-as-enforced-source-of-truth.

CodeMySpec inverts that. The behavior spec is the gate, and a live-app QA pass on top checks that the running software actually matches it. The spec is not documentation that hopefully stays current. It is the contract code must satisfy before the requirement node closes.

## Side-by-Side

| Dimension | OpenSpec | CodeMySpec |
|---|---|---|
| **Category** | Lightweight repo-resident SDD layer | Full-lifecycle harness on a requirement graph |
| **Spec format** | Structured markdown + optional Given/When/Then + delta tracking | BDD scenarios (Spex) + configurable module specs |
| **Where specs live** | In the repo (`openspec/`) | In the repo, on a requirement graph |
| **Behavior spec** | Optional, advisory | Mandatory gate |
| **Enforcement** | `validate` = structure only; `verify` won't block archive | Blocking BDD gate; reviews/tests configurable |
| **Verification** | None (no test execution) | Live browser QA + generated tests |
| **Agent lock-in** | None (20+ agents, no API key, no MCP) | None (any agent, BYO model/keys, via MCP or context files) |
| **Stack awareness** | Stack-neutral, structurally generic | Phoenix/Elixir-native |
| **Primary job** | Brownfield change tracking (delta-led) | Spec-quality-led build across the lifecycle |
| **Pricing** | Free, MIT, v1.4.1 (Jun 2026) [![GitHub stars](https://img.shields.io/github/stars/Fission-AI/OpenSpec?style=flat&label=stars&color=e25515)](https://github.com/Fission-AI/OpenSpec) | Free during early access |

## Where Each Wins

### OpenSpec Wins When...

- **You want the lightest possible footprint.** OpenSpec's output is famously lean (roughly 250 lines per change versus much heavier alternatives), which keeps review overhead low. It is consistently cited as the easiest SDD framework to start with.
- **You are iterating on a brownfield codebase.** Delta tracking is built for 1->n work on mature systems. ADDED/MODIFIED/REMOVED markers stop an agent from hallucinating requirements onto existing behavior, and parallel non-conflicting changes are a real payoff.
- **You want zero setup and zero LLM cost in the tool itself.** No API key, no MCP, npm install and go.
- **You need the broadest agent support today.** 20+ assistants, more than CodeMySpec's current roster, across any stack.
- **You don't want the tool to have an opinion about your stack.** OpenSpec's neutrality means it works the same in Python, Go, TypeScript, or Rust.

### CodeMySpec Wins When...

- **You want the behavior spec enforced, not suggested.** If "the agent drifted and nobody noticed" is a failure mode you have lived, a mandatory BDD gate is the answer. OpenSpec lets you skip the behavior spec; CodeMySpec won't.
- **You want verification, not just specification.** CodeMySpec boots the app and drives a real browser to confirm the software does what the spec says. OpenSpec has no test execution and no live verification of any kind.
- **You want the full lifecycle on one graph.** Requirements, specs, architecture, code, tests, and QA results are all nodes with prerequisites, and the system tells you what to build next. OpenSpec covers the propose-to-archive change loop, not the whole graph.
- **You are building in Phoenix or Elixir.** Framework-native depth across contexts, LiveView, Ecto, and OTP is something a deliberately stack-generic tool cannot match.

## The Drift Question

The dominant community complaint about OpenSpec is spec drift. The specs do not self-update during implementation, so when the agent diverges, you resync by hand. One Hacker News practitioner reported giving up on sync entirely: "it just keeps drifting and drifting until you have duplication and contradictions across specs... maintaining the main specs is not worth it." They now archive specs straight after implementation, discarding the living-spec benefit that is the whole point.

This is not a cheap shot. It is the structural cost of advisory verification. If nothing blocks on spec/code divergence, divergence is the default outcome over time. OpenSpec's own positioning is honest about requiring discipline: it works "if you invest enough in the specs."

CodeMySpec's bet is that you should not have to supply that discipline by hand. The spec is the gating contract code must satisfy, and the QA pass checks conformance against the running app, which structurally resists the drift OpenSpec users self-report. That is the trade: CodeMySpec asks more of you up front (a mandatory gate, a Phoenix-shaped opinion) in exchange for not asking you to manually police drift forever.

And the honest caveat in the other direction: CodeMySpec is early access with tooling still emerging, while OpenSpec is past v1.0, actively shipping, and battle-tested by a large community. If broad maturity and a 20+ agent install base matter more to you than enforcement and verification today, that is a legitimate reason to start with OpenSpec.

## Spec as a Protocol

Both tools believe the same thing the rest of the field is converging on: the spec is a portable protocol the agent consumes, and it belongs in your repo where any agent, any reviewer, and any pipeline can read it. OpenSpec treats that protocol as a living changelog you maintain. CodeMySpec treats it as a contract the system enforces and then verifies against the running app.

Most SDD tools are spec-only: they generate a spec and hand off to a separate agent. CodeMySpec is spec, code, test, and live verification in one system, tracked on a requirement graph. If you want a lightweight, stack-neutral way to keep specs and code roughly in step, OpenSpec is an excellent default. If you want the spec to be a guarantee rather than a convention, and you are building in Phoenix, that is [CodeMySpec](/developers).

## Related Articles

- [What Is a Spec? The Most Overloaded Word in Software](/blog/what-is-a-spec)
- [Spec-Driven Development in 2026: The Complete Guide and Tool Comparison](/blog/spec-driven-development)
- [OpenSpec Explained: Repo-Native Spec-Driven Development](/blog/openspec-explained)
- [OpenSpec vs Spec Kit: Lightweight vs Full Toolkit](/blog/openspec-vs-spec-kit)
- [CodeMySpec Specs vs Kiro EARS: Two Approaches to Spec-Driven AI Development](/blog/codemyspec-vs-kiro-specs)
- [CodeMySpec](/developers)

## Sources

- [OpenSpec repo (Fission AI)](https://github.com/Fission-AI/OpenSpec): tagline, MIT license, npm install, opsx workflow, directory structure, v1.4.1 (2026-06-03), brownfield framing.
- [OpenSpec concepts docs](https://github.com/Fission-AI/OpenSpec/blob/main/docs/concepts.md): specs by domain, behavior-contract definition, Requirements + GWT Scenarios + RFC 2119, delta specs ADDED/MODIFIED/REMOVED, source-of-truth and parallel non-conflicting changes.
- [OpenSpec workflows docs](https://github.com/Fission-AI/OpenSpec/blob/main/docs/workflows.md): propose/explore/apply/sync/archive, `/opsx:verify` "won't block archive," scenarios optional.
- [OpenSpec CLI docs](https://github.com/Fission-AI/OpenSpec/blob/main/docs/cli.md): validate = structural only, `--strict`, `archive --no-validate`, no API key / no LLM auth.
- [OpenSpec supported tools](https://github.com/Fission-AI/OpenSpec/blob/main/docs/supported-tools.md): 20+ assistants, Skills + Commands integration model.
- [openspec.dev](https://openspec.dev/): positioning: lightweight, brownfield-first, "specs live in your code," "No API Keys," "No MCP," free OSS.
- [intent-driven.dev: OpenSpec analysis](https://intent-driven.dev/knowledge/openspec/): independent strengths/weaknesses, lighter output, "true SDD" assessment.
- [Augment Code: best SDD tools (2026-03-07)](https://www.augmentcode.com/tools/best-spec-driven-development-tools): ~250 vs ~800 lines, static specs drift, no multi-agent, no enterprise/SSO.
- [dev.to: Spec Kit vs BMAD vs OpenSpec (2026-04-23)](https://dev.to/willtorber/spec-kit-vs-bmad-vs-openspec-choosing-an-sdd-framework-in-2026-d3j): delta markers, compounding docs, "specs don't self-update... resync manually."
- [Hacker News practitioner thread](https://news.ycombinator.com/item?id=47994433): drift complaint ("keeps drifting... duplication and contradictions," "maintaining the main specs is not worth it"), large/legacy alignment gap.
