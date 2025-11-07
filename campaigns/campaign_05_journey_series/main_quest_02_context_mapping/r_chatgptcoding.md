# Reddit Post: r/ChatGPTCoding - Context Mapping

**Title:** How I design architecture and keep LLM's compliant with my decisions

**Body:**

I've been coding with claude/aider/cursor/claude code (in order) for about 18 months now. I've tried MANY different approaches to keeping the LLM on track in larger projects. I've hit the wall so many times where new features the AI generates conflicts with the last one, swings wide, or totally ignores the architecture of my project. Like, it'll create a new "services" folder when there's already a perfectly good context that should handle it. Or it dumps business logic in controllers. Or it writes logic for a different context right in the file it's working on. Classic shit.

I've spent way too much timerefactoring AI slop because i never told it what my architecture actually *is*.

Recently I tried something different. At the beginning of the project, before asking AI to code anything, I spent a few hours having conversatiosn with it where it interviewed ME about my app. not coding yet, just design. We mapped out all my user stories to bounded contexts (I use elixir + phoenix contexts but this works for any vertical slice architecture).

The difference is honestly wild. now when i ask claude code to implement a feature, I paste in the relevant user stories and context definitions and it generates code that fits waay better. Less more random folders. Less chaos. It generally knows Stories context owns Story entities, DesignSessions coordinates across contexts, etc. It still makes mistakes, but they are SO easy to catch because everything is in it's place.

**The process:**
1. Dump your user stories into claude
2. Ask it to help design contexts following vertical slice principles (mention Phoenix Contexts FTW, even if you're in a different language)
3. Iterate until contexts are clean (took me like 3-4 hours of back and forth)
4. Save that shit in docs/context_mapping.md
5. Paste relevant contexts into every coding conversation

For reference, I have a docs git submodule in EVERY project I create that contains user stories, contexts, design documentation, website content, personas, and all the other non-code artifacts I need to move forward on my project

**What changed:**
- AI-generated code integrates better instead of conflicting
- Refactoring time dropped significantly - I'm mostly kicking out obvious architectural drift
- Can actually track progress (context is done or it's not, way better than random task lists)
- The AI stops inventing new architectural patterns every conversation

I wrote up the full process here if anyone wants to try it: [https://codemyspec.com/pages/managing-architecture](https://codemyspec.com/pages/managing-architecture?utm_source=reddit&utm_medium=social&utm_campaign=context_mapping&utm_content=r_chatgptcoding)

the tldr is: if you have well-defined architecture, AI stays on track. if you don't, it makes up structure as it goes and you spend all your time debugging architectural drift instead of features.

Anyone else doing something similar? Lot's of the methods I see are similar to my old approach: https://generaitelabs.com/one-agentic-coding-workflow-to-rule-them-all/.

**Flair:** Discussion

---

## Post Strategy Notes

### Why This Will Work:

1. **Opens with relatable pain** - "architectural chaos" and "AI slop" are real problems the community experiences
2. **Honest about the struggle** - "spent way too much time refactoring"
3. **Specific numbers** - "6 months", "3-4 hours", "70%"
4. **Names tools** - Claude, Cursor, Phoenix contexts, Elixir
5. **Practical process** - Numbered steps anyone can follow
6. **Shows before/after** - Clear contrast between chaos and order
7. **Asks genuine question** - Not just promoting, actually curious about others' approaches
8. **Casual tone** - lowercase, "shit", "honestly wild"

### Expected Engagement:

- **Pragmatists** will appreciate the practical workflow
- **Cautious Optimists** will like the "design before code" approach
- **Skeptics** will relate to the "AI slop" problem
- **Experimenters** will try the process and report back

### Potential Comments to Respond To:

- "does this work with other frameworks?" � yes, any vertical slice architecture
- "3-4 hours seems like a lot" � saves 10x that in refactoring time
- "what if requirements change?" � architecture doc evolves with git history
- "link to blog?" � [provide link]
- "can you share an example context mapping?" � [provide sanitized example]

### Follow-Up Engagement:

- Reply to every comment in first 2-3 hours
- Share specific examples when asked
- Acknowledge limitations (works best for greenfield or planned refactors)
- Ask clarifying questions back to commenters
- Update post if good suggestions come up