# CodeMySpec.AgentTasks.Init.PhoenixInstaller

## Type

module

Init step: verifies the Phoenix installer archive (`phx_new`) is available for the active Elixir toolchain by running `mix phx.new --version` from the project working directory. Queries `mix` rather than scanning `~/.mix/archives` so the check honors version managers like asdf where archives live under each Elixir version. `command/2` produces the `mix archive.install hex phx_new` instruction.
