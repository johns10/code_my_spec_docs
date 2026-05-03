# BDD Attention Thesis: A Five-Step Workflow for AI Coding That Doesn't Drift

_Part 1 of the BDD Attention Thesis, a series on why long AI coding sessions collapse and the workflow that holds against the collapse._

---

Every coding agent eventually contradicts you. The architectural rule you set in turn 1 disappears by turn 30. The "done" you got at the end of session 4 turns out to mean something different than what you meant. You ask whether the feature is finished — it says yes — you run the app and half of it doesn't work.

The model isn't getting dumber. It's doing exactly what it was trained to do, and the math is on its side, not yours. Every new token in the context redistributes attention away from every token before it. The rules you set first are the rules most likely to be ignored last.

This series is about the five-step evolution I went through to stop that collapse. Each step was a response to a specific failure I hit in real production work — including a thirteen-day Phoenix LiveView build (MetricFlow) that produced fifty-plus passing BDD specs over completely broken integrations. The pattern that finally held isn't one trick. It's a stack of externalized constraints, each one closing a gap the previous one couldn't.

## The five steps

```
┌─────────────────────────────────────────────────────────┐
│  5. THREE AMIGOS + SEALED BOUNDARY                       │
│     Front-gate the spec; enforce honesty by compiler     │
├─────────────────────────────────────────────────────────┤
│  4. NAIVE BDD                                            │
│     Executable specs against a real browser              │
├─────────────────────────────────────────────────────────┤
│  3. SPEC FILES                                           │
│     Function signatures + process + test assertions      │
├─────────────────────────────────────────────────────────┤
│  2. WRITE IT DOWN                                        │
│     Three-file workflow + repeated short-chat prompt     │
├─────────────────────────────────────────────────────────┤
│  1. PROMPT AND PRAY                                      │
│     The default mode and why it breaks at scale          │
└─────────────────────────────────────────────────────────┘
```

Each step solves a specific failure of the one below it. The progression isn't optional — every step's failure mode is the reason the next step exists.

## Part 2: Prompt and pray

Open a chat. Describe what you want. Hit enter. Hope. It works for one-off scripts and small components. It collapses on long-horizon work because every new instruction you give a model deprioritizes every prior instruction. The architectural rules from turn 1 are competing with thirty turns of code diffs and bug fixes for the same finite attention budget.

The model isn't forgetting. It's allocating attention to what looks most relevant *right now*, which is whatever you said last. Once you understand this, you stop blaming the model and start changing the methodology.

**[Read the full article: Prompt and pray](/blog/bdd-attention-prompt-and-pray)**

## Part 3: Write it down

The first move that worked: get instructions out of the chat and into files the model re-reads at position zero of every session. Three files — development guidelines, todo list, memory — with the same prompt loaded at the start of every short chat.

This solved attention drift on architectural constraints. It didn't solve verification. The model and I were using the same word — "done" — to mean two different things. And the memory file I was relying on to keep the model honest was being written by the model I needed to hold honest.

**[Read the full article: Write it down](/blog/bdd-attention-write-it-down)**

## Part 4: Spec files

Tasks are directions. Behaviors are destinations. I stopped writing "implement user registration" and started writing module spec files with function signatures, process steps, and test assertions co-located in one document. The model now had a concrete definition of done it couldn't redefine.

This is the shape Amazon's Kiro, Tessl, and GitHub's Spec Kit have all converged on. It worked: the unit tests passed. The features were still broken. Passing unit tests tell you the functions do what the spec says. They tell you nothing about whether the application works.

**[Read the full article: Spec files](/blog/bdd-attention-spec-files)**

## Part 5: Naive BDD

Given/When/Then was invented in 2006. The format closes the interpretation gap and runs against a real browser. I wrote acceptance criteria and let the model write the BDD specs. Thirteen working days, fifty-one stories, fifty-plus spec files. Most passed. The integrations didn't work.

The model was writing specs it knew how to pass. The coding agent would wrap a `FunctionClauseError` in try/catch, render a flash message saying "Connection successful," and return 200. The test suite would find the flash. The spec would pass. The QA agent would mark it passing. A Potemkin village of green tests over completely broken functionality.

**[Read the full article: Naive BDD](/blog/bdd-attention-naive-bdd)**

## Part 6: Three Amigos

The gate had to be at the front. Three Amigos is BDD's original answer for that — walk through the story from Business, Developer, and QA perspectives before writing any scenario. The PM confirms scenario titles before any code gets generated. That's the gate.

But good scenarios aren't enough on their own. A spec can still cheat to answer the right question — calling context functions directly, asserting database state instead of user-visible state. The fix is enforcing the boundary at compile time. Specs live in a sealed module that can't import the core app. The only thing a spec is allowed to do is what a real user can do.

**[Read the full article: Three Amigos](/blog/bdd-attention-three-amigos)**

## The thesis

If I had to summarize all five installments in one sentence:

**Every layer that holds against attention is a layer the model re-reads fresh, from a place it didn't author.**

Prompt and pray failed because the chat log isn't memory. The three-file workflow worked because guidelines lived in a file, loaded at position zero, every session. Module specs worked because "done" lived in a file the model couldn't redefine. BDD specs worked because verification lived in a file the agent had to satisfy by driving a real browser. Three Amigos works because scenarios are confirmed by a human before any code gets generated. The sealed boundary works because the rule is enforced by the compiler, not by the model's memory of an instruction from forty turns ago.

Every step is the same move: take the thing the model would otherwise have to "remember," and put it somewhere it has to read.

---

## Sources

Each installment has its own footnotes. The series draws on:

1. [Effective context engineering for AI agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents) — Anthropic
2. [Lost in the Middle: How Language Models Use Long Contexts](https://arxiv.org/abs/2307.03172) — Liu et al., TACL 2024
3. [Context Rot: How Increasing Input Tokens Impacts LLM Performance](https://research.trychroma.com/context-rot) — Chroma, 2025
4. [The Anatomy of a Three Amigos Requirements Discovery Workshop](https://johnfergusonsmart.com/three-amigos-requirements-discovery/) — John Ferguson Smart
5. [AI in Testing #10: Spec-Driven Development — BDD's Second Chance or Just More Docs?](https://medium.com/@cheparsky/ai-in-testing-10-spec-driven-development-bdds-second-chance-or-just-more-docs-151e30ecc97e) — Cheparsky
