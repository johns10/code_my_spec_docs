# MDEx.Sigil



## sigil_MD/2

The `~MD` sigil converts a Markdown string or a `%MDEx.Document{}` struct to either one of these formats: `MDEx.Document`, Markdown (CommonMark), HTML, [HEEx](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.Rendered.html) JSON or XML.

## Assigns

You can define a variable `assigns` in the context of the sigil to evaluate expressions:

    iex> assigns = %{lang: ":elixir"}
    iex> ~MD|`lang = <%= @lang %>`|HTML
    "<p><code>lang = :elixir</code></p>"

    iex> assigns = %{lang: ":elixir"}
    iex> ~MD|`lang = <%= @lang %>`|MD
    "`lang = :elixir`"

Note that only the `HTML` and `MD` modifiers support assigns.

## Examples

### Markdown to `MDEx.Document`

```elixir
iex> ~MD[`lang = :elixir`]
%MDEx.Document{nodes: [%MDEx.Paragraph{nodes: [%MDEx.Code{num_backticks: 1, literal: "lang = :elixir"}]}]}
```

### Markdown to HTML

```elixir
iex> ~MD[`lang = :elixir`]HTML
"<p><code>lang = :elixir</code></p>\n"
```

### Markdown to JSON

```elixir
iex> ~MD[`lang = :elixir`]JSON
"{"nodes":[{"nodes":[{"literal":"lang = :elixir","num_backticks":1,"node_type":"MDEx.Code"}],"node_type":"MDEx.Paragraph"}],"node_type":"MDEx.Document"}"
```

### Markdown to XML

```elixir
iex> ~MD[`lang = :elixir`]XML
"<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE document SYSTEM "CommonMark.dtd">
<document xmlns="http://commonmark.org/xml/1.0">
  <paragraph>
    <code xml:space="preserve">lang = :elixir</code>
  </paragraph>
</document>
"
```

### `MDEx.Document` to Markdown

```elixir
iex> ~MD|%MDEx.Document{nodes: [%MDEx.Paragraph{nodes: [%MDEx.Code{num_backticks: 1, literal: "lang = :elixir"}]}]}|MD
"`lang = :elixir`"
```

### Markdown to Quill Delta

```elixir
iex> ~MD|`lang = :elixir`|DELTA
[%{"insert" => "lang = :elixir", "attributes" => %{"code" => true}}, %{"insert" => "\n"}]
```

### Elixir Expressions

```elixir
iex> ~MD[## Section <%= 1 + 1 %>]HTML
"<h2>Section 2</h2>"
```