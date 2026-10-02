# QA Brief — Story 984: I connect a model provider by pasting its API key

## Tool

`web` for the settings page and the models page, `curl` for what actually
starts.

## Auth

Magic link, port 4000. There is no password field.

```
mix run priv/repo/qa_seeds.exs
```

Then: open `http://127.0.0.1:4000/users/log-in`, fill `user[email]` with the
seeded address, click "Log in with email", read
`http://127.0.0.1:4000/dev/mailbox` for the newest link, and visit
`/users/log-in/:token`.

The mailbox is shared — the newest link is whoever most recently asked, which
may not be you. Take the one whose recipient matches.

For the MCP side, no login: harness id from `.cms_harness.json`, against
`http://localhost:4004/mcp`. Handshake is `initialize`, then the
`notifications/initialized` notification, then `tools/call`.

## Seeds

```
mix run priv/repo/qa_seeds.exs
```

Nothing story-specific. The seeds connect no provider, which is the starting
state most of this story is about.

## The credential

**A real key is required for half of this and it does not come from the
seeds.** John supplies one Anthropic or Z.ai key for the run. Rules for it:

- Use it on the QA account only.
- **Disconnect the provider before finishing**, whatever the outcome.
- Never write it into a file, a brief, a result, an issue, or a log. It goes
  in the form field and nowhere else.

Without a key, the accept path cannot be tested and that is a QA gap to file,
not something to fake with a stub — the whole point of the story is that a key
somebody pastes reaches a real provider.

## What To Test

**The settings page** — `/app/users/settings`

- Anthropic and Z.ai appear, each with a field to paste a key. Before this
  story they were absent entirely and could only be reached by knowing
  `/auth/:provider` by heart — which for these two led nowhere.
- A key the provider **accepts**: the provider reads as connected.
- A key the provider **refuses** (mangle one character of the real key): the
  provider still reads as not connected, and the message says the provider
  rejected it rather than that something went wrong.
- Reload the page. A stored key is not rendered back — not in the field, not
  masked, not in the page source. Search the HTML for the key's own characters.
- Pasting again while connected replaces the key rather than adding a second
  connection or refusing for already being connected.
- Disconnect removes it, through the confirm dialog like every other provider.

**The models page** — `/app/accounts/:id/agents`

- The provider just connected is now selectable, where it said "connect it
  first" before.
- Point QA at it, then disconnect the provider on the settings page. QA falls
  back to something still connected rather than naming a provider that is gone.
- With nothing connected at all, every type says it has nothing to run on
  instead of naming a model.

**Starting an agent** — `start_agent` over MCP

- With the provider connected and QA pointed at it, a QA agent reports that
  provider and that model. **Stop the agent afterwards.**

**The scope change**

The setting moved from the account to the person in this story. Two members of
one account should get their own answers on the same URL, and the page should
say so — a per-user setting under an `/app/accounts/:id/` URL is the thing
most likely to read as a bug here.

## The one to look hardest at

Whether an account can now genuinely end up running its QA agent on something
cheap — connected, chosen, and started, with the reply naming the cheap model.
That is what 983 could not deliver and what this story exists to make true.
Issue `1a93e35d` says it is impossible; this run is the check on that claim.

## Result Path

`.code_my_spec/qa/984/result.md`

## Setup Notes

Requires a server restarted since `122b44b4`, with `20260830090000` applied.
`just refresh` does the restart and the migrate.
