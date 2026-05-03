# Plain-text Gherkin — human review artifact.
# Produced from rules.md + examples.md via Step 7 of the Three Amigos session.
# Downstream: SexySpex generation reads this, one spex file per Rule or Scenario group.
#
# Idioms used in Given clauses:
#   "X is satisfied"            — checker passed AND the chain above X is clean
#   "X is vacuously satisfied"  — checker passed but at least one prerequisite is unsatisfied
#   "X is unsatisfied"          — checker did not pass
# All Then clauses observe outcomes through next_actionable / compute_graph return values.

Feature: Next Actionable Requirement
  As the agent
  I want the harness to return the next actionable wave plus a remaining count
  So that I always have the right batch of work to focus on, and never thrash across sibling trees or work on vacuously-satisfied leaves

  Background:
    Given a project in account "Acme"

  Rule: Vacuously-satisfied checker results do not enable downstream work

    Scenario: Vacuously-satisfied upstream does not make a downstream node actionable
      Given component "Auth" has no test files on disk
      And "tests_passing" for "Auth" is vacuously satisfied
      And "bdd_specs_passing" for story "Login flow" has a prerequisite edge from "tests_passing" on "Auth"
      And "bdd_specs_passing" for "Login flow" is unsatisfied
      When the caller invokes next_actionable for the project
      Then "bdd_specs_passing" for "Login flow" is not in the returned wave

    Scenario: Genuinely-satisfied upstream makes the downstream node actionable
      Given "project_setup" is satisfied
      And "technical_strategy" is unsatisfied
      When the caller invokes next_actionable for the project
      Then "technical_strategy" is in the returned wave

    Scenario: A cascade of vacuously-satisfied nodes blocks every downstream dependent
      Given "project_setup" is unsatisfied
      And "technical_strategy" is vacuously satisfied
      And "code_generation" is vacuously satisfied
      And "qa_integration_plan" is unsatisfied
      When the caller invokes next_actionable for the project
      Then "project_setup" is in the returned wave
      And "qa_integration_plan" is not in the returned wave

    Scenario: Checker failure details survive graph computation
      Given "spec_valid" for component "Auth" is unsatisfied and its checker wrote details "schema mismatch on line 12"
      When the caller invokes compute_graph for the project
      Then the returned "spec_valid" node for "Auth" has details containing "schema mismatch on line 12"

    Scenario: Checker details on a vacuously-satisfied node are not overwritten
      Given "tests_passing" for component "Auth" is vacuously satisfied
      And the checker for "tests_passing" on "Auth" wrote details "no tests found"
      When the caller invokes compute_graph for the project
      Then the returned "tests_passing" node for "Auth" has details containing "no tests found"

  Rule: Actionable means unsatisfied, has a satisfied_by, and every incoming prerequisite is satisfied

    Scenario: A root node with no prerequisites and a satisfied_by is actionable
      Given a fresh project where nothing has been done
      And "project_setup" is unsatisfied with a non-nil satisfied_by
      When the caller invokes next_actionable for the project
      Then "project_setup" is in the returned wave

    Scenario: A node becomes actionable once its single prerequisite is satisfied
      Given "project_setup" is satisfied
      And "technical_strategy" is unsatisfied
      When the caller invokes next_actionable for the project
      Then "technical_strategy" is in the returned wave

    Scenario: A node whose prerequisite is only vacuously satisfied is not actionable
      Given "bdd_specs_passing" for story "Login flow" is vacuously satisfied
      And "qa_complete" for story "Login flow" is unsatisfied
      When the caller invokes next_actionable for the project
      Then "qa_complete" for "Login flow" is not in the returned wave

    Scenario: Any single unsatisfied prerequisite blocks a node
      Given "spec_file" for component "Auth" is satisfied
      And "test_file" for component "Auth" is unsatisfied
      And "implementation_file" for component "Auth" is unsatisfied
      When the caller invokes next_actionable for the project
      Then "implementation_file" for "Auth" is not in the returned wave

    Scenario: A node with satisfied_by nil is filtered
      Given a requirement with satisfied_by nil exists in the graph
      And its checker is unsatisfied
      And every one of its prerequisites is satisfied
      When the caller invokes next_actionable for the project
      Then that requirement is not in the returned wave

    Scenario: An already-satisfied node is not actionable
      Given "project_setup" is satisfied
      When the caller invokes next_actionable for the project
      Then "project_setup" is not in the returned wave

  Rule: next_actionable returns one wave plus a remaining count

    Scenario: Single actionable node returns a one-element wave
      Given "project_setup" is satisfied
      And "technical_strategy" is unsatisfied with prereqs green
      And no other actionable nodes exist
      When the caller invokes next_actionable for the project
      Then the return value is {:ready, %{wave: [technical_strategy], remaining_count: 0}}

    Scenario: Component fan-out returns a multi-element wave
      Given story "Auth" is past prep and its context "Users" has five child component specs all actionable
      And no other waves are surfaced ahead of this one
      When the caller invokes next_actionable for the project
      Then the returned wave contains all five "Users" child component spec nodes
      And remaining_count reflects every actionable node queued behind that wave

    Scenario: Blocked state when nothing is actionable but unsatisfied work remains
      Given the graph has unsatisfied requirements
      And for each unsatisfied requirement, at least one prerequisite is unsatisfied or only vacuously satisfied
      When the caller invokes next_actionable for the project
      Then the return value is :blocked

    Scenario: All done when every requirement is satisfied
      Given every requirement in the graph is satisfied
      When the caller invokes next_actionable for the project
      Then the return value is :all_done

    Scenario: Fresh project returns project_setup as a single-element wave
      Given a newly-initialized project with nothing yet done
      When the caller invokes next_actionable for the project
      Then the return value is {:ready, %{wave: [project_setup], remaining_count: 0}}

    Scenario: Cross-story spillover is excluded from the wave
      Given story "Auth" is priority 1 with one actionable component spec
      And story "Reports" is priority 2 with three actionable component specs
      When the caller invokes next_actionable for the project
      Then the returned wave contains only "Auth"'s actionable nodes
      And remaining_count includes "Reports"'s three actionable nodes

  Rule: Project work leads when actionable

    Scenario: Project node beats simultaneously-actionable story node
      Given project "code_generation" is actionable
      And story "Auth"'s "bdd_specs_exist" is also actionable
      When the caller invokes next_actionable for the project
      Then the returned wave contains "code_generation"
      And it does not contain "bdd_specs_exist"

    Scenario: Project node preempts a story chain mid-flight
      Given story "Auth" is mid-flight on its component implementation wave
      And project "all_bdd_specs_passing" becomes actionable on the next call
      When the caller invokes next_actionable for the project
      Then the returned wave contains "all_bdd_specs_passing"
      And no "Auth" component nodes appear in the wave

    Scenario: No project nodes actionable, story leads
      Given no project-level node is actionable
      And story "Auth" is the leading actionable story
      When the caller invokes next_actionable for the project
      Then the returned wave is taken from "Auth"'s chain

    Scenario: Fresh project's only actionable node is project-level
      Given a fresh project where only "project_setup" is actionable
      When the caller invokes next_actionable for the project
      Then the returned wave is exactly [project_setup]
      And remaining_count is 0

  Rule: Stories sort by priority, components inherit through the projector

    Scenario: Lower priority number leads
      Given story "Auth" is priority 1 with components actionable
      And story "Reports" is priority 5 with components actionable
      When the caller invokes next_actionable for the project
      Then the returned wave is taken from "Auth"

    Scenario: Same story priority, oldest created_at wins
      Given stories "Auth" and "Billing" are both priority 1
      And "Auth"'s created_at is earlier than "Billing"'s
      And both have actionable component specs
      When the caller invokes next_actionable for the project
      Then the returned wave is taken from "Auth"

    Scenario: Surface dependency inherits its dependent story's priority
      Given component "EmailSender" is a dependency of surface component "Auth"
      And story "Auth" links to surface "Auth" with priority 1
      When the caller invokes next_actionable for the project
      Then "EmailSender"'s actionable nodes carry inherited priority 1

    Scenario: Parent-chain inheritance
      Given component "AuthEvents" has parent_component_id pointing to "Auth"
      And "Auth" is linked to a priority-1 story
      When the caller invokes next_actionable for the project
      Then "AuthEvents"'s actionable nodes carry inherited priority 1

    Scenario: Components with no inherited priority sort last
      Given component "Standalone" has no story link, no dependency-of relationship, and no parent-chain priority
      And its spec_file is actionable alongside priority-1 component nodes
      When the caller invokes next_actionable for the project
      Then "Standalone" is not in the returned wave
      And "Standalone" is counted in remaining_count

  Rule: One orchestrated tree at a time

    Scenario: Sibling bounded contexts serialize in dependency order
      Given story "Auth" spans contexts "Users", "Sessions", "Tokens"
      And the projector's dependency order is "Users" → "Sessions" → "Tokens"
      And story prep is complete
      When the caller invokes next_actionable for the project
      Then the returned wave contains only "Users" context's nodes
      And no "Sessions" or "Tokens" nodes are in the wave

    Scenario: Children within one context fan out as one wave
      Given context "Users" has parent spec satisfied
      And four child component specs in "Users" are all actionable
      When the caller invokes next_actionable for the project
      Then the returned wave contains all four "Users" children together

    Scenario: Next sibling context begins only after the previous completes
      Given context "Users" was the leading wave on the previous call
      And every "Users" node is now satisfied
      And context "Sessions" is the next in dependency order
      When the caller invokes next_actionable for the project
      Then the returned wave is taken from "Sessions"

    Scenario: Parent review phase surfaces alone after children are valid
      Given context "Users" has all child spec_valid satisfied
      And the parent review_file is actionable
      And no other nodes share the parent's sort key
      When the caller invokes next_actionable for the project
      Then the returned wave is exactly [Users.review_file]

    Scenario: Hypothetical sibling project tracks would also serialize
      Given two project-level orchestrated trees are simultaneously actionable
      When the caller invokes next_actionable for the project
      Then the returned wave is taken from one tree only
      And the other tree's nodes are counted in remaining_count

  Rule: Every returned node carries its orchestration metadata

    Scenario: Sub-agent children carry orchestrator and validation type
      Given a wave of five child component specs is returned
      When the caller inspects each node
      Then each node has execution_type :sub_agent
      And each node has orchestrated_by :develop_context
      And each node has validation_type :automatic

    Scenario: Manual-validation node is tagged accordingly
      Given "three_amigos_complete" is the surfaced node
      When the caller inspects it
      Then it has validation_type :manual

    Scenario: Top-level project node carries main-agent metadata
      Given "project_setup" is the surfaced node
      When the caller inspects it
      Then it has execution_type :main_agent
      And it has no orchestrated_by parent

  Rule: Graph computation raises when satisfied_by references a missing module

    Scenario: Reference to a deleted module raises at graph computation
      Given a requirement definition with satisfied_by AgentTasks.DeletedThing
      And AgentTasks.DeletedThing has been removed from the codebase
      When compute_graph runs for the project
      Then the call raises
      And the error message names "AgentTasks.DeletedThing"
      And the error message names the requirement that referenced it

    Scenario: Existing module resolves without raising
      Given a requirement definition with satisfied_by AgentTasks.ComponentSpec
      And AgentTasks.ComponentSpec is loaded
      When compute_graph runs for the project
      Then no exception is raised

    Scenario: Rename without updating the template fails on the next graph call
      Given AgentTasks.OldName has been renamed to AgentTasks.NewName in the codebase
      And a requirement definition still references satisfied_by AgentTasks.OldName
      When compute_graph or next_actionable runs
      Then the call raises naming AgentTasks.OldName as missing
