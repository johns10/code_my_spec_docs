# CodeMySpec.McpServers.Components.Tools.ContextStatistics

MCP tool that provides statistical overview of component contexts including story counts, dependency counts (incoming/outgoing), and aggregate summaries sorted by story count or dependency count for LLM analysis.

## Dependencies

- CodeMySpec.Components
- CodeMySpec.McpServers.Components.ComponentsMapper
- CodeMySpec.McpServers.Validators
- Hermes.Server.Component
- Hermes.Server.Response

## Functions

### execute/2

Executes the context statistics tool, retrieving components with dependencies and returning statistical analysis sorted by the specified criteria.

```elixir
@spec execute(map(), Hermes.Server.Frame.t()) :: {:reply, Hermes.Server.Response.t(), Hermes.Server.Frame.t()}
```

**Process**:
1. Extract sort_by parameter from params (defaults to "story_count")
2. Validate scope using Validators.validate_scope/1 to ensure active account and project
3. If validation fails, return error response via ComponentsMapper.error/1
4. Retrieve components with dependencies using Components.list_components_with_dependencies/1
5. Build statistics structure by calling build_statistics/2 with components and sort criteria
6. Return tool response with statistics JSON via statistics_response/1

**Test Assertions**:
- returns empty statistics when no components exist
- returns statistics for components with stories and dependencies
- sorts results by story count when sort_by is "story_count"
- sorts results by dependency count when sort_by is "dependency_count"
- defaults to story_count sorting when no sort_by parameter provided
- calculates outgoing, incoming, and total dependency counts correctly
- includes component summary with total components, total stories, total dependencies, and components with stories count
- handles scope validation errors and returns error response
- returns component statistics with id, name, type, and module_name
- aggregates story counts correctly from component associations
