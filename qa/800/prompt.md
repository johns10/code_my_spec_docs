# QA Story 800: Three Amigos

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As a product manager, I want to run the three amigos process with an agent to develop my bdd specifications

## Acceptance criteria

- Graph surfaces three_amigos_complete for a story without acceptance criteria once upstream gates are satisfied
- add_rule rejects when no persona is linked to the story
- Readiness clears and the story is sealed when it has ≥1 persona, ≥1 rule, every rule has at least one scenario, and no question is left open
- Lightweight persona creation completes Three Amigos and surfaces personas_complete as the next research gap
- Readiness fails with "No rules" when the story has zero rules
- Readiness fails with "No personas" when the story has zero personas linked
- Past 10 rules the gate still passes but emits a non-blocking advisory suggesting the story be split
- Multiple personas can be linked to one story; all count toward the persona-linkage requirement
- Task prompt enumerates the available MCP tools (add_rule, add_scenario, add_question, add_persona, link_persona_to_story) and points the agent at the knowledge MCP
- add_scenario rejects when the rule_statement does not match any existing Rule on the story
- Deleting all acceptance criteria on a completed story flips readiness back to unsatisfied and re-dispatches Three Amigos
- add_question creates a Question record observable through list_questions
- Readiness fails while any question on the story is open, whatever the scenario count
- A resolved question stops blocking readiness; a deferred one does too
- get_story_gherkin renders a populated story as a plain-text Gherkin feature with Rule blocks, Scenario titles, and Given/When/Then bodies in insertion order
- A rule whose failure surface lives at a different layer passes the gate with only a happy-path
- Sealing is refused while any rule is unmet, so a story can never be sealed with an open red card
- Readiness fails when the story has 15 or more rules and the failure detail instructs the PM to slice the story (the hard ceiling). Past 10 rules emits a non-blocking advisory instead.
- The failure detail names the unanswered red cards and points at resolve_question
- A question raised after the story is sealed does not un-seal it — three_amigos_complete reads the seal, not a recomputed check
- A question raised after sealing leaves the story complete
- An unanswered red card refuses the seal

## BDD spec files

- `test/spex/559_three_amigos/criterion_5885_graph_surfaces_three_amigos_complete_for_story_without_ac_spex.exs`
- `test/spex/559_three_amigos/criterion_5886_add_rule_rejects_when_no_persona_linked_spex.exs`
- `test/spex/559_three_amigos/criterion_5887_three_amigos_complete_clears_and_graph_advances_spex.exs`
- `test/spex/559_three_amigos/criterion_5888_lightweight_persona_creation_surfaces_personas_complete_spex.exs`
- `test/spex/559_three_amigos/criterion_5889_readiness_fails_when_no_rules_spex.exs`
- `test/spex/559_three_amigos/criterion_5890_readiness_fails_when_no_personas_spex.exs`
- `test/spex/559_three_amigos/criterion_5891_readiness_fails_when_too_many_rules_spex.exs`
- `test/spex/559_three_amigos/criterion_5892_multiple_personas_can_be_linked_spex.exs`
- `test/spex/559_three_amigos/criterion_5893_task_prompt_enumerates_mcp_tools_and_knowledge_spex.exs`
- `test/spex/559_three_amigos/criterion_5894_add_scenario_rejects_unknown_rule_spex.exs`
- `test/spex/559_three_amigos/criterion_5895_redispatch_after_all_criteria_deleted_spex.exs`
- `test/spex/559_three_amigos/criterion_5896_add_question_creates_question_record_spex.exs`
- `test/spex/559_three_amigos/criterion_5897_readiness_fails_when_more_questions_than_scenarios_spex.exs`
- `test/spex/559_three_amigos/criterion_5898_resolved_questions_do_not_block_readiness_spex.exs`
- `test/spex/559_three_amigos/criterion_5899_get_story_gherkin_renders_feature_spex.exs`
- `test/spex/559_three_amigos/criterion_6544_agent_revises_a_rule_statement_via_update_rule_spex.exs`

## Linked component: AgentTasks

This story is implemented by `CodeMySpec.AgentTasks` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/agent_tasks_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/agent_tasks.spec.md`
- Source: `lib/code_my_spec/agent_tasks.ex`

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

Write the brief to `.code_my_spec/qa/800/brief.md` matching this spec exactly.
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