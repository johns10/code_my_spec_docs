# Earmark.Parser



## as_ast/2

iex(42)> markdown = "My `code` is **best**"
    ...(42)> {:ok, ast, []} = Earmark.Parser.as_ast(markdown)
    ...(42)> ast
    [{"p", [], ["My ", {"code", [{"class", "inline"}], ["code"], %{}}, " is ", {"strong", [], ["best"], %{}}], %{}}]



    iex(43)> markdown = "```elixir\nIO.puts 42\n```"
    ...(43)> {:ok, ast, []} = Earmark.Parser.as_ast(markdown, code_class_prefix: "lang-")
    ...(43)> ast
    [{"pre", [], [{"code", [{"class", "elixir lang-elixir"}], ["IO.puts 42"], %{}}], %{}}]

**Rationale**:

The AST is exposed in the spirit of [Floki's](https://hex.pm/packages/floki).

## version/0

Accesses current hex version of the `Earmark.Parser` application. Convenience for
  `iex` usage.