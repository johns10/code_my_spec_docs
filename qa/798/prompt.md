# QA Story 798: Validation Pipeline Redesign — Stop Response Compactness

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As an engineer using the agent to fix problems, I want the stop hook response to stay small so the agent has enough context window left to write the fix — rather than spending its budget parsing a verbose failure dump full of stacktraces and problems it can't act on this turn.

## Acceptance criteria

- When a stop is blocked and advisory problems also exist, the blocking response enumerates only the blocking set and collapses the advisory set to one summary line per source.
- When a stop is allowed and only advisory problems exist, the response is the empty allow signal — no advisory file paths, messages, or summary lines reach the agent's context through the response body.
- Each blocking problem renders as a single line (file:line — first line of message, truncated to ~200 chars). Multi-line message bodies — stacktraces, assertion left/right dumps, trailing newline noise — are stripped.
- Each source lists at most 10 blocking problems inline. Overflow surfaces as a footer: '... N more <source> problems (use get_issue to inspect)'.
- The full reason string is capped at 4 KB. When blocking problems would exceed the cap, later problems are omitted with a tail footer '... more problems omitted (response size limit)' and the body fits under the cap.
- A single blocking problem with a long message is compacted per criterion 5093 but never triggers the 4 KB overflow footer — one problem always fits.
- An allow response with analysis still running carries at most one line naming the pending sources (e.g. "analysis running: exunit, spex — results apply next stop") — no per-problem detail.

## BDD spec files

- `test/spex/554_validation_pipeline_redesign_stop_response_compactness/criterion_5091_when_a_stop_is_blocked_and_advisory_problems_also_exist_the_blocking_response_enumerates_only_the_spex.exs`
- `test/spex/554_validation_pipeline_redesign_stop_response_compactness/criterion_5092_when_a_stop_is_allowed_and_only_advisory_problems_exist_the_response_is_the_empty_allow_signal_no_spex.exs`
- `test/spex/554_validation_pipeline_redesign_stop_response_compactness/criterion_5093_each_blocking_problem_renders_as_a_single_line_fileline_first_line_of_message_truncated_to_200_spex.exs`
- `test/spex/554_validation_pipeline_redesign_stop_response_compactness/criterion_5094_each_source_lists_at_most_10_blocking_problems_inline_overflow_surfaces_as_a_footer_n_more_source_spex.exs`
- `test/spex/554_validation_pipeline_redesign_stop_response_compactness/criterion_5095_the_full_reason_string_is_capped_at_4_kb_when_blocking_problems_would_exceed_the_cap_later_problems_spex.exs`
- `test/spex/554_validation_pipeline_redesign_stop_response_compactness/criterion_5096_a_single_blocking_problem_with_a_long_message_is_compacted_per_criterion_5093_but_never_triggers_spex.exs`

## Linked component: Validation

This story is implemented by `CodeMySpec.Validation` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/validation_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/validation.spec.md`
- Source: `lib/code_my_spec/validation.ex`

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

Write the brief to `.code_my_spec/qa/798/brief.md` matching this spec exactly.
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