# Start Implementation: The Full Cycle

In the five levels article, I described Level 5 as the "dark factory" -- specs in, software out. The full autonomous cycle where you define stories and the system handles everything between those stories and running software.

That sounds like marketing. Let me show you what it actually is.

## The Orchestrator

`StartImplementation` is a graph-driven orchestrator. It does one thing in a loop: find the next unsatisfied requirement and dispatch the right agent task to handle it.

The loop works like this:

1. Sync the project state -- pull in everything the agent has done since last check
2. Walk the graph: project, stories, contexts, components, dependencies
3. Find the first requirement that isn't satisfied yet
4. Dispatch the appropriate command for that requirement
5. When the agent finishes, evaluate the result
6. If something is still unsatisfied, dispatch again
7. If everything passes, report completion

That's it. There's no planning step. There's no task queue. The orchestrator doesn't decide what to do next by reasoning about it. It walks the graph, finds the gap, and fills it. The graph is the plan.

When the orchestrator calls `get_next_actions`, it gets back a `Requirement` struct with a name and a scope. The scope tells the dispatcher whether this is something a single agent handles locally, something that needs to be orchestrated across child tasks, or something that requires spawning sub-agents. The dispatcher generates the right prompt and hands it off.

If the graph is fully satisfied -- every requirement on every component of every context of every story -- the orchestrator clears the implementation status and stops. Done.

## The Setup Phase

Before any business logic gets written, two tasks handle project initialization.

**ProjectSetup** takes an empty directory and turns it into a working Phoenix project connected to CodeMySpec. It checks prerequisites (Elixir version, PostgreSQL, Phoenix installer), creates the project, installs required dependencies (Credo, Boundary, Sobelow), sets up the `.code_my_spec/` directory structure, configures the CLI, installs framework rules and knowledge, and verifies everything compiles. The evaluation is deterministic -- it checks twenty-plus conditions and reports exactly what's missing.

**ProjectBootstrap** runs after technology decisions are made. It reads the Architecture Decision Records from the research phase, installs the chosen libraries, configures Dotenvy for environment management, collects API keys, writes Req-based API clients for every external integration, and records smoke test cassettes against real APIs. The evaluation checks that `.env.example` exists, Dotenvy is configured in `runtime.exs`, `.env` is gitignored, smoke tests exist, and the project compiles.

Both tasks follow the same pattern: generate a prompt with instructions and current state, let the agent execute, then evaluate with hard checks. No subjective review. Either the artifact exists and is correct, or it doesn't and the agent gets specific feedback about what to fix.

## Context Implementation

Once setup is done, the orchestrator starts walking stories. Each story maps to bounded contexts. Each context has child components -- schemas, repositories, services, GenServers, LiveComponents, LiveViews.

`ContextImplementation` is the container that manages this. It doesn't implement anything itself. It checks whether all children have their implementation requirements satisfied: implementation file exists, test file exists, tests pass. If any child is missing any of those three, it reports which components still need work.

The children get implemented in dependency order. Schemas first (no dependencies). Repositories next (depend on schemas). Services and GenServers (depend on repositories and schemas). LiveComponents before LiveViews. LiveViews last. Within a layer, components can be parallelized.

Each child component gets dispatched to the appropriate Level 2 or Level 3 command -- the same `develop_context`, `architecture_design`, `qa_story` commands that work standalone. Level 5 doesn't introduce new implementation logic. It orchestrates the existing commands in the right order based on the graph.

## The Dispatch Pattern

This is the key insight. `StartImplementation` doesn't know how to write code, design architecture, or run QA. It knows how to walk a graph and dispatch.

The requirements in the graph map to commands:

- Architecture not designed yet? Dispatch `architecture_design`.
- Context needs implementation? Dispatch `develop_context`.
- Story needs QA validation? Dispatch `qa_story`.
- Technology decisions not researched? Dispatch `topic_research`.
- Project not bootstrapped? Dispatch `project_bootstrap`.

Each of those commands is a complete agent task with its own `command/3` to generate prompts and `evaluate/3` to verify results. The orchestrator just picks the right one based on what the graph says is missing.

When an agent finishes work, the orchestrator syncs the project state (picking up new files, updated requirements) and re-walks the graph. If the work satisfied the requirement, the graph moves forward. If it didn't, the evaluation feedback goes back to the agent as a new prompt. The loop continues until everything is green or something fails hard enough to surface an error.

## What This Actually Produces

Fuellytics is a fuel card management platform with Stripe Treasury integration, fraud detection, and financial compliance requirements. It went from an empty repository to user acceptance testing in six weeks. One person defining requirements. The system handling implementation.

55 commits. Full financial services platform. Stripe Treasury for fund management. Real-time transaction monitoring. Compliance workflows. Multi-tenant architecture with role-based access control.

The orchestrator walked the graph hundreds of times. Each pass found the next gap -- a schema that needed implementing, a context that needed tests, a story that needed QA validation. Each gap got dispatched to the right command. Each command ran its agent, produced artifacts, got evaluated.

The human work was defining the stories, approving the architecture decisions (Stripe Treasury vs. alternatives, fraud detection approach, compliance strategy), and making product calls when the system surfaced questions it couldn't answer from the spec alone.

## What the Human Still Does

I want to be clear about this because the "dark factory" framing can be misleading.

The human defines stories. Not vague ideas -- structured stories with acceptance criteria that can be mechanically verified. This is product work. It requires understanding the domain, the users, and what correct behavior looks like.

The human approves architecture. When the system proposes a component graph, dependency structure, or technology decision, a human reviews it. Architecture mistakes are expensive and the system doesn't have the product context to make those calls autonomously.

The human makes product decisions. When a story has ambiguity that can't be resolved from the spec, the system surfaces it. Someone has to decide. That someone understands the business.

The human isn't removed from the process. They're elevated. Instead of writing code, reviewing diffs, and debugging test failures, they're working at the level of "what should this system do and why." Everything below that -- the how -- is automated and verified.

## The Loop That Makes It Work

The reason this works isn't the AI. The AI is the same Claude that everyone has access to. What makes it work is the loop.

The orchestrator dispatches a command. The agent does work. The evaluator checks the work with deterministic criteria. If it fails, the feedback is specific and actionable -- not "try again" but "`.env.example` is missing, tests don't compile, these three components still need implementation files." The agent gets that feedback and fixes exactly what's wrong.

This loop runs until every requirement on the graph is satisfied. Not until the AI thinks it's done. Until the checks pass. The checks don't get tired. They don't skim. They don't approve something because it looks close enough at 11pm.

That's the difference between Level 2 and Level 5. At Level 2, you're the loop. At Level 5, the graph is the loop, and you're the person who defined what the graph should look like.

## The Bottleneck Was Never Typing Code

In the five levels article, I used the YouTube analogy. When YouTube launched, professional videographers dismissed it. They were right that amateurs weren't making cinema. They were wrong about what that meant.

YouTube didn't succeed because amateurs got better at cinematography. It succeeded because the bottleneck was never operating a camera. It was knowing what to point it at.

The same thing is true here. The bottleneck in software development was never typing code. It was knowing what to build, defining what correct looks like, and verifying that what got built matches the definition.

`StartImplementation` is just a loop that walks a graph and dispatches commands. The graph is the interesting part. The graph is the spec -- stories, contexts, components, dependencies, requirements. If the graph is right, the software is right. If the graph is wrong, no amount of code quality saves you.

The skill that matters at Level 5 is the same skill that mattered before AI: understanding the problem well enough to define the solution. The difference is that everything between the definition and the running software is now automated. Not by magic. By a loop that checks its own work, over and over, until the checks pass.
