# Credo.Plugin

Plugins are module which can provide additional functionality to Credo.

A plugin is basically just a module that provides an `init/1` callback.

    defmodule CredoDemoPlugin do
      def init(exec) do
        # but what do we do here??
        exec
      end
    end

The `Credo.Plugin` module provides a number of functions for extending Credo's core features.

    defmodule CredoDemoPlugin do
      @config_file File.read!(".credo.exs")

      import Credo.Plugin

      def init(exec) do
        exec
        |> register_default_config(@config_file)
        |> register_command("demo", CredoDemoPlugin.DemoCommand)
        |> register_cli_switch(:castle, :string, :X)
        |> prepend_task(:set_default_command, CredoDemoPlugin.SetDemoAsDefaultCommand)
      end
    end

## append_task(exec, group_name, task_mod)

Appends a `Credo.Execution.Task` module to Credo's main execution pipeline.

Credo's execution pipeline consists of several steps, each with a group of tasks, which you can hook into.

Appending tasks to these steps is easy:

    # credo_demo_plugin.ex
    defmodule CredoDemoPlugin do
      import Credo.Plugin

      def init(exec) do
        append_task(exec, :set_default_command, CredoDemoPlugin.SetDemoAsDefaultCommand)
      end
    end

Note how `Credo.Plugin.append_task/3` takes two arguments after the `Credo.Execution` struct: the name of the group to be modified and the module that should be executed.

The group names of Credo's main pipeline are:

- `:parse_cli_options`
- `:initialize_plugins`
- `:determine_command`
- `:set_default_command`
- `:initialize_command`
- `:parse_cli_options_final`
- `:validate_cli_options`
- `:convert_cli_options_to_config`
- `:resolve_config`
- `:validate_config`
- `:run_command`
- `:halt_execution`


The module appended to these groups should use `Credo.Execution.Task`:

    # credo_demo_plugin/set_demo_as_default_command.ex
    defmodule CredoDemoPlugin.SetDemoAsDefaultCommand do
      use Credo.Execution.Task

      alias Credo.CLI.Options

      def call(exec, _opts) do
        set_command(exec, exec.cli_options.command || "demo")
      end

      defp set_command(exec, command) do
        %Execution{exec | cli_options: %Options{exec.cli_options | command: command}}
      end
    end

This example would have the effect that typing `mix credo` would no longer run the built-in `Suggest` command, but rather our plugin's `Demo` command.

## append_task(exec, pipeline_key, group_name, task_mod)

Appends a `Credo.Execution.Task` module to the execution pipeline of an existing Command.

Credo's commands can also have an execution pipeline of their own, which is executed when the command is used and which you can hook into as well.

Appending tasks to these steps is easy:

    # credo_demo_plugin.ex
    defmodule CredoDemoPlugin do
      import Credo.Plugin

      def init(exec) do
        append_task(exec, Credo.CLI.Command.Suggest.SuggestCommand, :print_after_analysis, CredoDemoPlugin.WriteFile)
      end
    end

Note how `Credo.Plugin.append_task/4` takes three arguments after the `Credo.Execution` struct: the pipeline and the name of the group to be modified and the module that should be executed.

Here are the pipeline keys and group names:

- `Credo.CLI.Command.Suggest.SuggestCommand` (run via `mix credo suggest`)
  - `:load_and_validate_source_files`
  - `:prepare_analysis`
  - `:print_before_analysis`
  - `:run_analysis`
  - `:filter_issues`
  - `:print_after_analysis`

- `Credo.CLI.Command.List.ListCommand` (run via `mix credo list`)
  - `:load_and_validate_source_files`
  - `:prepare_analysis`
  - `:print_before_analysis`
  - `:run_analysis`
  - `:filter_issues`
  - `:print_after_analysis`

- `Credo.CLI.Command.Diff.DiffCommand` (run via `mix credo diff`)
  - `:load_and_validate_source_files`
  - `:prepare_analysis`
  - `:print_previous_analysis`
  - `:run_analysis`
  - `:filter_issues`
  - `:print_after_analysis`
  - `:filter_issues_for_exit_status`

- `Credo.CLI.Command.Info.InfoCommand` (run via `mix credo info`)
  - `:load_and_validate_source_files`
  - `:prepare_analysis`
  - `:print_info`


The module appended to these groups should use `Credo.Execution.Task`:

    # credo_demo_plugin/write_file.ex
    defmodule CredoDemoPlugin.WriteFile do
      use Credo.Execution.Task

      alias Credo.CLI.Options

      def call(exec, _opts) do
        issue_count = exec |> Execution.get_issues() |> Enum.count
        File.write!("demo.json", ~q({"issue_count": #{issue_count}}))

        exec
      end
    end

This example would have the effect that running `mix credo suggest` would write the issue count in a JSON file.

## prepend_task(exec, group_name, task_mod)

Prepends a `Credo.Execution.Task` module to Credo's main execution pipeline.

Credo's execution pipeline consists of several steps, each with a group of tasks, which you can hook into.

Prepending tasks to these steps is easy:

    # credo_demo_plugin.ex
    defmodule CredoDemoPlugin do
      import Credo.Plugin

      def init(exec) do
        prepend_task(exec, :set_default_command, CredoDemoPlugin.SetDemoAsDefaultCommand)
      end
    end

Note how `Credo.Plugin.prepend_task/3` takes two arguments after the `Credo.Execution` struct: the name of the group to be modified and the module that should be executed.

The group names of Credo's main pipeline are:

- `:parse_cli_options`
- `:initialize_plugins`
- `:determine_command`
- `:set_default_command`
- `:initialize_command`
- `:parse_cli_options_final`
- `:validate_cli_options`
- `:convert_cli_options_to_config`
- `:resolve_config`
- `:validate_config`
- `:run_command`
- `:halt_execution`


The module prepended to these groups should use `Credo.Execution.Task`:

    # credo_demo_plugin/set_demo_as_default_command.ex
    defmodule CredoDemoPlugin.SetDemoAsDefaultCommand do
      use Credo.Execution.Task

      alias Credo.CLI.Options

      def call(exec, _opts) do
        set_command(exec, exec.cli_options.command || "demo")
      end

      defp set_command(exec, command) do
        %Execution{exec | cli_options: %Options{exec.cli_options | command: command}}
      end
    end

This example would have the effect that typing `mix credo` would no longer run the built-in `Suggest` command, but rather our plugin's `Demo` command.

## prepend_task(exec, pipeline_key, group_name, task_mod)

Prepends a `Credo.Execution.Task` module to the execution pipeline of an existing Command.

Credo's commands can also have an execution pipeline of their own, which is executed when the command is used and which you can hook into as well.

Prepending tasks to these steps is easy:

    # credo_demo_plugin.ex
    defmodule CredoDemoPlugin do
      import Credo.Plugin

      def init(exec) do
        prepend_task(exec, Credo.CLI.Command.Suggest.SuggestCommand, :print_after_analysis, CredoDemoPlugin.WriteFile)
      end
    end

Note how `Credo.Plugin.prepend_task/4` takes three arguments after the `Credo.Execution` struct: the pipeline and the name of the group to be modified and the module that should be executed.

Here are the pipeline keys and group names:

- `Credo.CLI.Command.Suggest.SuggestCommand` (run via `mix credo suggest`)
  - `:load_and_validate_source_files`
  - `:prepare_analysis`
  - `:print_before_analysis`
  - `:run_analysis`
  - `:filter_issues`
  - `:print_after_analysis`

- `Credo.CLI.Command.List.ListCommand` (run via `mix credo list`)
  - `:load_and_validate_source_files`
  - `:prepare_analysis`
  - `:print_before_analysis`
  - `:run_analysis`
  - `:filter_issues`
  - `:print_after_analysis`

- `Credo.CLI.Command.Diff.DiffCommand` (run via `mix credo diff`)
  - `:load_and_validate_source_files`
  - `:prepare_analysis`
  - `:print_previous_analysis`
  - `:run_analysis`
  - `:filter_issues`
  - `:print_after_analysis`
  - `:filter_issues_for_exit_status`

- `Credo.CLI.Command.Info.InfoCommand` (run via `mix credo info`)
  - `:load_and_validate_source_files`
  - `:prepare_analysis`
  - `:print_info`


The module prepended to these groups should use `Credo.Execution.Task`:

    # credo_demo_plugin/write_file.ex
    defmodule CredoDemoPlugin.WriteFile do
      use Credo.Execution.Task

      alias Credo.CLI.Options

      def call(exec, _opts) do
        issue_count = exec |> Execution.get_issues() |> Enum.count
        File.write!("demo.json", ~q({"issue_count": #{issue_count}}))

        exec
      end
    end

This example would have the effect that running `mix credo suggest` would write the issue count in a JSON file.

## register_cli_switch(exec, name, type, alias_name \\ nil, convert_to_param \\ true)

Adds a CLI switch to Credo.

For demo purposes, we are writing a command called `demo` (see `register_command/3`):

    # credo_demo_plugin/demo_command.ex
    defmodule CredoDemoPlugin do
      import Credo.Plugin

      def init(exec) do
        exec
        |> register_command("demo", CredoDemoPlugin.DemoCommand)
      end
    end

    # credo_demo_plugin/demo_command.ex
    defmodule CredoDemoPlugin.DemoCommand do
      alias Credo.CLI.Output.UI
      alias Credo.Execution

      def call(exec, _) do
        castle = Execution.get_plugin_param(exec, CredoDemoPlugin, :castle)

        UI.puts("By the power of #{castle}!")

        exec
      end
    end

Since Plugins can be configured by params in `.credo.exs`, we can add the `:castle` param:

    # .credo.exs
    {CredoDemoPlugin, [castle: "Grayskull"]}

And get the following output:

```bash
$ mix credo demo
By the power of Grayskull!
```

Plugins can provide custom CLI options as well, so we can do something like:

```bash
$ mix credo demo --castle Winterfell
Unknown switch: --castle
```

Registering a custom CLI switch for this is easy:

    defmodule CredoDemoPlugin do
      import Credo.Plugin

      def init(exec) do
        exec
        |> register_command("demo", CredoDemoPlugin.DemoCommand)
        |> register_cli_switch(:castle, :string, :X)
      end
    end

Every registered CLI switch is automatically converted into a plugin param of the same name, which is why we get the following output:

```bash
$ mix credo demo --castle Winterfell
By the power of Winterfell!

$ mix credo demo -X Camelot
By the power of Camelot!
```

Plugin authors can also provide a function to control the plugin param's name and value more granularly:

    defmodule CredoDemoPlugin do
      import Credo.Plugin

      def init(exec) do
        exec
        |> register_command("demo", CredoDemoPlugin.DemoCommand)
        |> register_cli_switch(:kastle, :string, :X, fn(switch_value) ->
          {:castle, String.upcase(switch_value)}
        end)
      end
    end

And get the following output:

```bash
$ mix credo demo --kastle Winterfell
By the power of WINTERFELL!
```

## register_command(exec, name, command_mod)

Registers and initializes a Command module with a given `name`.

## Add new commands

Commands are just modules with a call function and adding new commands is easy.

    # credo_demo_plugin.ex
    defmodule CredoDemoPlugin do
      import Credo.Plugin

      def init(exec) do
        register_command(exec, "demo", CredoDemoPlugin.DemoCommand)
      end
    end

    # credo_demo_plugin/demo_command.ex
    defmodule CredoDemoPlugin.DemoCommand do
      alias Credo.CLI.Output.UI
      alias Credo.Execution

      def call(exec, _) do
        castle = Execution.get_plugin_param(exec, CredoDemoPlugin, :castle)

        UI.puts("By the power of #{castle}!")

        exec
      end
    end

Users can use this command by typing

```bash
$ mix credo demo
By the power of !
```

## Override an existing command

Since commands are just modules with a call function, overriding existing commands is easy.

    defmodule CredoDemoPlugin do
      import Credo.Plugin

      def init(exec) do
        register_command(exec, "explain", CredoDemoPlugin.MyBetterExplainCommand)
      end
    end

This example would have the effect that typing `mix credo lib/my_file.ex:42` would no longer run the built-in `Explain` command, but rather our plugin's `MyBetterExplain` command.

## register_default_config(exec, config_file_string)

Registers the contents of a config file.

This registers the contents of a config file as default config, loading it after Credo's own default config but before the [config files loaded from the current working directory](config_file.html#transitive-configuration-files).

    defmodule CredoDemoPlugin do
      @config_file File.read!(".credo.exs")

      import Credo.Plugin

      def init(exec) do
        register_default_config(exec, @config_file)
      end
    end