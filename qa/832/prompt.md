# QA Story 832: Agent bootstraps a project

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As the bootstrap agent (Claude executing initial project setup), I need the bootstrap MCP tools — list_projects, init_project, sync_project, install_claude_md, install_agents_md, install_rules — registered on LocalServer and behaving predictably, so I can link a working directory, populate the requirements graph, and drop scaffolding files without silent failures.

This story is the agent-perspective companion to "Project Setup" (story 124). Story 124 captures human-architect outcomes (step page rendering, command/evaluate flow). This story captures agent-side mechanics: tool-surface registration, idempotent install behavior, scope resolution from the working directory, and prompt-as-contract correctness for the bootstrap phase.

## Acceptance criteria

- First install creates CLAUDE.md with the managed section
- Re-install replaces the managed section but preserves user-written content
- Install writes AGENTS.md when mix.exs is present
- Install errors with a project-root directive when mix.exs is absent
- First install copies every framework rule into .code_my_spec/rules/
- Re-install preserves a user-modified rule file
- Sync against a populated working directory returns a file and component summary
- Unauthenticated sync skips remote issue pull but completes local sync
- Init.command renders done/total progress and inlines only incomplete prompts
- Successful version probe satisfies a prereq sub-step
- Missing prereq tool surfaces install guidance
- Phoenix project shape in cwd satisfies Init.PhoenixProject
- Missing project shape emits relaunch-from-root directive
- OAuth-authenticated scope satisfies Init.Auth
- Unauthenticated init surfaces manual sign-in directive
- Project row with local_path matching cwd satisfies Init.CliConfig
- Unlinked working directory surfaces list_projects→init_project directive

## BDD spec files

- `test/spex/711_agent_bootstraps_a_project/criterion_6239_first_install_creates_claude_md_with_the_managed_section_spex.exs`
- `test/spex/711_agent_bootstraps_a_project/criterion_6240_re_install_replaces_the_managed_section_but_preserves_user_written_content_spex.exs`
- `test/spex/711_agent_bootstraps_a_project/criterion_6241_install_writes_agents_md_when_mix_exs_is_present_spex.exs`
- `test/spex/711_agent_bootstraps_a_project/criterion_6242_install_errors_with_a_project_root_directive_when_mix_exs_is_absent_spex.exs`
- `test/spex/711_agent_bootstraps_a_project/criterion_6243_first_install_copies_every_framework_rule_into_code_my_spec_rules_spex.exs`
- `test/spex/711_agent_bootstraps_a_project/criterion_6244_re_install_preserves_a_user_modified_rule_file_spex.exs`
- `test/spex/711_agent_bootstraps_a_project/criterion_6245_sync_against_a_populated_working_directory_returns_a_file_and_component_summary_spex.exs`
- `test/spex/711_agent_bootstraps_a_project/criterion_6247_init_command_renders_done_total_progress_and_inlines_only_incomplete_prompts_spex.exs`
- `test/spex/711_agent_bootstraps_a_project/criterion_6250_phoenix_project_shape_in_cwd_satisfies_init_phoenix_project_spex.exs`
- `test/spex/711_agent_bootstraps_a_project/criterion_6251_missing_project_shape_emits_relaunch_from_root_directive_spex.exs`
- `test/spex/711_agent_bootstraps_a_project/criterion_6252_oauth_authenticated_scope_satisfies_init_auth_spex.exs`
- `test/spex/711_agent_bootstraps_a_project/criterion_6253_unauthenticated_init_surfaces_manual_sign_in_directive_spex.exs`
- `test/spex/711_agent_bootstraps_a_project/criterion_6254_project_row_with_local_path_matching_cwd_satisfies_init_cli_config_spex.exs`
- `test/spex/711_agent_bootstraps_a_project/criterion_6255_unlinked_working_directory_surfaces_list_projects_init_project_directive_spex.exs`

## Linked component: McpServers

This story is implemented by `CodeMySpec.McpServers` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/mcp_servers_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/mcp_servers.spec.md`
- Source: `lib/code_my_spec/mcp_servers.ex`

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

Write the brief to `.code_my_spec/qa/832/brief.md` matching this spec exactly.
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