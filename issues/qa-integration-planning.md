# QA Integration Planning: Dedicated Pre-Bootstrap Step

## Problem

When the QA agent tests applications with third-party integrations (OAuth providers, API-key services), it can't distinguish between "the integration isn't set up" and "the feature is broken." It flails, papers over issues, or gives up — even when the user has manually set up OAuth connections and seeded tokens.

The root cause is that integration readiness is handled ad hoc. The user sets things up, but the agent has no way to **verify** that integrations are functional before testing features that depend on them. There's no manifest, no verification scripts, and no preflight gate.

QaStory's plan phase (`app overview`, `tools registry`, `seed strategy`) describes integrations in prose but can't prove they work. Integration setup is too important and too collaborative to be a subsection of QA story planning — it needs its own dedicated step with formal validation.

## Current State

- `TechnicalStrategy` identifies integration decisions ("use Twilio for SMS", "use Google Calendar with OAuth2") and writes ADRs to `.code_my_spec/architecture/decisions/`
- `ProjectBootstrap` implements those decisions but has no structured input about what integrations to scaffold
- `QaStory` plan phase asks the agent to "analyze the app" and write a free-text plan — no structured integration inventory
- OAuth providers in CodeMySpec itself (`integrations/providers/github.ex`, `google.ex`) follow an extremely consistent pattern (Assent strategies), suggesting generators would work well
- No verification scripts exist for proving credentials are valid or integrations are functional

## Design

### Position in the Requirement Graph

```
# Before:
technical_strategy → project_bootstrap → ...stories... → qa_journey_plan → ...

# After:
technical_strategy → qa_integration_plan → project_bootstrap → ...stories...
                                                                     ↓
                                              qa_preflight → qa_story (per-story)
                                                           → qa_journey_plan → ...
```

**QA integration planning** sits between technical strategy and project bootstrap because:

1. It reads technical decisions to identify what integrations are needed
2. It produces structured integration specs that bootstrap uses to scaffold code
3. Credential verification (hitting the third-party API directly) doesn't require the app to exist yet

**QA preflight** sits after stories are complete but before any QA testing because:

1. It verifies the app-level integration code works end-to-end (the app is running, seeds are loaded)
2. It gates QA stories — no point testing features if integrations are broken at the app level
3. It runs the same verify scripts but against the app's own endpoints, not direct API calls

### Integration Types by Auth Mechanism

| Type | Credentials | Verification | Example |
|------|-------------|-------------|---------|
| `api_token` | API key/secret in env var | Test API call with the key | Twilio, Stripe, Anthropic |
| `oauth2` | Client ID + Client Secret, then user-level token exchange | Token exchange + test API call | Google Calendar, GitHub |

### Artifacts

| Artifact | Path | Purpose |
|----------|------|---------|
| Integration specs | `.code_my_spec/integrations/{name}.md` | Per-integration config: type, credentials, verify script, status |
| Verify scripts | `.code_my_spec/qa/scripts/verify_{name}.sh` | Proves credentials are valid (direct API call) |
| Token exchange scripts | `.code_my_spec/qa/scripts/exchange_{name}_token.sh` | OAuth2: exchanges client creds for a test token |
| Integration index | `.code_my_spec/integrations.md` | Summary of all integrations and their status |

### Integration Spec Format

```markdown
# {Name} Integration

## Auth Type
api_token | oauth2

## Required Credentials
- `ENV_VAR_NAME` — description of what this is and where to get it

## Verify Script
`.code_my_spec/qa/scripts/verify_{name}.sh`

## Token Exchange Script (oauth2 only)
`.code_my_spec/qa/scripts/exchange_{name}_token.sh`

## Status
pending | configured | verified
```

### Integration Lifecycle

```
1. TechnicalStrategy writes ADR: "use Twilio for SMS"
2. QaIntegrationPlan reads decisions, drafts integration spec (status: pending)
3. Agent tells user: "provide TWILIO_ACCOUNT_SID and TWILIO_AUTH_TOKEN"
4. User provides credentials → status: configured
5. Verify script runs, test API call succeeds → status: verified
6. ProjectBootstrap reads specs, scaffolds provider code, routes, UI, tests
7. QA preflight (pre-stories) verifies app-level integration works end-to-end
```

### Three Verification Moments

| When | What | How |
|------|------|-----|
| QA Integration Plan (pre-bootstrap) | Credentials are valid | Verify scripts make direct API calls, checker validates structured JSON output |
| Generated Tests (during bootstrap) | Integration code works in isolation | ExVCR cassette tests record real API interactions — requires real tokens to record |
| QA Preflight (pre-QA stories) | App integrations work end-to-end | Verify scripts run against the running app's own endpoints, checker validates JSON output |

### Collaborative Workflow

This step is inherently collaborative — the agent can't get API keys on its own. The flow:

1. Agent reads technical decisions and identifies integrations
2. Agent drafts integration specs with credential requirements
3. Agent generates verify scripts and token exchange scripts
4. Agent prompts user: "I need these credentials to proceed"
5. User provides credentials (env vars, OAuth client secrets, etc.)
6. Agent runs verify scripts to confirm credentials work
7. Evaluate checks: all integrations at `verified` status?

### Code Generators

OAuth integrations are so consistently structured that they should be generated, not hand-written. A generator takes an integration spec and scaffolds:

- Provider module (Assent strategy pattern)
- OAuth controller routes
- Settings/connections UI page
- Backend context and schema
- **ExVCR cassette tests** — require real tokens/secrets to record, ensuring integrations are actually functional
- Verify and token exchange scripts

The generator is part of this step, not a follow-on. The generated tests serve double duty: they prove the integration works during development AND they become the permanent regression suite (recorded cassettes replay without hitting real APIs in CI).

The agent iterates on customizing generated code rather than writing boilerplate from scratch.

## Implementation Steps

### 1. Paths — add integration helpers

**File:** `lib/code_my_spec/paths.ex`

- `integrations_dir/0` → `".code_my_spec/integrations"`
- `integrations_index/0` → `".code_my_spec/integrations.md"`
- `integration_file/1` → `".code_my_spec/integrations/{name}.md"`

### 2. Document Registry — add integration spec document type

**File:** `lib/code_my_spec/documents/registry.ex`

**`integration_spec`:**
- Required sections: `"auth type"`, `"required credentials"`, `"verify script"`, `"status"`
- Optional sections: `"token exchange script"`, `"notes"`

### 3. Requirement Checker — runs verify scripts with structured output

**File:** `lib/code_my_spec/requirements/qa_integration_plan_checker.ex`

Implements `CheckerBehaviour`. This checker doesn't just read files — it **executes** the verify scripts and validates structured output.

Checks:
- Integration index exists at `.code_my_spec/integrations.md`
- At least one integration spec exists (if technical decisions reference integrations)
- All referenced verify scripts exist
- **Runs each verify script** and validates structured JSON output
- All integration specs have `status: verified`

#### Verify Script Contract

Every verify script MUST output a JSON result to stdout:

```json
{"integration": "twilio", "status": "ok", "details": "SMS test message sent to +1555000TEST"}
```

Or on failure:

```json
{"integration": "twilio", "status": "error", "error": "401 Unauthorized", "details": "TWILIO_AUTH_TOKEN is invalid or expired"}
```

The checker parses this output, validates `status: "ok"` for each integration, and produces specific failure messages when something is wrong. This gives strong programmatic guarantees — not "the file says verified" but "we just proved it works right now."

For OAuth2 integrations, the verify script also confirms token exchange works:

```json
{"integration": "google_calendar", "status": "ok", "auth_type": "oauth2", "details": "Token exchange succeeded, calendar list returned 3 calendars"}
```

### 4. Agent Task

**File:** `lib/code_my_spec/agent_tasks/qa_integration_plan.ex`

Follows the QaSetup pattern: `command/3` + `evaluate/3`.

**`command/3`:**
- Reads technical decisions from `.code_my_spec/architecture/decisions/`
- Identifies integration-related decisions (OAuth providers, API services, third-party APIs)
- Reads any existing integration specs
- Builds prompt instructing the agent to:
  1. Draft integration specs for each identified integration
  2. Generate verify scripts (and token exchange scripts for OAuth2)
  3. Ask the user for credentials
  4. Run verify scripts to confirm
  5. Update status to `verified`
  6. Write the integration index

**`evaluate/3`:**
- State machine checking:
  1. Integration index exists?
  2. All expected integration specs exist?
  3. All specs have verify scripts?
  4. **Runs each verify script**, parses JSON output, validates `status: "ok"`
  5. Updates spec status to `verified` on success
- Returns specific feedback for whichever check fails first (including the actual error from the verify script JSON)

### 5. Requirement Definition — wire into project graph

**File:** `lib/code_my_spec/requirements/requirement_definition_data.ex`

- Add `qa_integration_plan/0` definition
- Prerequisite: `technical_strategy`
- Make `project_bootstrap` depend on `qa_integration_plan`
- Uses `scope: :orchestrate`

### 6. Session Registration

**File:** `lib/code_my_spec/sessions/session_type.ex` — add to `@valid_types`

**File:** `lib/code_my_spec/agent_tasks/start_agent_task.ex` — add to `@session_type_map` + `@componentless_tasks`

### 7. QA Preflight — dedicated step before QA stories

QA preflight is its own requirement and agent task, not a subsection of QA journey plan. It gates all QA testing.

**File:** `lib/code_my_spec/requirements/qa_preflight_checker.ex`

Implements `CheckerBehaviour`. Checks:
- All integration specs exist and have verify scripts
- **Runs each verify script against the running app** (not direct API calls — those were pre-bootstrap)
- Parses structured JSON output, validates `status: "ok"` for each
- All generated ExVCR cassette tests pass (`mix test` on integration test files)

**File:** `lib/code_my_spec/agent_tasks/qa_preflight.ex`

Follows QaSetup pattern: `command/3` + `evaluate/3`.

- `command/3`: Reads integration specs, builds prompt to start the app, run seeds, execute verify scripts against app endpoints, run integration tests
- `evaluate/3`: Executes verify scripts, parses JSON, runs integration tests — returns specific failure info or `:valid`

**Requirement graph position:**
- Prerequisite: `all_stories_complete` (app is built)
- Gates: `qa_story` (per-story QA) and `qa_journey_plan` (journey QA)

This is the "prove the app's integrations actually work" gate. The integration plan step proved credentials are valid. Bootstrap generated the code and tests. Preflight proves the whole thing works end-to-end in the running app.

### 8. Tests

**Checker test:** `test/code_my_spec/requirements/qa_integration_plan_checker_test.exs`
- Satisfied when all integration specs exist with `status: verified`
- Not satisfied when specs are missing, unverified, or missing verify scripts

**Agent task test:** `test/code_my_spec/agent_tasks/qa_integration_plan_test.exs`
- `command/3` reads decisions and returns prompt with integration instructions
- `evaluate/3` validates integration spec structure and status

## Files Summary

### New files (8):
- `lib/code_my_spec/agent_tasks/qa_integration_plan.ex`
- `lib/code_my_spec/agent_tasks/qa_preflight.ex`
- `lib/code_my_spec/requirements/qa_integration_plan_checker.ex`
- `lib/code_my_spec/requirements/qa_preflight_checker.ex`
- `test/code_my_spec/agent_tasks/qa_integration_plan_test.exs`
- `test/code_my_spec/agent_tasks/qa_preflight_test.exs`
- `test/code_my_spec/requirements/qa_integration_plan_checker_test.exs`
- `test/code_my_spec/requirements/qa_preflight_checker_test.exs`

### Modified files (5):
- `lib/code_my_spec/paths.ex`
- `lib/code_my_spec/documents/registry.ex`
- `lib/code_my_spec/requirements/requirement_definition_data.ex`
- `lib/code_my_spec/sessions/session_type.ex`
- `lib/code_my_spec/agent_tasks/start_agent_task.ex`

## Verification

1. `mix compile` — all new modules compile cleanly
2. `mix test test/code_my_spec/requirements/qa_integration_plan_checker_test.exs` — checker tests pass
3. `mix test test/code_my_spec/requirements/qa_preflight_checker_test.exs` — preflight checker tests pass
4. `mix test test/code_my_spec/agent_tasks/qa_integration_plan_test.exs` — agent task tests pass
5. `mix test test/code_my_spec/agent_tasks/qa_preflight_test.exs` — preflight task tests pass
6. Verify `RequirementDefinitionData.project_requirements/0` includes `qa_integration_plan` between `technical_strategy` and `project_bootstrap`
7. Verify `RequirementDefinitionData.project_requirements/0` includes `qa_preflight` after `all_stories_complete` and before `qa_story`/`qa_journey_plan`
8. Verify `StartAgentTask` routes both `"qa_integration_plan"` and `"qa_preflight"` to correct modules

## Resolved

1. **Integration specs are markdown documents.** Consistent with everything else in `.code_my_spec/`. Verify script output is JSON (structured, parseable), but the specs themselves are markdown via the document registry.

## Open Questions

1. **Session interaction model for user-provided credentials.** This step requires user action mid-session — the agent drafts integration specs and verify scripts, but can't proceed until the user provides API keys or completes OAuth flows. The current stop-hook model (agent stops → hook evaluates → hook relaunches agent) is too intrusive here.

   Key insight: **evaluate checks what the user did, not what the agent did.** The agent's work (specs, scripts) is done when it stops. After that, evaluate is waiting for the *user's* contribution — credentials that make the verify scripts pass. This is the first task where evaluate is genuinely evaluating user action.

   This means the `:awaiting_user` state doesn't need the user to explicitly say "resume." The hook can periodically re-run evaluate. User drops in the API key → next evaluate cycle runs the verify script → script returns `{"status": "ok"}` → task advances automatically. The user never has to say "go" — they just do the thing, and the system picks it up.

   Three hook behaviors needed:

   | Evaluate result | Hook behavior |
   |---|---|
   | `:invalid` (fixable by agent) | Relaunch agent with feedback |
   | `:valid` | Advance to next task |
   | `:awaiting_user` (new) | Don't relaunch. Poll evaluate on interval. Advance when it passes. |

   This is tied to the broader stop-hook work already in progress. This task is one of the first real cases that needs the `:awaiting_user` pattern — but any task requiring user action in the real world (provide secrets, approve a deploy, complete an OAuth consent flow) hits the same need.
