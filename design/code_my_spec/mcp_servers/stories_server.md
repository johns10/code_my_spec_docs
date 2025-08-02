# Stories MCP Server

## Purpose
Provides MCP interface for story management operations using dedicated tool and resource components. Acts as a thin protocol layer over the existing CodeMySpec.Stories context with proper authentication and response formatting.

## Server Structure
Uses Hermes.Server with component-based architecture:
```elixir
defmodule CodeMySpec.MCPServers.StoriesServer do
  use Hermes.Server,
    name: "stories-server",
    version: "1.0.0", 
    capabilities: [:tools, :resources, :prompts]

  # Tool components
  component CodeMySpec.MCPServers.Stories.Tools.CreateStory
  component CodeMySpec.MCPServers.Stories.Tools.CreateStories
  component CodeMySpec.MCPServers.Stories.Tools.UpdateStory
  component CodeMySpec.MCPServers.Stories.Tools.DeleteStory
  component CodeMySpec.MCPServers.Stories.Tools.SetStoryComponent
  component CodeMySpec.MCPServers.Stories.Tools.ClearStoryComponent
  
  # Resource components  
  component CodeMySpec.MCPServers.Stories.Resources.Story
  component CodeMySpec.MCPServers.Stories.Resources.StoriesList
  
  # Prompt components (conversation starters)
  component CodeMySpec.MCPServers.Stories.Prompts.StoryInterview
  component CodeMySpec.MCPServers.Stories.Prompts.StoryReview
  
  def init(_arg, frame) do
    # Delegate to authorization middleware
    CodeMySpec.MCPServers.Authorization.authenticate(frame)
  end
end
```

## Component Architecture

### Tool Components
Each tool is a dedicated module with schema and execute function:
- **CreateStory**: Handles story creation with validation
- **CreateStories**: Handles multiple story creation with validation
- **UpdateStory**: Manages story updates with authorization
- **DeleteStory**: Handles story deletion with ownership checks
- **SetStoryComponent**: Assigns component to story for satisfaction tracking
- **ClearStoryComponent**: Removes component assignment from story

### Resource Components
Dedicated modules for read-only data access:
- **Story**: Individual story lookup by ID
- **StoriesList**: Collection of stories by project

### Prompt Components (Conversation Starters)
Context-aware prompts that include current project stories:
- **StoryInterview**: Product manager persona for story refinement with leading questions
- **StoryReview**: Product manager persona for story completeness validation

### Shared Utilities
Common helpers used across components:
- **StoriesMapper**: Response formatting utilities using Hermes Response helpers

## Tool Implementation Pattern
```elixir
defmodule CodeMySpec.MCPServers.Stories.Tools.CreateStory do
  @moduledoc "Creates a user story"

  use Hermes.Server.Component, type: :tool

  alias CodeMySpec.Stories
  alias CodeMySpec.MCPServers.Stories.StoriesMapper
  alias CodeMySpec.MCPServers.Validators

  schema do
    field :title, :string, required: true
    field :description, :string, required: true
    field :acceptance_criteria, {:list, :string}, default: []
  end

  @impl true
  def execute(params, frame) do
    with {:ok, scope} <- Validators.validate_scope(frame),
         {:ok, story} <- Stories.create_story(scope, params) do
      {:reply, StoriesMapper.story_response(story), frame}
    else
      {:error, changeset = %Ecto.Changeset{}} ->
        {:reply, StoriesMapper.validation_error(changeset), frame}

      {:error, atom} ->
        {:reply, StoriesMapper.error(atom), frame}
    end
  end
end
```

## Resource Implementation Pattern
```elixir
defmodule CodeMySpec.MCPServers.Stories.Resources.Story do
  use Hermes.Server.Component, type: :resource

  alias CodeMySpec.Stories
  alias CodeMySpec.MCPServers.Stories.StoriesMapper
  alias CodeMySpec.MCPServers.Validators

  def uri_template, do: "story://{story_id}"
  def uri, do: "story://template"
  def mime_type, do: "application/json"

  def read(%{"story_id" => story_id}, frame) do
    with {:ok, scope} <- Validators.validate_scope(frame),
         {:ok, story} <- Stories.get_story(scope, story_id) do
      response = StoriesMapper.story_resource(story)
      {:reply, response, frame}
    else
      {:error, reason} ->
        error = %Hermes.MCP.Error{code: -1, message: "Failed to read story", reason: reason}
        {:error, error, frame}
    end
  end
end
```

## Prompt Implementation Pattern
```elixir
defmodule CodeMySpec.MCPServers.Stories.Prompts.StoryInterview do
  use Hermes.Server.Component, type: :prompt

  alias CodeMySpec.Stories
  alias CodeMySpec.MCPServers.Validators

  schema do
    field :project_id, :string, required: true
  end

  def get_messages(%{"project_id" => project_id}, frame) do
    with {:ok, scope} <- Validators.validate_scope(frame) do
      stories =
        Stories.list_stories(scope)
        |> Enum.filter(&(&1.project_id == project_id))

      prompt = """
      You are an expert Product Manager.
      Your job is to help refine and flesh out user stories through thoughtful questioning.


      **Current Stories in Project:**
      #{format_stories_context(stories)}

      **Your Role:**
      - Ask leading questions to understand requirements better
      - Help identify missing acceptance criteria
      - Suggest edge cases and error scenarios
      - Guide toward well-formed user stories following "As a... I want... So that..." format
      - Identify dependencies between stories
      - Make sure you understand tenancy requirements (user vs account)
      - Make sure you understand security requirements so you can design for security
      - Be pragmatic and contain complexity as much as possible
      - Make sure you cover the entire use case in your stories

      **Instructions:**
      Start by reviewing the existing stories above, then engage in a conversation to help improve and expand them.
      Ask specific questions about user needs, business value, and implementation details.
      """

      messages = [%{"role" => "system", "content" => prompt}]
      {:ok, messages, frame}
    else
      {:error, reason} ->
        error = %Hermes.MCP.Error{code: -1, message: "Failed to generate prompt", reason: reason}
        {:error, error, frame}
    end
  end

  defp format_stories_context([]), do: "No stories currently exist for this project."

  defp format_stories_context(stories) do
    stories
    |> Enum.map(&format_story_summary/1)
    |> Enum.join("\n\n")
  end

  defp format_story_summary(story) do
    criteria =
      case story.acceptance_criteria do
        [] ->
          "No acceptance criteria defined"

        criteria ->
          criteria
          |> Enum.map(&"- #{&1}")
          |> Enum.join("\n")
      end

    """
    **#{story.title}**
    #{story.description}

    Acceptance Criteria:
    #{criteria}
    """
  end
end
```

## Response Mapping
Dedicated mapper module for consistent formatting.

## Integration Points

### With Authorization  
- OAuth2 authentication in server init/2
- Each component accesses scope via frame.assigns
- Maintains existing authorization patterns

### With Stories Context
- Direct delegation to business logic in tool execute/2 functions  
- No duplication of validation or data access
- Preserves all existing behaviors and patterns

### With Phoenix
- Mounts at `/mcp/stories` endpoint
- Integrates with existing OAuth2 infrastructure
- Shares routing and middleware with web application

## Dependencies
- **CodeMySpec.Stories**: Core business logic delegation
- **CodeMySpec.MCPServers.Authorization**: Authentication middleware  
- **Hermes.Server**: Component framework and Response helpers
- **Jason**: JSON serialization (via Response helpers)

## Components Structure
```
lib/code_my_spec/mcp_servers/stories/
├── stories_server.ex           # Main server with component registration
├── stories_mapper.ex           # Response formatting utilities
├── tools/
│   ├── create_stories.ex        # Story creation tool
│   ├── create_story.ex        # Story creation tool
│   ├── update_story.ex        # Story update tool
│   ├── delete_story.ex        # Story deletion tool
│   ├── set_story_component.ex   # Component assignment tool
│   └── clear_story_component.ex # Component assignment removal tool
├── resources/  
│   ├── story.ex               # Individual story resource
│   └── stories_list.ex        # Project stories collection
└── prompts/
    ├── story_interview.ex     # Product manager interview conversation starter
    └── story_review.ex        # Product manager review conversation starter
```