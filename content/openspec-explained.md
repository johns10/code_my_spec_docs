# OpenSpec Explained: Repo-Native Spec-Driven Development

OpenSpec is a free, MIT-licensed spec-driven development framework from Fission AI that adds a lightweight spec layer to your repository so you and your AI coding agent agree on what to build before any code is written. Its defining idea is delta tracking: every change to your system is captured as a scoped diff against a source-of-truth spec, which makes it unusually well suited to evolving existing codebases rather than starting from scratch.

I have spent the last year building real Phoenix apps with spec-driven tooling, and OpenSpec is the framework I'd point a skeptical engineer at first, because it asks for almost nothing up front. No API key, no MCP server, no proprietary runtime. You install an npm package, run `openspec init`, and your specs are plain markdown files in your repo. This explainer covers how it works, where it shines, the criticism that comes up over and over, and how it lines up against CodeMySpec, the closest thing it has to a direct comparison.

## What OpenSpec is

OpenSpec is built by [Fission AI](https://github.com/Fission-AI/OpenSpec) and shipped as the npm package `@fission-ai/openspec` (Node 20.19+). It is MIT-licensed and open source. The repo has a large and steadily growing community [![GitHub stars](https://img.shields.io/github/stars/Fission-AI/OpenSpec?style=flat&label=stars&color=e25515)](https://github.com/Fission-AI/OpenSpec), and it is under active iteration: v1.4.1 shipped June 3, 2026, the same day I pulled these facts.

The core promise is portability. OpenSpec is a local file and CLI workflow that layers on top of whatever agent you already run. It does not call an LLM itself; it generates and manages spec files, and your existing agent does the generation. The homepage leads with "No API Keys" and "No MCP," and that is the honest selling point: zero added inference cost, no lock-in, specs you can read in a text editor.

## The workflow: proposal, design, tasks

OpenSpec drives work through slash commands in the `opsx:` namespace. The default core profile is `propose -> explore -> apply -> sync -> archive`.

- **Propose** generates a full change proposal from a single request: the intent and scope (`proposal.md`), a design document (`design.md`), the delta specs, and a task checklist (`tasks.md`).
- **Apply** executes the implementation tasks.
- **Sync** merges the change's delta specs into the main specs.
- **Archive** moves the completed change to `changes/archive/` with a date prefix, and prompts you to sync if the specs aren't merged yet.

An extended profile adds commands like `/opsx:verify` and `/opsx:onboard`. The shape that matters: a single proposal step produces the spec, the design, and the tasks together, and the human approves the scope before code is generated. That approval-before-code gate is real and useful, even though, as we'll see, it is the only gate.

Specs are organized by domain, where a domain is a feature area or bounded context. They live at `openspec/specs/[domain]/spec.md`; think `auth/`, `payments/`, `search/`. Each `spec.md` holds Requirements (behaviors the system must exhibit) plus Scenarios in Given/When/Then format, using RFC 2119 keywords like MUST and SHOULD. The docs are explicit that a spec is "a behavior contract, not an implementation plan."

The directory layout makes the model obvious:

```
openspec/
├── specs/               # source of truth (current behavior)
│   └── [domain]/spec.md
└── changes/             # proposed modifications, one folder each
    ├── [change-name]/
    │   ├── proposal.md
    │   ├── design.md
    │   ├── tasks.md
    │   └── specs/        # DELTA specs
    └── archive/          # completed changes, date-prefixed
```

## The signature feature: spec delta tracking

Delta tracking is what sets OpenSpec apart, and it is worth getting precise about.

When you propose a change, OpenSpec does not restate the entire spec. The change's `specs/` folder contains delta specs that describe only what is changing, marked in three explicit sections:

- **ADDED Requirements**: new behavior, appended to the main spec on archive.
- **MODIFIED Requirements**: changed behavior that replaces the matching requirement in the main spec.
- **REMOVED Requirements**: deprecated behavior, deleted from the main spec.

On archive and sync, those deltas merge into `openspec/specs/`, so your system-level documentation compounds over time instead of being thrown away after each feature.

Two consequences fall out of this design. First, because deltas are scoped to individual requirements, two in-flight changes can edit the same `spec.md` without conflicting, as long as they touch different requirements, a real win for parallel work. Second, the delta enables intent-based code review: a reviewer reads the delta to understand what changed and why, instead of reverse-engineering it from a raw diff.

This is also why OpenSpec positions itself as brownfield-first. The delta markers exist specifically so an agent working in a mature codebase doesn't hallucinate new requirements onto existing behavior. If you are doing 1 to n work, adding and changing features in a system that already exists, this is the framework explicitly built for your situation, and it is the cleanest delta model I have seen in this category.

## Behavior scenarios are optional, and so is verification

OpenSpec uses Given/When/Then scenarios, but they are optional, and nothing enforces them. That is the detail that decides whether this tool fits your situation.

- `openspec validate` (with optional `--strict`) checks structure only: are the required sections present, is the file format valid, do cross-artifact dependencies line up. It will tell you a "Technical Approach" section is missing. It does not check behavioral correctness and does not run tests.
- `/opsx:verify` in the extended profile checks completeness, correctness, and coherence, but the docs are blunt that "Verify won't block archive, but it surfaces issues you might want to address first."
- `archive --no-validate` skips validation entirely.

Net it out: OpenSpec gives you advisory verification and structural validation. It has no mandatory, blocking quality gate, and no behavioral-spec or test enforcement. The Given/When/Then contract is something OpenSpec encourages, not something it requires. You can ship a change with no scenarios at all and the tool will let you.

## Strengths

- **Delta tracking is genuinely good for brownfield work.** Scoped ADDED/MODIFIED/REMOVED changes prevent requirement hallucination and let multiple changes proceed in parallel.
- **Lightweight output.** Independent analysis puts a typical OpenSpec change around 250 lines versus roughly 800 for heavier toolkits, which keeps review overhead low.
- **Compounding documentation.** Merged deltas leave you with a system-level spec that grows with the codebase rather than a pile of stale planning docs.
- **Real no-lock-in portability.** Repo-resident files, 20+ supported agents, no API key, no MCP, no proprietary runtime.
- **Low adoption friction.** It is consistently cited as the easiest SDD framework to start with, and that reputation is deserved.

## The drift criticism

The dominant complaint about OpenSpec is spec drift, and it follows directly from the optional-and-advisory design above. Specs don't self-update during implementation. When the agent diverges from the spec, and it will, you have to resync manually.

The sharpest version comes from a Hacker News practitioner who abandoned sync entirely:

> When you do the sync process, it just keeps drifting and drifting until you have duplication and contradictions across specs.

That same practitioner stopped syncing entirely ("I've stopped doing it entirely and just archive directly after implementation") because, in their words, "maintaining the main specs is not worth it." Archiving directly after implementation discards the living-spec benefit that is the whole point of the delta model. The same thread flags a related problem on large or legacy repos: when a spec changes, "AI needs to find the relevant code to change it. It's pretty easy to miss something in large codebase (especially when there is lots of legacy stuff)."

This is the predictable cost of making synchronization a convention rather than an enforced gate. OpenSpec gives you a strong place to write down intent; keeping that intent true to the code is on you.

## Who should use OpenSpec

Reach for OpenSpec if you are iterating on an existing codebase, you want lightweight repo-resident planning with a documentation trail, and you want to keep complete freedom over which AI agent you use. It is the pragmatic, low-friction default for a team that knows it wants spec-driven development but isn't sure which framework to commit to. The honest caveat from the FAQ holds: it works best for people willing to actively engage with and maintain their specs, because the tool will not maintain them for you.

It is a weaker fit if you need a hard quality gate, enforced behavioral specs, test execution, multi-agent orchestration, or deep knowledge of a specific framework's idioms. OpenSpec is deliberately stack-neutral, which is a strength for reach and a limitation for depth.

## How it compares to CodeMySpec

This is the comparison worth taking seriously, because OpenSpec is the closest thing CodeMySpec has to a peer, and the overlap is real.

Both are repo-resident: specs live in version control, not a proprietary cloud silo. Both are bring-your-own-agent with no lock-in. Neither monetizes inference: OpenSpec requires no API key at all, and CodeMySpec is explicitly BYO-key with no token markup. Both treat the spec as a portable protocol the agent consumes. And both speak in behavioral terms: OpenSpec uses Given/When/Then, so the contrast is not that one has behavior specs and the other doesn't.

The split is enforcement and depth.

| | OpenSpec | CodeMySpec |
|---|---|---|
| Spec format | Structured markdown + optional Given/When/Then + delta tracking | BDD scenarios (Spex) + module specs on a requirement graph |
| Behavior spec | Optional | **Mandatory gate** |
| Quality gate | None (`validate` = structure, `verify` = advisory) | **Mandatory BDD gate** |
| Verification | None | **Live browser QA + generated tests** |
| Stack depth | Stack-neutral, generic | **Phoenix/Elixir-native** |
| Center of gravity | Brownfield, change-led (deltas) | Quality-led, full lifecycle |
| Lock-in | None (20+ agents, no key) | None (any agent, BYO model/keys) |

The first row is the one that matters. OpenSpec asks for a behavior contract; CodeMySpec requires one and won't let work pass without it. In OpenSpec, scenarios are optional, `verify` won't block archive, and `archive --no-validate` bypasses checks entirely. CodeMySpec enforces behavioral specs as a non-negotiable gate, with module specs, reviews, and tests as configurable knobs on top. Said plainly: OpenSpec lets you skip the behavior spec; CodeMySpec won't.

The second difference is verification. OpenSpec's spec is a compounding documentation trail whose accuracy depends on manual sync, which is exactly the drift practitioners self-report. CodeMySpec treats the spec as a contract the code must satisfy, then goes further: its QA subagent boots the real app, drives a real browser, screenshots the result, and files issues with severity. Unit tests pass, BDD specs pass, then the QA agent clicks the button and finds the bug anyway. That live-app verification has no equivalent in OpenSpec.

The third is depth. OpenSpec is stack-neutral by design, which buys it reach across 20+ agents and every language. CodeMySpec trades that breadth for depth in one ecosystem: it is [Phoenix and Elixir-native](/products/code-my-spec), generating specs that understand contexts, LiveView, Ecto, and OTP.

The fair framing: OpenSpec gives you an optional behavior contract and a manual living changelog that works across any stack. CodeMySpec makes the behavior spec a mandatory gate, adds live verification, and goes framework-native in Phoenix. If you want maximum reach with minimum friction, OpenSpec is excellent. If you want the spec enforced and the result verified, that is a different tool.

## Related Articles

- [What Is a Spec? The Most Overloaded Word in Software](/blog/what-is-a-spec)
- [Spec-Driven Development in 2026: The Complete Guide and Tool Comparison](/blog/spec-driven-development)
- [CodeMySpec vs OpenSpec: Enforced Specs vs Living Docs](/blog/codemyspec-vs-openspec)
- [OpenSpec vs Spec Kit: Lightweight vs Full Toolkit](/blog/openspec-vs-spec-kit)
- [GitHub Spec Kit: How It Works and When to Use It](/blog/github-spec-kit-guide)
- [CodeMySpec](/products/code-my-spec)

## Sources

- OpenSpec repo (README, license, stars, npm, opsx workflow, directory structure, v1.4.1, brownfield framing): https://github.com/Fission-AI/OpenSpec
- OpenSpec concepts (specs by domain, behavior-contract definition, Requirements + Given/When/Then + RFC 2119, delta spec mechanics): https://github.com/Fission-AI/OpenSpec/blob/main/docs/concepts.md
- OpenSpec workflows (propose/explore/apply/sync/archive, `/opsx:verify` "won't block archive," scenarios optional): https://github.com/Fission-AI/OpenSpec/blob/main/docs/workflows.md
- OpenSpec CLI (validate = structural only, `--strict`, `archive --no-validate`, no API key): https://github.com/Fission-AI/OpenSpec/blob/main/docs/cli.md
- OpenSpec supported tools (20+ assistants, Skills + Commands model): https://github.com/Fission-AI/OpenSpec/blob/main/docs/supported-tools.md
- OpenSpec homepage (lightweight, brownfield-first, "No API Keys," "No MCP"): https://openspec.dev/
- Intent-driven.dev analysis (spec-anchored alignment, lighter output, "true SDD" assessment): https://intent-driven.dev/knowledge/openspec/
- Augment Code SDD roundup (ranking, ~250 vs ~800 lines, drift, no multi-agent, no enterprise): https://www.augmentcode.com/tools/best-spec-driven-development-tools
- DEV (Spec Kit vs BMAD vs OpenSpec): https://dev.to/willtorber/spec-kit-vs-bmad-vs-openspec-choosing-an-sdd-framework-in-2026-d3j
- Hacker News practitioner sentiment (drift quote, large/legacy alignment gap): https://news.ycombinator.com/item?id=47994433
- MarkTechPost SDD landscape: https://www.marktechpost.com/2026/05/08/9-best-ai-tools-for-spec-driven-development-in-2026-kiro-bmad-gsd-and-more-compare/
