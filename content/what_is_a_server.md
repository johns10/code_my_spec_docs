# What Is a Server and Why Are You Paying For One?

> "CodeX wanted me to upgrade... now I'm at $50/month and I don't know why"
> -- r/vibecoding

Someone posted a list of 15 services vibe coders should use. Databases, forms, payments, search, error tracking, analytics, CI/CD, on and on. Top comment, 97 upvotes: "Too many words, just prompt." Second comment, 43 upvotes: "I have no idea what any of that means."

Nobody explained what a server is first. Once you know that, half the list stops being confusing and the other half becomes optional.

## A Server Is Just a Computer

A server is a computer that's always on, connected to the internet, waiting for requests. Someone visits your app, their browser sends a request, your server sends back the page. That's it.

Your laptop can be a server. When you run your app locally and see it at `localhost:3000`, your computer IS the server. It's listening for requests and responding to them. The only reason you can't share that with the world is that your laptop isn't set up to accept requests from the internet.

"Deploying" means taking those code files from article one - the folder full of text files on your computer - and copying them to a computer that IS set up for the internet. Your code goes from your machine to their machine. Now anyone with the URL can use your app. That's the whole thing.

## Every Service Is Just Someone Else's Computer

Here's what clicked for me: every service your AI signs you up for is just a computer somewhere doing one specific job.

- **Vercel** is a computer that runs your frontend code
- **Supabase** is a computer that runs your database
- **Stripe** is a computer that processes credit cards
- **Sentry** is a computer that collects your error logs
- **Cloudinary** is a computer that stores your images

That 15-service list? Fifteen companies running fifteen computers. Your AI wired them all together because that's the path of least resistance in the JavaScript ecosystem. Each one has a free tier that runs out. That's how you went from $0 to $50/month without understanding why.

## You Don't Need 15 Services

Nobody tells vibe coders this. That 15-service stack exists because the JavaScript/React world evolved that way - lots of small specialized tools glued together. It's one way to build. Not the only way.

A single server handles most of it:

- **Database?** Runs on your server. Postgres, installed right there.
- **File uploads?** Stored on your server's hard drive.
- **Error tracking?** Your server already logs errors.
- **Analytics?** Your server knows every request it gets.
- **Hosting?** Your server IS the host.

I use Hetzner. $4/month for a server that runs my entire app with Postgres. One bill. One computer. Everything in one place.

The tradeoff: you manage that server yourself. Updates, security, backups. Services like Vercel and Supabase exist because they handle that for you. You pay more, but you think about less.

Neither is wrong. But your AI will never tell you "hey, you could run all of this on one $4 server instead of five separate services." Now you know the choice exists.

## The "Is A / Has A" Breakdown

**A VPS (Hetzner, DigitalOcean, Railway)** is a computer you rent. It has an operating system. It has a hard drive. It can run your code, your database, and your file storage all on one machine.

**A hosting platform (Vercel, Netlify)** is a service that runs your code for you. It has servers you don't manage. It has a dashboard. It has free tier limits.

**A BaaS (Supabase, Firebase)** is a service that gives you a database and login without writing backend code. It has an API your frontend talks to. It has free tier limits.

**Docker** is a tool that packages your code into a box called a "container." That container runs on any server. Like putting your app in a shipping container - doesn't matter which truck carries it.

**A CDN (Cloudflare)** is a network of servers around the world. It has copies of your static files. Someone in Tokyo gets files from a server in Tokyo instead of yours in Virginia.

## Why Your AI Picks the Expensive Path

Your AI defaults to Vercel + Supabase + a pile of services because that's what most tutorials use. Most common path means most statistically likely output.

It works. It's not wrong. But it's optimized for getting something running fast, not for keeping costs down or helping you understand what's going on.

When your AI sets up Vercel, it's picking a computer to run your code. When it sets up Supabase, it's picking a computer for your database. When it sets up Cloudinary, a computer for your images. Each one is a separate bill, a separate dashboard, a separate thing that can break.

Once you understand that these are all just computers doing jobs, you can start making choices instead of just accepting whatever your AI picks.

## What to Tell Your AI

> "List every external service this project depends on. For each one, tell me what it does, what it costs after the free tier, and whether we could do the same thing on our own server."

That gives you a map of where your money goes.

> "Can this app run on a single VPS with Postgres instead of using separate services for hosting, database, and file storage?"

Sometimes the answer is genuinely no - payment processing should always be Stripe or similar. But for a lot of vibe-coded apps, the answer is yes, and you'll go from $50/month to $4.
