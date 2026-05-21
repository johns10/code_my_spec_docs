# CodeMySpec.AgentTasks.Init.PhoenixProject

## Type

module

Init step: verifies the current working directory looks like a Phoenix project root — checks for `mix.exs`, `lib/`, and `config/`. Reports which files are missing. `command/2` leads with the most-common cause (Claude Code launched from outside the project root → quit, `cd`, relaunch) and falls back to `mix phx.new` scaffolding instructions for the case where the user genuinely wants the cwd to become a fresh Phoenix app.
