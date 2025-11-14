# Stories MCP Server - Technical Reference

## Overview

The Stories MCP Server (`stories-server`) is CodeMySpec's requirement management interface that enables Claude Code and Claude Desktop to create, manage, and review user story definitions. This server implements the Model Context Protocol (MCP) to provide story creation, quality review, and component linking capabilities.

## What It Does

The Stories Server manages user story lifecycle by:

1. **Creating and managing user stories** with title, description, and acceptance criteria
2. **Conducting quality reviews** of stories against best practices
3. **Linking stories to components** that implement them
4. **Tracking story status** (in_progress, completed, dirty)
5. **Providing interview guidance** for AI-driven requirement gathering

Stories are stored as database records enabling queries, status tracking, and traceability to implementing components.

## Philosophy

CodeMySpec follows **structured processes with tight specifications and human oversight**. The Stories Server embodies this by:

- Guiding AI through systematic requirement gathering instead of generating massive specs from vague prompts
- Maintaining human approval during planning (stories are reviewed before proceeding)
- Creating precise specifications that constrain downstream generation
- Establishing traceability from user needs through implementation

## How to Use It

### Prerequisites

1. Install the MCP server in Claude Desktop or Claude Code
2. Ensure you have an active project and account in CodeMySpec
3. The server automatically scopes all operations to your active account/project

### Typical Workflow

```
1. Start interview → AI conducts PM-guided requirement discussion
2. Create stories → Add stories individually or in batch
3. Review quality → AI evaluates stories against best practices
4. Refine stories → Update stories as requirements evolve
5. Link to components → Assign stories to implementing contexts
6. Track status → Monitor in_progress, completed, dirty states
```

## Available Tools

### Interview and Review

#### start_story_interview

**Purpose:** Begins an interactive requirement gathering session with AI Product Manager persona.

**Parameters:** None

**What it does:**
- Loads existing project stories for context
- Provides AI with expert PM persona and interview guidelines
- Generates structured prompt guiding requirement discussion

**PM Guidelines Provided:**
- Ask leading questions to understand requirements
- Identify missing acceptance criteria and edge cases
- Suggest error scenarios and validation rules
- Guide toward "As a... I want... So that..." format
- Identify story dependencies
- Clarify tenancy requirements (user vs account scoping)
- Address security requirements upfront
- Contain complexity pragmatically
- Cover entire use case comprehensively

**Example Usage:**
```
User: I want to build API key management
AI: [Uses start_story_interview]
    [Loads existing stories]
    [Generates PM interview prompt]

    Let me ask some questions:
    - Who manages keys - account admins or individual users?
    - What operations are needed? (create, revoke, rotate, list)
    - Do keys need scopes or rate limits?
    ...
```

#### start_story_review

**Purpose:** Conducts comprehensive quality review of all project stories.

**Parameters:** None

**What it does:**
- Loads all stories in current project
- Provides AI with review criteria and evaluation process
- Generates quality assessment against best practices

**Review Criteria:**
- Follows "As a... I want... So that..." format
- Business value clearly articulated
- Acceptance criteria specific and testable
- Appropriately sized (not too large/small)
- Dependencies identified
- Edge cases considered
- Security implications addressed
- Tenancy requirements clear

**Review Process:**
1. Evaluate each story against criteria
2. Identify gaps and inconsistencies
3. Suggest specific enhancements
4. Highlight implementation risks

**Example Output:**
```
Story 1: User Registration
✓ Clear business value
✓ Well-sized story
❌ Missing: duplicate email handling edge case
❌ Missing: specific password complexity requirements
Recommendation: Add acceptance criteria for password rules and duplicate email error messages
```

### CRUD Operations

#### create_story

**Purpose:** Creates a single user story.

**Parameters:**
- `title` (string, required): Story title
- `description` (string, required): Full story description
- `acceptance_criteria` (list of strings, required): Testable acceptance criteria

**Returns:** Created story with ID, status, timestamps, and metadata

**Validation:**
- Title must be present and non-empty
- Description must be present
- Acceptance criteria must be non-empty list
- All fields scoped to active project and account

**Example:**
```json
{
  "title": "Admin creates API key",
  "description": "As an account admin, I want to create API keys so that external services can authenticate with our API",
  "acceptance_criteria": [
    "Admin can generate new API key from settings page",
    "Key is displayed once and never shown again",
    "Key includes created date and name/description field",
    "System enforces maximum 10 keys per account",
    "Key format is cryptographically secure random string"
  ]
}
```

#### create_stories

**Purpose:** Creates multiple user stories in batch.

**Parameters:**
- `stories` (list of maps, required): Array of story objects with title, description, acceptance_criteria

**Returns:** JSON with:
- `successes`: Array of successfully created stories
- `failures`: Array of {index, errors} for validation failures

**Behavior:**
- Processes all stories even if some fail validation
- Each story validated independently
- Failures include array index and specific error messages
- All successful stories committed in single transaction

**Example:**
```json
{
  "stories": [
    {
      "title": "Admin creates API key",
      "description": "As an account admin...",
      "acceptance_criteria": ["..."]
    },
    {
      "title": "Admin revokes API key",
      "description": "As an account admin...",
      "acceptance_criteria": ["..."]
    }
  ]
}
```

#### get_story

**Purpose:** Retrieves a single story by ID.

**Parameters:**
- `id` (integer, required): Story ID

**Returns:** Story record with all fields and associations

**Errors:**
- 404 if story not found
- 403 if story belongs to different account/project

#### list_stories

**Purpose:** Lists all stories in current project.

**Parameters:**
- `status` (enum, optional): Filter by status (in_progress, completed, dirty)
- `component_id` (integer, optional): Filter by assigned component

**Returns:** Array of story records

**Behavior:**
- Automatically filtered by active project and account
- Results include component assignments if present
- Ordered by inserted_at descending (newest first)

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
- If story is linked to component and content changes, status automatically set to "dirty"
- Version history tracked via PaperTrail

**Validation:**
- Story must belong to active project
- Cannot update locked stories (locked by another user)
- Status must be valid enum value

#### delete_story

**Purpose:** Deletes a story.

**Parameters:**
- `id` (integer, required): Story ID

**Returns:** Success confirmation or error

**Behavior:**
- Removes story and all associations (component links)
- Cannot delete locked stories
- Soft delete if PaperTrail versioning enabled

### Component Linking

#### set_story_component

**Purpose:** Links a story to the component that satisfies it.

**Parameters:**
- `story_id` (integer, required): Story ID
- `component_id` (integer, required): Component ID

**Returns:** Updated story with component assignment

**Validation:**
- Both story and component must exist
- Both must belong to same project
- Cannot link story to multiple components (one-to-one relationship)

**Use case:** After architecture design, assign each story to the Phoenix context responsible for implementing it.

#### clear_story_component

**Purpose:** Removes component assignment from a story.

**Parameters:**
- `story_id` (integer, required): Story ID

**Returns:** Updated story with component_id set to null

**Use case:** When component changes or story needs reassignment during architecture refactoring.

## Story Data Model

```elixir
%Story{
  id: integer
  title: string
  description: string
  acceptance_criteria: list of strings  # Stored as JSON array
  status: :in_progress | :completed | :dirty
  component_id: integer | nil  # Foreign key to Component
  project_id: integer  # Foreign key to Project
  account_id: integer  # Foreign key to Account
  locked_at: datetime | nil  # Collaboration lock timestamp
  lock_expires_at: datetime | nil  # Lock expiration (15 minutes default)
  locked_by: integer | nil  # User ID of lock holder
  inserted_at: datetime
  updated_at: datetime

  # Associations
  component: Component | nil  # Loaded via preload
  project: Project  # Loaded via preload
}
```

### Status Values

- **`in_progress`**: Story is being refined or implementation is in progress
- **`completed`**: Story is satisfied by a component and implementation is complete
- **`dirty`**: Story was modified after component was created (requires review and potential re-implementation)

### Status Transitions

```
in_progress → completed (when linked to completed component)
completed → dirty (when story content modified after completion)
dirty → in_progress (when acknowledged and ready for re-work)
```

### Locking Mechanism

Stories can be locked for editing to prevent concurrent modification conflicts:

- Lock acquired automatically when user begins editing in UI
- Lock expires after 15 minutes of inactivity
- Other users cannot modify locked stories
- Lock holder can release lock manually
- Expired locks are cleaned up automatically

## Security & Multi-Tenancy

All operations are automatically scoped to active account and project:

- Stories cannot be accessed across accounts
- All queries filter by `account_id` and `project_id`
- MCP frame contains scope information passed to all tools
- Component links validated within project boundaries

**Scope Structure:**
```elixir
%Scope{
  user: %User{id: integer}
  active_account: %Account{id: integer}
  active_project: %Project{id: integer}
}
```

## Integration with Workflow

The Stories Server is the **first step** in CodeMySpec's structured development process:

```
1. Stories (this server) → Define requirements
2. Architect → Design Phoenix contexts from stories
3. Design Sessions → Generate component specs
4. Test Sessions → Generate tests from acceptance criteria
5. Coding Sessions → Implement components with TDD
```

Stories drive:
- Component design scope (which features to implement)
- Test generation (what to validate via acceptance criteria)
- Implementation priorities (dependency order)
- Traceability (why each component exists)

## Validation Rules

**Story Creation:**
- Title required, max 255 characters
- Description required, no length limit
- Acceptance criteria must be non-empty array of strings
- Each acceptance criterion must be non-empty string

**Story Update:**
- Cannot update stories locked by another user
- Cannot set invalid status values
- Cannot link to non-existent components
- Content changes on completed stories trigger "dirty" status

**Story Deletion:**
- Cannot delete locked stories
- Component links automatically removed
- Soft delete preserves audit trail

## Error Handling

**Validation Errors:**
- Missing required fields (title, description, acceptance_criteria)
- Empty acceptance criteria array
- Invalid status enum value
- Story locked by another user

**Not Found Errors:**
- Story ID doesn't exist
- Component ID doesn't exist for linking
- Story doesn't belong to active project

**Permission Errors:**
- Story belongs to different account
- Attempting to modify locked story

All errors return descriptive messages with field-level details for validation failures.

## Common Patterns

### Interview-Driven Story Creation

```
1. User initiates conversation about feature
2. AI calls start_story_interview
3. AI asks clarifying questions based on PM guidelines
4. User provides details through natural conversation
5. AI calls create_stories with batch of refined stories
6. AI calls start_story_review to validate quality
7. User reviews and refines as needed
```

### Architecture-Driven Component Linking

```
1. User completes architecture design (creates contexts)
2. For each context, identify which stories it satisfies
3. Call set_story_component for each story-context pair
4. Verify no unsatisfied stories remain
5. Stories now have complete traceability to implementation
```

### Quality Review Workflow

```
1. User calls start_story_review periodically
2. AI evaluates all stories against criteria
3. AI identifies gaps, conflicts, or risks
4. User updates stories based on feedback
5. Repeat review after major requirement changes
```

## Tips for Effective Use

1. **Start with interview, not creation**: Use `start_story_interview` to flesh out requirements through conversation
2. **Iterate with AI**: Let AI ask questions rather than writing perfect stories immediately
3. **Use batch creation**: After interview, call `create_stories` with multiple refined stories
4. **Review regularly**: Call `start_story_review` as project evolves to catch drift
5. **Be specific in acceptance criteria**: These become test assertions - avoid vague statements
6. **One feature per story**: Keep stories focused and appropriately sized
7. **Address tenancy upfront**: Clarify user-scoped vs account-scoped features during interviews
8. **Consider security early**: Discuss auth, authz, and data protection during requirement gathering
9. **Link stories promptly**: Assign components during architecture design for traceability
10. **Monitor dirty status**: When stories change after completion, assess impact on implementation

## Version History

Stories use PaperTrail for version tracking:

- Every create, update, delete recorded
- Previous versions retrievable for audit
- Change attribution to user
- Timestamps for all modifications
- Useful for understanding requirement evolution