# QA Story 801: Persona Research

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As a product manager, I want to run a persona research process with an agent to build a reusable persona library for my product

## Acceptance criteria

- Graph surfaces persona research as the next actionable requirement
- Agent receives the persona research task mid-design
- Unsatisfied requirement resumes on the next turn
- Satisfied requirement releases the next graph node
- Delegate checker surfaces per-artifact detail through the hook
- Agent opens with the intake question bank when the PM has no notes
- Agent narrows its questions to the gaps when the PM supplies partial notes
- Agent refuses to skip the conversation
- Agent runs a web search once PM input is sufficient
- Agent queries the knowledge MCP for reference material
- Agent surfaces contradictory evidence to the PM
- Agent reports a research dead-end instead of inventing content
- Agent pushes back on a one-line persona description
- Agent ends the session rather than produce a thin persona
- Agent demands sources when research corroborates nothing
- Fully-satisfied persona clears the checker
- Missing DB row fails evaluation
- Missing sources.md fails evaluation
- Two personas with different gaps surface together
- Zero personas on the project prompts the agent to start one
- Persona folder contains exactly summary.md and sources.md
- sources.md entries include URL, title, and access date
- Stray file in the persona folder is flagged
- Fully-sectioned summary validates
- Missing required section fails validation
- Optional section is accepted alongside required ones
- Unrecognized section is rejected
- Persona is scoped to its project — not visible from a sibling project in the same account
- Persona from one project is not visible to another project (including across accounts)
- Cross-project link attempt is rejected at the library boundary
- Linking one persona to a story creates one join row
- Linking two personas to one story creates two join rows
- Cross-project link is rejected at link creation
- Linking a persona to a story on a different project is rejected at link creation

## BDD spec files

- `test/spex/560_persona_research/criterion_5125_personas_complete_surfaces_as_next_requirement_spex.exs`
- `test/spex/560_persona_research/criterion_5126_start_task_prompt_references_playbook_and_outputs_spex.exs`
- `test/spex/560_persona_research/criterion_5128_unsatisfied_requirement_resumes_on_next_turn_spex.exs`
- `test/spex/560_persona_research/criterion_5129_satisfied_requirement_releases_graph_node_spex.exs`
- `test/spex/560_persona_research/criterion_5130_delegate_checker_surfaces_per_artifact_detail_spex.exs`
- `test/spex/560_persona_research/criterion_5131_agent_opens_with_intake_question_bank_spex.exs`
- `test/spex/560_persona_research/criterion_5132_agent_narrows_questions_to_gaps_spex.exs`
- `test/spex/560_persona_research/criterion_5133_agent_refuses_to_skip_the_conversation_spex.exs`
- `test/spex/560_persona_research/criterion_5134_agent_runs_web_search_once_input_sufficient_spex.exs`
- `test/spex/560_persona_research/criterion_5135_agent_queries_knowledge_mcp_for_reference_spex.exs`
- `test/spex/560_persona_research/criterion_5136_agent_surfaces_contradictory_evidence_spex.exs`
- `test/spex/560_persona_research/criterion_5137_agent_reports_dead_end_instead_of_inventing_spex.exs`
- `test/spex/560_persona_research/criterion_5138_agent_pushes_back_on_one_line_description_spex.exs`
- `test/spex/560_persona_research/criterion_5139_agent_ends_session_rather_than_produce_thin_spex.exs`
- `test/spex/560_persona_research/criterion_5140_agent_demands_sources_when_research_corroborates_nothing_spex.exs`
- `test/spex/560_persona_research/criterion_5141_fully_satisfied_persona_advances_the_graph_spex.exs`
- `test/spex/560_persona_research/criterion_5142_missing_db_row_fails_evaluation_spex.exs`
- `test/spex/560_persona_research/criterion_5143_missing_sources_md_surfaces_in_stop_hook_feedback_spex.exs`
- `test/spex/560_persona_research/criterion_5144_two_personas_with_different_gaps_surface_together_spex.exs`
- `test/spex/560_persona_research/criterion_5145_zero_personas_prompts_agent_to_start_one_spex.exs`
- `test/spex/560_persona_research/criterion_5146_persona_folder_contains_exactly_two_files_spex.exs`
- `test/spex/560_persona_research/criterion_5147_sources_md_entries_include_url_title_date_spex.exs`
- `test/spex/560_persona_research/criterion_5149_fully_sectioned_summary_validates_spex.exs`
- `test/spex/560_persona_research/criterion_5150_missing_evidence_section_surfaces_in_feedback_spex.exs`
- `test/spex/560_persona_research/criterion_5151_optional_section_accepted_alongside_required_spex.exs`
- `test/spex/560_persona_research/criterion_5152_unrecognized_section_rejected_spex.exs`
- `test/spex/560_persona_research/criterion_5153_persona_scoped_to_its_project_spex.exs`
- `test/spex/560_persona_research/criterion_5154_persona_not_visible_from_a_different_project_spex.exs`
- `test/spex/560_persona_research/criterion_5155_cross_project_link_rejected_at_library_spex.exs`
- `test/spex/560_persona_research/criterion_5156_linking_one_persona_creates_one_join_row_spex.exs`
- `test/spex/560_persona_research/criterion_5157_linking_two_personas_creates_two_rows_spex.exs`
- `test/spex/560_persona_research/criterion_5158_cross_project_link_rejected_at_creation_spex.exs`

## Linked component: Index

This story is implemented by `CodeMySpecWeb.PersonasLive.Index` (module).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec_web/personas_live/index_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec_web/personas_live/index.spec.md`
- Source: `lib/code_my_spec_web/personas_live/index.ex`

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

Write the brief to `.code_my_spec/qa/801/brief.md` matching this spec exactly.
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