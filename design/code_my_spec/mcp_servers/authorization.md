# MCP Server Authorization Middleware

## Purpose
Handles OAuth2 bearer token authentication for MCP servers using the `init/2` callback and populates the Hermes frame with user context (CodeMySpec.Users.Scope) for authorization in tools and resources.

## Integration Point: init/2 Callback
The `init/2` callback provides the recommended authentication hook:
- Executes during server initialization before any tool/resource calls
- Validates credentials and establishes user context early
- Can return `{:stop, :unauthorized}` to prevent unauthorized access
- Stores authenticated user context in `frame.assigns`

## Authentication Flow

### 1. Token Extraction and Validation
Extract and validate bearer token during server initialization:
```elixir
def init(_arg, frame) do
  case get_bearer_token(frame) do
    {:ok, token} -> authenticate_token(token, frame)
    {:error, :no_token} -> {:stop, :unauthorized}
  end
end

defp get_bearer_token(frame) do
  case get_in(frame.transport, [:headers, "authorization"]) do
    "Bearer " <> token -> {:ok, token}
    _ -> {:error, :no_token}
  end
end
```

### 2. OAuth2 Token Validation
Validate token against existing OAuth2 provider:
```elixir
defp authenticate_token(token, frame) do
  case ExOauth2Provider.AccessTokens.get_by_token(token, otp_app: :code_my_spec) do
    %{} = access_token -> 
      build_authenticated_frame(access_token, frame)
    
    nil -> 
      {:stop, :unauthorized}
  end
end
```

### 3. Scope Building and Frame Assignment
Create CodeMySpec.Users.Scope and store in frame:
```elixir
defp build_authenticated_frame(access_token, frame) do
  user = CodeMySpec.Users.get_user!(access_token.resource_owner_id)
  scope = CodeMySpec.Users.Scope.for_user(user)
  
  authenticated_frame = Map.put(frame, :assigns, %{
    current_scope: scope,
    access_token: access_token
  })
  
  {:ok, authenticated_frame}
end
```

The `Scope.for_user/1` function automatically:
- Loads user preferences to set active account and project
- Handles account/project switching context from user preferences
- Provides complete authorization context for business logic

## Tool/Resource Access Pattern
Tools and resources access authenticated user context:
```elixir
def handle_tool_call("create_story", params, frame) do
  %{current_scope: scope} = frame.assigns
  
  case CodeMySpec.Stories.create_story(scope, params) do
    {:ok, story} -> {:reply, format_story_response(story), frame}
    {:error, changeset} -> {:error, validation_error(changeset), frame}
  end
end
```

Since authentication happens in `init/2`, we can rely on `frame.assigns.current_scope` being present in all tool/resource handlers.

## Account/Project Context
The Scope automatically handles multi-tenant context:
- **active_account**: Loaded from user preferences for data isolation
- **active_project**: Loaded from user preferences for project-scoped operations  
- **Context switching**: Handled through user preference updates in main web app
- **Authorization**: Business logic contexts use `scope.active_account_id` for access control

## Error Handling

### Authentication Failures
Return `:unauthorized` during initialization:
```elixir
def init(_arg, frame) do
  case authenticate_user(frame) do
    {:ok, scope} -> 
      {:ok, Map.put(frame, :assigns, %{current_scope: scope})}
    :error -> 
      {:stop, :unauthorized}  # Prevents server from starting
  end
end
```

### Business Logic Errors
Standard MCP error responses in tool/resource handlers:
```elixir
defp validation_error(changeset) do
  %{
    code: -32602,
    message: "Invalid parameters",
    data: %{
      errors: format_changeset_errors(changeset)
    }
  }
end
```

## Implementation Benefits

### Early Authentication
- Authentication happens once during connection establishment
- All subsequent tool/resource calls are pre-authenticated
- No need to validate tokens on every request
- Clean separation of auth from business logic

### Stateful Context
- User scope persists throughout MCP session
- Account/project switching handled by main app (via user preferences)
- Consistent authorization context across all operations

### Framework Integration
- Follows Hermes MCP recommended patterns
- Leverages existing OAuth2 infrastructure completely
- Maintains compatibility with web app authentication

## Security Considerations

### Token Security
- Bearer token validation on connection establishment
- No token storage beyond session lifetime
- OAuth2 provider handles token expiry and refresh

### Scope Isolation
- Each MCP connection gets isolated user scope
- Account-level data isolation through existing patterns
- Business contexts handle fine-grained permissions

### Connection Management
- Failed authentication prevents connection establishment
- No unauthorized access to any tools or resources
- Clean connection termination on auth failure

## Dependencies
- **ExOauth2Provider.AccessTokens**: OAuth2 bearer token validation and lookup
- **CodeMySpec.Users**: User loading and scope creation
- **CodeMySpec.Users.Scope**: Multi-tenant context with account/project switching
- **CodeMySpec.UserPreferences**: Active account/project resolution