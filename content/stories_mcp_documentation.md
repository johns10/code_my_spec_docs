# Stories MCP Server - Technical Reference

## Overview

The Stories MCP Server (`stories-server`) is CodeMySpec's web-accessible MCP server for managing user stories, acceptance criteria, tags, and guided story sessions. It exposes 12 tools covering story CRUD, structured acceptance criteria management, tagging, and AI-guided interview/review sessions.

**Endpoint:** `/mcp/stories` (web)
**Transport:** Streamable HTTP via Hermes MCP
**Auth:** OAuth2 token required, ProjectScopeOverride plug

## What It Does

The Stories Server manages the user story lifecycle:

1. **Creating and managing user stories** with title, description, priority, and structured acceptance criteria
2. **Managing acceptance criteria** individually (add, update, delete) with verification protection
3. **Tagging stories** for organization by domain, epic, persona, or custom categories
4. **Conducting guided sessions** for AI-driven requirement gathering (interview) and quality review
5. **Tracking story status** (in_progress, completed, dirty)

Stories are stored as database records with PaperTrail versioning for audit trail, enabling queries, status tracking, and traceability to implementing components.

## Available Tools (12)

### Story CRUD (6 tools)

#### create_story

**Purpose:** Creates a user story with title, description, and acceptance criteria.

**Parameters:**
- `title` (string, required): Story title (e.g., "User Login Feature")
- `description` (string, required): User story in "As a [human role], I want [goal] so that [business value]" format. The role MUST be a real human (user, admin, manager) - never a system, API, or service.
- `acceptance_criteria` (list of strings, required): List of acceptance criteria strings
- `priority` (integer, optional): Priority order (1 = highest). Lower numbers are higher priority.

**Returns:** Created story with ID, status, timestamps, and metadata

**Example:**
```json
{
  "title": "Admin creates API key",
  "description": "As an account admin, I want to create API keys so that external services can authenticate with our API",
  "acceptance_criteria": [
    "Admin can generate new API key from settings page",
    "Key is displayed once and never shown again",
    "System enforces maximum 10 keys per account"
  ],
  "priority": 1
}
```

#### update_story

**Purpose:** Updates an existing story.

**Parameters:**
- `id` (integer, required): Story ID
- `title` (string, optional): New title
- `description` (string, optional): New description
- `acceptance_criteria` (list of strings, optional): New acceptance criteria
- `status` (enum, optional): New status (in_progress, completed, dirty)

**Returns:** Updated story or validation errors

**Behavior:**
- Only provided fields are updated
- If story is linked to component and content changes, status may be set to "dirty"
- Version history tracked via PaperTrail

#### delete_story

**Purpose:** Deletes a story.

**Parameters:**
- `id` (integer, required): Story ID

**Returns:** Success confirmation or error

#### get_story

**Purpose:** Retrieves a single story by ID.

**Parameters:**
- `id` (integer, required): Story ID

**Returns:** Story record with all fields, acceptance criteria, tags, and associations

#### list_stories

**Purpose:** Lists stories in a project with pagination and filtering.

**Parameters:**
- `limit` (integer, optional): Max stories to return (default: 20, max: 100)
- `offset` (integer, optional): Stories to skip for pagination (default: 0)
- `search` (string, optional): Filter by title or description (case-insensitive)
- `tag` (string, optional): Filter by tag name

**Returns:** Array of stories with full details, plus total count for pagination

#### list_story_titles

**Purpose:** Lists story titles in a project (lightweight).

**Parameters:**
- `search` (string, optional): Filter by title (case-insensitive)

**Returns:** Just ID, title, and component_id for each story - no criteria or full descriptions

**Use case:** Quick lookups, selection lists, or finding a story ID without loading full details.

### Acceptance Criteria (3 tools)

#### add_criterion

**Purpose:** Adds a new acceptance criterion to a story.

**Parameters:**
- `story_id` (string, required): Story ID to add criterion to
- `description` (string, required): The acceptance criterion text

**Returns:** Created criterion with the parent story

**Note:** Use `get_story` to see existing criteria before adding.

#### update_criterion

**Purpose:** Updates the description of an existing acceptance criterion.

**Parameters:**
- `criterion_id` (string, required): Criterion ID (from get_story response)
- `description` (string, required): New description text

**Returns:** Updated criterion

**Restrictions:** Cannot update verified (locked) criteria. Verified criteria are protected from changes. Use `get_story` to check verification status before updating.

#### delete_criterion

**Purpose:** Deletes an acceptance criterion from a story.

**Parameters:**
- `criterion_id` (string, required): Criterion ID (from get_story response)

**Returns:** Deleted criterion confirmation

**Restrictions:** Cannot delete verified (locked) criteria. Verified criteria are protected from removal.

### Tagging (2 tools)

#### tag_stories

**Purpose:** Adds a tag to multiple stories at once.

**Parameters:**
- `story_ids` (list of strings, required): List of story IDs to tag
- `tag` (string, required): Tag name to apply to all stories

**Returns:** Summary of successes and failures with the applied tag

**Tag naming conventions:**
- Simple tags: `notifications`, `urgent`, `mvp`
- Prefixed tags: `epic:verification-flow`, `persona:driver`, `domain:billing`
- Prefixed tags enable category-based filtering via `list_stories(tag: "persona:driver")`

**Behavior:**
- Processes all story IDs even if some fail
- Already-tagged stories are treated as success (idempotent)
- Returns failures only for stories not found

#### list_project_tags

**Purpose:** Lists all tags used in the project.

**Parameters:** None

**Returns:** All available tags that have been applied to stories or components

**Use case:** See what organizational categories exist before tagging or filtering.

### Sessions (1 tool)

#### start_story_session

**Purpose:** Starts a guided session for working with user stories.

**Parameters:**
- `mode` (string, required): Session mode - "interview" or "review"

**Modes:**

**Interview mode:** AI conducts PM-guided requirement discussion.
- Loads existing project stories for context
- Provides AI with expert PM persona and interview guidelines
- Enforces human-focused personas (never "As a system...")
- Guides toward well-formed stories with clear business value
- Identifies missing acceptance criteria, edge cases, dependencies
- Addresses tenancy and security requirements

**Review mode:** AI evaluates completeness and quality of existing stories.
- Loads all stories with numbered format for evaluation
- Validates personas are real humans (flags system/API personas)
- Checks "As a [role], I want [goal] so that [value]" format
- Evaluates acceptance criteria specificity and testability
- Identifies gaps, inconsistencies, and risks
- Provides specific, actionable feedback per story

## Story Data Model

```elixir
%Story{
  id: integer
  title: string
  description: string              # "As a [role], I want [goal] so that [value]"
  status: :in_progress | :completed | :dirty
  priority: integer | nil
  component_id: integer | nil      # Foreign key to Component
  project_id: integer
  account_id: integer
  locked_at: datetime | nil        # Collaboration lock timestamp
  lock_expires_at: datetime | nil  # Lock expiration (30 minutes)
  locked_by: integer | nil         # User ID of lock holder

  # Associations
  criteria: [Criterion]            # Structured acceptance criteria
  tags: [Tag]                      # Organization tags
  component: Component | nil

  inserted_at: datetime
  updated_at: datetime
}
```

### Acceptance Criteria Model

Acceptance criteria are stored as structured records (not plain string arrays):

```elixir
%Criterion{
  id: integer
  description: string
  verified: boolean         # When true, criterion is locked from edits/deletes
  story_id: integer
}
```

### Status Values

- **`in_progress`**: Story is being refined or implementation is in progress
- **`completed`**: Story is satisfied by a component and implementation is complete
- **`dirty`**: Story was modified after component was created (requires review)

### Locking Mechanism

Stories can be locked for editing to prevent concurrent modification:
- Lock duration: 30 minutes
- Locked stories cannot be modified by other users
- Lock holder can release lock manually
- Expired locks are cleaned up automatically
- Locking supports acquire/release/extend operations

## Security & Multi-Tenancy

All operations are automatically scoped to active account and project:
- Stories cannot be accessed across accounts
- All queries filter by `account_id` and `project_id`
- MCP frame contains scope information from OAuth2 token
- Component links validated within project boundaries
- All scope validation goes through the Validators module

## Integration with Workflow

The Stories Server is the **first step** in CodeMySpec's structured development process:

```
1. Stories (this server) -> Define requirements
2. Architecture Server   -> Analyze story groupings
3. Components Server     -> Design contexts from stories
4. Design Sessions       -> Generate component specs
5. Test/Coding Sessions  -> Implement with TDD
```

Stories drive:
- Component design scope (which features to implement)
- Test generation (acceptance criteria become test assertions)
- Implementation priorities (priority field + dependency order)
- Traceability (why each component exists)

## Version History

Stories use PaperTrail for version tracking:
- Every create, update, delete recorded
- Previous versions retrievable for audit
- Change attribution to user
- Timestamps for all modifications

## Technical Implementation

**Framework:** Hermes MCP Server
**Server name:** `stories-server` v1.0.0
**Capabilities:** Tools only (no resources or prompts)
**Location:** `lib/code_my_spec/mcp_servers/stories_server.ex`

**Tool modules:**
```elixir
# Story CRUD
component(CodeMySpec.McpServers.Stories.Tools.CreateStory)
component(CodeMySpec.McpServers.Stories.Tools.UpdateStory)
component(CodeMySpec.McpServers.Stories.Tools.DeleteStory)
component(CodeMySpec.McpServers.Stories.Tools.GetStory)
component(CodeMySpec.McpServers.Stories.Tools.ListStories)
component(CodeMySpec.McpServers.Stories.Tools.ListStoryTitles)

# Acceptance criteria
component(CodeMySpec.McpServers.Stories.Tools.AddCriterion)
component(CodeMySpec.McpServers.Stories.Tools.UpdateCriterion)
component(CodeMySpec.McpServers.Stories.Tools.DeleteCriterion)

# Tagging
component(CodeMySpec.McpServers.Stories.Tools.ListProjectTags)
component(CodeMySpec.McpServers.Stories.Tools.TagStories)

# Sessions
component(CodeMySpec.McpServers.Stories.Tools.StartStorySession)
```

**Note:** `CreateStories` (batch creation) exists as a module but is currently commented out/disabled in the server registration.

## Error Handling

**Validation errors:**
- Missing required fields (title, description, acceptance_criteria)
- Invalid session mode (must be "interview" or "review")
- Criterion verified (cannot update/delete locked criteria)

**Not found errors:**
- Story ID does not exist
- Criterion ID does not exist
- Story does not belong to active project

**Permission errors:**
- Story belongs to different account
- Invalid OAuth2 token

All errors return descriptive messages with field-level details for validation failures.
