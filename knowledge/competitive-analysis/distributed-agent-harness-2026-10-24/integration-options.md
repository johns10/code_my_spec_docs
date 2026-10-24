# Integration options

These are engineering estimates, not measured delivery commitments. Assume one engineer familiar with the Elixir harness, one authenticated native runtime, two accessible machines, existing secure device channels, and no UI redesign. Prototype ranges exclude procurement/provider approval; production ranges include failure handling and focused integration tests, not comprehensive compliance certification.

## Option A — Build the missing execution interfaces

Extend existing `Agents.Transport`, device registration and MCP with target-aware filesystem/shell/process calls and explicit runtime binding. Keep the present mailbox, offers, assignments and promotion. Use provider-native protocols directly: initially Codex App Server, then supported Claude Code CLI/SDK mechanisms.

* **Complexity:** medium; approximately 1–2 engineer-weeks for a one-provider/two-host prototype, 5–9 weeks for robust operation records, authorization, streaming, recovery and a second provider. Do not interpret “thin adapter” as no distributed-systems work.
* **Operational risks:** duplicate commands after response loss, stale authority after host restart, provider process/API drift, and loss of direct-tool parity if every command becomes an agent prompt.
* **Maintenance:** own execution semantics and provider compatibility tests; avoid another daemon's task state and release cadence.
* **Compromises:** little architectural compromise; largest new implementation burden. Provider-native sessions remain provider-specific and may still require host-local persistent storage. Logical agent identity can outlive them without claiming exact native-state migration.
* **Reuse:** existing device channels, server database, mailbox generations, resource UUIDs, promotion checks; provider-supported runtime APIs. This is not a new scheduler.

Choose this if existing device channels already expose most required execution services and a direct native adapter proves smaller than extracting a candidate's modules.

## Option B — Adopt candidate infrastructure behind the harness

There are two materially different sub-options:

**B1: Harness Remote sidecar.** A daemon per authorized user/host owns native adapters; the existing harness maps agent bindings to daemon provider/session IDs. Use claim/prompt/stop/status/history endpoints. Keep our work admission authoritative and dispatch only when a provider can consume; avoid double durable queues. A separate execution API is still needed for main's direct file/shell access.

**B2: OpenHands Agent Server backend.** Call its command/files/Git APIs from the harness without creating OpenHands conversations. Treat Agent Server as a replaceable execution service. Native sessions still need a separate adapter, or accepting the heavier ACPAgent stack. Do not adopt Canvas or its automation service.

* **Complexity:** medium-high; 1–3 weeks to prove a sidecar path, roughly 6–10 weeks to harden both native-session and execution gaps. Two sidecars together increase deployment work.
* **Operational risks:** coarse machine-level auth, extra listener exposure, auto-allow provider policy, runtime package supply chain, filesystem-local state, two queues disagreeing about delivery, and duplicate start-command retries.
* **Maintenance:** vendor pinning plus upstream compatibility/security updates; versioned REST APIs reduce source-fork work, internal JS imports do not carry the same guarantee.
* **Compromises:** native sessions remain tied to provider cwd/state; OpenHands default conversations remain workspace-server owned. Adopting either candidate's task/offer model or moving promotion into it is excluded.
* **Reuse:** complete provider bridge (B1) or packaged execution API (B2). Auth, cross-host authority, workspace preconditions and durable harness operation IDs remain ours.

Neither sub-option alone meets all critical requirements. Adopting both is not automatically less work than extending the existing channel.

## Option C — Hybrid (preferred)

Keep the current device transport and orchestration. Build explicit runtime bindings, attachments and target-aware execution tools. Reuse selected Harness Remote adapter patterns/components after isolating their dependencies: capability negotiation, ACP lifecycle, claim versus observation, event normalization, and uncertainty-aware request handling. Prefer direct Codex App Server if its live prototype is smaller and preserves approvals more clearly. Use OpenHands execution APIs only for environment types where they save substantial work, such as an already-managed container fleet.

* **Complexity:** medium; 1–2 weeks for one provider and two workspaces, then 4–8 additional weeks for second provider, fault injection, output retention and permission hardening. Optional OpenHands container backend adds an estimated 1–3 weeks. These ranges overlap A/B because durable correctness is unavoidable whichever transport is chosen.
* **Operational risks:** maintaining a small extraction/fork, assuming protocol normalization erases provider differences, and accidentally allowing direct provider tools to bypass harness target permissions.
* **Maintenance:** lowest likely incremental surface for this repository; keep the provider adapter boundary versioned and test it against installed supported runtimes. Reuse ideas without copying entire services where that reduces coupling.
* **Compromises:** maintain a neutral harness agent/conversation identity plus explicit provider session bindings. A new native session after host loss is reported as a new binding, not disguised as uninterrupted continuity. Some clients need adapters beyond MCP for streaming or lifecycle control.
* **Reuse:** the existing harness first; targeted candidate/provider components second. Do not copy Harness Remote's file ledger as the authoritative distributed store: use the existing database and generation-aware mailbox model as the basis for a separate operation ledger.

## Decision gate

Approve implementation only after a real two-host prototype shows: an agent without a repository mount can inspect/edit/run commands on two target copies; its identity/history survive target replacement; a controller disconnect does not cancel an accepted operation; retry cannot repeat a known completed mutation; a stale writer is fenced; and accepted/declined/ignored/undelivered offer reporting remains consistent.

The current research supports choosing C for that prototype. It does not establish that A/B/C has already passed those acceptance criteria. See [runtime-probes.md](runtime-probes.md) for what actually ran.
