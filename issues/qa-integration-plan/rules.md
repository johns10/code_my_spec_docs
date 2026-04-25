# QA Integration Plan — Rules

**Story:** Verified third-party integrations.

> As a developer bootstrapping a CodeMySpec project with third-party integrations, I want the agent to read my technical decisions, draft an integration spec and a credential-verify script for each external service (OAuth provider, API service), gather credentials from me, and prove the credentials work, so that my project's external connections are verified before code generation depends on them — and a missing or wrong credential surfaces during planning, not at runtime when generated code fails to call out.

**Personas for this story:** Bootstrap developer (primary). Re-runner (secondary) — same person on a project that already has integration specs and re-runs the task after a new ADR adds another integration. No-integrations project (tertiary) — ADRs reference only standard-stack tech, empty pipeline is the happy path.

**Sequencing note:** This rules document does not state where `qa_integration_plan` runs in the requirement graph. Sequencing is the concern of `CodeMySpec.Requirements.RequirementDefinitionData`. The rules below describe the task's own contract.

---

## Rule: Integration specs are derived from technical decisions

The orchestration prompt presents the project's ADRs (`.code_my_spec/architecture/decisions/*.md`) and instructs the agent to identify each third-party service that needs external credentials — OAuth providers, API-key services. For every identified integration, the agent writes a spec to `.code_my_spec/integrations/{name}.md`. When no decision records exist, the prompt offers an explicit empty-index escape hatch and points the agent at `technical_strategy` so the upstream work gets done.

## Rule: Each integration carries a runnable verify script

For every integration spec, the prompt instructs the agent to write `verify_{name}.sh` to `.code_my_spec/qa/scripts/`. The script reads credentials from environment variables, makes a test API call, and emits structured JSON to stdout — `{"integration": "...", "status": "ok", "details": "..."}` on success, `{"integration": "...", "status": "error", "error": "...", "details": "..."}` on failure. OAuth2 integrations also get an `exchange_{name}_token.sh` for client-credential exchange.

## Rule: Spec status moves from `pending` to `verified` only after successful credential verification

New integration specs start at `pending`. The prompt instructs the agent to gather credentials from the user, run the verify script, parse the JSON output, and only promote the spec's status to `verified` after a successful run. Specs in any other state mean credentials are unproven.

## Rule: Validation gates on the integration index plus per-spec verification

`evaluate/3` runs a small state machine:

- **No specs at all** → `:valid`. Empty pipeline is a first-class happy path; a project with no third-party integrations clears the requirement.
- **Specs exist, index missing** → `:invalid` with feedback naming the index path.
- **Specs exist, any spec missing its verify script reference** → `:invalid` naming the spec.
- **Specs exist, any spec lacking `verified` status** → `:invalid` naming the spec.
- **Specs exist, index present, every spec has a verify script and `verified` status** → `:valid`.

The "verified" check is currently a case-insensitive substring match on the spec content — known to be loose. A tighter contract (structured `status: verified` line) is a future refinement, not part of this story.

## Rule: The prompt grounds itself in real project state

The prompt has four conditional context sections — Decisions, Existing Specs, Existing Index, and the document-spec block — and each renders only when the corresponding state is on disk:

- No decisions on disk → "no decision records found" message + empty-index escape hatch.
- Decisions on disk → list with truncated content per ADR.
- No existing specs → section omitted.
- Existing specs → list of paths with "update rather than recreate" guidance.
- No existing index → section omitted.
- Existing index → "read it and update rather than starting from scratch" guidance.

A re-runner with prior specs and an index gets a prompt that clearly distinguishes new integrations from existing ones; a bootstrap dev with nothing on disk gets the minimal entry-point prompt.

---

## Session notes

**Storage split.** Integration specs at `.code_my_spec/integrations/<name>.md` (consumed downstream by code generation's `cms_gen.integration_provider` per-provider loop). Verify scripts at `.code_my_spec/qa/scripts/verify_<name>.sh`. Index at `Paths.integrations_index()`.

**Why a separate task from `qa_setup`.** Different inputs (ADRs vs the running app's router), different concern (third-party credentials vs the app's own QA harness), different re-run triggers (a new ADR vs a route change). They share the `.code_my_spec/qa/scripts/` directory but otherwise don't overlap. Naming would benefit from a rename in a future story (`integration_credentials_verified` reads cleaner than `qa_integration_plan`); not part of this work.

**Script execution at spec-test time.** BDD specs run against an in-memory env and cannot actually shell out. Scenarios assert on prompt content and on the spec metadata the agent claims to have written (the status text in the spec file). Real script execution is out of scope for the BDD layer; integration tests against a real env can cover that later.

**Brittle "verified" detection.** `check_verified_status/2` uses `String.contains?(String.downcase(content), "verified")`. Phrases like "we considered verifying" pass. Logged as a known limitation; tightening to a structured field is a future refinement, not gated by this story.
