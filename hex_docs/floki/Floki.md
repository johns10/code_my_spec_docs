# Floki

Floki is a simple HTML parser that enables search for nodes using CSS selectors.

## Example

Assuming that you have the following HTML:

```html
<!doctype html>
<html>
<body>
  <section id="content">
    <p class="headline">Floki</p>
    <a href="http://github.com/philss/floki">Github page</a>
    <span data-model="user">philss</span>
  </section>
</body>
</html>
```

To parse this, you can use the function `Floki.parse_document/1`:

```elixir
{:ok, html} = Floki.parse_document(doc)
# =>
# [{"html", [],
#   [
#     {"body", [],
#      [
#        {"section", [{"id", "content"}],
#         [
#           {"p", [{"class", "headline"}], ["Floki"]},
#           {"a", [{"href", "http://github.com/philss/floki"}], ["Github page"]},
#           {"span", [{"data-model", "user"}], ["philss"]}
#         ]}
#      ]}
#   ]}]
```

With this document you can perform queries such as:

  * `Floki.find(html, "#content")`
  * `Floki.find(html, ".headline")`
  * `Floki.find(html, "a")`
  * `Floki.find(html, "[data-model=user]")`
  * `Floki.find(html, "#content a")`
  * `Floki.find(html, ".headline, a")`

Each HTML node is represented by a tuple like:

    {tag_name, attributes, children_nodes}

Example of node:

    {"p", [{"class", "headline"}], ["Floki"]}

So even if the only child node is the element text, it is represented
inside a list.

## attr(html_elem_tuple, selector, attribute_name, mutation)

Changes the attribute values of the elements matched by `selector`
with the function `mutation` and returns the whole element tree.

## Examples

    iex> Floki.attr([{"div", [{"id", "a"}], []}], "#a", "id", fn(id) -> String.replace(id, "a", "b") end)
    [{"div", [{"id", "b"}], []}]

    iex> Floki.attr([{"div", [{"class", "name"}], []}], "div", "id", fn _ -> "b" end)
    [{"div", [{"id", "b"}, {"class", "name"}], []}]

## attribute(elements, attribute_name)

Returns a list with attribute values from elements.

## Examples

    iex> Floki.attribute([{"a", [{"href", "https://google.com"}], ["Google"]}], "href")
    ["https://google.com"]

    iex> Floki.attribute([{"a", [{"href", "https://google.com"}, {"data-name", "google"}], ["Google"]}], "data-name")
    ["google"]

## attribute(html, selector, attribute_name)

Returns a list with attribute values for a given selector.

## Examples

    iex> Floki.attribute([{"a", [{"href", "https://google.com"}], ["Google"]}], "a", "href")
    ["https://google.com"]

    iex> Floki.attribute(
    iex>   [{"a", [{"class", "foo"}, {"href", "https://google.com"}], ["Google"]}],
    iex>   "a",
    iex>   "class"
    iex> )
    ["foo"]

    iex> Floki.attribute(
    iex>   [{"a", [{"href", "https://e.corp.com"}, {"data-name", "e.corp"}], ["E.Corp"]}],
    iex>   "a[data-name]",
    iex>   "data-name"
    iex> )
    ["e.corp"]

## children(html_node, opts \\ [include_text: true])

Returns the direct child nodes of a HTML node.

By default, it will also include all texts. You can disable
this behaviour by using the option `include_text` to `false`.

If the given node is not an HTML tag, then it returns nil.

## Examples

    iex> Floki.children({"div", [], ["text", {"span", [], []}]})
    ["text", {"span", [], []}]

    iex> Floki.children({"div", [], ["text", {"span", [], []}]}, include_text: false)
    [{"span", [], []}]

    iex> Floki.children({:comment, "comment"})
    nil

## css_escape(value)

Escapes a string for use as a CSS identifier.

## Examples

    iex> Floki.css_escape("hello world")
    "hello\\ world"

    iex> Floki.css_escape("-123")
    "-\\31 23"

## filter_out(elements, selector)

Returns the nodes from a HTML tree that don't match the filter selector.

## Examples

    iex> Floki.filter_out({"div", [], [{"script", [], ["hello"]}, " world"]}, "script")
    {"div", [], [" world"]}

    iex> Floki.filter_out([{"body", [], [{"script", [], []}, {"div", [], []}]}], "script")
    [{"body", [], [{"div", [], []}]}]

    iex> Floki.filter_out({"div", [], [{:comment, "comment"}, " text"]}, :comment)
    {"div", [], [" text"]}

    iex> Floki.filter_out({"div", [], ["text"]}, :text)
    {"div", [], []}

## find(html_tree_as_tuple, selector)

Find elements inside an HTML tree or string.

## Examples

    iex> {:ok, html} = Floki.parse_fragment("<p><span class=hint>hello</span></p>")
    iex> Floki.find(html, ".hint")
    [{"span", [{"class", "hint"}], ["hello"]}]

    iex> {:ok, html} = Floki.parse_fragment("<div id=important><div>Content</div></div>")
    iex> Floki.find(html, "#important")
    [{"div", [{"id", "important"}], [{"div", [], ["Content"]}]}]

    iex> {:ok, html} = Floki.parse_fragment("<p><a href='https://google.com'>Google</a></p>")
    iex> Floki.find(html, "a")
    [{"a", [{"href", "https://google.com"}], ["Google"]}]

    iex> Floki.find([{ "div", [], [{"a", [{"href", "https://google.com"}], ["Google"]}]}], "div a")
    [{"a", [{"href", "https://google.com"}], ["Google"]}]

## find_and_update(html_tree, selector, fun)

Searches for elements inside the HTML tree and update those that matches the selector.

It will return the updated HTML tree.

This function works in a way similar to `traverse_and_update`, but instead of updating
the children nodes, it will only updates the `tag` and `attributes` of the matching nodes.

If `fun` returns `:delete`, the HTML node will be removed from the tree.

## Examples

    iex> Floki.find_and_update([{"a", [{"href", "http://elixir-lang.com"}], ["Elixir"]}], "a", fn
    iex>   {"a", [{"href", href}]} ->
    iex>     {"a", [{"href", String.replace(href, "http://", "https://")}]}
    iex>   other ->
    iex>     other
    iex> end)
    [{"a", [{"href", "https://elixir-lang.com"}], ["Elixir"]}]

## get_by_id(html_tree_as_tuple, id)

Finds the first element in an HTML tree by id.

Returns `nil` if no element is found.

This is useful when there are IDs that contain special characters that
are invalid when passed as is as a CSS selector.
It is similar to the `getElementById` method in the browser.

## Examples

    iex> {:ok, html} = Floki.parse_fragment(~s[<p><span class="hint" id="id?foo_special:chars">hello</span></p>])
    iex> Floki.get_by_id(html, "id?foo_special:chars")
    {"span", [{"class", "hint"}, {"id", "id?foo_special:chars"}], ["hello"]}
    iex> Floki.get_by_id(html, "does-not-exist")
    nil

## parse_document(document, opts \\ [])

Parses an HTML document from a string.

This is the main function to get a tree from an HTML string.

## Options

  * `:attributes_as_maps` - Change the behaviour of the parser to return the attributes
    as maps, instead of a list of `{"key", "value"}`. Default to `false`.

  * `:html_parser` - The module of the backend that is responsible for parsing
    the HTML string. By default it is set to the built-in parser, and the module
    name is equal to `Floki.HTMLParser.Mochiweb`, or from the value of the
    application env of the same name.

    See https://github.com/philss/floki#alternative-html-parsers for more details.

  * `:parser_args` - A list of options to the parser. This can be used to pass options
    that are specific for a given parser. Defaults to an empty list.

## Examples

    iex> Floki.parse_document("<html><head></head><body>hello</body></html>")
    {:ok, [{"html", [], [{"head", [], []}, {"body", [], ["hello"]}]}]}

    iex> Floki.parse_document("<html><head></head><body>hello</body></html>", html_parser: Floki.HTMLParser.Mochiweb)
    {:ok, [{"html", [], [{"head", [], []}, {"body", [], ["hello"]}]}]}

    iex> Floki.parse_document(
    ...>   "<html><head></head><body class=main>hello</body></html>",
    ...>   attributes_as_maps: true,
    ...>   html_parser: Floki.HTMLParser.Mochiweb
    ...>)
    {:ok, [{"html", %{}, [{"head", %{}, []}, {"body", %{"class" => "main"}, ["hello"]}]}]}

## parse_document!(document, opts \\ [])

Parses a HTML Document from a string.

Similar to `Floki.parse_document/1`, but raises `Floki.ParseError` if there was an
error parsing the document.

## Example

    iex> Floki.parse_document!("<html><head></head><body>hello</body></html>")
    [{"html", [], [{"head", [], []}, {"body", [], ["hello"]}]}]

## parse_fragment(fragment, opts \\ [])

Parses an HTML fragment from a string.

This is mostly for parsing sections of an HTML document.

## Options

  * `:attributes_as_maps` - Change the behaviour of the parser to return the attributes
    as maps, instead of a list of `{"key", "value"}`. Remember that maps are no longer
    ordered since OTP 26. Default to `false`.

  * `:html_parser` - The module of the backend that is responsible for parsing
    the HTML string. By default it is set to the built-in parser, and the module
    name is equal to `Floki.HTMLParser.Mochiweb`, or from the value of the
    application env of the same name.

    See https://github.com/philss/floki#alternative-html-parsers for more details.

  * `:parser_args` - A list of options to the parser. This can be used to pass options
    that are specific for a given parser. Defaults to an empty list.

## parse_fragment!(fragment, opts \\ [])

Parses a HTML fragment from a string.

Similar to `Floki.parse_fragment/1`, but raises `Floki.ParseError` if there was an
error parsing the fragment.

## raw_html(html_tree, options \\ [])

Converts HTML tree to raw HTML.

Note that the resultant HTML may be different from the original one.
Spaces after tags and doctypes are ignored.

## Options

  * `:encode` - A boolean option to control if special HTML characters
  should be encoded as HTML entities. Defaults to `true`.

  You can also control the encoding behaviour at the application level via
  `config :floki, :encode_raw_html, false`

  * `:pretty` - Controls if the output should be formatted, ignoring
  breaklines and spaces from the input and putting new ones in order
  to pretty format the html. Defaults to `false`.

## Examples

    iex> Floki.raw_html({"div", [{"class", "wrapper"}], ["my content"]})
    ~s(<div class="wrapper">my content</div>)

    iex> Floki.raw_html({"div", [{"class", "wrapper"}], ["10 > 5"]})
    ~s(<div class="wrapper">10 &gt; 5</div>)

    iex> Floki.raw_html({"div", [{"class", "wrapper"}], ["10 > 5"]}, encode: false)
    ~s(<div class="wrapper">10 > 5</div>)

    iex> Floki.raw_html({"div", [], ["\n   ", {"span", [], "Fully indented"}, "    \n"]}, pretty: true)
    """
    <div>
      <span>
        Fully indented
      </span>
    </div>
    """

## text(html, opts \\ [])

Returns the text nodes from a HTML tree.

By default, it will perform a deep search through the HTML tree.
You can disable deep search with the option `deep` assigned to false.
You can include content of script or style tags by setting the `:js` or 
`:style` flags, respectively, to true.
You can specify a separator between nodes content.

## Options

  * `:deep` - A boolean option to control how deep the search for
    text is going to be. If `false`, only the level of the HTML node
    or the first level of the HTML document is going to be considered.
    Defaults to `true`.

  * `:js` - A boolean option to control if the contents of `<script>` tags
    should be considered as text. Defaults to `false`.

  * `:style` - A boolean to control if the contents of `<style>` tags
    should be considered as text. Defaults to `false`.

  * `:sep` - A separator string that is added between text nodes.
    Defaults to `""`.

  * `:include_inputs` - A boolean to control if `<input>` or `<textarea>`
    values should be included in the resultant string.
    Defaults to `false`.

  * `:html_parser` - The module of the backend that is responsible for parsing
    the HTML string. By default it is set to `Floki.HTMLParser.Mochiweb`.

## Examples

    iex> Floki.text({"div", [], [{"span", [], ["hello"]}, " world"]})
    "hello world"

    iex> Floki.text({"div", [], [{"span", [], ["hello"]}, " world"]}, deep: false)
    " world"

    iex> Floki.text({"div", [], [{"script", [], ["hello"]}, " world"]})
    " world"

    iex> Floki.text([{"input", [{"type", "date"}, {"value", "2017-06-01"}], []}], include_inputs: true)
    "2017-06-01"

    iex> Floki.text({"div", [], [{"script", [], ["hello"]}, " world"]}, js: true)
    "hello world"

    iex> Floki.text({"ul", [], [{"li", [], ["hello"]}, {"li", [], ["world"]}]}, sep: "-")
    "hello-world"

    iex> Floki.text([{"div", [], ["hello world"]}])
    "hello world"

    iex> Floki.text([{"p", [], ["1"]},{"p", [], ["2"]}])
    "12"

    iex> Floki.text({"div", [], [{"style", [], ["hello"]}, " world"]}, style: false)
    " world"

    iex> Floki.text({"div", [], [{"style", [], ["hello"]}, " world"]}, style: true)
    "hello world"

## traverse_and_update(html_tree, fun)

Traverses and updates a HTML tree structure.

This function returns a new tree structure that is the result of applying the
given `fun` on all nodes except text nodes.
The tree is traversed in a post-walk fashion, where the children are traversed
before the parent.

When the function `fun` encounters HTML tag, it receives a tuple with `{name,
attributes, children}`, and should either return a similar tuple, a list of
tuples to split current node or `nil` to delete it.

The function `fun` can also encounter HTML doctype, comment or declaration and
will receive, and should return, different tuple for these types. See the
documentation for `t:html_comment/0`, `t:html_doctype/0` and
`t:html_declaration/0` for details.

**Note**: this won't update text nodes, but you can transform them when working
with children nodes.

## Examples

    iex> html = [{"div", [], ["hello"]}]
    iex> Floki.traverse_and_update(html, fn
    ...>   {"div", attrs, children} -> {"p", attrs, children}
    ...>   other -> other
    ...> end)
    [{"p", [], ["hello"]}]

    iex> html = [{"div", [], [{:comment, "I am comment"}, {"span", [], ["hello"]}]}]
    iex> Floki.traverse_and_update(html, fn
    ...>   {"span", _attrs, _children} -> nil
    ...>   {:comment, text} -> {"span", [], text}
    ...>   other -> other
    ...> end)
    [{"div", [], [{"span", [], "I am comment"}]}]

## traverse_and_update(html_tree, acc, fun)

Traverses and updates a HTML tree structure with an accumulator.

This function returns a new tree structure and the final value of accumulator
which are the result of applying the given `fun` on all nodes except text nodes.
The tree is traversed in a post-walk fashion, where the children are traversed
before the parent.

When the function `fun` encounters HTML tag, it receives a tuple with
`{name, attributes, children}` and an accumulator. It and should return a
2-tuple like `{new_node, new_acc}`, where `new_node` is either a similar tuple
or `nil` to delete the current node, and `new_acc` is an updated value for the
accumulator.

The function `fun` can also encounter HTML doctype, comment or declaration and
will receive, and should return, different tuple for these types. See the
documentation for `t:html_comment/0`, `t:html_doctype/0` and
`t:html_declaration/0` for details.

**Note**: this won't update text nodes, but you can transform them when working
with children nodes.

## Examples

    iex> html = [{"div", [], [{:comment, "I am a comment"}, "hello"]}, {"div", [], ["world"]}]
    iex> Floki.traverse_and_update(html, 0, fn
    ...>   {"div", attrs, children}, acc ->
    ...>     {{"p", [{"data-count", to_string(acc)} | attrs], children}, acc + 1}
    ...>   other, acc -> {other, acc}
    ...> end)
    {[
       {"p", [{"data-count", "0"}], [{:comment, "I am a comment"}, "hello"]},
       {"p", [{"data-count", "1"}], ["world"]}
     ], 2}

    iex> html = {"div", [], [{"span", [], ["hello"]}]}
    iex> Floki.traverse_and_update(html, [deleted: 0], fn
    ...>   {"span", _attrs, _children}, acc ->
    ...>     {nil, Keyword.put(acc, :deleted, acc[:deleted] + 1)}
    ...>   tag, acc ->
    ...>     {tag, acc}
    ...> end)
    {{"div", [], []}, [deleted: 1]}