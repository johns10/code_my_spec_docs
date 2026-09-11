# QA Story 984: I connect a model provider by pasting its API key

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As a solo shipper, I want to connect Anthropic or Z.ai by pasting an API key, so that my agents can run on the model I picked instead of the only one I could connect.

## Acceptance criteria

- Sam connects Z.ai by pasting the key from its console
- Sam pastes a key that Anthropic accepts
- Sam pastes a key with a character missing off the end
- Sam returns to settings and sees that a key is there, not what it is
- Two people on one account run QA on different models
- Sam rotates the Z.ai key after revoking the old one
- Sam disconnects Z.ai while QA is pointed at it
- Sam disconnects the last provider he had
- Sam starts QA and it runs on the cheap model he paid for

## BDD spec files

- `test/spex/1040_i_connect_a_model_provider_by_pasting_its_api_key/criterion_3022_sam_connects_zai_by_pasting_the_key_from_its_console_spex.exs`
- `test/spex/1040_i_connect_a_model_provider_by_pasting_its_api_key/criterion_3023_sam_pastes_a_key_that_anthropic_accepts_spex.exs`
- `test/spex/1040_i_connect_a_model_provider_by_pasting_its_api_key/criterion_3024_sam_pastes_a_key_with_a_character_missing_off_the_end_spex.exs`
- `test/spex/1040_i_connect_a_model_provider_by_pasting_its_api_key/criterion_3025_sam_returns_to_settings_and_sees_that_a_key_is_there_not_what_it_is_spex.exs`
- `test/spex/1040_i_connect_a_model_provider_by_pasting_its_api_key/criterion_3026_two_people_on_one_account_run_qa_on_different_models_spex.exs`
- `test/spex/1040_i_connect_a_model_provider_by_pasting_its_api_key/criterion_3027_sam_rotates_the_zai_key_after_revoking_the_old_one_spex.exs`
- `test/spex/1040_i_connect_a_model_provider_by_pasting_its_api_key/criterion_3028_sam_disconnects_zai_while_qa_is_pointed_at_it_spex.exs`
- `test/spex/1040_i_connect_a_model_provider_by_pasting_its_api_key/criterion_3029_sam_disconnects_the_last_provider_he_had_spex.exs`
- `test/spex/1040_i_connect_a_model_provider_by_pasting_its_api_key/criterion_3030_sam_starts_qa_and_it_runs_on_the_cheap_model_he_paid_for_spex.exs`

## Linked component: Agents

This story is implemented by `CodeMySpecWeb.AccountLive.Agents` (liveview).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec_web/live/account_live/agents_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec_web/account_live/agents.spec.md`
- Source: `lib/code_my_spec_web/live/account_live/agents.ex`

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

## Read the playbook

Read these via the `read_knowledge` MCP tool:

- `qa_story/workflow.md` — two-phase procedure (brief, test), tool
  rules (`:browser` vs `:api` pipelines), testing approach, and what
  the evaluator does when you stop.
- `qa-tooling.md` — testing tool patterns and selection.
- Tool-specific cheat sheets under `qa-tooling/` (browse with
  `list_knowledge`, then read individual entries).

## Brief format spec

Write the brief to `.code_my_spec/qa/984/brief.md` matching this spec exactly.
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