# QA Story 857: My deployed app talks back to CodeMySpec without a long-lived key

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

Sam's deployed environments authenticate to CodeMySpec with short-lived credentials, placed by setup rather than copied between systems by hand.

## Acceptance criteria

- A captured credential is useless after its window
- Calls keep working across the renewal boundary
- One credential covers content, issues, users and the widget
- Sam never sees the credential he is using
- A refusal says why, so the app knows to renew
- What the environment holds opens none of the five surfaces
- The refresh secret buys a token and nothing else
- A visitor mid-conversation notices no expiry

## BDD spec files

- `test/spex/971_my_deployed_app_talks_back_to_codemyspec_without_a_long-lived_key/criterion_8019_a_captured_credential_is_useless_after_its_window_spex.exs`
- `test/spex/971_my_deployed_app_talks_back_to_codemyspec_without_a_long-lived_key/criterion_8020_calls_keep_working_across_the_renewal_boundary_spex.exs`
- `test/spex/971_my_deployed_app_talks_back_to_codemyspec_without_a_long-lived_key/criterion_8021_one_credential_covers_content_issues_users_and_the_widget_spex.exs`
- `test/spex/971_my_deployed_app_talks_back_to_codemyspec_without_a_long-lived_key/criterion_8022_sam_never_sees_the_credential_he_is_using_spex.exs`
- `test/spex/971_my_deployed_app_talks_back_to_codemyspec_without_a_long-lived_key/criterion_8023_a_refusal_says_why_so_the_app_knows_to_renew_spex.exs`
- `test/spex/971_my_deployed_app_talks_back_to_codemyspec_without_a_long-lived_key/criterion_8045_what_the_environment_holds_opens_none_of_the_five_surfaces_spex.exs`
- `test/spex/971_my_deployed_app_talks_back_to_codemyspec_without_a_long-lived_key/criterion_8046_the_refresh_secret_buys_a_token_and_nothing_else_spex.exs`
- `test/spex/971_my_deployed_app_talks_back_to_codemyspec_without_a_long-lived_key/criterion_8055_a_visitor_mid-conversation_notices_no_expiry_spex.exs`

## Linked component: TokenController

This story is implemented by `CodeMySpecWeb.TokenController` (controller).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec_web/controllers/token_controller_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec_web/token_controller.spec.md`
- Source: `lib/code_my_spec_web/controllers/token_controller.ex`

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

Write the brief to `.code_my_spec/qa/857/brief.md` matching this spec exactly.
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