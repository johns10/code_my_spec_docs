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

## register_options/2

Registers a list of valid options that can be used by steps in the document pipeline.

## Examples

    iex> document = MDEx.new()
    iex> document = MDEx.Document.register_options(document, [:mermaid_version])
    iex> document = MDEx.Document.put_options(document, mermaid_version: "11")
    iex> document.options[:mermaid_version]
    "11"

    iex> MDEx.new(rendr: [unsafe: true])
    ** (ArgumentError) unknown option :rendr. Did you mean :render?

## put_options/2

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

## put_extension_options/2

Updates the document's `:extension` options.

## Examples

    iex> document = MDEx.Document.put_extension_options(MDEx.new(), table: true)
    iex> MDEx.Document.get_option(document, :extension)[:table]
    true

## put_render_options/2

Updates the document's `:render` options.

## Examples

    iex> document = MDEx.Document.put_render_options(MDEx.new(), escape: true)
    iex> MDEx.Document.get_option(document, :render)[:escape]
    true

## put_parse_options/2

Updates the document's `:parse` options.

## Examples

    iex> document = MDEx.Document.put_parse_options(MDEx.new(), smart: true)
    iex> MDEx.Document.get_option(document, :parse)[:smart]
    true

## put_syntax_highlight_options/2

Updates the document's `:syntax_highlight` options.

## Examples

    iex> document = MDEx.Document.put_syntax_highlight_options(MDEx.new(), formatter: :html_linked)
    iex> MDEx.Document.get_option(document, :syntax_highlight)[:formatter]
    :html_linked

## put_sanitize_options/2

Updates the document's `:sanitize` options.

## Examples

    iex> document = MDEx.Document.put_sanitize_options(MDEx.new(), add_tags: ["MyComponent"])
    iex> MDEx.Document.get_option(document, :sanitize)[:add_tags]
    ["MyComponent"]

## put_plugins/2

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

## put_codefence_renderers/2

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

## get_option/3

Retrieves an option value from the document.

## Examples

    iex> document = MDEx.new(render: [escape: true])
    iex> MDEx.Document.get_option(document, :render)[:escape]
    true

## assign/2

Adds key-value pairs to the document assigns.

## Examples

    iex> document = MDEx.Document.assign(MDEx.new(), title: "Hello", author: "Jane")
    iex> MDEx.Document.get_option(document, :assigns)
    %{title: "Hello", author: "Jane"}

    iex> document = MDEx.Document.assign(MDEx.new(), %{title: "Hello"})
    iex> MDEx.Document.get_option(document, :assigns)
    %{title: "Hello"}

## assign/3

Adds a key-value pair to the document assigns.

## Examples

    iex> document = MDEx.Document.assign(MDEx.new(), :title, "Hello")
    iex> MDEx.Document.get_option(document, :assigns)
    %{title: "Hello"}

## get_sanitize_option/3

Retrieves one of the `t:sanitize_options/0` options from the document.

## Examples

    iex> document =
    ...>   MDEx.new()
    ...>   |> MDEx.Document.put_sanitize_options(add_tags: ["x-component"])
    iex> MDEx.Document.get_sanitize_option(document, :add_tags)
    ["x-component"]

## is_sanitize_enabled/1

Returns `true` if the document has the `:sanitize` option set, otherwise `false`.

## get_private/3

Retrieves a private value from the document.

## Examples

    iex> document = MDEx.new() |> MDEx.Document.put_private(:count, 2)
    iex> MDEx.Document.get_private(document, :count)
    2

## update_private/4

Updates a value in the document's private storage using a function.

## Examples

    iex> document = MDEx.new() |> MDEx.Document.put_private(:count, 1)
    iex> document = MDEx.Document.update_private(document, :count, 0, &(&1 + 1))
    iex> MDEx.Document.get_private(document, :count)
    2

## put_private/3

Stores a value in the document's private storage.

## Examples

    iex> document = MDEx.Document.put_private(MDEx.new(), :mermaid_version, "11")
    iex> MDEx.Document.get_private(document, :mermaid_version)
    "11"

## append_steps/2

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

## prepend_steps/2

Prepends steps to the beginning of the existing document's step list.

## halt/1

Halts the document pipeline execution.

This function is used to stop the pipeline from processing any further steps. Once a pipeline
is halted, no more steps will be executed. This is useful for plugins that need to stop
processing when certain conditions are met or when an error occurs.

## Examples

    iex> document = MDEx.Document.halt(MDEx.new())
    iex> document.halted
    true

## halt/2

Halts the document pipeline execution with an exception.

## run/1

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

## put_node_in_document_root/3

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

## put_markdown/3

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

## update_nodes/3

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

## wrap/1

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

## fetch/2

Callback implementation for `Access.fetch/2`.

See the [Access](#module-access) section for more info.

## get_and_update/3

Callback implementation for `Access.get_and_update/3`.

See the [Access](#module-access) section for more info.

## pop/3

Callback implementation for `Access.fetch/2`.

See the [Access](#module-access) section for more info.