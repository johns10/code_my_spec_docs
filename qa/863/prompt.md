# QA Story 863: Analytics Tracking and Traffic Filtering

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As the owner of CodeMySpec, I want to track user traffic and key events, filtering out unwanted traffic on the backend, so I can read the funnel end-to-end without prod cross-checks.

The funnel-establishment work that's been running across the last two weeks has produced a working but partial pipeline. 9 rules cover the complete analytics tracking surface — 5 shipped (R1, R2, R3, R5, R6), 4 open (R4 env-aware measurement ID; R7 Reddit attribution; R8 daily reconciliation; R9 page_view on mobile-webview). Full rule and scenario text in `.code_my_spec/issues/analytics-tracking-and-traffic-filtering.md`.

## Acceptance criteria

- Server-side page_view dispatches on every browser-pipeline pageload
- Mobile-webview pageloads still fire page_view
- Reddit referrer attributes to Reddit, not (not set)
- Known-bot / empty-signal request is filtered before dispatch
- Homepage hero install-card copy fires install_command_copy
- All four install-card placements fire with the right location
- Register page mount dispatches :view_register_page
- /app onboarding mount dispatches :onboarding_panel_viewed
- In-app install step copy dispatches :install_step_copied with step
- New magic-link signup dispatches sign_up and registration_email_sent
- OAuth :new branch dispatches sign_up with provider method
- OAuth :existing via provider identity is silent
- OAuth :existing via email auto-link is silent
- OAuth callback with missing email returns error and dispatches nothing
- First cms connect dispatches :first_cli_connect once
- Subsequent cms connects do not re-fire :first_cli_connect
- Every dispatch traces from handler entry through MP delivery outcome
- Custom dimensions harness + location are queryable for install events
- Key activation events surface as conversions in GA4 reports
- Root layout has no gtag.js script
- window.GA_MEASUREMENT_ID is never set in the browser
- page_view originates from a server plug, never from gtag
- Click events route through the analytics API, not gtag
- GA4 measurement ID lives only in server config
- Root layout loads gtag.js async with the GA4 measurement id
- Install-card copy fires gtag install_command_copy with location + harness across all four placements
- Register and onboarding mounts fire their gtag behavior events
- No server-side page_view or behavior dispatch exists
- Server MP sign_up carries the gtag client_id from the _ga cookie so it stitches to the browser session
- Server MP conversions carry the gtag session_id from the _ga session cookie
- OAuth :new sign_up carries the gtag client_id and session_id stitch ids

## BDD spec files

- `test/spex/812_analytics_tracking_and_traffic_filtering/criterion_6507_new_magic_link_signup_dispatches_sign_up_and_registration_email_sent_spex.exs`
- `test/spex/812_analytics_tracking_and_traffic_filtering/criterion_6508_oauth_new_branch_dispatches_sign_up_with_provider_method_spex.exs`
- `test/spex/812_analytics_tracking_and_traffic_filtering/criterion_6509_oauth_existing_via_provider_identity_is_silent_spex.exs`
- `test/spex/812_analytics_tracking_and_traffic_filtering/criterion_6510_oauth_existing_via_email_auto_link_is_silent_spex.exs`
- `test/spex/812_analytics_tracking_and_traffic_filtering/criterion_6511_oauth_callback_with_missing_email_returns_error_and_dispatches_nothing_spex.exs`
- `test/spex/812_analytics_tracking_and_traffic_filtering/criterion_6512_first_cms_connect_dispatches_first_cli_connect_once_spex.exs`
- `test/spex/812_analytics_tracking_and_traffic_filtering/criterion_6513_subsequent_cms_connects_do_not_re_fire_first_cli_connect_spex.exs`
- `test/spex/812_analytics_tracking_and_traffic_filtering/criterion_6514_every_dispatch_traces_from_handler_entry_through_mp_delivery_outcome_spex.exs`
- `test/spex/812_analytics_tracking_and_traffic_filtering/criterion_6515_custom_dimensions_harness_location_are_queryable_for_install_events_spex.exs`
- `test/spex/812_analytics_tracking_and_traffic_filtering/criterion_6534_root_layout_loads_gtag_js_async_with_the_ga4_measurement_id_spex.exs`
- `test/spex/812_analytics_tracking_and_traffic_filtering/criterion_6535_install_card_copy_fires_gtag_install_command_copy_with_location_and_harness_across_all_four_placements_spex.exs`
- `test/spex/812_analytics_tracking_and_traffic_filtering/criterion_6536_register_and_onboarding_mounts_fire_their_gtag_behavior_events_spex.exs`
- `test/spex/812_analytics_tracking_and_traffic_filtering/criterion_6538_server_mp_sign_up_carries_gtag_client_id_from_ga_cookie_spex.exs`
- `test/spex/812_analytics_tracking_and_traffic_filtering/criterion_6539_server_mp_conversions_carry_the_gtag_session_id_from_the_ga_session_cookie_spex.exs`
- `test/spex/812_analytics_tracking_and_traffic_filtering/criterion_6540_oauth_new_sign_up_carries_the_gtag_client_id_and_session_id_stitch_ids_spex.exs`

## Linked component: Analytics

This story is implemented by `CodeMySpec.Analytics` (logic).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/analytics_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/analytics.spec.md`
- Source: `lib/code_my_spec/analytics.ex`

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

Write the brief to `.code_my_spec/qa/863/brief.md` matching this spec exactly.
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