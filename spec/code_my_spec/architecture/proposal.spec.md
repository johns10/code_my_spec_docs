# CodeMySpec.Architecture.Proposal

Represents an architecture proposal for a greenfield project. A proposal contains bounded contexts with their child components, surface components (controllers, LiveViews), story mappings, and dependencies between components.

Proposals are ephemeral - they exist only during a design session. Use `validate/1` to check for issues before `execute/2`.

## Type

module

## Fields

| Field | Type | Required | Description | Constraints |
| ----- | ---- | -------- | ----------- | ----------- |
| app_name | string | Yes | Application module name (e.g., "MetricFlow") | Defaults to "App" |
| contexts | list(context) | No | Bounded contexts with child components | Defaults to [] |
| surface_components | list(component) | No | Surface components (LiveViews, Controllers) | Defaults to [] |
| dependencies | list(dependency) | No | Component dependencies as from/to pairs | Defaults to [] |
| unmapped_story_ids | list(integer) | No | Story IDs not mapped to any component | Defaults to [] |

## Dependencies

- CodeMySpec.Components
- CodeMySpec.Environments
- CodeMySpec.Stories
- CodeMySpec.Documents

## Functions

### new/1

Creates a new proposal from a map of attributes. Supports both atom and string keys for flexibility when parsing from different sources.

```elixir
@spec new(map()) :: t()
```

**Process**:
1. Extract app_name from attrs, defaulting to "App"
2. Normalize contexts using `normalize_contexts/1`
3. Normalize surface_components using `normalize_components/1`
4. Normalize dependencies using `normalize_dependencies/1`
5. Return the populated Proposal struct

**Test Assertions**:
- creates proposal from map with atom keys
- creates proposal from map with string keys
- defaults app_name to 'App' when not provided

### from_markdown/2

Creates a proposal from a parsed markdown document. Uses the Documents system to parse the architecture_proposal document type.

```elixir
@spec from_markdown(String.t(), keyword()) :: {:ok, t()} | {:error, String.t()}
```

**Process**:
1. Validate that app_name option is provided (raises if missing)
2. Parse markdown using Documents.create_dynamic_document with "architecture_proposal" type
3. Transform dependencies section from "From -> To" strings to maps
4. Build proposal struct via new/1 with parsed sections

**Test Assertions**:
- parses surface component descriptions from markdown
- parses child component descriptions from markdown
- descriptions flow through to_components
- parses dependencies from markdown
- parses alternate format with description as plain paragraph
- parses nested child module names

### validate/2

Validates a proposal for architectural issues. Runs multiple validation checks and returns all errors found.

```elixir
@spec validate(t(), keyword()) :: {:ok, t()} | {:error, [validation_error()]}
```

**Process**:
1. Check naming conventions (valid PascalCase module names)
2. Check naming hierarchy (contexts start with app_name, surfaces with AppWeb, children with parent name)
3. Check consecutive capitals (LLM -> l_l_m.ex, use Llm for llm.ex)
4. Check component types are valid (context, schema, module, liveview, controller, component, channel, plug)
5. Check story-surface mapping (all stories must map to surface components when story_ids provided)
6. Check for circular dependencies using DFS cycle detection
7. Check for duplicate component names
8. Return {:ok, proposal} if no errors, {:error, errors} otherwise

**Test Assertions**:
- returns ok for valid proposal with dual story mapping
- returns error for invalid module names
- returns error for duplicate names
- returns error for circular dependencies
- requires stories to be mapped to surface components
- accepts stories mapped to both surface and context
- accepts stories mapped to context itself (not just children)
- returns error for child not starting with parent context name
- returns error for context not starting with app name
- returns error for surface component not starting with app web name
- returns error for consecutive capital letters in module names
- returns error for invalid component types

### execute/3

Executes the proposal, creating spec files and linking stories to components.

```elixir
@spec execute(t(), Scope.t(), keyword()) :: {:ok, map()} | {:error, term()}
```

**Process**:
1. If dry_run option is true, return preview without making changes
2. Convert proposal to flat component list via to_components/1
3. Create CLI environment for file operations
4. Write spec file for each component to docs/spec/ path
5. Sync each component to database via Components.upsert_component
6. Link stories to surface components (liveview, controller types only)
7. Return counts of created contexts, components, and linked stories

**Test Assertions**:
- returns preview without creating files (dry_run: true)
- skips writing spec file if it already exists

**Integration Test Assertions**:
- creates spec files at correct paths
- syncs components to database
- links stories to surface components only
- links stories to pre-existing surface components

### to_components/1

Returns all component definitions from the proposal as a flat list for creation.

```elixir
@spec to_components(t()) :: [map()]
```

**Process**:
1. Build dependencies map from dependency list (from -> [to, ...])
2. Flat-map contexts to include parent context and all children
3. Map surface components with their metadata
4. Include module_name, type, description, story_ids, dependencies for each
5. Add parent_module for child components
6. Concatenate context components with surface components

**Test Assertions**:
- returns all components from contexts and surface
- context has type "context"
- child components include parent_module reference
- surface components have correct type
