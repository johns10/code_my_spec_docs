# Component Registry

## Purpose
Central registry containing all component type-specific metadata and behavior definitions. Provides the authoritative source for component type characteristics including requirements, display properties, workflow rules, and validation logic.

## Entity Ownership
- **Type Definitions**: Complete metadata for each component type
- **Requirements Management**: Component type-specific completion criteria
- **Type-Specific Behaviors**: Encapsulates component type rules and constraints
- **Workflow Integration**: Provides type metadata for workflow orchestration

## Architecture Decision

**Context Placement**: This belongs in the Components context, not a separate context.
- Requirements are tightly coupled to component types
- Components context already manages component business logic
- Avoids context sprawl for domain-specific logic

**Schema Strategy**: Use embedded schemas for flexibility without persistence complexity.

## Public API

```elixir
# Registry queries
@spec get_type(component_type()) :: type_definition()
@spec get_requirements_for_type(component_type()) :: [requirement_definition()]
@spec check_requirements_satisfied(Component.t(), component_status()) :: requirement_status()
```

### Coordination Context Requirements
```elixir
coordination_context_requirements = [
  # All context requirements plus:
  %{
    name: :design_review_complete,
    type: :cross_component,
    description: "All related components reviewed together in design workflow",
    checker_module: Components.Requirements.DesignReviewChecker
  }
]
```

## Implementation Strategy

### Test Status Checker
```elixir
defmodule CodeMySpec.Components.Requirements.TestStatusChecker do
  @behaviour CheckerBehaviour

  def check(%{name: :tests_passing}, %{test_exists: test_exists, test_status: test_status}) do
    cond do
      not test_exists -> 
        {:not_satisfied, %{reason: "No test file exists"}}
      test_status == :passing -> 
        {:satisfied, %{status: "Tests are passing"}}
      test_status == :failing -> 
        {:not_satisfied, %{reason: "Tests are failing"}}
      test_status == :not_run -> 
        {:not_satisfied, %{reason: "Tests have not been run"}}
    end
  end
end
```

### Design Review Checker (Future)
```elixir
defmodule CodeMySpec.Components.Requirements.DesignReviewChecker do
  @behaviour CheckerBehaviour

  def check(%{name: :design_review_complete}, %{approvals: approvals}) do
    design_approval = Enum.find(approvals, &(&1.type == :design_review))
    
    if design_approval && design_approval.status == :approved do
      {:satisfied, %{approved_at: design_approval.completed_at}}
    else
      {:not_satisfied, %{reason: "Design review not completed"}}
    end
  end
end
```

## Data Storage Strategy

### No Database Persistence Needed
Requirements definitions are static configuration, stored in code as module attributes.

### Process State Storage
Some requirements need durable state (design reviews, approvals):
- Store in existing workflow/session tables
- Reference by component_id + requirement_type
- Query when checking requirement satisfaction

## Usage Examples

```elixir
# Get requirements for a schema
schema_reqs = Registry.get_requirements_for_type(:schema)
# => [design_file, implementation_file] (no tests)

# Check if component requirements are satisfied  
project_state = %{
  file_tree: file_tree,
  test_results: test_results,
  workflow_records: workflow_records
}

status = Registry.check_requirements_satisfied(component, project_state)
# => %{
#   component: component,
#   requirements: [
#     %{requirement: design_req, satisfied: true, details: %{file_path: "..."}},
#     %{requirement: impl_req, satisfied: false, details: %{missing_file: "..."}}
#   ],
#   overall_satisfied: false
# }
```

## Integration Points

### With ProjectCoordinator
```elixir
# Replace hardcoded logic with registry
def analyze_component(component, project_state) do
  Registry.check_requirements_satisfied(component, project_state)
end
```

### With Future Workflows
```elixir
# Design review workflow can query requirements
def can_start_design_review?(components) do
  Enum.all?(components, fn component ->
    status = Registry.check_requirements_satisfied(component, project_state)
    has_design_file?(status.requirements)
  end)
end
```

## Extension Points

### Adding New Component Types
1. Add to component type enum
2. Define requirements list
3. Add to @requirements map
4. No other changes needed

### Adding New Requirement Types
1. Create new checker module implementing CheckerBehaviour
2. Add requirement definitions using new checker
3. Requirements automatically integrate into existing flows

### Adding Process State Requirements
1. Create workflow records table/schema if needed
2. Create checker module that queries workflow state
3. Define requirements using the checker
4. System handles the rest automatically