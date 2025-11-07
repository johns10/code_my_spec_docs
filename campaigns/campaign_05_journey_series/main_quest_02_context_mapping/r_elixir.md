# r/elixir Post: Why I'm Building AI Tools for Elixir (After Trying 5 Other Languages)

## Post Title
"LLMs are terrible at generating Elixir code. That's exactly why they're great at generating Elixir applications."

## Post Body

Full Disclosure: I'm building an AI-assisted development tool for Phoenix applications, and I want to share why I chose Elixir after experimenting with Rust, C#, Python, TypeScript, and JavaScript.

**TLDR**: LLMs suck at writing idiomatic Elixir. They generate verbose if/else chains instead of pattern matching. They ignore OTP patterns. They use cond (bleah). They try/catch all over the place. But here's the thing, they're actually *really good* at generating Elixir applications when you leverage Phoenix's architectural standards.

### The Paradox I Discovered

Elixir was my first love. I started trying to generate code about a year ago, before the models were worth a damn for Elixir code generation. I moved on and spent months trying different languages for AI-assisted development:

- **Rust**: More training data, better library ecosystem, strong type system that should help LLMs
- **Python**: Massive training corpus, LLMs are trained heavily on Python code
- **TypeScript/JavaScript**: Dominant in training data, huge ecosystem
- **C#**: Strong patterns, great compiler checks, good tooling

Every one of these languages has advantages over Elixir for AI code generation. More examples in training data. Better library availability. More Stack Overflow answers to learn from.

But they all produced the same result: **architectural chaos**.

The AI would generate working code, but the application structure is either crap from the beginning, or drifts into lala land quickly.

### Phoenix Contexts

Phoenix contexts are the best architecture I've seen for generating larger applications. Not because LLMs suddenly got better at Elixir syntax. They're still genuinely bad at that. But because **the architectural constraints are so well-defined that they act as rails**.

The community standards Jose and the core team established aren't just good practices. They're *learnable, verifiable patterns* that AI systems can follow:

**Self-contained boundaries**: When an LLM sees `alias MyApp.Repo` in a controller, it's obviously wrong. Controllers call contexts, not Repo. The violation is detectable by both humans and automated tooling.

**Two architectural constructs, not ten**: Contexts and components. That's it. Compare that to traditional DDD with repositories, application services, domain services, entities, value objects, aggregates, ports, adapters... LLMs drown in that complexity. Phoenix's simplicity means fewer architectural decisions to get wrong, and higher success rates in architectural design sessions.

**Consistent patterns across all projects**: Once an LLM learns the context pattern, it applies to every Phoenix application. The predictability is gold for AI systems.

**Validatable designs**: You can check for circular dependencies, entity ownership rules, boundary violations programmatically. The architectural properties Phoenix contexts enforce aren't just conceptual. They're verifiable.

### The Insight That Changed My Approach

I realized the problem wasn't "how do I make LLMs better at Elixir syntax?" It was "how do I structure applications so that even imperfect AI code generation stays on rails?"

Elixir's architectural standards, particularly Phoenix contexts, solve this. The vertical slice architecture, the separation of `MyApp` and `MyAppWeb` namespaces, the explicit context boundaries... these aren't just nice organizational principles. They're **constraints that make AI-generated code maintainable**.

Even when the model screws the pooch and generates terrible code, IT'S ALL CONTAINED IN A SINGLE CONTEXT. It's much easier to catch earlier, and unwind. If you have sufficient design documentation and context, you should be able to fully regenerate the module at any time.

### Why I'm Being Transparent

I'm building a tool (CodeMySpec) that helps developers use AI to generate Phoenix applications following these architectural standards. It's not about making LLMs smarter, it's about leveraging the brilliant standards the Elixir community has already established to keep the LLM on the rails.

I'm posting this because:

1. **My method works, even if you don't use the product** follow my methodology posts. You can see exactly how I used the process manually to build the tool. I know it works, because I used the method to build the tool that implements the method.

2. **The Elixir community deserves credit** for creating and actually sticking to these architectural standards. The quality and consistency across Phoenix projects is rare—most language communities have "best practices" that nobody follows. Also, this community has been incredibly supportive as I've learned Elixir, hosting me at talks and helping me understand the ecosystem. I want to give back by sharing what I've learned.

1. **I want feedback** from experienced Elixir developers. Am I wrong about this? Have you had different experiences with AI code generation in Elixir? 

### The Article

I wrote up a full article about: [Why Phoenix Contexts Are Perfect for LLM-Based Code Generation](https://codemyspec.com/blog/why-phoenix-contexts-are-great-for-llms?utm_source=reddit&utm_medium=social&utm_campaign=journey_series&utm_content=r_elixir_context_mapping)

It covers:
- Why AI tools fail at Elixir (imperative bias, OTP confusion, framework lag)
- Common boundary violations I've seen AI tools make repeatedly
- How context self-containment helps both humans and AI
- Why validatable patterns matter for "almost right" AI output

### The Ask

If you've worked with AI coding tools (ChatGPT, Claude, Copilot) on Elixir projects:

- Have you noticed they struggle with idiomatic code but can follow patterns? What are your approaches to improving code quality?
- Do you see architectural drift when using AI without clear constraints? How do you keep the agent on track to your architecture?
- Does the context pattern help keep AI-generated code maintainable?

I'm genuinely curious if others have had similar experiences or if I'm off-base here.

---

**TL;DR**: After trying Rust, C#, Python, TypeScript, and JavaScript for AI-assisted development, I found Elixir (specifically Phoenix contexts) produces the most maintainable results - not because LLMs are good at Elixir syntax (they're not), but because the community's architectural standards are so well-designed they act as guardrails for AI code generation.