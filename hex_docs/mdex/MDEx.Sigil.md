# MDEx.Sigil

Sigils for parsing and formatting Markdown between different formats.

## Examples

With no modifier, `~MD` defaults to converting a Markdown string into a `MDEx.Document` struct:

    iex> import MDEx.Sigil
    iex> ~MD|# Hello from `~MD` sigil|
    %MDEx.Document{
      nodes: [
        %MDEx.Heading{
          nodes: [
            %MDEx.Text{literal: "Hello from "},
            %MDEx.Code{num_backticks: 1, literal: "~MD"},
            %MDEx.Text{literal: " sigil"}
          ],
          level: 1,
          setext: false
        }
      ]
    }

You can also convert Markdown to HTML, JSON or XML:

    iex> import MDEx.Sigil
    iex> ~MD|`~MD` also converts to HTML format|HTML
    "<p><code>~MD</code> also converts to HTML format</p>"

    iex> import MDEx.Sigil
    iex> ~MD|and to XML as well|XML
    "<?xml version="1.0" encoding="UTF-8"?>\n<!DOCTYPE document SYSTEM "CommonMark.dtd">\n<document xmlns="http://commonmark.org/xml/1.0">\n  <paragraph>\n    <text xml:space="preserve">and to XML as well</text>\n  </paragraph>\n</document>"

Assigns in the context can be referenced in the Markdown content using `<%= ... %>` syntax, which is evaluated at runtime. `~MD`
accepts an `assigns` map to pass variables to the document when rendering HTML or Markdown:

    iex> import MDEx.Sigil
    iex> assigns = %{lang: "Elixir"}
    iex> ~MD|Running <%= @lang %>|HTML
    "<p>Running Elixir</p>"

    iex> import MDEx.Sigil
    iex> assigns = %{lang: "Elixir"}
    iex> ~MD|Running <%= @lang %>|MD
    "Running Elixir"

The `HEEX` modifier can render component and Elixir expressions:

    iex> import MDEx.Sigil
    iex> assigns = %{lang: "Elixir"}
    iex> rendered = ~MD|Learn <Phoenix.Component.link href="https://elixir-lang.org">{@lang}</Phoenix.Component.link>|HEEX
    %Phoenix.LiveView.Rendered{...}
    iex> rendered |> Phoenix.HTML.Safe.to_iodata() |> IO.iodata_to_binary()
    "<p>Learn <a href="https://elixir-lang.org">Elixir</a></p>"

## Modifiers

  * `HTML` - converts Markdown or `MDEx.Document` to HTML

      Use [EEx.SmartEngine](https://hexdocs.pm/eex/EEx.SmartEngine.html) to convert the document into HTML. It does support `assigns` but only the old `<%= ... %>` syntax,
      and it doesn't support components. It's useful if you want to generate static HTML from Markdown or don't need components or don't want to define an `assigns` variable (it's optional).

      Prefer using the `HEEX` modifier if you need full Phoenix LiveView support with components and expressions.

  * `HEEX` - converts Markdown to [Phoenix HEEx](https://hexdocs.pm/phoenix_live_view/Phoenix.LiveView.Rendered.html) for LiveView templates

      Enables LiveView components, `phx-*` bindings, and Elixir expressions inside Markdown.
      Requires Phoenix LiveView and an `assigns` variable in scope.

      See [Phoenix LiveView HEEx example](https://hexdocs.pm/mdex/phoenix_live_view_heex.html) for a demo.

  * `JSON` - converts Markdown or `MDEx.Document` to JSON

  * `XML` - converts Markdown or `MDEx.Document` to XML

  * `MD` - converts `MDEx.Document` to Markdown and can interpolate assigns in Markdown strings

  * `DELTA` - converts Markdown or `MDEx.Document` to Quill Delta format

  * No modifier (default) - parses a Markdown string into a `MDEx.Document` struct

Note that you should `import MDEx.Sigil` to use the `~MD` sigil.

## HTML/EEx Format Order

In order to generate the final result, the Markdown string or `MDEx.Document` (initial input) is first converted into a static HTML without escaping
the content, then the HTML is passed to the appropriate engine to generate the final output.

## Assigns and Expressions

The `HTML` and `HEEX` modifiers evaluate assigns and expressions at runtime.
Other modifiers preserve them as literal text in the output.

> #### Expressions inside code blocks are preserved {: .warning}
> Expressions like `<%= ... %>` or `{ ... }` inside code blocks are escaped, not evaluated:
> ```elixir
> assigns = %{title: "Hello"}
> ~MD"`{@title}`"HTML
> #=> "<p><code>&lbrace;@title&rbrace;</code></p>"
> ```

## Options

All modifiers use these options by default:

```elixir
[
  codefence_renderers: %{},
  plugins: [],
  assigns: %{},
  streaming: false,
  sanitize: nil,
  syntax_highlight: [
    formatter: {:html_inline,
     [
       header: nil,
       highlight_lines: nil,
       include_highlights: false,
       italic: false,
       pre_class: nil,
       theme: "onedark"
     ]}
  ],
  extension: [
    cjk_friendly_emphasis: false,
    link_url_rewriter: nil,
    image_url_rewriter: nil,
    insert: false,
    highlight: false,
    subtext: false,
    greentext: false,
    subscript: false,
    wikilinks_title_before_pipe: false,
    wikilinks_title_after_pipe: false,
    front_matter_delimiter: nil,
    inline_footnotes: false,
    header_ids: nil,
    tagfilter: false,
    strikethrough: true,
    table: true,
    autolink: false,
    tasklist: true,
    superscript: true,
    footnotes: true,
    description_lists: true,
    multiline_block_quotes: true,
    alerts: true,
    math_dollars: true,
    math_code: true,
    shortcodes: true,
    underline: true,
    spoiler: true,
    phoenix_heex: true
  ],
  parse: [
    escaped_char_spans: false,
    leave_footnote_definitions: false,
    tasklist_in_table: false,
    ignore_setext: false,
    default_info_string: nil,
    smart: false,
    relaxed_tasklist_matching: true,
    relaxed_autolinks: true
  ],
  render: [
    experimental_minimize_commonmark: false,
    ol_width: 1,
    tasklist_classes: false,
    figure_with_caption: false,
    prefer_fenced: false,
    gfm_quirks: false,
    ignore_empty_links: false,
    escaped_char_spans: false,
    sourcepos: false,
    list_style: :dash,
    width: 0,
    hardbreaks: false,
    unsafe: true,
    escape: false,
    github_pre_lang: true,
    full_info_string: true
  ]
]
```

If you need a different set of options, you can either pass options to [use MDEx](https://hexdocs.pm/mdex/MDEx.html#__using__/1) or call the regular functions in `MDEx`.

## sigil_MD(arg, modifiers)

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