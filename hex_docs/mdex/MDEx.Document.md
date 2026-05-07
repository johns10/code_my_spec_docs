# MDEx.Document

Document is the core structure to store, manipulate, and render Markdown documents.

## Tree

```elixir
%MDEx.Document{
  nodes: [
    %MDEx.Paragraph{
      nodes: [
        %MDEx.Code{num_backticks: 1, literal: "Elixir"}
      ]
    }
  ]
}
```

Each node may contain attributes and children nodes as in the example above where `MDEx.Document`
contains a `MDEx.Paragraph` node which contains a `MDEx.Code` node with the attributes `:num_backticks` and `:literal`.

You can check out each node's documentation in the `Document Nodes` section, for example `MDEx.HtmlBlock`.

The `MDEx.Document` module represents the root of a document and implements several behaviours and protocols
to enable operations to fetch, update, and manipulate the document tree.

In these examples we will be using the [~MD](https://hexdocs.pm/mdex/MDEx.Sigil.html#sigil_MD/2) sigil.

### Tree Traversal

**Understanding tree traversal is fundamental to working with MDEx documents**, as it affects how all 
`Enum` functions, `Access` operations, and other protocols behave.

The document tree is enumerated using **depth-first pre-order traversal**. This means:

1. The parent node is visited first
2. Then each child node is visited recursively
3. Children are processed in the order they appear in the `:nodes` list

This traversal order affects all `Enum` functions, including `Enum.at/2`, `Enum.map/2`, `Enum.find/2`, and friends.

```elixir
iex> doc = ~MD[# Hello]
iex> Enum.at(doc, 0)
%MDEx.Document{nodes: [%MDEx.Heading{nodes: [%MDEx.Text{literal: "Hello"}], level: 1, setext: false}]}
iex> Enum.at(doc, 1)
%MDEx.Heading{nodes: [%MDEx.Text{literal: "Hello"}], level: 1, setext: false}
iex> Enum.at(doc, 2)
%MDEx.Text{literal: "Hello"}
```

More complex traversal with nested elements:

```elixir
iex> doc = ~MD[**bold** text]
iex> Enum.at(doc, 0)
%MDEx.Document{nodes: [%MDEx.Paragraph{nodes: [%MDEx.Strong{nodes: [%MDEx.Text{literal: "bold"}]}, %MDEx.Text{literal: " text"}]}]}
iex> Enum.at(doc, 1)
%MDEx.Paragraph{nodes: [%MDEx.Strong{nodes: [%MDEx.Text{literal: "bold"}]}, %MDEx.Text{literal: " text"}]}
iex> Enum.at(doc, 2)
%MDEx.Strong{nodes: [%MDEx.Text{literal: "bold"}]}
iex> Enum.at(doc, 3)
%MDEx.Text{literal: "bold"}
iex> Enum.at(doc, 4)
%MDEx.Text{literal: " text"}
```

### Traverse and Update

You can also use the low-level `MDEx.traverse_and_update/2` and `MDEx.traverse_and_update/3` APIs
to traverse each node of the AST and either update the nodes or do some calculation with an accumulator.

## Streaming

Pass `streaming: true` to buffer Markdown fragments and get valid output at every render,
even when chunks arrive with unclosed syntax. Useful for rendering LLM responses as they stream in.

    iex> doc = MDEx.new(streaming: true) |> MDEx.Document.put_markdown("**Fol")
    iex> MDEx.to_html!(doc)
    "<p><strong>Fol</strong></p>"
    iex> doc |> MDEx.Document.put_markdown("low**") |> MDEx.to_html!()
    "<p><strong>Follow</strong></p>"

See the [Streaming guide](streaming.html) for details on LiveView integration, fragment completion, and a full demo.

## Protocols

### Enumerable

The `Enumerable` protocol allows us to call `Enum` functions to iterate over and manipulate the document tree.
All enumeration follows the depth-first traversal order described above.

Count the nodes in a document:

```elixir
iex> doc = ~MD"""
...> # Languages
...>
...> `elixir`
...>
...> `rust`
...> """
iex> Enum.count(doc)
7
```

Count how many nodes have the `:literal` attribute:

```elixir
iex> doc = ~MD"""
...> # Languages
...>
...> `elixir`
...>
...> `rust`
...> """
iex> Enum.reduce(doc, 0, fn
...>   %{literal: _literal}, acc -> acc + 1
...>
...>   _node, acc -> acc
...> end)
3
```

Check if a node is member of the document:

```elixir
iex> doc = ~MD"""
...> # Languages
...>
...> `elixir`
...>
...> `rust`
...> """
iex> Enum.member?(doc, %MDEx.Code{literal: "elixir", num_backticks: 1})
true
```

Map each node to its module name:

```elixir
iex> doc = ~MD"""
...> # Languages
...>
...> `elixir`
...>
...> `rust`
...> """
iex> Enum.map(doc, fn %node{} -> inspect(node) end)
["MDEx.Document", "MDEx.Heading", "MDEx.Text", "MDEx.Paragraph", "MDEx.Code", "MDEx.Paragraph", "MDEx.Code"]
```

### Collectable

The `Collectable` protocol allows you to build documents by collecting nodes or merging multiple documents together.
This is particularly useful for programmatically constructing documents from various sources.

Merge two documents together using `Enum.into/2`:

```elixir
iex> first_doc = ~MD[# First Document]
iex> second_doc = ~MD[# Second Document]
iex> Enum.into(second_doc, first_doc)
%MDEx.Document{
  nodes: [
    %MDEx.Heading{nodes: [%MDEx.Text{literal: "First Document"}], level: 1, setext: false},
    %MDEx.Heading{nodes: [%MDEx.Text{literal: "Second Document"}], level: 1, setext: false}
  ]
}
```

Collect individual nodes into a document:

```elixir
iex> chunks = [
...>   %MDEx.Text{literal: "Hello "},
...>   %MDEx.Code{literal: "world", num_backticks: 1}
...> ]
iex> document = Enum.into(chunks, %MDEx.Document{})
%MDEx.Document{
  nodes: [
    %MDEx.Text{literal: "Hello "},
    %MDEx.Code{literal: "world", num_backticks: 1}
  ]
}
iex> MDEx.to_html!(document)
"Hello <code>world</code>"
```

Build a document incrementally by collecting mixed content:

```elixir
iex> chunks = [
...>   %MDEx.Heading{nodes: [%MDEx.Text{literal: "Title"}], level: 1, setext: false},
...>   %MDEx.Paragraph{nodes: []},
...>   %MDEx.Text{literal: "Some text"},
...>   %MDEx.ListItem{nodes: [%MDEx.Text{literal: "Item 1"}]},
...>   %MDEx.Text{literal: " - WIP"},
...> ]
iex> document = Enum.into(chunks, %MDEx.Document{})
%MDEx.Document{
  nodes: [
    %MDEx.Heading{
      level: 1,
      nodes: [%MDEx.Text{literal: "Title"}],
      setext: false
    },
    %MDEx.Paragraph{
      nodes: [%MDEx.Text{literal: "Some text"}]
    },
    %MDEx.List{
      bullet_char: "-",
      delimiter: :period,
      is_task_list: false,
      list_type: :bullet,
      marker_offset: 0,
      nodes: [%MDEx.ListItem{nodes: [%MDEx.Text{literal: "Item 1 - WIP"}], list_type: :bullet, marker_offset: 0, padding: 2, start: 1, delimiter: :period, bullet_char: "-", tight: true, is_task_list: false}],
      padding: 2,
      start: 1,
      tight: true
    }
  ]
}
iex> MDEx.to_html!(document)
"<h1>Title</h1>\n<p>Some text</p>\n<ul>\n<li>Item 1 - WIP</li>\n</ul>"
```

### Access

The `Access` behaviour gives you the ability to fetch and update nodes using different types of keys.
Access operations also follow the depth-first traversal order when searching through nodes.

#### Access by Index

You can access nodes by their position in the depth-first traversal using integer indices:

```elixir
iex> doc = ~MD[# Hello]
iex> doc[0]
%MDEx.Document{nodes: [%MDEx.Heading{nodes: [%MDEx.Text{literal: "Hello"}], level: 1, setext: false}]}
iex> doc[1]
%MDEx.Heading{nodes: [%MDEx.Text{literal: "Hello"}], level: 1, setext: false}
iex> doc[2]
%MDEx.Text{literal: "Hello"}
```

Negative indices access nodes from the end:

```elixir
iex> doc = ~MD[# Hello **world**]
iex> doc[-1]  # Last node
%MDEx.Text{literal: "world"}
```

#### Access by Node Type

Starting with a simple Markdown document, let's fetch only the text node by matching the `MDEx.Text` node:

```elixir
iex> ~MD[# Hello][%MDEx.Text{literal: "Hello"}]
[%MDEx.Text{literal: "Hello"}]
```

That's essentially the same as:

```elixir
doc = %MDEx.Document{nodes: [%MDEx.Heading{nodes: [%MDEx.Text{literal: "Hello"}], level: 1, setext: false}]},

Enum.filter(
  doc,
  fn node -> node == %MDEx.Text{literal: "Hello"} end
)
```

The key can also be modules, atoms, and even functions! For example:

Fetch all Code nodes, either by `MDEx.Code` module or the `:code` atom representing the Code node:

```elixir
iex> doc = ~MD"""
...> # Languages
...>
...> `elixir`
...>
...> `rust`
...> """
iex> doc[MDEx.Code]
[%MDEx.Code{num_backticks: 1, literal: "elixir"}, %MDEx.Code{num_backticks: 1, literal: "rust"}]
iex> doc[:code]
[%MDEx.Code{num_backticks: 1, literal: "elixir"}, %MDEx.Code{num_backticks: 1, literal: "rust"}]
```

Dynamically fetch Code nodes where the `:literal` (node content) starts with `"eli"` using a function to filter the result:

```elixir
iex> doc = ~MD"""
...> # Languages
...>
...> `elixir`
...>
...> `rust`
...> """
iex> doc[fn node -> String.starts_with?(Map.get(node, :literal, ""), "eli") end]
[%MDEx.Code{num_backticks: 1, literal: "elixir"}]
```

That's the most flexible option, in case struct, modules, or atoms are not enough to match the node you want.

The Access protocol also allows us to update nodes that match a selector.
In the example below we'll capitalize the content of all `MDEx.Code` nodes:

```elixir
iex> doc = ~MD"""
...> # Languages
...>
...> `elixir`
...>
...> `rust`
...>
...> Continue...
...> """
iex> update_in(doc, [:document, Access.key!(:nodes), Access.all(), :code, Access.key!(:literal)], fn literal ->
...>   String.upcase(literal)
...> end)
%MDEx.Document{
  nodes: [
    %MDEx.Heading{nodes: [%MDEx.Text{literal: "Languages"}], level: 1, setext: false},
    %MDEx.Paragraph{nodes: [%MDEx.Code{num_backticks: 1, literal: "ELIXIR"}]},
    %MDEx.Paragraph{nodes: [%MDEx.Code{num_backticks: 1, literal: "RUST"}]},
    %MDEx.Paragraph{nodes: [%MDEx.Text{literal: "Continue..."}]}
  ]
}
```

### String.Chars

Calling `Kernel.to_string/1` will format it as CommonMark text:

```elixir
iex> to_string(~MD[# Hello])
"# Hello"
```

Fragments (nodes without the parent `%Document{}`) are also formatted:

```elixir
iex> to_string(%MDEx.Heading{nodes: [%MDEx.Text{literal: "Hello"}], level: 1})
"# Hello"
```

### Inspect

The `Inspect` protocol provides two display formats for documents:

**Tree format (default)**: Shows the document structure as a visual tree, making it easy to understand the hierarchy and relationships between nodes.

```elixir
iex> ~MD[# Hello :smile:]
#MDEx.Document(3 nodes)<
└── 1 [heading] level: 1, setext: false
    ├── 2 [text] literal: "Hello "
    └── 3 [short_code] code: "smile", emoji: "😄"
>
```

**Struct format**: Shows the raw struct representation, useful for debugging and testing. To enable this format:

```elixir
iex> Application.put_env(:mdex, :inspect_format, :struct)
iex> ~MD[# Hello :smile:]
%MDEx.Document{
  nodes: [
    %MDEx.Heading{
      nodes: [%MDEx.Text{literal: "Hello "}, %MDEx.ShortCode{code: "smile", emoji: "😄"}],
      level: 1,
      setext: false
    }
  ],
  # ... other fields
}
```

The struct format is particularly useful in tests where you need to see exact differences between expected and actual values. You can set this in your `test/test_helper.exs`:

```elixir
Application.put_env(:mdex, :inspect_format, :struct)
```

## Pipeline and Plugins

MDEx.Document is a Req-like API to transform Markdown documents through a series of steps in a pipeline.

Its main use case is to enable plugins. There are two ways to use plugins:

### Using the `:plugins` Option

For quick one-off conversions, pass plugins directly to any `MDEx.to_*` function:

    markdown = """
    # Project Diagram

    ```mermaid
    graph TD
        A[Enter Chart Definition] --> B(Preview)
        B --> C{decide}
        C --> D[Keep]
    ```
    """

    # Simple plugin without options
    MDEx.to_html!(markdown, plugins: [MDExMermaid])

    # Plugin with options
    MDEx.to_html!(markdown, plugins: [{MDExMermaid, mermaid_version: "11"}])

    # Multiple plugins with other options
    MDEx.to_html!(markdown,
      extension: [table: true],
      plugins: [MDExGFM, {MDExMermaid, mermaid_version: "11"}]
    )

You can also use `MDEx.Document.put_plugins/2` to attach plugins to a document:

    MDEx.new(markdown: markdown)
    |> MDEx.Document.put_plugins([MDExMermaid])
    |> MDEx.to_html!()

### Using Plugin.attach

For more control or when building pipelines, use the pipeline `attach` pattern:

    MDEx.new(markdown: markdown)
    |> MDExMermaid.attach(mermaid_version: "11")
    |> MDEx.to_html!()

To understand how it works, let's write that Mermaid plugin.

### Writing Plugins

Let's start with a simple plugin as example to render Mermaid diagrams.

In order to render Mermaid diagrams, we need to inject a `<script>` into the document,
as outlined in their [docs](https://mermaid.js.org/intro/#installation):

    <script type="module">
      import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@11/dist/mermaid.esm.min.mjs';
      mermaid.initialize({ startOnLoad: true });
    </script>

Note that the package version is specified in the URL, so we'll add an option
`:mermaid_version` to the plugin to let users specify the version they want to use.

By default, we'll use the latest version:

    MDEx.new() |> MDExMermaid.attach()

But users can override it:

    MDEx.new() |> MDExMermaid.attach(mermaid_version: "11")

Let's get into the actual code, with comments to explain each part:

    defmodule MDExMermaid do
      alias MDEx.Document

      @latest_version "11"

      def attach(document, options \ []) do
        document
        # register option with prefix `:mermaid_` to avoid conflicts with other plugins
        |> Document.register_options([:mermaid_version])
        #  merge all options given by users
        |> Document.put_options(options)
        # actual steps to manipulate the document
        # see respective Document functions for more info
        |> Document.append_steps(enable_unsafe: &enable_unsafe/1)
        |> Document.append_steps(inject_script: &inject_script/1)
        |> Document.append_steps(update_code_blocks: &update_code_blocks/1)
      end

      # to render raw html and <script> tags
      defp enable_unsafe(document) do
        Document.put_render_options(document, unsafe: true)
      end

      defp inject_script(document) do
        version = Document.get_option(document, :mermaid_version, @latest_version)

        script_node =
          %MDEx.HtmlBlock{
            literal: """
            <script type="module">
              import mermaid from 'https://cdn.jsdelivr.net/npm/mermaid@#{version}/dist/mermaid.esm.min.mjs';
              mermaid.initialize({ startOnLoad: true });
            </script>
            """
          }

        Document.put_node_in_document_root(document, script_node)
      end

      defp update_code_blocks(document) do
        selector = fn
          %MDEx.CodeBlock{info: "mermaid"} -> true
          _ -> false
        end

        Document.update_nodes(
          document,
          selector,
          &%MDEx.HtmlBlock{literal: "<pre class="mermaid">#{&1.literal}</pre>", nodes: &1.nodes}
        )
      end
    end

Now we can `attach/1` that plugin into any MDEx document to render Mermaid diagrams.

## Practical Examples

Here are some common patterns for working with MDEx documents that combine the protocols described above.

### Update all code block nodes filtered by the `selector` function

_Add line "// Modified" in Rust block codes_:

```elixir
iex> doc = ~MD"""
...> # Code Examples
...>
...> ```elixir
...> def hello do
...>   :world
...> end
...> ```
...>
...> ```rust
...> fn main() {
...>   println!("Hello");
...> }
...> ```
...> """
iex> selector = fn
...>   %MDEx.CodeBlock{info: "rust"} -> true
...>   _ -> false
...> end
iex> update_in(doc, [:document, Access.key!(:nodes), Access.all(), selector], fn node ->
...>   %{node | literal: "// Modified\n" <> node.literal}
...> end)
%MDEx.Document{
  nodes: [
    %MDEx.Heading{
      nodes: [%MDEx.Text{literal: "Code Examples"}],
      level: 1,
      setext: false
    },
    %MDEx.CodeBlock{
      info: "elixir",
      literal: "def hello do\n  :world\nend\n"
    },
    %MDEx.CodeBlock{
      info: "rust",
      literal: "// Modified\nfn main() {\n  println!(\"Hello\");\n}\n"
    }
  ]
}
```

### Collect headings by level

```elixir
iex> doc = ~MD"""
...> # Main Title
...>
...> ## Section 1
...>
...> ### Subsection
...>
...> ## Section 2
...> """
iex> Enum.reduce(doc, %{}, fn
...>   %MDEx.Heading{level: level, nodes: [%MDEx.Text{literal: text}]}, acc ->
...>     Map.update(acc, level, [text], &[text | &1])
...>   _node, acc -> acc
...> end)
%{
  1 => ["Main Title"],
  2 => ["Section 2", "Section 1"],
  3 => ["Subsection"]
}
```

### Extract and transform task list items

```elixir
iex> doc = ~MD"""
...> # Todo List
...>
...> - [ ] Buy groceries
...> - [x] Call mom
...> - [ ] Read book
...> """
iex> Enum.map(doc, fn
...>   %MDEx.TaskItem{checked: checked, nodes: [%MDEx.Paragraph{nodes: [%MDEx.Text{literal: text}]}]} ->
...>     {checked, text}
...>   _ -> nil
...> end)
...> |> Enum.reject(&is_nil/1)
[
  {false, "Buy groceries"},
  {true, "Call mom"},
  {false, "Read book"}
]
```

### Bump all heading levels, except level 6

```elixir
iex> doc = ~MD"""
...> # Main Title
...>
...> ## Subtitle
...>
...> ###### Notes
...> """
iex> selector = fn
...>   %MDEx.Heading{level: level} when level < 6 -> true
...>   _ -> false
...> end
iex> update_in(doc, [:document, Access.key!(:nodes), Access.all(), selector], fn node ->
...>   %{node | level: node.level + 1}
...> end)
%MDEx.Document{
  nodes: [
    %MDEx.Heading{nodes: [%MDEx.Text{literal: "Main Title"}], level: 2, setext: false},
    %MDEx.Heading{nodes: [%MDEx.Text{literal: "Subtitle"}], level: 3, setext: false},
    %MDEx.Heading{nodes: [%MDEx.Text{literal: "Notes"}], level: 6, setext: false}
  ]
}
```

## append_steps(document, steps)

Appends steps to the end of the existing document's step list.

## Examples

    iex> document = MDEx.new()
    iex> document = MDEx.Document.append_steps(
    ...>   document,
    ...>   enable_tables: fn doc -> MDEx.Document.put_extension_options(doc, table: true) end
    ...> )
    iex> document
    ...> |> MDEx.Document.run()
    ...> |> MDEx.Document.get_option(:extension)
    ...> |> Keyword.get(:table)
    true

## assign(document, keyword_or_map)

Adds key-value pairs to the document assigns.

## Examples

    iex> document = MDEx.Document.assign(MDEx.new(), title: "Hello", author: "Jane")
    iex> MDEx.Document.get_option(document, :assigns)
    %{title: "Hello", author: "Jane"}

    iex> document = MDEx.Document.assign(MDEx.new(), %{title: "Hello"})
    iex> MDEx.Document.get_option(document, :assigns)
    %{title: "Hello"}

## assign(document, key, value)

Adds a key-value pair to the document assigns.

## Examples

    iex> document = MDEx.Document.assign(MDEx.new(), :title, "Hello")
    iex> MDEx.Document.get_option(document, :assigns)
    %{title: "Hello"}

## default_extension_options()

Returns the default `:extension` options.

```elixir
[
  phoenix_heex: false,
  cjk_friendly_emphasis: false,
  link_url_rewriter: nil,
  image_url_rewriter: nil,
  insert: false,
  highlight: false,
  subtext: false,
  greentext: false,
  spoiler: false,
  subscript: false,
  underline: false,
  wikilinks_title_before_pipe: false,
  wikilinks_title_after_pipe: false,
  shortcodes: false,
  math_code: false,
  math_dollars: false,
  alerts: false,
  multiline_block_quotes: false,
  front_matter_delimiter: nil,
  description_lists: false,
  inline_footnotes: false,
  footnotes: false,
  header_ids: nil,
  superscript: false,
  tasklist: false,
  autolink: false,
  table: false,
  tagfilter: false,
  strikethrough: false
]
```

## default_options()

Returns all default options.

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
    escape: false,
    unsafe: false,
    width: 0,
    full_info_string: false,
    github_pre_lang: false,
    hardbreaks: false
  ],
  parse: [
    escaped_char_spans: false,
    leave_footnote_definitions: false,
    tasklist_in_table: false,
    ignore_setext: false,
    relaxed_autolinks: true,
    relaxed_tasklist_matching: false,
    default_info_string: nil,
    smart: false
  ],
  extension: [
    phoenix_heex: false,
    cjk_friendly_emphasis: false,
    link_url_rewriter: nil,
    image_url_rewriter: nil,
    insert: false,
    highlight: false,
    subtext: false,
    greentext: false,
    spoiler: false,
    subscript: false,
    underline: false,
    wikilinks_title_before_pipe: false,
    wikilinks_title_after_pipe: false,
    shortcodes: false,
    math_code: false,
    math_dollars: false,
    alerts: false,
    multiline_block_quotes: false,
    front_matter_delimiter: nil,
    description_lists: false,
    inline_footnotes: false,
    footnotes: false,
    header_ids: nil,
    superscript: false,
    tasklist: false,
    autolink: false,
    table: false,
    tagfilter: false,
    strikethrough: false
  ]
]
```

## default_parse_options()

Returns the default `:parse` options.

```elixir
[
  escaped_char_spans: false,
  leave_footnote_definitions: false,
  tasklist_in_table: false,
  ignore_setext: false,
  relaxed_autolinks: true,
  relaxed_tasklist_matching: false,
  default_info_string: nil,
  smart: false
]
```

## default_render_options()

Returns the default `:render` options.

```elixir
[
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
  escape: false,
  unsafe: false,
  width: 0,
  full_info_string: false,
  github_pre_lang: false,
  hardbreaks: false
]
```

## default_sanitize_options()

Returns the default `:sanitize` options.

```elixir
[
  id_prefix: nil,
  strip_comments: true,
  rm_allowed_classes: %{},
  add_allowed_classes: %{},
  allowed_classes: %{},
  link_rel: "noopener noreferrer",
  url_relative: :passthrough,
  rm_url_schemes: [],
  add_url_schemes: [],
  url_schemes: ["bitcoin", "ftp", "ftps", "geo", "http", "https", "im", "irc",
   "ircs", "magnet", "mailto", "mms", "mx", "news", "nntp", "openpgp4fpr",
   "sip", "sms", "smsto", "ssh", "tel", "url", "webcal", "wtai", "xmpp"],
  rm_generic_attributes: [],
  add_generic_attributes: [],
  generic_attributes: ["lang", "title"],
  rm_generic_attribute_prefixes: [],
  add_generic_attribute_prefixes: [],
  generic_attribute_prefixes: [],
  rm_set_tag_attribute_value: %{},
  set_tag_attribute_value: %{},
  set_tag_attribute_values: %{},
  rm_tag_attribute_values: %{},
  add_tag_attribute_values: %{},
  tag_attribute_values: %{},
  rm_tag_attributes: %{},
  add_tag_attributes: %{},
  tag_attributes: %{
    "a" => ["href", "hreflang"],
    "bdo" => ["dir"],
    "blockquote" => ["cite"],
    "code" => ["class", "translate", "tabindex"],
    "col" => ["align", "char", "charoff", "span"],
    "colgroup" => ["align", "char", "charoff", "span"],
    "del" => ["cite", "datetime"],
    "hr" => ["align", "size", "width"],
    "img" => ["align", "alt", "height", "src", "width"],
    "ins" => ["cite", "datetime"],
    "ol" => ["start"],
    "pre" => ["class", "style"],
    "q" => ["cite"],
    "span" => ["class", "style", "data-line"],
    "table" => ["align", "char", "charoff", "summary"],
    "tbody" => ["align", "char", "charoff"],
    "td" => ["align", "char", "charoff", "colspan", "headers", "rowspan"],
    "tfoot" => ["align", "char", "charoff"],
    "th" => ["align", "char", "charoff", "colspan", "headers", "rowspan",
     "scope"],
    "thead" => ["align", "char", "charoff"],
    "tr" => ["align", "char", "charoff"]
  },
  rm_clean_content_tags: [],
  add_clean_content_tags: [],
  clean_content_tags: ["script", "style"],
  rm_tags: [],
  add_tags: [],
  tags: ["a", "abbr", "acronym", "area", "article", "aside", "b", "bdi", "bdo",
   "blockquote", "br", "caption", "center", "cite", "code", "col", "colgroup",
   "data", "dd", "del", "details", "dfn", "div", "dl", "dt", "em", "figcaption",
   "figure", "footer", "h1", "h2", "h3", "h4", "h5", "h6", "header", "hgroup",
   "hr", "i", "img", "ins", "kbd", "li", "map", "mark", "nav", "ol", "p", "pre",
   "q", "rp", "rt", "rtc", "ruby", "s", "samp", "small", "span", "strike",
   "strong", "sub", "summary", "sup", "table", "tbody", "td", "th", "thead",
   "time", "tr", "tt", "u", "ul", "var", "wbr"]
]
```

## default_syntax_highlight_options()

Returns the default `:syntax_highlight` options.

```elixir
[
  formatter: {:html_inline,
   [
     header: nil,
     highlight_lines: nil,
     include_highlights: false,
     italic: false,
     pre_class: nil,
     theme: "onedark"
   ]}
]
```

## fetch(document, selector)

Callback implementation for `Access.fetch/2`.

See the [Access](#module-access) section for more info.

## get_and_update(document, selector, fun)

Callback implementation for `Access.get_and_update/3`.

See the [Access](#module-access) section for more info.

## get_option(document, key, default \\ nil)

Retrieves an option value from the document.

## Examples

    iex> document = MDEx.new(render: [escape: true])
    iex> MDEx.Document.get_option(document, :render)[:escape]
    true

## get_private(document, key, default \\ nil)

Retrieves a private value from the document.

## Examples

    iex> document = MDEx.new() |> MDEx.Document.put_private(:count, 2)
    iex> MDEx.Document.get_private(document, :count)
    2

## get_sanitize_option(document, key, default \\ nil)

Retrieves one of the `t:sanitize_options/0` options from the document.

## Examples

    iex> document =
    ...>   MDEx.new()
    ...>   |> MDEx.Document.put_sanitize_options(add_tags: ["x-component"])
    iex> MDEx.Document.get_sanitize_option(document, :add_tags)
    ["x-component"]

## halt(document)

Halts the document pipeline execution.

This function is used to stop the pipeline from processing any further steps. Once a pipeline
is halted, no more steps will be executed. This is useful for plugins that need to stop
processing when certain conditions are met or when an error occurs.

## Examples

    iex> document = MDEx.Document.halt(MDEx.new())
    iex> document.halted
    true

## halt(document, exception)

Halts the document pipeline execution with an exception.

## is_sanitize_enabled(document)

Returns `true` if the document has the `:sanitize` option set, otherwise `false`.

## pop(document, key, default \\ nil)

Callback implementation for `Access.fetch/2`.

See the [Access](#module-access) section for more info.

## prepend_steps(document, steps)

Prepends steps to the beginning of the existing document's step list.

## put_codefence_renderers(document, renderers)

Updates the document's `:codefence_renderers` option.

Codefence renderers allow to customize how code blocks are rendered based on their info string.

See [Codefence Renderers examples](https://hexdocs.pm/mdex/codefence_renderers.html) for more info.

## Example

Given a Markdown containing a code block with `chart` as info string:

    ```chart
    {"type": "bar", "width": 630, "height": 410, "title_text": "Weekly Revenue", ...
    ```

Provide a custom renderer for `chart` code blocks to customize what will be rendered in that block (the key must match the info string):

    codefence_renderers: %{
      "chart" => fn _lang, _meta, code -> SvgCharts.render!(code) end
    }

## put_extension_options(document, options)

Updates the document's `:extension` options.

## Examples

    iex> document = MDEx.Document.put_extension_options(MDEx.new(), table: true)
    iex> MDEx.Document.get_option(document, :extension)[:table]
    true

## put_markdown(document, markdown, position \\ :bottom)

Adds `markdown` chunks into the `document` buffer.

## Examples

    iex> document =
    ...>   MDEx.new(markdown: "# First\n")
    ...>   |> MDEx.Document.put_markdown("# Second")
    ...>   |> MDEx.Document.run()
    iex> document.nodes
    [
      %MDEx.Heading{nodes: [%MDEx.Text{literal: "First"}], level: 1, setext: false},
      %MDEx.Heading{nodes: [%MDEx.Text{literal: "Second"}], level: 1, setext: false}
    ]

    iex> document =
    ...>   MDEx.new(markdown: "# Last")
    ...>   |> MDEx.Document.put_markdown("# First\n", :top)
    ...>   |> MDEx.Document.run()
    iex> document.nodes
    [
      %MDEx.Heading{nodes: [%MDEx.Text{literal: "First"}], level: 1, setext: false},
      %MDEx.Heading{nodes: [%MDEx.Text{literal: "Last"}], level: 1, setext: false}
    ]

    iex> document = MDEx.new(streaming: true) |> MDEx.Document.put_markdown("`let x =")
    iex> MDEx.to_html!(document)
    "<p><code>let x =</code></p>"

## put_node_in_document_root(document, node, position \\ :top)

Inserts `node` into the document root at the specified `position`.

  - By default, the node is inserted at the top of the document.
  - Node must be a valid fragment node like a `MDEx.Heading`, `MDEx.HtmlBlock`, etc.

## Examples

    iex> document =
    ...>   MDEx.new(markdown: "# Doc")
    ...>   |> MDEx.Document.append_steps(append_node: fn document ->
    ...>     html_block = %MDEx.HtmlBlock{literal: "<p>Hello</p>"}
    ...>     MDEx.Document.put_node_in_document_root(document, html_block, :bottom)
    ...>   end)
    iex> MDEx.to_html(document, render: [unsafe: true])
    {:ok, "<h1>Doc</h1>\n<p>Hello</p>"}

## put_options(document, options)

Merges options into the document options.

This function handles both built-in options (`:extension`, `:parse`, `:render`, `:syntax_highlight`, and `:sanitize`)
and user-defined options that have been registered with `register_options/2`.

## Examples

    iex> document = MDEx.Document.register_options(MDEx.new(), [:custom_option])
    iex> document = MDEx.Document.put_options(document, [
    ...>   extension: [table: true],
    ...>   custom_option: "value"
    ...> ])
    iex> MDEx.Document.get_option(document, :extension)[:table]
    true
    iex> MDEx.Document.get_option(document, :custom_option)
    "value"

Built-in options are validated against their respective schemas:

    iex> try do
    ...>   MDEx.Document.put_options(MDEx.new(), [extension: [invalid: true]])
    ...> rescue
    ...>   NimbleOptions.ValidationError -> :error
    ...> end
    :error

## put_parse_options(document, options)

Updates the document's `:parse` options.

## Examples

    iex> document = MDEx.Document.put_parse_options(MDEx.new(), smart: true)
    iex> MDEx.Document.get_option(document, :parse)[:smart]
    true

## put_plugins(document, plugins)

Attaches plugins to the document.

Plugins can be specified as:

- A module atom (calls `Module.attach(document)`)
- A tuple `{module, options}` (calls `Module.attach(document, options)`)
- A function `(document -> document)`

## Examples

    iex> defmodule MyPlugin do
    ...>   def attach(doc, opts \\ []) do
    ...>     MDEx.Document.put_extension_options(doc, table: true)
    ...>   end
    ...> end
    iex> doc = MDEx.Document.put_plugins(MDEx.new(), [MyPlugin])
    iex> MDEx.Document.get_option(doc, :extension)[:table]
    true

    iex> attach_fn = fn doc -> MDEx.Document.put_extension_options(doc, strikethrough: true) end
    iex> doc = MDEx.Document.put_plugins(MDEx.new(), [attach_fn])
    iex> MDEx.Document.get_option(doc, :extension)[:strikethrough]
    true

Note that you can also use the pipeline `Plugin.attach(document)` style:

    MDEx.new()
    |> MyPlugin.attach(option: "value")
    |> MDEx.to_html!()

## put_private(document, key, value)

Stores a value in the document's private storage.

## Examples

    iex> document = MDEx.Document.put_private(MDEx.new(), :mermaid_version, "11")
    iex> MDEx.Document.get_private(document, :mermaid_version)
    "11"

## put_render_options(document, options)

Updates the document's `:render` options.

## Examples

    iex> document = MDEx.Document.put_render_options(MDEx.new(), escape: true)
    iex> MDEx.Document.get_option(document, :render)[:escape]
    true

## put_sanitize_options(document, options)

Updates the document's `:sanitize` options.

## Examples

    iex> document = MDEx.Document.put_sanitize_options(MDEx.new(), add_tags: ["MyComponent"])
    iex> MDEx.Document.get_option(document, :sanitize)[:add_tags]
    ["MyComponent"]

## put_syntax_highlight_options(document, options)

Updates the document's `:syntax_highlight` options.

## Examples

    iex> document = MDEx.Document.put_syntax_highlight_options(MDEx.new(), formatter: :html_linked)
    iex> MDEx.Document.get_option(document, :syntax_highlight)[:formatter]
    :html_linked

## register_options(document, options)

Registers a list of valid options that can be used by steps in the document pipeline.

## Examples

    iex> document = MDEx.new()
    iex> document = MDEx.Document.register_options(document, [:mermaid_version])
    iex> document = MDEx.Document.put_options(document, mermaid_version: "11")
    iex> document.options[:mermaid_version]
    "11"

    iex> MDEx.new(rendr: [unsafe: true])
    ** (ArgumentError) unknown option :rendr. Did you mean :render?

## run(document)

Executes the document pipeline.

This function performs some main operations:

1. Processes buffered markdown: If there are any markdown chunks in the buffer (added via `put_markdown/3` for example),
   they are parsed and added to the document. If the document already has nodes, they are combined with the buffer.

2. Completes any buffered fragments: If streaming is enabled, it completes any buffered fragments to ensure valid Markdown.

3. Executes pipeline steps: All registered steps (added via `append_steps/2` or `prepend_steps/2`) are
   executed in order. Steps can transform the document or halt the pipeline.

See `MDEx.new/1` for more info.

## Examples

Processing buffered markdown:

    iex> document =
    ...>   MDEx.new(markdown: "# First\n")
    ...>   |> MDEx.Document.put_markdown("# Second")
    ...>   |> MDEx.Document.run()
    iex> document.nodes
    [
      %MDEx.Heading{nodes: [%MDEx.Text{literal: "First"}], level: 1, setext: false},
      %MDEx.Heading{nodes: [%MDEx.Text{literal: "Second"}], level: 1, setext: false}
    ]

Executing pipeline steps:

    iex> document =
    ...>   MDEx.new()
    ...>   |> MDEx.Document.append_steps(add_heading: fn doc ->
    ...>     heading = %MDEx.Heading{nodes: [%MDEx.Text{literal: "Intro"}], level: 1, setext: false}
    ...>     MDEx.Document.put_node_in_document_root(doc, heading, :top)
    ...>   end)
    ...>   |> MDEx.Document.run()
    iex> document.nodes
    [%MDEx.Heading{nodes: [%MDEx.Text{literal: "Intro"}], level: 1, setext: false}]

Streaming:

    iex> document =
    ...>   MDEx.new(streaming: true, markdown: "```elixir\n")
    ...>   |> MDEx.Document.put_markdown("IO.inspect(:mdex)")
    ...>   |> MDEx.Document.run()
    iex> document.nodes
    [
      %MDEx.CodeBlock{
        info: "elixir",
        literal: "IO.inspect(:mdex)\n"
      }
    ]

## update_nodes(document, selector, fun)

Updates all nodes in the document that match `selector`.

## Example

    iex> markdown = """
    ...> # Hello
    ...> ## World
    ...> """
    iex> document =
    ...>   MDEx.new(markdown: markdown)
    ...>   |> MDEx.Document.run()
    ...>   |> MDEx.Document.update_nodes(MDEx.Text, fn node -> %{node | literal: String.upcase(node.literal)} end)
    iex> document.nodes
    [
      %MDEx.Heading{nodes: [%MDEx.Text{literal: "HELLO"}], level: 1, setext: false},
      %MDEx.Heading{nodes: [%MDEx.Text{literal: "WORLD"}], level: 2, setext: false}
    ]

## update_private(document, key, default, fun)

Updates a value in the document's private storage using a function.

## Examples

    iex> document = MDEx.new() |> MDEx.Document.put_private(:count, 1)
    iex> document = MDEx.Document.update_private(document, :count, 0, &(&1 + 1))
    iex> MDEx.Document.get_private(document, :count)
    2

## wrap(document)

Wraps nodes in a `MDEx.Document`.

* Passing an existing document returns it unchanged.
* Passing a node or list of nodes builds a new document with default options.

## Examples

    iex> document = MDEx.Document.wrap(MDEx.new(markdown: "# Title") |> MDEx.Document.run())
    iex> document.nodes
    [%MDEx.Heading{nodes: [%MDEx.Text{literal: "Title"}], level: 1, setext: false}]

    iex> document = MDEx.Document.wrap(%MDEx.Text{literal: "Hello"})
    iex> document.nodes
    [%MDEx.Text{literal: "Hello"}]

## t/0

Tree root of a Markdown document, including all children nodes.

## md_node/0

Fragment of a Markdown document, a single node. May contain children nodes.

## step/0

Step in a pipeline.

It's a function that receives a `t:MDEx.Document.t/0` struct and must return either one of the following:

  - a `t:MDEx.Document.t/0` struct
  - a tuple with a `t:MDEx.Document.t/0` struct and an `t:Exception.t/0` as `{document, exception}`
  - a tuple with a module, function and arguments which will be invoked with `apply/3`

## selector/0

Selector used to match nodes in the document.

Valid selectors can be the module or struct, an atom representing the node name, or a function that receives a node and returns a boolean.

See `MDEx.Document` for more info and examples.

## plugins/0

A list of plugins to attach to a document.

Each plugin may be one of:

- `t:module/0` - A module that exposes `attach/1`, where the `t:MDEx.Document.t/0` is the only parameter
- `{module, keyword}` - A module exposing `attach/2`, where the `t:MDEx.Document.t/0` is
  the first parameter, and the second parameter is a keyword option list
- `(document -> document)` - A function that accepts a `t:MDEx.Document.t/0` and returns one

## extension_options/0

List of [comrak extension options](https://docs.rs/comrak/latest/comrak/options/struct.Extension.html).

## Example

    MDEx.to_html!("~~strikethrough~~", extension: [strikethrough: true])
    #=> "<p><del>strikethrough</del></p>"

## parse_options/0

List of [comrak parse options](https://docs.rs/comrak/latest/comrak/options/struct.Parse.html).

## Example

    MDEx.to_html!(""Hello" -- world...", parse: [smart: true])
    #=> "<p>“Hello” – world…</p>"

## render_options/0

List of [comrak render options](https://docs.rs/comrak/latest/comrak/options/struct.Render.html).

## Example

    MDEx.to_html!("<script>alert('xss')</script>", render: [unsafe: true])
    #=> "<script>alert('xss')</script>"

## syntax_highlight_options/0

Syntax Highlight code blocks using [lumis](https://hexdocs.pm/lumis).

## Example

    MDEx.to_html!("""
    ...> ```elixir
    ...> {:mdex, "~> 0.1"}
    ...> ```
    ...> """, syntax_highlight: [formatter: {:html_inline, theme: "nord"}])
    #=> <pre class="lumis" style="color: #d8dee9; background-color: #2e3440;"><code class="language-elixir" translate="no" tabindex="0"><span class="line" data-line="1"><span style="color: #88c0d0;">&lbrace;</span><span style="color: #ebcb8b;">:mdex</span><span style="color: #88c0d0;">,</span> <span style="color: #a3be8c;">&quot;~&gt; 0.1&quot;</span><span style="color: #88c0d0;">&rbrace;</span>
    #=> </span></code></pre>

## sanitize_options/0

List of [ammonia options](https://docs.rs/ammonia/latest/ammonia/struct.Builder.html).

## Example

    iex> MDEx.to_html!("<h1>Title</h1><p>Content</p>", sanitize: [rm_tags: ["h1"]], render: [unsafe: true])
    "Title<p>Content</p>"

## options/0

Options to customize the parsing and rendering of Markdown documents.

## Examples

- Enable the `table` extension:

    ````elixir
    MDEx.to_html!("""
    | lang |
    |------|
    | elixir |
    """,
    extension: [table: true]
    )
    ````

- Syntax highlight using inline style and the `github_light` theme:

    ````elixir
    MDEx.to_html!("""
    ## Code Example

    ```elixir
    Atom.to_string(:elixir)
    ```
    """,
    syntax_highlight: [
      formatter: {:html_inline, theme: "github_light"}
    ])
    ````

- Sanitize HTML output, in this example disallow `<a>` tags:

    ````elixir
    MDEx.to_html!("""
    ## Links won't be displayed

    <a href="https://example.com">Example</a>
    ```
    """,
    sanitize: [
      rm_tags: ["a"],
    ])
    ````

## Options

* `:extension` (`t:keyword/0`) - Enable extensions. See comrak's [ExtensionOptions](https://docs.rs/comrak/latest/comrak/struct.ExtensionOptions.html) for more info and examples. The default value is `[]`.

  * `:strikethrough` (`t:boolean/0`) - Enables the [strikethrough extension](https://github.github.com/gfm/#strikethrough-extension-) from the GFM spec. The default value is `false`.

  * `:tagfilter` (`t:boolean/0`) - Enables the [tagfilter extension](https://github.github.com/gfm/#disallowed-raw-html-extension-) from the GFM spec. The default value is `false`.

  * `:table` (`t:boolean/0`) - Enables the [table extension](https://github.github.com/gfm/#tables-extension-) from the GFM spec. The default value is `false`.

  * `:autolink` (`t:boolean/0`) - Enables the [autolink extension](https://github.github.com/gfm/#autolinks-extension-) from the GFM spec. The default value is `false`.

  * `:tasklist` (`t:boolean/0`) - Enables the [task list extension](https://github.github.com/gfm/#task-list-items-extension-) from the GFM spec. The default value is `false`.

  * `:superscript` (`t:boolean/0`) - Enables the superscript Comrak extension. The default value is `false`.

  * `:header_ids` - Enables the header IDs Comrak extension. The default value is `nil`.

  * `:footnotes` (`t:boolean/0`) - Enables the footnotes extension per cmark-gfm The default value is `false`.

  * `:inline_footnotes` (`t:boolean/0`) - Enables inline footnotes with ^[footnote content] syntax The default value is `false`.

  * `:description_lists` (`t:boolean/0`) - Enables the description lists extension. The default value is `false`.

  * `:front_matter_delimiter` - Enables the front matter extension. The default value is `nil`.

  * `:multiline_block_quotes` (`t:boolean/0`) - Enables the multiline block quotes extension. The default value is `false`.

  * `:alerts` (`t:boolean/0`) - Enables GitHub style alerts. The default value is `false`.

  * `:math_dollars` (`t:boolean/0`) - Enables math using dollar syntax. The default value is `false`.

  * `:math_code` (`t:boolean/0`) - Enables the [math code extension](https://github.github.com/gfm/#math-code) from the GFM spec. The default value is `false`.

  * `:shortcodes` (`t:boolean/0`) - Phrases wrapped inside of ':' blocks will be replaced with emojis. The default value is `false`.

  * `:wikilinks_title_after_pipe` (`t:boolean/0`) - Enables wikilinks using title after pipe syntax. The default value is `false`.

  * `:wikilinks_title_before_pipe` (`t:boolean/0`) - Enables wikilinks using title before pipe syntax. The default value is `false`.

  * `:underline` (`t:boolean/0`) - Enables underlines using double underscores. The default value is `false`.

  * `:subscript` (`t:boolean/0`) - Enables subscript text using single tildes. The default value is `false`.

  * `:spoiler` (`t:boolean/0`) - Enables spoilers using double vertical bars. The default value is `false`.

  * `:greentext` (`t:boolean/0`) - Requires at least one space after a > character to generate a blockquote, and restarts blockquote nesting across unique lines of input. The default value is `false`.

  * `:subtext` (`t:boolean/0`) - Enables Discord-style subtext using curly braces with hyphens: {-text-}. The default value is `false`.

  * `:highlight` (`t:boolean/0`) - Enables the highlight extension using double equals ==highlighted text== (wraps text in <mark> tags). The default value is `false`.

  * `:insert` (`t:boolean/0`) - Enables the insert extension using double plus ++inserted text++ (wraps text in <ins> tags). The default value is `false`.

  * `:image_url_rewriter` - Wraps embedded image URLs using a string template.

      Example:

      Given this image `![alt text](http://unsafe.com/image.png)` and this rewriter:

        image_url_rewriter: "https://example.com?url={@url}"

      Renders `<p><img src="https://example.com?url=http://unsafe.com/image.png" alt="alt text" /></p>`

      Notes:

      - Assign `@url` is always passed to the template.
      - Function callback is not supported, only string templates.
        Transform the Document AST for more complex cases.

    The default value is `nil`.

  * `:link_url_rewriter` - Wraps link URLs using a string template.

      Example:

      Given this link `[my link](http://unsafe.example.com/bad)` and this rewriter:

        link_url_rewriter: "https://safe.example.com/norefer?url={@url}"

      Renders `<p><a href="https://safe.example.com/norefer?url=http://unsafe.example.com/bad">my link</a></p>`

      Notes:

      - Assign `@url` is always passed to the template.
      - Function callback is not supported, only string templates.
        Transform the Document AST for more complex cases.

    The default value is `nil`.

  * `:cjk_friendly_emphasis` (`t:boolean/0`) - Recognizes many emphasis that appear in CJK contexts but are not recognized by plain CommonMark. The default value is `false`.

  * `:phoenix_heex` (`t:boolean/0`) - Enables Phoenix HEEx components and expressions. The default value is `false`.

* `:parse` (`t:keyword/0`) - Configure parsing behavior. See comrak's [ParseOptions](https://docs.rs/comrak/latest/comrak/struct.ParseOptions.html) for more info and examples. The default value is `[]`.

  * `:smart` (`t:boolean/0`) - Punctuation (quotes, full-stops and hyphens) are converted into 'smart' punctuation. The default value is `false`.

  * `:default_info_string` - The default info string for fenced code blocks. The default value is `nil`.

  * `:relaxed_tasklist_matching` (`t:boolean/0`) - Whether or not a simple `x` or `X` is used for tasklist or any other symbol is allowed. The default value is `false`.

  * `:relaxed_autolinks` (`t:boolean/0`) - Relax parsing of autolinks, allow links to be detected inside brackets and allow all url schemes. It is intended to allow a very specific type of autolink detection, such as `[this http://and.com that]` or `{http://foo.com}`, on a best can basis. The default value is `true`.

  * `:ignore_setext` (`t:boolean/0`) - Ignore setext headings in input. The default value is `false`.

  * `:tasklist_in_table` (`t:boolean/0`) - Parse a tasklist item if it's the only content of a table cell. The default value is `false`.

  * `:leave_footnote_definitions` (`t:boolean/0`) - Leave footnote definitions inline instead of moving them to the end of the document. The default value is `false`.

  * `:escaped_char_spans` (`t:boolean/0`) - Wrap escaped characters in a <span> to allow any post-processing to recognize them. The default value is `false`.

* `:render` (`t:keyword/0`) - Configure rendering behavior. See comrak's [RenderOptions](https://docs.rs/comrak/latest/comrak/struct.RenderOptions.html) for more info and examples. The default value is `[]`.

  * `:hardbreaks` (`t:boolean/0`) - [Soft line breaks](http://spec.commonmark.org/0.27/#soft-line-breaks) in the input translate into hard line breaks in the output. The default value is `false`.

  * `:github_pre_lang` (`t:boolean/0`) - GitHub-style `<pre lang="xyz">` is used for fenced code blocks with info tags. The default value is `false`.

  * `:full_info_string` (`t:boolean/0`) - Enable full info strings for code blocks. The default value is `false`.

  * `:width` (`t:integer/0`) - The wrap column when outputting CommonMark. The default value is `0`.

  * `:unsafe` (`t:boolean/0`) - Allow rendering of raw HTML and potentially dangerous links. The default value is `false`.

  * `:escape` (`t:boolean/0`) - Escape raw HTML instead of clobbering it. The default value is `false`.

  * `:list_style` - Set the type of [bullet list marker](https://spec.commonmark.org/0.30/#bullet-list-marker) to use.
    Either one of `:dash`, `:plus`, or `:star`. The default value is `:dash`.

  * `:sourcepos` (`t:boolean/0`) - Include source position attributes in HTML and XML output. The default value is `false`.

  * `:escaped_char_spans` (`t:boolean/0`) - Wrap escaped characters in a `<span>` to allow any post-processing to recognize them. The default value is `false`.

  * `:ignore_empty_links` (`t:boolean/0`) - Ignore empty links in input. The default value is `false`.

  * `:gfm_quirks` (`t:boolean/0`) - Enables GFM quirks in HTML output which break CommonMark compatibility. The default value is `false`.

  * `:prefer_fenced` (`t:boolean/0`) - Prefer fenced code blocks when outputting CommonMark. The default value is `false`.

  * `:figure_with_caption` (`t:boolean/0`) - Render the image as a figure element with the title as its caption. The default value is `false`.

  * `:tasklist_classes` (`t:boolean/0`) - Add classes to the output of the tasklist extension. This allows tasklists to be styled. The default value is `false`.

  * `:ol_width` (`t:integer/0`) - Render ordered list with a minimum marker width. Having a width lower than 3 doesn't do anything. The default value is `1`.

  * `:experimental_minimize_commonmark` (`t:boolean/0`) - Minimise escapes used in CommonMark output (`-t commonmark`) by removing each individually and seeing if the resulting document roundtrips.
    Brute-force and expensive, but produces nicer output.
    Note that the result may not in fact be minimal. The default value is `false`.

* `:syntax_highlight` - Apply syntax highlighting to code blocks.

    Examples:

        syntax_highlight: [formatter: {:html_inline, theme: "github_dark"}]

        syntax_highlight: [formatter: {:html_linked, theme: "github_light"}]

    See [Lumis](https://hexdocs.pm/lumis) for more info and examples.

  The default value is `[formatter: {:html_inline, [theme: "onedark"]}]`.

* `:sanitize` - Cleans HTML using [ammonia](https://crates.io/crates/ammonia) after rendering.

  It's disabled by default but you can enable its [conservative set of default options](https://docs.rs/ammonia/latest/ammonia/fn.clean.html) as:

      [sanitize: MDEx.Document.default_sanitize_options()]

  Or customize one of the options. For example, to disallow `<a>` tags:

      [sanitize: [rm_tags: ["a"]]]

  In the example above it will append `rm_tags: ["a"]` into the default set of options, essentially the same as:

      sanitize = Keyword.put(MDEx.Document.default_sanitize_options(), :rm_tags, ["a"])
      [sanitize: sanitize]

  See the [Safety](#module-safety) section for more info.

  The default value is `nil`.

* `:streaming` (`t:boolean/0`) - Enables streaming. See the [Streaming guide](streaming.html) for details. The default value is `false`.

* `:assigns` (`t:map/0`) - A map of assigns available for use in pipelines, plugins, and HEEx rendering.

  Assigns can be set at document creation time:

      MDEx.new(assigns: %{title: "My Doc"})

  Or dynamically using `MDEx.Document.assign/2` and `MDEx.Document.assign/3`:

      document
      |> MDEx.Document.assign(:title, "My Doc")
      |> MDEx.Document.assign(author: "Jane", version: 1)

  When rendering HEEx templates, assigns are available as `@variables`:

      MDEx.to_heex!(document, assigns: %{name: "World"})
      # In the template: Hello, {@name}!

  The default value is `%{}`.

* `:plugins` (list of `t:term/0`) - A list of plugins to attach to the document.

  Each plugin may be one of:

  - `t:module/0` - A module that exposes `attach/1`
  - `{module, keyword}` - A module exposing `attach/2` with options
  - `(document -> document)` - A function that accepts and returns a document

  See the [Pipeline and Plugins](#module-pipeline-and-plugins) section for more info.

  ## Examples

      MDEx.to_html!("# Hello", plugins: [MDExGFM])

      MDEx.to_html!("# Hello", plugins: [{MDExMermaid, version: "11"}])

  The default value is `[]`.

* `:codefence_renderers` (`t:map/0`) - Provide language-specific renderers for codefence blocks.

  See [Codefence Renderers examples](https://hexdocs.pm/mdex/codefence_renderers.html) for more info.

  The default value is `%{}`.