# Runtime probes and reproducibility

Research date: 2026-10-24. This is a bounded research probe, not a production integration. The initial [architecture assessment](architecture-findings.md) was written before these tests. Source pins are in [source-manifest.json](source-manifest.json).

## Isolation and setup

Sources were cloned outside production working copies:

```sh
mkdir -p /private/tmp/cms-distributed-agent-research-20261024
git clone --depth 1 https://github.com/giuliastro/harness-remote.git /private/tmp/cms-distributed-agent-research-20261024/harness-remote
git clone --depth 1 https://github.com/OpenHands/software-agent-sdk.git /private/tmp/cms-distributed-agent-research-20261024/software-agent-sdk
git clone --depth 1 https://github.com/OpenHands/OpenHands.git /private/tmp/cms-distributed-agent-research-20261024/OpenHands
```

Each clone's `git rev-parse HEAD` was recorded. For later reproduction, check out the manifest SHA; shallow clones made later may need that commit fetched explicitly. No production branch was switched or committed. No candidate setup scripts, npm installation, uv sync, containers, or package postinstall hooks were run. The clone initially failed due to sandbox DNS restrictions; the same public-source clone succeeded with approved network access.

Before executing tests, inspected package manifests, imported test modules and relevant implementations: `session-operation-ledger.js`, `json-file-store.js`, `session-claim-server.js`, `acp-service.js`, `machine-daemon.js`, `acp-client.js`, process/environment management, and the steering/handoff test entry points. Tests use temporary files, injected fake ACP objects and loopback HTTP. Root package only needs qrcode-terminal for other entry points; these selected tests run with Node built-ins and local modules. No third-party provider adapter was downloaded. SDK setup.py and package manifests were inspected, but Python code was not installed or run.

## Available infrastructure

| Check | Result |
|---|---|
| Node | 22.21.1 |
| Python | 3.14.6 |
| Codex CLI | 0.164.0; `codex login status` says ChatGPT login |
| Claude Code | 2.1.306; sanitized `claude auth status --json` says loggedIn=false, authMethod=none |
| ACP adapter binaries | `codex-acp` and `claude-agent-acp` absent from PATH |
| Docker | CLI installed; `/var/run/docker.sock` absent, `docker info` fails |
| Python server/test dependencies | fastapi, pydantic, pytest and httpx absent in the inspected system interpreter |
| Remote execution host | No separate authorized host/connection was supplied or established |

Only authentication status was queried, with account-identifying fields discarded for Claude. No credential file/token was opened, copied or logged. An installed CLI is not proof that its ACP wrapper is installed or that an LLM turn can run. A ChatGPT-authenticated CLI does not establish available quota.

## A — Native remote coding-agent control

### A1: candidate control mechanics, simulated providers

From the pinned Harness Remote checkout:

```sh
node --test --test-reporter=tap \
  bridge/test/session-operation-ledger.test.js \
  bridge/test/acp-session-claim.test.js \
  bridge/test/native-session-claim-lifecycle.test.js \
  bridge/test/session-claim-server.test.js
node --test --test-reporter=tap \
  bridge/test/acp-service-steering.test.js \
  bridge/test/cross-machine-handoff-ledger-failure.test.js \
  bridge/test/cross-machine-handoff-ledger-scope.test.js
```

**Result:** 35/35 and 24/24 passed; 59 total. The first attempt under the restricted sandbox had 18 passes and 17 failures because listeners could not bind (`listen EPERM 127.0.0.1`). Rerunning the same inspected tests with approved loopback access passed. This was an environment failure, not a source fix. Raw successful output is retained in [first suite](evidence/harness-remote-tests-allowed.tap) and [steering suite](evidence/harness-remote-steering-tests.tap).

Verified within these tests: native ID routing, read-only journal observation before claim, writer-conflict handling, clearing claims on adapter exit, serialized prompt admission, queued versus steered dispositions, stop semantics against fake providers, request-signature conflicts, accepted-result persistence across ledger reconstruction, and avoiding replay after explicitly ambiguous target creation. Test names saying “native” or “cross-machine” describe their contracts; their providers are fake and HTTP is loopback. They do not prove native continuity or two-host networking.

### A2: additional adversarial ledger probes

```sh
node .code_my_spec/knowledge/competitive-analysis/distributed-agent-harness-2026-10-24/probes/ledger-boundaries.mjs \
  /private/tmp/cms-distributed-agent-research-20261024/harness-remote
```

Both assertions passed. [Raw result](evidence/ledger-boundaries.jsonl):

1. Two independently cached ledger objects using the same state directory both returned `duplicate:false` for one operation. They are two objects in one process, not two hosts. This establishes that the class itself is not a multi-instance lease; it does not prove the normal one-daemon deployment races this way.
2. A simulated side effect followed by an ordinary thrown Error (without `ambiguous=true`) was executed twice across retries. This is a deliberate adapter-failure classification probe, not an observed native duplicate command. Each adapter must preserve uncertainty after dispatch could have occurred.

### A3: installed native Codex protocol handshake

```sh
python3 .code_my_spec/knowledge/competitive-analysis/distributed-agent-harness-2026-10-24/probes/codex-initialize.py
```

The script starts `codex app-server --stdio`, sends only `initialize`, waits at most 15 seconds, and terminates that subprocess. No thread, prompt, model turn or tool operation is created. It discards native stderr and records only status/result field names; this bounds disclosure but limits diagnosis of failures.

The sandbox attempt timed out ([result](evidence/codex-initialize.json)). The unrestricted retry succeeded (`initialize` returned protocol/platform fields); the result is in [codex-initialize-allowed.json](evidence/codex-initialize-allowed.json). A successful initialize is protocol availability only, not authentication validation or session continuity. No native session lifecycle is claimed from it.

### Requested native lifecycle steps

| Step | Codex via Harness Remote | Claude via Harness Remote |
|---|---|---|
| Start native session on host | Not performed: required ACP wrapper not installed/audited | Not performed: no login; wrapper absent |
| Separate controller attaches | Fake HTTP tests only | Fake ACP tests only |
| Send instruction to existing session | Fake session-ID routing tested | Fake adapter behavior only |
| Inspect native state/output | Source analysis only | Source analysis only |
| Disconnect controller/reconnect | Ledger/claim simulations; no live native disconnect | Not performed |
| Resume exact native continuity | Not verified | Not verified |
| Second concurrent controller | Serialization/conflict simulations only | Ownership remains adapter-defined/unverified |
| Actual cross-machine test | Not performed | Not performed |

A missing adapter is not an impossibility result. Installing and auditing the pinned ACP package plus transitive SDK/binary would be required to proceed. We chose not to let the bridge's automatic `npx --yes` fallback execute uninspected dependencies. The native Codex handshake offers a smaller candidate integration path for a later controlled session experiment. Do not report Experiment A's full acceptance criteria as passed.

## B — OpenHands remote reasoning/execution separation

No Agent Server was started: its dependencies are absent and the Docker daemon is unavailable. No workspace was provisioned, remote command/file operation executed, controller disconnected, or workspace replaced. The requested runtime experiment remains **unperformed**, not failed and not successful. We did not install the complete backend stack merely to demonstrate a placement restriction visible in source.

Source evidence at the pinned SDK commit:

* `Conversation.__new__` at `openhands-sdk/openhands/sdk/conversation/conversation.py:158` selects RemoteConversation from RemoteWorkspace; `LocalConversation` at `impl/local_conversation.py:399` asserts LocalWorkspace.
* `RemoteConversation.attach`, WebSocket reconnect and event reconciliation support reconnecting a controller to a server-owned conversation. They do not move that conversation's reasoning outside the workspace server.
* `RemoteWorkspaceMixin` provides command start/output/stop, upload/download and Git methods usable without an OpenHands conversation. This is the execution-only integration candidate.
* `ExecuteBashRequest` has no client request ID; Bash service generates a command ID and persists it before starting. A lost start response still leaves the caller without its server-generated ID unless it can reconcile.
* The default factory does not implement #4187's requested separation; the issue was closed for inactivity, with `not_planned` state reason. This is source + issue evidence, not an executed rejection test.

The next B probe should run an authenticated Agent Server in a disposable container on a separate host, call only execution endpoints from outside it, and store harness conversation/operation state elsewhere. Verify a known file hash before/after edits; disconnect during a marked shell operation; reconnect by command/output IDs; replace the environment and check our central agent identity survives. Separately demonstrate the default OpenHands conversation placement to avoid conflating API control with remote reasoning.

## C — Harness compatibility, source-only

| Role | Harness Remote | OpenHands |
|---|---|---|
| Remote execution backend | Incomplete generic fs/shell API; native prompting is not direct execution | Strong REST command/files/Git candidate, not live-verified |
| Native-session adapter | Best focused reference; avoid its queue as authoritative | ACPAgent exists but introduces more SDK state |
| Host transport | HTTP/SSE daemon addressable behind our authenticated tunnel | REST/WS addressed server; retain existing enrollment/channel |
| Workspace backend | Task-coupled worktree manager duplicates ours | Optional container workspace provisioning; requires runtime isolation review |
| MCP facade | Build target-aware facade in our existing MCP service | Same; upstream MCP configuration is not the requested facade |

No compatibility adapter was implemented and no production tests were run. Existing control-plane records and contracts were read only.

## Distributed failure analysis

S = source evidence; T = narrow local tests. No rows imply actual host reboot/network-loss tests.

| Failure | Harness Remote | OpenHands | Required harness behavior |
|---|---|---|---|
| Network loss during command/turn | Daemon retains native ownership when observer leaves (S); live stream gap | Background Bash task independent of polling; events retained (S) | Return operation ID before wait; read status/output after reconnect |
| Completed mutation, response lost | Accepted ledger returns stored result (T); bounded retention | Server-generated command ID; response loss can hide it (S) | Persist client operation ID and reconcile unknown outcomes |
| Retry state change | Signature dedup (T); ambiguous flag required (T) | No start-command idempotency field (S) | Same ID+digest returns same operation; different digest conflicts |
| Conflicting controllers | One native writer, shared clients; queue/steer (T with fakes); no client lease | In-process run locks, shared API key (S) | One writer lease with fencing epoch; read-only observers |
| Host restart/loss | Local native journals and ledger needed; adapter claims reset (T) | Durable files require surviving volume; processes do not survive (S) | Central state survives; distinguish restart from disk loss; fence old host generation |
| Native process crash | Clear claims; provider-specific reload (T/S) | ACP native session resume; load error can fall back to fresh (S) | Report resumed vs fresh explicitly; never silently equate IDs |
| Concurrent working-copy edit | Worktrees isolate branches, not agents inspecting same tree (S) | Directory/path scoping not snapshot consistency (S) | Observe HEAD+dirty state+file hashes; precondition writes |
| Resume with stale repository context | Native transcript/history is not current repository proof | Persisted agent state not current repository proof | Refresh attachment metadata/diff; require acknowledgement of changed context |
| Integration branch advances | No CodeMySpec promotion semantics | No CodeMySpec promotion semantics | Retain existing project promotion lock/certification; revalidate target HEAD |

## Research limitations

No live model inference, native-session concurrency, credential refresh, actual host reboot, real network partition, production-scale load, multi-tenant penetration test or full license/dependency audit was performed. This is sufficient to choose a minimal prototype boundary; it is not sufficient to certify a deployable remote execution service.
