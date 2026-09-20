# CodeMySpec.WorkingCopies

The working copies serving a project. One entry per checkout, minted the first time that checkout joins and presented by it on every join after — the harness writes the id it is given into a gitignored file in the working copy, so a restart is the same harness and a fresh clone is correctly a new one.

Tracks identity (device, root, label), liveness (`last_seen_at`), which copy is the project's main one, and what each checkout reports about itself on sync: git state, preview status, machine tool availability. Also owns minting a fresh working copy for a project (staffing it with agents) and offboarding one (stopping its agents and releasing its channel).

## Type

context

## Dependencies

- CodeMySpec.Agents
- CodeMySpec.Analysis
- CodeMySpec.Components
- CodeMySpec.Devices
- CodeMySpec.Encrypted.Binary
- CodeMySpec.Environments
- CodeMySpec.Files
- CodeMySpec.Problems
- CodeMySpec.Projects
- CodeMySpec.Repo
- CodeMySpec.Stories
- CodeMySpec.Users
