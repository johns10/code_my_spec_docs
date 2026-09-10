# QA Story 829: Local app onboarding guides me from sign-in to my first story

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As a newly-handed-off user, I want the local app to keep guiding me — picking up where the dashboard left off — until I've signed in locally, linked a project, run setup, and created my first story, so I can land in actual work rather than getting lost between the dashboard handoff and a working local workspace.

Today, when the dashboard hands a user off to the local app, the local app drops them on a generic projects list with no indication of what to do next. I want the local app to mirror the dashboard's ladder pattern: a top-level local-install ladder on `/` (auth + linked project), and a per-project ladder on each project's home page (init, project setup, first story). Both ladders share the dashboard's visual style and active-rung logic so the experience reads as one continuous journey.

The five local-side activation milestones — sign-in, project linked, init complete, project setup complete, first story created — also need to fire over the existing `cli:user:<id>` channel so the dashboard's analytics can complete the funnel.

Out of scope: dashboard-side onboarding (covered by story 700), the install panel's internal contract (story 698), what happens after the first story is created.

## Acceptance criteria

- Newly handed-off user sees both local-install rungs
- Authed user with no linked project sees only the linked-project rung as active
- Fully set-up user does not see the local-install ladder
- Project with no stories shows the per-project ladder on its home page
- Project with at least one story shows the standard project home
- Every rung renders with the chamfered shell and step-N eyebrow
- Active rung is the first incomplete in order (per-project ladder)
- Pending first-story rung is non-actionable
- Local app routes the user to the named project's ladder
- Missing or unknown project query param falls back to the projects list
- Each onboarding milestone fires its activation event over the channel
- CliChannel routes received activation events through Analytics

## BDD spec files

- `test/spex/701_local_app_onboarding_guides_me_from_sign_in_to_my_first_story/criterion_6059_newly_handed_off_user_sees_both_local_install_rungs_spex.exs`
- `test/spex/701_local_app_onboarding_guides_me_from_sign_in_to_my_first_story/criterion_6060_authed_user_with_no_linked_project_sees_only_the_linked_project_rung_as_active_spex.exs`
- `test/spex/701_local_app_onboarding_guides_me_from_sign_in_to_my_first_story/criterion_6061_fully_set_up_user_does_not_see_the_local_install_ladder_spex.exs`
- `test/spex/701_local_app_onboarding_guides_me_from_sign_in_to_my_first_story/criterion_6062_project_with_no_stories_shows_the_per_project_ladder_on_its_home_page_spex.exs`
- `test/spex/701_local_app_onboarding_guides_me_from_sign_in_to_my_first_story/criterion_6063_project_with_at_least_one_story_shows_the_standard_project_home_spex.exs`
- `test/spex/701_local_app_onboarding_guides_me_from_sign_in_to_my_first_story/criterion_6064_every_rung_renders_with_the_chamfered_shell_and_step_n_eyebrow_spex.exs`
- `test/spex/701_local_app_onboarding_guides_me_from_sign_in_to_my_first_story/criterion_6065_active_rung_is_the_first_incomplete_in_order_per_project_ladder_spex.exs`
- `test/spex/701_local_app_onboarding_guides_me_from_sign_in_to_my_first_story/criterion_6066_pending_first_story_rung_is_non_actionable_spex.exs`
- `test/spex/701_local_app_onboarding_guides_me_from_sign_in_to_my_first_story/criterion_6067_local_app_routes_the_user_to_the_named_projects_ladder_spex.exs`
- `test/spex/701_local_app_onboarding_guides_me_from_sign_in_to_my_first_story/criterion_6068_missing_or_unknown_project_query_param_falls_back_to_the_projects_list_spex.exs`
- `test/spex/701_local_app_onboarding_guides_me_from_sign_in_to_my_first_story/criterion_6069_each_milestone_fires_its_activation_event_over_the_channel_spex.exs`
- `test/spex/701_local_app_onboarding_guides_me_from_sign_in_to_my_first_story/criterion_6070_clichannel_routes_received_activation_events_through_analytics_spex.exs`

## Linked component: Projects

This story is implemented by `CodeMySpec.Projects` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/projects_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/projects.spec.md`
- Source: `lib/code_my_spec/projects.ex`

## Available scripts

Reference these by path in the brief instead of inlining commands:

- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/exchange_github_token.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/exchange_google_token.sh`
- `/Users/johndavenport/Documents/github/code_my_spec/.claude/worktrees/phx-new-generator/.code_my_spec/qa/scripts/qa_agents.sh`
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

## Read the playbook

Read these via the `read_knowledge` MCP tool:

- `qa_story/workflow.md` — two-phase procedure (brief, test), tool
  rules (`:browser` vs `:api` pipelines), testing approach, and what
  the evaluator does when you stop.
- `qa-tooling.md` — testing tool patterns and selection.
- Tool-specific cheat sheets under `qa-tooling/` (browse with
  `list_knowledge`, then read individual entries).

## Brief format spec

Write the brief to `.code_my_spec/qa/829/brief.md` matching this spec exactly.
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