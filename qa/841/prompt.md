# QA Story 841: Agent does my DevOps for me

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As a user, I want the agent to handle all my DevOps — provisioning, deploys, secrets, and monitoring — so my app gets to production and stays there without me doing infrastructure work.

## Acceptance criteria

- Sam pastes tokens once and walks away
- An under-scoped token names its missing permission
- Sam sees every resource in his own consoles
- DevOps setup surfaces after code generation
- Default setup ends with UAT and prod live — every step through the deploy has resources behind it: a repository, an age key per environment, both boxes, the domain, records pointing at them, and the app serving.

Narrowed 2026-08-16 (John's call, asked directly). It used to assert the whole sequence reported "Setup is complete", and it cannot: the widget step's proof is a message from the deployed site's own client, which lands wherever `CODEMYSPEC_WIDGET_URL` points. Recording from a laptop that means the dev server behind the tunnel, not the test database the run is watching — so the message arrives somewhere this criterion cannot see. The step pauses for it by design ("waiting on a person, not broken") rather than failing, and 973 already has criteria for the widget round-trip.

Measured rather than assumed: a live run on 2026-08-16 built `spex-story841-criterion1961-uat` and `-prod`, published DNS, deployed, and served HTTPS at c1961.legwork.ca — twelve of fourteen steps done in 23 minutes, stopping only on widget and callback_credential. What this criterion claims is the part that works and can be proven unattended.
- Opting out of prod completes setup UAT-only
- A story that clears QA rides to UAT — the loop's next work after qa_complete is the UAT deploy, health-verified; prod promotion belongs to the release process.
- A failing UAT health check fails the deploy: the deploy is not recorded as done, and the failure surfaces as a problem for the loop and the user — a sick UAT never reads as shipped.
- Secrets are seeded once and fetched at boot
- A missing secret fails the boot loudly and by name
- Each environment answers on its domain over HTTPS
- Setup leaves backups running — a dump lands in Sam's bucket and is proven by restoring it, on a schedule installed on the environment's own server. Uptime monitoring is deliberately not part of setup: it needed a third-party account, an API key and a notification target only a person can supply, so the step paused on every run and setup could never report complete. Rather than carry an unowned SaaS dependency in the path of "did my site go down", or build the monitoring ourselves, the claim is narrowed to what setup actually does. Generated applications still expose `/_cms/verify/always-failing`, which is down by construction, so whatever monitoring is eventually pointed at them can be proven to notice.
- The repo can rebuild the infrastructure from scratch
- DevOps off keeps the graph silent about infrastructure

## BDD spec files

- `test/spex/841_agent_does_my_devops_for_me/criterion_1957_sam_pastes_tokens_once_and_walks_away_spex.exs`
- `test/spex/841_agent_does_my_devops_for_me/criterion_1958_an_under-scoped_token_names_its_missing_permission_spex.exs`
- `test/spex/841_agent_does_my_devops_for_me/criterion_1959_sam_sees_every_resource_in_his_own_consoles_spex.exs`
- `test/spex/841_agent_does_my_devops_for_me/criterion_1960_devops_setup_surfaces_after_code_generation_spex.exs`
- `test/spex/841_agent_does_my_devops_for_me/criterion_1961_default_setup_ends_with_uat_and_prod_live_spex.exs`
- `test/spex/841_agent_does_my_devops_for_me/criterion_1962_opting_out_of_prod_completes_setup_uat-only_spex.exs`
- `test/spex/841_agent_does_my_devops_for_me/criterion_1963_a_story_that_clears_qa_rides_to_uat_the_loops_next_work_after_qa_complete_is_the_uat_deploy_spex.exs`
- `test/spex/841_agent_does_my_devops_for_me/criterion_1964_a_failing_uat_health_check_fails_the_deploy_the_deploy_is_not_recorded_as_done_and_the_failure_spex.exs`
- `test/spex/841_agent_does_my_devops_for_me/criterion_1965_secrets_are_seeded_once_and_fetched_at_boot_spex.exs`
- `test/spex/841_agent_does_my_devops_for_me/criterion_1966_a_missing_secret_fails_the_boot_loudly_and_by_name_spex.exs`
- `test/spex/841_agent_does_my_devops_for_me/criterion_1967_each_environment_answers_on_its_domain_over_https_spex.exs`
- `test/spex/841_agent_does_my_devops_for_me/criterion_1968_setup_leaves_backups_running_spex.exs`
- `test/spex/841_agent_does_my_devops_for_me/criterion_1969_the_repo_can_rebuild_the_infrastructure_from_scratch_spex.exs`
- `test/spex/841_agent_does_my_devops_for_me/criterion_1970_devops_off_keeps_the_graph_silent_about_infrastructure_spex.exs`

## Linked component: AgentTasks

This story is implemented by `CodeMySpec.AgentTasks` (context).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/agent_tasks_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/agent_tasks.spec.md`
- Source: `lib/code_my_spec/agent_tasks.ex`

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

Write the brief to `.code_my_spec/qa/841/brief.md` matching this spec exactly.
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