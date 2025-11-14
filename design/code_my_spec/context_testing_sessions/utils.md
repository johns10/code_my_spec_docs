# Utils

## Purpose

Utility functions for ContextTestingSessions workflow, including branch name generation for git operations. Provides consistent branch naming conventions that match other session types in the codebase.

## Public API

```elixir
@spec branch_name(session :: Session.t()) :: String.t()
```

## Implementation Details

### branch_name/1

Generates a sanitized git branch name for a context testing session based on the context component name.

**Input:**
- `session :: Session.t()` - Must have type `CodeMySpec.ContextTestingSessions` and preloaded `component` with name

**Output:**
- Returns sanitized branch name string with format: `"test-context-testing-session-for-{sanitized-context-name}"`

**Sanitization Rules:**
1. Convert component name to lowercase
2. Replace all non-alphanumeric characters (except hyphens and underscores) with hyphens
3. Collapse multiple consecutive hyphens into single hyphen
4. Trim leading and trailing hyphens

**Example:**
```elixir
# Component name: "UserAuthentication"
branch_name(session) #=> "test-context-testing-session-for-userauthentication"

# Component name: "Payment Processing!"
branch_name(session) #=> "test-context-testing-session-for-payment-processing"

# Component name: "Data__Export---Module"
branch_name(session) #=> "test-context-testing-session-for-data-export-module"
```

## Test Assertions

- describe "branch_name/1"
  - test "generates branch name with test-context-testing-session-for- prefix"
  - test "converts component name to lowercase"
  - test "replaces special characters with hyphens"
  - test "replaces spaces with hyphens"
  - test "collapses multiple consecutive hyphens"
  - test "preserves existing hyphens and underscores"
  - test "trims leading hyphens"
  - test "trims trailing hyphens"
  - test "handles component names with multiple special characters"
  - test "handles component names that are already sanitized"
