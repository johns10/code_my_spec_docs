# QA Story 958: Each device onboards itself and I can see what is running where

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As an engineer, I want each device to onboard itself when it comes online and to see all my devices, so that I know what is running where.

## Acceptance criteria

- A new machine appears without anyone registering it
- The machine is told who it is, and remembers
- Restarting a machine does not create a second one
- A machine claiming somebody else's identity does not get it
- My laptop and my cloud box are told apart
- Two checkouts at the same path on different machines are told apart
- A machine that did not say what it is does not read as a laptop
- A checkout with no machine is not claimed to be anything in particular
- Starting the harness is what onboards the machine
- A second checkout on the same machine does not make a second machine
- Destroying a machine leaves its checkouts behind, with no machine
- A machine that is online says so even when nothing is running on it
- A shared dev box onboards without belonging to anyone

## BDD spec files

- `test/spex/1020_each_device_onboards_itself_and_i_can_see_what_is_running_where/criterion_2838_a_new_machine_appears_without_anyone_registering_it_spex.exs`
- `test/spex/1020_each_device_onboards_itself_and_i_can_see_what_is_running_where/criterion_2839_the_machine_is_told_who_it_is_and_remembers_spex.exs`
- `test/spex/1020_each_device_onboards_itself_and_i_can_see_what_is_running_where/criterion_2840_restarting_a_machine_does_not_create_a_second_one_spex.exs`
- `test/spex/1020_each_device_onboards_itself_and_i_can_see_what_is_running_where/criterion_2841_a_machine_claiming_somebody_elses_identity_does_not_get_it_spex.exs`
- `test/spex/1020_each_device_onboards_itself_and_i_can_see_what_is_running_where/criterion_2842_my_laptop_and_my_cloud_box_are_told_apart_spex.exs`
- `test/spex/1020_each_device_onboards_itself_and_i_can_see_what_is_running_where/criterion_2843_two_checkouts_at_the_same_path_on_different_machines_are_told_apart_spex.exs`
- `test/spex/1020_each_device_onboards_itself_and_i_can_see_what_is_running_where/criterion_2844_a_machine_that_did_not_say_what_it_is_does_not_read_as_a_laptop_spex.exs`
- `test/spex/1020_each_device_onboards_itself_and_i_can_see_what_is_running_where/criterion_2845_a_checkout_with_no_machine_is_not_claimed_to_be_anything_in_particular_spex.exs`
- `test/spex/1020_each_device_onboards_itself_and_i_can_see_what_is_running_where/criterion_2846_starting_the_harness_is_what_onboards_the_machine_spex.exs`
- `test/spex/1020_each_device_onboards_itself_and_i_can_see_what_is_running_where/criterion_2847_a_second_checkout_on_the_same_machine_does_not_make_a_second_machine_spex.exs`
- `test/spex/1020_each_device_onboards_itself_and_i_can_see_what_is_running_where/criterion_2848_destroying_a_machine_leaves_its_checkouts_behind_with_no_machine_spex.exs`
- `test/spex/1020_each_device_onboards_itself_and_i_can_see_what_is_running_where/criterion_2849_a_machine_that_is_online_says_so_even_when_nothing_is_running_on_it_spex.exs`
- `test/spex/1020_each_device_onboards_itself_and_i_can_see_what_is_running_where/criterion_2858_a_shared_dev_box_onboards_without_belonging_to_anyone_spex.exs`

## Linked component: Index

This story is implemented by `CodeMySpecWeb.DeviceLive.Index` (liveview).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec_web/live/device_live/index_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec_web/device_live/index.spec.md`
- Source: `lib/code_my_spec_web/live/device_live/index.ex`

## Available scripts

Reference these by path in the brief instead of inlining commands:

- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/announce_device.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/exchange_github_token.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/exchange_google_token.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/qa_agents.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/qa_code_mode.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/qa_spine.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/stripe_get_subs.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/verify_github.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/verify_google.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/cro/.code_my_spec/qa/scripts/verify_resend.sh`

## Required reading: QA plan

Read `.code_my_spec/qa/plan.md` first. It contains the App Overview, Tools
Registry, auth strategy, and Seed Strategy you need before writing the
brief. The plan is produced and maintained by the `qa_setup` task; if
it's missing or incomplete, the evaluator will tell you to run that
task first.

## Repros that consume themselves

Before reusing a concrete input from an earlier attempt's brief, ask whether
running it *changed* what a second run would measure. Anything the system
remembers — a question it has answered, a decision it recorded, a name it has
already taken — is spent once it has been used.

The failure this prevents is the expensive kind: a system that correctly
declines to re-answer a settled question looks exactly like one that failed
to escalate it, and a re-test then reports a working fix as broken.

Where an input is consumable, choose a fresh one and say in the brief which
you used, so the next pass knows what is spent. Where you inherit a repro
from a previous attempt, check it is still unused before trusting the
result.

## If your tools stop answering, say so before you stop

The dev server and the harness both restart under you without warning. The
box is shared, several sessions ship fixes to it, and a plain deploy takes
the harness serving every checkout on the machine with it. You will see
`:econnrefused`, `:harness_not_connected`, or "No session_id and no agent id
on this call".

None of that is your story failing. Retry — the session's enrichment comes
back within a call or two once the harness rejoins — and carry on.

What matters is the case where you cannot carry on. Submit what you have
with the interruption named as the reason, rather than going quiet. Nobody
can tell a subagent that died from one that is mid-browser-check: both
produce no brief, no attempt and no notification. A pass that ended at
05:22 was reported as "still running" for three hours on exactly that
evidence (733ac788).

An interruption is also a finding about the QA loop, so file it.

## Read the playbook

Read these via the `read_knowledge` MCP tool:

- `qa_story/workflow.md` — two-phase procedure (brief, test), tool
  rules (`:browser` vs `:api` pipelines), testing approach, and what
  the evaluator does when you stop.
- `qa-tooling.md` — testing tool patterns and selection.
- Tool-specific cheat sheets under `qa-tooling/` (browse with
  `list_knowledge`, then read individual entries).

## Brief format spec

Write the brief to `.code_my_spec/qa/958/brief.md` matching this spec exactly.
The evaluator validates the brief structure on stop.

# Qa Story Brief

Per-story QA testing brief. Written by the QA planner after reading the story's prompt file and the QA plan. Gives the tester exact instructions — tool, auth, seeds, what to test.

## Required Sections

### Tool

Format:
- Use H2 heading
- Single line: tool name (web, curl, or script path)

Content:
- Which tool to use for this story's testing
- `web` for LiveView pages, `curl` or script path for controller/API routes


### Auth

Format:
- Use H2 heading
- Exact commands or instructions the tester copies verbatim

Content:
- Login URL, credentials, headers — whatever the tool needs
- Reference auth scripts from the QA plan if applicable
- Tester should not need to figure out auth on their own


### Seeds

Format:
- Use H2 heading
- Exact commands to run

Content:
- Seed script references (`mix run priv/repo/qa_seeds.exs`)
- Any story-specific seed commands beyond the base seeds
- Entity IDs or values the tester will need


### What To Test

Format:
- Use H2 heading
- Bullet list of specific test scenarios

Content:
- Specific URLs to visit
- Interactions to perform (click, fill form, submit)
- Expected outcomes (what the tester should see)
- Map to acceptance criteria from the story


### Result Path

Format:
- Use H2 heading
- Single line: file path

Content:
- Where the tester writes the result document


## Optional Sections

### Setup Notes

Format:
- Use H2 heading
- Free-form paragraphs

Content:
- Additional context, prerequisites, known issues



## Findings and done signal

Every finding you uncover during execution gets filed via
`mcp__plugin_codemyspec_local__create_issue` **as you find it** — not
written into a markdown file. Capture the title, severity, scope, and a
short description; the call returns an issue id. Hold those ids.

When you finish the session, call
`mcp__plugin_codemyspec_local__submit_qa_result` with the structured
scenarios payload **and** every issue id you filed:

    mcp__plugin_codemyspec_local__submit_qa_result(
      task_id: <task_id>,
      status: "pass" | "partial" | "fail",
      scenarios: [%{name: "...", status: "pass|partial|fail", observation: "..."}, ...],
      issue_ids: [<every id returned from create_issue>]
    )

Discipline:

- **`status: "pass"`** with `issue_ids: []` is fine.
- **`status: "partial"` or `"fail"`** with `issue_ids: []` is **rejected
  by the tool**. A failure with no filed issue is a finding that just
  disappeared when your session ended — there's nowhere else for it to
  live. File the issues first, then submit.
- The bare `submit_qa_result` (without the `mcp__plugin_codemyspec_local__`
  prefix) does NOT resolve — use the fully-qualified name.
- Attribution follows automatically: on submit, every `scope: app` issue
  you listed is attached to this story, and `story_issues_resolved` holds
  the story's release until they're fixed. `framework`, `qa` and `docs`
  findings are about the tooling rather than the story, so they queue at
  the project level instead. If an issue belongs to a *different* story,
  pass that `story_id` on the `create_issue` call — an explicit
  attribution is never overwritten.
- Don't write findings into a result.md file. The harness doesn't read it.
  Screenshots and other evidence still belong on disk, but the canonical
  record is the DB attempt + linked issues.