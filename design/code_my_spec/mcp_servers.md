# MCP Servers Context

## Purpose
Provides Model Context Protocol (MCP) interfaces for application domains while keeping MCP concerns separate from core business logic. Uses domain-specific MCP servers to enable clean separation of protocol handling from business operations.

## Architecture Philosophy
Instead of polluting individual domain contexts with MCP server code, we isolate all MCP protocol handling in this dedicated context. The Stories domain gets its own MCP server that acts as a thin interface layer over the existing Stories business logic.

## Current Servers
- **Stories Server**: Manages user story operations through MCP interface

## Common Infrastructure

### Authorization Middleware
MCP servers use OAuth2 bearer token authentication:
- Validates incoming bearer tokens against OAuth2 provider
- Converts tokens to user scopes for domain authorization
- Maintains existing security boundaries and permissions

### Transport Layer
Hermes handles the underlying MCP transport:
- HTTP/HTTPS for standard request-response
- Server-Sent Events (SSE) for real-time updates  
- Phoenix routing integration for web app compatibility

### Process Management
Hermes manages MCP server processes:
- Built-in process supervision and lifecycle
- No need for custom GenServer implementations
- Framework handles protocol details and connection management

## MCP Protocol Features

### Tools (Write Operations)
Side-effecting operations that modify application state:
- Create, update, delete operations
- Operations execute immediately through business logic
- Business logic handles any approval workflows internally

### Resources (Read Operations)
Read-only data access with structured URIs:
- Individual entity lookups (story://id)
- Collection queries (stories://project_id)
- Search and filtering capabilities

### Prompts (LLM Assistance)
Context-aware guidance for AI interactions:
- Domain-specific writing assistance
- Review and validation prompts
- Story estimation and planning helpers

## Integration Points

### With Phoenix Router
Stories MCP server mounts at dedicated endpoint:
```
/mcp/stories -> Stories MCP Server
```

### With Existing Contexts
MCP servers delegate to existing business logic:
- Stories MCP Server � CodeMySpec.Stories context
- No duplication of business rules or data access patterns
- Business logic handles complex workflows and approval processes

### With Authorization System
Leverages existing authorization infrastructure:
- OAuth2 token validation through ExOauth2Provider
- Scope-based permissions using existing Scope system
- Account-level access control maintained

## Error Handling Strategy
Standardized error responses:
- Proper MCP error codes and formatting
- Graceful degradation on service failures
- Authentication and authorization error handling

## Components
- **Stories MCP Server**: [stories/](./mcp_servers/stories/) - Story management interface
- **Authorization Middleware**: OAuth2 token validation and scope building
- **Transport Integration**: Hermes framework integration with Phoenix
