# QA Story 1020: The graph recomputes as observations arrive

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As an engineer, I want the requirement graph to recompute from observations as they arrive - file changes, QA submissions, analysis results - so that its answer reflects the project as it is rather than as it was at the last full pass.

## Acceptance criteria

- Work becomes available while nobody is looking
- An idle agent does not sit through available work
- Many writes at once cost one update
- The change is announced for whoever is listening
- A reader never sees an answer older than the observations in hand
- The collection window does not delay anybody who asks
- A failed recompute is an error somebody has to look at
- An agent's own process decides whether the change was for it
- A change for somebody else costs a query and nothing more
- A recompute that succeeds passes without noise
- A steady stream still gets a pass
- One project's burst does not collapse into another's
- A read with nothing pending does not force a recompute
- Two reads inside one window cost one recompute
- The announcement says only that something moved
- A cached answer and a fresh one describe the same graph

Given a reader with no checkout on its scope has been served the requirements graph
When it reads again and is answered from the cache
Then the cached answer holds the same requirements as the computation it came from

## BDD spec files

- `test/spex/1062_the_graph_recomputes_as_observations_arrive/criterion_3242_work_becomes_available_while_nobody_is_looking_spex.exs`
- `test/spex/1062_the_graph_recomputes_as_observations_arrive/criterion_3243_an_idle_agent_does_not_sit_through_available_work_spex.exs`
- `test/spex/1062_the_graph_recomputes_as_observations_arrive/criterion_3244_many_writes_at_once_cost_one_update_spex.exs`
- `test/spex/1062_the_graph_recomputes_as_observations_arrive/criterion_3245_the_change_is_announced_for_whoever_is_listening_spex.exs`
- `test/spex/1062_the_graph_recomputes_as_observations_arrive/criterion_3246_a_reader_never_sees_an_answer_older_than_the_observations_in_hand_spex.exs`
- `test/spex/1062_the_graph_recomputes_as_observations_arrive/criterion_3247_the_collection_window_does_not_delay_anybody_who_asks_spex.exs`
- `test/spex/1062_the_graph_recomputes_as_observations_arrive/criterion_3249_an_agents_own_process_decides_whether_the_change_was_for_it_spex.exs`
- `test/spex/1062_the_graph_recomputes_as_observations_arrive/criterion_3250_a_change_for_somebody_else_costs_a_query_and_nothing_more_spex.exs`
- `test/spex/1062_the_graph_recomputes_as_observations_arrive/criterion_3303_a_recompute_that_succeeds_passes_without_noise_spex.exs`
- `test/spex/1062_the_graph_recomputes_as_observations_arrive/criterion_3351_a_steady_stream_still_gets_a_pass_spex.exs`
- `test/spex/1062_the_graph_recomputes_as_observations_arrive/criterion_3352_one_projects_burst_does_not_collapse_into_anothers_spex.exs`
- `test/spex/1062_the_graph_recomputes_as_observations_arrive/criterion_3353_a_read_with_nothing_pending_does_not_force_a_recompute_spex.exs`
- `test/spex/1062_the_graph_recomputes_as_observations_arrive/criterion_3354_two_reads_inside_one_window_cost_one_recompute_spex.exs`
- `test/spex/1062_the_graph_recomputes_as_observations_arrive/criterion_3355_the_announcement_says_only_that_something_moved_spex.exs`
- `test/spex/1062_the_graph_recomputes_as_observations_arrive/criterion_3358_a_cached_answer_and_a_fresh_one_describe_the_same_graph_spex.exs`

## Linked component: Requirements

This story is implemented by `CodeMySpec.Requirements` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/requirements_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/requirements.spec.md`
- Source: `lib/code_my_spec/requirements.ex`

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

Write the brief to `.code_my_spec/qa/1020/brief.md` matching this spec exactly.
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