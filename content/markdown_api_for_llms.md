# Building a Markdown API for LLM Collaboration

Giving an LLM access to a large project with knowledge, tools, status, files, and database state without stuffing your context full or losing the ability to discover everything is actually very challenging. You can't stuff everything into CLAUDE.md without making a mess. You have to be very careful with MCP servers or you'll proliferate the context window. And putting everything in the filesystem is great until you start mixing dynamic data with static data, because then you have to project everything to the filesystem and your state management becomes messy.

I've tried a number of different approaches to this.

## Directories and Markdown

First, I tried just directories and markdown. I used a CLAUDE.md at the root of the project and then AGENTS.md files at the root of each directory and gave the agent traditional progressive disclosure. The problem I ran into is that I had a lot of dynamic state for my application. I was having to synchronize things from the database into the filesystem and that made things messy and slow.

## Shell Scripts Wrapping HTTP Calls

The next thing I tried was to make an HTTP server and then just have bash scripts that wrap curl commands and call the tools. That actually worked fairly well because I could progressively disclose tools and it was a lot easier to use only the ones that a particular agent needed.

## A Web Server That Aggregates Everything

What I landed on is a web server that aggregates everything. It surfaces database state. It surfaces files. It fronts tools as HTTP endpoints, which I try to keep as GET endpoints wherever possible so that simple WebFetch and curl can be used to navigate the entire server.

I also decided to surface everything as markdown. All of the API endpoints return markdown. The beauty of this is I can have a single module that formats what the agent needs to see into markdown, and then I can just convert that to HTML and render it to the user as well. The user and the agent literally have access to the same system so that they can both observe the state and work on it together.

## Why This Works

This works really well because you're not front-loading CLAUDE.md. You're not jamming up your context window. You have access to real-time and static data through the same interface. And it has progressive disclosure built in -- the agent can just WebFetch its way through the application.

In terms of tooling, there's no context proliferation. It's actually quite simple to build regular HTTP endpoints. And the agent can discover all the tools by just navigating around.

This keeps things in sync automatically. It harmonizes both static information from files and dynamic information from the database. It speeds everything up and makes the experience exactly the same for the human and the agent.

CLAUDE.md still matters -- it should be explaining the context of the system and helping the LLM get started. It just doesn't need to contain the system anymore. It points to it.

## Conclusion

I've gone through several iterations of how to structure applications for use by large language models at this point. Started with files and progressive disclosure, moved to shell scripts wrapping HTTP calls, and landed on a full web server returning navigable markdown. Each step solved the previous step's biggest limitation -- static files couldn't handle dynamic state, scripts couldn't aggregate, and now the web server does both.

Early tests show this being very effective. The agent navigates the project the same way a human browses a dashboard, and both see the same data in real time. If you're building systems where humans and LLMs need to collaborate on the same codebase, this is the pattern I'd start with.
