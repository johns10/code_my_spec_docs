# CodeMySpec.Utils.Paths

Utilities for resolving and working with file system paths within the project, particularly for determining context paths.

## Functions

### resolve_context_path/1

```elixir
@spec resolve_context_path(String.t()) :: {:ok, String.t()} | {:error, :not_a_context_path}
```

Takes any file path (spec file, implementation file, test file, or directory) and returns the canonical context path.

The canonical context path is the path that can be used to query and identify a context in the database.

**Logic**:

1. **Spec File Path** (ends with `.spec.md`)
   - Extract the directory containing the spec file
   - That directory is the canonical context path
   - Example: `docs/spec/code_my_spec/accounts.spec.md` -> `docs/spec/code_my_spec/accounts`
   - Example: `docs/spec/code_my_spec/accounts/accounts.spec.md` -> `docs/spec/code_my_spec/accounts`

2. **Implementation File Path** (`.ex` file in `lib/`)
   - Determine if it's a context file (main file defining the context)
   - If it's `lib/my_app/accounts.ex`, the context path is `lib/my_app/accounts`
   - If it's a file within a context directory like `lib/my_app/accounts/user.ex`, the context path is `lib/my_app/accounts`

3. **Directory Path**
   - If the path is already a directory, verify it represents a valid context
   - Check for either a matching spec file or a matching context implementation file
   - Return the directory path as the canonical context path

4. **Error Cases**
   - Return `{:error, :not_a_context_path}` if the path doesn't correspond to any context
   - This includes files that are not part of a context structure

**Examples**:

```elixir
# Spec file -> context directory
resolve_context_path("docs/spec/code_my_spec/accounts.spec.md")
# => {:ok, "docs/spec/code_my_spec/accounts"}

# Spec file in subdirectory -> context directory
resolve_context_path("docs/spec/code_my_spec/accounts/accounts.spec.md")
# => {:ok, "docs/spec/code_my_spec/accounts"}

# Implementation context file -> context directory
resolve_context_path("lib/code_my_spec/accounts.ex")
# => {:ok, "lib/code_my_spec/accounts"}

# Component file within context -> context directory
resolve_context_path("lib/code_my_spec/accounts/user.ex")
# => {:ok, "lib/code_my_spec/accounts"}

# Direct context directory path
resolve_context_path("docs/spec/code_my_spec/accounts")
# => {:ok, "docs/spec/code_my_spec/accounts"}

# Non-context file
resolve_context_path("lib/code_my_spec/utils/paths.ex")
# => {:error, :not_a_context_path}
```

**Test Assertions**:

- resolve_context_path/1 extracts context path from spec file
- resolve_context_path/1 extracts context path from spec file in subdirectory
- resolve_context_path/1 extracts context path from context implementation file
- resolve_context_path/1 extracts context path from component file within context
- resolve_context_path/1 extracts context path from test file
- resolve_context_path/1 extracts context path from test file in subdirectory
- resolve_context_path/1 accepts direct context directory path
- resolve_context_path/1 returns error for non-context files
- resolve_context_path/1 returns error for invalid paths
- resolve_context_path/1 handles absolute and relative paths
- resolve_context_path/1 normalizes path separators
