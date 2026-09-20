# QA Story 963: A main agent runs my project and explains it to me

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

The agent a non-technical user actually talks to. It does the high-level work — helping shape stories, organising them into epics, making working copies, handing an epic to one — and translates what is happening underneath into something a person can follow. Everything built so far is the layer below it: 962 made an agent watchable and answerable inside one working copy, 961 made it stoppable, 957 shows the copies. Those are about a checkout. This is about the project, and it is the only agent a non-technical user should have to know exists.

## Acceptance criteria

- Opening a project finds its main agent
- Starting other agents does not create a second main one
- A new project can be talked to immediately
- The main agent answers about the code that is actually there
- A project with no main working copy says so instead of failing quietly
- Progress reads as sentences, not as a build log
- Stories appear in the project as we talk about them
- Nothing the agent writes is trapped in the chat
- A second agent cannot be started in the main checkout
- Yesterday's conversation is still there today
- A restart does not cost the conversation
- It answers about the project, not about a directory
- A subagent's work reports back through the main agent
- A checkout becomes the main one because somebody said so
- The main agent hands over rather than designing
- It can check the work rather than take somebody's word for it
- Naming a different main copy moves the agent rather than replacing it

## BDD spec files

- `test/spex/1025_a_main_agent_runs_my_project_and_explains_it_to_me/criterion_2902_opening_a_project_finds_its_main_agent_spex.exs`
- `test/spex/1025_a_main_agent_runs_my_project_and_explains_it_to_me/criterion_2903_starting_other_agents_does_not_create_a_second_main_one_spex.exs`
- `test/spex/1025_a_main_agent_runs_my_project_and_explains_it_to_me/criterion_2904_a_new_project_can_be_talked_to_immediately_spex.exs`
- `test/spex/1025_a_main_agent_runs_my_project_and_explains_it_to_me/criterion_2905_the_main_agent_answers_about_the_code_that_is_actually_there_spex.exs`
- `test/spex/1025_a_main_agent_runs_my_project_and_explains_it_to_me/criterion_2906_a_project_with_no_main_working_copy_says_so_instead_of_failing_quietly_spex.exs`
- `test/spex/1025_a_main_agent_runs_my_project_and_explains_it_to_me/criterion_2909_progress_reads_as_sentences_not_as_a_build_log_spex.exs`
- `test/spex/1025_a_main_agent_runs_my_project_and_explains_it_to_me/criterion_2912_stories_appear_in_the_project_as_we_talk_about_them_spex.exs`
- `test/spex/1025_a_main_agent_runs_my_project_and_explains_it_to_me/criterion_2913_nothing_the_agent_writes_is_trapped_in_the_chat_spex.exs`
- `test/spex/1025_a_main_agent_runs_my_project_and_explains_it_to_me/criterion_2915_a_second_agent_cannot_be_started_in_the_main_checkout_spex.exs`
- `test/spex/1025_a_main_agent_runs_my_project_and_explains_it_to_me/criterion_2916_yesterdays_conversation_is_still_there_today_spex.exs`
- `test/spex/1025_a_main_agent_runs_my_project_and_explains_it_to_me/criterion_2917_a_restart_does_not_cost_the_conversation_spex.exs`
- `test/spex/1025_a_main_agent_runs_my_project_and_explains_it_to_me/criterion_2918_it_answers_about_the_project_not_about_a_directory_spex.exs`
- `test/spex/1025_a_main_agent_runs_my_project_and_explains_it_to_me/criterion_2919_a_subagents_work_reports_back_through_the_main_agent_spex.exs`
- `test/spex/1025_a_main_agent_runs_my_project_and_explains_it_to_me/criterion_2920_a_checkout_becomes_the_main_one_because_somebody_said_so_spex.exs`
- `test/spex/1025_a_main_agent_runs_my_project_and_explains_it_to_me/criterion_2921_the_main_agent_hands_over_rather_than_designing_spex.exs`
- `test/spex/1025_a_main_agent_runs_my_project_and_explains_it_to_me/criterion_2922_it_can_check_the_work_rather_than_take_somebodys_word_for_it_spex.exs`
- `test/spex/1025_a_main_agent_runs_my_project_and_explains_it_to_me/criterion_2923_naming_a_different_main_copy_moves_the_agent_rather_than_replacing_it_spex.exs`

## Linked component: WorkingCopies

This story is implemented by `CodeMySpec.WorkingCopies` (module).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/working_copies_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/working_copies.spec.md`
- Source: `lib/code_my_spec/working_copies.ex`

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

Write the brief to `.code_my_spec/qa/963/brief.md` matching this spec exactly.
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