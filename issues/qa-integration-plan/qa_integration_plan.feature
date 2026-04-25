# Plain-text Gherkin — human review artifact.
# Produced from rules.md + examples.md via Step 7 of the Three Amigos session
# for the "Verified third-party integrations" story.
# Downstream: SexySpex generation reads this, one spex file per Rule.
#
# All Then clauses observe outcomes through the agent-facing MCP tools
# (start_task, evaluate_task) or the in-memory environment. No DB reads in
# Then steps, no reaching past the MCP boundary into module internals.
#
# Out of scope at this layer: actual execution of verify_<name>.sh. Specs
# assert on prompt instructions and on the spec metadata the agent claims
# to have written. Real script execution is covered later by integration
# tests against a real environment.

Feature: Verified third-party integrations
  As a developer bootstrapping a CodeMySpec project with third-party integrations
  I want the agent to read my technical decisions, draft integration specs and credential-verify scripts, gather credentials, and prove the credentials work
  So that my project's external connections are verified before code generation depends on them — and a missing or wrong credential surfaces during planning, not at runtime

  Background:
    Given a project "MyApp" with qa_integration_plan as the current requirement
    And a task exists for qa_integration_plan

  Rule: Integration specs are derived from technical decisions

    Scenario: Bootstrap developer with a Twilio ADR sees a prompt that points at the integrations directory
      Given a decision record for twilio exists in .code_my_spec/architecture/decisions/
      When the agent calls start_task for the qa_integration_plan task
      Then the returned prompt contains the path .code_my_spec/integrations/
      And the returned prompt instructs writing one integration spec per identified third-party service
      And the returned prompt names twilio in its Technical Decisions section

    Scenario: Project with no decision records points the agent back at technical_strategy and offers an empty index
      Given the project has no decision records on disk
      When the agent calls start_task for the qa_integration_plan task
      Then the returned prompt names technical_strategy as the upstream step
      And the returned prompt offers writing an empty integration index when no integrations are needed

  Rule: Each integration carries a runnable verify script

    Scenario: Prompt names the verify-script path and JSON output contract for every integration
      When the agent calls start_task for the qa_integration_plan task
      Then the returned prompt names the path pattern .code_my_spec/qa/scripts/verify_{name}.sh
      And the returned prompt instructs the script to read credentials from environment variables
      And the returned prompt names the JSON success contract with status "ok"
      And the returned prompt names the JSON failure contract with status "error"

    Scenario: OAuth2 integrations trigger an additional token-exchange script instruction
      When the agent calls start_task for the qa_integration_plan task
      Then the returned prompt names the OAuth2-only path pattern .code_my_spec/qa/scripts/exchange_{name}_token.sh

  Rule: Spec status moves from `pending` to `verified` only after successful credential verification

    Scenario: Prompt instructs initial pending status and verified-on-success promotion
      When the agent calls start_task for the qa_integration_plan task
      Then the returned prompt instructs setting initial spec status to "pending"
      And the returned prompt instructs promoting status to "verified" only after the verify script reports success

  Rule: Validation gates on the integration index plus per-spec verification

    Scenario: No integration specs and no index passes evaluation as the empty-pipeline path
      Given the agent has completed the work and start_task has already run for qa_integration_plan
      And the project has no integration specs on disk
      And no .code_my_spec/integrations.md index exists
      When the agent calls evaluate_task for the qa_integration_plan task
      Then the tool response indicates the task passed

    Scenario: Specs exist but the index is missing yields needs-work feedback referencing the index path
      Given the agent has completed the work and start_task has already run for qa_integration_plan
      And one verified integration spec exists for twilio
      And no .code_my_spec/integrations.md index exists
      When the agent calls evaluate_task for the qa_integration_plan task
      Then the tool response indicates the task needs more work
      And the response feedback contains the integration index path

    Scenario: A spec without a Verify Script section yields needs-work naming the spec
      Given the agent has completed the work and start_task has already run for qa_integration_plan
      And an integration spec for twilio exists without a Verify Script section
      And the integration index exists
      When the agent calls evaluate_task for the qa_integration_plan task
      Then the tool response indicates the task needs more work
      And the response feedback names twilio as the offending spec

    Scenario: Verified spec plus index passes evaluation
      Given the agent has completed the work and start_task has already run for qa_integration_plan
      And one integration spec for twilio exists with a Verify Script section and verified status
      And a verify script exists at .code_my_spec/qa/scripts/verify_twilio.sh
      And the integration index exists
      When the agent calls evaluate_task for the qa_integration_plan task
      Then the tool response indicates the task passed

    Scenario: Spec missing the verified status yields needs-work naming the spec
      Given the agent has completed the work and start_task has already run for qa_integration_plan
      And one integration spec for twilio exists with a Verify Script section but pending status
      And a verify script exists at .code_my_spec/qa/scripts/verify_twilio.sh
      And the integration index exists
      When the agent calls evaluate_task for the qa_integration_plan task
      Then the tool response indicates the task needs more work
      And the response feedback names twilio as not yet verified

  Rule: The prompt grounds itself in real project state

    Scenario: Bare project produces a minimal prompt without optional sections
      Given the project has no integration specs on disk
      And no .code_my_spec/integrations.md index exists
      When the agent calls start_task for the qa_integration_plan task
      Then the returned prompt does not contain an "Existing Integration Specs" section
      And the returned prompt does not contain an "Existing Index" section

    Scenario: Re-runner project's prompt surfaces existing specs and index for update guidance
      Given an integration spec for twilio already exists
      And a .code_my_spec/integrations.md index already exists
      When the agent calls start_task for the qa_integration_plan task
      Then the returned prompt contains an "Existing Integration Specs" section listing twilio
      And the returned prompt contains an "Existing Index" section
      And the returned prompt instructs updating rather than recreating
