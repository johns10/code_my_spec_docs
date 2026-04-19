# BDD Spec Test Strategy

## The Problem

BDD specs authored by AI models can easily prove nothing. Stubs let the author
define both the question and the answer. Mocks let the author bypass the system
entirely. The spec passes, the code is broken.

## The Constraint

**The spec author can only put things IN and observe things OUT. They cannot
control what happens in between.**

No mocks. No stubs. No behaviour injection. No calling context functions
directly. No asserting on internal state.

## The Architecture

### Four layers

1. **In-memory filesystem** — real content, fake I/O. `File.read` returns real
   Elixir source code. `File.write` stores real content at a real path.
   DirWalker walks the in-memory tree. The system's logic runs against real
   file content — the only thing that's fake is the disk.

2. **Recorded System.cmd** — real tool output, fake execution. Compiler
   diagnostics, test results, credo output all replayed from cassettes
   captured against real tool runs. The system processes real diagnostics.
   It just didn't wait 45 seconds for `mix compile` to produce them.

3. **Real DB** — SQLite, real queries, real state transitions. Nothing faked.
   Projects, components, files, problems, configuration — all real records.

4. **Real pipeline logic** — Validation, Pipeline, TaskEvaluator,
   RequirementGraph, ProjectConfiguration all run their actual code paths.

### What the spec author gets

- **Givens** — pre-recorded project states (filesystem + tool cassettes)
- **Whens** — HTTP test tools, MCP test tools, LiveView test DSL
- **Thens** — DB assertions, HTTP response assertions, LiveView assertions

That's it. Nothing else.

## Givens Are Cassettes

Each Given is a self-contained cassette captured from a real tool run against
real files. The cassette contains:

- Filesystem snapshot (paths + content)
- Recorded System.cmd outputs (compiler JSONL, test JSON, credo JSON, etc.)

The recording workflow:

1. Start from a known state of the test repo (`code_my_spec_test_repo`)
2. Make a change (write a file with a violation, introduce an error, etc.)
3. Run the real tool (`mix compile`, `mix test`, `mix credo`)
4. Capture the triplet: initial state + change + tool output
5. Store as a named cassette

At test time:

1. The Given loads its cassette
2. In-memory filesystem is hydrated with the snapshot
3. System.cmd replay is loaded with the recorded outputs
4. The system runs for real against this state

**Givens do not compose.** One Given, one cassette, one known state. If you
need "credo violation AND failing tests" you record that as its own Given.
No layering, no composition magic.

## Why This Works

The spec author cannot invent a state that was never real. Every Given was
captured from an actual tool run against actual files. The filesystem content
and the tool output are always consistent because they were captured together.

The spec author cannot bypass the pipeline. They trigger it through the same
HTTP endpoints and MCP tools that Claude uses in production. The pipeline
runs its real code paths — the only shortcut is I/O.

The spec author cannot assert on things that don't matter. They can only
observe what came out: DB state, HTTP responses, LiveView state. If the
assertion passes, the system actually did the work.

## The Givens Library

Grows over time. Each one is a snapshot of reality recorded from
`code_my_spec_test_repo`. Adding a new Given means going to the test
repo, making a real change, running the real tool, and capturing the output.

### Validation pipeline givens (initial set)

- Project with clean state (no violations, tests pass)
- Project with compiler error
- Project with compiler warning
- Project with credo violation on a specific file
- Project with failing tests
- Project with failing spex
- Project with a spec file missing a required section

### Configuration givens (initial set)

- Project with components that have spec files
- Project with components that have test files
- Project with components that have both

## Guard Rails for the Model

When the model authors BDD specs, it is constrained to:

1. Select a Given from the library (cannot define file content or tool output)
2. Set up DB state through Repo inserts (project, components, config records)
3. Trigger actions through HTTP/MCP/LiveView (the public interface)
4. Assert on observable outcomes (DB queries, responses, rendered UI)

It CANNOT:

- Import or call internal modules
- Mock or stub any behaviour
- Inject test doubles
- Define System.cmd return values
- Call context functions directly
- Assert on process state, message passing, or logs
