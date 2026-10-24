# Candidate comparison

Research date: 2026-10-24. Pinned sources are in [source-manifest.json](source-manifest.json). All implementation claims concern those commits, not every past or future release.

## Evidence labels and conclusion

**T** = exercised here (scope stated); **S** = implemented source inspected, not runtime verified; **D** = documentation only; **P** = proposal; **N** = absent in the inspected interface, not a claim about every possible extension.

Prefer a hybrid. Harness Remote is the closer native-session adapter reference; OpenHands Agent Server is the stronger optional filesystem/command backend. Neither supplies the complete requested authority and workspace-independent identity model as a drop-in layer. Their orchestration and task models earn no credit: CodeMySpec already owns those responsibilities.

The OpenHands repository is now Agent Canvas, a React/TypeScript client, not the historical Python runtime. Backend implementation is in software-agent-sdk. Canvas is not an execution-backend candidate. This distinction comes from current package metadata and source, not project reputation.

## Pinned repositories and maturity

| Source | Commit | License | Evidence scope |
|---|---|---|---|
| Harness Remote 3.5.0 | `00882318c7de569be71f200f43f0a8eedc54d6ce` | Apache-2.0 | 59 targeted tests passed with fake provider adapters; two additional boundary probes |
| OpenHands SDK / Agent Server 1.58.1 | `acd96e6fa424c02432304395b9208f99be24b54d` | MIT | Source inspection only; Python runtime dependencies unavailable |
| OpenHands Agent Canvas 1.33.0 | `fee10e3d2909ebbf9950578575b1ee011492171e` | MIT | Source inspection only; UI not run |

Harness Remote exposes importable ES modules and HTTP factories with dependency injection, which made narrow tests possible without installation. Its root npm package exports a CLI, not a promised stable library API. Internal classes should be version-pinned behind our adapter. OpenHands provides separately packaged SDK, tools, workspace and Agent Server components, plus a typed TypeScript client and REST schemas. That is a clearer external API surface, but importing its full conversation architecture is a substantially larger commitment. No full security audit or production maturity certification was performed. Preserve license notices if copying source; third-party provider adapter licenses and dependencies need a separate audit before shipping.

## Harness Remote implementation map

* **Host discovery/connection (S)** — [bridge/src/machine-registry.js](https://github.com/giuliastro/harness-remote/blob/00882318c7de569be71f200f43f0a8eedc54d6ce/bridge/src/machine-registry.js#L50): `loadMachineIdentity`, `MachineRegistry`: stable machine.json identity; registry entries are provider hosts on that machine. This is not network-wide discovery. Clients pair/add a daemon URL; LAN/VPN reachability is external.

* **Session identity/persistence (S/T)** — [bridge/src/acp-service.js](https://github.com/giuliastro/harness-remote/blob/00882318c7de569be71f200f43f0a8eedc54d6ce/bridge/src/acp-service.js#L862): `claimSession` loads native session IDs; native runtime owns the conversation. Service caches and queues are in memory. Ledger tests cover persistence separately, not native transcripts.

* **Native processes (S)** — [bridge/src/acp-client.js](https://github.com/giuliastro/harness-remote/blob/00882318c7de569be71f200f43f0a8eedc54d6ce/bridge/src/acp-client.js#L123): `AcpClient.start` launches a stdio JSON-RPC child; shutdown is managed in managed-child-process.js. Profiles pin npm ACP adapter versions; default fallback uses npx and downloads code. We did not execute that fallback.

* **Filesystem/shell (S/N)** — [bridge/src/server.js](https://github.com/giuliastro/harness-remote/blob/00882318c7de569be71f200f43f0a8eedc54d6ce/bridge/src/server.js#L430): `/path` and `/file` provide directory selection/listing. The inspected generic bridge is not a complete arbitrary read/edit/shell/process RPC service. Agent prompts can invoke native tools, but that adds discretionary reasoning and is not equivalent to main directly invoking remote Bash. OpenCode forwarding is provider-specific.

* **Workspace lifecycle/isolation (S)** — [bridge/src/worktree-manager.js](https://github.com/giuliastro/harness-remote/blob/00882318c7de569be71f200f43f0a8eedc54d6ce/bridge/src/worktree-manager.js#L54): `WorktreeManager.prepare` creates task branches/worktrees; removal checks dirtiness. Reusing it would duplicate existing team/worktree logic. A worktree is not an OS security boundary.

* **Messaging/streaming (S/T)** — [bridge/src/acp-service.js](https://github.com/giuliastro/harness-remote/blob/00882318c7de569be71f200f43f0a8eedc54d6ce/bridge/src/acp-service.js#L1529): `prompt`, `#serializePrompt`, `#prompt`: serialize admission; queue normally, steer Codex when declared. Tested with fake ACP. server.js exposes SSE; managed-event-fanout.js shares a provider stream among clients.

* **Authentication/authorization (S)** — [bridge/src/http-policy.js](https://github.com/giuliastro/harness-remote/blob/00882318c7de569be71f200f43f0a8eedc54d6ce/bridge/src/http-policy.js#L46): `matchesCredentials` and `authenticateDaemonRequest`: Basic authentication, exact-origin CORS. config.js:137 requires credentials beyond loopback. pairing-server.js provides expiring single-use pairing grants. This is a machine-account boundary, not project/agent RBAC.

* **Retry/recovery (S/T)** — [bridge/src/session-operation-ledger.js](https://github.com/giuliastro/harness-remote/blob/00882318c7de569be71f200f43f0a8eedc54d6ce/bridge/src/session-operation-ledger.js#L17): `SessionOperationLedger`, `runIdempotentMutation`: persist pending/accepted/uncertain states and request signatures. Accepted results survive reconstructed instances; ambiguous records are not blindly replayed. Tested locally.

* **Multi-client coordination (S/T)** — [bridge/src/machine-daemon.js](https://github.com/giuliastro/harness-remote/blob/00882318c7de569be71f200f43f0a8eedc54d6ce/bridge/src/machine-daemon.js#L217): Claims belong to a live adapter process and clear on adapter exit. HTTP clients share that writer; this is not one independent writer lease per client. Fake-provider tests verify claim reset and prompt serialization.

* **Integration interfaces (S)** — [bridge/src/session-claim-server.js](https://github.com/giuliastro/harness-remote/blob/00882318c7de569be71f200f43f0a8eedc54d6ce/bridge/src/session-claim-server.js#L179): `createSessionClaimServer`: /v1/agents/:provider/session/:id/{claim,prompt,command,stop,handoff}; mutations require clientRequestId. Agent-facing transport is HTTP/SSE, adapter-facing transport ACP. No general MCP facade established by this inspection.

### Native runtime specifics

[bridge/src/harness-profiles.js](https://github.com/giuliastro/harness-remote/blob/00882318c7de569be71f200f43f0a8eedc54d6ce/bridge/src/harness-profiles.js#L137) configures Claude through `@agentclientprotocol/claude-agent-acp@0.84.0`, wrapping the Claude Agent SDK. It declares external observation via session/load **unverified**, and ownership adapter-defined. Do not advertise safe concurrent CLI+ACP control from this implementation. The profile's comment calling an adapter “official” is a project claim, not independent provider endorsement.

[bridge/src/harness-profiles.js](https://github.com/giuliastro/harness-remote/blob/00882318c7de569be71f200f43f0a8eedc54d6ce/bridge/src/harness-profiles.js#L331) configures Codex through `@agentclientprotocol/codex-acp@1.13.1`, with native account reuse and authentication disabled during discovery. Native journal reading can observe an externally held session without loading it. Explicit claim requires the native writer; desktop/CLI ownership can prevent loading even when idle. The native lock behavior is source-supported here, not live-tested against an authenticated native thread.

Session continuation, simultaneous observers, queued/steered input to one writer, and two independent writers are four different capabilities. Only the first three are represented in this design; provider-specific caveats remain.

[bridge/src/cross-machine-target-runtime.js](https://github.com/giuliastro/harness-remote/blob/00882318c7de569be71f200f43f0a8eedc54d6ce/bridge/src/cross-machine-target-runtime.js#L20) creates a **new target native session** and lineage metadata. It explicitly does not claim the source session, transfer writer/approval/tool state or send the first prompt. Cross-machine handoff is not transparent migration of a native session. A remote controller can address the original machine's daemon instead; actual two-host operation was not tested.

### Important recovery and security limits

* The operation ledger retains at most 1,024 entries by evicting old accepted records. Its `JsonFileStore.serial` queue is per object; atomic rename does not provide a distributed lease or multi-process transaction. Two preloaded instances admitted the same request in our probe. No claim of crash/power-loss fsync durability is warranted.
* `runIdempotentMutation` relies on `error.ambiguous` when dispatch throws before returning. A simulated side effect followed by an unmarked exception was executed twice on retry. This demonstrates adapter error-classification requirements, not a confirmed duplicate in every provider path.
* A queued prompt lives in `AcpService.#queues`. A durable accepted receipt can therefore mean admitted/queued, not completed or durably enqueued at the native provider. Daemon restart before dequeue needs reconciliation; the ledger alone cannot restore the lost queue payload.
* SSE disconnect removes the subscriber, not necessarily the native turn. Streams are live fanout; a complete durable Last-Event-ID replay protocol was not established. Re-read native history after reconnect, with provider-specific gaps.
* Profiles set `permissionMode: "allow"`. Do not inherit that policy for arbitrary agents. Roots constrain browsing/new-session selection, not an existing session's filesystem authority. The bridge runs with its OS user's privileges. Gateway Basic credentials must travel inside TLS/VPN, not bare internet HTTP. Child environment code removes gateway credential variables but does not provide OS isolation.

[bridge/src/json-file-store.js](https://github.com/giuliastro/harness-remote/blob/00882318c7de569be71f200f43f0a8eedc54d6ce/bridge/src/json-file-store.js#L24); [bridge/src/session-operation-ledger.js](https://github.com/giuliastro/harness-remote/blob/00882318c7de569be71f200f43f0a8eedc54d6ce/bridge/src/session-operation-ledger.js#L191); [bridge/src/acp-service.js](https://github.com/giuliastro/harness-remote/blob/00882318c7de569be71f200f43f0a8eedc54d6ce/bridge/src/acp-service.js#L1581); [bridge/src/server.js](https://github.com/giuliastro/harness-remote/blob/00882318c7de569be71f200f43f0a8eedc54d6ce/bridge/src/server.js#L396); [bridge/src/child-environment.js](https://github.com/giuliastro/harness-remote/blob/00882318c7de569be71f200f43f0a8eedc54d6ce/bridge/src/child-environment.js).

## OpenHands implementation map

* **Host connection/discovery (S)** — [openhands-sdk/openhands/sdk/workspace/remote/remote_workspace_mixin.py](https://github.com/OpenHands/software-agent-sdk/blob/acd96e6fa424c02432304395b9208f99be24b54d/openhands-sdk/openhands/sdk/workspace/remote/remote_workspace_mixin.py#L36): `RemoteWorkspaceMixin`: explicit host URL, session API key and working_dir; optional immutable runtime_conversation_id controls API prefix. This connects to an addressed server; it does not discover arbitrary enrolled devices.

* **Agent/conversation identity (S)** — [openhands-sdk/openhands/sdk/conversation/conversation.py](https://github.com/OpenHands/software-agent-sdk/blob/acd96e6fa424c02432304395b9208f99be24b54d/openhands-sdk/openhands/sdk/conversation/conversation.py#L158): `Conversation.__new__`: RemoteWorkspace produces RemoteConversation and rejects client persistence_dir. LocalConversation asserts LocalWorkspace at impl/local_conversation.py:399. Thus the outside Python object is a controller for server-owned reasoning.

* **Native coding-agent processes (S)** — [openhands-sdk/openhands/sdk/agent/acp_agent.py](https://github.com/OpenHands/software-agent-sdk/blob/acd96e6fa424c02432304395b9208f99be24b54d/openhands-sdk/openhands/sdk/agent/acp_agent.py#L1764): `ACPAgent` implements configurable subprocess adapters, model negotiation, native resume IDs and session load. This is real implementation, not “OpenHands cannot use native agents”; adopting it also imports OpenHands AgentBase/conversation machinery. Provider login and concurrent ownership were not tested.

* **Filesystem/shell/Git (S)** — [openhands-agent-server/openhands/agent_server/bash_service.py](https://github.com/OpenHands/software-agent-sdk/blob/acd96e6fa424c02432304395b9208f99be24b54d/openhands-agent-server/openhands/agent_server/bash_service.py#L274): `BashEventService.start_bash_command` persists command metadata, spawns a background task/process group and records output events. file_router.py and git_router.py expose file and Git operations; RemoteWorkspaceMixin invokes those APIs independently of conversation creation.

* **Workspace lifecycle/isolation (S)** — [openhands-workspace/openhands/workspace/docker/workspace.py](https://github.com/OpenHands/software-agent-sdk/blob/acd96e6fa424c02432304395b9208f99be24b54d/openhands-workspace/openhands/workspace/docker/workspace.py#L53): `DockerWorkspace` launches an Agent Server container and supports cleanup/pause/resume. LocalWorkspace is a directory, not a sandbox. Cloud, remote_api, agent_sandbox and Apptainer implementations exist but were not runtime tested.

* **Messaging/streaming (S)** — [openhands-sdk/openhands/sdk/conversation/impl/remote_conversation.py](https://github.com/OpenHands/software-agent-sdk/blob/acd96e6fa424c02432304395b9208f99be24b54d/openhands-sdk/openhands/sdk/conversation/impl/remote_conversation.py#L174): `WebSocketCallbackClient`, `RemoteEventsList.reconcile`, and RemoteConversation attach/run implement streaming, reconnect and event reconciliation. Persisted events can fill observation gaps; this is not exactly-once mutation delivery.

* **Authentication/authorization (S)** — [openhands-agent-server/openhands/agent_server/dependencies.py](https://github.com/OpenHands/software-agent-sdk/blob/acd96e6fa424c02432304395b9208f99be24b54d/openhands-agent-server/openhands/agent_server/dependencies.py#L27): `check_session_api_key` gates requests when keys are configured. Empty key configuration allows access. Workspace cookies have a narrower route group. A shared session key does not supply CodeMySpec account/project/agent authorization.

* **Recovery/retry (S)** — [openhands-agent-server/openhands/agent_server/bash_service.py](https://github.com/OpenHands/software-agent-sdk/blob/acd96e6fa424c02432304395b9208f99be24b54d/openhands-agent-server/openhands/agent_server/bash_service.py#L85): Bash events are files with command/event IDs and output order; background process ownership is memory-local. ExecuteBashRequest in models.py:638 has command/cwd/timeout, no client idempotency key. Retrying a lost start response can create another command.

* **Multi-client coordination (S)** — [openhands-agent-server/openhands/agent_server/event_service.py](https://github.com/OpenHands/software-agent-sdk/blob/acd96e6fa424c02432304395b9208f99be24b54d/openhands-agent-server/openhands/agent_server/event_service.py#L220): `EventService` owns a run task and asyncio run lock; conversation_service.py:558 has lifecycle/per-conversation locks. These coordinate one server process, not a distributed authority lease. Multiple remote observers do not mean conflicting writers are safe.

* **MCP/ACP and other APIs (S)** — [openhands-agent-server/openhands/agent_server/api.py](https://github.com/OpenHands/software-agent-sdk/blob/acd96e6fa424c02432304395b9208f99be24b54d/openhands-agent-server/openhands/agent_server/api.py#L572): REST route groups and WebSocket support; clients/typescript provides typed clients. ACPAgent consumes ACP; acp_router.py performs provider model discovery. mcp_router.py tests/configures upstream MCP connections; do not mistake that for an agent-facing MCP filesystem/shell server.

### Issue #4187: current status and implemented alternatives

[Issue #4187](https://github.com/OpenHands/software-agent-sdk/issues/4187) was created 2026-07-22 and closed 2026-09-29 with state_reason `not_planned`. The closing comment says inactivity, not implementation. Three comments were fetched through the GitHub connector. No implementation or maintainer acceptance is established by those comments. One user's security test report is third-party evidence, not a test performed here.

The requested server-owned conversation with a remote execution-only workspace remains **P/N for the default Conversation/LocalConversation binding at this pin**: the factory and explicit LocalWorkspace assertion above still enforce placement coupling. Current Docker runtime routers/proxy and secret mediation show a full inner Agent Server, not proof of issue #4187's requested default-tool split. See [openhands-agent-server/openhands/agent_server/docker_runtime/proxy.py](https://github.com/OpenHands/software-agent-sdk/blob/acd96e6fa424c02432304395b9208f99be24b54d/openhands-agent-server/openhands/agent_server/docker_runtime/proxy.py#L83) and [openhands-agent-server/openhands/agent_server/docker_runtime/mediation.py](https://github.com/OpenHands/software-agent-sdk/blob/acd96e6fa424c02432304395b9208f99be24b54d/openhands-agent-server/openhands/agent_server/docker_runtime/mediation.py).

However, it is already possible at the API level to use a remote workspace strictly as an execution client, without creating an OpenHands conversation. That can sit behind our harness while our agent reasons elsewhere. Custom remote tools/client tools are another integration avenue, but not the unchanged default-tool solution proposed in #4187. None of these possibilities proves a single default OpenHands agent session can transparently switch remote workspaces. No supported hot-swap guarantee was found; replacing a workspace object is not proof of preserved state.

Conversation-scoped runtime routes validate paths but explicitly say they are not a sandbox for arbitrary shell commands ([openhands-agent-server/openhands/agent_server/runtime_router.py](https://github.com/OpenHands/software-agent-sdk/blob/acd96e6fa424c02432304395b9208f99be24b54d/openhands-agent-server/openhands/agent_server/runtime_router.py#L1)). Strong isolation needs separate OS/container boundaries and separate credential authority. Do not generalize the issue comment's old-version vulnerability report to this pin: it now sanitizes child environments, but same-user process/filesystem isolation still needs testing.

### Additional current-source recovery details

The newer [session socket](https://github.com/OpenHands/software-agent-sdk/blob/acd96e6fa424c02432304395b9208f99be24b54d/openhands-agent-server/openhands/agent_server/session_socket.py#L1) separates durable frames/history replay from transient stream deltas and uses a bounded connection writer. [Socket authentication](https://github.com/OpenHands/software-agent-sdk/blob/acd96e6fa424c02432304395b9208f99be24b54d/openhands-agent-server/openhands/agent_server/sockets.py#L134) includes first-message authentication. Both are implemented but untested here; this is stronger observation recovery than merely reconnecting a WebSocket.

[ACPAgent load handling](https://github.com/OpenHands/software-agent-sdk/blob/acd96e6fa424c02432304395b9208f99be24b54d/openhands-sdk/openhands/sdk/agent/acp_agent.py#L3254) catches an ACP load error and can start a fresh session. A harness integration must surface that distinction explicitly rather than promising exact native continuation whenever resume was requested.

## Agent Canvas findings

[package.json](https://github.com/OpenHands/OpenHands/blob/fee10e3d2909ebbf9950578575b1ee011492171e/package.json#L1) pins `@openhands/typescript-client` 1.58.1. [src/api/backend-registry/types.ts](https://github.com/OpenHands/OpenHands/blob/fee10e3d2909ebbf9950578575b1ee011492171e/src/api/backend-registry/types.ts) and [src/api/backend-registry/storage.ts](https://github.com/OpenHands/OpenHands/blob/fee10e3d2909ebbf9950578575b1ee011492171e/src/api/backend-registry/storage.ts) implement client-side backend selection/persistence. [bin/agent-canvas.mjs](https://github.com/OpenHands/OpenHands/blob/fee10e3d2909ebbf9950578575b1ee011492171e/bin/agent-canvas.mjs#L60) launches a full UI/server/automation stack through uvx. Reusing this UI would add little to the missing execution layer and introduce another frontend and operational stack. Backend selection is not host enrollment or a workspace-independent agent identity service. No Canvas code is recommended for the minimal integration.

## Requirement evaluation

These are fit judgments from the evidence above, not numerical benchmark scores.

| Requirement | Importance | Harness Remote | OpenHands SDK / Agent Server |
|---|---|---|---|
| Remote host access | Critical | Addressable daemon; external network required (S) | Addressable REST server/workspace (S) |
| Native Codex/Claude reuse | Critical | Focused ACP profiles (S); fake adapters tested | ACPAgent implemented (S), heavier coupling |
| Agent independent of workspace | Critical | Controller independent; native session still cwd/host-bound | Default conversation placement coupled; execution APIs usable separately |
| Main Bash/filesystem parity | Critical | Generic RPC surface incomplete | Bash/files/Git APIs good candidate; permissions adapter required |
| Existing harness integration | Critical | Select adapter modules or sidecar; avoid task stack | Execution-only REST client; avoid Conversation adoption |
| Durable session recovery | High | Native journals plus bounded ledger; host-state dependence | Server persistence/events; storage and runtime dependence |
| MCP/client interoperability | High | Needs our MCP facade; ACP toward providers | Needs our MCP facade; upstream MCP consumption exists |
| Simultaneous environments | High | Multiple daemon URLs/provider sessions | Multiple workspace clients/containers |
| Multi-client access | High | Observers plus one shared native writer; no per-client lease | Observers/server locks; no cross-server writer guarantee |
| Explicit auth/authorization | High | Basic/pairing; coarse OS-account authority | Session keys; our role/resource policy still needed |
| Subscription operation | High | Provider-native auth path, eligibility dependent | ACP path possible; normal LLM integration uses provider credentials |
| Workspace isolation | High | Worktrees, not a sandbox | Local dirs or container backends; configuration dependent |
| Streaming output | Medium | ACP/SSE; journal reconciliation | WS/event reconciliation and Bash event polling |
| Built-in orchestration | Low | Excluded from value assessment | Excluded from value assessment |
| Built-in task/offer model | Low | Do not adopt | Do not adopt |

## Provider-supported authentication and concurrency

**Codex (D plus local diagnostic):** native CLI supports ChatGPT sign-in as well as API keys. Installed version 0.164.0 reports ChatGPT authentication. App Server documents thread start/resume and streamed turns/approvals; it is a direct alternative to an ACP dependency. Keep provider authentication on the runtime host through supported login. Auth status does not prove a successful model request, available quota or all remote integration entitlements. No universal numeric concurrent-session allowance was established; plan/workspace limits and writer ownership are separate constraints. See [authentication](https://learn.chatgpt.com/docs/auth) and [App Server](https://learn.chatgpt.com/docs/app-server). Do not copy auth.json or refresh tokens to implement multiplicity.

**Claude (D plus local diagnostic):** installed version 2.1.306 reports no login. Current provider guidance says SDK/`claude -p` use can still draw from subscription limits; this is not permission to collect or proxy end-user OAuth credentials. Hosted unmodified Claude Code has explicit conditions: user authenticates directly, usage is theirs, and authentication methods remain intact. Keep own-product SDK billing and hosted native CLI usage distinct. Source: [subscription update, October 7](https://support.claude.com/en/articles/15036540-use-the-claude-agent-sdk-with-your-claude-plan), [credential and hosted-product conditions](https://code.claude.com/docs/en/legal-and-compliance). Programmatic CLI supports continuation and structured output; `--bare` skips OAuth/keychain and is unsuitable for a subscription reuse probe. See [programmatic operation](https://code.claude.com/docs/en/headless). No numeric concurrency entitlement was verified.

Harness Remote also has OpenCode, PI, OMP, Copilot and other profiles. Their existence is source evidence only; no provider billing, login or concurrent-session claims were verified. Keep them out of the first integration.

## Secondary projects

Agent Zero, Sandbase Harness, clai and cowork were not investigated. The primary sources already identify reusable provider adapters and execution APIs. The remaining gaps are CodeMySpec-specific identity/authority boundaries and operation correctness, for which another orchestration framework is not evidence of a solution. A further shortlist is warranted only if a real two-host prototype shows the selected adapters or execution APIs cannot meet a specific capability. No comparative claims about these uninspected repositories are made.
