# Why Phoenix Contexts Are Perfect for LLM Code Generation

When generating code with LLMs, you need architectural patterns that are self-contained, follow recognizable mental models, and produce testable code. Phoenix contexts nail all three.

## The Problem: AI Writing Elixir

LLMs trained primarily on JavaScript, Python, and Java default to imperative patterns. Instead of function clauses with pattern matching, they generate verbose if/else chains. Instead of supervision trees, they suggest try/catch. Instead of pipelines, they write mutation-style loops.

This isn't a failure of AI. It's reflecting dominant patterns in training data.

Without clear architectural constraints, the drift gets worse over time. Business logic creeps into controllers. Database access scatters across modules. Context boundaries blur. Each individual AI suggestion seems reasonable. Collectively, they create architectural chaos.

The fix isn't better prompting. It's architectural patterns that are consistent, learnable, and verifiable.

**Phoenix contexts provide exactly this.**

## What Are Phoenix Contexts?

Contexts group related functionality around business domains rather than technical concerns. Instead of scattering "user" code across models, controllers, and views, a context organizes everything related to user management into a single module called `Accounts`. Shopping cart logic lives in `Shopping`. Payment processing in `Billing`.

The context module is the public interface -- the only entry point other parts of your application should use.

In CodeMySpec, we extend this further. We have two types of contexts: **context** (domain logic) and **coordination_context** (orchestrates across child contexts). Child components -- schema, repository, GenServer, task, controller, LiveView, and others (14 types total) -- live inside their parent context's namespace. All public context functions take `%Scope{}` as the first parameter.

## Why This Works for LLMs

### Self-Contained Units

Each context has a well-defined scope. The LLM doesn't need to maintain a mental model of your entire application -- it only needs to understand the context it's working within.

Encapsulated dependencies. Minimal coupling. Complete functional units. When the LLM generates code for `Billing`, it focuses on billing in isolation. It can't accidentally break `Shipping`.

### Boundary Enforcement

Here's the thing. Without enforcement, contexts are just a convention. LLMs ignore conventions.

We use `use Boundary` in every module for compile-time dependency enforcement. 14 component types, each with specific requirements. The compiler catches dependency violations, not code reviewers. When an LLM generates `alias MyApp.Repo` in a controller, the build fails. Not "flagged for review." Fails.

### Just Two Core Constructs

This is the most underrated advantage. The entire architecture boils down to:

1. **Contexts** -- domain modules providing public APIs
2. **Child components** -- schemas, repositories, GenServers, tasks, etc. that contexts own

Compare that to traditional DDD with infrastructure components, repositories, domain services, application services, entities, value objects, aggregates, domain events, ports, and adapters. That's ten constructs where we have two.

For an LLM, fewer constructs means fewer decisions. "Does this belong in a context? Which context? Is this a public function or a private helper?" That's it.

### Coordination Without New Abstractions

When you need to coordinate across contexts, you don't add another architectural layer. You create a coordination context:

```elixir
defmodule MyApp.OrderFulfillment do
  alias MyApp.Orders
  alias MyApp.Inventory
  alias MyApp.Billing

  def fulfill_order(%Scope{} = scope, order_id) do
    with {:ok, order} <- Orders.get_order(scope, order_id),
         {:ok, _} <- Inventory.reserve_items(scope, order.items),
         {:ok, _} <- Billing.charge_order(scope, order) do
      Orders.mark_fulfilled(scope, order)
    end
  end
end
```

Same pattern, same rules. The LLM doesn't learn a new construct -- it applies the existing one.

## Testability Built In

Contexts create natural test boundaries. You test the public API and assert on results. One test file per code file, matching the 1:1:1 principle (spec, code, test).

```elixir
defmodule MyApp.AccountsTest do
  use MyApp.DataCase, async: true

  describe "users" do
    test "create_user/2 with valid data creates a user" do
      scope = user_scope_fixture()
      valid_attrs = %{email: "test@example.com", name: "Test User"}
      assert {:ok, %User{} = user} = Accounts.create_user(scope, valid_attrs)
    end
  end
end
```

Isolated. Predictable. The LLM recognizes function signatures and generates appropriate tests -- happy path, error cases, edge cases. No elaborate mocking setups.

## Validatable Architecture

Because contexts follow predictable patterns, we can validate design decisions programmatically -- not just test behavior.

**Dependency health**: Context dependencies form a directed graph. Circular dependencies? The dependency checker catches them. Coordination contexts depending on domain contexts (correct) versus the reverse (incorrect)? Checked automatically.

**Pattern consistency**: Public functions in the context module. Schemas in the context's namespace. Repo access contained within boundaries. These patterns are checkable through static analysis. When AI-generated code violates them, 22 requirement checkers catch it before any human reviews.

**Document structure**: Each of our 14 component types has specific required and optional sections in its spec document. The validation pipeline rejects malformed specs before implementation begins.

You're not trying to validate spaghetti. You're validating well-defined modules with clear responsibilities and explicit boundaries.

## vs. Other Patterns

**vs. Traditional MVC**: Business logic scatters. Models bloat. Controllers implement business rules. Phoenix contexts prevent this with a dedicated layer separated from web concerns (`MyApp` vs `MyAppWeb`).

**vs. Service Objects**: Fine for single operations. No organizational structure for related operations. Contexts group all operations for a domain, providing cohesion service objects lack.

**vs. Full DDD Layering**: You get domain-centric organization without managing repositories, application services, domain services, and all the interfaces between them. Fewer constructs, fewer misclassification opportunities for LLMs.

**vs. Microservices**: Not mutually exclusive. Contexts provide logical boundaries within your codebase. Start with a well-organized monolith. Extract specific contexts into services later if scaling demands it. The boundaries were there from the start -- you're moving a well-defined module, not refactoring spaghetti.

## What This Means in Practice

When you structure a Phoenix application around contexts, LLM-assisted development gets dramatically easier:

- **Scoped generation**: Give the LLM one context, its spec, its component graph. That's all it needs.
- **Incremental building**: Generate CRUD operations first, add business logic, then cross-context interactions.
- **Clear review criteria**: "Does this belong in this context? Does it follow existing patterns? Are the tests covering the right behavior?"
- **Safe refactoring**: If a context grows too large, split it. Self-contained nature means changes don't cascade.

## The Bottom Line

Phoenix contexts give LLM-based code generation exactly what it needs: self-contained modules with clear boundaries, consistent patterns rooted in DDD, compile-time boundary enforcement, and built-in testability.

When you pair this with a validation pipeline that checks 22 requirements across the full stack -- compiler, tests, static analysis, BDD specs, document structure -- you get AI-generated code you can actually trust.

For teams using LLMs in their development process, Phoenix contexts aren't just a good organizational choice. They're the architectural foundation that makes the whole thing work.
