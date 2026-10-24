# Machine identity

`CodeMySpec.Devices` owns machines. A device can be a laptop, a development container, or a provisioned server with no harness. `CodeMySpec.Servers` remains the provider-operation interface; it has no separate machine table or schema.

A machine UUID is distinct from a provider resource ID. Devices retain `provider`, `provider_name`, `provider_resource_id`, and a human `purpose`. Provider inventory retains its external `id` and exposes `device_id` separately. A conflicting provider resource ID under an existing name is refused; it cannot inherit that machine's credentials. Hardware and provider status are still fetched from the provider. Harness presence is only the harness connection, never proof that a production server is up or down.

The cutover preserves linked-server UUIDs as device UUIDs, account ownership, purpose, and timestamps. Existing device credentials, working copies, and IDs are unchanged. Environment links use `device_id`; confirmed deployment instances use that destination device. Disposable app instances may remain unassigned to an environment.

An owner or admin can enroll an existing machine. The one-time device token authenticates that exact UUID; the harness's proposed UUID cannot replace it. Enrollment does not create a second machine. Hostname and IP matching are never used to merge identities. Previously duplicated real-world machines require an explicit association decision.

Retiring a provider link clears its provider metadata while preserving the machine, credentials, and working copies. Active environment references prevent retirement and device deletion. Removing a database record never destroys provider infrastructure. Other existing device deletion behavior remains unchanged.

The identity migration is intentionally irreversible: after enrollment, splitting machines back into server records can duplicate or orphan identities. Its down operation refuses without modifying data; rollback requires restoring a database backup. Both adapters preserve UUIDs, and SQLite rebuilds the environment foreign key atomically with a foreign-key integrity check.
