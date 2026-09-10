# QA Story 805: Verified third-party integrations

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As a developer bootstrapping a CodeMySpec project with third-party integrations, I want the agent to read my technical decisions, draft an integration spec and a credential-verify script for each external service (OAuth provider, API service), gather credentials from me, and prove the credentials work, so that my project's external connections are verified before code generation depends on them — and a missing or wrong credential surfaces during planning, not at runtime when generated code fails to call out.

## Acceptance criteria

- Bootstrap developer with a Twilio ADR sees a prompt that points at the integrations directory
- Project with no decision records points the agent back at technical_strategy and offers an empty index
- Prompt names the verify-script path and JSON output contract for every integration
- OAuth2 integrations trigger an additional token-exchange script instruction
- Prompt instructs initial pending status and verified-on-success promotion
- No integration specs and no index passes evaluation as the empty-pipeline path
- Specs exist but the index is missing yields needs-work feedback referencing the index path
- A spec without a Verify Script section yields needs-work naming the spec
- Verified spec plus index passes evaluation
- Spec missing the verified status yields needs-work naming the spec
- Bare project produces a minimal prompt without optional sections
- Re-runner project's prompt surfaces existing specs and index for update guidance

## BDD spec files

- `test/spex/597_verified_third-party_integrations/criterion_5277_bootstrap_developer_with_a_twilio_adr_sees_a_prompt_that_points_at_the_integrations_directory_spex.exs`
- `test/spex/597_verified_third-party_integrations/criterion_5278_project_with_no_decision_records_points_the_agent_back_at_technical_strategy_and_offers_an_empty_spex.exs`
- `test/spex/597_verified_third-party_integrations/criterion_5279_prompt_names_the_verify-script_path_and_json_output_contract_for_every_integration_spex.exs`
- `test/spex/597_verified_third-party_integrations/criterion_5280_oauth2_integrations_trigger_an_additional_token-exchange_script_instruction_spex.exs`
- `test/spex/597_verified_third-party_integrations/criterion_5281_prompt_instructs_initial_pending_status_and_verified-on-success_promotion_spex.exs`
- `test/spex/597_verified_third-party_integrations/criterion_5282_no_integration_specs_and_no_index_passes_evaluation_as_the_empty-pipeline_path_spex.exs`
- `test/spex/597_verified_third-party_integrations/criterion_5283_specs_exist_but_the_index_is_missing_yields_needs-work_feedback_referencing_the_index_path_spex.exs`
- `test/spex/597_verified_third-party_integrations/criterion_5284_a_spec_without_a_verify_script_section_yields_needs-work_naming_the_spec_spex.exs`
- `test/spex/597_verified_third-party_integrations/criterion_5285_verified_spec_plus_index_passes_evaluation_spex.exs`
- `test/spex/597_verified_third-party_integrations/criterion_5286_spec_missing_the_verified_status_yields_needs-work_naming_the_spec_spex.exs`
- `test/spex/597_verified_third-party_integrations/criterion_5287_bare_project_produces_a_minimal_prompt_without_optional_sections_spex.exs`
- `test/spex/597_verified_third-party_integrations/criterion_5288_re-runner_projects_prompt_surfaces_existing_specs_and_index_for_update_guidance_spex.exs`

## Linked component: AgentTasks

This story is implemented by `CodeMySpec.AgentTasks` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/agent_tasks_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/agent_tasks.spec.md`
- Source: `lib/code_my_spec/agent_tasks.ex`

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

Write the brief to `.code_my_spec/qa/805/brief.md` matching this spec exactly.
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