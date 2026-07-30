# CodeMySpec.ProjectSecrets

Encrypted store for a project's provider credentials, held in a dedicated table rather than the process environment so decrypted values never reach an agent. Peer to Projects so anything — including a cloud-run agent — can read credentials without depending on Provisioning. Uses the existing Encrypted types for at-rest encryption, following the precedent set by projects.deploy_key.

## Type

context
