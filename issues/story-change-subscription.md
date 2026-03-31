# Story Change Subscription via Phoenix Channels

## Problem

Stories are managed in the SaaS app (postgres) but consumed locally (SQLite CLI DB). The CLI only syncs stories on boot via `BootSync`. If a story changes during a session — `component_id` linked, priority changed, new story created — the CLI doesn't know until next restart.

## Design

### Phoenix Channel: CLI → SaaS

The CLI connects to the SaaS app via a Phoenix Channel on boot. Subscribes to story topics for each linked project. When stories change on the SaaS side, the channel pushes the event to the CLI, which triggers `RemoteSync`.

**SaaS side:**
- Channel: `StoriesChannel` on topic `"stories:#{project_id}"`
- Stories context broadcasts on PubSub when stories are mutated
- Channel intercepts and pushes to connected clients
- Events: `story_created`, `story_updated`, `story_deleted`

**CLI side:**
- `Stories.ChannelClient` — GenServer that manages a Phoenix Channel connection
- On boot: connects to `ws://localhost:4000/socket/websocket` (or the configured SaaS URL)
- Joins `"stories:#{project_id}"` for each linked project
- On push: calls `RemoteSync.sync(scope)` for the affected project
- Reconnects automatically on disconnect (Phoenix channel client handles this)

### Flow

```
Boot
  │
  ├─ BootSync runs (pull all stories for all projects)
  │
  └─ ChannelClient starts
     ├─ Connects to SaaS WebSocket
     └─ Joins "stories:#{project_id}" for each linked project

During session
  │
  SaaS: user links component to story via set_story_component
  │
  ├─ Stories context broadcasts {:story_updated, story}
  ├─ StoriesChannel pushes "story_updated" to CLI
  └─ CLI ChannelClient receives push
     └─ RemoteSync.sync(scope) for that project
        └─ Story now has component_id locally
```

### Dependencies

- `phoenix_client` or `slipstream` hex package for the CLI-side channel client
- SaaS needs a StoriesChannel (may already exist or be easy to add)
- Auth: channel join needs to authenticate the CLI — could use the OAuth token from `AuthState`

### What exists

- `RemoteClient` — already authenticates against SaaS API via OAuth token
- `RemoteSync` — already knows how to pull and upsert stories
- `BootSync` — runs on boot, could also start the channel client
- SaaS has PubSub — just needs a channel to bridge it to WebSocket

## Implementation

1. **SaaS: StoriesChannel** — join `"stories:#{project_id}"`, push on story mutations
2. **SaaS: Stories context** — broadcast after create/update/delete
3. **CLI: Stories.ChannelClient** — GenServer, connects to SaaS WS, joins topics, triggers RemoteSync on push
4. **CLI: Supervision** — add ChannelClient to supervision tree after BootSync
5. **Auth** — pass OAuth token on channel join for authentication
