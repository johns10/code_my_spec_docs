# Plain-text Gherkin — human review artifact.
# Produced from rules + examples via Step 7 of the Three Amigos session for Story 80.
# Downstream: SexySpex generation reads this, one spex file per Rule or Scenario group.
#
# All Then clauses observe outcomes through the agent-facing MCP tools
# (start_task, evaluate_task) or the filesystem. No DB reads in Then steps,
# no reaching past the MCP boundary into module internals.

Feature: Architecture Decision Records
  As a developer starting a CodeMySpec project
  I want ADRs for the standard stack auto-generated and the agent to guide me through project-specific decisions
  So that every technology choice has a traceable record with context, options, and tradeoffs from day one

  Background:
    Given a project "MyApp" with technical_strategy as the current requirement
    And a task exists for technical_strategy

  Rule: Pre-made decisions for the standard stack are auto-written before the prompt

    Scenario: Bootstrap developer sees the core stack ADRs after running the phase
      Given the project has no decision files on disk
      When the agent calls start_task for the technical_strategy task
      Then an ADR file exists at .code_my_spec/architecture/decisions/elixir.md
      And an ADR file exists at .code_my_spec/architecture/decisions/phoenix.md
      And an ADR file exists at .code_my_spec/architecture/decisions/liveview.md
      And an ADR file exists at .code_my_spec/architecture/decisions/tailwind.md
      And an ADR file exists at .code_my_spec/architecture/decisions/daisyui.md

    Scenario: Partially-setup project fills in only the pre-made ADRs it was missing
      Given .code_my_spec/architecture/decisions/elixir.md already exists with content "custom elixir rationale"
      And .code_my_spec/architecture/decisions/phoenix.md does not exist
      When the agent calls start_task for the technical_strategy task
      Then .code_my_spec/architecture/decisions/phoenix.md exists
      And .code_my_spec/architecture/decisions/elixir.md still contains "custom elixir rationale"

  Rule: Pre-existing ADR files are never overwritten

    Scenario: Retrofit developer's customized phoenix.md survives the auto-write pass
      Given .code_my_spec/architecture/decisions/phoenix.md exists with content "We chose Phoenix because of internal expertise"
      When the agent calls start_task for the technical_strategy task
      Then .code_my_spec/architecture/decisions/phoenix.md still contains "We chose Phoenix because of internal expertise"

  Rule: The phase adapts to the project's current state

    Scenario: Bare project produces a minimal prompt with only pre-made context
      Given the project has no components
      And mix.exs does not exist in the project root
      And the project has no stories
      When the agent calls start_task for the technical_strategy task
      Then the returned prompt does not contain an "Architecture Overview" section
      And the returned prompt does not contain a "Current Dependencies" section
      And the returned prompt does not contain a "User Stories" section
      And the returned prompt contains an "Existing Decisions" section listing the pre-made topics

    Scenario: Populated project's prompt includes architecture, deps, and story context
      Given the project has at least one component
      And mix.exs exists in the project root
      And the project has a story titled "Fleet manager suspends a driver card"
      When the agent calls start_task for the technical_strategy task
      Then the returned prompt contains an "Architecture Overview" section
      And the returned prompt contains a "Current Dependencies" section
      And the returned prompt contains a "User Stories" section
      And the returned prompt contains the story title "Fleet manager suspends a driver card"

  Rule: The prompt walks the agent through the full decision workflow

    Scenario: Prompt lays out identify, research, ADR, update index, stop
      When the agent calls start_task for the technical_strategy task
      Then the returned prompt instructs the agent to identify topics needing decisions
      And the returned prompt instructs the agent to write ADRs under .code_my_spec/architecture/decisions/
      And the returned prompt instructs the agent to update the decisions index at .code_my_spec/architecture/decisions.md
      And the returned prompt instructs the agent to stop after completing the work

  Rule: Validation gates on the decisions index

    Scenario: Evaluate passes when the decisions index exists
      Given the agent has completed the work and start_task has already run for technical_strategy
      And .code_my_spec/architecture/decisions.md exists
      When the agent calls evaluate_task for the technical_strategy task
      Then the tool response indicates the task passed

    Scenario: Missing decisions index yields needs-work feedback referencing the expected path
      Given the agent has completed the work and start_task has already run for technical_strategy
      And .code_my_spec/architecture/decisions.md does not exist
      When the agent calls evaluate_task for the technical_strategy task
      Then the tool response indicates the task needs more work
      And the response feedback contains the string ".code_my_spec/architecture/decisions.md"
