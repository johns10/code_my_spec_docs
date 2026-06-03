# Spec Kit vs Kiro: Which Spec-Driven Tool in 2026?

Both GitHub Spec Kit and AWS Kiro put a specification at the center of AI coding instead of letting the agent free-associate from a chat prompt. That is where the resemblance ends. Spec Kit is an open, MIT-licensed CLI toolkit you bolt onto whatever agent you already use. Kiro is Amazon's integrated, spec-first IDE (and CLI) where the spec, the model, and the billing all live inside the AWS perimeter. If you are searching "spec kit vs kiro," the real decision is not "which one has specs." It is openness and portability versus an integrated, opinionated environment.

I have read deeply on both and run spec-first workflows on real Phoenix apps. Here is the honest comparison.

## The core difference in one paragraph

Spec Kit is a methodology plus scaffolding: a Python CLI (`specify`) drops Markdown templates and slash commands into your repo, and your existing agent (Copilot, Claude Code, Cursor, Gemini CLI, and 30-odd others) drives the constitution -> specify -> plan -> tasks -> implement loop. Nothing is locked; the specs are prose Markdown you commit like code. Kiro inverts that. It is a Code OSS (VS Code-compatible) editor where one prompt generates three structured artifacts (`requirements.md` in EARS notation, `design.md`, and a dependency-sequenced `tasks.md`), and Bedrock-backed agents implement them. The discipline is stronger and more guided, but you cash it in inside Kiro, on AWS credits, with the models AWS offers you.

## Side-by-side comparison

| Dimension | GitHub Spec Kit | Kiro (AWS) |
|---|---|---|
| Maker | GitHub / Microsoft | Amazon Web Services |
| Category | Open spec-first CLI toolkit | Integrated spec-first IDE + CLI |
| Spec format | Prose Markdown (`spec.md`, `plan.md`, `tasks.md`) | EARS requirements + design + tasks (`.kiro/specs/`) |
| Where specs live | Your repo, plain Markdown (`specs/`, `.specify/`) | Your repo under `.kiro/`, tied to the Kiro runtime |
| Agent / IDE lock-in | None; ~30 agents, BYO editor | Kiro IDE/CLI; models via Bedrock |
| Pricing | Free, MIT (you pay your own agent/model) | Metered credits ($0/$20/$40/$200), $0.04/credit overage, no rollover |
| Verification | None built in | Agent Hooks can run tests; no live-app proof |
| Maturity | Self-described experiment, [![GitHub stars](https://img.shields.io/github/stars/github/spec-kit?style=flat&label=stars&color=e25515)](https://github.com/github/spec-kit) | AWS GA tiers; named successor to Amazon Q Developer |
| Best for | Multi-agent, free, repo-portable workflows | AWS-native / enterprise shops wanting one integrated tool |

(Pricing moves; re-check before you commit.)

## GitHub Spec Kit: strengths and weaknesses

**Strengths.** Spec Kit's biggest asset is that it does not own you. It is MIT-licensed, agent-agnostic across roughly 30 tools, and your specs are plain Markdown sitting in your own repo, diffable, reviewable, and versionable like any other source. You can switch agents and keep the specs. The structured checkpoints (`/speckit.clarify`, `/speckit.analyze`, `/speckit.checklist`) give teams explicit places to reject or refine before code multiplies, which matters when correctness beats demo speed. And GitHub's distribution is real: with one of the largest communities in the space, it is the default reference point in any SDD conversation.

**Weaknesses.** The recurring complaint is process weight. The Scott Logic review ("Putting Spec Kit Through Its Paces: Radical Idea or Reinvented Waterfall?", November 2025) described "a sea of markdown documents, long agent run-times and unexpected friction," with engineers spending "a significant amount of time... reviewing markdown or waiting for the agent to churn out more markdown, with no qualitative benefit to justify the overhead." Iteration and legacy work are the soft spots. On Hacker News, *yodon* likes Spec Kit but says the tutorials are "pretty elementary" and miss real cases like "making incremental improvements or refactorings to a huge legacy code base." Determinism is the other open question. *ares623* wants to "generate the project multiple times using the same spec" to "see how aligned it really makes things." That doubt is fair: prose specs are interpreted, not executed, so the same spec does not reliably yield the same code, and nothing proves the code conforms to the spec. The spec's authority is conventional, not enforced.

## Kiro: strengths and weaknesses

**Strengths.** Kiro is one of the most genuinely spec-first tools shipping. The spec is the unit of work: it persists as editable repo artifacts rather than a throwaway chat plan, and `tasks.md` keeps requirement-to-task traceability so each task links back to a specific requirement. EARS notation (the Easy Approach to Requirements Syntax, developed by Alistair Mavin's team at Rolls-Royce around 2009) brings a battle-tested, vendor-neutral discipline to AI codegen, forcing testable, unambiguous phrasing like "WHEN a user submits a form with invalid data THE SYSTEM SHALL display validation errors next to the relevant fields." The gated requirements -> design -> tasks flow catches design mistakes before code is written, and the AWS-native scaffolding, GovCloud support, SSO, steering files, and Agent Hooks are real enterprise muscle. AWS has now named Kiro the successor to Amazon Q Developer, so it is the company's consolidated dev-AI bet.

**Weaknesses.** Pricing distrust dominates. The August 2025 split into "vibe requests" and "spec requests" (overage at $0.04 per vibe request, $0.20 per spec request) plus a metering bug that drained limits drew sustained backlash. On Hacker News, *kermatt* wrote: "Clear pricing makes it easy for you to control costs. Vibe pricing makes it easy for the vendor to maximize revenue." *ranie93* added: "Just give me dollar amounts, I feel like I'm paying these companies with vbucks at this point." The current single-credit model is the post-backlash simplification, but per-prompt metering with non-rolling credits remains the structural complaint. The other knock is overhead for small work. Independent comparisons note that for developers "who primarily do small edits and bug fixes, spec overhead isn't worth it," since Kiro writes three docs before touching code. And EARS is requirements-syntax discipline, not executable tests: it standardizes how requirements are phrased, but the acceptance criteria do not run.

## Which should you choose?

**Choose Spec Kit if** you are starting greenfield, want to stay agent-agnostic, and refuse vendor lock-in. It is free, the specs are yours in plain Markdown, and you can run them through Copilot today and Claude Code tomorrow. It is the right call when you already have a coding agent you like and want spec-first structure layered on top, and when you want to avoid any per-prompt billing surface.

**Choose Kiro if** you are an AWS-native or enterprise shop that wants one integrated tool, value a guided gated workflow over assembling your own, and are comfortable inside Bedrock. The EARS rigor and requirement-to-task traceability are genuinely good, the enterprise controls are there, and if you are migrating off Amazon Q Developer it is the sanctioned path. The trade you accept is the credit-metered economics and editor adoption.

The honest summary: Spec Kit trades guidance for freedom, Kiro trades freedom for an integrated, opinionated experience. Pick the constraint you can live with.

## A third option: CodeMySpec

Here is what both tools share, and where both leave a gap. Spec Kit and Kiro are both spec-first, and both can drift. Spec Kit's prose specs drive the first generation but do not durably govern the codebase, because the authority is convention. Kiro's specs are more structured, but EARS phrasing is not an executable contract, and "vibe mode" sits right alongside spec mode as an escape hatch. Critically, neither tool verifies the generated code against the live, running app. Spec Kit has no verification loop at all; Kiro's Hooks can run tests, but unit tests passing is not the same as the button actually working.

[CodeMySpec](/products/code-my-spec) targets exactly that gap. It is a full-lifecycle, specification-driven harness for Phoenix and Elixir, distributed as a Claude Code plugin plus a local MCP server. Three differences matter against these two tools:

- **A mandatory BDD gate.** BDD scenarios (Given/When/Then) are not optional documents the agent should follow. They are required, and they are behavioral contracts, not requirement phrasing. Module specs, reviews, and tests are configurable knobs; the BDD gate is not.
- **Built-in live verification.** A QA subagent boots the real app, drives a real browser, screenshots the result, and files issues with severity. Unit tests pass, BDD specs pass, then the QA agent clicks the button and finds the bug anyway. No spec-first tool in this space does live-app verification.
- **Phoenix-native, and BYO everything.** Phoenix contexts, LiveView, Ecto, and OTP are first-class. Specs are portable as MCP context or context files (CLAUDE.md, .cursorrules, GEMINI.md), so you bring your own agent, your own model, and your own keys with no token markup, the opposite of Kiro's credit metering.

To be fair: portability is not unique to CodeMySpec. Spec Kit is also BYO-agent, and both tools keep specs in your repo. The defensible difference is the combination: a mandatory behavioral gate plus live-app verification plus a full lifecycle on one requirement graph, built deep for one stack. Most SDD tools generate a spec and hand off. CodeMySpec keeps spec, code, tests, and verification in one system. It is early access (free during early access) and Elixir-specific, so it is not the answer if you are on a different stack. But if you are building Phoenix and the drift-and-verification gap is what worries you, it is worth a look.

## Related Articles

- [What Is a Spec? The Most Overloaded Word in Software](/blog/what-is-a-spec)
- [Spec-Driven Development in 2026: The Complete Guide and Tool Comparison](/blog/spec-driven-development)
- [GitHub Spec Kit: How It Works and When to Use It (2026)](/blog/github-spec-kit-guide)
- [Kiro Specs Explained: EARS, Spec Mode, and the Trade-offs](/blog/kiro-specs-explained)
- [CodeMySpec](/products/code-my-spec)

## Sources

- https://github.com/github/spec-kit (official repo): MIT license, `speckit.*` command set, `.specify/` + `specs/` structure, 30+ agent list, experimental framing.
- https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/ (official launch post, 2025-09-02): author Den Delimarsky; "any AI coding agent" positioning, specify/plan/tasks/implement phases.
- https://github.github.io/spec-kit/ (official docs): 30 integrations, enterprise/offline use.
- https://blog.scottlogic.com/2025/11/26/putting-spec-kit-through-its-paces-radical-idea-or-reinvented-waterfall.html (critique): rigidity, "sea of markdown," overhead.
- https://news.ycombinator.com/item?id=45577377 (HN sentiment): yodon (weak on legacy/refactor), ares623 (determinism doubt).
- https://www.star-history.com/github/spec-kit/ (adoption / star history).
- https://vibecoding.app/blog/spec-kit-review (review, 2026-01-26): agent-agnostic, free, versionable; overhead for small scope.
- https://kiro.dev/blog/introducing-kiro/ (launch, 2025-07-14): spec workflow, vibe/spec mode, hooks, MCP.
- https://kiro.dev/docs/specs/ (docs): three-file spec model, three-phase gated workflow, task "waves."
- https://kiro.dev/docs/specs/feature-specs/ (docs): EARS template and example, requirements.md structure.
- https://kiro.dev/pricing/ (pricing): 2026 credits tiers, overage $0.04/credit, models, GovCloud, what consumes credits.
- https://aws.amazon.com/blogs/devops/amazon-q-developer-end-of-support-announcement/ (2026-04-30): Q Developer EOL, Kiro named successor.
- https://www.infoworld.com/article/4042912/aws-blames-bug-for-kiro-pricing-glitch-that-drained-developer-limits.html (2025-09): vibe/spec pricing, metering bug, AWS response.
- https://news.ycombinator.com/item?id=44942600 ("wallet-wrecking tragedy" thread): quoted sentiment (kermatt, ranie93).
- https://www.augmentcode.com/tools/kiro-vs-cursor and https://www.morphllm.com/comparisons/kiro-vs-cursor (Kiro vs Cursor 2026): spec overhead for small edits, AWS-aware scaffolding.
- EARS background: https://reqassist.com/blog/ears-requirements-syntax (Mavin / Rolls-Royce 2009 origin, five requirement types).
