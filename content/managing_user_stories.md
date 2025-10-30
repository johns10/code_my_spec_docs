# How to manage user stories to get the most out of LLM's

User stories are the interface to your entire product. Technically, they define the architecture, design, test and code in your application. They are also a plain english definition of what the product is and what it does. They can be used to define product positioning, documentation, and test assertions. 

Specifically, when using LLM's, user stories are a critical piece of context that should be in the context window when you design and code modules that satisfy said requirements.

User stories should be a living, holistic document. They helps your audience understand the product. They help your team market, sell, and develop. They guard you from developing conflicting or nonsensical features. They let you consistently evaluate your repository to make sure you haven't gone off the reservation.

## The Problem

Even on human teams, customers talk to product (hopefully) to develop user stories. They get put in tickets. Tickets get sent to devs. Devs write code. Testers test code. Tickets get completed.

But no one maintains these and re-evaluates them over time to make sure the application stays on track. No one evaluates them to make sure new requirements fit with the old ones. No one reads the original stories when they make changes.

Now that LLM's are under widespread use in our industry, the chaos gets worse. Code is generated faster. There's more (and worse) technical debt to contend with. 

It's more critical than ever that your application does what it's supposed to, and that there are checks and balances that can be continouously applied to the code models generate.

## My Solution: user_stories.md

I started keeping a single markdown file `user_stories.md` that contains all the requirements for my project. Not a PRD with fluff and business justifications. Not technical specifications. Just user stories with clear acceptance criteria.

```markdown
# My Project

## User Story 1: Authentication
As a user, I want to log in with email and password so that I can access my account securely.

**Acceptance Criteria:**
- User can register with email and password
- User can log in with email and password
- Passwords are hashed (never stored in plain text)
- Sessions persist for 30 days
- User can log out
- Password reset via email link
```

That's it. Simple, readable, version-controlled requirements.

I make a git submodule called docs, and I put `user_stories.md` in the root.

## How I Write It

Instead of just writing stories myself, I have conversations with the AI where *it interviews me*:

```
Yeah I'm just an ideating about this elixir coating agent and I'm thinking about whether I should be developing my mCP tools as like quote on quote part of the application or like where I just have tools that I that are implemented and then I use them internally ... I know that I just basically answered my own question and I'm just talking to myself at this point but tell me what you think about this
```

Holy shit. That's bad. But it's seriously how I started asking the questions. This is my first requirements conversation. It doesn't have to be perfect, or even good to start a good conversation and start thinking through your ideas.

Now I use something more like this:

```
You are an expert Product Manager.
Your job is to help refine and flesh out user stories through thoughtful questioning.


**Current Stories in Project:**
#{stories}

**Your Role:**
- Ask leading questions to understand requirements better
- Help identify missing acceptance criteria
- Suggest edge cases and error scenarios
- Guide toward well-formed user stories following "As a... I want... So that..." format
- Identify dependencies between stories
- Make sure you understand tenancy requirements (user vs account)
- Make sure you understand security requirements so you can design for security
- Be pragmatic and contain complexity as much as possible
- Make sure you cover the entire use case in your stories

**Instructions:**
Start by reviewing the existing stories above, then engage in a conversation to help improve and expand them.
Ask specific questions about user needs, business value, and implementation details.
```

The AI asks questions I didn't think of: "What should happen if a user tries to reset their password for an email that doesn't exist?" "Should sessions work across devices?" "What's the maximum number of failed login attempts before locking an account?"

Through these interviews, I refine the stories, critique them for correctness and completeness, ensure all use cases are covered. Then update `user_stories.md` with the results. 

Version control it so the AI doesn't ruin it.

## How I Use It

The process is deliberately manual at first:

**1. One file, version controlled.** Everything goes in `user_stories.md`. It lives in my git repository. Every change is tracked. I can see how requirements evolved over time.

**2. Paste relevant sections before asking for code or designs.** Before I ask the AI to design, implement or test something, I paste the relevant user stories into the conversation.

**3. Update as requirements evolve.** When I discover a new requirement or realize an existing one was incomplete, I update the file immediately. The file is the source of truth, not any particular conversation with the AI.

## Making It Work

Start simple. Don't over-engineer it.

Use git. Commit changes to user stories frequently.

Keep it readable. You'll reference this constantly. If it's a mess, you won't use it. Simple markdown is perfect because:
- Anyone can edit it (no special tools)
- It's diff-friendly (git shows changes clearly)
- It's searchable
- It renders nicely on GitHub
- AIs can easily parse it

User stories are a living document. This is not waterfall planning. You're not writing all requirements upfront and freezing them. You're maintaining a current, accurate picture of what your application should do. As you learn, the stories evolve.

Check for conflicts regularly. As you add new stories, read through existing ones. Does Story 15 conflict with Story 3? Does the new admin panel requirement contradict the earlier privacy requirement? Catch these early.

Spend more time on your stories than you feel like you should. If you think you're done, ask Claude to review them with specific questions. I use something like this:

```
You are an expert Product Manager conducting a comprehensive story review.
Your job is to evaluate the completeness and quality of user stories.

**Current Stories in Project:**
#{stories}

**Your Review Criteria:**
- Story follows "As a... I want... So that..." format
- Business value is clearly articulated
- Acceptance criteria are specific and testable
- Story is appropriately sized (not too large or too small)
- Dependencies and relationships are identified
- Edge cases and error scenarios are considered

**Your Review Process:**
1. Evaluate each story against the criteria above
2. Identify gaps, inconsistencies, or areas for improvement
3. Suggest specific enhancements or clarifications
4. Highlight potential risks or implementation challenges

**Instructions:**
Provide a comprehensive review of the stories above, focusing on completeness, clarity, and technical feasibility.
Give specific, actionable feedback for each story.
```

## The Technique: Step by Step

1. **Create `user_stories.md` in your project root**
2. **Start an interview** with the prompt shown above
4. **The AI stays focused** on documented requirements instead of making assumptions
5. **Update the file** as requirements evolve, new edge cases are discovered, or priorities change
6. **Commit changes** to version control frequently

## What This Enables

Beyond just keeping AI on track, this approach creates something valuable:

**Consistent context for all AI interactions.** Every conversation with the AI starts from the same foundation. No more "wait, did I tell you about the session limit?"

**Requirements traceability.** You can see in git history when requirements changed and why. 

**Team alignment.** New team members read one file and understand what the application does. Everyone prompting AI uses the same requirements.

User stories become the linchpin for managing not just your software, but your software company.

## The Philosophy

This is not about doing things automatically, fast, and haphazardly. It's about having a tool (AI code assistants) that makes it *feasible* to do things the right way.

Writing comprehensive user stories and keeping them updated used to be aspirational. Most teams would start with good intentions and then let the documentation rot as the code diverged from reality. Keeping them in sync was too much overhead.

But with AI assistants, the equation changes. The user stories become your primary interface to the AI. They're not documentation you maintain *after* writing code they're the input you use *to write* code. Keeping them accurate isn't overhead; it's how you work.

This means you can finally do what you always knew you should do: maintain a clear, current picture of what your application is supposed to do, and build from that picture.

If you find the copy-pasting tedious and want to let AI access your stories directly, I've built an MCP server that does exactly that. Check out "Building an MCP Server So AI Can Access Stories Directly" [link coming soon].