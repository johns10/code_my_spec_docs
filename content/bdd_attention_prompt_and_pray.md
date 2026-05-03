# Prompt and pray: how I started with AI agents, and why it broke

_Part 2 of the [BDD Attention Thesis](/blog/bdd-attention-thesis)._

---

Most people working with coding agents are doing the same thing I was doing two years ago. They open a chat, describe what they want, hit enter, and hope. I call it prompt and pray. It's the default mode. It's also the mode that has people convinced AI coding tools are either magic or trash, depending on which task they tried last.

I used this approach exclusively for a long time. It kinda works. And the moment it stops working isn't random. There's a mechanical reason it falls apart.

## What prompt and pray actually is

No spec. No plan. No acceptance criteria. No structure. Just me, Claude Code, and a description of what I want the thing to do. I hit enter. I see where it lands. I correct. I hit enter again. Repeat until the code works, or until I rage-quit and write it myself.

For small stuff, this is fine. It's more than fine. If I need a one-off script to rename 200 files, or a quick LiveView component that renders a list, prompt and pray is the fastest path to "done." The model gets the whole task in one shot, the context is small, and there's not enough surface area for things to go sideways. I still work this way for small tasks. I'm not going to write a spec for a five-line bash script. That would be insane.

The trouble starts when the task gets bigger.

## The medium-task drift

Somewhere between "rename these files" and "build me an authentication system" there's a zone where prompt and pray starts to wobble. The task is big enough that I have to give the model multiple instructions across multiple turns. I tell it to use Phoenix contexts. Three turns later it's shoving business logic into the controller. I tell it not to mock the database in tests. Four turns later it has mocked the database. I tell it to follow the existing naming conventions. It uses its own.

I used to think this was the model being dumb. After about 8 months of this pattern repeating across hundreds of sessions, I stopped blaming the model. The model isn't getting dumber. Something else is happening.

## The long-horizon task: full collapse

Now extend that to a real feature. Multi-day. Multiple files. Schema changes, business logic, controller, LiveView, tests. The kind of work that takes a human a week.

This is where prompt and pray goes off the rails. I've lived through every version of this failure:

- The model contradicts itself across phases. It writes a function one way in module A and the opposite way in module B, in the same session.
- It "fixes" a failing test by breaking the function the test was actually testing. I've watched it delete real logic to make red turn green.
- It ignores constraints I set 30 minutes ago. I told it explicitly we don't use Ecto changesets in this layer. An hour later it's full of changesets.
- "Done" becomes meaningless. I ask if the feature is finished. It says yes. I run the app. Half of it doesn't work. I don't even know what it thought it was building anymore.

The model isn't lying. It genuinely thinks it followed the instructions. From its perspective, it did.

## Why it actually breaks

The reason long-horizon prompt-and-pray collapses isn't "the model has a small context window" or "it forgot what you said."

Every new instruction you give a model deprioritizes every prior instruction. Not metaphorically. Mechanically.

Here's how attention works inside a transformer: every token in the context competes for a finite pool of attention. Anthropic's own engineering team writes about this directly[^1]: context is a finite resource with diminishing marginal returns. Every new token added depletes the attention budget by some amount. There's no version of "more context" that doesn't push older context further down the priority list. It's built into the math.

So picture what's actually happening in a long prompt-and-pray session. Turn 1: I tell the model my architectural rules. They get full attention. Turn 5: I tell it to fix a bug. The bug-fix instructions are now competing with my architectural rules for the same finite attention. Turn 20: I tell it to refactor a module. Those rules from turn 1 are now buried under nineteen turns of chat, and the model is working off whatever is loudest right now, which is the most recent thing I said. Turn 40: those original rules are functionally invisible.

Liu et al.'s "Lost in the Middle"[^2] puts numbers on this. Performance is highest at the start and end of the context. Information in the middle gets retrieved worst. Chroma published research in 2025[^3] testing 18 frontier models, including Claude 4, GPT-4.1, and Gemini 2.5, and every single one of them degraded as input grew. No model is immune. The shape of the problem is universal.

What this means in practice: the rules I set early in a session are exactly the rules most likely to be ignored by turn 30. The architectural decisions, the constraints, the "don't do this" instructions. All of it slides toward the middle of the context, where the model's ability to act on it goes to zero.

The model isn't forgetting. It's doing precisely what it was trained to do. It's allocating finite attention to what looks most relevant right now. The bug is not in the model. The bug is in me, expecting the chat log to function as memory.

## Why most people never leave this stage

I lived it. Prompt and pray is sticky. It works often enough on small tasks that you keep reaching for it. When it fails on a big task, the failure feels like the model's fault, not the methodology's fault. So you blame the model, switch to a different one, get burned the same way, and conclude that AI coding is overhyped.

I went through that whole loop. I tried Claude. I tried GPT. I tried Cursor, Aider, Cline. Every single one fell apart in the same way on long tasks, because every single one is built on the same attention mechanism. The tooling around the model doesn't change the math inside the model.

At some point I realized my methodology was the problem. I kept treating a chat session like a stable memory, when what it actually is, is working memory, RAM, a finite resource that gets overwritten as I keep talking. If I wanted the rules to stick, I couldn't keep them in the chat. I had to put them somewhere the model would re-read fresh, every time it needed them.

That was the first time I started writing things down outside the chat.

## Coming next

I started writing things down outside the chat — a development guidelines file, a todo list, a memory file. A prompt that loaded all three at the start of every session. That helped. Until it didn't, in two specific ways I didn't see coming.

**Continue to [Part 3: Write it down](/blog/bdd-attention-write-it-down).**

---

[^1]: Anthropic, "Effective context engineering for AI agents." https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents

[^2]: Liu et al., "Lost in the Middle: How Language Models Use Long Contexts," TACL 2024. https://arxiv.org/abs/2307.03172

[^3]: Chroma, "Context Rot: How Increasing Input Tokens Impacts LLM Performance," 2025. https://research.trychroma.com/context-rot
