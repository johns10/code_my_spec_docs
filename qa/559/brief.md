# Qa Story Brief

## Tool

web (Vibium MCP browser tools for the Three Amigos LiveView at port 4003); spex suite (`mix spex`) for MCP surface criteria; MCP client (`mcp__plugin_codemyspec_local__*`) for backend tool verification.

## Auth

Local app (port 4003): No auth — `Plugs.LocalOnly` accepts loopback IPs directly.

Hosted app (port 4000): Navigate to `http://127.0.0.1:4000/users/log-in`, fill `#login_form_password` with:
- Email: qa@codemyspec.local
- Password: qa-password-123!
- Click "Log in and stay logged in"

## Seeds

```
mix run priv/repo/qa_seeds.exs
```

Creates qa@codemyspec.local / qa-password-123!, account "qa-account", project "QA Fixture Project" (id 11111111-1111-4111-8111-111111111111).

## What To Test

### Scenario 1: Spex suite for all 15 BDD criteria (criteria 5885-5899)

Run `mix spex --verbose` and verify all 15 spex files in `test/spex/559_three_amigos/` pass. These cover:
- criterion_5885: graph surfaces three_amigos_complete for story without AC
- criterion_5886: add_rule rejects when no persona linked
- criterion_5887: three_amigos_complete clears and graph advances
- criterion_5888: lightweight persona creation surfaces personas_complete next
- criterion_5889: readiness fails when no rules
- criterion_5890: readiness fails when no personas
- criterion_5891: readiness fails when too many rules (15 ceiling)
- criterion_5892: multiple personas can be linked
- criterion_5893: task prompt references priv/knowledge/three_amigos/workflow.md
- criterion_5894: add_scenario rejects unknown rule
- criterion_5895: redispatch after all criteria deleted
- criterion_5896: add_question creates question record
- criterion_5897: readiness fails when more questions than scenarios
- criterion_5898: resolved questions do not block readiness
- criterion_5899: get_story_gherkin renders Feature/Rule/Scenario structure

### Scenario 2: Three Amigos LiveView renders on local app (port 4003)

Navigate to `http://127.0.0.1:4003/projects/code-my-spec/stories/559/three-amigos`.
Verify:
- Page renders without error
- Rules, scenarios (as criteria), and questions columns show
- SEALED status appears when readiness gate is cleared
- Story title is visible

### Scenario 3: Verify the hosted app (port 4000) three-amigos route

Check whether `/app/stories/:id/three-amigos` exists on port 4000. The local Three Amigos LiveView only lives at port 4003. If the hosted route is absent, note it as expected given current architecture.

## Result Path

`.code_my_spec/qa/559/result.md`
