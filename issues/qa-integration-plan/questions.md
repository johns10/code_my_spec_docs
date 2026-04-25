# QA Integration Plan — Questions

## Resolved: Where in the requirement graph does this task run?

Not the concern of this module's docs or this story's rules. Sequencing lives in `CodeMySpec.Requirements.RequirementDefinitionData`. The graph currently has `qa_integration_plan` prereq'd on `code_generation`; intent is to move it to precede `code_generation` so integration specs are produced before generated provider code consumes them. That graph edit is a separate change.

## Resolved: Should `qa_integration_plan` and `qa_setup` merge into one task?

No. They look similar — both write to `.code_my_spec/qa/scripts/` and both carry the `qa_*` prefix — but their concerns are orthogonal:

- `qa_integration_plan` reads ADRs, focuses on third-party credential verification, re-runs when a new ADR adds an integration.
- `qa_setup` reads the running app's router/auth, focuses on the app's own QA harness (auth helpers, seeds), re-runs when routes or auth pipelines change.

Merging would create a god-task with two state machines, two evaluators, and two trigger conditions. The shared `.code_my_spec/qa/scripts/` directory is the only real overlap and isn't enough justification.

The naming is the real problem. `qa_integration_plan` reads as "QA infrastructure for integrations" but is actually "external-credential verification." A future rename to `integration_credentials_verified` (or similar) would make the dual-existence obvious and remove the temptation to merge. Out of scope here.

## Resolved: Empty-pipeline happy path?

Yes — first-class. A project whose ADRs reference no third-party services satisfies the requirement with no specs and no index file. `evaluate/3` returns `:valid` immediately when the integrations directory is empty. (Slight asymmetry with `code_generation`'s shebang-only script — there the artifact must exist; here absence is acceptance.)

## Resolved: Persona for this story

Bootstrap developer (primary). Re-runner (secondary). No-integrations project (tertiary).

## Open: Brittle "verified" detection

`check_verified_status/2` does `String.contains?(String.downcase(content), "verified")`. False positives include "we considered verifying" and "currently NOT verified." A tighter contract — e.g., a structured `status: verified` field detected by regex — would harden this. Logged as a known limitation; not gated by this story. Tightening would be a small follow-up that doesn't change the public contract.

## Deferred: Mocking script execution at spec-test time

BDD specs run against an in-memory env and can't actually shell out to run `verify_<name>.sh`. Scenarios in this story stay at the prompt-content + spec-metadata layer (the agent's claimed status in the spec file). Real script execution is testable later via integration tests against a real env, or a stub adapter. Out of scope for the BDD layer.

## Deferred: Re-running over an existing verified pipeline

When a re-runner's project already has every integration verified, the prompt-and-evaluate cycle effectively no-ops. Out-of-scope question: should the re-run prompt point to the existing verifications and offer to skip rather than re-prompting for credentials? Probably yes; not gated by this story.
