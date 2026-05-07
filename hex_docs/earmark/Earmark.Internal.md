# Earmark.Internal

All public functions that are internal to Earmark, so that **only** external API
functions are public in `Earmark`

## as_ast!(markdown, options \\ [])

A wrapper to extract the AST from a call to `Earmark.Parser.as_ast` if a tuple `{:ok, result, []}` is returned,
raise errors otherwise

    iex(1)> as_ast!(["Hello %% annotated"], annotations: "%%")
    [{"p", [], ["Hello "], %{annotation: "%% annotated"}}]

    iex(2)> as_ast!("===")
    ** (Earmark.Error) [{:warning, 1, "Unexpected line ==="}]

## from_file!(filename, options \\ [])

This is a convenience method to read a file or pass it to `EEx.eval_file` if its name
ends in  `.eex`

The returned string is then passed to `as_html` this is used in the escript now and allows
for a simple inclusion mechanism, as a matter of fact an `include` function is passed

## include(filename, options \\ [])

A utility function that will be passed as a partial capture to `EEx.eval_file` by
providing a value for the `options` parameter

```elixir
    EEx.eval(..., include: &include(&1, options))
```

thusly allowing

```eex
  <%= include.(some file) %>
```

where `some file`  can be a relative path starting with `"./"`

Here is an example using [these fixtures](https://github.com/pragdave/earmark/tree/master/test/fixtures)

    iex(3)> include("./include/basic.md.eex", file: "test/fixtures/does_not_matter")
    "# Headline Level 1\n"

And here is how it is used inside a template

    iex(4)> options = [file: "test/fixtures/does_not_matter"]
    ...(4)> EEx.eval_string(~s{<%= include.("./include/basic.md.eex") %>}, include: &include(&1, options))
    "# Headline Level 1\n"