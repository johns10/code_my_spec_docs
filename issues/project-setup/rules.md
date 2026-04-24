# Project Setup — Rules

Story 124: As a developer, I want to bootstrap a Phoenix project with
CodeMySpec tooling so that I can start using agent-driven development.

Persona: A developer with an existing Phoenix project (greenfield or
mid-flight) who has installed the CodeMySpec plugin. They want to turn
their repo into a CodeMySpec-managed project without reading a 13-step
manual. They run `start_task` once and expect the agent to figure out
what's done vs. what needs doing and hand them a single prompt that
drives them to done. Nearby personas: developer running on a fresh
`mix phx.new` output (everything unchecked); developer re-running after
a partial setup (most things checked).

## Rule: Setup is idempotent — re-running never undoes completed work

Each step's `evaluate/2` determines `done`. Already-satisfied steps
render as `- [x]` with no prompt body. Re-invoking `command/2` on a
fully-configured project must yield an all-checked list with no
remaining work.

## Rule: The prompt is self-contained — one agent, one prompt, no back-and-forth

`command/2` inlines every incomplete step's full prompt into a single
checklist. The agent receives one atomic prompt and can complete every
unchecked step without re-querying the harness.

## Rule: Order of step completion is not enforced

The checklist header reads "Complete all unchecked steps below. Order
does not matter." The agent is free to interleave, parallelize, or
reorder step execution. Evaluation is based on final state, not order
of operations.

## Rule: Completion is gated by every step evaluating `{:ok, :valid}`

`evaluate/2` returns `{:ok, :valid}` only when every step in
`@setup_steps` returns `{:ok, :valid}`. Any step returning otherwise
produces `{:ok, :invalid, feedback}` listing the incomplete steps.

## Rule: Progress is visible in the prompt

The prompt header shows `(done/total)`, and completed steps render as
checked (`- [x] **Step Name**`) with no prompt body. A developer or
agent reading the prompt can see at a glance how much of setup is
complete.

## Rule: Step command errors propagate to the caller

If any step's `command/2` returns `{:error, reason}` (or otherwise
fails), `ProjectSetup.command/2` returns `{:error, reason}` to the
caller. No silent fallback to degraded one-line prompts. A step that
cannot produce instructions is a setup failure the caller must see,
not a warning buried in an otherwise-healthy checklist.
