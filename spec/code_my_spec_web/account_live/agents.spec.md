# CodeMySpecWeb.AccountLive.Agents

Where the account says which provider and model each agent type runs on.

Account-scoped, at `/app/accounts/:id/agents`, beside `AccountLive.Members` and `AccountLive.Invitations` — agents belong to the account, not to a project, so this sits where the account's other settings already do.

Shows the four types the `Agent.role` enum defines — main, product, coding, qa — and for each one the provider and model it will launch on. A type nobody has set shows the default it would resolve to rather than an empty field, because "unset" and "unset but it will do the right thing" are different things and only the second is true.

Only providers the account has a key for can be chosen. The others say what is missing rather than being silently absent — a screen that hides them makes a connected provider indistinguishable from one that does not exist.

Each choice says enough about what it costs to choose between them. The whole point is picking a cheap model for QA, and that is not a decision anybody can make from model names alone.


## Type

liveview
