# QA Story 825: Always-fresh project documentation search

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As an agent working on a task, I want `semantic_search` to reflect the current state of my project's specs, rules, and knowledge files without me running an embed step first, so the results I rely on are never stale relative to what's on disk.

The file sync pipeline already detects content changes by checksum; embedding the project documentation corpus (knowledge, project_knowledge, spec, rules) should be driven by that pipeline rather than a separate manual MCP tool. Files whose checksum is unchanged are skipped; new and modified files are re-embedded; deleted files have their embeddings dropped.

This obsoletes the `embed_docs` MCP tool — it should be removed once auto-sync is in place.

## Acceptance criteria

- A new project doc file becomes searchable after the next sync
- A modified project doc file's new content replaces the old in search results
- A deleted project doc file is removed from search results after the next sync
- Repeat sync with unchanged files does no embedding work
- The agent's MCP tool list does not expose `embed_docs`
- File sync completes when the embedding pipeline is unavailable
- Bundled framework knowledge is re-embedded after a CodeMySpec upgrade

## BDD spec files

- `test/spex/688_always_fresh_project_documentation_search/criterion_5969_a_new_project_doc_file_becomes_searchable_after_the_next_sync_spex.exs`
- `test/spex/688_always_fresh_project_documentation_search/criterion_5970_a_modified_project_doc_files_new_content_replaces_the_old_in_search_results_spex.exs`
- `test/spex/688_always_fresh_project_documentation_search/criterion_5971_a_deleted_project_doc_file_is_removed_from_search_results_after_the_next_sync_spex.exs`
- `test/spex/688_always_fresh_project_documentation_search/criterion_5972_repeat_sync_with_unchanged_files_does_no_embedding_work_spex.exs`
- `test/spex/688_always_fresh_project_documentation_search/criterion_5973_the_agents_mcp_tool_list_does_not_expose_embed_docs_spex.exs`
- `test/spex/688_always_fresh_project_documentation_search/criterion_5974_file_sync_completes_when_the_embedding_pipeline_is_unavailable_spex.exs`
- `test/spex/688_always_fresh_project_documentation_search/criterion_5975_bundled_framework_knowledge_is_re_embedded_after_a_codemyspec_upgrade_spex.exs`

## Linked component: Files

This story is implemented by `CodeMySpec.Files` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/files_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/files.spec.md`
- Source: `lib/code_my_spec/files.ex`

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

Write the brief to `.code_my_spec/qa/825/brief.md` matching this spec exactly.
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