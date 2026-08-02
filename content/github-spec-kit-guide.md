---
# Metadata for github-spec-kit-guide.md

# Required fields
slug: github-spec-kit-guide
type: blog
title: "GitHub Spec Kit: How It Works and When to Use It (2026)"

# Publishing control
protected: false
publish_at: 2026-06-03T00:00:00Z
expires_at: null

# SEO Metadata
meta_title: "GitHub Spec Kit: How It Works (2026 Guide)"
meta_description: "What is GitHub Spec Kit? A 2026 guide to the /specify -> /plan -> /tasks -> implement workflow, its strengths, the sea-of-markdown critique, and where it stops."
og_title: "GitHub Spec Kit: How It Works and When to Use It"
og_description: "A hands-on guide to GitHub's spec-driven toolkit -- the workflow, strengths, the reinvented-waterfall critiques, and how it stacks up against an enforced harness."
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
  - github-spec-kit
  - spec-kit
---

# GitHub Spec Kit: How It Works and When to Use It (2026)

Spec Kit is the most visible thing in [spec-driven development](/blog/spec-driven-development) right now, and most of that is GitHub's brand and a very large, fast-growing repo doing the talking. The tool itself is good at one job and stops dead at another, and the gap between those two is the whole story.

GitHub Spec Kit is an open-source toolkit that bolts a structured, spec-first workflow onto whatever AI coding agent you already use, turning Markdown specs into the artifact that drives code generation. I've read the philosophy doc, dug through the field reports, and the pattern is consistent: it gets you a clean spec and a first generation, then leaves you on your own. Here's how the `/specify -> /plan -> /tasks -> implement` loop works, where it shines, the criticisms it has earned, and where it stops compared to a full-lifecycle harness like CodeMySpec.

## What Spec Kit is

Spec Kit is a project from GitHub (owned by Microsoft), shipped under the official `github/spec-kit` org with an MIT license. The public face is Den Delimarsky, a Principal Product Manager at GitHub, who authored the launch post on the GitHub Blog (September 2, 2025) and maintains an ongoing explainer series.

The framing GitHub itself uses is important: Spec Kit is "an experiment designed to test how well the methodologies behind Spec-Driven Development actually work." It is not pitched as a finished product. It ships frequent releases and leans heavily on community input.

Adoption has been extraordinary. The repo has one of the largest GitHub followings in the whole category, and it keeps climbing month over month. The point is that Spec Kit has default-tool gravity in the SDD conversation, and GitHub's brand is a big part of why. That matters when you read the criticisms later: many people are running this because it's from GitHub, not because they benchmarked it against alternatives. [![GitHub stars](https://img.shields.io/github/stars/github/spec-kit?style=flat&label=stars&color=e25515)](https://github.com/github/spec-kit)

The core philosophy, from the repo's `spec-driven.md`, is a deliberate "power inversion":

> "Specifications don't serve code -- code serves specifications."

> "The Product Requirements Document (PRD) isn't a guide for implementation; it's the source that generates implementation."

Specs are pitched as "living, executable artifacts" and the single source of truth, where "maintaining software means evolving specifications." That is a strong, sincere SDD claim, and it is worth holding onto when we get to where the claim and the reality diverge.

## How it works: the workflow

Setup is a Python CLI (`specify`, run via `uv`/`uvx` or `pipx`) that initializes a project, drops in the templates, and installs slash-command files for your agent. Prereqs are Python 3.11+, Git, `uv`, and one supported agent. It works offline and behind firewalls, which is a real plus for enterprise teams.

The full workflow runs as slash commands (current `speckit.` namespace):

1. `/speckit.constitution`: establish project principles and governance (`.specify/memory/constitution.md`)
2. `/speckit.specify`: define functional requirements, user stories, the "what" and "why" (no tech details)
3. `/speckit.clarify`: structured refinement of underspecified areas (a quality gate)
4. `/speckit.plan`: technical architecture, stack, constraints (the "how")
5. `/speckit.analyze`: cross-artifact consistency validation (a quality gate)
6. `/speckit.tasks`: break the plan into ordered, testable task units
7. `/speckit.implement`: execute the tasks to produce code

A lean path exists for experiments (specify, plan, tasks, implement), with `clarify`, `checklist`, and `analyze` recommended as gates for production features. Optional commands include `/speckit.checklist` for custom quality checklists and `taskstoissues` to convert tasks into GitHub issues.

Every artifact is plain Markdown committed to your own repo:

```
.specify/
├── memory/constitution.md
├── scripts/bash/ (create-new-feature.sh, setup-plan.sh, ...)
└── templates/ (spec-template.md, plan-template.md, tasks-template.md)

specs/
└── [feature-name]/
    ├── spec.md
    ├── plan.md
    ├── tasks.md
    ├── data-model.md
    ├── research.md
    └── contracts/ (api-spec.json, etc.)
```

The specs are per-feature, dense, human-readable prose documents, not a formal or structured DSL. The mental model Spec Kit promotes is that the agent is a "literal-minded pair programmer" and you steer it through the specs.

## Strengths

Spec Kit gets real things right, and it is worth being honest about them.

- **No vendor or model lock-in.** It supports 30+ agents via per-agent command files plus a generic fallback: Copilot, Claude Code, Gemini CLI, Cursor, Windsurf, Codex CLI, Goose, Kiro, and more. Switch agents, keep your specs.
- **Free, open, transparent.** MIT-licensed; the templates and scripts are inspectable and version-controllable. You bring and pay for your own agent and model, and Spec Kit adds zero markup on top.
- **Real structure instead of vibe coding.** The explicit checkpoints (clarify, analyze, checklist) give teams places to reject or refine before code multiplies. As the reviews put it, this helps "when correctness matters more than quick demo speed."
- **Specs as diffable Markdown in your repo.** They review, diff, and version like code.
- **Distribution and momentum.** GitHub's brand plus the star count give it gravity no other SDD tool currently matches.

## Weaknesses and criticisms

The criticisms cluster around one theme: the process is heavy, and the documents it produces govern the code by convention rather than by enforcement.

The sharpest published critique is Scott Logic's "Putting Spec Kit Through Its Paces: Radical Idea or Reinvented Waterfall?" (November 26, 2025). Their reviewer hit "a sea of markdown documents, long agent run-times and unexpected friction." One plan phase generated over 2,000 lines of markdown, including a 406-line research doc they found duplicative. The line that sticks:

> "Ultimately a lot of time spent reviewing markdown or waiting for the agent to churn out more markdown. I didn't see any qualitative benefit to justify the overhead."

The same reviewer reckoned they were "around ten times faster" with plain iterative prompting than with the full spec pipeline.

That feeds the "reinvented waterfall" worry: a rigid up-front spec, then plan, then tasks sequence can re-introduce exactly the rigidity agile spent two decades escaping.

Community sentiment on Hacker News adds more texture. The commenter *yodon* likes Spec Kit but notes the tutorials are "pretty elementary" and lack real-world cases like "making incremental improvements or refactorings to a huge legacy code base," with no good guidance for mid-implementation spec changes, a gap echoed in open repo discussions about refining specs after plan and tasks already exist. The commenter *ares623* wants to "generate the project multiple times using the same spec" to check how consistent the output really is, a determinism doubt, because the same prose spec does not reliably yield the same code. And *westurner* questions the novelty directly, asking how SDD is "distinct from workflows that include README.md, AGENTS.md or .agents/, and subagents," and how it relates to formal methods.

That last point is the old 5GL and BDD critique resurfacing: the bet that if you only specify precisely enough in natural language, the system will build itself correctly. Natural-language specs are not actually unambiguous, which is why that bet has never fully paid off. Reviews also agree Spec Kit "can feel like overhead when you're experimenting" and is poorly suited "when the scope is tiny and a spec would be longer than the change." And it is not a standalone coding agent; it orchestrates one, so you still need a capable agent and disciplined human review.

## Is it true spec-driven development?

Partially, and the distinction matters. Spec Kit is genuinely spec-first in intent. Its philosophy doc makes the strongest possible claim, and that puts it ahead of tools that merely bolt a planning step onto chat.

In practice, though, it is closer to **spec-first scaffolding than generative SDD**. The specs are prose Markdown, not a formal or executable artifact, so "executable specification" is aspirational: the agent interprets prose, the results are non-deterministic, and no verification loop proves the code conforms to the spec. The spec drives the *first* generation, then drifts: its authority over the code afterward is conventional, not enforced. The "change the spec, regenerate the code" promise is the weakest part in field reports, and iteration and legacy work are where users say it breaks down.

## Who should use it

Spec Kit is a strong fit if you are a developer or team using AI agents who wants a repeatable, structured workflow and you value being able to switch agents freely. It suits greenfield work, adding features to existing systems, and enterprise environments that need offline or firewalled operation. It is a poor fit for tiny exploratory changes where the spec would be longer than the diff, and you should expect to supply your own discipline at the review checkpoints; skip them and the value collapses.

{{portable_spec_cta headline="One plan phase produced over 2,000 lines of markdown." sub="Volume of spec is not the same as enforcement of spec." body="A gate that blocks is worth more than a document that describes." label="See what enforcement looks like" campaign="github-spec-kit-guide"}}

## How it compares to CodeMySpec

Both Spec Kit and CodeMySpec are BYO-agent and keep specs in your own repo, and both reject pure vibe coding. That shared ground is real; portability is table stakes here, not a CodeMySpec exclusive. The differences are enforcement, spec structure, verification, and vertical focus.

Most SDD tools, Spec Kit included, are spec-first scaffolding: they generate a spec and hand off to a separate agent, and the spec governs by convention. [CodeMySpec](/developers) is a full-lifecycle harness (spec, code, tests, and live verification on one requirement graph) where BDD specs are a mandatory gate, not optional documents.

| Dimension | GitHub Spec Kit | CodeMySpec |
|---|---|---|
| Category | Spec-first scaffolding | Full-lifecycle harness |
| Spec format | Free-form prose Markdown (`spec.md`, `plan.md`, `tasks.md`) | Mandatory BDD scenarios (Spex DSL) + configurable module specs |
| Enforcement | Convention only; specs drive first generation, not gated | Mandatory BDD gate; spec quality is the explicit lever on code quality |
| Verification | None | Live browser QA via Vibium MCP + generated tests |
| Spec authority over time | Drifts after first generation | Durable protocol on a requirement graph |
| Stack | Stack-neutral, language-agnostic | Phoenix/Elixir-native |
| Agent / model | BYO-agent (30+); BYO-model implied | BYO-agent, BYO-model, BYO-keys, no token markup |
| Pricing | Free, MIT | Free (early access) |

The honest contrast comes down to three things. First, **enforcement vs convention**: Spec Kit's specs are documents the agent should follow; CodeMySpec makes BDD specs a gate the work has to pass. Second, **verification**: Spec Kit has none, so you are trusting that prose produced conforming code. CodeMySpec's QA subagent boots the real app, drives a real browser, screenshots, and files issues with severity: unit tests pass, BDD specs pass, then the QA agent clicks the button and finds the bug anyway. Third, **depth vs breadth**: Spec Kit is stack-neutral and broad; CodeMySpec runs deep for Elixir and Phoenix, with contexts, LiveView, Ecto, and OTP as first-class concerns.

Spec Kit's success is the best validation the spec-driven thesis has. CodeMySpec's bet is that the gaps Spec Kit users keep hitting (document overhead, weak iteration, non-deterministic prose specs, no verification) are exactly the gaps an enforced, verified, Phoenix-native harness closes.

## Related Articles

- [What Is a Spec? The Most Overloaded Word in Software](/blog/what-is-a-spec)
- [Spec-Driven Development in 2026: The Complete Guide and Tool Comparison](/blog/spec-driven-development)
- [Spec Kit vs Kiro: Which Spec-Driven Tool in 2026?](/blog/spec-kit-vs-kiro)
- [OpenSpec vs Spec Kit: Lightweight vs Full Toolkit](/blog/openspec-vs-spec-kit)
- [OpenSpec Explained: Repo-Native Spec-Driven Development](/blog/openspec-explained)
- [CodeMySpec](/developers)

## Sources

- GitHub Spec Kit official repo: https://github.com/github/spec-kit
- GitHub Blog launch post (2025-09-02), Den Delimarsky: https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/
- Spec Kit official docs: https://github.github.io/spec-kit/
- Spec Kit philosophy (`spec-driven.md`): https://github.com/github/spec-kit/blob/main/spec-driven.md
- Star history: https://www.star-history.com/github/spec-kit/
- Scott Logic, "Putting Spec Kit Through Its Paces: Radical Idea or Reinvented Waterfall?" (2025-11-26): https://blog.scottlogic.com/2025/11/26/putting-spec-kit-through-its-paces-radical-idea-or-reinvented-waterfall.html
- Hacker News thread (yodon, ares623, OptionOfT): https://news.ycombinator.com/item?id=45577377
- Hacker News thread (westurner): https://news.ycombinator.com/item?id=45154355
- vibecoding.app Spec Kit review (2026-01-26): https://vibecoding.app/blog/spec-kit-review
- Visual Studio Magazine launch coverage (2025-09-16): https://visualstudiomagazine.com/articles/2025/09/16/github-spec-kit-experiment-a-lot-of-questions.aspx
