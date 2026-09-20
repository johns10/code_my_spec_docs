# QA Story 1003: A story's code is on the running dev copy before QA tests it

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

A node between bdd_specs_passing and qa_complete, with qa_complete's prerequisite moving to it. Not a deploy: no environments, no health_verified_at, no devops setting. It is the local-machine step — get the work onto the branch the running dev copy sits on, and make sure that copy is serving it. Satisfaction is per story; the action is copy-wide. The gate is a precondition of the task: no problems.

## Acceptance criteria

- QA does not start on a story the running copy has never seen
- QA starts once the code is there
- A copy with a failing spec promotes nothing
- A clean copy promotes everything on it
- A stale analyzer is swept before the gate answers
- Work done on the running copy is already there
- A merge that breaks the target is not a completed promotion
- Problems the target already had do not block the promotion
- The application is serving the promoted code
- The promoting agent resolves its own conflict
- QA is told the copy is behind rather than failing the story
- There is one place work goes
- Uncommitted work is refused before the merge is attempted
- The application is restarted every time, not conditionally
- The preview app is up after a promotion, and is started if it is not
- Promotion returns in seconds
- A slow deployment does not become a slow promotion
- Divergence is refused before anything is merged
- A refusal reads as ordinary, not as a fault
- A failed deployment is not silence

## BDD spec files

- `test/spex/1046_a_storys_code_is_on_the_running_dev_copy_before_qa_tests_it/criterion_3162_qa_does_not_start_on_a_story_the_running_copy_has_never_seen_spex.exs`
- `test/spex/1046_a_storys_code_is_on_the_running_dev_copy_before_qa_tests_it/criterion_3163_qa_starts_once_the_code_is_there_spex.exs`
- `test/spex/1046_a_storys_code_is_on_the_running_dev_copy_before_qa_tests_it/criterion_3164_a_copy_with_a_failing_spec_promotes_nothing_spex.exs`
- `test/spex/1046_a_storys_code_is_on_the_running_dev_copy_before_qa_tests_it/criterion_3165_a_clean_copy_promotes_everything_on_it_spex.exs`
- `test/spex/1046_a_storys_code_is_on_the_running_dev_copy_before_qa_tests_it/criterion_3166_a_stale_analyzer_is_swept_before_the_gate_answers_spex.exs`
- `test/spex/1046_a_storys_code_is_on_the_running_dev_copy_before_qa_tests_it/criterion_3167_work_done_on_the_running_copy_is_already_there_spex.exs`
- `test/spex/1046_a_storys_code_is_on_the_running_dev_copy_before_qa_tests_it/criterion_3168_a_merge_that_breaks_the_target_is_not_a_completed_promotion_spex.exs`
- `test/spex/1046_a_storys_code_is_on_the_running_dev_copy_before_qa_tests_it/criterion_3169_problems_the_target_already_had_do_not_block_the_promotion_spex.exs`
- `test/spex/1046_a_storys_code_is_on_the_running_dev_copy_before_qa_tests_it/criterion_3170_the_application_is_serving_the_promoted_code_spex.exs`
- `test/spex/1046_a_storys_code_is_on_the_running_dev_copy_before_qa_tests_it/criterion_3171_a_conflict_is_aborted_not_left_on_the_shared_checkout_spex.exs`
- `test/spex/1046_a_storys_code_is_on_the_running_dev_copy_before_qa_tests_it/criterion_3172_qa_is_told_the_copy_is_behind_rather_than_failing_the_story_spex.exs`
- `test/spex/1046_a_storys_code_is_on_the_running_dev_copy_before_qa_tests_it/criterion_3173_there_is_one_place_work_goes_spex.exs`
- `test/spex/1046_a_storys_code_is_on_the_running_dev_copy_before_qa_tests_it/criterion_3174_uncommitted_work_is_refused_before_the_merge_is_attempted_spex.exs`
- `test/spex/1046_a_storys_code_is_on_the_running_dev_copy_before_qa_tests_it/criterion_3175_the_application_is_restarted_every_time_not_conditionally_spex.exs`
- `test/spex/1046_a_storys_code_is_on_the_running_dev_copy_before_qa_tests_it/criterion_3176_the_preview_app_is_up_after_a_promotion_and_is_started_if_it_is_not_spex.exs`
- `test/spex/1046_a_storys_code_is_on_the_running_dev_copy_before_qa_tests_it/criterion_3433_promotion_returns_in_seconds_spex.exs`
- `test/spex/1046_a_storys_code_is_on_the_running_dev_copy_before_qa_tests_it/criterion_3434_a_slow_deployment_does_not_become_a_slow_promotion_spex.exs`
- `test/spex/1046_a_storys_code_is_on_the_running_dev_copy_before_qa_tests_it/criterion_3435_divergence_is_refused_before_anything_is_merged_spex.exs`
- `test/spex/1046_a_storys_code_is_on_the_running_dev_copy_before_qa_tests_it/criterion_3436_a_refusal_reads_as_ordinary_not_as_a_fault_spex.exs`

## Linked component: Promotion

This story is implemented by `CodeMySpec.Promotion` (coordination_context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/promotion_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/promotion.spec.md`
- Source: `lib/code_my_spec/promotion.ex`

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

Write the brief to `.code_my_spec/qa/1003/brief.md` matching this spec exactly.
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