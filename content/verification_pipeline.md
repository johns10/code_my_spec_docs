---
# Metadata for verification_pipeline.md
# This file defines metadata for content that will be synced to the database

# Required fields
slug: verification-pipeline
type: blog  # Options: blog, page, landing
title: "The Part Nobody Talks About: Verifying AI-Generated Code"

# Publishing control
protected: false  # Set to true to require authentication (routes to /private/*)
publish_at: "2026-03-10T00:00:00Z"
expires_at: null  # ISO 8601 datetime or null for never expires

# SEO Metadata
meta_title: "Verifying AI-Generated Code: The QA Pipeline - CodeMySpec"
meta_description: How CodeMySpec verifies AI-generated code with analyzers, structured problems, BDD specs, and end-to-end QA journeys.
og_title: "The Part Nobody Talks About: Verifying AI-Generated Code"
og_description: AI generates code fast. Verifying it's correct is the actual hard problem. Here's how we built a pipeline that does it automatically.
og_image: null  # URL to Open Graph image

# Additional metadata (custom key-value pairs)
metadata:
  template: article  # Options: default, article, tutorial
  author: John Davenport
  category: AI Development
  featured: true

# Tags (optional, list of tag names)
tags:
  - ai
  - testing
  - verification
  - validation-pipeline
  - bdd
  - qa
  - software-architecture
---

# The Part Nobody Talks About: Verifying AI-Generated Code

Every AI coding tool demo ends the same way. The code compiles. The tests pass. Ship it.

Nobody shows you what happens three weeks later when you realize the tests were validating the wrong behavior, the architecture drifted while you weren't looking, and a security vulnerability slipped through because nobody ran static analysis.

AI generates code fast. Verifying it's correct? That's the actual hard problem.

## How Is Verification Different From Testing?

Testing asks: does this function return the expected output?

Verification asks: does this codebase, as a whole, satisfy the requirements it was built against? Are the dependencies clean? Does the design match the spec? Are the security patterns consistent? Did that last change break something three modules away?

Testing is one step. Verification is a pipeline.

## What Does the Verification Pipeline Run on AI-Generated Code?

When an AI agent finishes a turn in CodeMySpec, it doesn't "submit." A stop hook fires, syncs the files the agent touched, and records what it finds. The heavier analyzers run as tracked analysis runs, and each one turns its output into structured problems:

1. **Compiler**: Does it build? Diagnostics captured as structured problems, not terminal output.
2. **ExUnit**: Do the tests pass? Failures converted to problem records with file paths and line numbers.
3. **Credo**: Static analysis. Code quality violations caught before review.
4. **Sobelow**: Security analysis. Phoenix-specific vulnerability detection.
5. **Spex**: BDD specs, run with `mix spex`. Do the acceptance criteria from your user stories pass as executable scenarios?
6. **Document validation**: Do the QA plans, journey plans, and results match their required structure? A malformed document is a problem like any other.

Every finding is a structured problem with severity, source, file path, line number, and category. Not "tests failed."

Where the pipeline bites is the gates. The graph won't mark a story ready for QA until its working copy is clean, every analyzer is clean at the current commit, and the story's own specs are green. Promotion checks the same findings again before work lands on your development branch. The agent doesn't get to decide whether to address them.

This is not theoretical. Running the pipeline against my own books in [Keel](/case-studies/keel) surfaced $227,736 of phantom income across 9,225 transactions, with a database-level constraint making unbalanced transactions impossible to commit.

## How Does the Pipeline Avoid Re-Validating the Whole Codebase Every Time?

Running every analyzer across an entire codebase after every keystroke would be slow and wasteful. So it doesn't.

The stop hook works from the files the agent actually changed in that turn, attributed to the session that edited them. It syncs those files into the component model and runs the fast in-process validators on them. The slow analyzers (compiler, ExUnit, Credo, Sobelow, Spex) run as analysis runs, which can be targeted at the files that moved or run in full. A full run replaces the problems for its source in one transaction, so a fixed problem disappears and a stale one can't linger.

Targeted runs keep feedback quick while an agent works. Full runs are what the gates trust.

## How Does the Problems System Store and Track All Validation Failures?

Every failure from every tool flows into one place: the Problems context.

```elixir
%Problem{
  severity: :error | :warning | :info,
  source: "compiler" | "exunit" | "credo" | "sobelow" | "spex",
  file_path: "lib/my_app/billing/invoice.ex",
  line: 42,
  message: "Billing > create_invoice: expected {:ok, invoice} but got {:error, changeset}",
  category: "spex_failure",
  component_id: "uuid-of-billing-context"
}
```

Test failures, compilation errors, security warnings, and BDD spec failures are all stored as structured data with the same shape. You can query problems by source, severity, component, or file path. You can track which components have problems and which are clean. You can see exactly how many issues exist across your project at any moment.

This matters because it eliminates the "I think the tests were passing" ambiguity. Problems are persisted records, not terminal output that scrolled past. When a gate asks "is this work clean?" it reads the problems table. No interpretation. No judgment calls. Low priority advisory findings (`:info` severity) don't block unless you turn that on in the project configuration.

## How Do Hooks Enforce Automatic Validation Without Human Intervention?

The validation pipeline doesn't run because the AI decides to run it. It runs because hooks make it automatic.

Claude Code supports hooks, which are commands that fire on specific events. The CodeMySpec plugin registers hooks for session start, pre and post tool use, prompt submit, stop, and session end, and forwards each one to the local harness. Two of them carry the weight:

**PostToolUse**: Records which files each agent edited, so a stop can tell an agent's work from someone else's changes.

**Stop**: When an agent finishes a turn:
1. Sync the files it changed
2. Run the in-process validators on them
3. Assign problems to components
4. Match the agent's work to its dispatched task
5. Evaluate the task: did it satisfy its requirements?

If the task isn't satisfied, the hook hands Claude Code the specific reason and the agent keeps going. A stop doesn't wait on slow subprocess analyzers. Findings gate at ready-for-QA and promotion, where they can't be skipped.

No human has to remember to run tests. No AI has to decide whether to skip validation. The hook fires. The pipeline runs. Problems are recorded. Requirements are updated. Every time.

## How Do BDD Specs Turn Requirements Into Executable Tests?

Unit tests verify implementation. BDD specs verify requirements.

When you write user stories with acceptance criteria ("Admin can generate new API key from settings page"), those criteria need to become executable tests. Not tests the AI invents based on its interpretation of the code. Tests that trace back to specific acceptance criteria on specific stories.

CodeMySpec generates Spex files, BDD specs using a custom DSL, mapped to individual acceptance criteria:

```
test/spex/api_keys/
  admin_creates_api_key_spex.exs     → Story 42, Criterion 1
  key_displayed_once_spex.exs        → Story 42, Criterion 2
  max_keys_enforced_spex.exs         → Story 42, Criterion 3
```

The `WriteBddSpecs` agent task works on the next story with incomplete spec coverage, generates specs with proper scenarios, and checks coverage per criterion, so a criterion added later gets its own pass. Specs run with `mix spex`, not `mix test`.

When specs fail, `FixBddSpecs` reads the structured failures from the Problems system and provides them to the agent as context. The agent knows exactly which scenario failed, on which line, with which error, not "3 tests failed."

This creates a closed loop: story → criteria → specs → implementation → validation → feedback → fix. Requirements are never only documentation. They're executable assertions that run on every change.

## How Do QA Journeys Verify the Running Application End-to-End?

Unit tests and BDD specs verify components in isolation. QA verifies the running application.

The QA system follows a sequence through the requirement graph:

**1. Setup**: `QaSetup` reads your router and architecture, then generates a QA plan (`qa_plan.md`) with app overview, tools registry, and seed strategy.

**2. Story QA**: For each user story, `QaStory` writes a brief (what to test), executes the plan against the running app, and records results. Issues found become structured issue records automatically.

**3. Journey Planning**: `QaJourney` designs end-to-end user journeys that cross multiple stories and contexts. A journey might be: register → create API key → use key to authenticate → revoke key → verify revoked key fails.

**4. Journey Execution**: The same task walks the journeys against the live application using browser automation. Results are recorded. Passing journeys are then converted into permanent LiveView tests under `test/journeys/`.

Each phase has its own requirement. The graph knows whether the QA plan exists, whether a journey plan exists, and whether the journey result is recorded. Progress is tracked through the same requirement system that tracks everything else.

## How Does the Requirement Graph Connect All the Verification Steps?

None of this runs in isolation. The requirement system defines dependencies between steps.

At the project level the graph runs personas, stories, technical strategy, code generation, architecture, and the BDD spec boundary, then dispatches work. Per story, the order is: component linked, Three Amigos sealed, BDD specs written, ready for QA, QA complete, promoted, deployed. A story can't be promoted until QA passes. QA journeys can't be planned until QA setup exists and accepted issues are resolved.

The graph computes what's next from actual state. When the analyzers update problems, requirements recalculate. You always know exactly where every story and component stands, not because someone updated a tracker, but because the system computed it from actual validation results.

{{verification_gate_cta headline="Nobody reads six validation stages for fun." sub="They read them because an agent shipped something broken last week." campaign="verification-pipeline"}}

## What Does This Look Like During a Real Implementation Session?

I run multi-hour implementation sessions. The agent works through a task, the hook fires, validation runs, problems update, requirements recalculate. If something breaks, the agent gets specific feedback. If everything passes, the next task begins.

I don't review every line of generated code. I review the verification results. Did the pipeline pass? Are the BDD specs green? Did the QA journey succeed? If yes, the code is correct by the standards I defined in my stories, specs, and architecture.

That's the shift. You stop verifying code and start verifying that your verification system is comprehensive. Define good requirements. Write precise acceptance criteria. Design thorough specs. Then let the pipeline enforce them continuously.

The AI generates code. The pipeline tells you whether it's right. Your job is making sure "right" is well-defined.

## Frequently Asked Questions

**Does the verification pipeline slow down AI code generation?** The stop hook only looks at the files the agent changed, and the slow analyzers run as tracked runs that can be targeted at what moved. The full-codebase runs are what the gates (ready for QA, promotion) trust, so continuous validation doesn't meaningfully slow the development cycle.

**What happens when the AI agent fails a validation step?** The agent receives structured feedback, not "tests failed" but specific problem records with severity, source, file path, line number, and component assignment. The task isn't satisfied until the feedback is addressed, and the same findings gate ready-for-QA and promotion.

**How does CodeMySpec track what's done?** A requirement graph spans the project, each story, and each component. Each node has a check, such as a file existing, BDD specs covering every criterion, or the latest QA attempt passing. When the validation pipeline updates problems, requirements recalculate automatically.

**Can this verification approach work with languages other than Elixir?** The pipeline architecture (scoped runs, structured problems, requirement graphs, and hook-based enforcement) is language-agnostic in concept. The specific tools (ExUnit, Credo, Sobelow) are Elixir-specific, but each could be swapped for equivalents in other ecosystems like ESLint, Jest, or Bandit for their respective languages.

**What is the difference between BDD specs and QA journeys?** BDD specs verify individual acceptance criteria from user stories through API and interface calls in isolation. QA journeys test end-to-end flows across multiple stories and contexts against the live running application, catching seam bugs that only surface when features interact in the real environment.

## Related Articles

- [The Agentic Software Development Process](/blog/agentic-software-development-process)
- [The Verification Gap: Why Agents Ship Broken Code and What to Do About It](/blog/agentic-qa-verification)
- [Agentic QA](/blog/agentic-qa)
- [Testing AI-Generated Code: The Self-Confirming Loop and How to Break It](/blog/agentic-testing)
