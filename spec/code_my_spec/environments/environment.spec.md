# CodeMySpec.Environments.Environment

**Type**: struct

Opaque struct representing an execution context. Encapsulates implementation-specific details.

## Fields

| Field    | Type | Required | Description                                                         | Constraints  |
| -------- | ---- | -------- | ------------------------------------------------------------------- | ------------ |
| type     | atom | Yes      | Environment type identifier (:cli, :server, :vscode)                |              |
| ref      | term | Yes      | Implementation-specific reference (window_ref, process_id, conn_id) |              |
| metadata | map  | No       | Optional context information                                        | Default: %{} |
