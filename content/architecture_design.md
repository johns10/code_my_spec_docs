# Architecture Design: Defining the System Before Code Exists

Most AI coding workflows put the human in the review seat. The AI writes code, you read it, you approve or reject. That works until the AI is producing code faster than you can read.

Level 4 flips the relationship. You stop reviewing code and start defining what correct looks like. On the architecture side, that means defining the system's structure -- contexts, components, dependencies, technology decisions -- before any implementation begins.

This is where procedural code matters most. The AI proposes. Deterministic validation checks the proposal. The human approves structure, not code.

## Architecture Design

The `/architecture-design` command starts a guided session that turns user stories into a component graph.

The agent receives every unsatisfied user story, the current component count, and generated architecture views -- an overview, a Mermaid dependency graph, and a namespace hierarchy. Its job is to analyze the stories, identify bounded contexts, and map each story to both a surface component (the LiveView or controller the user interacts with) and a domain component (the context or schema that implements the logic).

This dual-mapping is enforced by procedural validation, not AI judgment. Every story must appear on both a surface component and a domain component. The system checks real story IDs, not AI-generated ones. If the mapping is incomplete or invalid, the agent gets specific feedback about exactly what's wrong.

The agent writes a proposal to a markdown file following a strict document schema. When the session stops, procedural code parses the proposal, validates it, and executes it -- creating spec files for every component, linking stories to components in the database, and building out the component tree. No human reads the proposal line by line. The validation catches structural problems. The human reviews the architecture at the level of "does this decomposition make sense for the product?"

## Technical Strategy

Before any code gets written, technology decisions need to happen. `/technical-strategy` handles this through Architecture Decision Records.

The system auto-writes ADRs for the standard stack -- Elixir, Phoenix, LiveView, Tailwind, DaisyUI, phx.gen.auth, Wallaby, BDD testing, Dotenvy, Resend. These are pre-made decisions baked into procedural code. They get committed as accepted records without discussion because they're not decisions anymore -- they're the platform.

Then the agent looks at the project's architecture, stories, and dependencies to identify decisions that still need to be made. Testing strategy. Deployment approach. Third-party integrations. Background job infrastructure. For each topic, it does cursory research, evaluates options against project needs, and writes a decision record with context, options considered, and consequences.

The evaluate step is deterministic: check that all pre-made decisions have ADR files and that the decisions index exists. Technology choices are captured as documents before the first line of implementation code. This matters because it means the AI has explicit constraints to work within, not implicit assumptions to guess at.

## Architecture Review

`/architecture-review` reviews the health of the existing architecture. Procedural code calculates metrics -- total components, surface-to-domain ratio, context count, circular dependencies, orphaned components -- and generates fresh architecture views.

The agent reviews surface-to-domain separation, dependency flow direction, component responsibilities, story coverage, and architectural issues. It uses tools to investigate and make changes directly: linking stories to components, checking for cycles, browsing spec files.

This is a conversational session. There's no strict validation gate. The value is in catching drift -- components that lost focus, dependencies that flow the wrong direction, stories that fell through the cracks. You run this periodically, not as part of every build.

## Context Design Review

`/context-design-review` validates the design of a specific bounded context before implementation begins. The agent reads the context spec, every child component spec, and all linked user stories.

Then it cross-checks: do the type signatures match the descriptions? Does every function belong in its component? Do test assertions contradict each other? Do dependencies reference real components? Do context delegates match child APIs? Does every acceptance criterion map to at least one function?

If it finds problems, it fixes the specs directly before writing the review. The evaluate step checks artifact requirements -- a requirements system that tracks whether the review document exists and is valid. The design review has to pass before implementation can proceed.

This is the gate between "we designed this" and "we're building this." No code gets generated for a context that hasn't been reviewed. That gate is enforced by procedural code, not by hoping someone remembers to check.

## The Pattern

Across all of these commands, the human works at the level of "what should this system do and why." You define stories. You approve architecture. You make technology decisions.

Everything below that -- mapping stories to components, generating specs, validating proposals, writing ADRs for standard decisions, calculating architecture health metrics -- is handled by a combination of AI doing the creative work and procedural code validating the output. The AI proposes. The code checks. The human approves at the structural level.

This is what makes Level 4 architecture different from "ask the AI to design your system." The AI's proposals are validated against real data -- actual story IDs, actual component graphs, actual dependency chains. When it gets something wrong, the feedback is specific and mechanical, not a vague "try again."

The architecture side defines what should exist. The QA side verifies that what exists is correct. Together, they close the loop.
