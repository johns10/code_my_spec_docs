# My First Serious AI Coding Workflow

I spent six months teaching myself to code with AI before the aha moment hit. Not a better model. A better plan.

## The Setup

I used Claude for planning and Cline (inside Cursor) for coding. Cline was more effective for agentic work. Cost more, but I value time over dollars.

## The Plan

Five components: architecture, planning, coding, review, and process iteration. I want to be very clear -- I don't do any of this by hand. I work with the model to generate all of it.

### Architecture

It doesn't really matter which one you use. It matters that you use a proven one. Human coders can follow it, the model has seen examples of it, and you can understand what it's doing.

I use domain-driven design. You could use vertical slice, event-driven, or even simple CRUD. Be consistent and understand it.

### Planning

#### The fluffy stuff

Product brief: vision, features, phases, overall architecture. High-level. This is what your product manager writes at work.

Project brief: description, features, significant entities, business rules, success metrics. What you need for the technical implementation.

#### The real stuff

**Technical implementation plan.** Detail exactly how you'll achieve the fluffy plan. What fields go on what models, what libraries you'll use, how interfaces and services work. Run dependency analysis.

If you haven't iterated on this at least 3-5 times, you're not done. Do not leave this step until you're convinced it will work.

**Todo list.** Everything needed to execute the plan. Markdown with checkboxes. The model generates it from the implementation plan. This file keeps the model oriented between chats.

**Memory file.** An empty `memory.md`. You'll see why soon.

### Coding Process

Same prompt, over and over:

```
Continue working on the project in @project_folder. Follow the development
guidelines in @development_guidelines, and remember everything in @memory.
```

The development guidelines tell the model: do task-based development. Write tests, implement, run tests. When tests pass: update todos, update memory, fix warnings, commit, stop. Open a new chat for the next task.

The memory file keeps state between chats. What's done, what's in progress, anything the model needs to remember.

Keep chats small. Preface everything with guidelines. The model stays on rails.

It performs a task, writes tests, runs tests, fixes errors, updates todos, updates memory, tells you it's done. You commit, close the chat, start a new chat, send the same prompt. Repeat until the project ships.

This was THE MOST effective workflow I'd used at that point.

### Review Process

```
When you've finished a project:
* Run the formatter
* Run tests, fix failures
* Run git diff --name-only main to get changed files
* Review each against the project guidelines
* Verify all todo items are completed
* Evaluate what should move to permanent memory
* Update development guidelines with lessons learned
```

You did make a new branch for this, right?

## Where This Led

This workflow was the foundation. It taught me the core principle: **process beats prompting.**

But it was still manual. Copy-pasting context. Managing memory files by hand. Hoping the model remembered its guidelines.

That's why I built CodeMySpec. It takes these ideas -- structured planning, clear architecture, persistent memory, stop-and-validate loops -- and automates all the manual parts.

Instead of copy-pasting context into every chat, MCP servers give AI direct access to your architecture, stories, and components. Instead of manually sequencing tasks, a dependency graph determines work order. Instead of hoping the model ran tests, a validation pipeline enforces it. Instead of updating memory files by hand, the system tracks what's dirty and what's done.

The workflow principles haven't changed. I still use them every day. CodeMySpec just removed the tedium that made them hard to sustain.

## The Lesson

Back up from the technology, the tooling, the hype. Being good at AI-assisted development means going back to first principles of software design. Critically inspect your workflows. Constantly improve them.

Not even good engineers get good at coding with AI overnight. A good plan and a good understanding of what you want to build -- that's what separates shipping from spinning.
