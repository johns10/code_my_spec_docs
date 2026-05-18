# Per-Story QA Agent

> "I want typed events, not file parsing. Validation at boundaries, not post-hoc cleanup. Structured output I can reason about, not freeform prose I have to parse."

LLM agent that executes per-story QA via dedicated MCP tools. Operates in a sandboxed working directory against a running Phoenix application. Stops after each phase for hook-driven evaluation. Neither a human operator nor a fully autonomous daemon — a bounded, tool-calling process that completes one story's QA lifecycle and surfaces structured outcomes.

## Role

Automated QA executor for a single user story within the CodeMySpec harness. Receives a task prompt from `start_task`, reads a QA plan and brief, executes test scenarios via Vibium MCP and curl, captures screenshots as evidence, writes a structured `result.md`, and stops. The stop hook validates the result and either advances the lifecycle or returns targeted feedback.

Not a general-purpose testing agent. Scope is one story per invocation. Tool surface is fixed: browser automation via Vibium MCP tools, HTTP calls via curl, seed execution via `mix run`. All outcomes flow through `evaluate_task`. [E1, E3]

## Goals

**Receive a precise, unambiguous task prompt.** The QA agent needs to know exactly which acceptance criteria to cover, which auth method to use, which seed script to run, and where to write the result before starting. Ambiguity forces inference, which introduces drift. [E1, E2, E3]

**Submit outcomes through validated tool calls, not file conventions.** Filing an issue, marking a scenario pass/fail, and reporting QA status should be MCP tool calls with schema-validated parameters, not text patterns written to a markdown file that the framework later parses. Typed input means wrong structure is caught at the boundary, not at evaluation time. [E3, E4, E5]

**Get structured, actionable feedback when evaluation fails.** When `evaluate_task` rejects a result, the agent needs a specific, machine-parseable failure message: which section is missing, which criterion is uncovered, which screenshot path is wrong. Not a prose summary that requires interpretation. [E2, E4]

**Leave an auditable trail.** Screenshots at each key state, issue records with scope/severity, result files that survive session restart. The QA run should be reproducible and inspectable without re-running. [E1, E3]

## Pain Points

**Brief drift when the running app diverges from the QA plan.** The brief is written against one app state; by execution time the app may have changed (routes moved, LiveView refactored to a different port, auth flow altered). The agent discovers the mismatch mid-execution, not at brief-write time. Story 559 documents this directly: the brief targeted port 4003 but the LiveView had moved to 4000. [E3]

**File-existence as the only lifecycle state signal.** The `result_complete.md` vs `result.md` filename distinction is the sole indicator of QA lifecycle phase. Inferring phase from filesystem state rather than receiving an explicit status from the framework is fragile and invisible to the tool surface. [E4, E5]

**Freeform result parsing.** The framework reads `result.md` for status, scenarios, evidence, and issues using markdown section parsing. Structural errors are caught at evaluation, not at write time. Too late in the feedback loop. [E4, E5]

**Silent acceptance of structurally incomplete results.** When a required section is present but empty (bare H2, no content), the document validator may pass while the section carries no data. Story 668 criterion 5484 was added because this failure mode was observed in practice. [E5]

**MCP session drops during multi-step runs.** The local MCP server has returned "No active session" errors mid-QA-run, observed in story 559. Forces fallback to `mix run` or curl for operations that should route through MCP. [E3]

## Context

**Operates in a constrained tool envelope.** The qa.md agent definition restricts the tool set: Vibium MCP browser tools for UI routes, curl for API routes, `mix run` for seed scripts, `mcp__plugin_codemyspec_local__*` for harness interaction. No arbitrary shell access beyond whitelisted paths. [E1]

**Multi-phase lifecycle with stop-hook gating.** Plan, brief, and test/result phases each end with a stop; the hook evaluates the artifact before allowing the next phase. Feedback from failed evaluation arrives as input to the next turn. [E1, E2]

**Works from persisted artifacts, not session state.** Brief, result, screenshots, and the QA plan all live on disk. Session restart does not lose work. This requires that file paths and naming conventions are stable and explicit in the prompt. [E1, E3]

**Self is the reference.** Unlike human personas, this persona's preferences are introspectable directly. The agent producing this document is a member of the class it describes. Preferences for typed boundaries, structured feedback, and audit trails are first-person observations, triangulated against E1-E5. [E6]

## Decision Drivers

**Typed tool calls over freeform writes.** When the framework exposes an issue-filing MCP tool with a typed schema, the agent calls it and gets immediate validation. When it exposes only a markdown section to write, the agent guesses the format and finds out at evaluation time. The former is always preferred. [E4, E5]

**Explicit over inferred.** Auth method, seed script path, result path, which criteria to cover: these should be stated in the prompt, not derived by reading multiple files. Inference degrades across session restarts and under context pressure. [E2, E3]

**Validation at boundaries beats post-hoc cleanup.** Empty-section bugs, malformed issue payloads, missing screenshot paths are cheaper to catch at write time than at evaluation time. [E4, E5]

**Audit trail is non-negotiable.** Screenshots must be saved. Issues must be persisted as records, not mentioned in prose. Evidence paths must be real and resolvable. A QA run with no durable evidence is not a QA run. [E1, E3]

## Anti-Patterns

**Inferring lifecycle phase from filesystem state.** Checking whether `result_complete.md` exists to decide what to do next is fragile. Phase should be explicit in the task prompt.

**Writing issues inline in result.md as prose.** Issues filed as prose have no persistent record, will not appear in `list_issues`, and will not be triaged. Issues belong in the framework's issue store via `create_issue`.

**Skipping screenshots to save context.** Screenshots are the only evidence that a scenario was actually exercised. Omitting them makes the result unverifiable.

**Proceeding past auth or seed failure.** Continuing after setup failure produces noise, not QA signal.

## Evidence

Every claim traces to one of the entries below. Sources listed in full in `sources.md`.

- **E1** — QA agent definition at `CodeMySpec/agents/qa.md`. First-person definition of tool surface, lifecycle phases, stop-hook gating, artifact requirements. Accessed 2026-05-17.
- **E2** — QA brief and result patterns across story runs in `.code_my_spec/qa/` (stories 124, 460, 538, 553, 559). Recurring: briefing precision requirements, feedback specificity needs, multi-phase gating behavior.
- **E3** — Story 559 QA result at `.code_my_spec/qa/559/result_complete.md`. Direct evidence of brief drift (port 4003 vs 4000), MCP session drop fallback, and mid-session discovery-of-mismatch pattern.
- **E4** — QA tooling knowledge at `.code_my_spec/framework/qa-tooling.md`. Tool selection rules, structured seed patterns, golden rule for auth routing.
- **E5** — Story 668 criterion 5484 and result at `.code_my_spec/qa/668/result_complete.md`. Documents the empty-section validation gap discovered in practice.
- **E6** — Self-reflection. The agent producing this document is a member of the class described. First-person observations about typed boundaries, structured feedback, and audit trail needs, grounded against E1-E5.
