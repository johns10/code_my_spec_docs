# Credo.Execution

Every run of Credo is configured via an `Credo.Execution` struct, which is created and
manipulated via the `Credo.Execution` module.

## %Credo.Execution{}

The `Credo.Execution` struct is created and manipulated via the `Credo.Execution` module.

## build(argv \\ [])

Builds an Execution struct for the given `argv`.

## checks(exec)

Returns the checks that should be run for a given `exec` struct.

Takes all checks from the `checks:` field of the exec, matches those against
any patterns to include or exclude certain checks given via the command line.

## ensure_execution_struct(value, fun_name)

Ensures that the given `value` is a `%Credo.Execution{}` struct, raises an error otherwise.

Example:

    exec
    |> mod.init()
    |> Credo.Execution.ensure_execution_struct("#{mod}.init/1")

## get_assign(exec, name_or_list, default \\ nil)

Returns the assign with the given `name` for the given `exec` struct (or return the given `default` value).

    Credo.Execution.get_assign(exec, "foo")
    # => nil

    Credo.Execution.get_assign(exec, "foo", 42)
    # => 42

## get_command(exec, name)

Returns the `Credo.CLI.Command` module for the given `name`.

    Credo.Execution.get_command(exec, "explain")
    # => Credo.CLI.Command.Explain.ExplainCommand

## get_command_name(exec)

Returns the name of the command, which should be run by the given execution.

    Credo.Execution.get_command_name(exec)
    # => "suggest"

## get_given_cli_switch(exec, switch_name)

Returns the value for the given `switch_name`.

    Credo.Execution.get_given_cli_switch(exec, "foo")
    # => "bar"

## get_issues(exec)

Returns all issues for the given `exec` struct.

## get_issues(exec, filename)

Returns all issues for the given `exec` struct that relate to the given `filename`.

## get_issues_grouped_by_filename(exec)

Returns all issues grouped by filename for the given `exec` struct.

## get_plugin_param(exec, plugin_mod, param_name)

Returns the `Credo.Plugin` module's param value.

    Credo.Execution.get_command(exec, CredoDemoPlugin, "foo")
    # => nil

    Credo.Execution.get_command(exec, CredoDemoPlugin, "foo", 42)
    # => 42

## get_result(exec, name, default \\ nil)

Returns the result with the given `name` for the given `exec` struct (or return the given `default` value).

    Credo.Execution.get_result(exec, "foo")
    # => nil

    Credo.Execution.get_result(exec, "foo", 42)
    # => 42

## get_source_files(exec)

Returns all source files for the given `exec` struct.

    Credo.Execution.get_source_files(exec)
    # => [%SourceFile<lib/my_project.ex>,
    #     %SourceFile<lib/credo/my_project/foo.ex>]

## get_valid_command_names(exec)

Returns all valid command names.

    Credo.Execution.get_valid_command_names(exec)
    # => ["categories", "diff", "explain", "gen.check", "gen.config", "help", "info",
    #     "list", "suggest", "version"]

## halt(exec)

Halts further execution of the pipeline meaning all subsequent steps are skipped.

The `error` callback is called for the current Task.

    defmodule FooTask do
      use Credo.Execution.Task

      def call(exec) do
        Execution.halt(exec)
      end

      def error(exec) do
        IO.puts("Execution has been halted!")

        exec
      end
    end

## halt(exec, halt_message)

Halts further execution of the pipeline using the given `halt_message`.

The `error` callback is called for the current Task.
If the callback is not implemented, Credo outputs the given `halt_message`.

    defmodule FooTask do
      use Credo.Execution.Task

      def call(exec) do
        Execution.halt(exec, "Execution has been halted!")
      end
    end

## put_assign(exec, name_or_list, value)

Puts the given `value` with the given `name` as assign into the given `exec` struct and returns the struct.

    Credo.Execution.put_assign(exec, "foo", 42)
    # => %Credo.Execution{...}

## put_issues(exec, issues)

Sets the issues for the given `exec` struct, overwriting any existing issues.

## put_pipeline(exec, pipeline_key, pipeline)

Puts a given `pipeline` in `exec` under `pipeline_key`.

A pipeline is a keyword list of named groups. Each named group is a list of `Credo.Execution.Task` modules:

    Execution.put_pipeline(exec, :my_pipeline_key,
      load_things: [ MyProject.LoadThings ],
      run_analysis: [ MyProject.Run ],
      print_results: [ MyProject.PrintResults ]
    )

A named group can also be a list of two-element tuples, consisting of a `Credo.Execution.Task` module and a
keyword list of options, which are passed to the Task module's `call/2` function:

    Execution.put_pipeline(exec, :my_pipeline_key,
      load_things: [ {MyProject.LoadThings, []} ],
      run_analysis: [ {MyProject.Run, [foo: "bar"]} ],
      print_results: [ {MyProject.PrintResults, []} ]
    )

## put_result(exec, name, value)

Puts the given `value` with the given `name` as result into the given `exec` struct.

    Credo.Execution.put_result(exec, "foo", 42)
    # => %Credo.Execution{...}

## run_pipeline(initial_exec, pipeline_key)

Runs the pipeline with the given `pipeline_key` and returns the result `Credo.Execution` struct.

    Execution.run_pipeline(exec, :my_pipeline_key)
    # => %Credo.Execution{...}

## set_strict(exec)

Sets the exec values which `strict` implies (if applicable).

## tags_for_check(check, params)

Returns the tags for a given `check` and its `params`.