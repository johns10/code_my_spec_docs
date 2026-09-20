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

## Before you conclude anything

Read the composed prompt. Read the ordered tool calls, not the agent's narration of
them — a model will describe a call it never made. And ask whether the agent *could*
have done the right thing with what it was given. If the answer is no, you are not
looking at a prompt problem.
