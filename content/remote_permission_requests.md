# Remote Permission Approval for AI Coding Agents

Once your AI coding agent runs for more than about ten minutes, you hit a problem: it needs your permission to do something, and you're not at your computer.

Claude Code has a permission system. When the agent wants to run a tool that isn't pre-approved, it pauses and asks. This works fine when you're sitting there watching. It does not work when you've kicked off a 45-minute implementation session and you're making coffee.

I needed a way to approve these requests from my phone. So I built one.

## Why Are Push Notifications Not Enough for AI Agent Permissions?

The obvious solution is push notifications. There are already tools out there that do this well — [claude-remote-approver](https://github.com/yuuichieguchi/claude-remote-approver) hooks into Claude Code's permission system and sends notifications via ntfy.sh with approve, deny, and even "always approve" action buttons. It handles AskUserQuestion too. It works and it ships in an afternoon.

But when I started building my version, I realized I wanted more than a notification flow. I wanted persistence, a full approval UI, and audit history. The questions that drove me:

- What happens if I miss the notification?
- What if I want to see the full context of what the agent is trying to do before I decide?
- How do I audit past permission decisions?
- How do I handle authentication so not just anyone can approve my agent's actions?

Those questions pushed me toward building a full-stack permission system.

## How Does the Remote Permission Approval System Work?

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

## Why Build a Full-Stack Permission System Instead of a Simple Notification Tool?

A fair question. Tools like claude-remote-approver are maybe 200 lines of code and solve the core problem. This is several thousand lines across multiple files. Why bother?

**Persistence.** Permission requests don't vanish if the notification is missed. They sit in the database. I can approve them from my laptop, my phone, or any browser where I'm authenticated. If my phone dies mid-session, I don't lose the agent's progress.

**Context.** A notification action button gives you a label. A LiveView page gives you the full tool input, formatted and readable. When an agent wants to run `rm -rf` on something, I want to see the full path before I approve.

**Auditability.** Every permission request and its resolution is in the database with timestamps. I can query what my agent asked to do, what I approved, and when. This matters for the same reason audit logs matter in any system handling sensitive operations.

**Authentication.** Web Push subscriptions are tied to authenticated users. The approval page requires login. There's no shared secret or public topic that someone else could respond to.

## Why Is Phoenix Ideal for Building an Agent Permission System?

Phoenix is almost unfairly good at this. The stack I needed was:

- **Ecto** for permission request persistence
- **Phoenix PubSub** for broadcasting decisions
- **Phoenix Channels** for real-time WebSocket communication
- **LiveView** for the approval UI (no JavaScript to write)
- **Web Push** via `web_push_elixir` for notifications
- **Slipstream** for the local WebSocket client connecting back to production

Every one of these is a first-class Phoenix citizen or a well-maintained library. The hardest part wasn't any individual piece — it was wiring them together into a coherent flow. Phoenix's built-in PubSub made the broadcasting trivial. Channels gave me authenticated real-time communication without thinking about it. LiveView meant the approval page was a single `.ex` file.

If you're building agent infrastructure and wondering which stack to use, the real-time capabilities of Phoenix/Elixir make this kind of system almost too easy.

## Frequently Asked Questions

**How fast is the round trip from permission request to agent resuming?** The entire flow -- from the hook firing, through the production server, Web Push notification, user approval on their phone, and the decision cascading back to the waiting agent -- takes about 2 seconds. The agent pauses seamlessly and resumes immediately after the decision arrives.

**What happens if I miss the push notification?** The permission request is persisted in the database with a pending status. You can approve it from any browser where you are authenticated -- your laptop, phone, or any other device. The request does not vanish if the notification fails to deliver.

**Is this secure enough for production use?** Web Push subscriptions are tied to authenticated users via VAPID keys. The approval page requires login. Every permission request and its resolution is stored in the database with timestamps for audit purposes. There is no shared secret or public topic that an unauthorized person could respond to.

**Can I use this with AI agents other than Claude Code?** The architecture is designed around Claude Code's hook system, which fires shell commands on specific events. Any AI coding agent that supports similar hook or callback mechanisms could integrate with the same permission flow by posting requests to the local server endpoint.

**How does this compare to claude-remote-approver?** claude-remote-approver is a lightweight solution of about 200 lines that sends notifications via ntfy.sh with action buttons. It solves the core notification problem well. This system adds persistence, a full approval UI with complete tool input context, audit history, and authenticated access, at the cost of significantly more code and infrastructure.
