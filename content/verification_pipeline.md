# The Part Nobody Talks About: Verifying AI-Generated Code

Every AI coding tool demo ends the same way. The code compiles. The tests pass. Ship it.

Nobody shows you what happens three weeks later when you realize the tests were validating the wrong behavior, the architecture drifted while you weren't looking, and a security vulnerability slipped through because nobody ran static analysis.

AI generates code fast. Verifying it's correct? That's the actual hard problem.

## How Is Verification Different From Testing?

Testing asks: does this function return the expected output?

Verification asks: does this codebase, as a whole, satisfy the requirements it was built against? Are the dependencies clean? Does the design match the spec? Are the security patterns consistent? Did that last change break something three modules away?

Testing is one step. Verification is a pipeline.

## What Does the Verification Pipeline Run After Every AI Task?

When an AI agent finishes a task in CodeMySpec, it doesn't just "submit." A validation hook fires and runs scoped analysis on every component the agent touched:

1. **Compiler** — Does it build? Diagnostics captured as structured problems, not terminal output.
2. **ExUnit** — Do the tests pass? Failures converted to problem records with file paths and line numbers.
3. **Credo** — Static analysis. Code quality violations caught before review.
4. **Sobelow** — Security analysis. Phoenix-specific vulnerability detection.
5. **Spex** — BDD specs. Do the acceptance criteria from your user stories pass as executable tests?
6. **Spec validation** — Does the design document match its required schema? A context_spec needs Functions + Dependencies + Components sections. A liveview spec needs Route + Interactions + Design. Missing a required section? Blocked.
7. **QA validation** — Are QA briefs, results, and journey plans structurally valid?

If any step fails, the agent gets specific feedback about what broke and why. Not "tests failed" — structured problem records with severity, source, file path, line number, category, and component assignment.

The agent doesn't decide whether to address the feedback. It must.

## How Does Dirty Tracking Avoid Validating the Entire Codebase Every Time?

Running seven validation tools across an entire codebase after every change would be slow and wasteful. So we don't.

Every component tracks two timestamps: when its files last changed (`files_changed_at`) and when each tool last analyzed it (`last_analyzed_at`). When the validation hook fires, it asks: which components are dirty for which tools?

If you changed files in the `Billing` context, only `Billing` gets revalidated. The `Accounts` context that hasn't been touched since yesterday? Skipped. Zero wasted cycles.

After analysis completes, timestamps update. The component is clean until its files change again.

This is what makes continuous validation practical. You're not choosing between "validate everything" and "validate nothing." You're validating exactly what changed, every time something changes.

## How Does the Problems System Store and Track All Validation Failures?

Every failure from every tool flows into one place: the Problems context.

```elixir
%Problem{
  severity: :error | :warning | :info,
  source: "compiler" | "exunit" | "credo" | "sobelow" | "spex" | "spec_validation",
  file_path: "lib/my_app/billing/invoice.ex",
  line: 42,
  message: "Billing > create_invoice: expected {:ok, invoice} but got {:error, changeset}",
  category: "spex_failure",
  component_id: "uuid-of-billing-context"
}
```

Test failures, compilation errors, security warnings, BDD spec failures, and document validation errors — all stored as structured data with the same shape. You can query problems by source, severity, component, or file path. You can track which components have problems and which are clean. You can see exactly how many issues exist across your project at any moment.

This matters because it eliminates the "I think the tests were passing" ambiguity. Problems are persisted records, not terminal output that scrolled past. When the requirement system asks "is this component's test requirement satisfied?" it queries the problems table. No interpretation. No judgment calls.

## How Do Hooks Enforce Automatic Validation Without Human Intervention?

The validation pipeline doesn't run because the AI decides to run it. It runs because hooks make it automatic.

Claude Code supports hooks — shell commands that fire on specific events. CodeMySpec uses two:

**SubagentStop** — When a subagent finishes a task:
1. Find dirty components from the agent's file changes
2. Run scoped validation pipeline on those components
3. Assign problems to components
4. Recalculate requirements for components with problems
5. Match the agent's work to its dispatched task
6. Evaluate the task — did it satisfy its requirements?

**Stop** — When the main agent finishes:
Same three-phase process, but evaluates the full session stack instead of matching a single task.

The result is binary: `{:ok, :valid}` or `{:error, feedback}`. Compilation errors and validation failures block. Test failures provide feedback but don't block (you might be mid-implementation). The hook returns this to Claude Code, which either continues or stops.

No human has to remember to run tests. No AI has to decide whether to skip validation. The hook fires. The pipeline runs. Problems are recorded. Requirements are updated. Every time.

## How Do BDD Specs Turn Requirements Into Executable Tests?

Unit tests verify implementation. BDD specs verify requirements.

When you write user stories with acceptance criteria — "Admin can generate new API key from settings page" — those criteria need to become executable tests. Not tests the AI invents based on its interpretation of the code. Tests that trace back to specific acceptance criteria on specific stories.

CodeMySpec generates Spex files — BDD specs using a custom DSL — mapped to individual acceptance criteria:

```
test/spex/api_keys/
  admin_creates_api_key_spex.exs     → Story 42, Criterion 1
  key_displayed_once_spex.exs        → Story 42, Criterion 2
  max_keys_enforced_spex.exs         → Story 42, Criterion 3
```

The `WriteBddSpecs` agent task auto-selects the next story with incomplete spec coverage, generates specs with proper scenarios, and validates that each criterion has at least one scenario.

When specs fail, `FixBddSpecs` reads the structured failures from the Problems system and provides them to the agent as context. The agent knows exactly which scenario failed, on which line, with which error — not just "3 tests failed."

This creates a closed loop: story → criteria → specs → implementation → validation → feedback → fix. Requirements are never just documentation. They're executable assertions that run on every change.

## How Do QA Journeys Verify the Running Application End-to-End?

Unit tests and BDD specs verify components in isolation. QA journeys verify the running application.

The QA system follows a state machine through four phases:

**1. Setup** — `QaSetup` reads your router and architecture, then generates a QA plan (`qa_plan.md`) with app overview, tools registry, and seed strategy. It produces seed scripts (`qa_seeds.exs`) and curl-based test scripts.

**2. Story QA** — For each user story, `QaStory` writes a brief (what to test), executes the plan against the running app, and records results. Issues found become structured issue records automatically.

**3. Journey Planning** — `QaJourneyPlan` designs end-to-end user journeys that cross multiple stories and contexts. A journey might be: register → create API key → use key to authenticate → revoke key → verify revoked key fails.

**4. Journey Execution** — `QaJourneyExecute` runs journeys against the live application using browser automation tools. Results are recorded. Passing journeys can be converted to permanent Wallaby integration tests via `QaJourneyWallaby`.

Each phase has its own requirement checker. The system knows whether journey plans exist, whether they've been executed, whether Wallaby tests have been generated. Progress is tracked through the same requirement system that tracks everything else.

## How Does the Requirement Graph Connect All the Verification Steps?

None of this runs in isolation. The requirement system defines dependencies between validation steps:

A component can't be "implementation complete" until its spec file exists and is valid, its code file exists, its test file exists, tests pass, and BDD specs pass. BDD specs can't be fixed until the component has an implementation. QA journeys can't execute until journey plans exist.

22 requirement checkers, arranged in a dependency graph, tracking progress per component. When the validation pipeline updates problems, requirements recalculate automatically. You always know exactly where every component stands — not because someone updated a tracker, but because the system computed it from actual validation results.

## What Does This Look Like During a Real Implementation Session?

I run multi-hour implementation sessions. The agent works through a task, the hook fires, validation runs, problems update, requirements recalculate. If something breaks, the agent gets specific feedback. If everything passes, the next task begins.

I don't review every line of generated code. I review the verification results. Did the pipeline pass? Are the BDD specs green? Did the QA journey succeed? If yes, the code is correct by the standards I defined in my stories, specs, and architecture.

That's the shift. You stop verifying code and start verifying that your verification system is comprehensive. Define good requirements. Write precise acceptance criteria. Design thorough specs. Then let the pipeline enforce them continuously.

The AI generates code. The pipeline tells you whether it's right. Your job is making sure "right" is well-defined.

## Frequently Asked Questions

**Does the verification pipeline slow down AI code generation?** Dirty tracking ensures only the components whose files actually changed get revalidated. The pipeline does not run across the entire codebase after every change. This scoped approach makes continuous validation practical without meaningfully slowing down the development cycle.

**What happens when the AI agent fails a validation step?** The agent receives structured feedback -- not just "tests failed" but specific problem records with severity, source, file path, line number, and component assignment. Compilation errors and validation failures block progress. The agent must address the feedback before the next task begins.

**How many requirement checkers does CodeMySpec use?** There are 22 requirement checkers arranged in a dependency graph. They track progress per component across the full stack, including compiler health, test results, static analysis, BDD spec coverage, document structure, and QA journey status. When the validation pipeline updates problems, requirements recalculate automatically.

**Can this verification approach work with languages other than Elixir?** The pipeline architecture -- dirty tracking, structured problems, requirement graphs, and hook-based enforcement -- is language-agnostic in concept. The specific tools (ExUnit, Credo, Sobelow) are Elixir-specific, but each could be swapped for equivalents in other ecosystems like ESLint, Jest, or Bandit for their respective languages.

**What is the difference between BDD specs and QA journeys?** BDD specs verify individual acceptance criteria from user stories through API and interface calls in isolation. QA journeys test end-to-end flows across multiple stories and contexts against the live running application, catching seam bugs that only surface when features interact in the real environment.
