# Stories MCP Server - Project Manager AI Assistant

## Overview

The Stories MCP Server (`stories-server`) is CodeMySpec's AI-powered project manager interface that enables Claude Code and Claude Desktop to help you refine your product ideas into well-structured user stories. This server implements the Model Context Protocol (MCP) to provide interactive requirement gathering, story creation, and project planning capabilities.

## What It Does

The Stories Server acts as your AI project manager, helping you:

1. **Brainstorm and refine requirements** through structured interviews
2. **Create and manage user stories** with acceptance criteria
3. **Review story quality** for completeness and testability
4. **Track story status** (in_progress, completed, dirty)
5. **Link stories to components** that satisfy them

Think of it as a conversational interface for transforming vague product ideas into concrete, actionable user stories that drive your development workflow.

## Philosophy

Per the executive summary transcript, CodeMySpec follows the principle that **LLMs work best with structured processes and tight specifications**. The Stories Server embodies this by:

- Guiding AI through systematic requirement gathering instead of generating massive specs from vague prompts
- Maintaining human oversight during planning (you approve stories)
- Creating precise specifications that leave little wiggle room for downstream generation
- Establishing traceability from user needs through to implementation

The result: User stories become "fly ass prompts" that make test and code generation trivial because the design work has been done properly.

## How to Use It

### Prerequisites

1. Install the MCP server in Claude Desktop or Claude Code
2. Ensure you have an active project and account in CodeMySpec
3. The server automatically scopes all operations to your active account/project

### Typical Workflow

```
1. Start Story Interview → Discuss your idea with AI PM
2. AI asks clarifying questions about requirements
3. Create stories (individually or in batch)
4. Review stories for quality and completeness
5. Refine and update stories as needed
6. Link stories to components once design begins
```

## Available Tools

### 1. start_story_interview

**Purpose:** Begins an interactive session with an AI Product Manager to develop and refine user stories.

**Parameters:** None

**What it does:**
- Loads existing project stories for context
- Provides AI with expert PM persona and guidelines
- Generates a structured prompt that guides discussion toward well-formed stories

**PM Guidelines:**
- Ask leading questions to understand requirements
- Identify missing acceptance criteria
- Suggest edge cases and error scenarios
- Guide toward "As a... I want... So that..." format
- Identify story dependencies
- Clarify tenancy requirements (user vs account scoping)
- Address security requirements upfront
- Contain complexity pragmatically
- Cover entire use case comprehensively

**Example Usage:**
```
User: I want to build a feature for managing API keys
AI: [Uses start_story_interview]
AI: Great! Let me ask some questions to flesh this out:
    - Who manages these API keys - account admins or individual users?
    - What operations do they need? (create, revoke, rotate, list)
    - Do keys need scopes or rate limits?
    - How should expiration be handled?
    ...
```

### 2. start_story_review

**Purpose:** Conducts a comprehensive quality review of existing user stories.

**Parameters:** None

**What it does:**
- Loads all stories in the current project
- Provides AI with review criteria and process
- Generates evaluation against best practices

**Review Criteria:**
- Follows "As a... I want... So that..." format
- Business value clearly articulated
- Acceptance criteria specific and testable
- Appropriately sized (not too large/small)
- Dependencies identified
- Edge cases considered

**Review Process:**
1. Evaluate each story against criteria
2. Identify gaps and inconsistencies
3. Suggest specific enhancements
4. Highlight risks or implementation challenges

**Example Output:**
```
Story 1: User Registration
✓ Clear business value
✓ Well-sized story
❌ Missing edge case: duplicate email handling
❌ Acceptance criteria not specific about password requirements
Recommendation: Add criteria for password complexity and duplicate email error messages
```

### 3. create_story

**Purpose:** Creates a single user story.

**Parameters:**
- `title` (string, required): Story title
- `description` (string, required): Full story description
- `acceptance_criteria` (list of strings, required): Testable acceptance criteria

**Returns:** Created story with ID, status, and metadata

**Example:**
```json
{
  "title": "User can create API key",
  "description": "As an account admin, I want to create API keys so that external services can authenticate with our API",
  "acceptance_criteria": [
    "Admin can generate new API key from settings page",
    "Key is displayed once and never shown again",
    "Key includes created date and name/description",
    "System enforces max 10 keys per account"
  ]
}
```

### 4. create_stories

**Purpose:** Creates multiple user stories in batch.

**Parameters:**
- `stories` (list of maps, required): Array of story objects with title, description, acceptance_criteria

**Returns:** Successful creations and any validation errors

**Behavior:**
- Processes all stories even if some fail
- Returns successes and failures separately
- Failures include index and error details

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

### 5. get_story

**Purpose:** Retrieves a single story by ID.

**Parameters:**
- `id` (integer, required): Story ID

**Returns:** Story details or error if not found

### 6. list_stories

**Purpose:** Lists all stories in the current project.

**Parameters:** None

**Returns:** Array of stories with full details

### 7. update_story

**Purpose:** Updates an existing story.

**Parameters:**
- `id` (integer, required): Story ID
- `title` (string, optional): New title
- `description` (string, optional): New description
- `acceptance_criteria` (list of strings, optional): New acceptance criteria
- `status` (enum, optional): New status (in_progress, completed, dirty)

**Returns:** Updated story or validation errors

### 8. delete_story

**Purpose:** Deletes a story.

**Parameters:**
- `id` (integer, required): Story ID

**Returns:** Success confirmation or error

### 9. set_story_component

**Purpose:** Links a story to the component that satisfies it.

**Parameters:**
- `story_id` (integer, required): Story ID
- `component_id` (integer, required): Component ID

**Use case:** After component design, mark which component implements each story

### 10. clear_story_component

**Purpose:** Removes component assignment from a story.

**Parameters:**
- `story_id` (integer, required): Story ID

**Use case:** When component changes or story needs to be reassigned

## Story Data Model

```elixir
%Story{
  id: integer
  title: string
  description: string
  acceptance_criteria: list of strings
  status: :in_progress | :completed | :dirty
  component_id: integer | nil  # Which component satisfies this story
  project_id: integer
  account_id: integer
  locked_at: datetime | nil
  lock_expires_at: datetime | nil
  locked_by: integer | nil
  inserted_at: datetime
  updated_at: datetime
}
```

**Status Values:**
- `in_progress`: Story is being refined or implemented
- `completed`: Story is satisfied by a component
- `dirty`: Story was modified after component was created (needs review)

## Security & Multi-Tenancy

All operations are automatically scoped to the active account and project:
- Stories cannot be accessed across accounts
- All queries filter by `account_id`
- Project context determines which stories are visible
- MCP frame contains scope information passed to all tools

## Integration with Workflow

The Stories Server is the **first step** in CodeMySpec's structured AI development process:

```
1. Stories (this server) → Define requirements
2. Component Design → Plan Phoenix modules/contexts
3. Component Tests → Generate test specifications
4. Component Coding → Implement with TDD
```

Stories created here drive:
- Component design decisions (what to build)
- Test generation (how to validate)
- Implementation priorities (what order)
- Traceability (why each component exists)

## Tips for Effective Use

1. **Start with interview, not creation**: Use `start_story_interview` first to flesh out requirements before creating stories
2. **Iterate with AI**: Let AI ask questions - don't try to write perfect stories immediately
3. **Use batch creation**: After interview, AI can use `create_stories` to add multiple refined stories at once
4. **Review regularly**: Use `start_story_review` periodically as stories evolve
5. **Be specific in acceptance criteria**: These become the basis for test generation later
6. **One feature per story**: Keep stories focused and appropriately sized
7. **Consider tenancy upfront**: Clarify whether features are user-scoped or account-scoped
8. **Address security early**: Discuss auth, authz, and data protection during interviews
