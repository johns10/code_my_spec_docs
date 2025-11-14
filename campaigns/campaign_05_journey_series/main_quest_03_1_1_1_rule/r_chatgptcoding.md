# r/ChatGPTCoding Post: The 1:1:1 Rule

## Campaign Context
- **Campaign**: Journey Series (Main Quest)
- **Article**: "How to Write Design Documents That Keep AI From Going Off the Rails"
- **Target Community**: r/ChatGPTCoding
- **Goal**: Drive traffic to Phase 3 article, establish methodology credibility

---

## Title Options (Test These)

**Primary (Most Likely to Hit):**
"My AI Agent Kept Inventing Its Own Architecture. One Simple Rule Fixed Everything."

**Alternatives:**
1. "6 Months Fighting AI Drift. This Stupidly Simple Pattern Changed Everything."
2. "AI Agents Keep Going Off Track? You're Probably Missing This One File."
3. "Finally Cracked Design Specs After Watching AI Rewrite My Code Wrong 100 Times"
4. "Why Your AI Agent Writes Shit Code (And the 1:1:1 Rule That Fixes It)"

**Selection Criteria:**
- Emotional hook (pain/struggle)
- Implies breakthrough moment
- Promises simple solution
- Makes reader go "wait, what?"

---

## Post Structure

### Opening: The Struggle (2-3 paragraphs)

**Hook with specific pain:**
```
For 6 months I fought with Claude and ChatGPT over code structure. I'd design a feature, the agent would implement it, and by the end we'd have completely different architecture than what I asked for.

I tried everything. More detailed prompts. System instructions. Breaking tasks into smaller pieces. Yelling at my screen.

Nothing worked. The agent would start strong, then drift. Add helper modules I didn't ask for. Restructure things "for better organization." Create its own dependency patterns. By the time I caught the violations, other code depended on them. Refactoring became a nightmare.
```

**The specific breaking point:**
```
The worst was an MCP server project in C#. I was working with another dev and handed him my process (detailed planning docs, implementation guidelines, the works). He followed it exactly. Had the LLM generate the whole feature.

The problem? It was an infrastructure component, but instead of implementing it AS infrastructure, the agent invented its own domain-driven design architecture INSIDE my infrastructure layer. Complete with its own entities, services, the whole nine yards.

Compiled fine. Tests passed. Worked. Completely fucking wrong architecturally.

Took 3 days to untangle because by the time I caught it, other code was calling into this nested architecture. That's when I realized: my previous method (detailed planning + guidelines) wasn't enough. I needed something MORE explicit.
```

### Middle: The Realization

**The insight:**
```
Then I realized something obvious: I was giving the AI architecture (high-level) and asking it to jump straight to code (low-level). The agent was filling in the gap with its own decisions. Some good, some terrible, all inconsistent.

I needed something in the middle. Specifications. Design documents. But not after coding - BEFORE coding.

Actually got the inspiration from Elixir. Elixir has this convention: one code file, one test file. Clean, simple, obvious. I just extended it:
- One design doc per code file
- One test file per code file
- One implementation per design + test

I call it the 1:1:1 rule.

Design doc controls WHAT to build. Tests control HOW to verify. Agent just makes tests pass.

This is basically structured reasoning. Instead of letting the model "think" in unstructured text (which drifts), you force the reasoning into an artifact that CONTROLS the code generation.
```

### The Method (Practical Steps)

**How it actually works:**
```
Here's what changed:

Before asking for code, I write (or have Claude write) a design doc that describes exactly what the file should do:
- Purpose (what and why)
- Public API (function signatures with types)
- Execution flow (step-by-step)
- Dependencies (what it calls)
- Test assertions (what to verify)

I iterate on the DESIGN in plain English until it's right. This is way faster than iterating on code. Design changes = text edits. Code changes = refactoring, test updates, compilation errors.

Once the design is solid, I hand it to the agent with "implement this design document." The agent has very little room to improvise.

For my Phoenix/Elixir projects, the structure is dead simple:
docs/design/app/context/component.md � lib/app/context/component.ex

One doc, one code file. That's it.
```

### Results (Specifics)

**What actually changed:**
```
Results after 2 months using this:

- AI architectural violations: Basically zero (I catch them in design review before any code)
- Time debugging AI code: Down ~60% (less improvisation = fewer surprises)
- Code regeneration: Trivially easy (just delete implementation, regenerate from design)
- Team onboarding: Way faster (new devs read design docs, understand intent immediately)

The weirdest benefit: I stopped caring which AI model I use. Claude, GPT, whatever. They all follow designs fine. The design doc is doing the heavy lifting, not the model.
```

### The Product Mention (20% of post)

**Natural integration:**
```
I've been using this workflow manually for a while (just me + Claude + markdown files). Recently started building CodeMySpec to automate it - AI generates design docs from architecture, validates them against schemas, spawns test generation, etc. But honestly, the manual process works fine. You don't need tooling to get value from this pattern.

The key insight is: iterate on designs (fast), not code (slow).
```

### Ending: Invite Discussion

**Genuine questions:**
```
Anyone else doing something similar? I've seen people using docs/adr/ for architectural decisions, but not one design doc per implementation file.

What do you use to keep agents from going off the rails?
```

---

## Full Post Draft

```markdown
# My AI Agent Kept Inventing Its Own Architecture. One Simple Rule Fixed Everything.

For 6 months I fought with Claude and ChatGPT over code structure. I'd design a feature, the agent would implement it, and by the end we'd have completely different architecture than what I asked for.

I tried everything. More detailed prompts. System instructions. Breaking tasks into smaller pieces. Yelling at my screen.

Nothing worked. The agent would start strong, then drift. Add helper modules I didn't ask for. Restructure things "for better organization." Create its own dependency patterns. By the time I caught the violations, other code depended on them. Refactoring became a nightmare.

The worst was an MCP server project in C#. I was working with another dev and handed him [my process](https://codemyspec.com/content/my-first-serious-coding-workflow?utm_source=reddit&utm_medium=post&utm_campaign=journey_series&utm_content=main_quest_03_backstory) (detailed planning docs, implementation guidelines, the works). He followed it exactly. Had the LLM generate the whole feature.

The problem? It was an infrastructure component, but instead of implementing it AS infrastructure, the agent invented its own domain-driven design architecture INSIDE my infrastructure layer. Complete with its own entities, services, the whole nine yards.

Compiled fine. Tests passed. Worked. Completely fucking wrong architecturally. Took 3 days to untangle because by the time I caught it, other code was calling into this nested architecture. That's when I realized: my previous method (detailed planning + guidelines) wasn't enough. I needed something MORE explicit.

## Then I Realized Something Obvious

I was giving the AI architecture (high-level) and asking it to jump straight to code (low-level). The agent was filling in the gap with its own decisions. Some good, some terrible, all inconsistent.

I needed something in the middle. Specifications. Design documents. But not after coding - BEFORE coding.

That's when I stumbled on what I call the **1:1:1 rule**:
- One design doc per code file
- One test file per code file
- One implementation per design + test

Design doc controls WHAT to build. Tests control HOW to verify. Agent just makes tests pass.

## Here's What Changed

Before asking for code, I write (or have Claude write) a design doc that describes exactly what the file should do:
- **Purpose** - what and why this module exists
- **Public API** - function signatures with types
- **Execution Flow** - step-by-step operations
- **Dependencies** - what it calls
- **Test Assertions** - what to verify

I iterate on the DESIGN in plain English until it's right. This is way faster than iterating on code.

Design changes = text edits.
Code changes = refactoring, test updates, compilation errors.

Once the design is solid, I hand it to the agent: "implement this design document." The agent has very little room to improvise.

For my Phoenix/Elixir projects:
```
docs/design/app/context/component.md � lib/app/context/component.ex
```

One doc, one code file. That's it.

## What Actually Changed

Results after 2 months using this:

- **AI architectural violations**: Basically zero (I catch them in design review before any code)
- **Time debugging AI code**: Down ~60% (less improvisation = fewer surprises)
- **Code regeneration**: Trivially easy (delete implementation, regenerate from design)
- **Team onboarding**: Way faster (new devs read designs, understand intent immediately)

The weirdest benefit: I stopped caring which AI model I use. Claude, GPT, whatever. They all follow designs fine. The design doc is doing the heavy lifting, not the model.

## The Manual Process Works Fine

I've been using this workflow manually - just me + Claude + markdown files. Recently started building [CodeMySpec](https://codemyspec.com?utm_source=reddit&utm_medium=post&utm_campaign=journey_series&utm_content=main_quest_03_1_1_1_rule) to automate it (AI generates designs from architecture, validates against schemas, spawns test generation, etc). But honestly, the manual process works fine. You don't need tooling to get value from this pattern.

The key insight: **iterate on designs (fast), not code (slow)**.

Wrote up the full process here if you want details: [How to Write Design Documents That Keep AI From Going Off the Rails](https://codemyspec.com/content/writing-design-documents?utm_source=reddit&utm_medium=post&utm_campaign=journey_series&utm_content=main_quest_03_1_1_1_rule)

## Questions for the Community

Anyone else doing something similar? I've seen people using `docs/adr/` for architectural decisions, but not one design doc per implementation file.

What do you use to keep agents from going off the rails?
```

---

## Comment Response Strategy

### First 2 Hours: Respond to Every Comment

**When someone asks "isn't this just more overhead?":**
```
Honestly, I thought the same thing at first. But turns out iterating on plain text is SO much faster than debugging generated code.

Example: Realize I need filtering?
- Design iteration: Add "filters parameter" to design doc (30 seconds)
- Code iteration: Refactor function signature, update tests, fix callers, rerun tests (20 minutes)

The design iteration pays for itself immediately.
```

**When someone says "I just use better prompts":**
```
Better prompts help, but I found the AI still makes different structural decisions every session. It might decide error handling goes in one place this time, somewhere else next time.

Design doc locks in those decisions. "Errors return {:error, :not_found}" is way more specific than "handle errors properly."

But yeah, prompts + designs together is the real combo.
```

**When someone asks about your tool:**
```
It's basically automation around the manual workflow. Spawns AI agents to generate designs, validates them against schemas (catches missing sections, invalid module names, etc), does revision loops if validation fails, commits to git.

But you can get 80% of the benefit with just markdown files. The core insight (design before code) is what matters.

Link if you want to check it out: https://codemyspec.com?utm_source=reddit&utm_medium=comment&utm_campaign=journey_series&utm_content=main_quest_03_1_1_1_rule
```

**When someone shares their workflow:**
```
[Genuinely engage with their approach]

That's interesting - you're doing [specific thing they mentioned]. How do you handle [relevant question]?

I like the idea of [something specific from their comment]. Might try that.
```

### Engagement Metrics to Track

- **First 2 hours**: Aim for 20+ comments
- **First 24 hours**: Respond to every question
- **Upvote pattern**: If you get 10+ upvotes in first hour, you're probably hitting front page
- **Comment depth**: Long threads mean engagement, Reddit algorithm loves that

---

## Red Flags to Avoid in Comments

L **Don't**:
- Be defensive about criticism
- Over-promote the product
- Dismiss other people's workflows
- Use corporate speak
- Ignore genuine questions

 **Do**:
- Acknowledge limitations
- Share real numbers
- Be genuinely curious about alternatives
- Admit when someone has a good point
- Keep it conversational

---

## Timing

**Post Schedule:**
- Tuesday-Thursday, 7-9am EST
- Avoid Mondays (inbox-clearing day)
- Avoid Fridays (people checking out mentally)
- Avoid weekends (unless viral-worthy)

**Best Time for This Post:**
Wednesday, 8am EST - catches US devs procrastinating, gives full work day for engagement

---

## Success Metrics

**Minimum Success:**
- 50+ upvotes
- 30+ comments
- 500+ article views

**Good Success:**
- 100+ upvotes
- 75+ comments
- 1500+ article views

**Home Run:**
- 200+ upvotes
- 150+ comments
- 3000+ article views
- Triggers discussions in other subreddits

---

## Follow-Up Content (If This Hits)

If this post performs well, queue up:

1. **Week later**: "The Template I Use For Every Design Document" (resource post)
2. **2 weeks later**: "3 Months of the 1:1:1 Rule. Here's What Actually Happened." (results post)
3. **Month later**: "I Built a Tool to Automate Design Document Generation. Here's What I Learned." (product-focused, but earned)

Space them out. Don't spam. Each post needs to stand on its own value.

---

## Notes

- This post format mirrors your successful "Finally Cracked Agentic Coding" post
- Struggle � Realization � Method � Results � Invite Discussion
- 80% value, 20% product mention
- Authentic voice, specific details, real numbers
- Questions at end to drive engagement
