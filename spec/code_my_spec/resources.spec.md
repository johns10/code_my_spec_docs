# CodeMySpec.Resources

What the account should have, against what it actually has.

Two checks feeding one answer. Per project, the expected set is derived from `Provisioning.Sequence` and the project's chosen options — no second manifest to disagree with the sequence that does the work. Across the account, the cross-cutting checks no single project can see: a DNS record aimed at an address no server holds, a bucket no environment names, a firewall covering nothing.

A project counts only when it is meant to be deployed — `devops != :off` and it has engaged with provisioning. Ten projects that were never meant to have infrastructure would otherwise report as entirely missing and drown the one real problem.

Never derives health from stored step state. `provisioning_steps.state` records what happened on the last run; a certificate that expired since then still reads as done. The expected side comes from our records, the actual side from the providers.

## Type

context

## Dependencies

- CodeMySpec.Projects
- CodeMySpec.Provisioning
- CodeMySpec.Servers
- CodeMySpec.Configurations
