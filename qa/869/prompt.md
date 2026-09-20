# QA Story 869: Spec failures block only stories whose specs have gone green

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As an engineer, I want failing BDD specs to block the agent only on stories whose specs have already passed once, so that I can turn spex enforcement on project-wide without it blocking every story still mid-build.

## Acceptance criteria

- A freshly released story starts with its specs not ready
- A green run on every spec flips the story to specs-ready
- One failing spec leaves the story short of ready
- A stale green run refuses the flip and directs the agent to wait
- A later edit stales the spex run without un-readying the story
- Rewriting a story's BDD specs returns it to not ready
- A failing spec on a specs-ready story blocks the stop
- A failing spec on a mid-build story is advisory, not blocking
- Only the ready story's failure blocks when both kinds are red at once
- A story reaches ready while another story's specs are red
- The agent is handed the specs-passing task rather than QA
- Reaching specs-ready releases QA on the story
- Clearing specs-ready parks a shipped story mid-refactor
- Setting specs-ready by hand puts a story under enforcement without waiting for a run
- A ready story's failure blocks whoever is stopping

## BDD spec files

- `test/spex/983_spec_failures_block_only_stories_whose_specs_have_gone_green/criterion_2408_a_ready_storys_failure_blocks_whoever_is_stopping_spex.exs`
- `test/spex/983_spec_failures_block_only_stories_whose_specs_have_gone_green/criterion_8157_a_freshly_released_story_starts_with_its_specs_not_ready_spex.exs`
- `test/spex/983_spec_failures_block_only_stories_whose_specs_have_gone_green/criterion_8158_a_green_run_on_every_spec_flips_the_story_to_specs-ready_spex.exs`
- `test/spex/983_spec_failures_block_only_stories_whose_specs_have_gone_green/criterion_8159_one_failing_spec_leaves_the_story_short_of_ready_spex.exs`
- `test/spex/983_spec_failures_block_only_stories_whose_specs_have_gone_green/criterion_8160_a_stale_green_run_refuses_the_flip_and_directs_the_agent_to_wait_spex.exs`
- `test/spex/983_spec_failures_block_only_stories_whose_specs_have_gone_green/criterion_8161_a_later_edit_stales_the_spex_run_without_un-readying_the_story_spex.exs`
- `test/spex/983_spec_failures_block_only_stories_whose_specs_have_gone_green/criterion_8162_rewriting_a_storys_bdd_specs_returns_it_to_not_ready_spex.exs`
- `test/spex/983_spec_failures_block_only_stories_whose_specs_have_gone_green/criterion_8163_a_failing_spec_on_a_specs-ready_story_blocks_the_stop_spex.exs`
- `test/spex/983_spec_failures_block_only_stories_whose_specs_have_gone_green/criterion_8164_a_failing_spec_on_a_mid-build_story_is_advisory_not_blocking_spex.exs`
- `test/spex/983_spec_failures_block_only_stories_whose_specs_have_gone_green/criterion_8165_only_the_ready_storys_failure_blocks_when_both_kinds_are_red_at_once_spex.exs`
- `test/spex/983_spec_failures_block_only_stories_whose_specs_have_gone_green/criterion_8166_a_story_reaches_ready_while_another_storys_specs_are_red_spex.exs`
- `test/spex/983_spec_failures_block_only_stories_whose_specs_have_gone_green/criterion_8167_the_agent_is_handed_the_specs-passing_task_rather_than_qa_spex.exs`
- `test/spex/983_spec_failures_block_only_stories_whose_specs_have_gone_green/criterion_8168_reaching_specs-ready_releases_qa_on_the_story_spex.exs`
- `test/spex/983_spec_failures_block_only_stories_whose_specs_have_gone_green/criterion_8169_clearing_specs-ready_parks_a_shipped_story_mid-refactor_spex.exs`
- `test/spex/983_spec_failures_block_only_stories_whose_specs_have_gone_green/criterion_8170_setting_specs-ready_by_hand_puts_a_story_under_enforcement_without_waiting_for_a_run_spex.exs`

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

Write the brief to `.code_my_spec/qa/869/brief.md` matching this spec exactly.
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