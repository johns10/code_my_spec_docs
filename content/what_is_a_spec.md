# What Is a Spec? The Most Overloaded Word in Software

I've been doing spec-driven development for a long time. My efforts would have gone a lot better if I'd answered this question earlier: what is a spec?

Turns out the answer is "at least 13 different things." And if you're doing SDD with AI agents right now, most of those definitions are wrong for your use case.

## The Word Means Everything and Nothing

Martin Fowler's team said it directly: "spec" is "quite overloaded at the moment" and there "doesn't seem to be a general definition." A developer saying "check the spec" could mean "read RFC 9110," "look at the RSpec file," "open the Kubernetes YAML," or "review the CLAUDE.md."

This isn't a pedantic complaint. If you tell someone "I do spec-driven development" and they hear "you write design docs before coding," you've already miscommunicated. The SDD wave is building on a word nobody has defined.

So let me define it.

## The Quick Tour

### The Institutional Specs

Standards and protocol specs (RFCs, W3C recommendations, ECMA-262) and language specs (Java Language Specification, the Rust Reference, Python Language Reference). These are canonical definitions published by standards bodies and language designers.

You don't feed these to AI agents. The models absorbed them at training time. When Claude writes valid HTTP requests, it's because it trained on RFC 9110, not because you pasted it into context. These specs matter enormously. They're just not what SDD is about.

### The Interface Specs

API specs (OpenAPI, GraphQL SDL, protobuf), schemas (JSON Schema, SQL DDL, Ecto schemas), and type specs (TypeScript types, Elixir typespecs, Rust's type system).

Machines already read these. AI agents love them. OpenAPI specs power LLM function calling. JSON Schema constrains structured output. TypeScript's entire value proposition for AI coding is that the type system gives agents something to target. These specs are critical infrastructure, but they're not what people mean when they say "spec-driven development."

### The Guidance Specs

Requirements specs (PRDs, user stories, EARS requirements), design docs (ADRs, technical design documents), and agent context files (CLAUDE.md, AGENTS.md, .cursorrules). This is what most people mean by "specs" in SDD right now.

The Andrew Ng course teaches writing markdown specs -- mission.md, tech-stack.md, roadmap.md -- as the primary agent input. Kiro uses EARS notation: "WHEN the API returns a 429 status code, the system SHALL retry with exponential backoff." GitHub's spec-kit has constitutions and feature specs.

These are instructions. They tell the agent what to do. I'll come back to why that's a problem.

### The Verification Specs

Test specs (RSpec, ExUnit, Jest), BDD scenarios (Gherkin/Cucumber), contract specs (Design by Contract, Pact), and formal specs (TLA+, Z notation, Coq).

These prove the code works. Test specs execute against the implementation. BDD scenarios verify behavior. Contracts enforce preconditions and postconditions. Formal specs provide mathematical proofs.

The difference from guidance specs: verification specs don't just say what the code should do. They confirm it did it.

### The New Kids

AI agent specs are a category that didn't exist before 2024. SDD markdown specs (Kiro specs, Tessl specs, BMAD-METHOD docs), agent context files, agent skills. Every SDD tool has invented its own spec format. The landscape ranges from lightweight (a CLAUDE.md file) to heavyweight (Tessl, where the spec IS the source code and generated code is marked "DO NOT EDIT").

## The Problem with Guidance Specs

The SDD movement is overwhelmingly focused on guidance specs. Write a markdown document. Feed it to the agent. Get code back. The Ng course, Kiro, spec-kit, BMAD -- they're all variations on this pattern.

Guidance specs tell the agent what to build. They don't verify it built it correctly.

When the model follows your instructions perfectly, this works great. When the model ignores your instructions -- and it will -- guidance specs fail silently. There's no alarm. No red test. No contract violation. Just code that doesn't match what you asked for, and you won't know until a user finds the bug.

I learned this the hard way. I didn't have any requirements about the account creation flow after signup. So the AI built a signup system where users literally could not create an account after registering. The app was broken for the exact reason I told the agent to build it broken. A markdown spec wouldn't have caught that. An executable spec would have.

Guidance specs are necessary. They're not sufficient.

## Why BDD Specs Win

[BDD specs](/blog/bdd-specs-for-ai-generated-code) sit at an intersection that no other spec type occupies. They are simultaneously:

**A requirement.** A BDD scenario says what the system should do, in language a product owner can read. "Given a registered user, When they submit valid credentials, Then they are redirected to their dashboard."

**A test.** That same scenario executes against the implementation. Green means the code does what the scenario says. Red means it doesn't. No ambiguity.

**Documentation.** The scenario persists as a living description of the system's behavior. It doesn't go stale because it runs in CI. If the behavior changes, the scenario breaks.

This triple nature is the key. A markdown spec is a requirement but not a test. A unit test is a test but not a requirement (it describes implementation details, not business behavior). A BDD spec is both, and it documents itself.

For AI agents specifically, this matters because:

1. The same artifact that instructs the agent also verifies its output. You're not hoping the agent followed your markdown. You're proving it did.

2. BDD specs survive model upgrades. When you switch from one model to another and it interprets your markdown differently, your guidance specs produce different code. Your BDD specs still either pass or fail. The verification is independent of the model.

3. BDD scenarios function as few-shot prompts. Thoughtworks documented this -- Given/When/Then scenarios give the agent concrete behavioral examples to pattern-match against. They're more effective than prose instructions because they're structured and unambiguous.

4. They close the feedback loop. An agent that generates code against a BDD spec can run the spec immediately and know if it succeeded. No human review required for the first pass. The spec is the acceptance gate. This is the difference between "generate and hope" and "generate and verify."

## The Spectrum

Not all specs are created equal for AI-assisted development. Here's how the major types stack up:

| Spec Type | Human-Readable | Machine-Readable | Executable | Self-Verifying |
|-----------|:-:|:-:|:-:|:-:|
| Standards/Language | Yes | No | No | No |
| Requirements (PRDs, EARS) | Yes | Partially | No | No |
| Design Docs | Yes | No | No | No |
| Agent Context (CLAUDE.md) | Yes | Yes | No | No |
| API Specs (OpenAPI) | Yes | Yes | Yes | No |
| Schemas (JSON Schema) | Partially | Yes | Yes | No |
| Type Specs | Partially | Yes | Yes | No |
| Unit Tests | No | Yes | Yes | Yes |
| Contract Specs | Partially | Yes | Yes | Yes |
| **BDD Specs** | **Yes** | **Yes** | **Yes** | **Yes** |

BDD specs are the only type that checks all four boxes. Human-readable (product owners can read Gherkin). Machine-readable (testing frameworks parse it). Executable (it runs). Self-verifying (it tells you pass or fail).

Unit tests are close, but they fail on human readability. `test "returns {:error, :invalid_credentials} when password hash doesn't match"` is developer-facing, not stakeholder-facing. BDD scenarios describe business behavior. Unit tests describe implementation behavior. When you're telling an AI agent *what to build*, you want business behavior.

Contract specs also come close. The VibeContract research showed that preconditions and postconditions dramatically improve AI code generation -- an LLM-generated ATM system without contracts lacked basic input validation; with contracts, it handled edge cases correctly. But contracts require a developer to write them. BDD scenarios can be co-authored with non-technical stakeholders. The accessibility gap matters when the whole point of SDD is letting non-developers drive the process.

## My Take

If I'd understood this taxonomy a year ago, I would have skipped months of trying to make markdown specs work and gone straight to BDD. I wrote requirements docs. I wrote CLAUDE.md files. I wrote detailed design specs. The agent still built things wrong, and I didn't catch it until manual testing.

The industry is going through that same journey right now. The SDD wave is teaching people to write guidance specs. That's step one. Step two is realizing guidance specs don't verify anything. Step three is landing on BDD -- the spec format that tells the agent what to build AND proves it did it.

Every other spec type in the taxonomy has its place. Standards specs define protocols. API specs enable function calling. Schemas constrain data. Type specs catch errors at compile time. Agent context files set behavioral boundaries. None of them are wrong.

But if you're doing spec-driven development and you want to know which spec to write first, write the BDD spec. It's the only one that simultaneously tells the agent what to build, verifies it built it correctly, and documents what it built for the next developer -- or the next agent -- who comes along.

The spec you want is the one that fails when the code is wrong. Everything else is just asking nicely.
