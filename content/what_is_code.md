# What Is Code, Actually?

> "You said a lot of words but as a vibe coder, I have no idea what any of that means."
> -- r/vibecoding, 21 upvotes

Yeah, fair. Most "guides for beginners" are written by developers who forgot what it's like to not know this stuff. I've been writing code for years and I still remember the feeling of staring at a project folder full of files I didn't create, wondering what any of it was.

So let's actually start from zero.

## Code Is Just Instructions

Code is a list of instructions that tells a computer what to do. Not math. Not magic. Instructions. Like a recipe, except the computer follows it literally and will burn your house down if you forget a step.

When you tell Cursor or Claude or Codex "build me a landing page with a signup form," it writes those instructions for you. Hundreds of them. They get saved into files. Those files live in a folder on your computer. That folder is your project.

That's it. That's the whole thing. There's no hidden layer. Your project is a folder full of text files.

You've probably looked at your project folder and seen stuff like `index.tsx`, `page.js`, `layout.css`, `schema.prisma`. Every one of those is just a text file full of instructions. You could open them in Notepad right now. You wouldn't understand them yet, but they're just text. Nothing to be scared of.

## The "Is A / Has A" Cheat Sheet

Here's what I've found after watching people get confused by this stuff for months: the fastest way to stop drowning in jargon is to just know what things ARE. Not how they work. Not their history. Just what they are and what they have.

### Languages

Languages are what code is written in. Your AI is almost certainly writing one of these:

- **JavaScript** is a programming language. It runs in browsers. It's the reason websites do things when you click buttons instead of sitting there like a PDF. If you're building anything web-related, this is probably what your AI is writing.
- **TypeScript** is JavaScript with extra safety rules bolted on. Same thing with training wheels. Don't worry about the difference yet.
- **Python** is a different language. Your AI might use it for data stuff or AI stuff, but probably not for building your website.

### Frameworks and Libraries

These are pre-built code that someone else already wrote so your AI doesn't start from scratch every time.

- **React** is a library for building user interfaces. It's the most popular one. Your AI keeps choosing it because everyone else did too. Made by Facebook.
- **Next.js** is a framework. It has React built in. It has a server built in. It's made by Vercel (a hosting company - we'll get to them). Your AI loves Next.js because it makes a ton of decisions automatically.
- **Svelte**, **Vue** - same job as React, less popular, so AI picks them less.
- **Tailwind** is a library for making things look good. It's why your code has a million class names like `bg-blue-500 text-white p-4`. That's not broken. That's just how Tailwind works.

### Services

These are other companies' products that your app plugs into. This is where the surprise bills come from.

- **Supabase** is a web app. It has a database (where your data lives). It has user login built in. It has an API (a way for your app to talk to it). Your AI loves Supabase because one service does three jobs.
- **Firebase** is Google's version of roughly the same thing. Database, login, file storage, all in one.
- **Vercel** is a hosting company. It runs your code on their computers so other people can visit your app. It has a dashboard where you see your deployments.
- **Netlify** is another hosting company. Same deal as Vercel.
- **Stripe** is a payment service. It handles credit cards so you don't have to. It has an API your app talks to behind the scenes.

### Tools

Things that help you build but your users never see.

- **Git** is a tool that saves snapshots of your code. Think of it as "undo" for your whole project. Runs on your computer.
- **GitHub** is a website where those snapshots get uploaded. Vercel and Netlify watch your GitHub and automatically update your live app when the code changes.
- **npm** is a tool that downloads other people's code so your project can use it. That massive `node_modules` folder everyone jokes about? That's everything npm pulled down. It runs on your computer.

## How They Fit Together

Here's what your AI probably set up for you, whether you realized it or not:

Your **project** is a folder. It has files written in **JavaScript** (or TypeScript). Those files use **React** (through **Next.js**) to build what people see on screen. The project talks to **Supabase** to store data and handle logins. The whole thing gets uploaded to **GitHub**, and **Vercel** watches GitHub and puts your app on the internet every time the code changes.

Five pieces: a language, a framework, a database service, a code storage service, and a hosting service. That's your "stack." When people ask "what's your stack?" they're asking which five-ish things you're using.

You didn't pick any of this. Your AI did. That's fine. But now you know what the pieces are, and that matters more than you think.

## Why This Matters

You don't need to learn to code. But you need to know what the pieces are so when something breaks, you can point at the right thing.

"The signup form doesn't work" is a bad prompt. Your AI will flail around guessing.

"The signup form sends data to Supabase but the user doesn't show up in the database" is a good prompt. You've told the AI exactly which piece broke.

That's the whole point of this series. Not to turn you into a developer. Just to give you enough vocabulary to stop feeling lost when your AI throws jargon at you, and to point at the right piece when something goes wrong.

## What to Tell Your AI

Next time you start a project, before you build anything, try this:

> "Before we start, list every service, framework, and tool you're planning to use. For each one, tell me what it is, what it does in this project, and whether it costs money."

I've watched people on r/vibecoding go from zero to $50/month in surprise bills within a week because they didn't know what their AI was signing them up for. One prompt saves you from that.

## If You're Still Here and Want the Gory Details

You don't need to know any of this. But if you're curious about what actually happens when your code "runs," here's the short version.

Your AI writes something like this in JavaScript:

```javascript
let price = quantity * 9.99
```

That's human-readable. The computer can't run it directly. So it goes through a pipeline:

```
JavaScript (what your AI writes)
        ↓
   Bytecode (compact instructions the engine understands)
        ↓
   Machine Code (binary - the 1s and 0s your CPU actually executes)
```

**JavaScript** is the top layer. It's what you see in your project files. Readable by humans, written by your AI.

**Bytecode** is the middle layer. The JavaScript engine (V8 in Chrome/Node, SpiderMonkey in Firefox) compiles your JavaScript into a compact intermediate format. You never see this. It's what the engine works with internally.

**Machine code** is the bottom layer. The engine compiles hot bytecode down to actual binary instructions that run directly on the CPU. This is the 1s and 0s. This is what the computer actually executes.

This happens automatically. You don't control it. Your AI doesn't think about it. But when someone says "JavaScript is interpreted" or "JavaScript is compiled" - it's actually both. It gets interpreted into bytecode first, then the frequently-run parts get compiled further into machine code for speed.

The same idea applies to other languages, just with different steps. Python compiles to `.pyc` bytecode files. Java compiles to bytecode that runs on the JVM. Rust and C compile directly to machine code (no bytecode step). Different paths, same destination: binary instructions running on a processor.

That's it. Code goes in, binary comes out, the CPU does what you asked. Everything else is just layers of translation.
