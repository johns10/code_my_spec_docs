# QA Story 794: Filesystem-to-DB Projection

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As an agent, I want File records and the derived component graph to stay in sync with the project's source tree — driven both by file-watcher events and by explicit catch-up sync (full or mtime-incremental) — so requirement evaluation, the next-actionable query, and architecture views always read from a current, on-disk-faithful DB without doing their own filesystem walks.

## Acceptance criteria

- Deleted file is reaped from the DB on next sync
- Full sync rescans every tracked file in the project
- Incremental sync processes only files whose mtime is newer than the DB record
- Single-path sync touches exactly one file
- Watcher's single-path sync leaves mtime stale so the stop-hook catch-up re-validates
- Saving a spec file flows through classify, validate, upsert, and component derivation
- Spec file validity comes from document parsing
- Spec file with malformed structure is marked invalid with the parser error
- mix.exs validity comes from concern-keyed checks readable by Setup steps
- Files outside the project source tree are not picked up by sync
- Content edit produces a new fingerprint and triggers downstream consumers
- A File row whose path is no longer on disk is reaped by the next sync, even when the watcher missed the delete event
- Single-path sync on a path that no longer exists on disk deletes the File row
- Test file misaligned with its spec is marked invalid with the alignment errors captured
- sync_path updates File.fingerprint eagerly while leaving mtime stale
- mtime flip without content change leaves File.fingerprint unchanged and out-of-band consumers skip
- A linked project's file changes appear in its /files projection without engineer intervention

## BDD spec files

- `test/spex/127_filesystem_to_db_projection/criterion_5919_deleted_file_is_reaped_from_the_db_on_next_sync_spex.exs`
- `test/spex/127_filesystem_to_db_projection/criterion_5920_full_sync_rescans_every_tracked_file_in_the_project_spex.exs`
- `test/spex/127_filesystem_to_db_projection/criterion_5921_incremental_sync_processes_only_files_whose_mtime_is_newer_than_the_db_record_spex.exs`
- `test/spex/127_filesystem_to_db_projection/criterion_5922_single_path_sync_touches_exactly_one_file_spex.exs`
- `test/spex/127_filesystem_to_db_projection/criterion_5923_watchers_single_path_sync_leaves_mtime_stale_so_the_stop_hook_catch_up_re_validates_spex.exs`
- `test/spex/127_filesystem_to_db_projection/criterion_5924_saving_a_spec_file_flows_through_classify_validate_upsert_and_component_derivation_spex.exs`
- `test/spex/127_filesystem_to_db_projection/criterion_5925_spec_file_validity_comes_from_document_parsing_spex.exs`
- `test/spex/127_filesystem_to_db_projection/criterion_5926_spec_file_with_malformed_structure_is_marked_invalid_with_the_parser_error_spex.exs`
- `test/spex/127_filesystem_to_db_projection/criterion_5927_mix_exs_validity_comes_from_concern_keyed_checks_readable_by_setup_steps_spex.exs`
- `test/spex/127_filesystem_to_db_projection/criterion_5930_files_outside_the_project_source_tree_are_not_picked_up_by_sync_spex.exs`
- `test/spex/127_filesystem_to_db_projection/criterion_5931_content_edit_produces_a_new_fingerprint_and_triggers_downstream_consumers_spex.exs`
- `test/spex/127_filesystem_to_db_projection/criterion_5933_a_file_row_whose_path_is_no_longer_on_disk_is_reaped_by_the_next_sync_even_when_the_watcher_missed_the_delete_event_spex.exs`
- `test/spex/127_filesystem_to_db_projection/criterion_5934_single_path_sync_on_a_path_that_no_longer_exists_on_disk_deletes_the_file_row_spex.exs`
- `test/spex/127_filesystem_to_db_projection/criterion_5937_test_file_misaligned_with_its_spec_is_marked_invalid_with_the_alignment_errors_captured_spex.exs`
- `test/spex/127_filesystem_to_db_projection/criterion_5944_sync_path_updates_file_fingerprint_eagerly_while_leaving_mtime_stale_spex.exs`
- `test/spex/127_filesystem_to_db_projection/criterion_5945_mtime_flip_without_content_change_leaves_file_fingerprint_unchanged_and_out_of_band_consumers_skip_spex.exs`
- `test/spex/127_filesystem_to_db_projection/criterion_6085_a_linked_projects_file_changes_appear_in_its_files_projection_without_engineer_intervention_spex.exs`

## Linked component: Files

This story is implemented by `CodeMySpec.Files` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/files_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/files.spec.md`
- Source: `lib/code_my_spec/files.ex`

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

Write the brief to `.code_my_spec/qa/794/brief.md` matching this spec exactly.
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