# Remote Permission Approval: Building Trust Boundaries for Autonomous AI Agents

Once your AI coding agent runs for more than about ten minutes, you hit a problem that nobody warns you about: it needs your permission to do something, and you're not at your computer.

Claude Code has a permission system. When the agent wants to run a tool that isn't pre-approved — writing to a new file, executing a shell command, making an API call — it pauses and asks. This works fine when you're sitting there watching. It does not work when you've kicked off a 45-minute implementation session and you're making coffee.

I needed a way to approve these requests from my phone. So I built one.

## The Problem is Bigger Than Notifications

The obvious solution is push notifications. Someone in the Claude Code community built exactly this — an npm package that hooks into Claude Code's permission system and sends notifications via ntfy.sh. You get a notification, tap approve or deny, and the agent continues. It works and it ships in an afternoon.

But when I started building my version, I realized the problem is more interesting than "how do I get a notification on my phone." The real questions are:

- What happens if I miss the notification?
- What if I want to see the full context of what the agent is trying to do before I decide?
- What if I need to say "I need more information" instead of binary approve/deny?
- How do I audit past permission decisions?
- How do I handle authentication so not just anyone can approve my agent's actions?

These questions pushed me toward building a full-stack permission system rather than a notification hack.

## The Architecture

Here's how permission requests flow through CodeMySpec:

### Step 1: The Hook

Claude Code supports hooks — shell scripts that run before or after tool calls. When a tool needs approval, the hook fires. It POSTs the tool name and input to a local server running on the developer's machine.

### Step 2: Local Server → Production

The local server doesn't make the decision. It forwards the request to the production CodeMySpec instance via HTTP. Why? Because the production server is where the user's authentication, push subscriptions, and persistent state live. The local server is just a bridge.

### Step 3: Persistence + Web Push

The production server does two things simultaneously:

1. **Saves the permission request to the database.** This is the key difference from a notification-only approach. The request exists as a record with a status (`pending`, `approved`, `denied`, `expired`), a decision field, timestamps, and a foreign key to the user. If the notification never arrives, the request still exists and can be acted on from any browser.

2. **Fires a Web Push notification.** Not ntfy.sh or any third-party service — the W3C Web Push API with VAPID keys. The notification includes a link to the approval page.

```elixir
def create_permission_request(user, attrs) do
  with {:ok, request} <- save_request(user, attrs) do
    notify_user(user, request)
    {:ok, request}
  end
end
```

### Step 4: The Approval UI

Tapping the notification opens a Phoenix LiveView page showing the full permission request — tool name, the complete tool input (which can be complex JSON), and approve/deny buttons. This is where having a real UI matters. Some tool inputs are a single file path. Others are multi-line shell commands or API payloads. You need to actually read them before deciding.

I also added an `ask` decision option. Sometimes the right answer isn't approve or deny — it's "I need more context." The `ask` decision tells the agent to provide more information about what it's trying to do and why.

### Step 5: The Decision Cascade

When the user clicks approve or deny:

1. The `PermissionRequest` record is updated in the database
2. A message is broadcast via Phoenix PubSub on the topic `"permission_request:{id}"`
3. A Phoenix Channel (`PermissionChannel`) subscribed to that topic pushes the decision to connected clients
4. A Slipstream WebSocket client running on the developer's local machine receives the message
5. The local server sends the decision as a Server-Sent Event back to the waiting hook
6. The hook returns the decision to Claude Code, which continues or stops

The whole round trip takes about 2 seconds.

```
Hook → Local Server → Production → DB + Web Push
                                          ↓
Phone ← Web Push notification ← Production
  ↓
User taps → LiveView → Approve/Deny
  ↓
PubSub → Channel → WebSocket → Local Server → SSE → Hook → Claude Code continues
```

## Why This Complexity?

A fair question. The ntfy.sh approach is maybe 200 lines of code. This is several thousand across multiple files. Why bother?

**Persistence.** Permission requests don't vanish if the notification is missed. They sit in the database. I can approve them from my laptop, my phone, or any browser where I'm authenticated. If my phone dies mid-session, I don't lose the agent's progress.

**Context.** A notification action button gives you a label. A LiveView page gives you the full tool input, formatted and readable. When an agent wants to run `rm -rf` on something, I want to see the full path before I approve.

**Auditability.** Every permission request and its resolution is in the database with timestamps. I can query what my agent asked to do, what I approved, and when. This matters for the same reason audit logs matter in any system handling sensitive operations.

**Authentication.** Web Push subscriptions are tied to authenticated users. The approval page requires login. There's no shared secret or public topic that someone else could respond to.

**The `ask` option.** Binary approve/deny is not enough. Sometimes I need the agent to explain itself before I decide. This three-way decision (allow, deny, ask) changes the dynamic from rubber-stamping to actual oversight.

## The Trust Boundary Pattern

What I'm really building is the AI equivalent of `sudo`. When a process needs elevated privileges, it doesn't just take them — it asks, proves what it wants to do, and waits for authorization from someone with the authority to grant it.

As AI coding agents get more capable and run for longer, these trust boundaries become critical infrastructure. The agent that runs for 5 minutes while you watch doesn't need this. The agent that runs for 2 hours while you do other work absolutely does.

The pattern generalizes beyond permission requests. Any time an autonomous agent needs human judgment — approving a deploy, confirming a destructive database migration, signing off on a PR — the architecture is the same: persist the request, notify the human, present full context, wait for a decision, propagate it back.

## Building It in Phoenix

Phoenix is almost unfairly good at this. The stack I needed was:

- **Ecto** for permission request persistence
- **Phoenix PubSub** for broadcasting decisions
- **Phoenix Channels** for real-time WebSocket communication
- **LiveView** for the approval UI (no JavaScript to write)
- **Web Push** via `web_push_elixir` for notifications
- **Slipstream** for the local WebSocket client connecting back to production

Every one of these is a first-class Phoenix citizen or a well-maintained library. The hardest part wasn't any individual piece — it was wiring them together into a coherent flow. Phoenix's built-in PubSub made the broadcasting trivial. Channels gave me authenticated real-time communication without thinking about it. LiveView meant the approval page was a single `.ex` file.

If you're building agent infrastructure and wondering which stack to use, the real-time capabilities of Phoenix/Elixir make this kind of system almost too easy.

## What's Next

The permission system is live and I use it daily. The next iteration will add:

- **Batch approvals** — when the agent hits three permission requests in quick succession, I want to approve them as a group
- **Policy rules** — "always approve file reads in the `lib/` directory" so the agent doesn't have to ask for things I'd always approve
- **Time-based expiry** — requests older than 30 minutes auto-deny, so stale sessions don't accumulate

The bigger picture is that human-in-the-loop isn't a temporary workaround until agents get trustworthy enough to run unsupervised. It's a permanent architectural pattern. Even the most capable agent should have boundaries, and those boundaries need real infrastructure — not just a notification service.
