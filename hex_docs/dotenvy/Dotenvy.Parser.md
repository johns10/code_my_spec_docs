# Dotenvy.Parser

This module handles the parsing of the contents of `.env` files into maps with
string keys. See [Dotenv File Format](docs/dotenv-file-format.md) for details
on the supported file format.

This implementation uses parsing over regular expressions for most of its work.

## parse(contents, vars \\ %{}, opts \\ [])

Parse the given `contents`, substituting and merging with the given `vars`.

## Examples

If you wish to disable or limit support for executing system commands (i.e. those inside `$()`),
you can provide a custom `:sys_cmd_fn` option. For example, to disable the feature altogether:

    iex> Dotenvy.Parser.parse(contents, %{}, sys_cmd_fn: fn _cmd, _args, _opts -> {"", 0} end)

If you wish to limit the available commands, you can customize your function, e.g.

    iex> Dotenvy.Parser.parse(contents, %{}, sys_cmd_fn: fn
      "op", args, opts -> System.cmd("op", args, opts)
      _cmd, _args, _opts -> raise "Command not allowed"
    end)

## Options

- `:sys_cmd_fn` an arity 3 function returning a tuple matching the spec for
  the [System.cmd/3](https://hexdocs.pm/elixir/System.html#cmd/3) function: the
  first element is the raw output and the second represents the exit status (0
  on success). Default: `System.cmd/3`
- `:sys_cmd_opts` keyword list of options passed as the 3rd arg to the `:sys_cmd_fn`.