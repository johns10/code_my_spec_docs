# CodeMySpec.AgentTasks.Init.CliConfig

## Type

module

Init step: verifies the current working directory is linked to a project in the local DB by looking up `Projects.Project` where `local_path == scope.cwd`. `command/2` directs the user to `list_projects` then `init_project` to link the directory, plus `.gitignore` entries for `.code_my_spec/internal/` and `/diagnostics.jsonl`.

## Dependencies

- CodeMySpec.Projects
- CodeMySpec.Repo
