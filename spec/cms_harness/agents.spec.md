# CmsHarness.Agents

Coding-agent processes running on this machine's working copies — start one, list what is running, stop it, and reap it when the harness goes away.

Harness-side because that is where the working copy is. The server holds no disk and cannot start a process on someone's machine; `CodeMySpec.AgentHarness` is only PubSub topic helpers and starts nothing. A Pi lane connects *in* over `HarnessSocket`, so nothing here needs the agent's stdio — start, stop and reap is the whole surface.

`MuonTrap.Daemon` was the original choice and is not what shipped. Its strongest guarantee is cgroup teardown, which is Linux-only, and the primary development machine is macOS — where the platform gap is not theoretical: macOS ships no `setsid`, and `Runner.Local` falls back to merely disowning the child there, which is exactly why it orphans. `CmsHarness.Agents.Runner` uses `perl -e 'setpgrp; exec @ARGV'` instead, measured on Darwin before anything was built on it: a group of three, one TERM to the group, nothing left.

An agent is started detached, in a process group of its own, and **outlives the harness on purpose**. Restarting the harness is routine here — `just refresh-harness` runs several times a day — and supervising the agent under the per-working-copy tree would make every one of those restarts kill every agent on the machine, cutting off whatever each was part-way through.

That inverts the original design, which put agents under `CmsHarness.Project.Supervisor` so an agent died with the copy it served, citing the failure `Workspaces.Runner.Local` documents against itself at `local.ex:36-44`. The lesson there stands and is not what was dropped: `Runner.Local` orphans a process *and keeps a row pointing at it*, with nothing able to find or end it afterwards. The problem is the unreachable orphan, not the surviving process.

So the survival is kept and the unreachability is removed. Each agent is its own process group leader, so one signal takes it and every tool it spawned; the group id is recorded with the boot it belongs to, so a recycled number can never be mistaken for ours; and an agent whose lane has gone is found and ended by the reconcile rather than forgotten. Story 961 is that half.

Decided 2026-08-23, after the code had already been written this way and the divergence was noticed.

Also owns the per-working-copy Pi configuration directory the agent is started against (`PI_CODING_AGENT_DIR`). Per copy rather than per machine because the cloud host is multi-tenant: one shared `~/.pi/agent/auth.json` would put one tenant's subscription in reach of another. The directory sits outside the working copy, so starting an agent never writes a credential into the tree.

## Type

module
