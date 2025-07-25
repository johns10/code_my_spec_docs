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
  component CodeMySpec.MCPServers.Stories.Tools.UpdateStory
  component CodeMySpec.MCPServers.Stories.Tools.DeleteStory
  
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
- **UpdateStory**: Manages story updates with authorization
- **DeleteStory**: Handles story deletion with ownership checks

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
  use Hermes.Server.Component, type: :tool

  alias CodeMySpec.Stories
  alias CodeMySpec.MCPServers.Stories.StoriesMapper

  schema do
    field :title, :string, required: true
    field :description, :string, required: true
    field :acceptance_criteria, {:list, :string}, default: []
  end

  def execute(params, frame) do
    %{current_scope: scope} = frame.assigns
    params = Map.put(params, "project_id", scope.active_project.id)

    case Stories.create_story(scope, params) do
      {:ok, story} -> {:reply, StoriesMapper.story_response(story), frame}
      {:error, changeset} -> StoriesMapper.validation_error(changeset)
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
  
  def uri_template, do: "story://{story_id}"
  
  def execute(%{"story_id" => story_id}, frame) do
    %{current_scope: scope} = frame.assigns
    
    case Stories.get_story!(scope, story_id) do
      story -> StoriesMapper.story_resource(story)
      _ -> StoriesMapper.not_found_error()
    end
  end
end
```

## Prompt Implementation Pattern
```elixir
defmodule CodeMySpec.MCPServers.Stories.Prompts.StoryInterview do
  use Hermes.Server.Component, type: :prompt
  
  alias CodeMySpec.Stories
  
  schema do
    field :project_id, :string, required: true
  end
  
  def execute(%{"project_id" => project_id}, frame) do
    %{current_scope: scope} = frame.assigns
    
    stories = Stories.list_stories(scope)
    |> Enum.filter(&(&1.project_id == project_id))
    
    prompt = """
    You are an expert Product Manager. Your job is to help refine and flesh out user stories through thoughtful questioning.

    **Current Stories in Project:**
    #{format_stories_context(stories)}

    **Your Role:**
    - Ask leading questions to understand requirements better
    - Help identify missing acceptance criteria
    - Suggest edge cases and error scenarios
    - Guide toward well-formed user stories following "As a... I want... So that..." format
    - Identify dependencies between stories

    **Instructions:**
    Start by reviewing the existing stories above, then engage in a conversation to help improve and expand them. Ask specific questions about user needs, business value, and implementation details.
    """
    
    {:ok, %{content: prompt}}
  end
  
  defp format_stories_context(stories) do
    stories
    |> Enum.map(&format_story_summary/1)
    |> Enum.join("\n\n")
  end
end
```

```elixir  
defmodule CodeMySpec.MCPServers.Stories.Prompts.StoryReview do
  use Hermes.Server.Component, type: :prompt
  
  alias CodeMySpec.Stories
  
  schema do
    field :project_id, :string, required: true
  end
  
  def execute(%{"project_id" => project_id}, frame) do
    %{current_scope: scope} = frame.assigns
    
    stories = Stories.list_stories(scope)
    |> Enum.filter(&(&1.project_id == project_id))
    
    prompt = """
    You are a Senior Product Manager conducting a story review session.

    **Stories to Review:**
    #{format_stories_context(stories)}

    **Review Criteria:**
    - ✅ Story follows proper "As a... I want... So that..." format
    - ✅ Acceptance criteria are specific and testable
    - ✅ Business value is clearly articulated
    - ✅ Story is appropriately sized (not too large/small)
    - ✅ Dependencies and assumptions are identified
    - ✅ Edge cases and error scenarios considered

    **Your Task:**
    Review each story against the criteria above. For each story, provide:
    1. Overall assessment (Ready/Needs Work)
    2. Specific feedback on what's missing or unclear
    3. Suggestions for improvement
    4. Questions to clarify requirements

    Focus on making each story development-ready and valuable to users.
    """
    
    {:ok, %{content: prompt}}
  end
end
```

## Response Mapping
Dedicated mapper module for consistent formatting:
```elixir
defmodule CodeMySpec.MCPServers.Stories.StoriesMapper do
  alias Hermes.Server.Response
  
  def story_response(story) do
    Response.json(%{
      id: story.id,
      title: story.title,
      description: story.description,
      acceptance_criteria: story.acceptance_criteria,
      project_id: story.project_id,
      # ... other fields
    })
  end
  
  def validation_error(changeset) do
    Response.error(-32602, "Validation failed", %{
      errors: format_changeset_errors(changeset)
    })
  end
end
```

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
│   ├── create_story.ex        # Story creation tool
│   ├── update_story.ex        # Story update tool
│   └── delete_story.ex        # Story deletion tool
├── resources/  
│   ├── story.ex               # Individual story resource
│   └── stories_list.ex        # Project stories collection
└── prompts/
    ├── story_interview.ex     # Product manager interview conversation starter
    └── story_review.ex        # Product manager review conversation starter
```