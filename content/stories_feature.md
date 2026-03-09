# Stories: AI-Managed Requirements

The Stories MCP Server turns requirements gathering from a writing exercise into a conversation with an expert product manager.

## How It Works

**1. Start the interview**

Tell the AI what feature you want to build. It calls `start_story_session`, loads your existing stories for context, and starts asking clarifying questions.

```
You: I need API key management

AI: [Calls start_story_session]
    Let me ask some questions:
    - Who manages keys — admins or users?
    - What operations? (create, revoke, rotate, list)
    - Do keys need scopes or rate limits?
    - How should expiration work?
```

The AI uses a structured PM persona — understands tenancy, addresses security, identifies edge cases, contains complexity. You get better requirements through conversation than you'd write alone.

**2. Stories become structured data**

Stories live in your database with:
- Full version history (PaperTrail)
- Component relationships (story → component → tests → code)
- Status tracking (in_progress, completed, dirty)
- 30-minute locking for collaboration
- Priority ordering and tagging

**3. Structured acceptance criteria**

Each criterion is a discrete record. Add, update, delete independently — they're not just bullet points in a text field. This means criteria map directly to test assertions and you can refine one without touching the rest.

**4. Integration with component design**

During architecture design, AI automatically loads unsatisfied stories and existing components. After designing, link stories to the components that satisfy them. Full traceability: Story 42 → ApiKeys context → specs → tests → code.

## The MCP Server

12 tools organized by function (plus `set_story_component` available in the Components Server):

| Category | Tools |
|----------|-------|
| Sessions | `start_story_session` |
| CRUD | `create_story`, `update_story`, `delete_story`, `get_story`, `list_stories`, `list_story_titles` |
| Criteria | `add_criterion`, `update_criterion`, `delete_criterion` |
| Organization | `list_project_tags`, `tag_stories` |

All operations scoped to your active account and project.

## Typical Workflow

1. **Interview** — AI calls `start_story_session`, asks questions about your feature
2. **Create** — AI drafts stories with structured criteria
3. **Organize** — Tag and prioritize
4. **Refine** — Update as requirements evolve
5. **Link** — Connect stories to implementing components
6. **Track** — Stories flagged dirty if modified after components exist

## Tips

**Start with interviews, not creation.** Let AI ask questions rather than writing stories upfront.

**Be specific in criteria.** "User can log in" is vague. "User can log in with email/password and session persists 30 days" is testable.

**One feature per story.** Don't create "Entire authentication system." Break it down.

**Use tags.** Group by feature area, sprint, or priority level.

**Keep stories focused.** If your criteria list hits 7+, split into multiple stories.

---

**Next:** [Architecture →](/pages/architect-mcp-feature)
