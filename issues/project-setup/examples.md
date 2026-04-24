# Project Setup — Examples

Scenario titles grouped by rule. Given/When/Then bodies live in
`specs.md` when written.

## Rule: Setup is idempotent — re-running never undoes completed work

- Developer runs `command` on a fully-configured project and every step renders as checked
- Developer runs `command`, completes one incomplete step, re-runs `command`, and the newly-completed step is now checked

(No failure path — a step that incorrectly reports itself done is
that step's own responsibility, covered in its own story.)

## Rule: The prompt is self-contained — one agent, one prompt, no back-and-forth

- Developer runs `command` with multiple incomplete steps and receives a single prompt containing every unchecked step's full instructions inline

(No failure path at this layer — a step that can't generate a prompt
is covered by the error-propagation rule.)

## Rule: Order of step completion is not enforced

- Developer completes steps in reverse declaration order and `evaluate` returns `{:ok, :valid}`
- Developer interleaves completion of multiple steps and `evaluate` returns `{:ok, :valid}` once all are done

(No failure path — evaluation is purely state-based; there is no
ordering invariant to violate.)

## Rule: Completion is gated by every step evaluating `{:ok, :valid}`

- Every step evaluates valid and `evaluate` returns `{:ok, :valid}`
- One step is incomplete and `evaluate` returns `{:ok, :invalid, feedback}` naming that step
- Multiple steps are incomplete and the feedback lists every incomplete step

## Rule: Progress is visible in the prompt

- Three of thirteen steps are done and the prompt header reads `Project Setup (3/13)`
- All steps are done and the prompt header reads `Project Setup (13/13)` with every step rendered as `- [x]` and no prompt bodies
- A completed step renders as `- [x] **Step Name**` with no prompt body beneath it

(No failure path — header/rendering correctness is a formatting
property, not a failure mode with a distinct scenario.)

## Rule: Step command errors propagate to the caller

- Every step's `command/2` succeeds and `ProjectSetup.command` returns `{:ok, prompt}`
- One step's `command/2` returns `{:error, reason}` and `ProjectSetup.command` returns `{:error, reason}` without swallowing the error
