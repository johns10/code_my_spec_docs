# Elixir Application Documentation Design

## Overview

This documentation design provides 1:1 mapping to Phoenix's file structure, with documentation requirements tailored to each file type's specific role and responsibilities.

## Documentation Structure

```
docs/lib/myapp/ (1:1 mapping to Phoenix file structure)
├── todos.ex.md                    # Context module
├── todos/
│   ├── todo.ex.md                 # Ecto schema
│   ├── todo_repository.ex.md      # Repository module
│   ├── todo_policy.ex.md          # Policy module
│   └── queries.ex.md              # Query module
├── order_fulfillment.ex.md        # Coordination context
├── order_fulfillment/
│   ├── saga.ex.md                 # Saga coordinator
│   ├── payment_task.ex.md         # Oban task
│   ├── order_converter.ex.md      # Data converter
│   └── fulfillment_server.ex.md   # GenServer
├── shared/
│   └── email_validator.ex.md      # Shared utility
└── myapp_web/
    ├── controllers/
    │   └── todo_controller.ex.md
    └── live/
        └── todo_live.ex.md
```

## Documentation Requirements by File Type

### Context Modules (`todos.ex.md`)
**Purpose**: Domain boundaries and public API definition
**Required Content**:
- Purpose and entity ownership
- Public API contracts with `@spec`
- State management strategy
- Component diagram showing internal modules (repositories, policies, etc.)

**Example Structure**:
```markdown
# Todos Context

## Purpose
Manages todo items and user task workflows

## Entity Ownership
- Todo items and their lifecycle
- Task categories and priorities

## Public API
```elixir
@spec create_todo(user_id(), todo_params()) :: {:ok, Todo.t()} | {:error, Changeset.t()}
@spec list_todos(user_id()) :: [Todo.t()]
```

## Component Diagram
[Shows TodoRepository, TodoPolicy, Todo schema relationships]
```

### Ecto Schemas (`todo.ex.md`)
**Purpose**: Entity definition and data validation
**Required Content**:
- Entity purpose and lifecycle
- Field definitions and validations
- Relationship mappings
- Changeset functions and validation rules

**Example Structure**:
```markdown
# Todo Schema

## Entity Purpose
Represents a user's task with completion tracking

## Fields
- `title`: String, required, max 255 chars
- `completed_at`: DateTime, nullable
- `user_id`: References users table

## Relationships
- `belongs_to :user`
- `has_many :comments`

## Changesets
- `changeset/2`: Basic validation
- `completion_changeset/2`: Marks as completed
```

### Repository/Policy/Query Modules
**Files**: `todo_repository.ex.md`, `todo_policy.ex.md`, `queries.ex.md`
**Required Content**:
- Sequence diagrams for complex operations
- Function specifications with `@spec`
- Performance considerations (repositories/queries)
- Access control rules (policies)

### Concurrency Primitives
**Files**: `payment_task.ex.md`, `user_server.ex.md`, `cache_agent.ex.md`
**Purpose**: Tasks, GenServers, Agents, and other OTP primitives
**Required Content**:
- Sequence diagrams showing process flows
- Function specifications with `@spec`
- State management (for GenServers/Agents)
- Error handling and supervision strategies

**Example Structure**:
```markdown
# Payment Task

## Purpose
Processes payment transactions asynchronously

## Sequence Diagram
[Shows task execution flow, external API calls, error handling]

## Function Specifications
```elixir
@spec perform(job_args()) :: :ok | {:error, reason()}
```

## Error Handling
- Retry strategy: 3 attempts with exponential backoff
- Dead letter queue for failed payments
```

### Coordination Contexts (`order_fulfillment.ex.md`)
**Purpose**: Cross-context orchestration without entity ownership
**Required Content**:
- Data flow diagrams between contexts
- Sequence diagrams for orchestration patterns
- Component diagram (especially showing converters/mappers)
- Which domain contexts it coordinates
- Public coordination API

**Example Structure**:
```markdown
# Order Fulfillment Coordination

## Purpose
Orchestrates order processing across Payment, Inventory, and Shipping contexts

## Coordinated Contexts
- PaymentContext: Process payments
- InventoryContext: Reserve items
- ShippingContext: Arrange delivery

## Data Flow Diagram
[Shows data transformation between contexts]

## Component Diagram
[Shows OrderConverter, PaymentConverter, fulfillment saga]

## Sequence Diagrams
[Shows saga orchestration patterns, compensation flows]
```

### Converters/Mappers (`order_converter.ex.md`)
**Purpose**: Data transformation between context boundaries
**Required Content**:
- Sequence diagrams for transformation flows
- Function specifications with `@spec`
- Data mapping rules between contexts

## Context Level Documentation

Contexts come in two types: **Domain Contexts** (own entities and business logic) and **Coordination Contexts** (orchestrate between domain contexts).

### Purpose
- **Domain Contexts**: Define bounded context boundaries, entity ownership, and business rules
- **Coordination Contexts**: Handle orchestration between domain contexts without owning entities

### Required Documents

**design.md**
- Context purpose and responsibilities
- Context type (domain or coordination)
- For domain contexts: Entity ownership and business rules
- For coordination contexts: Which domain contexts are coordinated
- State Management section:
  - Database schemas and entities (domain contexts only)
  - Stateful vs stateless components
  - Shared state (ETS tables, caches)
  - State lifecycle management
- External dependencies
- Public API contracts

**component_diagram.md**
- Visual representation of internal components
- Component relationships and dependencies
- Data flow between components

**sequence_diagram.md** (all contexts)
- Internal orchestration flows
- Key interaction patterns
- Error handling flows

**data_flow_diagram.md** (coordination contexts only)
- Data transformation between domain contexts
- Mapping between context boundaries
- Cross-context orchestration patterns

### Contract Definition
```elixir
# Domain context API contract
@type user_params() :: %{name: String.t(), email: String.t()}
@type result() :: {:ok, User.t()} | {:error, String.t()}
@spec create_user(user_params()) :: result()

# Coordination context API contract  
@type order_fulfillment_params() :: %{order_id: String.t(), user_id: String.t()}
@type fulfillment_result() :: {:ok, :completed} | {:error, :payment_failed | :inventory_unavailable}
@spec fulfill_order(order_fulfillment_params()) :: fulfillment_result()
```

## Component Level Documentation

### Purpose
Define implementation details, types, and contracts for individual modules within contexts.

### Required Documents

**[module_name].ex.md**
- Purpose and responsibility
- Dependencies (explicit references to other modules):
  ```markdown
  ## Dependencies
  - [EmailValidator](../shared/email_validator.ex.md) - validates email format
  - [UserRepository](./user_repository.ex.md) - persistence interface
  ```
- Content varies by file type (see Documentation Requirements by File Type above)
- Usage examples where applicable

### Interface Definition
```elixir
# Module types and contracts
@type module_state() :: %{field: type()}
@spec public_function(input_type()) :: output_type()
```



## Documentation Principles

### Self-Contained Documents
Each document should be independently readable with explicit references to dependencies:

```markdown
## Dependencies
- [ContextName.FunctionName](../../contexts/context_name/design.md#function-name)
- [ComponentName](./component_name.md)
```

### Reference Rules (Preventing Leakage)
- **Domain context modules**: Reference other contexts only through public APIs
- **Coordination context modules**: Reference domain context interfaces, never internal modules
- **Internal modules**: Reference only modules within same context + shared utilities
- **Web layer modules**: Reference context public APIs only

**Valid References:**
```markdown
# Same context - OK
[UserValidator](./user_validator.ex.md)

# Cross-context public interface - OK  
[UserContext.CreateUser](../user.ex.md#create-user)

# Coordination context referencing domain context API - OK
[OrderContext.GetOrder](../order.ex.md#get-order)

# Web layer referencing context - OK
[UserContext](../../lib/myapp/user.ex.md)
```

**Invalid References (indicate leakage):**
```markdown
# Coordination context referencing internal module - BAD
[UserRepository](../user/user_repository.ex.md)

# Domain context referencing coordination internals - BAD
[OrderFulfillmentWorker](../order_fulfillment/fulfillment_worker.ex.md)

# Controller referencing internal module - BAD  
[UserRepository](../../lib/myapp/user/user_repository.ex.md)
```

### State Management Integration

Rather than separate documentation types, integrate concerns based on file type and responsibility:

**Domain Context Level**: Entity ownership, business rules, and public API definition
**Coordination Context Level**: Cross-context orchestration with data flow and component diagrams  
**Module Level**: File-specific requirements based on role (schema, repository, task, etc.)

### Elixir-Specific Considerations

**Type Safety**: Use `@spec` and `@type` definitions in documentation
**Error Handling**: Follow "let it crash" philosophy - document supervision strategies
**Contracts**: Define explicit structs with `@enforce_keys` for data crossing boundaries
**Validation**: Use Ecto changesets for boundary validation

### Implementation Support

**Compiler Integration**:
```elixir
# mix.exs
elixirc_options: [warnings_as_errors: true]
```

**Static Analysis**:
```elixir
# Dialyzer for type checking
dialyzer: [flags: [:error_handling, :underspecs, :unknown]]
```

**Boundary Enforcement**:
```elixir
# Explicit structs for data boundaries
defmodule UserData do
  @enforce_keys [:id, :email]
  defstruct [:id, :name, :email]
  
  @type t() :: %__MODULE__{
    id: String.t(),
    name: String.t() | nil,
    email: String.t()
  }
end
```

## Benefits

1. **1:1 File Mapping**: Every Phoenix file gets corresponding documentation
2. **Type-Specific Requirements**: Each file type has tailored documentation needs
3. **Prevents Complexity Leakage**: Explicit boundaries between domain and coordination contexts
4. **Maintains Phoenix Patterns**: Uses standard Phoenix file organization
5. **Tool-Supported**: Leverages Elixir's type system and compiler warnings
6. **Scalable**: Clear patterns for documenting any Phoenix file type