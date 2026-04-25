# Plain-text Gherkin — human review artifact.
# Produced from rules.md + examples.md as the Step 7 output of the Three Amigos session.
# Source of truth at impl time is the DB (Rule + Criterion + Question rows on the story).
# Downstream: SexySpex generation reads from the DB via MCP, not from this file.

Feature: Three Amigos
  As a product manager
  I want to run the three amigos process with an agent
  So that I develop my BDD specifications without having to write Gherkin myself

  Background:
    Given an account "Acme"
    And a project "Product X" in account "Acme" with project_setup satisfied

  Rule: Three Amigos is graph-dispatched per story; story is fixed input

    Scenario: Graph surfaces three_amigos_complete for a new story without AC
      Given a story "S1" in project "Product X" with no acceptance criteria
      When the agent calls get_next_requirement for the project
      Then the returned requirement is three_amigos_complete
      And the requirement is scoped to story "S1"
      And the requirement's prerequisites are satisfied

    Scenario: Agent receives a Three Amigos task for a specific story
      Given a story "S1" in project "Product X" with no acceptance criteria
      When the agent calls start_task for three_amigos_complete on "S1"
      Then the returned prompt names story "S1"
      And the returned prompt instructs the agent to call the knowledge MCP for protocol guidance
      And the returned prompt enumerates the available MCP tools

    Scenario: Deleting all criteria re-dispatches Three Amigos
      Given a story "S2" with three acceptance criteria
      And three_amigos_complete for "S2" was previously satisfied
      When the PM deletes every criterion on "S2"
      Then get_next_requirement for the project returns three_amigos_complete scoped to "S2"

    Scenario: Story with at least one criterion does not dispatch Three Amigos
      Given a story "S3" with one acceptance criterion
      When the agent calls get_next_requirement for the project
      Then three_amigos_complete for "S3" is not returned

    Scenario: Story description is fixed during the session
      Given an active Three Amigos session on story "S4"
      When the PM attempts to update story "S4"'s description
      Then the update is rejected
      And the rejection message instructs the PM to abandon the session and re-run story_interview

  Rule: Protocol ordering is enforced

    Scenario: Agent walks the protocol in order
      Given a Three Amigos session has just started on story "S1"
      When the agent processes its first turn
      Then the agent's first action is to confirm or trigger persona linkage
      And the agent does not call add_rule before persona linkage is complete
      And the agent does not call add_scenario before any rule exists

    Scenario: Agent links a persona before asking for rules
      Given a Three Amigos session on story "S1"
      And persona "fleet_manager" exists in account "Acme"'s persona library
      When the agent begins the session
      Then the agent calls link_persona for "fleet_manager" and "S1"
      And only then does the agent ask the PM to articulate the first rule

    Scenario: Agent declines when the PM asks to skip ahead
      Given an active Three Amigos session on story "S1" with no rules added
      When the PM instructs the agent to skip ahead and just write the scenarios
      Then the agent does not call add_scenario
      And the agent's response prompts the PM for rules first

    Scenario: add_scenario rejects when no rule exists
      Given a Three Amigos session on story "S1" with no rules added
      When the agent calls add_scenario
      Then the MCP tool returns a validation error
      And no Criterion record is created

    Scenario: Scenario title and Gherkin body are written in one MCP call
      Given a Three Amigos session on story "S1" with rule "R1" added
      When the agent calls add_scenario with title and body for rule "R1"
      Then a Criterion is created with both description and body populated in one operation
      And no separate name-then-body call is required

  Rule: Persona linkage required

    Scenario: Agent links an existing suitable persona
      Given a Three Amigos session on story "S1"
      And persona "fleet_manager" exists in account "Acme"'s persona library
      When the agent identifies "fleet_manager" as the relevant persona
      Then the agent calls link_persona for "fleet_manager" and "S1"
      And a persona_stories row exists linking "fleet_manager" to "S1"

    Scenario: Agent creates a lightweight persona inline when none exists
      Given a Three Amigos session on story "S2"
      And no suitable persona exists in account "Acme"'s persona library
      When the agent identifies a needed persona
      Then the agent calls add_persona with identity and metadata only
      And a new persona record is created in account "Acme" without research artifacts
      And the agent calls link_persona for the new persona and "S2"

    Scenario: Agent links multiple personas covering distinct roles
      Given a Three Amigos session on story "S3" describing both fleet manager and driver behavior
      When the agent processes the rules
      Then the agent calls link_persona for "fleet_manager" and "S3"
      And the agent calls link_persona for "driver" and "S3"
      And two persona_stories rows exist for "S3"

    Scenario: Three Amigos creates a lightweight persona; persona research surfaces next
      Given the agent has just received a Three Amigos task for story "S4"
      And no suitable persona exists in account "Acme"'s persona library
      When the agent calls add_persona with identity and metadata for persona "ops_lead"
      And the agent calls link_persona for "ops_lead" and "S4"
      And the agent populates "S4" with rules and scenarios meeting the readiness gate
      And the agent fires the stop hook for the Three Amigos task
      Then the Three Amigos task evaluates as complete
      And the next get_next_requirement returns personas_complete
      And the failure detail names "ops_lead" as missing summary.md and sources.md

    Scenario: add_rule rejects when no persona is linked to the story
      Given a Three Amigos session on story "S5" with no personas linked
      When the agent calls add_rule
      Then the MCP tool returns a validation error
      And no Rule record is created

  Rule: Each rule needs at least one happy-path and one failure-path scenario

    Scenario: Agent generates happy and failure for every rule
      Given a Three Amigos session on story "S1" with persona linked
      When the PM dictates rule "Suspension takes effect immediately"
      Then the agent calls add_scenario with kind happy_path for that rule
      And the agent calls add_scenario with kind failure_path for that rule

    Scenario: Agent surfaces failure paths even when PM only volunteers happy
      Given a Three Amigos session on story "S2" with rule "Driver receives notification" added
      And the PM has only volunteered happy-path scenarios for that rule
      When the agent processes the rule
      Then the agent proposes a failure-path scenario for the rule unprompted
      And the agent asks the PM to confirm or refine the proposed failure path

    Scenario: Agent prompts the PM for failure paths after each rule
      Given a Three Amigos session on story "S3" with rule "R1" just added
      When the agent transitions to scenario generation for "R1"
      Then the agent's prompt to the PM includes a question of the form "what could go wrong here?"

    Scenario: Readiness blocks on a rule with only happy scenarios
      Given a story "S4" with rule "R1"
      And one happy-path scenario exists for "R1"
      And zero failure-path scenarios exist for "R1"
      When the agent runs the readiness check
      Then the readiness check fails
      And the failure detail names rule "R1" as missing a failure-path scenario

    Scenario: Readiness blocks on a rule with only failure scenarios
      Given a story "S5" with rule "R1"
      And one failure-path scenario exists for "R1"
      And zero happy-path scenarios exist for "R1"
      When the agent runs the readiness check
      Then the readiness check fails
      And the failure detail names rule "R1" as missing a happy-path scenario

  Rule: Session readiness gate

    Scenario: All readiness conditions pass and the session completes
      Given a Three Amigos session on story "S1"
      And one persona is linked to "S1"
      And three rules exist for "S1" with happy and failure scenarios each
      And no questions are open on "S1"
      When the agent's evaluate runs the readiness check
      Then the check returns ok
      And the completion marker is set on "S1"
      And the next get_next_requirement for the project does not return three_amigos_complete for "S1"

    Scenario: Zero personas linked fails readiness
      Given a Three Amigos session on story "S2"
      And no personas are linked to "S2"
      When the agent's evaluate runs the readiness check
      Then the check returns invalid
      And the detail string names "persona linkage" as the failing condition

    Scenario: Zero rules fails readiness
      Given a Three Amigos session on story "S3"
      And one persona is linked to "S3"
      And zero rules exist for "S3"
      When the agent's evaluate runs the readiness check
      Then the check returns invalid
      And the detail string names "rules > 0" as the failing condition

    Scenario: Eleven rules fails readiness
      Given a Three Amigos session on story "S4"
      And one persona is linked to "S4"
      And eleven rules exist for "S4"
      When the agent's evaluate runs the readiness check
      Then the check returns invalid
      And the detail string names "rules < 10" as the failing condition
      And the detail string instructs the PM to slice the story

    Scenario: More questions than scenarios fails readiness
      Given a Three Amigos session on story "S5"
      And one persona is linked to "S5"
      And three rules exist for "S5"
      And six questions are open on "S5"
      And four scenarios exist on "S5"
      When the agent's evaluate runs the readiness check
      Then the check returns invalid
      And the detail string names "scenarios > questions" as the failing condition

    Scenario: A rule with zero scenarios fails readiness
      Given a Three Amigos session on story "S6"
      And one persona is linked to "S6"
      And rule "R1" exists for "S6"
      And rule "R1" has zero scenarios
      When the agent's evaluate runs the readiness check
      Then the check returns invalid
      And the detail string names rule "R1" as missing happy and failure scenarios

    Scenario: Multiple readiness conditions fail simultaneously
      Given a Three Amigos session on story "S7"
      And no personas are linked to "S7"
      And eleven rules exist for "S7"
      And one rule has zero scenarios
      When the agent's evaluate runs the readiness check
      Then the check returns invalid
      And the detail markdown string lists "persona linkage", "rules < 10", and the rule with zero scenarios as failing conditions
      And the stop hook surfaces the full detail string in the next turn's feedback

  Rule: Session state is a persisted domain object; PM and agent share it

    Scenario: Agent's add_rule is reflected in the PM's UI
      Given a Three Amigos session on story "S1" open in the local web UI
      When the agent calls add_rule with statement "Suspension takes effect immediately"
      Then a Rule row is inserted with statement "Suspension takes effect immediately" and story_id "S1"
      And the rule appears as a blue card in the UI within seconds

    Scenario: PM edit in UI persists and is visible to the agent
      Given a Three Amigos session on story "S2"
      And rule "R1" exists with statement "Suspension takes effect immediately"
      When the PM edits "R1"'s statement to "Suspension takes effect at end of trip" via the UI
      Then the Rule row's statement is "Suspension takes effect at end of trip"
      And on the agent's next turn list_rules for "S2" returns the updated statement

    Scenario: PM deletes a question card from the UI
      Given a Three Amigos session on story "S3"
      And question "Q1" exists for "S3"
      When the PM deletes "Q1" from the UI
      Then no Question row exists for "Q1"
      And the agent's next list_questions call for "S3" omits "Q1"

    Scenario: Page refresh preserves all session artifacts
      Given a Three Amigos session on story "S4" with three rules, six scenarios, and two questions
      When the PM refreshes the session page in the UI
      Then all three rules are still present
      And all six scenarios are still present
      And both questions are still present

    Scenario: DB write failure surfaces to agent and is invisible in UI
      Given a Three Amigos session on story "S5"
      And the database is unable to accept writes
      When the agent calls add_rule
      Then the MCP tool returns an error to the agent
      And no Rule row is inserted
      And no new card appears in the UI

  Rule: Agent operates via MCP tools

    Scenario: Task prompt enumerates available MCP tools and points to the knowledge MCP
      Given the agent calls start_task for three_amigos_complete on story "S1"
      When the returned prompt is rendered
      Then the prompt names add_rule, add_scenario, add_question, add_persona, link_persona, resolve_question, and get_story_gherkin
      And the prompt describes the contract of each tool
      And the prompt instructs the agent to call the knowledge MCP for protocol guidance

    Scenario: Successful mutation persists and is observable through the public interface
      Given a Three Amigos session on story "S2" with persona linked
      When the agent calls add_rule with a valid statement
      Then the MCP tool returns success
      And the rule is returned by the next list_rules MCP call for "S2"

    Scenario: Malformed add_rule payload returns validation error
      Given a Three Amigos session on story "S3" with persona linked
      When the agent calls add_rule with an empty statement
      Then the MCP tool returns a validation error
      And the rule does not appear in the next list_rules MCP call for "S3"
      And the validation error names the missing field

    Scenario: add_question rejects payload without required text
      Given a Three Amigos session on story "S4" with persona linked
      When the agent calls add_question with no text
      Then the MCP tool returns a validation error
      And the question does not appear in the next list_questions MCP call for "S4"

  Rule: Documentation is split — PM gets UI, agent gets knowledge MCP

    Scenario: First-time PM reads inline tooltip definition
      Given a first-time PM in the local web UI on a Three Amigos session
      When the PM hovers over a blue card with no rules yet added
      Then a tooltip appears defining "rule" in business terms
      And the tooltip is sourced from in-product documentation

    Scenario: PM reads readiness failure explanation in UI
      Given a Three Amigos session on story "S2" with a failing readiness check
      When the PM hovers over the readiness check status indicator
      Then the UI displays a short explanation of the failing condition
      And the PM can click through for the full readiness rules

    Scenario: PM follows doc link without leaving the session
      Given a Three Amigos session open in the local web UI
      When the PM clicks the "How Example Mapping works" doc link on the session page
      Then the documentation opens in a panel or new tab
      And the session state remains intact

    Scenario: Agent queries the knowledge MCP for protocol guidance
      Given a Three Amigos session is starting on story "S4"
      When the agent calls the knowledge MCP tool with a query about the Three Amigos protocol
      Then the returned chunks include scenario quality bar and readiness rule guidance
      And the agent applies that guidance during the session

    Scenario: Agent surfaces UI doc link instead of writing a tutorial
      Given a Three Amigos session on story "S5"
      And the PM asks in chat "what is a rule?"
      When the agent processes the question
      Then the agent's response points the PM to the UI tooltip or doc link for that concept
      And the agent's response does not contain a multi-paragraph tutorial about BDD
