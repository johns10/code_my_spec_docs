I’ve been working on teaching myself to code with AI for six months. It feels strange that it took me this long to have the aha moment, but here we are.

I’ve finally hit the point where the model does exactly what I want it to most of the time with minimal intervention. I didn’t get a better model. I just got a better plan.

That said, I primarily use Claude for everything. I do most of my planning in Claude, and then I use it with Cline (inside Cursor) for coding.

Cursor is fine, but I’ve found that Cline is more effective for agentic coding. This flow works pretty well with Cursor, but I value my time more than the extra bucks it costs to get it done faster.

I’ve started using Cline so much, and so well that I’ll probably drop Cursor eventually, but we’ll see.

## The Plan

The plan has several components: architecture, planning processes, coding processes, review processes, and process iteration.

I want to be very clear. I don’t do any of this by hand. I work with the model to generate all this.

### Architecture

It doesn’t REALLY matter which one you use. It mostly matters that you use one that’s proven to work.

There are a few reasons for this:

1. Human coders can use it to be successful
2. The model has seen a bunch of examples, so it knows what you’re talking about
3. You can understand what it’s doing

Personally, I use domain-driven design. I’ll write another article on why sometime. You can use vertical slice, event-driven, or even simple CRUD. As long as you’re consistent and understand it, you’ll be good.

### Planning process

For the fluffy part of planning, I’m not sure it matters which methodology you use. Just make sure you use it well.

For the other part, I think it’s incredibly important to structure your plan in a specific way. Here’s what I do:

### The fluffy stuff

This is what your product manager writes at work 😉

### Product brief

At the beginning of the application, I define a product brief. This is a high-level overview of the application. It includes:

- The vision of the project
- The features I expect to include, and what phase they’ll enter into the product
- The overall architecture
- Other fluffy things that don’t contribute to this workflow

### Project brief (or epic or whatever you call it)

At the beginning of each project, I write a project brief. This is a high-level overview of the project. It includes:

- A high-level description of the project and what it aims to accomplish
- Features I expect to get working on the project
- Any significant types, entities, or whatever you call them in your language
- Business rules
- Success metrics
- Other details that are relevant to the technical implementation of the project

## The real stuff

This is what you do after you get it from the product manager.

### Technical implementation plan

Once you have your fluffy plan, you can get down to business. You must have a solid technical implementation plan. It should detail exactly how you are going to achieve the fluffy plan.

It should detail what fields go on what models, what libraries you’ll use, and how your interfaces and services will be implemented. You should ask the model to do dependency analysis, especially if you can sniff out any problems.

If you don’t iterate on this at least 3-5 times YOU ARE NOT DONE.

You should have a detailed, solid plan on how to execute the project. Do not leave this step until you are convinced it will work.

### Todo list

Create a to-do list. This is a list of everything that needs to be done to achieve the implementation plan.

The contents of this file should be PAINFULLY obvious from the implementation plan, but handwriting this stuff is for scrubs. Make the model do it.

You don’t need anything fancy here. Just a markdown file with [ ]’s and [X]’s. This file is extremely important, as it will help your model remember where it was between chats. If you’re interested in controlling cost (assuming you’re on Cline), maintaining context between chats, or maintaining quality by keeping chat sizes low, this is critically important.

### Project memory

Create an empty file called memory.md. This is also very important. You’ll see why soon.

### Coding process

Your coding process will literally be the same thing, over and over again. You’re basically going to use the same prompt over and over again. It will be something like this:

```Continue working on the project in @project_folder. Follow the development guidelines in @development guidelines, and remember everything in @memory.
You do need a couple of things to make this fly.```

### The project memory

An empty markdown file. It’s really important. You’ll see why soon.

### Development guidelines

If you’re in cursor land, this might be a rules file. If you’re in Cline land, it’s just a regular file. This file will contain your guidelines for how you want the model to operate.

What it won’t contain are architectural directions, coding standards, design principles, or best practices. Consider this like your coding process guidelines. Here’s mine at the moment:

```
# General Development Rules

You should do task-based development. For every task, you should write the tests, implement the code, and run the tests to make sure everything works. Use `dotnet test` to run the tests or use `dotnet test --filter "FullyQualifiedName~TypeConversionTests"` to run a specific test.

When the tests pass:
* Update the todo list to reflect the task being completed
* Update the memory file to reflect the current state of the project
* Fix any warnings or errors in the code
* Commit the changes to the repository with a descriptive commit message
* Update the development guidelines to reflect anything that you've learned while working on the project
* Stop and we will open a new chat for the next task


## Retain Memory

There will be a memory file for every project.

The memory file will contain the state of the project, and any notes or relevant details you'd need to remember between chats.

Keep it up to date based on the project's current state. 

Do not annotate task completion in the memory file. It will be tracked in the to-do list.

## Update development guidelines

If necessary, update the development guidelines to reflect anything you've learned while working on the project.
```

You can probably see where I’m going with this. If you keep your chats small and preface everything with these guidelines, the model will generally stay on the rails.

If you do this, it will perform a task, write some tests, run the tests, fix the errors, update the todos, update the memory, and then tell you it’s done.

At that point, you should commit, close the chat, start a new chat, and send the same prompt until you are done with the project, and that’s literally all she wrote.

This is THE MOST effective workflow I’ve used, and I’ve used many of them.

Review Guidelines
This document is much less well-refined, but here’s what I’m using:

```
# Review guidelines

When you have finished a project:

* Run `dotnet format`
* Run the tests with `dotnet test`
* Fix all failing tests
* Fix all warnings
* Run `git diff --name-only main` to get a list of the files you've changed
* Review each of them according to the guidelines in the project memory
* Review the todo list and verify all the tasks are completed
* Review the project memory, and evaluate what should be added to the application memory
* Review the development guidelines, and evaluate what should be added to the development guidelines
```

This one’s also not fluffy. You did make a new branch for this, right? RIGHT??

You probably get the idea here too. This makes for some pretty nice reviews.

## Conclusion

Yes, you need a good model to make this work. I’m using Claude 3.5.

Yes, you need a good tool to make this work. I’m using Cline.

If you don’t have a good plan, and a good understanding of what you want to accomplish, and how, everything is going to fall apart.

Not even good Engineers can get good at coding with LLM’s overnight. Further, just because you’re good at coding with LLM’s, that doesn’t make you good at coding with agents.

If you back up from the technology, and the tooling, and the hype, being good at this workflow means going back to the first principles of software design and engineering. It means critically inspecting and dissecting your workflows and processes, and constantly improving them.