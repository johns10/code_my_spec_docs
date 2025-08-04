# Rules

## Purpose
Manages dynamic rule composition and storage for generating context-aware design guidelines based on component and session types.

## Entity Ownership
- Rule entities with content and matching criteria
- Rule composition logic for generating final rule strings
- Rule matching based on component types and session types

## Scope Integration
### Accepted Scopes
- **Primary Scope**: CodeMySpec.Users.Scope with active_account_id for account-level rules

### Access Patterns
- All rules filtered by scope.active_account_id for account isolation
- Scope struct contains user, active_account with their IDs
- Rule seeding occurs during account creation to populate base rules from markdown

## Public API
```elixir
# Rule management
@spec list_rules(Scope.t()) :: [Rule.t()]
@spec get_rule!(Scope.t(), id :: integer()) :: Rule.t()
@spec create_rule(Scope.t(), attrs :: map()) :: {:ok, Rule.t()} | {:error, Changeset.t()}
@spec update_rule(Scope.t(), Rule.t(), attrs :: map()) :: {:ok, Rule.t()} | {:error, Changeset.t()}
@spec delete_rule(Scope.t(), Rule.t()) :: {:ok, Rule.t()} | {:error, Changeset.t()}

# Rule composition and matching
@spec find_matching_rules(Scope.t(), component_type :: atom(), session_type :: atom()) :: String.t()

# Rule seeding and initialization
@spec seed_account_rules(Scope.t(), account_id) :: {:ok, [Rule.t()]} | {:error, term()}

@type rule_criteria :: %{
  component_type: String.t() | "*",
  session_type: String.t() | "*"
}

@type rule_attrs :: %{
  name: String.t(),
  content: String.t(),
  component_type: String.t(), # "*" for wildcard, specific type otherwise
  session_type: String.t()    # "*" for wildcard, specific type otherwise
}
```

## State Management Strategy
### Persistence
- Rules stored in database with flexible matching criteria
- Priority-based ordering for rule composition
- Account-scoped isolation via account_id foreign key

### Rule Seeding
- Base rules loaded from markdown files in lib/code_my_spec/rules/content/ directory
- Account creation triggers seeding of base rules for new account
- Markdown frontmatter provides component_type and session_type
- Seeded rules can be customized per account after creation

### Composition
- Rules matched by component type and session type patterns with wildcard support
- Wildcard "*" matches any type (e.g., session_type: "*" applies to all sessions)
- Multiple matching patterns: global (*,*), session-specific (coding,*), component-specific (*,context), specific (coding,context)
- String concatenation with separator handling

## Component Diagram
```
Rules Context
- Rule Schema (account_id, component_type, session_type, content)
- Rule Repository: Standard crud, rule matcher query
- Rule Composer: Takes a list of rules, returns a string representing rules
- Rule Seeder
  - Markdown Parser (lib/code_my_spec/rules/content/)
  - Rule Extractor
  - Account Seeder Hook
```

## Dependencies
- **CodeMySpec.Users.Scope**: Account-level scoping and access control
- **Ecto**: Database persistence and query building
- **Phoenix.PubSub**: Rule change notifications within scope

## Execution Flow
1. **Scope Validation**: Verify user scope and account access permissions
2. **Rule Matching**: Query database for rules where:
   - session_type = "*" OR session_type = current_session_type
   - AND component_type = "*" OR component_type = current_component_type
3. **Content Composition**: Concatenate rule content with proper separators
4. **Result Return**: Return final composed rule string

## Implementation Commands

### Generate Context and Schema
```bash
mix phx.gen.live Rules Rule rules \
  name:string \
  content:text \
  component_type:string \
  session_type:string \
  account_id:references:accounts
```