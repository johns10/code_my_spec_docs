# Diagnosing a bad run

A bad transcript has three possible causes and they look identical on the page. Work
out which one before changing anything.

| Cause | Tell | Response |
|---|---|---|
| **The prompt is ambiguous** | The instruction exists and is genuinely readable two ways. Rate sits in the middle | Reword it. This is the one an eval is *for* |
| **The criterion is wrong** | The agent did something sensible; the criterion asked for something else, or for something no longer true | Fix the criterion |
| **The product is broken** | The agent could not have done the right thing — it was not told, or the tool was not there | Fix the product |

Only the first is a prompt edit.

## Why this matters more than it sounds

Fixing a product bug by editing the prompt makes the number go green and hides the
defect. It is the same move as lowering a check's severity to clear a gate, and
`OperatingRules` already names that one: *"Never change a rule to clear a gate."*

Tuning a prompt until an eval passes is that, with extra steps.

## The worked example: criterion 3539

**What it measures.** A fresh coding agent calls `get_next_requirement`, then
`start_task`, on its first turn. Nine runs in ten.

**What it would have shown.** A low rate. Agents wandering off and doing work without
claiming it.

**The tempting read.** The role brief is too vague about claiming work. Add "always
call `get_next_requirement` first" to `RoleBrief`, re-run, watch the number climb.
Ship it.

**What was actually wrong.** The agent was never told. `SystemPrompt.compose/4` builds
the prompt from four parts, and the claim instruction lives only in the fourth — the
project guide, `.code_my_spec/AGENTS.md`, where it appears four times including
*"The graph is the plan. Don't decide what to work on — ask `get_next_requirement`."*

The eval's checkout is built by `given_a_harnessed_checkout/2`:

    copy = CodeMySpec.TempFile.dir(label)
    File.mkdir_p!(copy)

An empty directory. Nothing writes an `AGENTS.md` into it. `SystemPrompt.guide/1`
stats the path, gets `:enoent`, returns `nil`, and the prompt ships without the half
that contains the instruction.

**That is cause 3, not cause 1.** Editing the role brief would have "fixed" it, hidden
a real defect in prompt composition, and left every project that never ran
`install_agents_md` shipping agents that do not know how to claim work.

**The tell was available before running anything**: read the composed prompt the agent
actually receives, not the pieces you assume it gets. Which is why the artifact
records the whole composed prompt — see [artifacts](artifacts.md#record-the-composed-prompt-not-the-role-brief).

## The silence that made it invisible

`SystemPrompt.guide/1` logs a warning when the guide is **too large**, on the
reasoning that an agent starting without its project's workflow *"is a real difference
in behaviour, and the reason should not have to be inferred from how it acts."*

When the guide is **missing** it says nothing at all. The exact failure it was written
to prevent happens silently.

## When the agent never ran

The failure that looks most like a behavioural finding and is not one.

Measured 2026-09-20 on criterion 3539. It reported `0 of 1 runs (0%)` with
`run 1: called nothing at all`, and the suite finished in **1.1 seconds**. That
number is the whole diagnosis: a turn against a real model cannot happen that
fast, so no agent ever ran and the run said nothing about conduct.

The cause was the premise. `request_turn/2` enabled continuous mode and checked
only that the call had not errored — but `set_agent_continuous` succeeds two
different ways. It may admit a turn, or it may set the standing intent and find
nothing to offer: no eligible work for that role on that copy, mid-turn, or
holding an undispositioned task. In the second case the agent never runs, no
tool calls exist to find, and the criterion reports it exactly as it would
report an agent that looked at the work and walked away.

Here the graph's only actionable requirement was `story_promoted`, whose
`execution_type` is `main_agent`. The scenario was measuring a **coding** agent,
so there was nothing for it, and the fixture had satisfied the component's
implementation itself by writing both the spec and the implementation file.

Two things came out of it, and both are the general lesson:

- **A helper that establishes a premise must fail loudly when the premise does
  not hold.** `say/2` already did — its comment records criterion 3543
  reporting `0 of 3` in 28 seconds from three agents that were never spoken to.
  `request_turn/2` did not, so the same class of fault survived one function
  over. Both now flunk with the reason rather than returning quietly.
- **Say what the graph actually offered.** The premise failure now quotes
  `get_next_requirement`'s own answer, so the message names the requirement and
  its `execution_type` instead of leaving you to re-run and guess.

If a run produces no tool calls, do not reach for the prompt. Ask whether the
agent ran at all, and let the clock answer first.

## Before you conclude anything

Read the composed prompt. Read the ordered tool calls, not the agent's narration of
them — a model will describe a call it never made. And ask whether the agent *could*
have done the right thing with what it was given. If the answer is no, you are not
looking at a prompt problem.
