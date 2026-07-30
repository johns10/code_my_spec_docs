# CodeMySpec.Provisioning.ContentPublishing

Wires the already-built publish pipeline onto the new stack: a content bucket in the user's object storage, pull credentials and trigger configuration. Sync is trigger-only with no reconciliation pass, so a trigger that fails to land must be reported rather than swallowed. Not called done until a real post has rendered on the deployed site.

## Type

module
