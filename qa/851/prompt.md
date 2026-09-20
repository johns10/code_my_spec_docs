# QA Story 851: My domain is registered and pointed at my app

Run a full QA session for this story. Two phases: write a testing brief,
then execute it. The playbook below has the detailed procedure.

**App URL:** Run `mix run -e 'IO.puts(CodeMySpecWeb.Endpoint.url())'`.

## Story description

As a solo founder, I want my domain pointed at my app so that I never hand-configure DNS.

## Acceptance criteria

- Setup reports what the registrar actually said, and no more.

Sam checks a name. Setup shows him the registrar's own answer for that name — which, for anything the account does not already hold, is the name and whether the extension is supported. It does not fill the gap: no invented availability, no price, no invitation to buy.

Re-grounded 2026-08: this was "Sam picks a name and sees what it costs", and no input could reach it. Cloudflare's Registrar API returns availability, price and current registrar **only for domains already on the account**; for anything else it returns `{name, supported_tld}`. So a name Sam does not own can never be priced, and a name he does own has no price to show.

It had been passing against a cassette named `cloudflare_domain_check_available_with_price` whose recorded response is `{"name": "sams-new-thing.com", "supported_tld": true}` — no price in it. The recording was honest about the provider; the criterion was satisfied by something that did not demonstrate its claim, which is why this took QA to notice rather than the suite. The cassette is now named `cloudflare_domain_check_unpriced`.

Reporting exactly what the provider said is the claim worth keeping, and it is what the spex already asserted. Reading the absence of an availability field as "taken" is a bug an earlier version had; `:unknown` is the honest answer. Adopting a domain Sam already owns is criterion 8052's territory, not this one.
- A name setup cannot register says so plainly.

Sam checks a name his account does not hold. Setup does not claim it is available, does not claim it is taken, and does not invite him to buy it — it says what is true: this app cannot register a name it does not already hold, so buy it in the Cloudflare dashboard and come back, and it will be adopted on the next check.

Re-grounded 2026-08: this was "a taken domain sends Sam back to choose again", which assumed setup could tell taken from available. It cannot — the Registrar API answers the same way for `google.com` and for a name nobody has ever registered, because both are equally "not on this account". The old behaviour told Sam to register `google.com` in the dashboard, an errand he cannot complete.

The failure worth guarding against is therefore not "taken" but "implied a capability we do not have". A message that reads as a provider limitation rather than a broken feature is the outcome; the previous copy read as the latter.
- A retried step does not buy a second domain
- Sam finds the domain in his own account
- An unsupported extension becomes a dashboard errand
- Each environment resolves to its own server
- The records let the proxy get its certificate
- An existing domain is an ordinary way in, not an error path

## BDD spec files

- `test/spex/965_my_domain_is_registered_and_pointed_at_my_app/criterion_7988_setup_reports_what_the_registrar_actually_said_and_no_more_spex.exs`
- `test/spex/965_my_domain_is_registered_and_pointed_at_my_app/criterion_7989_a_name_setup_cannot_register_says_so_plainly_spex.exs`
- `test/spex/965_my_domain_is_registered_and_pointed_at_my_app/criterion_7991_a_retried_step_does_not_buy_a_second_domain_spex.exs`
- `test/spex/965_my_domain_is_registered_and_pointed_at_my_app/criterion_7992_sam_finds_the_domain_in_his_own_account_spex.exs`
- `test/spex/965_my_domain_is_registered_and_pointed_at_my_app/criterion_7993_an_unsupported_extension_becomes_a_dashboard_errand_spex.exs`
- `test/spex/965_my_domain_is_registered_and_pointed_at_my_app/criterion_7995_each_environment_resolves_to_its_own_server_spex.exs`
- `test/spex/965_my_domain_is_registered_and_pointed_at_my_app/criterion_7996_the_records_let_the_proxy_get_its_certificate_spex.exs`
- `test/spex/965_my_domain_is_registered_and_pointed_at_my_app/criterion_8052_an_existing_domain_is_an_ordinary_way_in_not_an_error_path_spex.exs`

## Linked component: Cloudflare

This story is implemented by `CodeMySpec.Provisioning.Cloudflare` (module).
Reading the source code and spec will help you understand what to
test and how the feature works.

- Tests: `test/code_my_spec/provisioning/cloudflare_test.exs`
- Spec: `.code_my_spec/spec/code_my_spec/provisioning/cloudflare.spec.md`
- Source: `lib/code_my_spec/provisioning/cloudflare.ex`

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

Write the brief to `.code_my_spec/qa/851/brief.md` matching this spec exactly.
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