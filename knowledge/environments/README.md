# Environments

An environment is a durable named destination owned by a project. An app instance is a runtime assigned to that destination; replacing or deleting the instance does not delete the environment. A working copy owns source and an execution context describes how commands run. Neither is an environment.

`CodeMySpec.Environments` owns the `environments` table. The migration preserves the former provisioning environment identities, server links, hosts and first-deployment timestamps. `management` distinguishes harness runtimes from provisioned deployments and cannot be changed after creation.

`list/1` and `list_existing/1` are pure reads. Provisioning uses `list_deployment/1`, `deployment_names/1` and the deployment-only get/put APIs. Its initial prod/UAT rows are seeded only when the provisioned subset is empty; creating development cannot suppress that initialization or enter cloud resource fan-out.

A main working copy's default app instance attaches to a harness-managed development environment. Existing main instances are backfilled. If a provisioned destination already uses `dev`, development uses the first free `dev-local` name instead. Other harness destinations do not become development implicitly. Disposable QA instances may have no environment.

App-instance assignment checks project ownership. An environment with attached instances cannot be deleted. The environment survives instance replacement. Confirmed provider deployment records a persistent runtime and its image reference; a tag is not proof of a serving Git commit. Provider deployments use the environment's `device_id`, never the deployer's device. Provider inventory and harness enrollment share the same machine UUID; see [machine identity](../infrastructure/machine-identity.md).

Agents discover machines with `list_devices` / `get_device`, runtimes with `list_app_instances` / `get_app_instance`, and destinations with `list_environments`. Device discovery is account-scoped; working-copy IDs and connection observations within its output are project-scoped. Enrollment and last-seen timestamps do not establish availability. Instance discovery includes deployments without checkouts and reports recorded status, not a live health probe. Both surfaces use explicit credential-free fields.

`Environments.Tools` owns `ensure_environment`, `assign_environment_device` and `assign_app_instance_environment`. Assignments change association only; they do not deploy or move a process. Device placement takes the canonical machine UUID, not a provider resource ID. Provisioning retains `link_server` as a name-based compatibility convenience and owns actual provider operations. Read tools are available to Main, Product, Coding and QA; placement mutations remain Main's.

Harness lifecycle tools (`ensure_app_running`, `restart_app`, `stop_app`) default to the caller's own source checkout. Main can supply an explicit instance UUID for another checkout after connecting through `connect_working_copy`; the persisted active Main identity and attachment authorize the target. Disconnecting removes that authority for subsequent calls. Coding and QA retain their own-copy restriction. Provisioned deployments use provisioning rather than harness lifecycle, even if their environment is associated with a source checkout. Preview sharing remains own-copy scoped.
