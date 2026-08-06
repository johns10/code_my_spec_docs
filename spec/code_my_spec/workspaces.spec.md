# CodeMySpec.Workspaces

One visitor's running application instance: bring it up, report whether it came up or failed, and hand back the URL to look at it. In development that is the devbox container in Docker; the shared-host path is 986's and lands later. Failure is a first-class outcome here — the caller has to be able to tell the visitor it failed rather than leave them on a spinner.

## Type

context

## Dependencies

- CodeMySpec.Projects
- CodeMySpec.Environments
