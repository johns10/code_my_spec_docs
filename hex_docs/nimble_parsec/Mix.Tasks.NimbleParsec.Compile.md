# Mix.Tasks.NimbleParsec.Compile

Compiles a parser from a template.

    $ mix nimble_parsec.compile template.ex.exs

This task is useful to generate parsers that have no runtime dependency
on NimbleParsec.

## Examples

Let's define a template file:

    # lib/my_parser.ex.exs
    defmodule MyParser do
      @moduledoc false

      # parsec:MyParser
      import NimbleParsec

      date =
        integer(4)
        |> ignore(string("-"))
        |> integer(2)
        |> ignore(string("-"))
        |> integer(2)

      time =
        integer(2)
        |> ignore(string(":"))
        |> integer(2)
        |> ignore(string(":"))
        |> integer(2)
        |> optional(string("Z"))

      defparsec :datetime, date |> ignore(string("T")) |> concat(time)

      # parsec:MyParser
    end

After running:

    $ mix nimble_parsec.compile lib/my_parser.ex.exs

The following file will be generated:

    # lib/my_parser.ex
    defmodule MyParser do
      @moduledoc false

      def datetime(binary, opts \\ []) do
        ...
      end

      defp datetime__0(...) do
        ...
      end

      ...
    end

The file will be automatically formatted if using Elixir v1.6+.

## Options

  * `-o` - configures the output location. Defaults to the input
    file without its last extension