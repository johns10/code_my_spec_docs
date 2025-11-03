
### Main Quest Post 1: "I Use a Markdown File to Keep AI Focused on Requirements"

**Target audience:** Anyone frustrated with AI wandering off-spec
**Length:** 1500-1800 words
**Channel:** r/elixir, dev.to, your blog

#### Content Outline

**Hook (First 2 paragraphs):**
- "After watching Claude generate 500 lines of code I didn't ask for..."
- The problem: AI makes assumptions, wanders, forgets context
- "I started keeping a single markdown file with all my requirements"

**The Problem:**
- AI chat has no memory beyond conversation
- Copy-pasting context is tedious
- Requirements drift as conversations grow
- Team members can't see what AI is working from

**My Solution: user_stories.md**
```markdown
# My Project

## User Story 1: Authentication
As a user, I want to log in...

**Acceptance Criteria:**
- Email/password authentication
- Session management
- Password reset flow
```

**How I Use It:**
- One file, version controlled
- Paste relevant sections to AI before asking for code
- Update as requirements evolve
- Team has single source of truth
- AI can't make up requirements that aren't documented

**Show Real Example:**
- Reference your actual user_stories.md
- Pick 2-3 stories
- Show before/after: AI output without stories vs with stories
- Demonstrate how quality improves

**Making It Work:**
- Start simple: Just title and acceptance criteria
- Add detail as you discover it
- Don't over-engineer at first
- Version control is critical
- Keep it readable (you'll reference it constantly)

**The Technique:**
```
Step 1: Create requirements.md (or user_stories.md)
Step 2: Write stories in simple format
Step 3: When prompting AI: "Here are the requirements: [paste]"
Step 4: AI stays focused on documented requirements
Step 5: Update file as requirements evolve
```

**What This Enables:**
- Consistent context for all AI interactions
- Requirements traceability
- Team alignment
- Foundation for everything else

**Transition:**
- "This works great, but copy-pasting gets tedious..."
- "I eventually automated this (I'll share how in next post)"
- "But start here - the manual process teaches you what matters"

**Call to Action:**
- Create your requirements.md today
- Try it for one feature
- Share your experience in comments
- "What format works for you?"

**Side Quest Teaser:**
> If you find the copy-pasting tedious, check out "Building an MCP Server So AI Can Access Stories Directly" [link to Side Quest 1A when published]

#### Source Material
- `/docs/user_stories.md` (your actual file)
- Your experience using it manually before building automation
- Comparison: AI output quality before vs after using structured requirements

#### Success Metrics
- 50+ upvotes on Reddit
- 20+ comments with people trying it
- "I'm going to try this" responses
- Saved/bookmarked for reference
- Questions about specific techniques