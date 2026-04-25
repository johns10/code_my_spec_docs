# QA Integration Plan — Examples

## Rule: Integration specs are derived from technical decisions

- Bootstrap dev's project has a Twilio ADR, prompt instructs writing an integration spec at `.code_my_spec/integrations/twilio.md`
- Project has no decision records, prompt points the agent at `technical_strategy` and offers writing an empty integration index instead

## Rule: Each integration carries a runnable verify script

- Prompt instructs writing `verify_<name>.sh` and naming the JSON-on-stdout success/failure contract for every identified integration
- OAuth2 integration triggers an additional `exchange_<name>_token.sh` instruction in the prompt

## Rule: Spec status moves from `pending` to `verified` only after successful credential verification

- Prompt instructs initial spec status `pending` and explicit promotion to `verified` only after a successful verify-script run

## Rule: Validation gates on the integration index plus per-spec verification

- Project with no integration specs and no index file, evaluate returns valid (empty pipeline)
- Project has integration specs but no `integrations.md` index, evaluate returns invalid naming the index path in feedback
- A spec exists without a `## Verify Script` section, evaluate returns invalid naming the spec file
- A spec's status text contains "verified" and the index is present, evaluate returns valid
- A spec is missing the verified status, evaluate returns invalid naming the spec

## Rule: The prompt grounds itself in real project state

- Bare project (no specs, no index, no decisions) produces a prompt without "Existing Integration Specs" or "Existing Index" sections
- Re-runner project (specs and index already present) produces a prompt with both sections so the agent updates rather than recreates
