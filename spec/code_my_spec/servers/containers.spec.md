# CodeMySpec.Servers.Containers

Reads what is running on a server, from the server. Runs `docker ps` over SSH with the account's access key and returns every container the box reports — running, exited or restarting — with the reason it is in that state. Never consults our record of what was deployed: a container that crashed an hour ago is exactly what this exists to surface, and the deploy that put it there still says it succeeded. Returns an error naming the cause when the box cannot be reached, which is distinct from a box running nothing, and distinct again from a box that never gave us a key.

## Type

module

## Dependencies

- CodeMySpec.AccountSecrets
- CodeMySpec.Environments
