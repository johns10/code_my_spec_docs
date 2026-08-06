# CodeMySpecWeb.ServerLive.Index

The servers screen at `/app/servers` — every box the account owns, linked or not.

Lists what the provider reports right now rather than what CodeMySpec recorded earlier, so a box resized in the Hetzner console reads correctly here. Linked servers are shown first; unlinked ones stay reachable behind a count ("+3 more") rather than being omitted, because a box nobody can see is a box that keeps billing.

Both ways in start here: link a server Sam already runs, or provision a new one. Provisioning states the cost and creates nothing until he confirms, the same discipline the domain purchase already has.

Two failure surfaces it must render rather than swallow: a provider that cannot be reached says so instead of showing an empty list (which would read as "you have no servers"), and a linked server destroyed at the provider is called out as missing rather than quietly disappearing.

## Type

liveview

## Dependencies

- CodeMySpec.Servers
