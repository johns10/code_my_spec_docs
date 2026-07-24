---
# Metadata for openspec-vs-spec-kit.md

# Required fields
slug: openspec-vs-spec-kit
type: blog
title: "OpenSpec vs Spec Kit: Lightweight vs Full Toolkit (2026)"

# Publishing control
protected: false
publish_at: 2026-06-03T00:00:00Z
expires_at: null

# SEO Metadata
meta_title: "OpenSpec vs Spec Kit (2026): Brownfield vs Greenfield"
meta_description: "OpenSpec vs Spec Kit (2026): lightweight brownfield change-tracker vs the full greenfield toolkit. Table, strengths, and which Spec Kit alternative to pick."
og_title: "OpenSpec vs Spec Kit (2026)"
og_description: "Spec Kit is the full, greenfield toolkit with the biggest community. OpenSpec is the lightweight, brownfield change-tracker. Here's how to pick, plus a fair third option."
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
  - github-spec-kit
  - comparison
  - tools
---

# OpenSpec vs Spec Kit: Lightweight vs Full Toolkit (2026)

If you are choosing a spec-driven development framework in 2026, the two names you will hit first are GitHub Spec Kit and OpenSpec. They share a thesis (write the spec before the code, keep it in your repo, hand it to whatever AI agent you already use), but they make opposite bets on how much process you should carry. Spec Kit is the heavyweight, greenfield-oriented toolkit with GitHub's brand and the biggest community in the space. OpenSpec is the lightweight, brownfield-first framework built around change tracking, with no API key and no MCP required.

I have read deeply into both and run spec-first workflows on real Phoenix apps. Here is the honest breakdown: what each one actually does, where each one breaks down, and how to pick.

## The core difference in one paragraph

Spec Kit gives you a full pipeline (constitution, specify, clarify, plan, analyze, tasks, implement) that produces a stack of dense Markdown documents per feature. It takes a project from zero to a working system through deliberate up-front planning. OpenSpec gives you a much smaller loop (propose, apply, sync, archive) built around a "delta" model where each change describes only what it adds, modifies, or removes against a source-of-truth spec. Spec Kit optimizes for structure and starting clean. OpenSpec optimizes for low overhead and changing code that already exists.

## Side-by-side

| Dimension | GitHub Spec Kit | OpenSpec |
|---|---|---|
| Maker | GitHub (Microsoft) | Fission AI |
| License | MIT, free | MIT, free |
| Install | Python CLI (`specify` via `uv`/`pipx`) | npm (`@fission-ai/openspec`), Node 20.19+ |
| Workflow | constitution -> specify -> clarify -> plan -> analyze -> tasks -> implement | propose -> apply -> sync -> archive |
| Spec format | Prose Markdown (`spec.md`, `plan.md`, `tasks.md`, contracts) | Structured Markdown, optional Given/When/Then, RFC 2119 keywords |
| Signature feature | Multi-phase pipeline with review gates | Delta tracking (ADDED / MODIFIED / REMOVED requirements) |
| Center of gravity | Greenfield, structured up-front planning | Brownfield, change-led iteration |
| Output weight | Heavy (~800 lines reported per change) | Light (~250 lines reported per change) |
| Quality gate | Convention only (clarify / analyze are advisory steps) | Convention only (`validate` = structure; `verify` won't block archive) |
| Verification | None | None |
| Agent lock-in | None (~30+ agents) | None (30 agents, no API key, no MCP) |
| Adoption | [![GitHub stars](https://img.shields.io/github/stars/github/spec-kit?style=flat&label=stars&color=e25515)](https://github.com/github/spec-kit) | [![GitHub stars](https://img.shields.io/github/stars/Fission-AI/OpenSpec?style=flat&label=stars&color=e25515)](https://github.com/Fission-AI/OpenSpec) |

Re-verify the star counts at read time; both move fast.

## How Spec Kit works

Spec Kit installs a Python CLI and a set of slash commands into your agent. You run them in sequence: `/speckit.constitution` to set project principles, `/speckit.specify` for the what and why, `/speckit.clarify` to refine underspecified areas, `/speckit.plan` for the technical how, `/speckit.analyze` for cross-artifact consistency, `/speckit.tasks` to break the plan into ordered units, and `/speckit.implement` to generate code. Every artifact is plain Markdown committed to your repo under `specs/[feature-name]/` and `.specify/`.

The philosophy is explicit and ambitious. The repo's own framing calls it a "power inversion": "Specifications don't serve code, code serves specifications," and the PRD "isn't a guide for implementation; it's the source that generates implementation." That is the strongest possible SDD claim, and Spec Kit commits to it openly while also labeling itself "an experiment designed to test how well the methodologies behind Spec-Driven Development actually work."

## How OpenSpec works

OpenSpec is a thinner layer. You run `openspec init`, then drive a short loop with the `opsx:` commands: `/opsx:propose` generates a full change proposal (intent, design, delta specs, task checklist) from one request, `/opsx:apply` executes the tasks, `/opsx:sync` merges the change's deltas into the main specs, and `/opsx:archive` files the completed change away with a date prefix.

Specs live in your repo organized by domain: `openspec/specs/[domain]/spec.md` holds requirements and optional Given/When/Then scenarios, framed in the docs as a "behavior contract, not an implementation plan." The signature mechanic is delta tracking. A change does not restate the whole spec; its `changes/[name]/specs/` folder contains only ADDED, MODIFIED, and REMOVED requirements. On archive, those deltas merge back into the main spec, so documentation compounds over time. Because deltas are scoped to individual requirements, two in-flight changes can edit the same `spec.md` without conflicting as long as they touch different requirements. It rides on whatever agent you already run and never calls an LLM itself: no API key, no MCP.

## Strengths and weaknesses

### Spec Kit strengths
- Real structure with explicit checkpoints. The clarify and analyze steps give teams places to reject or refine before code multiplies, which matters when correctness beats demo speed.
- GitHub's brand plus the largest community in the space, with a deep bench of contributors and extensions. It is the default reference point for the whole SDD conversation.
- Specs are plain Markdown in your repo: diffable, reviewable, versionable like code, portable across 30+ agents.

### Spec Kit weaknesses
The recurring criticism is weight. The Scott Logic review ("Putting Spec Kit Through Its Paces: Radical Idea or Reinvented Waterfall?", 2025-11-26) found the process rigid and the docs dense, describing "a sea of markdown documents, long agent run-times and unexpected friction" and concluding there was no "qualitative benefit to justify the overhead." Critics warn the up-front spec-plan-tasks sequence can re-introduce the rigidity agile tried to escape, the "reinvented waterfall" line in the review's own title. On Hacker News, *yodon* likes it but says the tutorials are "pretty elementary" and lack real-world cases like "making incremental improvements or refactorings to a huge legacy code base," with no good guidance for mid-implementation spec changes. *ares623* raises a determinism doubt: he wants to "generate the project multiple times using the same spec" to "see how aligned it really makes things." And because the specs are prose, the old 5GL/BDD critique applies: natural language is not actually unambiguous, and there is no loop that proves the code conforms to the spec.

### OpenSpec strengths
- Delta tracking is genuinely good for brownfield 1->n. Scoped ADDED/MODIFIED/REMOVED changes prevent requirement hallucination onto existing behavior and let multiple changes proceed in parallel without conflict.
- Lightweight output (~250 lines vs Spec Kit's ~800 in the Augment Code roundup), which cuts review overhead.
- Intent-based code review: a reviewer reads the delta to understand what changed and why, without reverse-engineering the diff.
- True no-lock-in portability: repo-resident files, 30 agents, no API key, no MCP, no proprietary runtime. It is frequently cited as the easiest SDD framework to start with.

### OpenSpec weaknesses
The dominant complaint is manual spec drift. Augment Code (2026-03-07) and intent-driven.dev both note that specs "don't self-update during implementation. If the agent drifts (and it will), you resync manually." One Hacker News practitioner abandoned sync entirely: "it just keeps drifting and drifting until you have duplication and contradictions across specs... maintaining the main specs is not worth it." He now archives specs directly after implementation, which discards the living-spec benefit. The same practitioner flagged a codebase-alignment gap on large repos: when specs change, "AI needs to find the relevant code to change it. It's pretty easy to miss something in a large codebase (especially when there is lots of legacy stuff)." Others note the full proposal/design/tasks cycle is overkill for bug fixes or copy tweaks, there is no multi-agent orchestration, and no enterprise features (no multi-repo, no SSO/SCIM).

Worth being precise on one point: OpenSpec does have behavioral vocabulary (Given/When/Then scenarios), but they are optional, `validate` checks structure only, and `verify` is advisory and "won't block archive." Neither tool has a mandatory quality gate, and neither verifies that the generated code actually behaves as specified.

## Which should you choose

Pick **Spec Kit** if you are starting greenfield, want the most structure and review checkpoints, value GitHub's brand and the largest community, and your work justifies the up-front planning weight. It shines when correctness matters more than speed and you are building something new with no existing code to fit.

Pick **OpenSpec** if you are iterating on an existing codebase, want a lightweight loop with minimal overhead, and value change tracking that records exactly what each change added, modified, or removed. It is the pragmatic low-friction default, and the easiest to adopt if you are unsure where to start. Just budget for the manual sync discipline its drift problem demands.

The dividing line is clean: Spec Kit is the full toolkit for building new; OpenSpec is the lightweight tracker for changing what exists.

## A third option: CodeMySpec

Both Spec Kit and OpenSpec stop at the same place. They are spec tools (they help you write a good spec and hand it to an agent), but neither enforces a behavioral spec as a mandatory gate, and neither verifies that the code the agent produced actually does what the spec says. Spec Kit's clarify/analyze steps are advisory. OpenSpec's `verify` "won't block archive." In both, the spec governs the code by convention, not by enforcement, and nothing closes the loop between spec and running software.

[CodeMySpec](/developers) makes a different bet on those two gaps. BDD specs are a mandatory gate: you cannot pass work without them (module specs, reviews, and tests are configurable knobs on top). And verification is built in: a QA agent boots the real app, drives a live browser, screenshots, and files issues by severity. Unit tests pass, the BDD specs pass, and then the QA agent clicks the button and finds the bug anyway. No other tool in this comparison runs the live app to confirm the spec held. It is also Phoenix/Elixir-native, where Spec Kit and OpenSpec are deliberately stack-neutral, a depth trade-off (theirs is breadth across stacks; CodeMySpec's is depth in one).

To be fair to both: repo-resident specs, bring-your-own-agent, and no token markup are not unique to CodeMySpec, since OpenSpec and Spec Kit meet that bar too. The honest difference is the combination of a mandatory behavioral gate plus live verification plus framework-native depth. If you want a lightweight changelog across any stack, OpenSpec fits. If you want structured greenfield planning with the biggest community, Spec Kit fits. If you want the spec to be an enforced contract the running app is checked against, that is the wedge CodeMySpec is built on.

## Related Articles

- [What Is a Spec? The Most Overloaded Word in Software](/blog/what-is-a-spec)
- [Spec-Driven Development in 2026: The Complete Guide and Tool Comparison](/blog/spec-driven-development)
- [OpenSpec Explained: Repo-Native Spec-Driven Development](/blog/openspec-explained)
- [GitHub Spec Kit: How It Works and When to Use It](/blog/github-spec-kit-guide)
- [Kiro vs OpenSpec: Integrated AWS IDE vs Lightweight Spec Tool](/blog/kiro-vs-openspec)
- [CodeMySpec vs OpenSpec: Enforced Specs vs Living Docs](/blog/codemyspec-vs-openspec)
- [The Harness Layer: Harness vs Wrapper in AI Coding](/blog/the-harness-layer)
- [Tessl Review 2026: Framework, Pricing, Skills and Funding](/blog/tessl-review)

## Sources

- https://github.com/github/spec-kit official repo: MIT license, 7-phase `speckit.*` command set, `.specify/` + `specs/` structure, 30+ agents, experimental framing.
- https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/ official launch post (2025-09-02), Den Delimarsky; philosophy and phases.
- https://github.com/github/spec-kit/blob/main/spec-driven.md core philosophy quotes (power inversion, PRD as source, executable specs).
- https://blog.scottlogic.com/2025/11/26/putting-spec-kit-through-its-paces-radical-idea-or-reinvented-waterfall.html critique: rigidity, dense docs, "sea of markdown," overhead, "reinvented waterfall."
- https://news.ycombinator.com/item?id=45577377 HN: *yodon* (weak on legacy/refactor + mid-implementation changes), *ares623* (determinism doubt).
- https://github.com/Fission-AI/OpenSpec repo: MIT, npm install, Node 20.19+, opsx workflow, directory structure, brownfield framing, v1.4.1 (2026-06-03).
- https://github.com/Fission-AI/OpenSpec/blob/main/docs/concepts.md specs by domain, behavior-contract definition, delta specs ADDED/MODIFIED/REMOVED mechanics, parallel non-conflicting changes.
- https://github.com/Fission-AI/OpenSpec/blob/main/docs/workflows.md propose/apply/sync/archive, `/opsx:verify` "won't block archive," scenarios optional.
- https://github.com/Fission-AI/OpenSpec/blob/main/docs/cli.md validate = structural only, `archive --no-validate`, no API key / no LLM auth.
- https://www.augmentcode.com/tools/best-spec-driven-development-tools 2026-03-07 roundup: ~250 vs ~800 lines, drift, no multi-agent, no enterprise/SSO.
- https://dev.to/willtorber/spec-kit-vs-bmad-vs-openspec-choosing-an-sdd-framework-in-2026-d3j 2026-04-23: delta markers prevent hallucination, "resync manually," overhead on simple tasks.
- https://news.ycombinator.com/item?id=47994433 HN practitioner: drift complaint ("keeps drifting... duplication and contradictions"), large/legacy alignment gap.
- https://intent-driven.dev/knowledge/openspec/ independent analysis: spec-anchored alignment, lighter output, manual sync caveat.
