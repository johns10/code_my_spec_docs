# Rules Repository

## Purpose
Provides data access for rule management with account-scoped isolation and pattern matching queries for finding rules based on component types and session types with wildcard support.

## Core Operations/Public API

### Basic CRUD
```elixir
@spec list_rules(Scope.t()) :: [Rule.t()]
@spec get_rule!(Scope.t(), id :: integer()) :: Rule.t()
@spec create_rule(Scope.t(), attrs :: map()) :: {:ok, Rule.t()} | {:error, Changeset.t()}
@spec update_rule(Scope.t(), Rule.t(), attrs :: map()) :: {:ok, Rule.t()} | {:error, Changeset.t()}
@spec delete_rule(Scope.t(), Rule.t()) :: {:ok, Rule.t()} | {:error, Changeset.t()}
```

### Specialized Operations
```elixir
@spec find_matching_rules(Scope.t(), component_type :: String.t(), session_type :: String.t()) :: [Rule.t()]
```

## Function Descriptions

### list_rules/1
Returns all rules for the account in the scope. Uses CodeMySpec.Authorization to verify the user has read access to the account before querying.

### get_rule!/2
Finds a single rule by ID within the account scope. Raises if not found or if user lacks access.

### create_rule/2, update_rule/3, delete_rule/2
Standard CRUD operations that first authorize the user has manage_account permission, then perform the database operation with account_id automatically set from scope.

### find_matching_rules/3
The key function that finds all rules matching the given component and session types. Handles wildcard matching where "*" means "match anything". For example, if you pass component_type="context" and session_type="coding", it will find:
- Rules with component_type="context" AND session_type="coding" (exact match)
- Rules with component_type="*" AND session_type="coding" (any component, specific session)
- Rules with component_type="context" AND session_type="*" (specific component, any session)  
- Rules with component_type="*" AND session_type="*" (global rules)

## Error Handling

### Authorization Errors
- Uses CodeMySpec.Authorization.authorize!/3 which raises "Unauthorized" exceptions
- All operations require :read_account or :manage_account permissions

### Validation Errors
- `{:error, changeset}` for invalid rule attributes
- Database constraint violations on account_id foreign key

### Not Found Errors
- `Ecto.NoResultsError` from get_rule!/2 when rule doesn't exist in account scope

## Usage Patterns

### Query Composition
The find_matching_rules function uses a query like:
```elixir
from r in Rule,
  where: r.account_id == ^scope.active_account_id,
  where: r.component_type == ^component_type or r.component_type == "*",
  where: r.session_type == ^session_type or r.session_type == "*",
  order_by: [r.component_type, r.session_type]
```

This returns rules in a predictable order for the rule composer to concatenate into the final rule string.