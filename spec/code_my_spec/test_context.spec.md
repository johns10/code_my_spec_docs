# CodeMySpec.TestContext

## Type

context

Test context for the children_designs step-through script.

## Functions

### list_widgets/1

Returns all widgets.

```elixir
@spec list_widgets(Scope.t()) :: [Widget.t()]
```

**Process**:
1. Delegate to WidgetRepository.list_widgets/1

**Test Assertions**:
- returns widgets belonging to the scope

## Dependencies

- CodeMySpec.TestContext.Widget
- CodeMySpec.TestContext.WidgetRepository
- CodeMySpec.Users.Scope

## Components

### CodeMySpec.TestContext.Widget

Ecto schema for widgets.

### CodeMySpec.TestContext.WidgetRepository

Data access layer for widgets.
