# QA Story 1021: A cached graph is never served after its inputs have moved

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As an engineer, I want a cached graph to be refused the moment any input it was computed from has changed, so that no agent is ever handed a verdict about work that has already moved on.

## Acceptance criteria

- A heartbeat changes nothing anyone can see

Given a working copy has reported its state and the requirements graph shows that answer
When the working copy reports in again with nothing about it changed but the time
Then the requirements graph shows the same answer
And no agent is woken
- A field that only sometimes matters still invalidates when it matters
- A QA attempt lands and the graph hears about it
- A second identical failure is taken at face value
- One story's attempt moves that story and leaves the others

Given two stories each have requirements showing on the requirements graph
When a QA attempt is recorded against the first story
Then the first story's requirements reflect that attempt
And the second story's requirements are unchanged
- Files changed out of band are caught by hashing
- An event for work on another working copy does not disturb mine
- A heartbeat wakes nobody

Given a coding agent is running and idle on a working copy
When that working copy reports in on its timer with nothing changed
Then the coding agent is not woken
And the requirements graph shows the same answer as before the report
- A commit count changing is a change; a report time is not
- A story being released moves the graph
- A criterion being added moves the graph
- An issue being filed moves the graph
- A deploy being recorded moves the graph
- A persona being linked moves the graph
- A spec file appearing moves the graph
- An implementation file appearing moves the graph
- A spex file appearing moves the graph
- A file nothing classifies moves nothing

## BDD spec files

- `test/spex/1063_a_cached_graph_is_never_served_after_its_inputs_have_moved/criterion_3231_a_heartbeat_changes_nothing_anyone_can_see_spex.exs`
- `test/spex/1063_a_cached_graph_is_never_served_after_its_inputs_have_moved/criterion_3232_a_field_that_only_sometimes_matters_still_invalidates_when_it_matters_spex.exs`
- `test/spex/1063_a_cached_graph_is_never_served_after_its_inputs_have_moved/criterion_3235_a_qa_attempt_lands_and_the_graph_hears_about_it_spex.exs`
- `test/spex/1063_a_cached_graph_is_never_served_after_its_inputs_have_moved/criterion_3236_a_second_identical_failure_is_taken_at_face_value_spex.exs`
- `test/spex/1063_a_cached_graph_is_never_served_after_its_inputs_have_moved/criterion_3237_one_storys_attempt_moves_that_story_and_leaves_the_others_spex.exs`
- `test/spex/1063_a_cached_graph_is_never_served_after_its_inputs_have_moved/criterion_3238_files_changed_out_of_band_are_caught_by_hashing_spex.exs`
- `test/spex/1063_a_cached_graph_is_never_served_after_its_inputs_have_moved/criterion_3240_an_event_for_work_on_another_working_copy_does_not_disturb_mine_spex.exs`
- `test/spex/1063_a_cached_graph_is_never_served_after_its_inputs_have_moved/criterion_3241_a_heartbeat_wakes_nobody_spex.exs`
- `test/spex/1063_a_cached_graph_is_never_served_after_its_inputs_have_moved/criterion_3339_a_commit_count_changing_is_a_change_a_report_time_is_not_spex.exs`
- `test/spex/1063_a_cached_graph_is_never_served_after_its_inputs_have_moved/criterion_3340_a_story_being_released_moves_the_graph_spex.exs`
- `test/spex/1063_a_cached_graph_is_never_served_after_its_inputs_have_moved/criterion_3341_a_criterion_being_added_moves_the_graph_spex.exs`
- `test/spex/1063_a_cached_graph_is_never_served_after_its_inputs_have_moved/criterion_3343_an_issue_being_filed_moves_the_graph_spex.exs`
- `test/spex/1063_a_cached_graph_is_never_served_after_its_inputs_have_moved/criterion_3344_a_deploy_being_recorded_moves_the_graph_spex.exs`
- `test/spex/1063_a_cached_graph_is_never_served_after_its_inputs_have_moved/criterion_3345_a_persona_being_linked_moves_the_graph_spex.exs`
- `test/spex/1063_a_cached_graph_is_never_served_after_its_inputs_have_moved/criterion_3346_a_spec_file_appearing_moves_the_graph_spex.exs`
- `test/spex/1063_a_cached_graph_is_never_served_after_its_inputs_have_moved/criterion_3347_an_implementation_file_appearing_moves_the_graph_spex.exs`
- `test/spex/1063_a_cached_graph_is_never_served_after_its_inputs_have_moved/criterion_3348_a_spex_file_appearing_moves_the_graph_spex.exs`
- `test/spex/1063_a_cached_graph_is_never_served_after_its_inputs_have_moved/criterion_3349_a_file_nothing_classifies_moves_nothing_spex.exs`

## Linked component: Requirements

This story is implemented by `CodeMySpec.Requirements` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/requirements_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/requirements.spec.md`
- Source: `lib/code_my_spec/requirements.ex`

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

Write the brief to `.code_my_spec/qa/1021/brief.md` matching this spec exactly.
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