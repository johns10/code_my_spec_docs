# Context Development: Let the AI Build the Whole Thing

> **Part of the [CodeMySpec Methodology](/methodology)** -- Level 3: AI Develops, Humans Review.

At Level 2, you drive one component at a time. Write a spec. Generate code from the spec. Generate tests. Run validation. Fix what breaks. Repeat for the next component. You're in control the whole way, and every step has guardrails.

It works. But when a context has a dozen components with dependencies between them, you're spending most of your time deciding what to build next, not reviewing what gets built. You become the scheduler.

Level 3 is where you stop scheduling and start reviewing.

## What develop-context Does

You run `/develop-context` and point it at a bounded context. The system takes over from there.

Here's what actually happens, end to end:

1. **Context spec.** The system writes a specification for the context itself -- the bounded context's responsibilities, its public API, its delegates to child components.

2. **Child component specs.** For every child component in the context -- schemas, repositories, GenServers, tasks, whatever -- the system generates a spec. Each spec defines the module's functions, types, dependencies, and test assertions.

3. **Design review.** This is a gate. The system reads every spec it just generated, cross-references them against the user stories assigned to this context, and produces a design review document. It checks that types are consistent across modules, that every function belongs where it's placed, that test assertions don't contradict each other, that dependencies reference real components, and that story acceptance criteria are covered. If issues are found, it fixes the specs before the review passes.

4. **Implementation.** Tests and code for each child component, in dependency order. Leaves first -- the components with no dependencies get built before the ones that depend on them. Then the context module itself, last.

5. **Validation.** Every component gets checked against a requirement checklist: spec file exists, spec is valid, implementation file exists, test file exists, tests passing. The context isn't "done" until every component in the tree satisfies every requirement.

You review the output as a whole. A finished context, not a pile of individual files.

## The Requirement Lifecycle

Each component tracks a set of requirements. For a context, the full list is:

- `spec_file` -- the specification exists
- `spec_valid` -- the specification passes schema validation
- `children_designs` -- all child components have specs
- `review_file` -- the design review document exists
- `review_valid` -- the design review passes validation
- `children_implementations` -- all children have implementation files
- `implementation_file` -- the context module itself exists
- `test_file` -- the context test file exists
- `tests_passing` -- all tests pass

These have prerequisite chains. You can't write the design review until all children have specs. You can't implement children until the review passes. You can't implement the context itself until all children are implemented. The system enforces this ordering automatically.

Each requirement also has a `satisfied_by` field pointing to a specific agent task -- `ComponentSpec`, `ComponentCode`, `ComponentTest`, `ContextDesignReview`, and so on. These are the Level 2 commands running under the hood. The orchestrator figures out what's actionable (unsatisfied requirement with all prerequisites met), dispatches the right task, and moves on.

## Dependency Ordering

The system doesn't just build components in any order. It walks the dependency graph.

The `DependencyTree` module performs a topological sort on components. If your `AccountRepository` depends on `Account` (the schema), the schema gets built first. If your context module delegates to `AccountRepository`, the repository gets built before the context.

The orchestrator uses this to find what's ready: the first component in the sorted order that has unsatisfied requirements and whose own dependencies are all satisfied. If something is blocked -- waiting on a dependency that isn't done yet -- it skips it and picks up the next ready item.

This means the system naturally works bottom-up through the component tree. Schemas and value objects first, then repositories and services, then the context facade on top.

## The Design Review Gate

The design review is the human checkpoint. It happens after all child specs are written but before any code is generated.

The review reads every spec file, checks them against the user stories assigned to the context, and validates cross-cutting concerns: are the types consistent? Do the delegate functions in the context actually match the APIs in the child components? Are there contradictions in test assertions?

If the review finds problems, it fixes the spec files directly and documents what it changed. The review document itself gets validated against a schema -- it has to actually say something substantive, not just rubber-stamp the design.

This is where you look. Not at individual spec files. Not at code diffs. You read the design review, see what the architecture looks like, and decide if this is the right structure before any implementation happens. If something is wrong, you catch it here -- before the system generates thousands of lines of code from a flawed design.

## develop-live-context: The UI Variant

`/develop-live-context` is the same idea for LiveView groupings. A live context is a spec-only container -- it defines a group of LiveViews and LiveComponents but doesn't have a code file itself.

The lifecycle is shorter:

1. **Live context spec** -- define the grouping, list child views and components
2. **Child specs** -- design each LiveView and LiveComponent
3. **Implementation** -- tests and code for children only, with LiveComponents built before LiveViews (since views depend on components)

No design review gate for live contexts. The specs for individual LiveViews and LiveComponents are simpler -- they define routes, interactions, and component composition rather than business logic APIs.

The evaluation only checks children. The parent live context is done when all its children satisfy their implementation requirements.

## Other Orchestrated Commands

The same pattern applies to smaller scopes:

**develop-liveview** -- Orchestrates a single LiveView and its child components. Specs for each child, then implementation in dependency order (children first, parent last).

**develop-controller** -- Orchestrates a Phoenix controller and its companion JSON view. Writes specs, then implements both the controller and the JSON view together. It even creates a stub spec for the JSON view automatically if one doesn't exist.

**develop-component** -- The general-purpose variant. Works on any component tree -- walks all descendants, finds unsatisfied requirements, and dispatches tasks until everything is complete.

Each of these delegates to the same `ProjectCoordinator` for orchestration. Same dependency resolution, same prompt file generation, same evaluation logic. The difference is scope -- a single component tree vs. an entire bounded context.

## How It Knows When It's Done

The evaluate function on each task module checks the same thing: are all implementation requirements satisfied across all components in scope?

For `develop-context`, that means the context itself plus all children. For `develop-live-context`, just the children (the parent has no code). For `develop-component`, the root plus all descendants recursively.

The check is simple. Load the component tree. For each component, verify that every required requirement (`spec_file`, `spec_valid`, `implementation_file`, `test_file`, `tests_passing`) is satisfied. If any component has any unsatisfied requirement, the context isn't done yet.

When all requirements are satisfied, the orchestrator reports completion. When they're not, it lists exactly which components still need work and what's missing. The system loops -- generating prompt files for the next batch of actionable work, dispatching subagents, validating results, and repeating until everything passes.

## What This Feels Like

You pick a context. You run the command. You go do something else.

When you come back, there's a design review to read. You skim the architecture, check that the component breakdown makes sense, verify the story coverage looks right. If it's good, you let it continue. If something is off, you adjust a spec and re-run.

Then implementation happens. The system works through the component tree bottom-up. Each component gets tests written first, then code. Tests run. If they fail, the system fixes the code. When the whole tree is green, the context is done.

Your job shifted from "write this schema, now write this repository, now write these tests, now write the context module" to "does this architecture make sense?" That's the Level 3 transition. You went from driving to reviewing.

## What Comes Next

This works well when you know which context to build. You point the system at an Accounts context, it builds the Accounts context. You point it at Transactions, it builds Transactions.

But who decides that Accounts and Transactions are the right contexts in the first place? Who maps user stories to bounded contexts? Who designs the dependency graph between them?

That's Level 4 -- where humans define the architecture and the system builds everything that follows from it.
