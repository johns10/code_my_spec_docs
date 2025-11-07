# Stories: AI-Managed Requirements

> **Let AI interview you about your product, then manage your requirements as structured data.** The Stories MCP Server turns requirements gathering into a conversation with an expert product manager.

## What Stories Does

### 1. AI Interviews You About Requirements

Instead of writing stories yourself or prompting AI to generate them, **the AI becomes your product manager and interviews you**:

```
You: I need API key management

AI: [Calls start_story_interview]
    Let me ask some questions:
    - Who manages keys - account admins or users?
    - What operations? (create, revoke, rotate, list)
    - Do keys need scopes or rate limits?
    - How should expiration work?
    - What happens with revoked keys?
```

The AI uses a structured PM persona with specific guidelines (understand tenancy, address security, identify edge cases, contain complexity). You get better requirements through conversation than you'd write alone.

### 2. Stories Become Structured Data, Not Markdown

Stories live in your database with:
- Full version history
- Component relationships (traceability from story → component → tests → code)
- Status tracking
- Locking mechanism (for collaboration)
- Multi-tenancy
- Prioritization

This enables:
- Automatic loading of unsatisfied stories during component design
- "Dirty" flag when stories change after components exist
- Query by component, status, or priority
- Bidirectional navigation between requirements and implementation

### 3. Automatic Quality Reviews

The AI can review all your stories against best practices at any time:

```
AI: [Calls start_story_review]

Story 1: Admin creates API key
✓ Clear business value
✓ Well-sized story
✓ Testable acceptance criteria
⚠ Missing: What happens at the 10-key limit?
⚠ Missing: Audit logging for key creation?

Story 2: Admin revokes API key
✓ Good acceptance criteria
❌ Missing: How long until revoked keys fully expire?
❌ Missing: Should we send notifications on revocation?
```

Reviews catch gaps before you design components or write tests.

### 4. Direct Integration with Component Design

When you start a component design session, AI automatically loads:
- All unsatisfied stories (stories without assigned components)
- Existing components and their dependencies
- Context about what needs to be built

After designing components, you link them to stories. Now you have complete traceability: Story 42 ("Admin creates API key") is satisfied by Component 15 (ApiKeys context), which has tests and implementation you can navigate to in VSCode.

## How It Works

### Installation

Install the Stories MCP Server in Claude Code or Claude Desktop. The server exposes tools that Claude can call during conversations:

- `start_story_interview` - Begin PM interview session
- `start_story_review` - Review story quality
- `create_story` / `create_stories` - Add stories
- `update_story` - Modify existing stories
- `list_stories` - View all project stories
- `get_story` - View single story details
- `delete_story` - Remove stories
- `set_story_component` - Link story to component
- `clear_story_component` - Unlink story from component

All operations are automatically scoped to your active account and project (multi-tenancy built-in).

### Typical Workflow

1. **Interview:** Start a conversation, AI calls `start_story_interview`, asks questions about your feature
2. **Create:** AI drafts stories from conversation, uses `create_stories` to add them
3. **Review:** Periodically call `start_story_review` to evaluate quality
4. **Refine:** Update stories as requirements evolve
5. **Link:** During component design, link stories to components that satisfy them
6. **Track:** Stories marked "dirty" if modified after component exists (signals need for review)

## Key Features

- **AI-Guided Interviews:** Structured PM persona asks questions you'd miss on your own
- **Structured Database:** Stories are data, not markdown - enables queries and relationships
- **Quality Reviews:** AI evaluates stories against best practices on demand
- **Component Traceability:** Direct links from stories to implementing components
- **Batch Operations:** Create/update multiple stories efficiently
- **Version Control:** Full audit trail via PaperTrail
- **Multi-Tenancy:** Automatic project and account scoping
- **Collaboration Support:** Story locking mechanism prevents conflicts
- **Status Tracking:** in_progress, completed, dirty states
- **Dirty Detection:** Flags when stories change after components exist

## Integration with CodeMySpec Workflow

Stories is the **first step** in the design-driven development process:

```
1. Stories → Define requirements (this feature)
2. Components → Design architecture (links to stories)
3. Design Sessions → Generate detailed designs (uses story context)
4. Test Sessions → Generate tests (from acceptance criteria)
5. Coding Sessions → Implement with TDD (with full traceability)
```

Everything traces back to stories. When you generate tests, AI knows which story they validate. When you implement code, you know which component satisfies which user need.

## Tips for Best Results

**Start with interviews, not creation.** Let AI ask you questions rather than trying to write perfect stories upfront.

**Be specific in acceptance criteria.** These become test assertions later. "User can log in" is vague. "User can log in with email/password and session persists 30 days" is testable.

**One feature per story.** Don't create mega-stories like "Entire authentication system." Break it down: registration, login, logout, password reset, etc.

**Review regularly.** Run `start_story_review` as your project evolves to catch gaps and conflicts.

**Address tenancy and security early.** Clarify whether features are user-scoped or account-scoped. Discuss auth, authz, and data protection during interviews.

**Use batch creation.** After a good interview conversation, have AI create all the stories.

**Keep stories focused.** If acceptance criteria list gets long (7+), consider splitting into multiple stories.

## Get Started

**Prerequisites:**
- CodeMySpec account and active project
- Claude Code or Claude Desktop with MCP support
- Stories MCP Server installed

**First conversation:**
```
You: I want to add [feature] to my app. Let's start a story interview.

AI: [Calls start_story_interview]
    [Loads existing stories for context]
    [Begins asking questions as expert PM]
```

Then create stories from the conversation, review for quality, and link to components when you're ready to design.

---

**Next:** [Components MCP Server](/mcp-servers/components) - Design architecture from your stories

**Related:** [Managing User Stories](/methodology/managing_user_stories) - Manual markdown workflow for stories

**Learn more:** [CodeMySpec Methodology](/methodology) - Full design-driven development process
