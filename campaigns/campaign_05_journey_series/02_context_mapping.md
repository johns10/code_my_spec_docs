
### Main Quest Post 2: "How I Map Requirements to Phoenix Contexts in a Markdown File"

**Target audience:** Phoenix developers managing multiple contexts
**Length:** 1800-2200 words
**Channel:** r/elixir, dev.to, your blog

#### Content Outline

**Hook:**
- "After I had 30 user stories documented, I needed to organize them..."
- "Which context does this belong in?"
- "AI kept suggesting poor context boundaries"

**The Problem:**
- User stories don't map directly to code structure
- AI doesn't understand Phoenix context principles
- Need architectural view before coding
- Team needs shared understanding of boundaries

**My Solution: context_mapping.md**
- Maps user stories to contexts
- Documents context responsibilities
- Explicit dependency tracking
- Single architecture document

**Show Real Example:**
```markdown
## Projects Context
**Type**: Domain Context
**Entity**: Project
**Responsibilities**: Project CRUD, configuration
**Dependencies**: None
**Stories**: 1.1, 1.2, 1.3
```

**How I Use It:**
- Read through user_stories.md
- Group by entity ownership first
- Identify coordination contexts
- Document dependencies explicitly
- Review before any coding starts

**Phoenix Context Principles:**
- One entity per domain context
- Coordination contexts orchestrate, don't own
- Flat structure (no nested contexts)
- Clear boundaries prevent coupling

**The Mapping Process:**
```
Step 1: Read all user stories
Step 2: Identify entities (nouns that need persistence)
Step 3: Group stories by entity ownership
Step 4: Identify coordination needs
Step 5: Document dependencies
Step 6: Review for circular dependencies
```

**Why This Matters:**
- AI can generate code aligned with architecture
- Team sees system structure upfront
- Prevents context boundary violations
- Makes refactoring safer

**When to Do This:**
- After user stories are relatively stable
- Before any serious coding begins
- Update as architecture evolves
- Review with team before implementation

**Common Mistakes:**
- Too many small contexts (over-fragmentation)
- Contexts that depend on each other circularly
- Mixing domain and coordination in one context
- Not documenting dependencies explicitly

**How I Prompt AI With This:**
```
"Here's the context mapping: [paste relevant sections]
Generate code for the Projects context following Phoenix conventions.
Projects depends on: [list dependencies]
Projects is a domain context owning the Project entity."
```

**Transition:**
- "This mapping file became critical for keeping AI architecturally aligned"
- "Eventually I built tooling to help AI query this (next side quest)"
- "But the manual process teaches you good architecture"

**Call to Action:**
- After you have user_stories.md, create context_mapping.md
- Map stories to contexts
- Review with team
- Use it to guide AI code generation

**Side Quest Teaser:**
> For managing complex component dependencies, check out "Building an MCP Server for Component Architecture Tracking" [link to Side Quest 2A]

#### Source Material
- `/docs/context_mapping.md` (your actual file)
- Phoenix documentation on contexts
- Your experience doing this mapping manually
- Examples of good vs poor context boundaries

#### Success Metrics
- Referenced by others asking about Phoenix architecture
- Saved for reference
- Questions about specific mapping decisions
- "This clarified contexts for me" comments
