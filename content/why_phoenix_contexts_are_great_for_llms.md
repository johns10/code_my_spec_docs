# Why Phoenix Contexts Are Perfect for LLM-Based Code Generation

When generating code with Large Language Models, consistency and predictability are paramount. You need architectural patterns that are self-contained, follow recognizable mental models, and produce testable, maintainable code. Phoenix contexts check all these boxes, making them an ideal choice for AI-assisted development workflows.

## The Challenge: Teaching AI Systems to Write Good Elixir

Current AI coding tools face specific challenges with Elixir that stem from fundamental mismatches between training data and functional programming paradigms:

**Imperative Bias**: Models trained primarily on JavaScript, Python, and Java default to imperative patterns. Instead of function clauses with pattern matching and guards, AI tools often generate verbose if/else chains and case statements. They prefer mutation-style loops over recursive or pipeline-based transformations. This isn't a failure of the AI—it's reflecting the dominant patterns in its training data.

**OTP Pattern Confusion**: Generic process management suggestions ignore supervision trees, GenServers, and the "let it crash" philosophy. AI tools might suggest try/catch error handling where supervision would be more appropriate, or recommend global state management where process-based state would be idiomatic.

**Framework Version Lag**: Training data often reflects older Phoenix versions, leading to deprecated patterns. A common example: generating Phoenix 1.6 EEx syntax (`<%= example %>`) in Phoenix 1.7+ projects that use HEEx (`{example}`). Function signatures change, recommended practices evolve, but training data lags behind.

**Architectural Drift Without Clear Boundaries**: Without well-defined architectural constraints, AI-generated code gradually violates separation of concerns as features accumulate. Business logic creeps into controllers, database access scatters across modules, and context boundaries blur. Each individual AI suggestion might seem reasonable in isolation, but collectively they create architectural chaos.

These aren't random failures—they're predictable consequences of how LLMs learn patterns. The solution isn't better prompting or more specific instructions. The solution is architectural patterns that are consistent, learnable, and verifiable—patterns that give AI systems clear rails to follow.

**Phoenix contexts provide exactly this architecture.**

## What Are Phoenix Contexts?

Phoenix contexts are a code organization pattern introduced in Phoenix 1.3 that groups related functionality around business domains rather than technical concerns. Think of a context as a dedicated module that provides a clear API to the rest of your application for a specific area of your business logic.

For someone unfamiliar with Phoenix, imagine you're building an e-commerce application. Instead of having all your "user" code scattered across models, controllers, and views, a context organizes everything related to user management—authentication, profiles, permissions—into a single, cohesive module called `Accounts`. Similarly, all shopping cart functionality would live in a `Shopping` context, and payment processing in a `Billing` context.

Here's what a typical Phoenix context looks like:

```elixir
defmodule MyApp.Accounts do
  @moduledoc """
  The Accounts context handles user authentication and management.
  """

  alias MyApp.Accounts.User
  alias MyApp.Repo

  def list_users do
    Repo.all(User)
  end

  def get_user!(id), do: Repo.get!(User, id)

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, attrs) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def delete_user(%User{} = user) do
    Repo.delete(user)
  end
end
```

The context module serves as the public interface—the only entry point other parts of your application should use to interact with user-related functionality. This encapsulation is gold for LLM-based code generation.

## The Self-Contained Advantage

Phoenix contexts are remarkably self-contained, which is exactly what LLMs need to generate accurate code. When an AI model analyzes a context module, it finds:

**Clear Boundaries**: Each context has a well-defined scope. The `Accounts` context deals with users and authentication. It doesn't concern itself with products, orders, or payments. This clear delineation makes it easy for an LLM to understand what belongs in a context and what doesn't.

**Encapsulated Dependencies**: All the schemas, queries, and business logic for a domain live together. When generating code for the `Accounts` context, the LLM doesn't need to reason about unrelated parts of the application. It can focus on user-related functionality in isolation.

**Minimal Coupling**: Contexts interact through their public APIs, not by reaching into each other's internals. This loose coupling means an LLM can generate or modify one context without inadvertently breaking another. If you're adding a feature to `Billing`, you don't need to worry about the internals of `Shipping`.

**Complete Functional Units**: A context contains everything needed for its domain to function—data structures, validation logic, database operations, and business rules. This completeness means an LLM can generate a working feature by focusing on a single context, rather than coordinating changes across disparate files.

This self-contained nature dramatically reduces the cognitive load on both humans and AI. The LLM doesn't need to maintain a mental model of your entire application; it only needs to understand the context it's working within.

### Common Boundary Violations AI Tools Make

Without clear context boundaries, AI tools frequently generate code that violates architectural principles. Here's a pattern seen repeatedly in AI-generated Phoenix code:

```elixir
# AI-generated anti-pattern: Direct Repo access in controller
defmodule MyAppWeb.UserController do
  alias MyApp.Accounts.User
  alias MyApp.Repo

  def create(conn, %{"user" => user_params}) do
    # Bypasses context boundary - accesses Repo directly
    case Repo.insert(User.changeset(%User{}, user_params)) do
      {:ok, user} ->
        # Business logic in controller
        send_welcome_email(user)
        render(conn, "show.json", user: user)

      {:error, changeset} ->
        render(conn, "error.json", changeset: changeset)
    end
  end

  defp send_welcome_email(user) do
    # Side effect logic mixed with web layer
    # ...
  end
end
```

This anti-pattern appears innocent—it works, it compiles, it even follows some conventions. But it violates the context boundary by accessing `Repo` directly and mixing business logic (sending emails) into the web layer.

With Phoenix contexts, the boundary is clear and enforceable.

The context boundary makes architectural violations obvious. When an LLM sees `alias MyApp.Repo` in a controller, it's a clear signal that something is wrong—controllers should only interact with contexts, never with Repo directly. This clarity helps both AI systems and human reviewers catch problems immediately.

## The Domain-Driven Design Connection

Phoenix contexts draw heavily from [Domain-Driven Design (DDD)](https://speakerdeck.com/andrewhao/building-beautiful-systems-with-phoenix-contexts-and-ddd) principles, particularly the concept of bounded contexts. This connection provides LLMs with a consistent mental model across projects.

**Ubiquitous Language**: In DDD, each bounded context uses language that reflects the business domain. An `Order` in the `Sales` context might mean something different from an `Order` in the `Inventory` context, and that's okay—each context has its own vocabulary. This alignment with business terminology makes it easier to translate requirements into code. When you tell an LLM "create a context for handling customer subscriptions," it understands you're describing a business domain, not just a technical component.

**Consistent Patterns**: Because Phoenix contexts follow DDD principles, they share similar structures across different applications. An LLM trained on Phoenix codebases recognizes this pattern: contexts contain schemas, changesets, query functions, and business logic functions. This consistency means the model can apply learned patterns reliably, even to domains it hasn't seen before.

**Strategic Design**: DDD emphasizes identifying core domains, supporting domains, and generic subdomains. Phoenix contexts naturally map to these divisions. Your `OrderProcessing` context might be a core domain where you invest heavily in custom logic, while `Notifications` might be a supporting domain with simpler, more generic code. LLMs can leverage these patterns to make appropriate decisions about code complexity and design.

The mental model is transferable. Once an LLM understands how to structure one Phoenix context, it can apply that understanding to any other context in any Phoenix application. This is the consistency that makes AI-assisted development practical.

## Testability: A First-Class Concern

Phoenix contexts are designed with testability built in, and this has profound implications for LLM-generated code quality.

**Clear Test Boundaries**: Because contexts provide public APIs, they create natural test boundaries. You test a context by calling its public functions and asserting on the results. Phoenix even [generates test files for contexts automatically](https://hexdocs.pm/phoenix/testing_contexts.html), providing LLMs with templates to follow:

```elixir
defmodule MyApp.AccountsTest do
  use MyApp.DataCase, async: true

  alias MyApp.Accounts

  describe "users" do
    test "list_users/0 returns all users" do
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "create_user/1 with valid data creates a user" do
      valid_attrs = %{email: "test@example.com", name: "Test User"}
      assert {:ok, %User{} = user} = Accounts.create_user(valid_attrs)
      assert user.email == "test@example.com"
      assert user.name == "Test User"
    end
  end
end
```

**Isolated Testing**: The self-contained nature of contexts means tests can focus on one domain at a time. You don't need elaborate mocking setups or complex test fixtures spanning multiple modules. This isolation makes it easier for LLMs to generate comprehensive test suites without getting tangled in dependencies.

**Predictable Structure**: Phoenix contexts follow consistent patterns for CRUD operations, queries, and business logic. This predictability means LLMs can generate appropriate tests by recognizing the function signature. See `create_user/1`? Generate tests for valid attributes, invalid attributes, and edge cases. See `get_user!/1`? Test the happy path and the exception case.

**ExUnit Integration**: Phoenix contexts integrate seamlessly with Elixir's ExUnit testing framework, which provides excellent support for database testing through [Ecto's SQL Sandbox](https://hexdocs.pm/phoenix/testing_contexts.html). Tests can run concurrently without interfering with each other, making test suites fast and reliable. LLMs can generate tests that leverage this infrastructure without special configuration.

The testability of Phoenix contexts means LLM-generated code isn't just syntactically correct—it comes with tests that verify correctness. You can confidently accept AI-generated features knowing they include automated verification.

## Validatable Patterns: Beyond Syntax Checking

Phoenix contexts enable validation that goes beyond compilation errors and test failures. Because contexts follow predictable architectural patterns, you can validate design decisions programmatically—both during development and as part of automated workflows.

**Dependency Health Validation**: Context dependencies form a directed graph that can be analyzed:
- Are there circular dependencies between contexts?
- Do coordination contexts depend on domain contexts (correct) or vice versa (incorrect)?
- Are cross-context calls going through public APIs rather than reaching into internals?

These structural properties are checkable. If your `Billing` context depends on `Orders`, and `Orders` depends on `Billing`, you have a cycle that indicates poor domain boundaries. AI-generated architectures can be validated against these rules before any code is written.

**Pattern Consistency Validation**: Phoenix contexts follow consistent structural patterns:
- Public functions in the context module, private helpers kept private
- Schemas defined in the context's namespace (`MyApp.Accounts.User`)
- Repo access contained within context boundaries
- Changesets defined on schemas, called from context functions

These patterns are checkable through static analysis. When AI-generated code violates them—like defining a public CRUD function that bypasses changesets, or placing a schema in the wrong namespace—automated validation can catch it.

The self-contained nature of contexts makes this validation practical where it would be impossible with scattered, tightly-coupled code. You're not trying to validate spaghetti. You're validating well defined modules with clear responsibilities and explicit boundaries.

For teams using AI-assisted development, this validation capability is crucial. It addresses the common frustration of "almost right" AI output by providing automated verification that designs meet architectural standards before implementation begins. The consistency of Phoenix contexts makes them not just learnable for AI systems, but verifiable through automated tooling.

## Why Phoenix Contexts Over Other Architectural Patterns?

You might wonder: why not use a different architectural pattern? What makes Phoenix contexts particularly well-suited for LLM-based code generation compared to alternatives like service objects, traditional MVC layers, or full-blown domain-driven design with technical layering?

**Architectural Simplicity: Just Two Constructs**: This is perhaps the most underrated advantage of Phoenix contexts. The entire architecture boils down to two main constructs:

1. **Contexts** - The domain modules that provide public APIs
2. **Schemas/Components** - The data structures and smaller modules that contexts own

That's it. Compare this to a traditional DDD architecture with technical layering, where you might have:
- Infrastructure components
- Repositories
- Domain services
- Application services
- Entities
- Value objects
- Aggregates
- Domain events
- Interfaces/ports
- Adapters

The cognitive overhead of managing all these different architectural constructs is substantial. For an LLM, this complexity multiplies the number of decisions it needs to make: "Should this be a domain service or an application service?" "Is this an entity or a value object?" "Where does this repository interface go?"

With Phoenix contexts, the LLM has far fewer decisions to make: "Does this belong in a context? Which context? Is this a public function or a private helper?" The simplicity dramatically reduces the chance of architectural errors and makes the codebase easier to understand and maintain.

**Versus Traditional MVC**: In classic Model-View-Controller architectures, business logic often gets scattered. Models become bloated with unrelated functionality, or worse, controllers start implementing business rules. Phoenix contexts prevent this by providing a dedicated layer for business logic, separate from web concerns. The [web layer lives in a separate namespace](https://hexdocs.pm/phoenix/contexts.html) (`MyAppWeb`), while contexts live in the application namespace (`MyApp`). This separation gives LLMs clear guidance on where different types of code belong.

**Versus Service Objects and Rails Concerns**: Service objects are fine for single operations, but they don't provide organizational structure for related operations. A context groups all operations for a domain, providing cohesion that service objects lack. Rails concerns, meanwhile, often become dumping grounds for loosely related functionality organized around technical patterns rather than business domains. Phoenix contexts solve both problems: they're organized around business domains and provide structure for grouping related operations.

When you need to coordinate across multiple contexts, Phoenix's simplicity shines again. Rather than adding yet another architectural layer, you can use **coordination contexts**—contexts whose primary purpose is orchestrating operations across other domain contexts. For example:

```elixir
defmodule MyApp.OrderFulfillment do
  @moduledoc """
  Coordinates order processing across multiple domains.
  """
  
  alias MyApp.Orders
  alias MyApp.Inventory
  alias MyApp.Billing
  alias MyApp.Notifications

  def fulfill_order(order_id) do
    with {:ok, order} <- Orders.get_order(order_id),
         {:ok, _} <- Inventory.reserve_items(order.items),
         {:ok, payment} <- Billing.charge_order(order),
         {:ok, _} <- Orders.mark_fulfilled(order) do
      Notifications.send_fulfillment_confirmation(order)
      {:ok, order}
    end
  end
end
```

A coordination context is still just a context—it follows the same patterns and architectural rules. The LLM doesn't need to learn a new construct; it just applies the existing pattern to a coordination use case.

**Versus Microservices**: Here's a key point many miss: Phoenix contexts and microservices aren't mutually exclusive. Contexts provide logical boundaries within your codebase, which can absolutely be deployed as microservices if needed. You can start with a well-organized monolith where contexts provide clear module boundaries, then later extract specific contexts into separate services if your scaling needs demand it.

The beauty is that the context boundaries were there from the start. You're not refactoring spaghetti code to extract a service—you're simply moving a well-defined module to its own deployment. For LLM-based development, this means you can design for eventual distribution without prematurely introducing operational complexity. The AI helps you build clean boundaries from day one, and those boundaries remain valuable whether you deploy as a monolith or microservices.

**Versus Full DDD with Technical Layering**: While Phoenix contexts draw inspiration from DDD's bounded contexts, they deliberately avoid the full complexity of DDD's technical layering. You get the domain-centric organization without the overhead of managing repositories, application services, domain services, and all the interfaces between them. For LLMs generating code, fewer architectural constructs means fewer opportunities for misclassification and confusion. The simplicity is a feature, not a limitation.

## Practical Implications for LLM-Based Development

When you design a Phoenix application around contexts, you unlock several practical advantages for AI-assisted development:

**Prompt Engineering Becomes Easier**: You can give an LLM focused, domain-specific instructions including [relevant user stories](/pages/managing-user-stories) and [context descriptions](/pages/managing-architecture)

**Incremental Feature Development**: Contexts allow you to build features incrementally. Generate the basic CRUD operations first, then add business logic, then add cross-context interactions. Each step builds on the previous one without disrupting existing functionality.

**Code Review Becomes Simpler**: When reviewing LLM-generated code, you can ask: "Does this belong in this context?" "Does it follow the context's existing patterns?" "Are the tests comprehensive?" The structure provides a checklist for code quality.

**Refactoring Is Less Risky**: If a context grows too large, you can split it into multiple contexts with well-defined boundaries. The self-contained nature means refactoring doesn't cascade through your entire application.

**Documentation Writes Itself**: The context structure is self-documenting. When you look at `MyApp.Billing`, you immediately know it handles billing-related operations. The public functions tell you what operations are available. LLMs can generate or enhance documentation that follows this natural structure.

## Working Across Context Boundaries

Real applications need contexts to interact. A `Billing` context might need information from an `Accounts` context. Phoenix provides clear patterns for [cross-context communication](https://hexdocs.pm/phoenix/cross_context_boundaries.html) that LLMs can follow:

**Direct Function Calls**: The simplest approach—one context calls another's public API:

```elixir
defmodule MyApp.Billing do
  alias MyApp.Accounts

  def create_invoice(user_id, items) do
    user = Accounts.get_user!(user_id)
    # Create invoice for user...
  end
end
```

**Data Transformation at Boundaries**: When contexts need to share data structures, [convert at the boundary](https://hexdocs.pm/phoenix/cross_context_boundaries.html):

```elixir
defmodule MyApp.Marketing do
  def subscribe_to_newsletter(user_id) do
    user = Accounts.get_user!(user_id)
    subscriber = user_to_subscriber(user)
    # Subscribe using Marketing's internal representation
  end

  defp user_to_subscriber(%Accounts.User{} = user) do
    %Subscriber{email: user.email, name: user.name}
  end
end
```

**Collaborator Schemas**: For deeper integration, create a schema in one context that [references another context's schema](https://hexdocs.pm/phoenix/in_context_relationships.html):

```elixir
defmodule MyApp.Billing.Invoice do
  use Ecto.Schema

  schema "invoices" do
    belongs_to :user, MyApp.Accounts.User
    field :amount, :decimal
    field :status, :string
  end
end
```

These patterns are consistent and learnable. An LLM can recognize when contexts need to interact and choose the appropriate integration pattern based on the coupling requirements.

## Resources and Further Reading

To dive deeper into Phoenix contexts and their relationship to domain-driven design, explore these resources:

**Official Phoenix Documentation**:
- [Introduction to Contexts](https://hexdocs.pm/phoenix/contexts.html) - The foundational guide
- [Your First Context](https://hexdocs.pm/phoenix/your_first_context.html#grokking-generated-code) - Hands-on tutorial with generated code examples
- [Managing Relationships Within Contexts](https://hexdocs.pm/phoenix/in_context_relationships.html)
- [Cross-Context Boundaries](https://hexdocs.pm/phoenix/cross_context_boundaries.html)
- [More Context Examples](https://hexdocs.pm/phoenix/more_examples.html)
- [Context FAQ](https://hexdocs.pm/phoenix/faq.html)
- [Testing Contexts](https://hexdocs.pm/phoenix/testing_contexts.html)

**Domain-Driven Design and Phoenix**:
- [Building Beautiful Systems with Phoenix Contexts and DDD](https://speakerdeck.com/andrewhao/building-beautiful-systems-with-phoenix-contexts-and-ddd) - Andrew Hao's influential talk
- [Applying DDD for Improved Phoenix Contexts](https://elixirmerge.com/p/applying-ddd-for-improved-phoenix-contexts) - German Velasco's ElixirConf talk
- [Phoenix Context Maintainability Guidelines](https://www.curiosum.com/blog/elixir-phoenix-context-maintainability-guildelines) - Best practices for maintaining contexts

**Testing Resources**:
- [Introduction to Testing in Phoenix](https://hexdocs.pm/phoenix/testing.html)
- [Outside-In TDD with Phoenix](https://yiming.dev/blog/2018/08/04/how-to-do-outside-in-tdd-with-phoenix/) - Test-driven development approach
- [Lessons From Using Phoenix 1.3](https://thoughtbot.com/blog/lessons-from-using-phoenix-1-3) - Real-world experiences with contexts

## Conclusion

Phoenix contexts provide exactly what LLM-based code generation needs: self-contained modules with clear boundaries, consistent patterns rooted in domain-driven design, and built-in testability. These qualities aren't just nice to have—they're essential for AI-assisted development workflows.

When you structure your Phoenix applications around contexts, you're not just organizing code for today. You're creating a foundation that both humans and AI systems can understand, reason about, and extend reliably. The predictability and consistency of contexts dramatically improve the quality of LLM-generated code, while the domain-centric organization ensures the code aligns with your business requirements.

For teams incorporating LLMs into their development process, Phoenix contexts aren't just a good choice—they're the right choice. They provide the architectural framework that makes AI-assisted development practical, productive, and maintainable at scale.

To learn how to apply these principles systematically in your projects, explore [managing user stories](/pages/managing-user-stories) for requirements-driven development and [managing architecture](/pages/managing-architecture) for structured context design workflows.