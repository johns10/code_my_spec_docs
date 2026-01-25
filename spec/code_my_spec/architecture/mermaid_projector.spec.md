# CodeMySpec.Architecture.MermaidProjector

**Type**: module

Generates a simple Mermaid flowchart showing contexts and their dependency relationships.

## Delegates

None

## Functions

### project/1

Generates a Mermaid flowchart showing contexts and their dependencies.

```elixir
@spec project([Component.t()]) :: String.t()
```

**Process**:
1. Filter components to include only contexts (type is "context")
2. Generate "flowchart TD" header
3. For each context, generate a node line: `{sanitized_id}[{module_name}]`
   - sanitized_id: module_name with dots replaced by underscores, lowercased
   - module_name: full module name as label
4. For each context with outgoing_dependencies, generate edges: `{source_id} --> {target_id}`
5. Combine all lines with newlines and return

**Test Assertions**:
- generates flowchart TD header
- filters to only include context types
- generates node for each context
- uses sanitized module name as node ID
- uses full module name as node label
- generates edges for dependencies
- handles empty component list
- handles contexts with no dependencies

## Dependencies

- CodeMySpec.Components.Component
