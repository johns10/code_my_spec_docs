# QA Story 875: Guided intake takes a visitor from an idea to a running app

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

A visitor describes what they want to build, answers a few questions, and gets a plan back — all before signing up. Signing up turns the plan into an account, a project, and a running workspace.

## Acceptance criteria

- The generator inputs are inferred, not asked
- The plan names its guesses back, and every one of them can be corrected
- A visitor who leaves and returns finds the plan waiting
- A plan does not follow the visitor to a different browser
- An existing customer gets a new project, not a replaced one
- The workspace comes up and the app is running in it
- A workspace that fails to come up says so and the plan survives
- The choice comes after the plan and starts the work
- A cloud copy is a checkout, not a running artifact
- What the visitor first typed is still there at the end
- The project starts with somebody it is for
- A brand new visitor talks to their agent without connecting anything
- A visitor who talks past the budget is told, not dropped
- The sign-up card appears with names already filled in and three ways to continue
- An unconfirmed email sign-up still continues the conversation
- Choosing cloud asks for payment before the shared host provisions anything
- Choosing local never asks for payment
- An anonymous visitor describes an idea and gets a plan back
- Asked about something else, it comes back to the plan
- The interview pays out within four questions
- The conversation is already going when the visitor arrives
- Asking the box for an instance is all it takes
- Nothing the visitor already answered is asked again
- A corrected name is the one that survives signup
- A name someone else already uses is accepted anyway

## BDD spec files

- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_2230_the_plan_names_its_own_guesses_back_to_the_visitor_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_2970_the_choice_comes_after_the_plan_and_starts_the_work_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_2971_a_cloud_copy_is_a_checkout_not_a_running_artifact_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_2974_what_the_visitor_first_typed_is_still_there_at_the_end_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_2977_the_project_starts_with_somebody_it_is_for_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_2978_a_brand_new_visitor_talks_to_their_agent_without_connecting_anything_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_2980_a_visitor_who_talks_past_the_budget_is_told_not_dropped_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_3398_the_sign-up_card_appears_with_names_already_filled_in_and_three_ways_to_continue_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_3399_an_unconfirmed_email_sign-up_still_continues_the_conversation_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_3400_choosing_cloud_asks_for_payment_before_the_shared_host_provisions_anything_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_3401_choosing_local_never_asks_for_payment_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_3402_an_anonymous_visitor_describes_an_idea_and_gets_a_plan_back_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_3403_asked_about_something_else_it_comes_back_to_the_plan_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_3404_the_interview_pays_out_within_four_questions_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_3405_the_conversation_is_already_going_when_the_visitor_arrives_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_3406_asking_the_box_for_an_instance_is_all_it_takes_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_3407_nothing_the_visitor_already_answered_is_asked_again_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_3408_a_corrected_name_is_the_one_that_survives_signup_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_3409_a_name_someone_else_already_uses_is_accepted_anyway_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_8209_an_anonymous_visitor_describes_an_idea_and_gets_a_plan_back_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_8210_the_generator_questions_are_asked_in_operator_language_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_8214_a_visitor_who_leaves_and_returns_finds_the_plan_waiting_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_8215_a_plan_does_not_follow_the_visitor_to_a_different_browser_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_8216_an_existing_customer_gets_a_new_project_not_a_replaced_one_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_8217_the_workspace_comes_up_and_the_app_is_running_in_it_spex.exs`
- `test/spex/990_guided_intake_takes_a_visitor_from_an_idea_to_a_running_app/criterion_8218_a_workspace_that_fails_to_come_up_says_so_and_the_plan_survives_spex.exs`

## Linked component: Plan

This story is implemented by `CodeMySpecWeb.IntakeLive.Plan` (liveview).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec_web/live/intake_live/plan_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec_web/intake_live/plan.spec.md`
- Source: `lib/code_my_spec_web/live/intake_live/plan.ex`

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

Write the brief to `.code_my_spec/qa/875/brief.md` matching this spec exactly.
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