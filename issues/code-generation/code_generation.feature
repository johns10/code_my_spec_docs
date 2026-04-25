# Plain-text Gherkin — human review artifact.
# Produced from rules + examples via Step 7 of the Three Amigos session for
# the "Standard stack code generation" story.
# Downstream: SexySpex generation reads this, one spex file per Rule.
#
# All Then clauses observe outcomes through the agent-facing MCP tools
# (start_task, evaluate_task) or the filesystem. No DB reads in Then steps,
# no reaching past the MCP boundary into module internals.
#
# ⚠️  Rule 6 specifies a behavior CHANGE from the current implementation:
#     `build_existing_artifact_section` currently says "append any new
#     commands you run." Scenarios under Rule 6 expect the agent to be
#     told to rewrite the script from currently-detected state and
#     confirm with the user before overwriting an existing script.

Feature: Standard stack code generation
  As a developer bootstrapping a CodeMySpec project
  I want the agent to run the standard generators (auth, accounts, integrations, feedback widget) in the right order, verify the scaffold compiles and migrates cleanly, and record the commands in a re-runnable shell script
  So that my project gets the standard scaffolding without me memorizing the sequence and the scaffold can be reproduced on a fresh checkout

  Background:
    Given a project "MyApp" with code_generation as the current requirement
    And a task exists for code_generation

  Rule: Generators run in dependency order with detection-based skipping

    Scenario: Bootstrap developer's prompt lists every standard generator as pending, in order
      Given the project has no generator detection files on disk
      When the agent calls start_task for the code_generation task
      Then the returned prompt lists `mix phx.gen.auth Users User users --live` as pending
      And the returned prompt lists `mix cms_gen.accounts` as pending after phx.gen.auth
      And the returned prompt lists `mix cms_gen.integrations` as pending after cms_gen.accounts
      And the returned prompt lists `mix cms_gen.feedback_widget` as pending after cms_gen.integrations

    Scenario: Retrofit project with phx.gen.auth already applied checks off auth and lists the rest as pending
      Given the file lib/my_app/users/scope.ex exists in the project
      When the agent calls start_task for the code_generation task
      Then the returned prompt marks `mix phx.gen.auth Users User users --live` as already run
      And the returned prompt lists `mix cms_gen.accounts` as the next pending generator

    Scenario: Project with every standard generator already applied signals all generators have run
      Given lib/my_app/users/scope.ex exists in the project
      And lib/my_app/accounts/account.ex exists in the project
      And lib/my_app/integrations/integration.ex exists in the project
      And lib/my_app_web/live/feedback_widget.ex exists in the project
      When the agent calls start_task for the code_generation task
      Then the returned prompt indicates that all standard generators have already been run

  Rule: The prompt is grounded in real project state

    Scenario: Bootstrap project with no ADRs, no script, and no integrations yields a minimal prompt
      Given the project has no decision records on disk
      And no code_generation.sh exists in the project
      And the project has no integration specs on disk
      When the agent calls start_task for the code_generation task
      Then the returned prompt does not contain an "Existing Generation Script" section
      And the returned prompt does not contain an "Integration Providers" section
      And the returned prompt's Technical Decisions section indicates no decision records were found

    Scenario: Fully-populated project's prompt includes decisions, providers, and existing-script sections
      Given decision records exist for elixir, phoenix, and pow-assent-integrations
      And an existing code_generation.sh is present in the project
      And integration specs exist for github and google
      When the agent calls start_task for the code_generation task
      Then the returned prompt's Technical Decisions section names elixir, phoenix, and pow-assent-integrations
      And the returned prompt contains an "Existing Generation Script" section
      And the returned prompt contains an "Integration Providers" section

  Rule: Integration providers come from the integrations directory

    Scenario: Two integration specs surface as cms_gen.integration_provider invocations
      Given integration specs exist for github and google
      When the agent calls start_task for the code_generation task
      Then the returned prompt names github as a provider to scaffold
      And the returned prompt names google as a provider to scaffold
      And the returned prompt instructs the agent to run `mix cms_gen.integration_provider` for each provider

    Scenario: Project with no integration specs omits the Integration Providers section
      Given the project has no integration specs on disk
      When the agent calls start_task for the code_generation task
      Then the returned prompt does not contain an "Integration Providers" section

  Rule: The scaffold must land clean before completion

    Scenario: Prompt instructs the agent to run deps.get, compile, migrate, and test after generators
      When the agent calls start_task for the code_generation task
      Then the returned prompt instructs the agent to run `mix deps.get`
      And the returned prompt instructs the agent to run `mix compile`
      And the returned prompt instructs the agent to run `mix ecto.migrate`
      And the returned prompt instructs the agent to run `mix test`

  Rule: The generation script is the durable artifact

    Scenario: Non-empty generation script passes evaluation
      Given the agent has completed the work and start_task has already run for code_generation
      And .code_my_spec/tasks/code_generation.sh contains the recorded generator commands
      When the agent calls evaluate_task for the code_generation task
      Then the tool response indicates the task passed

    Scenario: Minimal-project shebang-only script is accepted as valid
      Given the agent has completed the work and start_task has already run for code_generation
      And .code_my_spec/tasks/code_generation.sh contains only a shebang and a "no generators needed" comment
      When the agent calls evaluate_task for the code_generation task
      Then the tool response indicates the task passed

    Scenario: Missing generation script yields needs-work feedback referencing the expected path
      Given the agent has completed the work and start_task has already run for code_generation
      And .code_my_spec/tasks/code_generation.sh does not exist
      When the agent calls evaluate_task for the code_generation task
      Then the tool response indicates the task needs more work
      And the response feedback contains the string ".code_my_spec/tasks/code_generation.sh"

  Rule: Retrofit script is rewritten from the currently-detected state

    Scenario: Prompt instructs the agent to rewrite the script from currently-detected state
      When the agent calls start_task for the code_generation task
      Then the returned prompt instructs the agent to rewrite the script from the currently-detected state
      And the returned prompt does not instruct the agent to append commands to an existing script

    Scenario: Existing script triggers a confirmation step before overwrite
      Given an existing code_generation.sh is present in the project
      When the agent calls start_task for the code_generation task
      Then the returned prompt names the existing code_generation.sh path
      And the returned prompt instructs the agent to confirm with the user before overwriting the existing script
