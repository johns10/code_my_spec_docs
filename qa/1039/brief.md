# QA Brief — Story 983: I choose which model each agent runs on

## Tool

`web` for the settings screen, `curl` for the MCP tool.

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

Nothing story-specific. **The seeds connect no provider**, which is not an
oversight to work around — it is the state most of this story's behaviour is
about, and one of its criteria.

## What To Test

**The settings screen** — `/app/accounts/:id/agents`

- Four types are listed: main, product, coding, qa. Not five; `spec_writer`
  folded into coding.
- A type nobody has set shows the default it *would* resolve to, marked
  `default` — not an empty field.
- Each type says what its default costs in words, not just a model id.
- With no provider connected: the page says so and links somewhere to fix it.
- Every provider is listed. Unconnected ones are **disabled and say why**,
  not hidden.

**Starting an agent** — `start_agent` over MCP

- With no provider connected, it refuses and says the account has none —
  rather than naming a provider nobody asked for.
- A type that does not exist is refused, and the refusal lists the types
  there are.
- The reply names the type, provider and model it started on. Before this
  story it named the provider only, which is not the thing being chosen.

**The one to look hardest at**

Whether a provider offered on that page can actually be connected. The page
lists what `Agents.Providers` knows; connecting goes through
`Integrations.authorize_url/1`, and those are two different lists. A provider
that can be chosen and never connected is a setting that cannot be used.

## Result Path

`.code_my_spec/qa/983/result.md`

## Setup Notes

Requires a server restarted since `6d01957d`, and both migrations applied.
`just refresh` does the restart and the migrate.

The story's point is cheap QA, so the question behind every check is whether
an account can actually end up with a cheap model running its QA agent — not
merely whether the page accepts a choice.
