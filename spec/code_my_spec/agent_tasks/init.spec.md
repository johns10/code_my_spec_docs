# CodeMySpec.AgentTasks.Init

## Type

module

Parent agent task for project initialization — the pre-project-ID bootstrap. Walks an ordered list of step modules (`Init.Auth`, `Init.Elixir`, `Init.PhoenixInstaller`, `Init.Postgresql`, `Init.PhoenixProject`, `Init.CliConfig`), each implementing `command/2` + `evaluate/2`. `command/2` renders a combined checklist and inlines incomplete steps' prompts; `evaluate/2` short-circuits at the first not-done step. Once all steps pass, the directory has a linked project ID and transitions to project-level setup.

## Components

- ./init/auth.spec.md
- ./init/elixir.spec.md
- ./init/phoenix_installer.spec.md
- ./init/postgresql.spec.md
- ./init/phoenix_project.spec.md
- ./init/cli_config.spec.md

## Dependencies

- CodeMySpec.AgentTasks.Init.Auth
- CodeMySpec.AgentTasks.Init.CliConfig
- CodeMySpec.AgentTasks.Init.Elixir
- CodeMySpec.AgentTasks.Init.PhoenixInstaller
- CodeMySpec.AgentTasks.Init.PhoenixProject
- CodeMySpec.AgentTasks.Init.Postgresql
