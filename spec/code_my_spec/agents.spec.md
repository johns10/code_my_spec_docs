# CodeMySpec.Agents

The agents CodeMySpec has started, and the credential each one runs on.

Server-side half of starting an agent. Owns which agents exist, on which working copy, and on which provider; mints the per-copy Pi configuration from the account's provider integration; and holds the record a conversation attaches to. `CmsHarness.Agents` is the other half — the OS process on the device — reached over the harness channel. Same split as Provisioning: state and ordering live server-side, execution happens on the box.

An agent is only started when it can be watched. Registration, login and the first messages are one act, not three: a started agent joins over `HarnessSocket`, `AgentHarness.relay_up/2` carries its turns into `Conversations`, and it appears in the agent chat surface alongside a Claude Code agent on the same copy. An agent the server cannot observe is indistinguishable from one that never started, which is what makes "it appears in chat and is talking" the acceptance signal rather than an exit status.

Credentials are held here as integrations, per provider, and both Pi credential kinds are in scope — OAuth for subscriptions, API key for coding plans. Adding a provider is adding an integration, not a second way to start an agent.

Dependencies: Integrations, Conversations, AgentHarness, Projects, Harnesses.

## Type

context
