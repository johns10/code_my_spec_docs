# Keeping Agents Grounded With User Stories

If you've used agents for a while, I know you've been here. 
You have a small feature or module you want to implement.
You plan it or fire off an ad hoc prompt, and get back 1000 line files covering use cases and edge cases you had no intention of touching.

Claude builds impressive shit, but it's frequently over engineered or completely off the mark.
You get in there and read the code and realize the LLM is off in lala land.
Or you actually try to use it, you realize it's not solving your problem?

Broadly, this is not a problem with the agent, you just didn't give it sufficient context to understand your requirements.
If you don't know exactly what you're building, how the hell is the AI supposed to know?

## The Real Problem: AI Improvises

The problem is that AI fills in the gaps with assumptions from it's training data.
You say "build me authentication" and AI confidently generates a bunch of authentication code that's statistically similar to other authentication code.
It's not necessarily what you want, but it IS authentication.

And it all *works*. The code compiles. It looks professional. But it's not what you needed. You spend the next 2 hours explaining what you *actually* meant, and AI keeps adding more features you didn't ask for.

This is the grounding problem. AI isn't building the wrong thing because it's stupid. It's building the wrong thing because **you never told it what "right" looks like.**

## My Solution: user_stories.md

I started keeping a single markdown file `user_stories.md` that defines exactly what "done" means. Not a PRD with fluff and business justifications. Not technical specifications. Just user stories with clear acceptance criteria.

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

Before asking AI to build anything, I paste the user story. Not as a memory aid. As a **contract**. This is what "done" looks like. Don't add OAuth. Don't add 2FA. Don't assume 24-hour sessions. Build *exactly this*.

## How I Write It: Let AI Interview Me

Instead of just writing stories myself, I have conversations with the AI where *it interviews me*.
When I started down this road, I prompted it like this:

```
Yeah I'm just an ideating about this elixir coating agent and I'm thinking about whether I should be developing my mCP tools as like quote on quote part of the application or like where I just have tools that I that are implemented and then I use them internally ... I know that I just basically answered my own question and I'm just talking to myself at this point but tell me what you think about this
```

Holy shit that's bad. 
But, it's better than nothing.
It's enough to get the model going and help you think through your ideas.

Nowadays, I use a prompt like this:

```
You are an expert Product Manager.
Your job is to help refine and flesh out user stories through thoughtful questioning.

**Current Stories in Project:**
[paste your existing stories]

**Your Role:**
- Ask leading questions to understand requirements better
- Help identify missing acceptance criteria
- Suggest edge cases and error scenarios
- Guide toward well-formed user stories
- Identify dependencies between stories
- Be pragmatic and contain complexity as much as possible
```

The AI asks questions that make me realize I haven't thought things through:
- "What should happen if a user tries to reset their password for an email that doesn't exist?"
- "Should sessions work across devices?"
- "What's the maximum number of failed login attempts before locking an account?"

These questions force me to decide **before** I ask AI to code. Once I've decided, I update `user_stories.md`.

Version control it so the AI doesn't ruin it. This file is the source of truth.

## How I Use It

Paste in the relevant user stories when it's time to write code.
I'll show you how this techniques maps to vertical slice architecture in a future post.

## Why This Works: You're Grounding the AI

When you paste a user story, you're not just reminding AI of something. You're **anchoring it to reality**. You're saying: "This is the actual problem. These are the actual requirements. Don't drift off into lala-land.

---

**Full blog post:** [Managing User Stories](https://codemyspec.com/blog/managing-user-stories?utm_source=reddit&utm_medium=social&utm_campaign=user_stories_backlink&utm_content=r_chatgptcoding)

How do you keep AI on track? Do you have a way to define "done" before you start building?
