# Stories MCP Server Component

## Purpose
Provides MCP (Model Context Protocol) server integration for exposing Story operations to LLMs, enabling direct story management during LLM interactions.

## Component Role
Acts as a bridge between the Stories context and external LLM clients, exposing story CRUD operations through standardized MCP tool interfaces.

## Tool Registration
The component registers the following tools with the central MCP server:

### Story Management Tools
- **create_story**: Create new user story with title, description, acceptance criteria
- **update_story**: Update existing story fields with lock validation
- **delete_story**: Remove story from project (with confirmation)
- **get_story**: Retrieve single story by ID with full details
- **list_stories**: List stories for project with filtering options
- **search_stories**: Text search across story titles and descriptions

## Tool Specifications
Each tool defines:
- **Input Schema**: Required and optional parameters with validation rules
- **Output Schema**: Expected response format and data structure
- **Error Handling**: Specific error codes and messages for different failure scenarios

## Integration Pattern
```elixir
# Central MCP Server delegates to Stories component
def handle_call_tool(request_id, %{"name" => "create_story"} = params) do
  CodeMySpec.Stories.MCPServer.handle_create_story(request_id, params)
end

# Stories MCP Server handles the actual operation
def handle_create_story(request_id, %{"arguments" => args}) do
  case Stories.create_story(args) do
    {:ok, story} -> format_success_response(request_id, story)
    {:error, changeset} -> format_error_response(request_id, changeset)
  end
end
```

## Request Flow
1. **Tool Execution**: LLM calls story tool, central server delegates to Stories.MCPServer
2. **Context Operations**: Stories.MCPServer calls appropriate Stories context functions
3. **Response Formatting**: Results formatted according to MCP protocol specifications
4. **Error Handling**: Validation errors, permission failures, and business logic errors properly formatted

## Input Validation
- Schema validation for all tool arguments
- Business rule validation (required fields, field lengths, etc.)
- Permission validation (user access to project/story)
- Lock validation for update operations

## Response Formatting
- Success responses include full story data with metadata
- Error responses include specific error codes and user-friendly messages
- List responses include pagination metadata when applicable
- Search responses include relevance scoring and highlighting

## Error Handling
- **-32602**: Invalid params (schema validation failures)
- **-32603**: Internal error (database/context failures)
- **-32000**: Business logic errors (lock conflicts, permission denied)
- **-32001**: Resource not found (story/project doesn't exist)

## Security Considerations
- All operations require valid user session
- Story access validated against project permissions
- Lock operations tied to specific user sessions
- Audit trail maintained through PaperTrail integration

## Dependencies
- **Stories Context**: For all story CRUD operations
- **MCP Server Library**: For protocol compliance and tool registration
- **User Sessions**: For authentication and lock ownership
- **Project Permissions**: For authorization validation