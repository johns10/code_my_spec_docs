# QA Story 833: Local-first content publishing — CLI parses, validates, uploads to user-owned S3, triggers client

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As a solo developer using CodeMySpec, I want the local CLI/plugin to handle content publishing end-to-end — parse my markdown wherever it lives on disk, validate it, upload images and a content manifest to my own S3 buckets, then trigger my deployed client to pull — so my editorial workflow stays on my machine, my AWS/CF credentials never leave my laptop, and the CodeMySpec SaaS is not gating content publishing behind its subscription.


## Acceptance criteria

- Sam syncs a plain non-Git folder and the pipeline runs end-to-end
- One malformed frontmatter doesn't abort the sync
- Admin LiveView renders parse status without hitting the SaaS
- Images upload to the user's S3 image bucket on sync
- Markdown image URLs rewrite to CDN host before persistence
- Replaced hero image goes live immediately via CF purge
- Publish aborts when parse errors remain in the snapshot
- Publish writes manifest + blob to user's content bucket
- Client gets pull trigger and fetches the manifest from S3

## BDD spec files

- `test/spex/712_local-first_content_publishing_cli_parses_validates_uploads_to_user-owned_s3_triggers_client/criterion_6268_sam_syncs_a_plain_non-git_folder_and_the_pipeline_runs_end-to-end_spex.exs`
- `test/spex/712_local-first_content_publishing_cli_parses_validates_uploads_to_user-owned_s3_triggers_client/criterion_6269_one_malformed_frontmatter_doesnt_abort_the_sync_spex.exs`
- `test/spex/712_local-first_content_publishing_cli_parses_validates_uploads_to_user-owned_s3_triggers_client/criterion_6270_admin_liveview_renders_parse_status_without_hitting_the_saas_spex.exs`
- `test/spex/712_local-first_content_publishing_cli_parses_validates_uploads_to_user-owned_s3_triggers_client/criterion_6271_images_upload_to_the_users_s3_image_bucket_on_sync_spex.exs`
- `test/spex/712_local-first_content_publishing_cli_parses_validates_uploads_to_user-owned_s3_triggers_client/criterion_6272_markdown_image_urls_rewrite_to_cdn_host_before_persistence_spex.exs`
- `test/spex/712_local-first_content_publishing_cli_parses_validates_uploads_to_user-owned_s3_triggers_client/criterion_6273_replaced_hero_image_goes_live_immediately_via_cf_purge_spex.exs`
- `test/spex/712_local-first_content_publishing_cli_parses_validates_uploads_to_user-owned_s3_triggers_client/criterion_6274_publish_aborts_when_parse_errors_remain_in_the_snapshot_spex.exs`
- `test/spex/712_local-first_content_publishing_cli_parses_validates_uploads_to_user-owned_s3_triggers_client/criterion_6275_publish_writes_manifest_blob_to_users_content_bucket_spex.exs`
- `test/spex/712_local-first_content_publishing_cli_parses_validates_uploads_to_user-owned_s3_triggers_client/criterion_6276_client_gets_pull_trigger_and_fetches_the_manifest_from_s3_spex.exs`

## Linked component: ContentLive

This story is implemented by `CodeMySpecWeb.ContentLive` (module).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec_web/content_live_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec_web/content_live.spec.md`
- Source: `lib/code_my_spec_web/content_live.ex`

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

Write the brief to `.code_my_spec/qa/833/brief.md` matching this spec exactly.
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