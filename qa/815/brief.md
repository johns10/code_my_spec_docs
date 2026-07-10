# Qa Story Brief

Story 815: Sam sends and receives messages with his users

## Tool

web (Vibium MCP browser tools for the hosted LiveView at `http://localhost:4000`)

## Auth

Log in via magic link at `http://localhost:4000/users/log-in`:

1. Fill `input[name='user[email]']` in the magic-link form with a confirmed, passwordless user
2. Click "Email me a login link", navigate to `http://localhost:4000/dev/mailbox`, click the link
3. Replace `https://dev.codemyspec.com` with `http://localhost:4000` in the link URL

Use `qa-604-1779069053@example.com` — confirmed, no password, has project `616c8e35-7aea-440a-a572-c67dca2455fb`.

## Seeds

No additional seeds required. The QA user and project already exist.

For scenarios that need a pre-existing conversation, the operator can start one via the `[data-test='new-conversation-form']` from the inbox page.

## What To Test

### Scenario 1: Empty inbox state
- Navigate to `http://localhost:4000/app/inbox`
- Verify page renders with heading "Chats" and `[data-test='conversations']` table
- Verify `[data-test='conversations-empty']` row is visible with "No conversations yet"
- Verify `[data-test='new-chat-menu']` button is visible
- Screenshot

### Scenario 2: Account starts a conversation (AC: Account starts a conversation)
- On `/app/inbox`, click `[data-test='new-chat-menu']` (opens dropdown)
- Fill `input[name='conversation[email]']` with `testuser@example.com`
- Fill `input[name='conversation[body]']` with `Hello from the account!`
- Submit the form (click "Start chat")
- Verify redirect to `/app/inbox/:id` (thread view)
- Verify `[data-test='chat']` is present
- Verify `[data-test='message']` shows the opening message body "Hello from the account!"
- Screenshot

### Scenario 3: Replies append to the same thread (AC: Replies append to the same thread)
- On the thread view from Scenario 2
- Fill `input[name='message[body]']` with `Follow-up message`
- Submit via "Send" button
- Verify a new `[data-test='message']` appears with "Follow-up message"
- Screenshot

### Scenario 4: History is shown on return (AC: History is shown on return)
- From the thread view, click `[data-test='back-to-chats']` to return to `/app/inbox`
- Verify `[data-test='conversation']` row exists for `testuser@example.com`
- Verify `[data-test='conversation-preview']` shows the last message
- Click the conversation row to re-open the thread
- Verify previous messages are still present in `[data-test='thread']`
- Screenshot

### Scenarios blocked (widget/channel surface — not reachable via Vibium):
- **User starts a conversation** — requires Phoenix `WidgetSocket` / `ConversationChannel` connection from an end-user widget (not a browser flow)
- **Live delivery while connected** — requires two simultaneous WebSocket connections
- **Delivery on next connect** — requires end-user channel connect/disconnect cycle
- **Teammate reads and replies** — requires two authenticated browser sessions simultaneously
- **User sees only their own conversation** — requires end-user channel
- **Cross-user access is denied** — requires two end-user channels
- **Online status reflects connection** — requires end-user widget channel + Phoenix Presence
- **Conversations span all projects** — requires end-user channels across two projects

These widget-surface scenarios are covered at contract level by the spex suite
(`criterion_6569`, `6571–6579`). They require exercising `CodeMySpecWeb.WidgetSocket` /
`CodeMySpecWeb.ConversationChannel` which has no direct browser or curl surface;
it's a Phoenix channel that requires authenticated WebSocket connection from the
widget SDK. QA would need a purpose-built WebSocket client or a running widget
to exercise these.

## Result Path

`.code_my_spec/qa/815/`
