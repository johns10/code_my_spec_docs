# CodeMySpec.AgentTasks.Init.Elixir

## Type

module

Init step: verifies Elixir 1.18+ is available on PATH by shelling out to `elixir --version` from the project working directory and regex-matching the version string. `command/2` produces install instructions via asdf (preferred) or Homebrew.
