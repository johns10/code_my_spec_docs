# Plain-text Gherkin — human review artifact.
# Produced from rules.md + examples.md via Step 7 of the Three Amigos session.
# Downstream: SexySpex generation reads this, one spex file per Rule or Scenario group.
#
# Idioms used in Given clauses:
#   "X is satisfied"            — checker passed AND the chain above X is clean
#   "X is vacuously satisfied"  — checker passed but at least one prerequisite is unsatisfied
#   "X is unsatisfied"          — checker did not pass
# All Then clauses observe outcomes through next_actionable/compute_graph return values.

Feature: Next Actionable Requirement
  As the agent
  I want the harness to return the next actionable requirement
  So that I always have exactly one correct thing to work on and can't accidentally work on vacuously-satisfied leaves

  Background:
    Given a project in account "Acme"

  Rule: Vacuously-satisfied checker results do not enable downstream work

    Scenario: Vacuously-satisfied upstream does not make a downstream node actionable
      Given component "Auth" has no test files on disk
      And "tests_passing" for "Auth" is vacuously satisfied
      And "bdd_specs_passing" for story "Login flow" has a prerequisite edge from "tests_passing" on "Auth"
      And "bdd_specs_passing" for "Login flow" is unsatisfied
      When the caller invokes next_actionable for the project
      Then "bdd_specs_passing" for "Login flow" is not in the returned ready list

    Scenario: Genuinely-satisfied upstream makes the downstream node actionable
      Given "project_setup" is satisfied
      And "technical_strategy" is unsatisfied
      When the caller invokes next_actionable for the project
      Then "technical_strategy" is in the returned ready list

    Scenario: A cascade of vacuously-satisfied nodes blocks every downstream dependent
      Given "project_setup" is unsatisfied
      And "technical_strategy" is vacuously satisfied
      And "code_generation" is vacuously satisfied
      And "qa_integration_plan" is unsatisfied
      When the caller invokes next_actionable for the project
      Then "project_setup" is in the returned ready list
      And "qa_integration_plan" is not in the returned ready list

    Scenario: Checker failure details survive graph computation
      Given "spec_valid" for component "Auth" is unsatisfied and its checker wrote details "schema mismatch on line 12"
      When the caller invokes compute_graph for the project
      Then the returned "spec_valid" node for "Auth" has details containing "schema mismatch on line 12"

    Scenario: Checker details on a vacuously-satisfied node are not overwritten
      Given "tests_passing" for component "Auth" is vacuously satisfied
      And the checker for "tests_passing" on "Auth" wrote details "no tests found"
      When the caller invokes compute_graph for the project
      Then the returned "tests_passing" node for "Auth" has details containing "no tests found"

  Rule: Actionable means unsatisfied and every incoming prerequisite is satisfied

    Scenario: A root node with no prerequisites is actionable
      Given a fresh project where nothing has been done
      And "project_setup" is unsatisfied
      When the caller invokes next_actionable for the project
      Then "project_setup" is in the returned ready list

    Scenario: A node becomes actionable once its single prerequisite is satisfied
      Given "project_setup" is satisfied
      And "technical_strategy" is unsatisfied
      When the caller invokes next_actionable for the project
      Then "technical_strategy" is in the returned ready list

    Scenario: A node whose prerequisite is only vacuously satisfied is not actionable
      Given "bdd_specs_passing" for story "Login flow" is vacuously satisfied
      And "qa_complete" for story "Login flow" is unsatisfied
      When the caller invokes next_actionable for the project
      Then "qa_complete" for "Login flow" is not in the returned ready list

    Scenario: Any single unsatisfied prerequisite blocks a node
      Given "spec_file" for component "Auth" is satisfied
      And "test_file" for component "Auth" is unsatisfied
      And "implementation_file" for component "Auth" is unsatisfied
      When the caller invokes next_actionable for the project
      Then "implementation_file" for "Auth" is not in the returned ready list

    Scenario: An already-satisfied node is not actionable
      Given "project_setup" is satisfied
      When the caller invokes next_actionable for the project
      Then "project_setup" is not in the returned ready list

  Rule: Actionable results are sorted by story priority, tiebroken by oldest entity created_at

    Scenario: Lower priority number sorts first
      Given component "Auth" is linked to a story with priority 1
      And component "Reports" is linked to a story with priority 5
      And "spec_file" on each component is unsatisfied
      When the caller invokes next_actionable for the project
      Then "spec_file" for "Auth" appears before "spec_file" for "Reports" in the returned ready list

    Scenario: Same inherited priority, older story wins the tiebreak
      Given component "Auth" is linked to a story with priority 1 created at T1
      And component "Billing" is linked to a different story with priority 1 created at T2
      And T1 is earlier than T2
      And "spec_file" on each component is unsatisfied
      When the caller invokes next_actionable for the project
      Then "spec_file" for "Auth" appears before "spec_file" for "Billing" in the returned ready list

    Scenario: Same story and priority, older component wins the tiebreak
      Given components "Auth" and "Billing" are both linked to the same story with priority 1
      And "Auth" was created before "Billing"
      And "spec_file" on each component is unsatisfied
      When the caller invokes next_actionable for the project
      Then "spec_file" for "Auth" appears before "spec_file" for "Billing" in the returned ready list

    Scenario: Nodes with no inherited priority sort last
      Given component "Auth" is linked to a story with priority 1 with an actionable "spec_file"
      And project-level "qa_preflight" is actionable
      When the caller invokes next_actionable for the project
      Then "spec_file" for "Auth" appears before "qa_preflight" in the returned ready list

  Rule: Return distinguishes ready, blocked, and all-done

    Scenario: Ready state returns actionable nodes in priority order
      Given "spec_file" is actionable on components "Auth", "Billing", "Reports"
      And "Auth" is driven by a priority-1 story, "Billing" by a priority-2 story, "Reports" by a priority-3 story
      When the caller invokes next_actionable for the project
      Then the return value is {:ready, [spec_file-on-Auth, spec_file-on-Billing, spec_file-on-Reports]}

    Scenario: Unsatisfied work exists but no candidate has all prerequisites genuinely satisfied
      Given the graph has unsatisfied requirements
      And for each unsatisfied requirement, at least one prerequisite is unsatisfied or only vacuously satisfied
      When the caller invokes next_actionable for the project
      Then the return value is :blocked

    Scenario: Graph is fully satisfied
      Given every requirement in the graph is satisfied
      When the caller invokes next_actionable for the project
      Then the return value is :all_done

    Scenario: Fresh project returns project_setup as ready
      Given a newly-initialized project with nothing yet done
      When the caller invokes next_actionable for the project
      Then the return value is {:ready, [project_setup]}

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
