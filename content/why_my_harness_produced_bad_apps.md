# Why My Harness Produced Incomplete Apps (and What I Changed)

My harness produced incomplete applications. Not because the model was bad. Because I didn't understand what a spec is.

Eight months. 580+ commits. Three client apps generated from specs. And I'm only now getting clear on what "specification" actually means when you're handing work to an AI agent.

## Phase 1: Module Specs

I thought a spec meant describing what the code does. Here's the schema. Here's the repository pattern. Here are the function signatures.

The model followed them perfectly. The application didn't work as a whole.

Module specs tell the agent how to write code. They don't tell it what the application is supposed to do. You end up with well-implemented modules that don't compose into working software.

I was specifying the solution instead of the problem.

## Phase 2: BDD Specs

I wrote about this shift in [BDD Specs for AI-Generated Code](/pages/bdd-specs-for-ai-generated-code). Moving from "describe the code" to "describe what the app does" was a real improvement. Given/When/Then. User stories with acceptance criteria.

Better. Not good enough.

My specs weren't specific enough, and I gave the agent too much freedom writing them. Happy path in broad strokes, gaps filled with the agent's assumptions. Still spending significant time debugging applications that "passed all their tests."

The self-confirming loop was still happening. Just at a higher level of abstraction.

## Phase 3: Executable BDD Specs at Boundaries

The specs I'm building have three interaction surfaces. The agent reads and writes files through the filesystem. The user interacts through LiveView. The model calls tools through MCP servers.

Three boundaries. Three places where the application touches the outside world.

A spec needs to exercise the full application with realistic I/O at each boundary. Not mocked. Not simplified. Realistic recordings of what actually flows across the boundary.

The spec becomes executable by providing realistic inputs at the boundary and asserting on realistic outputs. Everything in between is the application doing its job.

A module spec says "this function should return a map with these keys." A BDD spec says "when the user clicks submit, they should see a confirmation." A boundary spec says "when the user clicks submit, the system sends this exact HTTP request to Stripe, receives this exact response, stores this exact record, and renders this exact confirmation." The boundary spec leaves nowhere to hide.

## What This Entails

Refining user stories into tight BDD specs is a skill, not a template. You have to anticipate edge cases, specify error conditions, define what "done" looks like with enough precision that an agent can't misinterpret it.

Turning those specs into executable tests at the boundaries is engineering. Realistic fixtures. Understanding the I/O contract at each boundary. Test infrastructure to replay recordings deterministically.

Both are harder than writing code. The code is the easy part. The hard part is specifying what you want with enough precision that the easy part produces the right result.

## The 4.7 Validation

Opus 4.7 validates this. People with harnesses see a better model. People who prompt and pray see a worse one. Same model, different outcomes.

The non-technical vibecoders who got good results from models optimized for zero-context prompting are going to have a harder time with models that reward structure. The experienced engineers who invested in harness infrastructure are going to see compounding returns.

The model is getting better at being steered. That only helps you if you're steering.

## What's Next

I'm working on [MetricFlow](https://github.com/Code-My-Spec/metric_flow) as the test case. It's open source -- specs, generated code, where things break.

The meta thing about building a harness is that the [harness itself needs a harness](/pages/the-harness-layer). My BDD specs for CodeMySpec have to handle the fact that the system under test is a system that writes and tests other systems.

It's specs all the way down.
