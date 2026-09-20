# QA Story 1008: Harness startup and restart leave the agent working

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As an internal agent, I want my tools, registration and in-flight work to survive a harness start or restart, so that infrastructure lifecycle is not my problem.

## Acceptance criteria

- Tools come back on their own after a harness restart
- An agent stopped and started again has its tools
- Restarting an agent never costs it its tools
- An interrupted agent is told what happened to its work
- An idle agent is told the harness restarted
- An agent refuses to start without its tools
- An agent with working tools starts normally
- A stopped agent leaves no MCP session behind, so the next one to start under its name is not refused
- An agent is asked for on a machine serving no tools
- A restart collides with the agent it just stopped
- An agent is restarted part-way through a turn
- The discarded turn leaves nothing claiming to be in flight

## BDD spec files

- `test/spex/1051_harness_startup_and_restart_leave_the_agent_working/criterion_3204_tools_come_back_on_their_own_after_a_harness_restart_spex.exs`
- `test/spex/1051_harness_startup_and_restart_leave_the_agent_working/criterion_3205_an_agent_stopped_and_started_again_has_its_tools_spex.exs`
- `test/spex/1051_harness_startup_and_restart_leave_the_agent_working/criterion_3206_restarting_an_agent_never_costs_it_its_tools_spex.exs`
- `test/spex/1051_harness_startup_and_restart_leave_the_agent_working/criterion_3209_an_interrupted_agent_is_told_what_happened_to_its_work_spex.exs`
- `test/spex/1051_harness_startup_and_restart_leave_the_agent_working/criterion_3210_an_idle_agent_is_told_the_harness_restarted_spex.exs`
- `test/spex/1051_harness_startup_and_restart_leave_the_agent_working/criterion_3211_an_agent_refuses_to_start_without_its_tools_spex.exs`
- `test/spex/1051_harness_startup_and_restart_leave_the_agent_working/criterion_3296_an_agent_with_working_tools_starts_normally_spex.exs`
- `test/spex/1051_harness_startup_and_restart_leave_the_agent_working/criterion_3449_a_stopped_agent_leaves_no_mcp_session_behind_so_the_next_one_to_start_under_its_name_is_not_refused_spex.exs`
- `test/spex/1051_harness_startup_and_restart_leave_the_agent_working/criterion_3462_an_agent_is_asked_for_on_a_machine_serving_no_tools_spex.exs`
- `test/spex/1051_harness_startup_and_restart_leave_the_agent_working/criterion_3467_a_restart_collides_with_the_agent_it_just_stopped_spex.exs`
- `test/spex/1051_harness_startup_and_restart_leave_the_agent_working/criterion_3468_an_agent_is_restarted_part-way_through_a_turn_spex.exs`
- `test/spex/1051_harness_startup_and_restart_leave_the_agent_working/criterion_3469_the_discarded_turn_leaves_nothing_claiming_to_be_in_flight_spex.exs`

## Linked component: Agents

This story is implemented by `CodeMySpec.Agents` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/agents_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/agents.spec.md`
- Source: `lib/code_my_spec/agents.ex`

## Available scripts

Reference these by path in the brief instead of inlining commands:

- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/announce_device.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/exchange_github_token.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/exchange_google_token.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/qa_agents.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/qa_code_mode.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/qa_spine.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/stripe_get_subs.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/verify_github.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/verify_google.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/verify_resend.sh`

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

Write the brief to `.code_my_spec/qa/1008/brief.md` matching this spec exactly.
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