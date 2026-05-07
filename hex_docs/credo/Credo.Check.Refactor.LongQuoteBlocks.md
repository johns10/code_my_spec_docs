# Credo.Check.Refactor.LongQuoteBlocks

## Basics

> #### This check is enabled by default. {: .tip}
>
> [Learn how to disable it](config_file.html#checks) via `.credo.exs`.



This check has a base priority of `high` and works with any version of Elixir.

## Explanation

Long `quote` blocks are generally an indication that too much is done inside
them.

Let's look at why this is problematic:

    defmodule MetaCommand do
      def __using__(opts \\ []) do
        modes = opts[:modes]
        command_name = opts[:command_name]

        quote do
          def run(filename) do
            contents =
              if File.exists?(filename) do
                {:ok, file} = File.open(filename, unquote(modes))
                {:ok, contents} = IO.read(file, :line)
                File.close(file)
                contents
              else
                ""
              end

            case contents do
              "" ->
                # ...
              unquote(command_name) <> rest ->
                # ...
            end
          end

          # ...
        end
      end
    end

A cleaner solution would be to call "regular" functions outside the
`quote` block to perform the actual work.

    defmodule MyMetaCommand do
      def __using__(opts \\ []) do
        modes = opts[:modes]
        command_name = opts[:command_name]

        quote do
          def run(filename) do
            MyMetaCommand.run_on_file(filename, unquote(modes), unquote(command_name))
          end

          # ...
        end
      end

      def run_on_file(filename, modes, command_name) do
        contents =
          # actual implementation
      end
    end

This way it is easier to reason about what is actually happening. And to debug
it.


## Check-Specific Parameters

Use the following parameters to configure this check:

### `:max_line_count`

  The maximum number of lines a quote block should be allowed to have.

*This parameter defaults to* `150`.

### `:ignore_comments`

  Ignores comments when counting the lines of a `quote` block.

*This parameter defaults to* `false`.





## General Parameters

Like with all checks, [general params](check_params.html) can be applied.

Parameters can be configured via the [`.credo.exs` config file](config_file.html).