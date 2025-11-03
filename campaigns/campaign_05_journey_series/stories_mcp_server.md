### Side Quest 1A: "I Built an MCP Server So AI Can Access Stories Directly"

**Prerequisites**: Main Quest Post 1 (markdown file approach)
**Target audience**: Readers who tried Post 1 and want automation
**Length:** 2500-3000 words
**Channel:** dev.to, r/elixir, your blog

#### Content Outline

**Hook:**
- "After copy-pasting from user_stories.md 100+ times..."
- "I built an MCP server so AI can query stories directly"
- "No more copy-paste, AI has live access"

**The Problem with Manual:**
- Copy-pasting is tedious
- Stories file grows large (what to paste?)
- Multiple team members = coordination issues
- Changes require re-pasting
- Can't update stories from AI conversation

**What is MCP:**
- Model Context Protocol (Anthropic)
- Standard for AI-to-tool communication
- Works with Claude Desktop and Claude Code
- Better than APIs: structured tool calling

**My MCP Server: stories-server**

**Architecture:**
```
Claude Desktop/Code
       ↓
  MCP Protocol
       ↓
Phoenix Application
       ↓
Stories Context → Database
```

**Tools Exposed:**
- `list_stories` - AI can browse all stories
- `get_story` - AI can read specific story
- `create_story` - AI can add stories from conversation
- `update_story` - AI can refine stories
- `search_stories` - AI can find relevant stories

**Implementation Walkthrough:**

Show actual code from `stories_server.ex`:
```elixir
defmodule CodeMySpec.MCPServers.StoriesServer do
  use Hermes.Server,
    name: "stories-server",
    version: "1.0.0",
    capabilities: [:tools]

  component(CodeMySpec.MCPServers.Stories.Tools.CreateStory)
  component(CodeMySpec.MCPServers.Stories.Tools.ListStories)
  # ... other tools
end
```

**How It Works:**
1. Phoenix app exposes MCP server
2. Claude Desktop connects to server
3. AI can call tools during conversation
4. Tools query Stories context
5. Results returned to AI
6. AI uses context to inform responses

**The Conversation Flow:**

Before (manual):
```
Me: "Generate code for this feature"
    [paste 50 lines from stories.md]
AI: "Here's the code..."
```

After (MCP):
```
Me: "Generate code for user authentication"
AI: [calls list_stories tool with filter: "authentication"]
    [reads story 1.3: "As a user, I want to log in..."]
    "Based on story 1.3, here's the code..."
```

**Building an MCP Server in Phoenix:**

**Step 1: Define tools**
```elixir
defmodule ListStories do
  use Hermes.Tool

  def definition do
    %{
      name: "list_stories",
      description: "List user stories for a project",
      parameters: %{
        project_id: %{type: "integer", required: true}
      }
    }
  end

  def execute(%{project_id: project_id}) do
    stories = Stories.list_stories(project_id)
    {:ok, format_stories(stories)}
  end
end
```

**Step 2: Register with server**
```elixir
defmodule StoriesServer do
  use Hermes.Server

  component(ListStories)
  component(GetStory)
  component(CreateStory)
end
```

**Step 3: Configure Claude Desktop**
```json
{
  "mcpServers": {
    "stories-server": {
      "url": "http://localhost:4000/mcp",
      "headers": {
        "Authorization": "Bearer <token>"
      }
    }
  }
}
```

**Authentication & Security:**
- OAuth2 for agent access
- Scope to user's projects
- Rate limiting
- Audit trail of AI actions

**Multi-tenancy:**
```elixir
def execute(%{project_id: id}, %{scope: scope}) do
  # Scope contains authenticated user/account
  with :ok <- authorize(scope, id),
       stories <- Stories.list_stories(scope, id) do
    {:ok, format_stories(stories)}
  end
end
```

**What This Enables:**
- AI has live access to requirements
- No copy-pasting
- AI can create/update stories from conversation
- Team works from same database
- Audit trail of AI changes

**Comparison:**

Manual approach:
- ✅ Simple, no code needed
- ✅ Learn the process
- ❌ Tedious copy-pasting
- ❌ Stories get stale
- ❌ No audit trail

MCP approach:
- ✅ No copy-pasting
- ✅ Live data
- ✅ AI can update stories
- ✅ Audit trail
- ❌ Requires Phoenix app
- ❌ More complex setup

**When to Build This:**
- You've done manual approach and hit friction
- Multiple team members need access
- Stories change frequently
- Want AI to help refine stories
- Building Phoenix application anyway

**Resources:**
- [Link to MCP documentation]
- [Link to Hermes library]
- [Link to your GitHub repo with example]

**Call to Action:**
- Try manual approach first
- When it gets tedious, consider MCP
- Start with read-only tools (list/get)
- Add write tools when comfortable
- Share your MCP server implementations

**Next Side Quest Teaser:**
> I also built an MCP server for component architecture. It helps AI understand context boundaries: [link to Side Quest 2A]

#### Source Material
- `/lib/code_my_spec/mcp_servers/stories_server.ex`
- Your actual tools implementations
- MCP documentation
- Hermes library documentation

#### Success Metrics
- GitHub stars on example repo
- "I built my own version" posts
- Questions about specific implementation
- MCP community discussion
- Referenced in MCP examples
