# Plain-text Gherkin — human review artifact.
# Produced from rules.md + examples.md via Step 7 of the Three Amigos session.
# Downstream: SexySpex generation reads this, one spex file per Rule or Scenario group.

Feature: Persona Research
  As a product manager / founder
  I want to run a persona research process with an agent
  So that I build a reusable, evidence-backed persona library for my product

  Background:
    Given an account "Acme"
    And a project "Product X" in account "Acme" with project_setup satisfied

  Rule: Persona research is a graph requirement, not a setup gate

    Scenario: Graph surfaces persona research as the next actionable requirement
      Given the project has no personas linked
      When the agent calls get_next_requirement for the project
      Then the returned requirement is personas_complete
      And the requirement's only prerequisite is project_setup

    Scenario: Agent receives the persona research task mid-design
      Given the project has no personas linked
      When the agent calls start_task for personas_complete
      Then the returned prompt references priv/knowledge/persona_research/ by name
      And the returned prompt names the expected output paths under .code_my_spec/personas/<slug>/

  Rule: Stop hook dispatches the research task

    Scenario: Unsatisfied requirement resumes on the next turn
      Given personas_complete is unsatisfied
      And the agent stops mid-turn without completing a persona
      When the next turn begins
      Then get_next_requirement returns personas_complete again

    Scenario: Satisfied requirement releases the next graph node
      Given one persona with DB row + summary.md + sources.md
      When the stop hook evaluates personas_complete
      Then the node is marked satisfied
      And the next get_next_requirement returns a downstream requirement, not personas_complete

    Scenario: Delegate checker surfaces per-artifact detail through the hook
      Given personas_complete is unsatisfied because persona "founder" is missing sources.md
      When the stop hook runs PersonasChecker.complete?
      Then the feedback string names "founder"
      And the feedback string names sources.md as the missing artifact

  Rule: Conversational input from the PM

    Scenario: Agent opens with the intake question bank when the PM has no notes
      Given the PM starts a persona research session with no prior context
      When the agent receives control
      Then the agent's first output contains intake questions derived from pm_intake.md
      And no summary.md is written

    Scenario: Agent narrows its questions to the gaps when the PM supplies partial notes
      Given the PM pastes notes covering Role and Context into the session
      When the agent processes the input
      Then the agent asks about Goals, Pain Points, Decision Drivers, and Evidence
      And the agent does not re-ask about Role or Context
      And no summary.md is written

    Scenario: Agent refuses to skip the conversation
      Given the PM instructs the agent to write a persona immediately without questions
      When the agent processes the instruction
      Then the agent does not write summary.md
      And the agent returns intake questions to the PM instead

  Rule: Agent-led research with real tooling

    Scenario: Agent runs a web search once PM input is sufficient
      Given the conversation has produced a decision stake and initial hypotheses
      When the agent transitions from intake to research
      Then the agent issues web search queries
      And each cited result appears as an entry in sources.md

    Scenario: Agent queries the knowledge MCP for reference material
      Given the agent is in the research phase
      When the agent pulls reference material
      Then the agent retrieves overview.md, pm_intake.md, and primary_research.md via the knowledge MCP server
      And guidance from those files (triangulation, evidence footer, decision-useful fields) is reflected in summary.md

    Scenario: Agent surfaces contradictory evidence to the PM
      Given two sources disagree on a persona's primary motivation
      When the agent detects the conflict
      Then the agent presents both sources to the PM before writing summary.md
      And the agent asks the PM to arbitrate

    Scenario: Agent reports a research dead-end instead of inventing content
      Given web search and the knowledge MCP return no relevant data for a claim
      When the agent runs out of leads
      Then the agent returns to the PM for source suggestions
      And the agent does not write summary.md with placeholder or invented content

  Rule: No thin personas — agent challenges the PM

    Scenario: Agent pushes back on a one-line persona description
      Given the PM provides "a developer who wants to ship code" as the full input
      When the agent evaluates the input
      Then the agent returns targeted follow-up questions covering Role, Goals, Pain Points, Context, and Decision Drivers
      And no summary.md is written

    Scenario: Agent ends the session rather than produce a thin persona
      Given the PM refuses to answer follow-up questions across multiple turns
      When the agent determines evidence is inadequate
      Then the agent ends the session without writing summary.md
      And personas_complete remains unsatisfied
      And the next turn's feedback explains the session ended for lack of evidence

    Scenario: Agent demands sources when research corroborates nothing
      Given PM input is present but web search and knowledge MCP produce no supporting evidence
      When the agent evaluates the evidence bar
      Then the agent returns a source-leads request to the PM
      And no summary.md is written

  Rule: Evaluate requires record and both files together, per persona

    Scenario: Fully-satisfied persona clears the checker
      Given one persona "founder" with a personas row
      And .code_my_spec/personas/founder/summary.md exists with all required sections
      And .code_my_spec/personas/founder/sources.md exists with at least one entry
      When PersonasChecker.complete? runs for the project
      Then the checker returns :ok

    Scenario: Missing DB row fails evaluation
      Given .code_my_spec/personas/founder/summary.md and sources.md exist
      And no personas row for "founder"
      When PersonasChecker.complete? runs
      Then the checker returns invalid
      And the detail names "founder" and "record missing"

    Scenario: Missing sources.md fails evaluation
      Given a personas row for "founder"
      And .code_my_spec/personas/founder/summary.md exists
      And .code_my_spec/personas/founder/sources.md does not exist
      When PersonasChecker.complete? runs
      Then the checker returns invalid
      And the detail names "founder" and sources.md

    Scenario: Two personas with different gaps surface together
      Given two personas "founder" and "agency_pm" on the project
      And "founder" is missing summary.md
      And "agency_pm" is missing sources.md
      When PersonasChecker.complete? runs
      Then the checker returns invalid
      And the detail lists "founder" with summary.md
      And the detail lists "agency_pm" with sources.md

    Scenario: Zero personas on the project prompts the agent to start one
      Given the project has no personas linked
      When PersonasChecker.complete? runs
      Then the checker returns invalid
      And the detail instructs the agent to start a persona

  Rule: Research artifacts are exactly two markdown files

    Scenario: Persona folder contains exactly summary.md and sources.md
      Given the agent has finalized persona "founder"
      When the agent inspects .code_my_spec/personas/founder/
      Then the folder contains summary.md and sources.md
      And the folder contains no other files

    Scenario: sources.md entries include URL, title, and access date
      Given the agent has completed research for "founder"
      When the agent writes sources.md
      Then each entry contains a URL, a title, and an access date

    Scenario: Stray file in the persona folder is flagged
      Given .code_my_spec/personas/founder/ contains summary.md, sources.md, and research_notes.md
      When PersonasChecker.complete? runs
      Then the checker returns invalid
      And the detail names research_notes.md as a stray file

  Rule: persona_summary required sections

    Scenario: Fully-sectioned summary validates
      Given summary.md contains Role, Goals, Pain Points, Context, Decision Drivers, and Evidence sections
      When CodeMySpec.Documents validates it against the persona_summary type
      Then validation returns :ok

    Scenario: Missing required section fails validation
      Given summary.md is missing the Evidence section
      When CodeMySpec.Documents validates it against the persona_summary type
      Then validation returns an error naming "Evidence"

    Scenario: Optional section is accepted alongside required ones
      Given summary.md contains all required sections plus a Jobs to Be Done section
      When CodeMySpec.Documents validates it against the persona_summary type
      Then validation returns :ok

    Scenario: Unrecognized section is rejected
      Given summary.md contains all required sections plus a "Demographics" section
      When CodeMySpec.Documents validates it against the persona_summary type
      Then validation returns an error naming "Demographics" as disallowed

  Rule: Personas are account-scoped

    Scenario: Persona is visible across projects within the same account
      Given account "Acme" contains project "Product X" and project "Product Y"
      And a persona "founder" was created while working on "Product X"
      When the PM opens "Product Y"
      Then "founder" appears in the account persona library for "Product Y"

    Scenario: Persona from one account is not visible to another
      Given account "Acme" contains persona "founder"
      And account "Globex" contains project "Product Z"
      When the PM operating in "Globex" queries the persona library
      Then "founder" does not appear

    Scenario: Cross-account link attempt is rejected at the library boundary
      Given the PM is operating in account "Globex"
      When the PM attempts to link "founder" (from account "Acme") to a story in "Globex"
      Then the request is rejected before any database change

  Rule: Personas link to stories via a many-to-many join

    Scenario: Linking one persona to a story creates one join row
      Given persona "founder" and story "S1" both in account "Acme"
      When the PM links them
      Then one persona_stories row exists referencing "founder" and "S1"

    Scenario: Linking two personas to one story creates two join rows
      Given personas "founder" and "agency_pm" and story "S1" all in account "Acme"
      When the PM links both personas to "S1"
      Then two persona_stories rows exist
      And each references "S1" with a different persona

    Scenario: Cross-account link is rejected
      Given persona "founder" in account "Acme"
      And story "S99" in account "Globex"
      When a link between them is attempted
      Then the link is rejected
      And no persona_stories row is created
