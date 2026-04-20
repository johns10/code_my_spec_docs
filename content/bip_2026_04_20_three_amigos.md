# Build In Public: The Three Amigos Problem

The cornerstone of my harness was always supposed to be BDD specs. I just didn't invest enough in the process that produces them.

Too module-spec heavy. Too unit-test heavy. Too light on product management. Bad specs produce incomplete apps.

## What I'm Prototyping

A three amigos process. The classic BDD workflow:

1. **Conversations** - AI interviews you about the feature. What does it do? Who uses it? What goes wrong?
2. **Example mapping** - concrete examples. Happy path, edge cases, error states.
3. **Questions** - things we don't know yet.
4. **Rules** - business rules extracted from examples.
5. **Specs** - Gherkin scenarios derived from rules and examples.
6. **Executable tests** - specs wired up with realistic fixtures at the system boundary.

Each step produces a durable artifact. The artifacts accumulate into a specification an agent can implement against and verify against.

## Why This Is the Bottleneck

Eight months building CodeMySpec. The harness generates code fine. The model writes decent Elixir. Tests run. Apps come out incomplete because the specs don't capture enough.

The problem was never code generation. It was input quality. Garbage in, garbage out applies to specs the same way it applies to prompts.

A bad prompt produces bad code you can see. A bad spec produces incomplete code that passes its tests. You don't catch it until a user tries to do the thing you forgot to specify.

## Boundaries and Fixtures

Every project has different boundaries. You'd plan and define these per project based on how the system interacts with the outside world.

For CodeMySpec specifically, the interaction surfaces are:

- Agent reads and writes files through the filesystem
- Users interact through LiveView
- Model calls tools through MCP servers

A good BDD spec exercises the full application with realistic I/O at these boundaries. Not mocked. Not simplified. Realistic recordings of what actually flows across the boundary.

The spec infrastructure is harder to build than the application code. But you only build it once per project, and every spec you write after that benefits from it.

## MetricFlow Case Study

Releasing the MetricFlow case study whether the process is perfect or not. Analytics reporting platform built entirely with spec-driven development. Multiple integrations. Full hands-off dev cycle.

It has big misses. The agent hit the broad strokes but missed glaring things. Comes down to two things: specs weren't specific enough, and I gave the agent too much freedom writing them.

Open source, warts and all.

https://github.com/Code-My-Spec/metric_flow

The goal isn't to show a perfect system. It's to show the real process of getting from "specs that sort of work" to "specs that actually produce complete applications."
