# QA Story 830: Agent administers their session

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As an agent (main or sub-agent), I want to manage my session — track which sub-agents are running, hand work between them, and recover from stuck states — so I never get blocked on administrative bookkeeping I can't see or fix.

## Acceptance criteria

- Main agent registers a freshly-spawned sub-agent
- Registered sub-agent claims a task via start_task
- Sub-agent stop hook unregisters the sub-agent
- Fresh registration survives within the TTL window
- Registration older than TTL is pruned on next read
- Long-running sub-agent re-registers to keep its slot
- Engineer sees registered sub-agents on the session detail page
- Agent reads the same roster through list_session_subagents
- TTL-expired registration is absent from both surfaces
- Agent assigns an idle sub-agent to an open task
- Agent reassigns a sub-agent from one task to another
- Agent cancels a stuck task to unblock the loop
- assign_subagent for an unregistered agent_id is rejected
- Agent calls tap_out and gets an immediate awaiting-approval response
- Human approves the tap-out and continuous mode clears
- Human rejects the tap-out and continuous mode stays on
- assign_subagent for a TTL-expired registration is rejected the same as unknown

## BDD spec files

- `test/spex/704_agent_administers_their_session/criterion_6086_main_agent_registers_freshly_spawned_subagent_spex.exs`
- `test/spex/704_agent_administers_their_session/criterion_6087_registered_subagent_claims_task_via_start_task_spex.exs`
- `test/spex/704_agent_administers_their_session/criterion_6088_subagent_stop_unregisters_the_subagent_spex.exs`
- `test/spex/704_agent_administers_their_session/criterion_6089_fresh_registration_survives_within_ttl_spex.exs`
- `test/spex/704_agent_administers_their_session/criterion_6090_ttl_expired_registration_is_pruned_spex.exs`
- `test/spex/704_agent_administers_their_session/criterion_6091_long_running_subagent_reregisters_spex.exs`
- `test/spex/704_agent_administers_their_session/criterion_6092_engineer_sees_subagents_on_session_detail_page_spex.exs`
- `test/spex/704_agent_administers_their_session/criterion_6093_agent_reads_roster_via_list_session_subagents_spex.exs`
- `test/spex/704_agent_administers_their_session/criterion_6094_ttl_expired_absent_from_both_surfaces_spex.exs`
- `test/spex/704_agent_administers_their_session/criterion_6095_agent_assigns_idle_subagent_to_open_task_spex.exs`
- `test/spex/704_agent_administers_their_session/criterion_6096_agent_reassigns_subagent_from_one_task_to_another_spex.exs`
- `test/spex/704_agent_administers_their_session/criterion_6097_agent_cancels_stuck_task_to_unblock_loop_spex.exs`
- `test/spex/704_agent_administers_their_session/criterion_6098_assign_subagent_unregistered_agent_id_rejected_spex.exs`
- `test/spex/704_agent_administers_their_session/criterion_6099_agent_calls_tap_out_awaiting_response_spex.exs`
- `test/spex/704_agent_administers_their_session/criterion_6100_human_approves_tap_out_continuous_clears_spex.exs`
- `test/spex/704_agent_administers_their_session/criterion_6101_human_rejects_tap_out_continuous_stays_on_spex.exs`
- `test/spex/704_agent_administers_their_session/criterion_6102_assign_subagent_ttl_expired_rejected_spex.exs`

## Linked component: Sessions

This story is implemented by `CodeMySpec.Sessions` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/sessions_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/sessions.spec.md`
- Source: `lib/code_my_spec/sessions.ex`

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

Write the brief to `.code_my_spec/qa/830/brief.md` matching this spec exactly.
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