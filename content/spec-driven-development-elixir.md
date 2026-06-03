# Spec-Driven Development for Elixir and Phoenix

Most spec-driven development tools are stack-neutral by design, and that is exactly why they fall short on Elixir. They treat a Phoenix app like any other web project, generate plausible-looking code, and miss everything that makes Elixir Elixir: contexts as boundaries, LiveView's process model, Ecto's changeset discipline, OTP supervision. [Spec-driven development](/blog/spec-driven-development) is a good idea. It makes the spec the source of truth instead of vibe-coding through chat. But point a generic SDD tool at a Phoenix app and you get specs that don't speak the language of the framework, and code I'd rewrite before it ever hit review.

I write Elixir. This is why generic SDD and AI-coding tools produce non-idiomatic Phoenix, what spec-driven development looks like when it actually understands the framework, and how I built CodeMySpec to close that gap.

## Why generic SDD tools fall short on Elixir

The big SDD tools (GitHub Spec Kit, Kiro, OpenSpec) are deliberately language-agnostic. That breadth is a real strength when you are bouncing between a React frontend and a Go service. It is a liability the moment the target is a Phoenix app, because the things that decide whether Elixir code is good are framework-specific, and the tool has no model of them.

Here is what a stack-neutral agent gets wrong on Phoenix, every time:

- **Contexts.** Phoenix contexts are the architectural boundary of the app, the public API to a slice of the domain. A generic agent treats them as a folder, scatters business logic into controllers and LiveViews, calls `Repo` directly from the web layer, and produces a "context" that is just a thin pass-through to schemas. The boundary that contexts exist to enforce evaporates.
- **LiveView.** LiveView is a stateful process with a mount/event/render lifecycle, not a request-response controller. Agents trained mostly on stateless web patterns put business logic in the template, mutate socket assigns carelessly, miss `handle_info` for async work, and ignore the PubSub patterns that make LiveView worth using.
- **Ecto.** Idiomatic Ecto routes every write through a changeset, keeps validation and casting in the changeset function, and composes queries with the `Ecto.Query` API. Generic output skips changeset validation, hand-rolls queries inline, and treats Ecto like an ORM it half-remembers from another ecosystem.
- **OTP and supervision.** When background work, state, or concurrency shows up, the idiomatic answer is a GenServer under a supervisor, or a Task, or an Oban job. A stack-neutral tool reaches for the patterns it knows from elsewhere and ignores the supervision tree entirely.
- **Tests.** Elixir has ExUnit, `Phoenix.LiveViewTest`, `Phoenix.ConnTest`, and Ecto's `Sandbox`. Generic tooling either generates no tests or generates tests that don't use the framework's own test helpers.

The result passes a quick read, then trips [Credo](https://github.com/rrrene/credo), fails review, and would never survive in a codebase an Elixir team actually maintains. The spec was stack-neutral, so the code is stack-neutral, and stack-neutral Elixir is just non-idiomatic Elixir wearing an `.ex` extension.

## What Elixir-native spec-driven development should look like

If SDD is going to work for Phoenix, the spec has to speak the framework's own terms, and the verification has to understand the framework's own runtime. That means four things.

**Specs framed around contexts and behaviors.** The unit of specification should be the context and its public functions, not a generic "module." A spec for a `Billing` context should describe the behaviors that context guarantees (what `Billing.create_subscription/2` accepts, what it returns, what it refuses) because the context boundary is the contract. (This is the same reason [Phoenix contexts are great for LLMs](/blog/why-phoenix-contexts-are-great-for-llms): they give the agent a stable, named seam to reason about instead of an undifferentiated pile of modules.)

**BDD scenarios mapped to real Phoenix flows.** Acceptance criteria should compile down to behavior scenarios that map onto how Phoenix actually runs: a LiveView mount and a sequence of events, a controller action and its rendered response, a context function and its side effects. A scenario like "WHEN a signed-out user submits the registration form, the system SHALL create the user and redirect to the dashboard" should map to a concrete LiveView interaction, not a vague prose paragraph.

**Architecture as a context dependency graph.** Phoenix architecture is, at the macro level, which contexts exist and how they depend on each other. An Elixir-native design step should produce that graph explicitly, with contexts as nodes and allowed dependencies as edges, so the design fixes the boundaries up front rather than discovering them after the web layer has reached straight into three schemas it shouldn't know about.

**Tests that are real ExUnit.** The verification artifact should be ExUnit tests using the actual framework helpers (`Phoenix.LiveViewTest` for LiveViews, `Phoenix.ConnTest` for controllers, the Ecto `Sandbox` for data) so the tests run in the same toolchain the rest of the codebase already uses. Tests in any other shape are friction, not coverage.

None of this is exotic. It is just what a senior Elixir engineer already does by hand. The gap in generic SDD is that the tools have no notion of any of it.

## How CodeMySpec does Elixir-native SDD

[CodeMySpec](/products/code-my-spec) is the full-lifecycle, spec-driven AI development harness I built Phoenix-first. It ships as a Claude Code plugin with a local MCP server and a web app, and Elixir and Phoenix are not a supported target bolted on after the fact. They are the design center.

The pieces map directly onto the four requirements above:

- **The requirement graph.** Every artifact (spec, BDD scenario, test, implementation, QA result) is a node with prerequisites on a single graph. The harness computes what to work on next (`get_next_requirement` then `start_task`) rather than leaving you to thread the workflow by hand. Contexts and their dependencies live on that same graph, so the architecture is a first-class, navigable structure, not a comment in a README.
- **BDD specs via the Spex DSL.** Acceptance criteria become behavior scenarios written in the Spex DSL. These BDD specs are a mandatory gate, and work has to pass them. Module specs, reviews, and generated tests are configurable knobs on top, but the behavioral contract is not optional. Spec quality becomes the explicit lever on code quality.
- **Context architecture design.** The design step produces the context dependency graph (which contexts exist, what each one's public API is, how they may depend on each other) before code generation. The boundary Phoenix contexts exist to enforce gets designed, not discovered.
- **Generated ExUnit tests.** Specs produce acceptance criteria and generated ExUnit tests in the real toolchain, so verification lives where your existing suite lives.
- **Live QA against a running Phoenix app.** This is the part no stack-neutral tool does. The `qa` subagent writes a brief from the BDD specs, boots the real Phoenix app, drives a real browser through Vibium MCP, takes screenshots, and files issues with severity. Unit tests pass. BDD specs pass. Then the QA agent clicks the button and finds the bug anyway. Prompting is praying; verification is a guarantee.

And it is bring-your-own throughout: specs are markdown, tests are ExUnit, and MCP serves the artifacts to any agent (Claude Code, Codex, Gemini CLI, Goose, Cline) or generated context files. Bring your own agent, your own model, your own keys. The harness adds no token markup.

The honest framing: portability and repo-resident specs are table stakes in this space, and OpenSpec, Spec Kit, and others meet them too. The combination CodeMySpec rests on is the wedge: a mandatory BDD gate, built-in live verification, full lifecycle on one graph, and Phoenix-native depth that stack-generic tools structurally cannot match.

## A note on the generic tools

None of this is a knock on Spec Kit, Kiro, or OpenSpec. They are good at what they are for, and I'd reach for them on a polyglot project without hesitation.

[GitHub Spec Kit](/blog/github-spec-kit-guide) is the category-defining open-source toolkit, supports roughly 30 agents, and has enormous momentum. [OpenSpec](/blog/openspec-explained) is an excellent lightweight, repo-resident, no-API-key option with strong brownfield support. Kiro brings EARS-based specs into an agentic IDE. Their shared trait is breadth: they are stack-neutral and language-agnostic by design, which is what makes them broadly useful and, simultaneously, what gives them zero Phoenix depth. They will happily help you spec a Phoenix feature; they just have no model of contexts, LiveView, Ecto, or OTP, so the Elixir-specific quality is entirely on you.

If your work spans many stacks, that breadth is the right trade. If your work is Phoenix, depth beats breadth.

## Who this is for

This page is for two groups.

**Elixir engineer-founders** building a real Phoenix product with AI agents, who have had it with generated code that ignores contexts, dumps logic into LiveViews, and skips changesets, and who want specs and verification that speak Elixir natively instead of fighting a stack-neutral tool the whole way.

**Phoenix agencies and consultancies** delivering client Elixir work, who need the architecture (the context graph), the behavioral contract (BDD specs), and the proof (generated ExUnit tests plus live-app QA) to be consistent and enforced across projects and engineers, not dependent on whoever happened to write the prompt.

If that is you, the bet is simple: an enforced, verified, Phoenix-native harness closes exactly the gaps a stack-neutral SDD tool leaves open on Elixir. CodeMySpec is free during early access, and I'd rather you run it on a real feature and tell me where it falls short than take my word for it.

## Related Articles

- [What Is a Spec? The Most Overloaded Word in Software](/blog/what-is-a-spec)
- [Spec-Driven Development in 2026: The Complete Guide and Tool Comparison](/blog/spec-driven-development)
- [Why Phoenix Contexts Are Great for LLMs](/blog/why-phoenix-contexts-are-great-for-llms)
- [GitHub Spec Kit: How It Works and When to Use It (2026)](/blog/github-spec-kit-guide)
- [OpenSpec Explained: Repo-Native Spec-Driven Development](/blog/openspec-explained)
- [CodeMySpec](/products/code-my-spec)
- [The CodeMySpec Methodology](/methodology)

## Sources

- GitHub Spec Kit launch post (2025-09-02): https://github.blog/ai-and-ml/generative-ai/spec-driven-development-with-ai-get-started-with-a-new-open-source-toolkit/
- Spec Kit canonical workflow (`spec-driven.md`): https://github.com/github/spec-kit/blob/main/spec-driven.md
- Martin Fowler / Birgitta Böckeler, three-level SDD taxonomy: https://martinfowler.com/articles/exploring-gen-ai/sdd-3-tools.html
- "From Code to Contract" (arXiv, 2026), SDD definition and taxonomy: https://arxiv.org/html/2602.00180v1
- OpenSpec: https://openspec.dev/ and https://github.com/Fission-AI/OpenSpec
- DeepLearning.AI, Spec-Driven Development with Coding Agents: https://www.deeplearning.ai/courses/spec-driven-development-with-coding-agents
- Phoenix contexts guide: https://hexdocs.pm/phoenix/contexts.html
- Phoenix LiveView: https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.html
- Ecto: https://hexdocs.pm/ecto/Ecto.html
- ExUnit: https://hexdocs.pm/ex_unit/ExUnit.html
- Credo: https://github.com/rrrene/credo
