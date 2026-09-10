# QA Story 834: Content — generator-output rendering surface in deployed client apps

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As a solo developer using CodeMySpec, I want the generator to drop a `Content` module into my deployed app that receives content pushes from the CodeMySpec server and renders them at clean public URLs — so I get a marketing/blog/landing surface in my product without hand-rolling routing, render, scheduling, image handling, or tag-filtering logic.

In scope: Generator output — receive pushes from ContentAdmin (including images); persist locally in the client app's DB; render images alongside text; render `/blog/:slug`, `/pages/:slug`, `/landing/:slug`, `/documentation/:slug` (dead-view controllers); honor publish_at + expires_at at render time; tag-based filtering / index pages; 404 for unknown / unpublished / expired content.

Out of scope: Editorial workflow on the SaaS side (separate story for `ContentAdmin`); the wire protocol details between ContentAdmin and Content — those will surface during Three Amigos.

Acceptance criteria deliberately omitted — this story should trigger Three Amigos in the requirements graph so rules + scenarios get authored fresh against current architecture (Content = generator output, not a permanent server feature; the `lib/code_my_spec/content*` files in this repo are dogfooding the SaaS marketing site AND the generator reference implementation). Recreated after deletion to satisfy orphan check on the existing dogfood code.

## Acceptance criteria

- Valid trigger with matching deploy_key kicks off the sync
- Well-formed manifest parses into the expected fields
- Blob whose hash matches the manifest passes verification
- New manifest replaces local content atomically
- Future-publish and expired slugs return 404 without re-pulling
- Tag-filtered index lists only currently in-window slugs

## BDD spec files

- `test/spex/713_content_generator-output_rendering_surface_in_deployed_client_apps/criterion_6277_valid_trigger_with_matching_deploy_key_kicks_off_the_sync_spex.exs`
- `test/spex/713_content_generator-output_rendering_surface_in_deployed_client_apps/criterion_6278_well-formed_manifest_parses_into_the_expected_fields_spex.exs`
- `test/spex/713_content_generator-output_rendering_surface_in_deployed_client_apps/criterion_6279_blob_whose_hash_matches_the_manifest_passes_verification_spex.exs`
- `test/spex/713_content_generator-output_rendering_surface_in_deployed_client_apps/criterion_6280_new_manifest_replaces_local_content_atomically_spex.exs`
- `test/spex/713_content_generator-output_rendering_surface_in_deployed_client_apps/criterion_6281_future-publish_and_expired_slugs_return_404_without_re-pulling_spex.exs`
- `test/spex/713_content_generator-output_rendering_surface_in_deployed_client_apps/criterion_6282_tag-filtered_index_lists_only_currently_in-window_slugs_spex.exs`

## Linked component: Content

This story is implemented by `CodeMySpec.Content` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/content_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/content.spec.md`
- Source: `lib/code_my_spec/content.ex`

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

Write the brief to `.code_my_spec/qa/834/brief.md` matching this spec exactly.
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