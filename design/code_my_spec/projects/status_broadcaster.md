# StatusBroadcaster Module

## Purpose
Handles real-time broadcasting of project status updates using Phoenix PubSub, enabling live updates in user interfaces.

## Public API
```elixir
# Status Broadcasting
@spec broadcast_project_update(Project.t()) :: :ok
@spec broadcast_project_error(Project.t(), String.t()) :: :ok

# Topic Management
@spec project_topic(String.t()) :: String.t()

# Subscription Helpers
@spec subscribe_to_project(String.t()) :: :ok | {:error, term()}
@spec subscribe_to_all_projects() :: :ok | {:error, term()}
@spec unsubscribe_from_project(String.t()) :: :ok
@spec unsubscribe_from_all_projects() :: :ok
```

## Function Descriptions

### Broadcast Project Update
The primary function for broadcasting project changes. Accepts a complete project record and broadcasts it to the project-specific topic. Called after the ProjectSetup module updates the project status in the database.

### Broadcast Project Error
Specialized function for broadcasting error states. Includes both the updated project record and the error message in the broadcast payload, allowing subscribers to display detailed error information to users.

### Topic Management
The module uses a consistent topic naming scheme:
- **Project-specific topics**: `"projects:#{project_id}"` for updates to individual projects
- **All projects subscription**: `"projects:*"` pattern for updates to any project

This allows UI components to subscribe to either specific projects they're monitoring or all project updates for dashboard views using the wildcard pattern.

### Subscription Helpers
Convenience functions for subscribing to and unsubscribing from project updates. The `subscribe_to_all_projects/0` function uses the `"projects:*"` pattern to receive updates from all project-specific topics.

## Message Formats

### Project Update Messages
```elixir
%{
  event: "project_updated",
  project: %Project{
    id: "uuid",
    name: "my_app",
    status: :compiling,
    code_repo: "https://github.com/user/my_app",
    docs_repo: "https://github.com/user/my_app_docs",
    inserted_at: ~U[2024-01-01 12:00:00Z],
    updated_at: ~U[2024-01-01 12:05:00Z]
  }
}
```

### Error Messages
```elixir
%{
  event: "project_error",
  project: %Project{...},  # Full project struct with status: :failed
  error: "Mix deps.get failed"
}
```

## Update Flow
1. **ProjectSetup Module**: Updates project status in database
2. **Database Update**: Project record is updated with new status
3. **StatusBroadcaster**: Called with updated project struct
4. **Broadcast**: Message sent to project-specific topic `"projects:#{project_id}"`
5. **Subscribers**: Receive full project data, no need to re-query

## Usage Patterns

### Broadcasting from Setup Process
The StatusBroadcaster is called by the ProjectSetup module after each database update:

```elixir
# ProjectSetup updates DB and broadcasts
{:ok, updated_project} = Projects.Repository.update_project_status(project.id, :compiling)
StatusBroadcaster.broadcast_project_update(updated_project)
```

### Subscribing in LiveView
LiveView components can subscribe to project updates and receive full project data:

```elixir
def mount(%{"project_id" => project_id}, _session, socket) do
  StatusBroadcaster.subscribe_to_project(project_id)
  {:ok, assign(socket, :project_id, project_id)}
end

def handle_info(%{event: "project_updated", project: project}, socket) do
  {:noreply, assign(socket, :project, project)}
end
```

### Dashboard Subscriptions
Dashboard views can subscribe to all project updates:

```elixir
def mount(_params, _session, socket) do
  StatusBroadcaster.subscribe_to_all_projects()
  {:ok, assign(socket, :projects, [])}
end
```

## Integration Points

### Phoenix PubSub
The module integrates directly with Phoenix PubSub for message broadcasting and subscription management. Uses the `"projects:*"` pattern for wildcard subscriptions.

### ProjectSetup Module
Called by the setup process to broadcast status changes after database updates are complete.

### LiveView Components
Consumed by LiveView components that display real-time project status updates to users without needing to re-query the database.

## Error Handling
Broadcasting failures are logged but don't interrupt the main project setup process. The module is designed to be resilient to PubSub failures, ensuring that project setup continues even if status broadcasting fails.

## Performance Considerations
The module uses Phoenix PubSub's efficient message routing and wildcard patterns to minimize overhead. Project-specific topics with wildcard subscriptions provide flexible subscription patterns while maintaining performance.