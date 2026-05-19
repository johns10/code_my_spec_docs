# CodeMySpec.ProjectSync

Singleton GenServer that watches project directories for file changes and detects hex dep changes via `mix.lock` polling.

## Type

context

## Dependencies

- CodeMySpec.Embeddings
- CodeMySpec.Files
- CodeMySpec.Projects
- CodeMySpec.Repo
- CodeMySpec.Users
- Phoenix.PubSub

## Components

- ./project_sync/file_watcher_server.spec.md
