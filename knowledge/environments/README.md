# Environments

An environment is a durable named destination owned by a project. An app instance is a runtime assigned to that destination; replacing or deleting the instance does not delete the environment. A working copy owns source and an execution context describes how commands run. Neither is an environment.

`CodeMySpec.Environments` owns the `environments` table. The migration preserves the former provisioning environment identities, server links, hosts and first-deployment timestamps. `management` distinguishes harness runtimes from provisioned deployments and cannot be changed after creation.

`list/1` and `list_existing/1` are pure reads. Provisioning uses `list_deployment/1`, `deployment_names/1` and the deployment-only get/put APIs. Its initial prod/UAT rows are seeded only when the provisioned subset is empty; creating development cannot suppress that initialization or enter cloud resource fan-out.

A main working copy's default app instance attaches to a harness-managed development environment. Existing main instances are backfilled. If a provisioned destination already uses `dev`, development uses the first free `dev-local` name instead. Other harness destinations do not become development implicitly. Disposable QA instances may have no environment.

App-instance assignment checks project ownership. An environment with attached instances cannot be deleted. The environment survives instance replacement. Confirmed provider deployment records a persistent runtime and its image reference; a tag is not proof of a serving Git commit. Provider deployments use the environment's `device_id`, never the deployer's device. Provider inventory and harness enrollment share the same machine UUID; see [machine identity](../infrastructure/machine-identity.md).

Agents use `list_environments`, `ensure_environment` and `assign_app_instance_environment`. Assignment changes association only; it does not deploy or move a process. Provisioning's existing UI remains focused on provisioned destinations.
