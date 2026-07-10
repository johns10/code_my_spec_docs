---
# Metadata for kiro-specs-explained.md

# Required fields
slug: kiro-specs-explained
type: blog
title: "Kiro Specs Explained: EARS, Spec Mode, and the Trade-offs"

# Publishing control
protected: false
publish_at: 2026-06-03T00:00:00Z
expires_at: null

# SEO Metadata
meta_title: "Kiro Specs Explained: EARS, Spec Mode & Trade-offs"
meta_description: "What is Kiro? AWS's spec-first IDE and Q Developer successor. How spec mode, EARS notation, and hooks work, plus the pricing and lock-in trade-offs."
og_title: "Kiro Specs Explained"
og_description: "AWS's spec-driven IDE and CLI: how Kiro's spec workflow, EARS notation, and Agent Hooks work, and the lock-in and pricing trade-offs to know."
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
  - kiro
  - ears
  - aws
---

# Kiro Specs Explained: EARS, Spec Mode, and the Trade-offs

Kiro is Amazon's spec-first agentic IDE and CLI, and as of mid-2026 it's AWS's flagship dev-AI bet. AWS is winding down Amazon Q Developer: new Q signups are blocked starting May 15, 2026, full end of support lands April 30, 2027, and the deprecated Q plugins point users at Kiro as the successor. If you used Q Developer, the migration path is Kiro. So it's worth understanding what Kiro's spec system actually does, where EARS notation comes from, and what you give up to use it.

This is a deep look at the spec system itself, not an IDE-vs-IDE shootout. If you want the head-to-head against CodeMySpec, I cover that separately in [CodeMySpec vs Kiro EARS](/blog/codemyspec-vs-kiro-specs).

## What Kiro Is

Kiro is built by AWS (the launch post lists Nikhil Swaminathan and Deepak Singh) and went to public preview on July 14, 2025. It ships in two well-documented forms: the **Kiro IDE**, a Code OSS / VS Code-compatible editor, and the **Kiro CLI**, the same agent in the terminal. There's also reporting of a background autonomous agent that picks up tasks and opens PRs, but that's less confirmed than the IDE and CLI, so I'm not leaning on it.

The pitch is "the clarity of specs with the flow of vibe coding." The core idea is that a natural-language specification, not a chat prompt, is the unit of work. Models run through Amazon Bedrock (Claude Sonnet and Opus, Amazon Nova, plus open-weight options, with an "Auto" router by default). It supports the Model Context Protocol and is aimed squarely at AWS-native and enterprise shops, with GovCloud support, SSO, and org dashboards.

## The Spec Workflow

Kiro's defining feature is **spec mode**. From a single prompt like "Add a review system for products," it generates three version-controlled documents under `.kiro/specs/<feature-name>/`:

1. **`requirements.md`**: user stories with acceptance criteria written in EARS notation, explicitly covering edge cases. Bug fixes generate a `bugfix.md` instead.
2. **`design.md`**: the technical design, covering data-flow and sequence diagrams, interfaces, database schemas, and API endpoints, derived from analyzing your codebase plus the approved requirements.
3. **`tasks.md`**: discrete implementation tasks, sequenced by dependency and linked back to specific requirements. Kiro groups independent tasks into "waves" for parallel execution.

The flow is gated: Requirements, then Design, then Tasks and execution, with a human approving each phase before the next. There's also an "Analyze Requirements" step to validate requirements before design begins. The value proposition is the standard spec-driven one: you catch design mistakes at the requirements stage instead of after the code is written. The spec persists as editable repo artifacts, not a throwaway chat plan, with requirement-to-task traceability built in. That's more rigorous than "the AI writes a plan and then codes."

## EARS Notation

EARS is the part people search for, so it's worth getting right. EARS stands for **Easy Approach to Requirements Syntax**. Kiro did not invent it. It was developed by Alistair Mavin and a team at Rolls-Royce around 2009 and presented at IEEE RE09, originally to write airworthiness requirements for aircraft engine control. It's a vendor-neutral requirements standard that Kiro adopted.

EARS is a constrained-English template set with five requirement patterns:

| Pattern | Template | Use |
|---|---|---|
| **Ubiquitous** | THE SYSTEM SHALL [action] | Always-on requirements |
| **Event-driven** | WHEN [trigger] THE SYSTEM SHALL [action] | Triggered behavior |
| **State-driven** | WHILE [state] THE SYSTEM SHALL [action] | Behavior during a state |
| **Optional** | WHERE [feature included] THE SYSTEM SHALL [action] | Feature-conditional behavior |
| **Unwanted behavior** | IF [condition] THEN THE SYSTEM SHALL [action] | Error and edge handling |

Kiro's docs foreground the event-driven form. Their canonical example: "WHEN a user submits a form with invalid data THE SYSTEM SHALL display validation errors next to the relevant fields." The point of the constraint is to kill ambiguity. Instead of "handle errors gracefully," you're forced to name the trigger, the system, and the exact required behavior, which makes the requirement testable and traceable.

Be precise about what EARS is and isn't, though. It standardizes how a requirement is phrased. It does not make the acceptance criteria executable on their own. EARS is requirements-syntax discipline, not a behavioral test you can run.

## Steering Files

Specs cover one feature. Kiro's standing project context lives in `.kiro/steering/` as markdown:

- **`product.md`**: the "why," the product intent.
- **`tech.md`**: the stack and constraints.
- **`structure.md`**: file organization, naming, architecture conventions.

You generate these with "Generate Steering Docs," and they persist across features. Steering is Kiro's rules layer; specs are the per-feature work units. The 2026 changelog added global steering and remote MCP support.

## Agent Hooks and Spec Mode vs Vibe Mode

**Agent Hooks** are event-driven automations. They fire on file save, create, or delete, or on a manual trigger, and run an agent in the background to auto-run tests, do a code review, or enforce consistency after a change. This is how Kiro keeps tests and checks attached to the edit loop instead of something you remember to run.

Kiro has two modes. **Spec mode** is the structured three-document workflow, meant for complex features and team collaboration. **Vibe mode** is ad-hoc agentic chat for quick exploration and prototyping with no predefined spec. Kiro positions itself as the overlap of the two. Both modes consume credits, and vibe mode means SDD is a strong default in Kiro, not a hard constraint.

## Strengths

Credit where it's due. Kiro is one of the more legitimately spec-first tools in the field.

- **Genuinely spec-first.** The spec is the unit of work and persists as reviewable repo artifacts, with requirement-to-task traceability built in.
- **EARS brings real discipline.** A battle-tested requirements standard producing testable, unambiguous acceptance criteria is a meaningful upgrade over freeform prompting.
- **Catches mistakes early.** The gated requirements-design-tasks flow surfaces design problems before code is written.
- **AWS-native and enterprise-ready.** GovCloud, SSO, org dashboards, first-class MCP, steering, and hooks.
- **Distribution.** AWS backing plus the Q Developer migration funnel, across IDE and CLI.

## Weaknesses and Criticisms

The criticisms are real, and most of them trace back to pricing.

**Pricing distrust is the dominant complaint.** Kiro went from a free preview to a per-request metering model in late August 2025 that split usage into "vibe requests" and "spec requests" with very different costs (overage ran $0.04 per vibe request and $0.20 per spec request). A metering bug then caused some tasks to inaccurately consume multiple requests and drain limits fast. AWS acknowledged the bug, promised a fix, and offered to reset affected limits (InfoWorld, September 2025).

The community reaction was overwhelmingly negative. From the Hacker News thread titled "AWS pricing for Kiro dev tool dubbed 'a wallet-wrecking tragedy'":

> "Clear pricing makes it easy for you to control costs. Vibe pricing makes it easy for the vendor to maximize revenue." -- kermatt

> "Just give me dollar amounts, I feel like I'm paying these companies with vbucks at this point." -- ranie93

> "I still don't understand why pricing can't be as simple as it was initially." -- mns

The current 2026 model is the post-backlash simplification: a single "credit" unit instead of the vibe-vs-spec split (Free at $0, Pro at $20/mo for 1,000 credits, up to Power at $200/mo for 10,000, overage at $0.04/credit, credits don't roll over). But the structural complaint stands. Every action consumes credits, including spec prompts, refinements, task execution, and hook runs, and per-prompt metering against non-rolling credits still feels opaque next to flat-rate competitors.

That's the part that would keep me out. I want to know what a feature costs before I build it, not after.

**Spec overhead for small work.** Independent comparisons make the point that for developers who mostly do small edits and bug fixes, writing three documents first isn't worth it. The structure that pays off on a big feature is friction on a one-line change.

**Lock-in.** This is the one I'd weigh most heavily. Your specs and steering live in `.kiro/`, your models run through Bedrock, and your billing is AWS credits. Kiro is not BYO-model or BYO-key, so the credit is the markup surface. The spec's value is realized inside Kiro and AWS, not as a portable artifact you can hand to an arbitrary agent. And since the IDE is a VS Code / Code OSS fork, you adopt Kiro's editor too.

## How It Compares to CodeMySpec

I build CodeMySpec, a full-lifecycle, specification-driven AI development harness for Phoenix and Elixir. Kiro and CodeMySpec agree on the premise that better specs beat better models. We diverge on three axes that matter.

**EARS requirement syntax vs BDD behavioral specs.** Kiro's EARS standardizes how a requirement is phrased. CodeMySpec's specs are mandatory BDD scenarios (Given/When/Then) plus configurable module specs, and the BDD specs produce acceptance criteria with generated tests. The difference isn't "Kiro has no specs." It's that EARS is requirement phrasing while BDD is a behavioral contract, and in CodeMySpec the QA step boots the real app and drives a real browser to verify behavior, not only run unit tests. Unit tests pass, BDD specs pass, then the QA agent clicks the button and finds the bug anyway.

**Locked-in IDE vs portable protocol.** Kiro's specs live in `.kiro/` and are realized inside Kiro and Bedrock. CodeMySpec's specs are markdown and its tests are ExUnit, served to any agent through MCP or generated context files (CLAUDE.md, AGENTS.md, .cursorrules, GEMINI.md). The spec is the portable artifact, not a feature of one editor. Portability is table stakes in this category, not a CMS exclusive, but Kiro doesn't offer it.

**Bedrock metering with markup vs BYO-model with no markup.** Kiro routes inference through Bedrock and bills credits. CodeMySpec is bring-your-own-agent, bring-your-own-model, bring-your-own-keys, with no token arbitrage. You pay your model provider directly.

The shorthand: most spec tools, Kiro included, own the spec phase. CodeMySpec runs spec, code, test, and live verification end to end on a requirement graph, built Elixir-first. If you want the full side-by-side, see [CodeMySpec vs Kiro EARS](/blog/codemyspec-vs-kiro-specs), and you can see the harness itself at [CodeMySpec](/products/code-my-spec).

Kiro is a strong choice if you're an AWS-native or enterprise team planning large features and you're comfortable inside AWS billing and tooling. If you want your specs to outlive any one editor, or you work in Elixir and Phoenix, or you want verification that goes past unit tests, the trade-offs cut the other way.

## Related Articles

- [What Is a Spec? The Most Overloaded Word in Software](/blog/what-is-a-spec)
- [Spec-Driven Development in 2026: The Complete Guide and Tool Comparison](/blog/spec-driven-development)
- [CodeMySpec vs Kiro EARS: Two Approaches to Spec-Driven AI Development](/blog/codemyspec-vs-kiro-specs)
- [Spec Kit vs Kiro: Which Spec-Driven Tool in 2026?](/blog/spec-kit-vs-kiro)
- [Kiro vs OpenSpec: Integrated AWS IDE vs Lightweight Spec Tool](/blog/kiro-vs-openspec)
- [CodeMySpec](/products/code-my-spec)

## Sources

- https://kiro.dev/blog/introducing-kiro/ : launch (July 14, 2025), authors, spec workflow, vibe/spec mode, hooks, MCP.
- https://kiro.dev/ : current tagline and positioning.
- https://kiro.dev/docs/specs/ : three-file spec model, gated workflow, spec vs vibe, task waves.
- https://kiro.dev/docs/specs/feature-specs/ : EARS template and example, requirements.md structure, Analyze Requirements.
- https://kiro.dev/pricing/ : 2026 credits tiers, overage, models, GovCloud, what consumes credits.
- https://kiro.dev/docs/steering/ and https://kiro.dev/blog/teaching-kiro-new-tricks-with-agent-steering-and-mcp/ : steering files.
- https://kiro.dev/changelog/remote-mcp-and-global-steering/ : remote MCP and global steering (2026).
- https://aws.amazon.com/blogs/devops/amazon-q-developer-end-of-support-announcement/ : Q Developer EOL, May 15 2026 signup block, Kiro named successor.
- https://www.infoworld.com/article/4042912/aws-blames-bug-for-kiro-pricing-glitch-that-drained-developer-limits.html : Aug 2025 vibe/spec pricing, metering bug, AWS response.
- https://news.ycombinator.com/item?id=44942600 : "wallet-wrecking tragedy" thread and quoted sentiment.
- https://www.augmentcode.com/tools/kiro-vs-cursor and https://www.morphllm.com/comparisons/kiro-vs-cursor : spec overhead for small edits, AWS-aware scaffolding vs speed.
- https://github.com/kirodotdev/Kiro : official repo.
- EARS background: https://reqassist.com/blog/ears-requirements-syntax, https://www.mdpi.com/2079-8954/13/7/567, https://makerneo.com/en/articles/what-is-ears-requirements-syntax-how-to-write-better-ai-prompts.html : Mavin/Rolls-Royce 2009 origin, IEEE RE09, five patterns.
