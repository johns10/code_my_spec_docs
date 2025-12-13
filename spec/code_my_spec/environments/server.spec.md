
### CodeMySpec.Environments.ServerTerminal (`:server`)

Executes commands directly on the server using `System.cmd/3`. No tmux display.

**Functions**:
- set_vars/1: Sets process environment variables
- run_command/2: Executes command via System.cmd/3, returns output and exit_code
- read_file/1: Uses File.read/1
- list_directory/1: Uses File.ls/1
- setup/0: No-op (returns :ok)
- teardown/0: No-op (returns :ok)
